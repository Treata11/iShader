/*
 BassAudioEngine.swift
 MuVis

 Created by Keith Bromley on 2/24/23.
 
 Abstract:
 The BassAudioEngine class handles the playing, capture, and processing of audio data in real time.
 This version of the BassAudioEngine uses the BASS audio library from [un4seen](https://www.un4seen.com) .
*/

#if os(iOS) || os(macOS)
import CBass
import Foundation
import Observation

// Declare and intialize global constants and variables:
var showMSPF: Bool = true       // display the Performance Monitor's "milliseconds per frame"

var usingBlackHole: Bool = false // true if using BlackHole as sole audio input (macOS only)
// To use BlackHole audio driver: SystemSettings | Sound, set Input to BlackHole 2ch; set Ouput to Multi-Output Device.
// To use micOn: SystemSettings | Sound, Input: MacBook Pro Microphone; Ouput: Multi-Output Device

let notesPerOctave   = 12       // An octave contains 12 musical notes.
let pointsPerNote    = 12       // The number of frequency samples within one musical note.
let pointsPerOctave  = notesPerOctave * pointsPerNote  // 12 * 12 = 144

let eightOctNoteCount   = 96    // from C1 to B8 is 96 notes  (  0 <= note < 96 ) (This covers 8 octaves.)
let eightOctPointCount  = eightOctNoteCount * pointsPerNote  // 96 * 12 = 1,152  // number of points in 8 octaves

let sixOctNoteCount  = 72       // the number of notes within six octaves
let sixOctPointCount = sixOctNoteCount * pointsPerNote  // 72 * 12 = 864   // number of points within six octaves

let historyCount    = 48        // Keep the 48 most-recent values of muSpectrum[point] in a circular buffer
let peakCount       = 16        // We only consider the loudest 16 spectral peaks.
let peaksHistCount  = 100       // Keep the 100 most-recent values of peakBinNumbers in a circular buffer

// Create a 96-element array of accidental notes to render the keyboard (denoting white and black keys) in the background:
//                              C      C#    D      D#    E      F      F#    G      G#    A      A#    B
let accidentalNotes: [Bool] = [ false, true, false, true, false, false, true, false, true, false, true, false,
                                false, true, false, true, false, false, true, false, true, false, true, false,
                                false, true, false, true, false, false, true, false, true, false, true, false,
                                false, true, false, true, false, false, true, false, true, false, true, false,
                                false, true, false, true, false, false, true, false, true, false, true, false,
                                false, true, false, true, false, false, true, false, true, false, true, false,
                                false, true, false, true, false, false, true, false, true, false, true, false,
                                false, true, false, true, false, false, true, false, true, false, true, false ]


/**
 The BassAudioEngine class handles the playing, capture, and processing of audio data in real time.
 This version of the BassAudioEngine uses the BASS audio library from [un4seen](https://www.un4seen.com) .
 
 When this class is first run, it plays the song file named music.mp3 located in the app's bundle .  Pressing the "Select Song" button in the ContentView struct allows the user to change to any song file located on his device.  Also, pressing the "MicOn" button, changes the micEnabled variable to true, and causes this class to processes live audio data from the microphone.

 The input audio signal is sampled at 44,100 samples per second.
 Our FFT window of 16,384 samples has a duration of 16,384 / 44,100 = 0.37152 seconds.
 We calculate a new spectrum every 1/60 seconds (that is, 0.01666 seconds), hence our window overlap factor is (0.37152-0.016666)/0.37152 = 95%
 If we calculate a new spectrum every 1/20 seconds (that is, 0.05000 seconds), hence our window overlap factor is (0.37152-0.050000)/0.37152 = 86%
 If we calculate a new spectrum every 1/10 seconds (that is, 0.10000 seconds), hence our window overlap factor is (0.37152-0.100000)/0.37152 = 73%

 If the firing time is delayed so far that it passes one or more of the scheduled firing times, the timer is fired only once for that time period; the timer is then rescheduled, after firing, for the next scheduled firing time in the future.

 If the repeating Timer is scheduled to fire ever 17 msec, but the graphics task takes 20 msec, then it will fire at 0, 20, 34, 54, 68, 78
                                                                     difference:       20, 14, 20, 14, 20

 From Ian on 230327:  On most platforms, BASS can detect and use the device's current rate, and so the BASS_Init "freq" parameter has no effect on the output. An exception is on Linux, where the specified rate will be used if it's supported. It can also be applied on macOS/iOS (changing the device's current rate) with the BASS_DEVICE_FREQ flag. In all cases, BASS's actual output rate can be confirmed with BASS_GetInfo.

 A repeating timer reschedules itself automatically based on the scheduled firing time, not the actual firing time. For example, if a timer is scheduled to fire at a particular time and every 5 seconds after that, the scheduled firing time will always fall on the original 5 second time intervals, even if the actual firing time gets delayed. If the firing time is delayed so much that it misses one or more of the scheduled firing times, the timer is fired only once for the missed time period. After firing for the missed period, the timer is rescheduled for the next scheduled firing time.

 timer.invalidate()   This method is the only way to remove a timer from an RunLoop object. The RunLoop object removes its strong reference to the timer, either just before the invalidate() method returns or at some later point.  If it was configured with target and user info objects, the receiver removes its strong references to those objects as well.  You must send this message from the thread on which the timer was installed. If you send this message from another thread, the input source associated with the timer may not be removed from its run loop, which could prevent the thread from exiting properly.
 */
