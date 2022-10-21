//
//  ProjectInfoPage.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/19/22.
//

import SwiftUI

struct ProjectInfoPage: View {
    
    var body: some View {
        
        VStack {
            
            VStack(alignment: .leading) {
                
                InfoPageTitle("The Project")
                
                Text("""
***Hear Birds Again*** is a project of [Miracle of Nature](https://miracleofnature.org), a 501(c)(3) nonprofit. The app is free and open source software, with source code available [here](https://github.com/HaroldMills/hear-birds-again).
""")
                .padding()
                
                InfoPageSectionHeader("Our Team")
                
                Image("LangElliott")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding([.leading, .top, .trailing])
                
                Text("**Lang Elliott**")
                    .font(.title3)
                    .padding([.leading, .trailing])
                
                Text("""
Hi all! I am a well-known professional nature recordist and the author of numerous audio guides to birds and other wildlife. Notably, I suffer from high frequency deafness (read my story [here](https://hearbirdsagain.org/story-behind-app)), which makes me the perfect “poster child” for our cause.

In spite of my disability, I have authored numerous audio guides to bird and other wildlife sounds and I’m also the creator of [Pure Nature 3D Audio](https://musicofnature.com/app/), an iOS app that features immersive soundscapes from wild areas across North America. You can learn more about me on my [Music of Nature](https://musicofnature.com/) website.
""")
                .padding()

                Image("HaroldMills")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding([.leading, .top, .trailing])
                
                Text("**Harold Mills**")
                    .font(.title3)
                    .padding([.leading, .trailing])
                
                Text("""
I’m a computer programmer, audio signal processing engineer, bird enthusiast, and musician who’s been in love with sound all my life. I’ve focused on audio in most of my work, including at the Cornell Lab of Ornithology, where I was the initial lead developer of the [Raven](https://ravensoundsoftware.com/) sound analysis software, and most recently as the developer of the open source [Vesper](https://github.com/HaroldMills/Vesper) acoustic bird migration monitoring software and ***Hear Birds Again***.
""")
                .padding()
                
            }
            .hbaScrollbar()
            
            Rectangle()
                .frame(height: 45)
                .foregroundColor(.clear)
            
        }
        .hbaBackground()

    }
    
}

struct ProjectInfoPage_Previews: PreviewProvider {
    static var previews: some View {
        ProjectInfoPage()
    }
}
