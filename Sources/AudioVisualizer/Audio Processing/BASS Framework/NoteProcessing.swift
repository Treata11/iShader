///  NoteProcessing.swift
///  MuVis
///
///  The NoteProcessing class specified some constants and variable specific to musical notes.
///  When MuVis starts running, the function calculateParameters() is run to calculate a number of variables used throughout the entire project.
///
///  From the spectrum of the audio signal, we are interested in the frequencies between note C1 (about 33 Hz) and note B8 (about 7,902 Hz).
///  These 96 notes cover 8 octaves.
///
///  Created by Keith Bromley on 16 Feb 2021.


import Accelerate

#if os(iOS) || os(macOS)
class NoteProcessing {
    /// This singleton instantiates the NoteProcessing class
    static let shared = NoteProcessing()

    init() { calculateParameters() }

    let twelfthRoot2      : Float = pow(2.0, 1.0 / 12.0)     // twelfth root of two = 1.059463094359
    let twentyFourthRoot2 : Float = pow(2.0, 1.0 / 24.0)     // twenty-fourth root of two = 1.029302236643
    
    // variables used to transform the spectrum into an "octave-aligned" spectrum:
    var freqC1: Float = 0         // The lowest note of interest is C1 (about 33 Hz Hz)
    var leftFreqC1: Float = 0
    var leftFreqC2: Float = 0
    var freqB8: Float = 0
    var rightFreqB8: Float = 0

    // To capture 3 octaves, the highest note is B3 =  Hz      rightFreqB3 =  Hz   topBin = 94
    static let binCount3: Int =  95        // binCount3 = octTopBin[2] + 1 =  94 + 1 =  95
    
    // To capture 6 octaves, the highest note is B6 = 1,976 Hz      rightFreqB6 = 2,033.42 Hz   topBin = 755
    static let binCount6: Int =  756        // binCount6 = octTopBin[5] + 1 =  755 + 1 =  756
    
    // To capture 8 octaves, the highest note is B8 = 7,902 Hz      rightFreqB8 = 8,133.68 Hz   topBin = 3,021
    static let binCount8: Int = 3022        // binCount8 = octTopBin[7] + 1 = 3021 + 1 = 3022
    
    // The 8-octave spectrum covers the range from leftFreqC1 = 31.77 Hz to rightFreqB8 = 8133.84 Hz.
    // That is, from bin = 12 to bin = 3,021
    // The FFT provides us with 8,192 bins.  We will ignore the bin values above 3,021.
    var lowerOctFreq = [Double](repeating: 0, count: 8)           // frequency at the lower border for a given octave
    var upperOctFreq = [Double](repeating: 0, count: 8)           // frequency at the upper border for a given octave

    var lowerNoteFreq = [Double](repeating: 0, count: eightOctNoteCount+1) // frequency at the lower border of a each note
    var upperNoteFreq = [Double](repeating: 0, count: eightOctNoteCount+1) // frequency at the upper border of a each note
    
    var octBottomBin = [Int](repeating: 0, count: 8)   // the bin number of the bottom spectral bin in each octave
    var octTopBin    = [Int](repeating: 0, count: 8)   // the bin number of the top spectral bin in each octave
    var octBinCount  = [Int](repeating: 0, count: 8)   // number of spectral bins in each octave
    
    var noteBottomBin = [Int](repeating: 0, count: eightOctNoteCount) // bin number of bottom spectral bin in each note
    var noteTopBin    = [Int](repeating: 0, count: eightOctNoteCount) // bin number of top spectral bin in each note
    var noteBinCount  = [Int](repeating: 0, count: eightOctNoteCount) // number of spectral bins in each note
    
