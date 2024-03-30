///  SpectralEnhancer.swift
///  MuVis
///
///  SpectralEnhancer is a normalization method used to enhance the display of spectral lines (usually the harmonics of musical notes) and to reduce the display
///  of noise (usually percussive effects which smear spectral energy over a large range.)  The technique used here is to (1) slide a moving window across
///  the spectrum seeking local peaks above some threshold; (2) replace those peaks with the local mean value; (3) compute a moving average of the resultant reduced-peaks spectrum, and (4) subtract this moving average from the initial spectrum.
///
///  This technique is called "Two-Pass Split-Window (TPSW) Filtering" and is described in the paper "Evaluation of Threshold-Based Algorithms for Detection of Spectral Peaks in Audio" by Leonardo Nunes, Paulo Esquef, and Luiz Biscainho.
///  This paper can be downloaded from: https://www.lncc.br/%7Epesquef/publications/nat_conferences/nunes_aesbr2007.pdf
///
///  The "two-pass split-window filtering" algorithm comprises the following four steps:
///  (1) Calculate a local first-pass mean for each bin using a 65-bin window with a 5-bin gap.
///  (2) Compare each bin value against its respective local first-pass mean.  Values above a threshold are replaced by the local first-pass mean.
///  (3) Calculate a local second-pass noise mean estimate for each bin of this smoothed data again using a 65-bin window but this time with no gap.
///  (4) Subtract this noise mean estimate from each original bin value to reduce the noise.

///  The SpectralEnhancer class contains the private method localSum() which creates an output array where each element is the sum of
///  inputArray[-32] to inputArray[32].  It also contains a public method findMean() which uses the localSum() method to perform the
///  TPSW filtering on the desired input array.  It also contains a public methods enhance() which subtracts the meanArray from the inputArray.
///
///  The SpectralEnhancer class contains a public method pickPeaks().  It produces an outputArray[] that contains "true" values only at bins
///  that are larger in value than the three bins on either side.
///
///  The Apple vDSP documentation does not discuss how edge effects are handled.
///  I noticed that the sumFilter[] array and the localMean[] array are both of length (inputArray.count - filterWidth -1).
///  I suspect that the output of the vDSP.slidingWindowSum() function has length (inputArray.count - filterWidth - 1).
///  To properly handle this changed length, and to properly line-up the filtered arrays with the inputArray, I surmise that I need to add (filterWidth-1)/2 zeroes
///  to the front and end of the inputArray each time we use the vDSP.slidingWindowSum() method.
///
///  -------------------------------------------------------------------------------------------------------------------
///  There is an excellent blog (written by Dinesh Harjano of Dordic Semiconductor) on using vDSP at:
///  devzone.nordicsemi.com/nordic/nordic-blog/b/blog/posts/nrf_2d00_connect_2d00_simd_2d00_optimizations_2d00_in_2d00_swift
///
///  The following (slightly re-worded) extract is taken from this blog:
///  Accelerate is the all-in-one framework to make the best possible use of all the vector processing capabilities of Apple’s devices. The concept behind this framework is that it gives us access to optimized implementations of math algorithms that are hardware-accelerated, at the cost of a more complex API. This allows us to write complex algorithms once, tapping into the full power of the silicon underneath, without needing to know about the architectural differences between Apple SoC generations.  So if our goal is to speed-up our graph computations, the Accelerate framework is where we need to look.
///
///  Unfortunately for us, there’s very little practical information regarding the use of Accelerate functions in real life. There are many WWDC talks given by Apple on the topic, and although some examples are valid, most of them don’t apply to the standard arithmetic uses we need. And if you go on looking for Accelerate examples on the web, 99.9% of them are just rehashed examples from the documentation. No practical use-case guide for where you can use Accelerate, except if your use case follows what is described in the documentation. If you have an algorithm written in Swift with a processor-intensive loop that you’d like to speed-up, there’s no writeup with a guide as to how you might go about it or the corresponding performance numbers to back up the theory.
///
///  Part of the Accelerate framework is the vDSP library.  As its name suggests, vDSP stands for vector Digital Signal Processing, where vector is a stand-in for SIMD-like operations that can be performed all at once. The conceptual roots of this library lie in the fact that SIMD operations can be used not only to fast-track processing of arithmetic data, but also to apply algorithms to waveforms, such as those used in processing digital audio.
///
///  A more technical perspective on Accelerate is that CPUs took their learnings from the SIMD speed-ups and began adding tiny dedicated processors within themselves, sometimes referred to as ‘blocks’ (IP blocks, SiP blocks).  Whilst true that these DSP algorithms can be executed in the main Integer/Floating Point pipeline, using dedicated hardware trades computing flexibility in exchange for lower-power and greater-performance. Thus, since these units tend to be small and dedicated to targeted tasks, modern microprocessors incorporate many of them, and switch between them depending on the instructions received.  This is why multiple libraries such as Machine Learning and vDSP find their home in Accelerate.  Apple’s custom SoC architectures aren’t well-documented at this point, so we don’t know for certain what kinds of specific hardware blocks are on those chips or how they work. What we do know, however, is that by using Accelerate, we get to enjoy the rewards of using the most efficient hardware for our supported tasks, “for free”.
///  -------------------------------------------------------------------------------------------------------------------
///  
///  This version of SpectralEnhancer (using vDSP) was created by Keith Bromley in March 2023.

