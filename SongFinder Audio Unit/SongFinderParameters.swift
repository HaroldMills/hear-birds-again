//
//  SongFinderParameters.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//


import Foundation


class SongFinderParameters {

    private enum SongFinderParam: AUParameterAddress {
        case pitchShift
    }
    
    static let minPitchShift: AUValue = 2
    static let maxPitchShift: AUValue = 4

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

    let parameterTree: AUParameterTree

    init(kernelAdapter: SongFinderDSPKernelAdapter) {

        // Create the audio unit's tree of parameters
        parameterTree = AUParameterTree.createTree(withChildren: [pitchShiftParam])

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
                default:
                    return "?"
            }
        }
    }
    
    func setParameterValues(pitchShift: AUValue) {
        pitchShiftParam.value = pitchShift
    }
    
}