    // This is an array of scaling factors to multiply the octaveWidth to get the x coordinate:
    var binXFactor:  [Double] = [Double](repeating: 0, count: binCount8)  // binCount8 = 3,022
    var binXFactor3: [Double] = [Double](repeating: 0, count: binCount3)  // binCount6 =    95
    var binXFactor6: [Double] = [Double](repeating: 0, count: binCount6)  // binCount6 =   756
    var binXFactor8: [Double] = [Double](repeating: 0, count: binCount8)  // binCount8 = 3,022
    var binXFactor36:[Double] = [Double](repeating: 0, count: 95 + 661)
    // count: 95 + octBinCount[3] + octBinCount[4] + octBinCount[5] = 95 + 94+189+378 = 95 + 661 = 756
    
    var theta: Double = 0                                     // 0 <= theta < 1 is the angle around the ellipse
    let pointIncrement: Double = 1.0 / Double(sixOctPointCount)         // pointIncrement = 1 / 864
    var cos2PiTheta = [Double](repeating: 0, count: sixOctPointCount) // cos(2 * Pi * theta)
    var sin2PiTheta = [Double](repeating: 0, count: sixOctPointCount) // sin(2 * Pi * theta)



    // -----------------------------------------------------------------------------------------------------------------
    // Let's calculate a few frequency values and bin values common to many of the music visualizations:
    func calculateParameters() {

        // Calculate the lower bound of our frequencies-of-interest:
        freqC1 = 55.0 * pow(twelfthRoot2, -9.0)     // C1 = 32.7032 Hz          C1 is 9 semitones below A1=55 Hz
        leftFreqC1 = freqC1 / twentyFourthRoot2     // leftFreqC1 = 31.772186 Hz
        leftFreqC2 = 2.0 * leftFreqC1               // C1 = 32.7032 Hz    C2 = 65.4064 Hz
    
        // Calculate the upper bound of our frequencies-of-interest:
        freqB8  = 7040 * pow(twelfthRoot2, 2.0)   // B8 = 7,902.134 Hz        B8 is 2 semitones above A8=7,040 Hz
        rightFreqB8 = freqB8 * twentyFourthRoot2    // rightFreqB8 = 8,133.684 Hz


        // For each octave, calculate the left-most and right-most frequencies:
        for oct in 0 ..< 8 {    // 0 <= oct < 8
            let octD = Double(oct)
            let pow2oct: Double = pow( 2.0, octD )
            lowerOctFreq[oct] = pow2oct * Double( leftFreqC1 ) // 31.77  63.54 127.09 254.18  508.35 1016.71 2033.42 4066.84 Hz
            upperOctFreq[oct] = pow2oct * Double( leftFreqC2 ) // 63.54 127.09 254.18 508.35 1016.71 2033.42 4066.84 8133.68 Hz
        }


        // For each note, calculate the left-most frequency:
        for oct in 0 ..< 8 {    // 0 <= oct < 8
            lowerNoteFreq[ oct*notesPerOctave] = lowerOctFreq[oct]     // left  border of the lowest note in the octave
            
            // Now calculate the lower border frequencies of the remaining 11 notes in each octave:
            for note in 1 ..< notesPerOctave {    // 1 <= note < 12
                lowerNoteFreq[oct*notesPerOctave+note] = Double(twelfthRoot2) * lowerNoteFreq[oct*notesPerOctave + (note-1)]
            }
        }
        // The upperNoteFreq of a note is the lowerNoteFreq of the next-higher note:
        for oct in 0 ..< 8 {    // 0 <= oct < 8
            for note in 0 ..< notesPerOctave {    // 0 <= note < 12
                upperNoteFreq[ oct * notesPerOctave + note ] = lowerNoteFreq[ oct * notesPerOctave + note+1 ]
            }
        }
        lowerNoteFreq[95] = Double(twelfthRoot2) * lowerNoteFreq[94]
        upperNoteFreq[95] = Double(twelfthRoot2) * upperNoteFreq[94]

        /*
        // To verify these equations, let's print out the results in a chart of 96 rows.
        for noteNum in 0 ..< eightOctNoteCount  {    // 0 <= noteNum < 96
            print("noteNum: \(noteNum)", "lowerfreq: \( lowerNoteFreq[noteNum])", "upperfreq: \( upperNoteFreq[noteNum])")
        }
        // noteNum: 0  lowerfreq: 31.772186279296875 upperfreq: 33.66146034652411
        // noteNum: 1  lowerfreq: 33.66146034652411  upperfreq: 35.66307658843584
        // noteNum: 2  lowerfreq: 35.66307658843584  upperfreq: 37.78371522386945
        //
        // noteNum: 93 lowerfreq: 6839.584938391551  upperfreq: 7246.288158028695
        // noteNum: 94 lowerfreq: 7246.288158028695  upperfreq: 7677.175229515497
        // noteNum: 95 lowerfreq: 7677.175229515497  upperfreq: 8133.684200701219
        */

        let binFreqWidth = (Double(BassAudioEngine.sampleRate)/2.0) / Double(BassAudioEngine.binCount) // (44100/2)/8192=2.69165 Hz

        // Calculate the number of bins in each octave:
        for oct in 0 ..< 8 {    // 0 <= oct < 8
            var bottomBin: Int = 0
            var topBin: Int = 0
            var startNewOct: Bool = true
            
            for bin in 0 ..< BassAudioEngine.binCount {
                let binFreq: Double = Double(bin) * binFreqWidth
                
                // For each row, ignore bins with frequency below the leftFreq:
                if (binFreq < lowerOctFreq[oct]) { continue }
                if (startNewOct) { bottomBin = bin; startNewOct = false }
                // For each row, ignore bins with frequency above the rightFreq:
                if (binFreq > upperOctFreq[oct]) {topBin = bin-1; break}
            }
            octBottomBin[oct] = bottomBin               // 12, 24, 48,  95, 189, 378,  756,  1511, 3022
            octTopBin[oct] = topBin                     // 23, 47, 94, 188, 377, 755, 1510,  3021, 6043
            octBinCount[oct] = topBin - bottomBin + 1   // 12, 24, 47,  94, 189, 378,  755,  1511, 3022
            // print( octBottomBin[oct], octTopBin[oct], octBinCount[oct] )

        }

        
        // Calculate the number of bins in each note:
        for oct in 0 ..< 8 {            // 0 <= oct < 8
            for note in 0 ..< 12 {      // 0 <= note < 12
                var bottomBin: Int = 0
                var topBin: Int = 0
                var startNewNote: Bool = true
                
                for bin in octBottomBin[oct] ... octTopBin[oct] {
                    let binFreq: Double = Double(bin) * binFreqWidth
                    // For each note, ignore bins with frequency below the lowerFreq:
                    if (binFreq < lowerNoteFreq[oct*notesPerOctave + note]) { continue }
                    if (startNewNote) { bottomBin = bin; startNewNote = false }
                    // For each row, ignore bins with frequency above the upperFreq:
                    if (binFreq > lowerNoteFreq[oct*notesPerOctave + note+1]) { topBin = bin-1; break }
                }
                noteBottomBin[oct*notesPerOctave + note] = bottomBin
                noteTopBin[   oct*notesPerOctave + note] = topBin
                noteBinCount[ oct*notesPerOctave + note] = topBin - bottomBin + 1
            }
            noteTopBin[   oct*notesPerOctave + 11] = octTopBin[oct]
            noteBinCount[ oct*notesPerOctave + 11] = noteTopBin[oct*notesPerOctave+11] - noteBottomBin[oct*notesPerOctave+11] + 1
        }
        noteTopBin[3] = 15      // Ad-hoc: We need to share bin 15 among the noteNum's 3 and 4.
        noteBinCount[3] = 1
        
        /*
        // To verify these equations, let's print out the results in a chart of 96 rows.
        for noteNum in 0 ..< eightOctNoteCount  {    // 0 <= noteNum < 96
            print("noteNum:   \(noteNum)",
                  "BottomBin: \(noteBottomBin[noteNum])",
                  "TopBin:    \(noteTopBin[noteNum])",
                  "BinCount:  \(noteBinCount[noteNum])")
        }
        // noteNum: 0 BottomBin: 12 TopBin: 12 BinCount: 1
        // noteNum: 1 BottomBin: 13 TopBin: 13 BinCount: 1
        // noteNum: 2 BottomBin: 14 TopBin: 14 BinCount: 1
        // noteNum: 3 BottomBin: 15 TopBin: 15 BinCount: 1
        // noteNum: 4 BottomBin: 15 TopBin: 15 BinCount: 1
        //
        // noteNum: 92 BottomBin: 2399 TopBin: 2541 BinCount: 143
        // noteNum: 93 BottomBin: 2542 TopBin: 2692 BinCount: 151
        // noteNum: 94 BottomBin: 2693 TopBin: 2852 BinCount: 160
        // noteNum: 95 BottomBin: 2853 TopBin: 3021 BinCount: 169
        */
        
        
        // Calculate the exponential x-coordinate scaling factor:
        for oct in 0 ..< 8 {    // 0 <= oct < 8
            for bin in octBottomBin[oct] ... octTopBin[oct] {
                let binFreq: Double = Double(bin) * binFreqWidth
                let binFraction: Double = (binFreq - lowerOctFreq[oct]) / (upperOctFreq[oct] - lowerOctFreq[oct]) // 0 < binFraction < 1.0
                let freqFraction: Double = pow(Double(twelfthRoot2), 12.0 * binFraction) // 1.0 < freqFraction < 2.0
                
                // This is an array of scaling factors to multiply the octaveWidth to get the x coordinate:
                // That is, binXFactor goes from 0 to 1.0 within each octave.
                binXFactor[bin] =  (2.0 - (2.0 / freqFraction))
                // If freqFraction = 1.0 then binXFactor = 0; If freqFraction = 2.0 then binXFactor = 1.0
                
                // As bin goes from 12 to 3021, binXFactor8 goes from 0 to 1.0
                binXFactor8[bin] = ( Double(oct) + binXFactor[bin] ) / Double(8)
                
                // As bin goes from 12 to 755, binXFactor6 goes from 0 to 1.0
                if(oct < 6) {binXFactor6[bin] = ( Double(oct) + binXFactor[bin] ) / Double(6) }
                
                // As bin goes from 12 to 94, binXFactor3 goes from 0 to 1.0
                if(oct < 3) {binXFactor3[bin] = ( Double(oct) + binXFactor[bin] ) / Double(3) }
            }
        }
              
        // Calculate the exponential x-coordinate scaling factor for octaves 3 to 5 (i.e., bins 95 to 755):
        //var count: Int = 0
        for oct in 3 ... 5 {    // 3 <= oct <= 5
            for bin in octBottomBin[oct] ... octTopBin[oct] {
                let binFreq: Double = Double(bin) * binFreqWidth
                let binFraction: Double = (binFreq - lowerOctFreq[oct]) / (upperOctFreq[oct] - lowerOctFreq[oct]) // 0 < binFraction < 1.0
                let freqFraction: Double = pow(Double(twelfthRoot2), 12.0 * binFraction) // 1.0 < freqFraction < 2.0

                // This is an array of scaling factors to multiply the octaveWidth to get the x coordinate:
                // That is, binXFactor goes from 0 to 1.0 within each octave.
                binXFactor[bin] =  (2.0 - (2.0 / freqFraction))
                // If freqFraction = 1.0 then binXFactor = 0; If freqFraction = 2.0 then binXFactor = 1.0

                // As bin goes from 95 to 755, binXFactor36 goes from 0 to 1.0
                binXFactor36[bin] = ( ( Double(oct) + binXFactor[bin] ) / Double(3) ) - 1.0
                // count += 1
                // print( count, oct, bin, binXFactor36[bin] )
                // print(oct, bin, binXFactor[bin], binXFactor3[bin], binXFactor6[bin], binXFactor8[bin], binXFactor36[bin])
            }
        }

        // Calculate the angle theta from dividing a circle into sixOctPointCount angular increments:
        for point in 0 ..< sixOctPointCount {           // sixOctPointCount = 72 * 12 = 864
            theta = Double(point) * pointIncrement
            cos2PiTheta[point] = cos(2.0 * Double.pi * theta)
            sin2PiTheta[point] = sin(2.0 * Double.pi * theta)
        }

    }  // end of calculateParameters() func



