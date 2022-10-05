## Audio Unit

To create the SongFinderAudioUnit and SongFinderParameters classes, I started with sample code from Apple, including [this](https://developer.apple.com/documentation/audiotoolbox/audio_unit_v3_plug-ins/creating_custom_audio_effects). I suspect that some code (e.g. that dealing with MIDI) inherited from the sample is not needed by Hear Birds Again, but I have not removed it yet. I hope to perform a careful refactoring and cleanup of the code at some point to make it simpler and easier to understand. I would also like to minimize the amount of Objective-C code involved. As of this writing, however, at least some Objective-C code seems to be required as glue between Swift and C++. Apparently Swift code [can't call C++ code directly](https://forums.swift.org/t/running-of-c-code-or-library-in-windows-swift-program/46960), but it can call it via Objective-C code.

The C++ code that performs the SongFinder signal processing was written and tested outside of the HBA app and then brought into it.