@Observable
public class BassAudioEngine {
    /// This singleton instantiates the BassAudioEngine class and runs setupAudio()
    static let shared = BassAudioEngine()
    
    private let spectralEnhancer = SpectralEnhancer()
    private let peaksSorter = PeaksSorter()
    private let noteProc = NoteProcessing()
    
    static let sampleRate: Double = 44100.0     // We will process the audio data at 44,100 samples per second.
    static let fftLength: Int = 16384           // The number of audio samples inputted to the FFT operation each frame.
    static let binCount: Int = fftLength/2      // The number of frequency bins provided in the FFT output
                                                // binCount = 8,192 for fftLength = 16,384

    static let binFreqWidth: Double = (sampleRate/2) / Double(binCount) //binFreqWidth = (44100/2)/8192  = 2.69165 Hz

    var isPaused = false      // When paused, don't overwrite the previous rendering with all-zeroes:
    var micOn = false         // true means microphone is on and its audio is being captured.

    /// Play this song when the MuVis app starts:
    @ObservationIgnored var filePath: String?    // changed in ContentView by Button("Song")
    
    @ObservationIgnored var userGain: Float = getGain()         // The getGain() func is located at the bottom of this file.
    @ObservationIgnored var userSlope: Float = getSlope()       // The getSlope() func is located at the bottom of this file.
    @ObservationIgnored var onlyPeaks: Bool = getOnlyPeaks()    // The getOnlyPeaks() func is located at the bottom of this file.

    @ObservationIgnored var skipHist: Int = 0       // number of muSpectra to skip between adding to muSpecHistory array
    @ObservationIgnored var skipCounter: Int = 0    // temporary counter to decide skipping in adding to muSpecHistory array

    // Declare arrays of the final values (for this frame) that we will publish to the various visualizations:
    
    // Declare an array to contain the first 3,022 binValues of the current window of audio spectral data:
    public var spectrum = [Float](repeating: 0, count: NoteProcessing.binCount8)   // binCount8 = 3,022
    
    // Declare an array to contain the 96 * 12 = 1,152 points of the current muSpectrum of the audio data:
    public var muSpectrum = [Float](repeating: 0, count: eightOctPointCount)
    
    // Declare two arrays to store the 16 loudest peak bin numbers and their amplitudes of the spectrum:
    private(set) var peakBinNumbers = [Int](repeating: 0,   count: peakCount)   // bin numbers of the spectral peaks
    private(set) var peakAmps = [Double](repeating: 0, count: peakCount)      // amplitudes of the spectral peaks
    private(set) var currentNotes = [Int](repeating: 0, count: 8)               // estimate of notes currently playing
    
    // Declare a circular buffer to store the past 48 blocks of the first six octaves of the spectrum.
    // It stores 48 * 756 = 36,288 bins
    private(set) var spectrumHistory = [Float](repeating: 0, count: historyCount * NoteProcessing.binCount6)
    
    // Declare a circular array to store the past 48 blocks of the first six octaves of the muSpectrum.
    // It stores 48 * 72 * 12 = 41,472 points
    private(set) var muSpecHistory = [Float](repeating: 0, count: historyCount * sixOctPointCount)
    
    // Declare a circular array to store the past 100 blocks of the 16 loudest peak bin numbers of the spectrum:
    // It stores 100 * 16 = 1,600 bin numbers
    private(set) var peaksHistory = [Int](repeating: 0, count: peaksHistCount * peakCount)
    
    // Declare a circular array to store the past 100 blocks of the 8 current (estimated) notes:
    // It stores 100 * 8 = 800 note numbers
    private(set) var notesHistory = [Int](repeating: 0, count: peaksHistCount * 8)
    