    // -----------------------------------------------------------------------------------------------------------------
    
    // This function converts an input bin number into an output octave number:
    public func binToOctave(inputBin: Int) -> Int {
        var myOctave: Int = 0
        for oct in 0 ..< 8 {
            if ( inputBin > octBottomBin[oct] && inputBin < octTopBin[oct] ) {
                myOctave = oct
                break
            }
        }
        return myOctave
    }


    
    // This function converts an input bin number into an output note number:
    public func binToNote(inputBin: Int) -> Int {
        var myNote: Int = 0
        for oct in 0 ..< 8 {                // eightOctNoteCount = 96
            for note in 0 ..< 12 {
                if inputBin > noteBottomBin[oct*notesPerOctave+note] && inputBin < noteTopBin[oct*notesPerOctave+note] {
                    myNote = note
                    break
                }
            }
        }
        return myNote
    }

    
    // This function calculates the muSpectrum array:
    public func computeMuSpectrum(inputArray: [Float]) -> [Float] {
        // The inputArray is typically an audio spectrum from the BassAudioEngine.
        
        var outputIndices   = [Float] (repeating: 0, count: eightOctPointCount) // eightOctPointCount = 96*12 = 1,152
        var pointBuffer     = [Float] (repeating: 0, count: eightOctPointCount) // eightOctPointCount = 96*12 = 1,152
        let tempFloat1: Float = Float(leftFreqC1)
        let tempFloat2: Float = Float(notesPerOctave * pointsPerNote)
        let tempFloat3: Float = Float(BassAudioEngine.binFreqWidth)

        for point in 0 ..< eightOctPointCount {
            outputIndices[point] = ( tempFloat1 * pow( 2.0, Float(point) / tempFloat2 ) ) / tempFloat3
        }
        // print(outputIndices)
        
        vDSP_vqint( inputArray,                             // inputVector1
                    &outputIndices,                         // inputVector2 (with indices and fractional parts)
                    vDSP_Stride(1),                         // stride for inputVector2
                    &pointBuffer,                           // outputVector
                    vDSP_Stride(1),                         // stride for outputVector
                    vDSP_Length(eightOctPointCount),        // outputVector.count
                    vDSP_Length(NoteProcessing.binCount8))  // inputVector1.count

        return pointBuffer
    }