import Foundation
import Accelerate

class SpectralEnhancer {

    let filterWidth: Int      	// filter width = number of bins to include in average
    let halfFilterWidth: Int
    let gapWidth: Int           // A Hamming FFT window will smear the main peak over about 5 FFT bins.
    let halfGapWidth: Int
    let noiseThreshold: Float 	// determines which peaks are replaced by the mean during the first pass
    
    init() {
        filterWidth = 65
        halfFilterWidth = Int( Double(filterWidth - 1) / 2.0 )  // halfFilterWidth = 32
        gapWidth = 5
        halfGapWidth = Int( Double(gapWidth - 1) / 2.0 )         // halfGapWidth = 2
        noiseThreshold = 2.0
    }



    //------------------------------------------------------------------------------------------------------------------
    // This localSum() function returns the sliding-window sum of a one-dimensional array.
    internal func localSum( inputArray: [Float], windowLength: Int) -> [Float] {
        return ( vDSP.slidingWindowSum(inputArray, usingWindowLength: windowLength) )
        // We observe that the returned array has count = inputArray.count - (windowLength - 1).
    }



    //------------------------------------------------------------------------------------------------------------------
    // This findMean() function generates an array that is the same as the inputArray but is free of prominent peaks.
    public func findMean(inputArray: [Float]) ->  [Float] {
        // We start the first pass by: (1) first sum over the total window, then (2) sum over the gap,
        // and then (3) subtract the gap sum from the total-window sum.

        // Add halfFilterWidth zeroes to the front and end of the inputArray array:
        let zeroesArray1: [Float] = [Float] (repeating: 0.0, count: halfFilterWidth )
        var inputArray1 = inputArray
        inputArray1.insert(contentsOf: zeroesArray1, at: 0)     // adds 32 elements to start of array
        inputArray1.append(contentsOf: zeroesArray1)            // adds 32 elements to end of array
        
        // local sliding-window sum of the input array (using windowLength = filterWidth = 65):
        let sumFilter = localSum(inputArray: inputArray1, windowLength: filterWidth)
        // sumFilter.count = inputArray.count
 
        // Add halfGapWidth zeroes to the front and end of the inputArray array:
        let zeroesArray2: [Float] = [Float] (repeating: 0.0, count: halfGapWidth)
        var inputArray2 = inputArray
        inputArray2.insert(contentsOf: zeroesArray2, at: 0)     // adds 2 elements to start of array
        inputArray2.append(contentsOf: zeroesArray2)            // adds 2 elements to end of array
        
        // local sliding-window sum of the input array (using windowLength = gapWidth = 5):
        let sumGap = localSum(inputArray: inputArray2, windowLength: gapWidth)
        // sumGap.count = inputArray.count
        
        // We then compare each bin value against its respective local first-pass mean, and
        // values above a threshold are replaced by the local first-pass mean.
        
        var mean : Float = 0.0
        var noPeaksArray: [Float] = [Float] (repeating: 0.0, count: inputArray.count)
        
        // Create an array with the number of bins within the filter as it slides across the inputArray:
        // binsInWindow = 32,33,34,35,36 ... 61,62,63,64,65,65,65,65,65 ... 65,65,65,65,64,63,62,61 ... 36,35,34,33,32
        var binsInWindow: [Float] =  [Float] (repeating: Float(filterWidth), count: inputArray.count )
        for i in 0 ..< halfFilterWidth {
            binsInWindow[i] = Float( halfFilterWidth + i )
        }
        for i in (inputArray.count - halfFilterWidth) ..< inputArray.count {
            binsInWindow[i] = Float( inputArray.count + halfFilterWidth - i )
        }

        // Compute the noPeaksArray[] by replacing peaks of the inputArray[] with the local mean.
        for i in 0 ..< inputArray.count {
            mean = ( sumFilter[i] - sumGap[i] ) / binsInWindow[i]
            
            if (inputArray[i] > noiseThreshold * mean) {
                noPeaksArray[i] = mean
            } else {
                noPeaksArray[i] = inputArray[i]
            }
        }
        
        // In the second pass, we perform further smoothing on this noPeaksArray[] by applying a conventional
        // moving summation filter to determine an array of local sums.
        
        // Add halfFilterWidth zeroes to the front and end of the noPeaksArray array:
        noPeaksArray.insert(contentsOf: zeroesArray1, at: 0)        // adds 32 elements to start of array
        noPeaksArray.append(contentsOf: zeroesArray1)               // adds 32 elements to end of array
        
        // local sliding-window sum of the noPeaksArray (using windowLength = filterWidth = 65):
        let sumArray = localSum(inputArray: noPeaksArray,  windowLength: filterWidth)
        // sumArray.count = inputArray.count

        var meanArray: [Float] = [Float] (repeating: 0.0, count: inputArray.count)

        // Now subtract this local mean from the original inputArray
        
        for i in 0 ..< inputArray.count {
            mean = sumArray[i] / binsInWindow[i]
            meanArray[i] = mean
        }
        // print(meanArray.count)
        
        return (meanArray)
        // The meanArray[] is the same as the inputArray[] but is free of prominent peaks.
        // Note that the meanArray[0] averages over inputArray[-32] to inputArray[+32]
    }



