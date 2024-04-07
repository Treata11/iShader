# iShader

iShader is a collection of open-source shaders written in Metal targeted for SwiftUI projects. The package is organized into different submodules based on use cases & functionality of shaders:

<details>
<summary> AudioVisualizer </summary>

Shaders in this module are designed to respond to changes in sound frequencies, facilitated by the integration of the [BASS framework](https://www.un4seen.com/bass.html). 
Please be aware that BASS is only free for non-commercial use.

</details>


<details>
<summary> ColorEffect </summary>

ColorEffect shaders act as a filter effect on the color of each pixel. 
You've probably used them many times editing a photo taken with your phone.


</details>


<details>
<summary> DistortionEffect </summary>

DistortionEffects manipulate the location of each pixel. Seen in many Video editing tools.

</details>


<details>
<summary> LayerEffect </summary>

Very similar to ColorEffect, but much more powerful. These shaders are capable of sampling a SwiftUI `layer` at location(s) derived from any `position` and then applying some kind of transformation to produce a new color.

</details>


<details>
<summary> ShaderArt </summary>

Art using pure math!
The results are mesmerizing. 

</details>


<details>
<summary> Transition </summary>

Work In Process

</details>



## See it in action

[Book iShader](https://github.com/Treata11/Book-iShader) is a sample project, demonstrating all of the metal shaders of the library, in SwiftUI Views.

<img src="https://github.com/Treata11/iShader/blob/main/Misc/Book_iShader.jpeg">


## Resources

The majority of the shaders were sourced from platforms such as [ShaderToy](https://www.shadertoy.com/) and [GL-Transition](https://gl-transitions.com/), and subsequently adapted for Metal.
Prior to inclusion in iShader, it was ensured that the original codes were published under permissive licenses. Links to the original sources are provided in the header of each file.



## Creation Journey

<details>
<summary> Details </summary>

I started working on a 3D MIDI Visualizer app early in October of 23 in order to participate in Swift Student Challenge.
The project depended on RealityKit, ARKit and SceneKit for the visualization and my app didn't rely on any specific signal processing since the MIDI data was directly visualized.

I thought about bringing the project to a next level; Visualizing audio Signals!
Did a bit of a research on those topics and at first I used SwiftUI's ViewBuilders such as `Canvas` & `Path` for visualization. But I wasn't very satisfied 'til I got introduced to shaders.
There were some GitHub repos which linked [ShaderToy](https://www.shadertoy.com/) and when I visted that web, I lost the count of hours.
I was exploring countless hours on that platfrom and I literally was astounded!

Got many of the best shaders transferred to metal when I was testing the new iOS 17 SwiftUI shaders and tried to visualized audio with them. 
I firstly deployed the Apple's `AVAudioEngine` to sample audio. But it had a limited 10fps sampling rate, which is not enough for this purpose.
That was when I started another research to find another solution and I found [MuVis](https://github.com/Keith-43/MuVis-v2.1.1) written by 
[Keith Bromley](https://github.com/Keith-43).
He already was ahead of me and used a **C audio library** called [BASS](https://www.un4seen.com/bass.html) which we then wrapped it in a standalone swift package called [CBass](https://github.com/Treata11/CBass) ...

I already had dozens of `GLSL` shaders tranferred to metal for tests and perhaps enthusiasm. And I used BASS as the audio engine and that got me to delve deeper into shaders. That was when I figured that I could share all the work that I've done and maybe even expand it.
So, I started writing some basic shaders and improving the shaders of others by introducing new arguments and making them more efficient and enhancing their readability ... and included all in iShader.

At the end, you might see that I'm the main contributor of this repo, but there are many people envolved and I have to give credits to the open-source shader community.

</details>