    // -----------------------------------------------------------------------------------------------------------------
    // This function calculates the "Harmonic Sum Spectrum" array:
    public func computeHarmSumSpectrum(inputArray: [Float]) -> [Float] {
        // The inputArray is typically a muSpectrum from the BassAudioEngine and has length eightOctPointCount.
        // The outputArray is the "Harmonic Sum Spectrum" and has length sixOctPointCount.
        var harmSumSpectrum = [Float] (repeating: 0, count: sixOctPointCount) // sixOctPointCount = 72*12 = 864
        
        let harmIncrement: [Int]  = [ 0, 12, 19, 24, 28, 31 ]   // The increment (in notes) for the six harmonics:
        //                           C1  C2  G2  C3  E3  G3
        
        for point in 0 ..< sixOctPointCount {
            for har in 0 ..< harmIncrement.count {
                let tempPointer: Int = point + ( 12 * harmIncrement[har] )
                if( tempPointer >= eightOctPointCount-1 ) { break }
                harmSumSpectrum[point] += inputArray[ tempPointer ]
            }
        }
        return harmSumSpectrum
    }



    // -----------------------------------------------------------------------------------------------------------------
    // This function calculates the "Harmonic Product Spectrum" array:
    public func computeHarmProdSpectrum(inputArray: [Float]) -> [Float] {
        // The inputArray is typically a muSpectrum from the BassAudioEngine and has length eightOctPointCount.
        // The outputArray is the "Harmonic Product Spectrum" and has length sixOctPointCount.
        var harmProdSpectrum = [Float] (repeating: 1.0, count: sixOctPointCount) // sixOctPointCount = 72*12 = 864

        let harmIncrement: [Int]  = [ 0, 12, 19, 24, 28, 31 ]   // The increment (in notes) for the six harmonics:
        //                           C1  C2  G2  C3  E3  G3

        for point in 0 ..< sixOctPointCount {
            for har in 0 ..< harmIncrement.count {
                let tempPointer: Int = point + ( 12 * harmIncrement[har] )
                if( tempPointer >= eightOctPointCount-1 ) { break }
                harmProdSpectrum[point] *= inputArray[ tempPointer ]
            }
        }
        return harmProdSpectrum
    }



