# iShader

iShader is a collection of _open-source_ shaders written in Metal targeted for SwiftUI projects. The package is organized into different submodules based on use cases & functionality of shaders:

<details>
<summary> AudioVisualizer </summary>

Shaders in this module are designed to respond to changes in sound frequencies.
The shaders in this section are primarily designed for non-scientific purposes. It's written to look responsive and aesthetic when used to visualize music.

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

A Transition is an animation that smoothly animates the intermediary steps between 2 SwiftUI `Views`.

</details>



## See it in action

**[Book iShader](https://github.com/Treata11/Book-iShader)** is a SwiftUI-based sample app that demonstrates the entire collection of metal fragment shaders available in the iShader library.

<img src="https://github.com/Treata11/iShader/blob/main/Misc/Book_iShader.jpeg">


## Resources

The majority of the shaders were sourced from platforms such as [ShaderToy](https://www.shadertoy.com/) and [GL-Transition](https://gl-transitions.com/), and subsequently adapted for Metal.
Prior to inclusion in iShader, it was ensured that the original codes were published under permissive licenses. Links to the original sources are provided in the header of each file.