    // Variables used for performance monitoring:
    @ObservationIgnored var startTime = Date()
    @ObservationIgnored var endTime = Date()
    @ObservationIgnored var averageTime: Double = .zero
    @ObservationIgnored var durationArray = [Double](repeating: 0, count: 100) // an array of the 10 most-recent interval durations
    @ObservationIgnored private var fps: Double
    
    // MARK: - BASS Framework
    private var stream: HSTREAM = 0
    
    func startMusicPlay() { BASS_Start() }
    func pauseMusicPlay() { BASS_Pause() }
    func stopMusicPlay()  { BASS_Stop(); BASS_Free() }

    // MARK: - Init(s)
    
    public init(filePath: String? = nil, fps: Double = 48) {
        self.filePath = filePath
        self.fps = fps
        
        processAudio()
    }

    // MARK: - processAudio
   
    func processAudio() {
        // Set up the BASS audio library:
        
        // Initialize the output device (i.e., speakers) that BASS should use:
        BASS_Init(  -1,                                 // device: -1 is the default device; 0 is no sound output
                     UInt32(BassAudioEngine.sampleRate),   // freq: output sample rate is 44,100 sps
                     0,                                 // flags: DWORD
                     nil,                               // win: 0 = the desktop window (for console applications)
                     nil)                               // dsguid: Unused, set to nil
        // The sample format specified in the freq and flags parameters has no effect on the output on macOS or iOS.
        // The device's native sample format is automatically used.
        
        if micOn || usingBlackHole {

            // Initialize the input device (i.e., microphone) that BASS should use:
            BASS_RecordInit(-1)     // device = -1 is the default input device

            // Create a sample stream from our live microphone input:
            stream = BASS_RecordStart(  44100,          // freq: the sample rate to record at
                                        1,              // chans: number of audio channels, 1 = mono
                                        0,              // flags:
                                        myRecordProc,   // callback proc:
                                        nil)            // user:

            func myRecordProc(_: HRECORD, _: UnsafeRawPointer?, _: DWORD, _: UnsafeMutableRawPointer?) -> BOOL32{
                return BOOL32(truncating: true)         // continue recording
            }

        } else {

            // Create a sample stream from our MP3 song file:
            stream = BASS_StreamCreateFile( BOOL32(truncating: false),  // mem: false = stream file from a filename
                                            filePath,                   // file:
                                            0,                          // offset:
                                            0,                          // length: 0 = use all data up to end of file
                                            0)                          // flags:

            BASS_ChannelPlay(stream, -1) // starts the output
        }

        //--------------------------------------------------------------------------------------------------------------

        // Declare an array to contain all 8,192 binValues of the current window of audio spectral data:
        var fullSpectrum = [Float](repeating: 0, count: BassAudioEngine.binCount)   // binCount  = 8,192

        // Compute the 8,192-bin spectrum of the song waveform every 1/fps seconds:
        Timer.scheduledTimer(withTimeInterval: 1/fps, repeats: true) { [self] _ in
            DispatchQueue.global().async {
                BASS_ChannelGetData(self.stream, &fullSpectrum, BASS_DATA_FFT16384)
            }
                
            DispatchQueue.global().sync {
                // Normalize the rms amplitudes to be loosely within the range 0.0 to 1.0:
                // Truncate the fullSpectrum array of size 8,192 to the spectrum array of size 3,022:
                for bin in 0 ..< NoteProcessing.binCount8 {
                    let scalingFactor: Float = userGain + userSlope * Float(bin)
                    // !!!: Can not be async; Thread 15: Fatal error: UnsafeMutablePointer.initialize overlapping range
                    // fullSpectrum crashes the app when called Async ... Race conditions?
                    spectrum[bin] = scalingFactor * fullSpectrum[bin]
                }
            }

            if onlyPeaks { spectrum = spectralEnhancer.enhance(inputArray: spectrum) }

//            if showMSPF { averageTime = monitorPerformance() }

            //----------------------------------------------------------------------------------------------------------
            // Calculate the sixteen loudest spectral peaks within the 6-octave spectrum:
            // Get the sortedPeakBinNumbers for our 6-octave spectrum:
            let lowerBin: Int = noteProc.octBottomBin[0]    // lowerBin =  12
            let upperBin: Int = noteProc.octTopBin[5]       // upperBin = 755

            let result = peaksSorter.getSortedPeaks(    binValues: spectrum,
                                                        bottomBin: lowerBin,
                                                        topBin: upperBin,
                                                        peakThreshold: 0.1)
            peakBinNumbers = result.sortedPeakBinNumbers
            peakAmps = result.sortedPeakAmplitudes
            currentNotes = noteProc.computeCurrentNotes(inputArray: peakBinNumbers)

            //----------------------------------------------------------------------------------------------------------
            // Enhance the spectrum to the muSpectrum:  The muSpectrum array has 96 * 12 = 1,152 points
            muSpectrum = noteProc.computeMuSpectrum(inputArray: spectrum)

            //----------------------------------------------------------------------------------------------------------
            
            // Store the first 756 bins of the current spectrum array into the spectrumHistory array (48 * 756 bins):
            let spectrum6 = Array( spectrum[0 ..< NoteProcessing.binCount6] )
            spectrumHistory.removeFirst(NoteProcessing.binCount6) // requires 0 <= binCount6 <= spectrumHistory.count
            spectrumHistory.append(contentsOf: spectrum6)
            // Note that the newest data is at the end of the spectrumHistory array.
            
            if skipCounter == 0 {
                // Store the current muSpectrum6 array (72*12 points) into the pointHistoryBuffer array (48*72*12 points):
                let muSpectrum6 = Array( muSpectrum[0 ..< sixOctPointCount] )  // Reduce pointCount from 1152 to 864
                muSpecHistory.removeFirst(sixOctPointCount) // requires 0 <= sixOctPointCount <= muSpecHistory.count
                muSpecHistory.append(contentsOf: muSpectrum6)
                // Note that the newest data is at the end of the muSpecHistory array.
            }
            skipCounter = (skipCounter >= skipHist) ? 0 : skipCounter + 1
            
            // Store current sortedPeakBinNumbers array (16 binNums) into the peaksHistoryBuffer array (100*16 binNums):
            peaksHistory.removeFirst(peakCount)        // requires that  0 <= peakCount <= peaksHistory.count
            peaksHistory.append(contentsOf: peakBinNumbers)
            // Note that the newest data is at the end of the peaksHistory array.

            // Store current currentNotes array (8 noteNums) into the notesHistory array (100 * 8 noteNums):
            notesHistory.removeFirst(8)        // requires that  0 <= 8 <= notesHistory.count
            notesHistory.append(contentsOf: currentNotes)
            // Note that the newest data is at the end of the peaksHistory array.
            
            
        }  // end of Timer()
    }  // end of processAudio() func