    /*
    The following function estimates which notes are currently playing by observing the harmonic relationships among
    the sixteen loudest spectral peaks.
    We will start counting harmonics from 1 - meaning that harm=1 refers to the fundamental.
    If the fundamental is note C1, then:
        harm=1  is  C1  fundamental
        harm=2  is  C2  octave          freqC2  = 2.0 x freqC1
        harm=3  is  G2                  freqG2  = 3.0 x freqC1
        harm=4  is  C3  two octaves     freqC3  = 4.0 x freqC1
        harm=5  is  E3                  freqE3  = 5.0 x freqC1
        harm=6  is  G3                  freqG3  = 6.0 x freqC1
    So, harmonicCount = 6 and  harm = 1, 2, 3, 4, 5, 6.
    */
    public func computeCurrentNotes(inputArray: [Int]) -> [Int] {
        let harmonicCount: Int = 6
        let peakBinNumbers: [Int] = inputArray
        var noteFundamental: [Bool] = [Bool](repeating: false, count: sixOctNoteCount)
        var noteScore: [Int]   = [Int](repeating:  0, count: sixOctNoteCount)   // sixOctNoteCount = 6 * 12 = 72
        var currentNotes: [Int] = [Int](repeating: 99, count: 8)                // less than 9 notes from 16 peaks
        var i: Int = 0                                                          // counter for currentNote element

        // Calculate how many peaks fall within each note:
        for harm in 1 ... harmonicCount {                       // harm = 1, 2, 3, 4, 5, 6
            for peakNum in 0 ..< peakCount {                    // peakCount = 16
                if(peakBinNumbers[peakNum] == 0) {continue}                 // Only count non-zero peaks.
                let binFreq: Double = ( Double(peakBinNumbers[peakNum]) * BassAudioEngine.binFreqWidth ) / Double(harm)

                for noteNum in 0 ..< sixOctNoteCount {                                      // cycle through all notes
                    let leftNoteBorder:  Double = lowerNoteFreq[noteNum  ]
                    let rightNoteBorder: Double = lowerNoteFreq[noteNum+1]
                    if ( (binFreq > leftNoteBorder) && (binFreq < rightNoteBorder) ) {      // note sieve
                        noteScore[noteNum] += 1
                        if(harm == 1) { noteFundamental[noteNum] = true }
                    }
                }
            }
        }
        // Now that we have iterated over all the peaks and their harmonics, we have a complete noteScore array.

        // Set the value of currentNote array to the noteNum - if it has sufficient noteScore
        for noteNum in 0 ..< sixOctNoteCount {
            if( (noteFundamental[noteNum] == true) && (noteScore[noteNum] >= 3) ) { // Best choice is 3 or 4 out of 6.
                currentNotes[i] = noteNum
                i += 1
            }
            if(i > 7) {break} // This occasionally happens when multiple close peaks are in the same note.
        }
        return currentNotes
        // The currentNote array will contain 8 noteNums (0-71).  If the element is 99, it is not a playing currentNote.
        
    }  // end of computeCurrentNotes() func
    
}  
#endif
