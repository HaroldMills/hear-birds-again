//
//  SongFinderParameters.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//


// TODO: Review use of "parameter" vs "param".


import Foundation


class SongFinderParameters {

    private enum SongFinderParam: AUParameterAddress {
        case pitchShift, windowType, windowSize, gain
    }
    
    static let minPitchShift: AUValue = 2
    static let maxPitchShift: AUValue = 4
    
    static let minWindowType: AUValue = 0
    static let maxWindowType: AUValue = 1
    
    static let minWindowSize: AUValue = 5
    static let maxWindowSize: AUValue = 50
    
    static let minGain: AUValue = -24
    static let maxGain: AUValue = 24

    var pitchShiftParam: AUParameter = {
        
        let parameter = AUParameterTree.createParameter(
            withIdentifier: "pitchShift",
            name: "Pitch Shift",
            address: SongFinderParam.pitchShift.rawValue,
            min: minPitchShift,
            max: maxPitchShift,
            unit: .customUnit,
            unitName: nil,
            flags: [.flag_IsReadable,
                    .flag_IsWritable],
            valueStrings: nil,
            dependentParameters: nil)
        
        parameter.value = minPitchShift

        return parameter
        
    }()

    var windowTypeParam: AUParameter = {
        
        let parameter = AUParameterTree.createParameter(
            withIdentifier: "windowType",
            name: "Window Type",
            address: SongFinderParam.windowType.rawValue,
            min: minWindowType,
            max: maxWindowType,
            unit: .indexed,
            unitName: nil,
            flags: [.flag_IsReadable,
                    .flag_IsWritable],
            valueStrings: nil,
            dependentParameters: nil)
        
        parameter.value = minWindowType

        return parameter
        
    }()
    
    var windowSizeParam: AUParameter = {
        
        let parameter = AUParameterTree.createParameter(
            withIdentifier: "windowSize",
            name: "Window Size",
            address: SongFinderParam.windowSize.rawValue,
            min: minWindowSize,
            max: maxWindowSize,
            unit: .milliseconds,
            unitName: "ms",
            flags: [.flag_IsReadable,
                    .flag_IsWritable,
                    .flag_CanRamp],
            valueStrings: nil,
            dependentParameters: nil)
        
        parameter.value = minWindowSize

        return parameter
        
    }()

    var gainParam: AUParameter = {
        
        let parameter = AUParameterTree.createParameter(
            withIdentifier: "gain",
            name: "Gain",
            address: SongFinderParam.gain.rawValue,
            min: minGain,
            max: maxGain,
            unit: .decibels,
            unitName: "dB",
            flags: [.flag_IsReadable,
                    .flag_IsWritable,
                    .flag_CanRamp],
            valueStrings: nil,
            dependentParameters: nil)
        
        parameter.value = 0

        return parameter
        
    }()

    let parameterTree: AUParameterTree

    init(kernelAdapter: SongFinderDSPKernelAdapter) {

        // Create the audio unit's tree of parameters
        parameterTree = AUParameterTree.createTree(
            withChildren: [pitchShiftParam, windowTypeParam, windowSizeParam, gainParam])

        // Closure observing all externally-generated parameter value changes.
        parameterTree.implementorValueObserver = { param, value in
            kernelAdapter.setParameter(param, value: value)
        }

        // Closure returning state of requested parameter.
        parameterTree.implementorValueProvider = { param in
            return kernelAdapter.value(for: param)
        }

        // Closure returning string representation of requested parameter value.
        parameterTree.implementorStringFromValueCallback = { param, value in
            switch param.address {
            case SongFinderParam.pitchShift.rawValue,
                SongFinderParam.windowType.rawValue,
                SongFinderParam.windowSize.rawValue,
                SongFinderParam.gain.rawValue:
                return String(format: "%.f", value ?? param.value)
            default:
                return "?"
            }
        }
    }
    
    func setParameterValues(pitchShift: AUValue, windowType: AUValue, windowSize: AUValue, gain: AUValue) {
        pitchShiftParam.value = pitchShift
        windowTypeParam.value = windowType
        windowSizeParam.value = windowSize
        gainParam.value = gain
    }
    
}
