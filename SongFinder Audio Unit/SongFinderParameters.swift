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
        case pitchShift
        case windowType
    }
    
    static let minPitchShift: AUValue = 2
    static let maxPitchShift: AUValue = 4
    
    static let minWindowType: AUValue = 0
    static let maxWindowType: AUValue = 1

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
                    .flag_IsWritable,
                    .flag_CanRamp],
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
                    .flag_IsWritable,
                    .flag_CanRamp],
            valueStrings: nil,
            dependentParameters: nil)
        
        parameter.value = minWindowType

        return parameter
        
    }()

    let parameterTree: AUParameterTree

    init(kernelAdapter: SongFinderDSPKernelAdapter) {

        // Create the audio unit's tree of parameters
        parameterTree = AUParameterTree.createTree(
            withChildren: [pitchShiftParam, windowTypeParam])

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
                case SongFinderParam.pitchShift.rawValue:
                    return String(format: "%.f", value ?? param.value)
                case SongFinderParam.windowType.rawValue:
                    return String(format: "%.f", value ?? param.value)
                default:
                    return "?"
            }
        }
    }
    
    func setParameterValues(pitchShift: AUValue, windowType: AUValue) {
        pitchShiftParam.value = pitchShift
        windowTypeParam.value = windowType
    }
    
}
