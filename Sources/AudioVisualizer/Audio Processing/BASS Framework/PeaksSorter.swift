//  PeaksSorter.swift
//  MuVis
//
//  Keith is experimenting with ideas for future visualizations that involve the interval frequency ratios between
//  prominent spectrum peaks.  The bedrock for these ideas is to, frame by frame, efficiently and accurately detect
//  the spectrum peaks, and select the twenty-or-so biggest (loudest) ones.  This PeakSorter{} class (along with the
//  few visualizations that use it) is the first step to develop the code and validate its accuracy.
//
//  Created by Keith Bromley on 12/2/21.


import Foundation

#if os(iOS) || os(macOS)
class PeaksSorter {

    var spectralEnhancer = SpectralEnhancer()
    
    // Typically, the binValues[] array is of size binCount6, and topBin (the highest bin of interest) is  755.
    public func getSortedPeaks( binValues: [Float],
                                bottomBin: Int,
                                topBin: Int,
                                peakThreshold: Float ) ->
                              ( actualPeakCount: Int,
                                sortedPeakBinNumbers: [Int],
                                sortedPeakAmplitudes: [Double] ) {

        // To capture 6 octaves, the highest note is B6 = 1,976 Hz, the rightFreqB6 = 2,033.42 Hz, and topBin = 755
        // Declare two arrays of size topBin-bottomBin and initialize them to all zeroes:
                                  
        // var peakBinNumbers: [Int]   = [Int]   (repeating: 0,   count: topBin-bottomBin) // topBin-bottomBin = 755-12=743
        var peakBinNumbers: [Int]   = [Int]   (repeating: 0,   count: topBin) // topBin = 755
                                  
        // var peakAmplitudes: [Float] = [Float] (repeating: 0.0, count: topBin-bottomBin) // topBin-bottomBin = 755-12=743
        var peakAmplitudes: [Float] = [Float] (repeating: 0.0, count: topBin) // topBin = 755
                                  
        var peakNum: Int = 0
        var actualPeakCount: Int = 0
                                  
        // We use the enhancedSpectrum[] to detect peaks, but then use the binValues[] array to get their amplitudes.
        let enhancedSpectrum = spectralEnhancer.enhance(inputArray: binValues)
                                  
        for bin in bottomBin ... topBin {
            if(bottomBin < 3) {break}                        // Move on to next iteration of the for(bin) loop
            if(topBin > enhancedSpectrum.count - 3) {break}  // Move on to next iteration of the for(bin) loop
            
            let tempFloat: Float = enhancedSpectrum[bin]
            
            if ((tempFloat > peakThreshold) &&
                (tempFloat > enhancedSpectrum[bin - 3]) &&
                (tempFloat > enhancedSpectrum[bin - 2]) &&
                (tempFloat > enhancedSpectrum[bin - 1]) &&
                (tempFloat > enhancedSpectrum[bin + 1]) &&
                (tempFloat > enhancedSpectrum[bin + 2]) &&
                (tempFloat > enhancedSpectrum[bin + 3])) {
                    peakBinNumbers[peakNum] = bin               // 12 <= bin <= 755 // index out of range
                    peakAmplitudes[peakNum] = binValues[bin]
                    actualPeakCount += 1
                }
                peakNum += 1
                
        }  // end of for(bin) loop
                                  
        // actualPeakCount is the actual number of peaks (non-zero elements in the peakAmplitudes[] array).
        // The peakBinNumbers[] and peakAmplitudes[] arrays contain actualPeakCount peaks.
        // They are of size topBin, but they contain only actualPeakCount non-zero values.
        // They are ordered by frequency (i.e., bin).
        // We want to re-order them from largest amplitude (loudest) to smallest amplitude (quietest):
        
        let sorted = peakAmplitudes.enumerated().sorted(by: {$0.element > $1.element})
        // The enumerated() method converts an array of items to an array of (index, item) pairs.
        // Swift calls these (offset, element) pairs.
        // The sorted() method sorts all the elements of the (offset, element) pairs using a given criterion.
        // The map() method converts the resulting array of (offset, element) pairs to an array of offsets.
        
        let amplitudes = sorted.map{$0.element}             // elements from largest to smallest
        let indices = sorted.map{$0.offset}  // indices of largest element to smallest element  // 12 <= indices <= 755

        // We need to account for the fact that actualPeakCount will sometimes be zero due to silence in the music:
        // The extra array elements (not containing real data) will have bin = 0, amplitude = 0.0, frequency = 0.0
        // if(actualPeakCount < 8) { actualPeakCount = 8 }

        // return three arrays containing the bin numbers, frequencies, and amplitudes sorted from loudest to quietest.
        // Any array elements not containing real data will have bin = 0, frequency = 0.0, and amplitude = 0.0
        var sortedPeakBinNumbers: [Int]    = [Int]    (repeating: 0,   count: peakCount)    // peakCount = 16
        var sortedPeakAmplitudes: [Double] = [Double] (repeating: 0.0, count: peakCount)    // peakCount = 16

        // We ony pass peakCount peaks - even if there are more.
        if(actualPeakCount > peakCount) {actualPeakCount = peakCount}                       // peakCount = 16

        for index in 0 ..< actualPeakCount {
            sortedPeakBinNumbers[index] = indices[index] + 12
            sortedPeakAmplitudes[index] = Double( amplitudes[index] )
        }
        return (actualPeakCount, sortedPeakBinNumbers, sortedPeakAmplitudes)

    }  // end of the getSortedPeaks() func

}  // end of PeaksSorter class
#endif
