//
//  SongFinderParameters.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//


import Foundation


class AttenuatorParameters {

    private enum AttenuatorParam: AUParameterAddress {
        case attenuation
    }

    var attenuationParam: AUParameter = {
        
        let parameter = AUParameterTree.createParameter(
            withIdentifier: "attenuation",
            name: "Attenuation",
            address: AttenuatorParam.attenuation.rawValue,
            min: 0.0,
            max: 100.0,
            unit: .decibels,
            unitName: nil,
            flags: [.flag_IsReadable,
                    .flag_IsWritable,
                    .flag_CanRamp],
            valueStrings: nil,
            dependentParameters: nil)
        
        parameter.value = 0.0

        return parameter
        
    }()

    let parameterTree: AUParameterTree

    init(kernelAdapter: SongFinderDSPKernelAdapter) {

        // Create the audio unit's tree of parameters
        parameterTree = AUParameterTree.createTree(withChildren: [attenuationParam])

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
                case AttenuatorParam.attenuation.rawValue:
                    return String(format: "%.f", value ?? param.value)
                default:
                    return "?"
            }
        }
    }
    
    func setParameterValues(attenuation: AUValue) {
        attenuationParam.value = attenuation
    }
    
}
