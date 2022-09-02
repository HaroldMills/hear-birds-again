//
//  SongFinderParameters.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//


import Foundation


public struct SongFinderParameters {

    
    private enum ParameterAddress: AUParameterAddress {
        case cutoff, pitchShift, windowType, windowSize, gain, balance, outputLevel0, outputLevel1
    }
    
    
    private static let minCutoff: AUValue = 0
    private static let maxCutoff: AUValue = 4000
    
    private static let minPitchShift: AUValue = 2
    private static let maxPitchShift: AUValue = 4
    
    private static let minWindowType: AUValue = 0
    private static let maxWindowType: AUValue = 1

    private static let minWindowSize: AUValue = 5
    private static let maxWindowSize: AUValue = 50
    
    private static let minGain: AUValue = -20
    private static let maxGain: AUValue = 20
    
    private static let minBalance: AUValue = -10
    private static let maxBalance: AUValue = 10
    
    private static let minOutputLevel: AUValue = -100
    private static let maxOutputLevel: AUValue = 0

    
    public let cutoff: AUParameter = {
        
        let parameter = AUParameterTree.createParameter(
            withIdentifier: "cutoff",
            name: "Cutoff",
            address: ParameterAddress.cutoff.rawValue,
            min: minCutoff,
            max: maxCutoff,
            unit: .customUnit,
            unitName: nil,
            flags: [.flag_IsReadable, .flag_IsWritable],
            valueStrings: nil,
            dependentParameters: nil)
        
        parameter.value = minCutoff

        return parameter
        
    }()
    
    
    public let pitchShift: AUParameter = {
        
        let parameter = AUParameterTree.createParameter(
            withIdentifier: "pitchShift",
            name: "Pitch Shift",
            address: ParameterAddress.pitchShift.rawValue,
            min: minPitchShift,
            max: maxPitchShift,
            unit: .customUnit,
            unitName: nil,
            flags: [.flag_IsReadable, .flag_IsWritable],
            valueStrings: nil,
            dependentParameters: nil)
        
        parameter.value = minPitchShift

        return parameter
        
    }()

    
    public let windowType: AUParameter = {
        
        let parameter = AUParameterTree.createParameter(
            withIdentifier: "windowType",
            name: "Window Type",
            address: ParameterAddress.windowType.rawValue,
            min: minWindowType,
            max: maxWindowType,
            unit: .indexed,
            unitName: nil,
            flags: [.flag_IsReadable, .flag_IsWritable],
            valueStrings: nil,
            dependentParameters: nil)
        
        parameter.value = minWindowType

        return parameter
        
    }()
    
    
    public let windowSize: AUParameter = {
        
        let parameter = AUParameterTree.createParameter(
            withIdentifier: "windowSize",
            name: "Window Size",
            address: ParameterAddress.windowSize.rawValue,
            min: minWindowSize,
            max: maxWindowSize,
            unit: .milliseconds,
            unitName: "ms",
            flags: [.flag_IsReadable, .flag_IsWritable],
            valueStrings: nil,
            dependentParameters: nil)
        
        parameter.value = minWindowSize

        return parameter
        
    }()

    
    public let gain: AUParameter = {
        
        let parameter = AUParameterTree.createParameter(
            withIdentifier: "gain",
            name: "Gain",
            address: ParameterAddress.gain.rawValue,
            min: minGain,
            max: maxGain,
            unit: .decibels,
            unitName: "dB",
            flags: [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp],
            valueStrings: nil,
            dependentParameters: nil)
        
        parameter.value = 0

        return parameter
        
    }()

    
    public let balance: AUParameter = {
        
        let parameter = AUParameterTree.createParameter(
            withIdentifier: "balance",
            name: "Balance",
            address: ParameterAddress.balance.rawValue,
            min: minBalance,
            max: maxBalance,
            unit: .decibels,
            unitName: "dB",
            flags: [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp],
            valueStrings: nil,
            dependentParameters: nil)
        
        parameter.value = 0

        return parameter
        
    }()
    
    
    public let outputLevel0: AUParameter = {
        
        let parameter = AUParameterTree.createParameter(
            withIdentifier: "outputLevel0",
            name: "Output Level 0",
            address: ParameterAddress.outputLevel0.rawValue,
            min: minOutputLevel,
            max: maxOutputLevel,
            unit: .decibels,
            unitName: "dB",
            flags: [.flag_MeterReadOnly],
            valueStrings: nil,
            dependentParameters: nil)
        
        parameter.value = minOutputLevel

        return parameter
        
    }()
    
    
    public let outputLevel1: AUParameter = {
        
        let parameter = AUParameterTree.createParameter(
            withIdentifier: "outputLevel1",
            name: "Output Level 1",
            address: ParameterAddress.outputLevel1.rawValue,
            min: minOutputLevel,
            max: maxOutputLevel,
            unit: .decibels,
            unitName: "dB",
            flags: [.flag_MeterReadOnly],
            valueStrings: nil,
            dependentParameters: nil)
        
        parameter.value = minOutputLevel

        return parameter
        
    }()
    
    
    public let parameterTree: AUParameterTree

    
    public init(kernelAdapter: SongFinderDSPKernelAdapter) {

        // Create the audio unit's tree of parameters
        parameterTree = AUParameterTree.createTree(
            withChildren: [cutoff, pitchShift, windowType, windowSize, gain, balance, outputLevel0, outputLevel1])

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
            case ParameterAddress.cutoff.rawValue,
                ParameterAddress.pitchShift.rawValue,
                ParameterAddress.windowType.rawValue,
                ParameterAddress.windowSize.rawValue,
                ParameterAddress.gain.rawValue,
                ParameterAddress.balance.rawValue,
                ParameterAddress.outputLevel0.rawValue,
                ParameterAddress.outputLevel1.rawValue:
                return String(format: "%.f", value ?? param.value)
            default:
                return "?"
            }
        }
    }
    
    
    public func setValues(cutoff: AUValue, pitchShift: AUValue, windowType: AUValue, windowSize: AUValue, gain: AUValue, balance: AUValue) {
        
        self.cutoff.value = cutoff
        self.pitchShift.value = pitchShift
        self.windowType.value = windowType
        self.windowSize.value = windowSize
        self.gain.value = gain
        self.balance.value = balance
                
    }
    
    
}