    /// It monitors the millisecond per frame at the cost of some performance drop.
    private func monitorPerformance() async -> Double {
        endTime = Date()
        let timetaken = DateInterval(start: startTime, end: endTime)
        durationArray.removeFirst(1)
        durationArray.append(timetaken.duration * 1_000.0)
        averageTime = self.durationArray.reduce(0,+) / Double(self.durationArray.count)
        startTime = Date()
        return averageTime
    }

}  // end of class BassAudioEngine


// ---------------------------------------------------------------------------------------------------------------------

func getGain() -> Float {
    let serialQueue = DispatchQueue(label: "...")
    // https://www.raywenderlich.com/books/concurrency-by-tutorials/v2.0/chapters/5-concurrency-problems

    var tempUserGain: Float = 4             // 0.0  <= userGain  <= 8.0
    
    var userGain: Float {                   // The user's choice for "gain" is changed in ContentView.
        get { return serialQueue.sync { tempUserGain } }
        set { serialQueue.sync { tempUserGain = newValue } }
    }
    return tempUserGain
}



func getSlope() -> Float {
    let serialQueue = DispatchQueue(label: "...")
    // https://www.raywenderlich.com/books/concurrency-by-tutorials/v2.0/chapters/5-concurrency-problems
    
    var tempUserSlope: Float = 0.2
    
    var userSlope: Float {      // The user's choice for "slope" (0.00 <= userSlope <= 0.1) is changed in ContentView.
        get { return serialQueue.sync { tempUserSlope } }
        set { serialQueue.sync { tempUserSlope = newValue } }
    }
    return userSlope
}



func getOnlyPeaks() -> Bool {
    let serialQueue = DispatchQueue(label: "...")
    // https://www.raywenderlich.com/books/concurrency-by-tutorials/v2.0/chapters/5-concurrency-problems
    
    // Allow the user to choose to see normal spectrum or only peaks (with percussive noises removed).
    var tempOnlyPeaks = false
    var onlyPeaks: Bool {           // The user's choice for "onlyPeaks" (true or false) is changed in ContentView.
        get { return serialQueue.sync { tempOnlyPeaks } }
        set { serialQueue.sync { tempOnlyPeaks = newValue } }
    }
    return onlyPeaks
}
#endif
