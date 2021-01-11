# shadow-sdf-godot
This repo is an attempt to genererate real-time shadows using [Ray marching](https://en.wikipedia.org/wiki/Volume_ray_casting)  
Keep in mind this is a proof of concept.  

This was done with godot 3.2

![shadow with sdf](https://github.com/Eptwalabha/shadow-sdf-godot/blob/main/image/screen-01.png?raw=true )

# How does it works ?

A «shadow layer» is generated using a ray marcher on the SDF (Signed Distance Function) of your 3D scene.  
Once this layer is constructed, we can "mix" it with the current `SCREEN_TEXTURE` to simulate shades.  

## How do we cast shadow with a Ray marcher ?

This is a two steps process:  
1. We cast a ray from the camera and "march" along that ray until it hits a surface in the scene.
2. From this point, we cast a second ray only this time we "march" toward a light source.

If the second ray hits a surface on its way to the light source, this means our screen pixel is in the shade, if not, it's in the light.

With a bit of trickery, we can also compute (almost for free):
- Feathered shadow
- Ambient Occlusion

## Using the `DEPTH_BUFFER`

The nice thing about the `DEPTH_BUFFER` is it can be used to by-pass step 1 entirely.  
Because we can construct the world position for each pixel of our screen (see [this tutorial](https://docs.godotengine.org/en/stable/tutorials/shading/advanced_postprocessing.html#depth-texture) for more informations on how to proceed).  
This trick saves us a lot of GPU computation.  

# Screenshots

![screenshot 1](https://github.com/Eptwalabha/shadow-sdf-godot/blob/main/image/screen-02.png?raw=true )
![screenshot 2](https://github.com/Eptwalabha/shadow-sdf-godot/blob/main/image/screen-03.png?raw=true )

# How do I use this technique for my game ?

:warning: You must be familiar with SDF to use this technique. If you're not, you can find a list of ressources that might help you.

## 1. Set-up the `Camera` of your scene

Add a `QuadMesh` (`MeshInstance`) as a child of your camera. Because this mesh must cover its entire field of view, you have to set its size to `Vector2(2, 2)`.  
Finaly, add a `ShaderMaterial` with the shader in `shader/SDFShadow.shader`.

## 2. Set-up the SDF's scene

For this technique to work every elements in your scene (or at leat those that need to cast shadows) must have their counter-part in the SDF scene.  
The SDF scene should be defined in the `float map(vec3 p)` function in `shader/SDFShadow.shader`.  


# Drawbacks

If you wish to use this technique in your game, you should be aware that it comes with a lot of drawbacks:
- Although mesh that are not defined in the SDF's scene will catch shadows but won't cast any.
- Moving meshes need to be updated every frame they're in motion (using `uniform`)
- Generating the SDF scene ~~can be~~ is cumbersome.
- Performances on low-end computer are atrocious.
- Performances tank rather quickly if your SDF contains too much geometry
- Same with lights
Even if the result is interesting, here are the points 

# SDF/Ray marching ressources:

- mandatory [SDF](https://en.wikipedia.org/wiki/Signed_distance_function) and [Ray marching](https://en.wikipedia.org/wiki/Volume_ray_casting) articles
- Iñigo QUILEZ's [website](https://www.iquilezles.org/www/index.htm) and [youtube](https://www.youtube.com/user/mari1234mari) chanel
- The art of code [youtube](https://www.youtube.com/channel/UCcAlTqd9zID6aNX3TzwxJXg)
- another one of my [repo](https://github.com/Eptwalabha/raymarching-godot)