    //------------------------------------------------------------------------------------------------------------------
    // This enhance() function subtracts the meanArray from the original inputArray.
    public func enhance(inputArray: [Float]) -> [Float] {

        let meanArray: [Float] = findMean(inputArray: inputArray)
        // meanArray.count = inputArray.count

        var outputArray: [Float] = [Float] (repeating: 0.0, count: inputArray.count)

        for i in 0 ..< inputArray.count {
            outputArray[i] = inputArray[i] - meanArray[i]
            if (outputArray[i] < 0.0) { outputArray[i] = 0.0 }
        }

        return ( outputArray )
        // We have now reduced the noise floor and hopefully improved the visibility of the harmonic peaks above it.
        // Note that the outputArray[0] averages over inputArray[-32] to inputArray[+32]
    }
    

    //------------------------------------------------------------------------------------------------------------------
    // The outputArray[] computed by the pickPeaks() method contains "true" values only at bins
    // that are larger in value than the three bins on either side.

    public func pickPeaks(inputArray: [Float], peakThreshold: Float) -> [Bool] {

        // Initialize the outputArray to all false.
        var outputArray: [Bool] = [Bool] (repeating: false, count: inputArray.count)

        for bin in 3 ..< inputArray.count - 3 {
            let tempFloat: Float = inputArray[bin]
            if ((tempFloat > peakThreshold) &&
                    (tempFloat > inputArray[bin - 3]) &&
                    (tempFloat > inputArray[bin - 2]) &&
                    (tempFloat > inputArray[bin - 1]) &&
                    (tempFloat > inputArray[bin + 1]) &&
                    (tempFloat > inputArray[bin + 2]) &&
                    (tempFloat > inputArray[bin + 3])) {
                outputArray[bin] = true;
            }
        }
        return ( outputArray )
    }

}  // end of SpectralEnhancer class
