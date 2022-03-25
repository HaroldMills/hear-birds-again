//
//  SongFinderAudioUnit.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//


import Foundation
import AudioToolbox
import AVFoundation
import CoreAudioKit


public class SongFinderAudioUnit: AUAudioUnit {

    
    public static let componentSubType = OSType(0x736f6669)          // 'sofi'
    public static let componentManufacturer = OSType(0x48424178)     // 'HBAx'
    
    public static let componentDescription = AudioComponentDescription(
        componentType: kAudioUnitType_Effect,
        componentSubType: componentSubType,
        componentManufacturer: componentManufacturer,
        componentFlags: 0,
        componentFlagsMask: 0
    )


    private let parameters: AttenuatorParameters
    private let kernelAdapter: SongFinderDSPKernelAdapter

    
    lazy private var inputBusArray: AUAudioUnitBusArray = {
        AUAudioUnitBusArray(
            audioUnit: self,
            busType: .input,
            busses: [kernelAdapter.inputBus])
    }()

    
    lazy private var outputBusArray: AUAudioUnitBusArray = {
        AUAudioUnitBusArray(
            audioUnit: self,
            busType: .output,
            busses: [kernelAdapter.outputBus])
    }()

    
    // weak var viewController: AttenuatorViewController?

    
    public override var inputBusses: AUAudioUnitBusArray {
        return inputBusArray
    }

    
    public override var outputBusses: AUAudioUnitBusArray {
        return outputBusArray
    }
    
    
    public override var parameterTree: AUParameterTree? {
        get { return parameters.parameterTree }
        set { /* This makes this property read-only. */ }
    }

    /*
    public override var factoryPresets: [AUAudioUnitPreset] {
        return [
            AUAudioUnitPreset(number: 0, name: "Unattenuated"),
            AUAudioUnitPreset(number: 1, name: "Attenuated"),
        ]
    }
    */

    
    private let factoryPresetValues: [AUValue] = [
        0,    // "Unattenuated"
        10    // "Attenuated"
    ]

    
    private var _currentPreset: AUAudioUnitPreset?
    
    
    public override var currentPreset: AUAudioUnitPreset? {
        
        get { return _currentPreset }
        
        set {
            
            guard let preset = newValue else {
                // newValue is nil
                
                _currentPreset = nil
                return
                
            }
            
            if preset.number >= 0 {
                // factory preset
                
                let attenuation = factoryPresetValues[preset.number]
                print("Attenuator.currentPreset setting parameter value")
                parameters.setParameterValues(attenuation: attenuation)
                print("Attenuator.currentPreset done setting parameter value")
                _currentPreset = preset
                
            } else {
                // user preset
                
                // Attempt to restore the archived state for this user preset.
                do {
                    fullStateForDocument = try presetState(for: preset)
                    // Set the currentPreset after we've successfully restored the state.
                    _currentPreset = preset
                } catch {
                    print("Unable to restore set for preset \(preset.name)")
                }
                
            }
            
        }
        
    }
    
    
    public override var supportsUserPresets: Bool {
        return true
    }

    
    public override init(
        
        componentDescription: AudioComponentDescription,
        options: AudioComponentInstantiationOptions = []
    
    ) throws {

        // Create adapter for communicating with C++ DSP code.
        kernelAdapter = SongFinderDSPKernelAdapter()
        
        // Create parameters object to control attenuation
        parameters = AttenuatorParameters(kernelAdapter: kernelAdapter)

        // Initialize superclass.
        try super.init(componentDescription: componentDescription, options: options)

        // Show process and component description info.
        // showInfo(componentDescription)
        
        // Set default preset.
        /*
        print("Attenuator initializer setting preset")
        currentPreset = factoryPresets[1]
        print("Attenuator initializer done setting preset")
        */

    }

    
    private func showInfo(_ acd: AudioComponentDescription) {

        let info = ProcessInfo.processInfo
        print("\nProcess Name: \(info.processName) PID: \(info.processIdentifier)\n")

        let message = """
        SongFinder (
                  type: \(acd.componentType.stringValue)
               subtype: \(acd.componentSubType.stringValue)
          manufacturer: \(acd.componentManufacturer.stringValue)
                 flags: \(String(format: "%#010x", acd.componentFlags))
        )
        """
        print(message)
        
    }

    
    public override var maximumFramesToRender: AUAudioFrameCount {
        
        get {
            return kernelAdapter.maximumFramesToRender
        }
        
        set {
            if !renderResourcesAllocated {
                kernelAdapter.maximumFramesToRender = newValue
            }
        }
        
    }

    
    public override func allocateRenderResources() throws {
        
        if kernelAdapter.outputBus.format.channelCount != kernelAdapter.inputBus.format.channelCount {
            throw NSError(
                domain: NSOSStatusErrorDomain,
                code: Int(kAudioUnitErr_FailedInitialization),
                userInfo: nil)
        }
        
        try super.allocateRenderResources()
        
        kernelAdapter.allocateRenderResources()
        
    }

    
    public override func deallocateRenderResources() {
        super.deallocateRenderResources()
        kernelAdapter.deallocateRenderResources()
    }

    
    public override var internalRenderBlock: AUInternalRenderBlock {
        return kernelAdapter.internalRenderBlock()
    }

    
    // Boolean indicating that this AU can process the input audio in-place
    // in the input buffer, without requiring a separate output buffer.
    public override var canProcessInPlace: Bool {
        return true
    }

    
    /*
    // MARK: View Configurations
    public override func supportedViewConfigurations(
        
        _ availableViewConfigurations: [AUAudioUnitViewConfiguration]
        
    ) -> IndexSet {
        
        var indexSet = IndexSet()

        let min = CGSize(width: 400, height: 100)
        let max = CGSize(width: 800, height: 500)

        for (index, config) in availableViewConfigurations.enumerated() {

            let size = CGSize(width: config.width, height: config.height)

            if size.width <= min.width && size.height <= min.height ||
                    size.width >= max.width && size.height >= max.height ||
                    size == .zero {

                indexSet.insert(index)
                
            }
            
        }
        
        return indexSet
        
    }

     
    public override func select(_ viewConfiguration: AUAudioUnitViewConfiguration) {
        viewController?.selectViewConfiguration(viewConfiguration)
    }
    */
    
    
}


fileprivate extension AUAudioUnitPreset {
    
    convenience init(number: Int, name: String) {
        self.init()
        self.number = number
        self.name = name
    }
    
}


fileprivate extension FourCharCode {
    
    var stringValue: String {
        let value = CFSwapInt32BigToHost(self)
        let bytes = [0, 8, 16, 24].map { UInt8(value >> $0 & 0x000000FF) }
        guard let result = String(bytes: bytes, encoding: .utf8) else {
            return "fail"
        }
        return result
    }
    
}
