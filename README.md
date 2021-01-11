# shadow-sdf-godot
This repo is an attempt to genererate real-time shadows using [Ray marching](https://en.wikipedia.org/wiki/Volume_ray_casting)  
Keep in mind this is only a proof of concept.  

This was done with version 3.2.3 of godot

![shadow with sdf](https://github.com/Eptwalabha/shadow-sdf-godot/blob/main/image/screen-01.png?raw=true)
The shadows in the image above have been generated with a ray marcher

# How does it works ?

A "shadow layer" is generated using a ray marcher on the SDF (Signed Distance Function) of your 3D scene.  
Once this layer is constructed, we can "mix" it with the current `SCREEN_TEXTURE` to simulate shades.  

![building shadow](https://github.com/Eptwalabha/shadow-sdf-godot/blob/main/image/explanations.png?raw=true)

## Casting shadows with a Ray marcher

This is a two steps process:  
1. We cast a ray from the camera and "march" along that ray until it hits a surface in the scene.
2. From this point, we cast a second ray and "march" toward a light source.

If the second ray hits a surface on its way to the light source, this means our screen pixel is in the shade, in the light otherwise.

Using ray marching, we can also compute (for almost nothing):
- Feathered shadow
- Ambient Occlusion

Keep in mind this process needs to be repeated for each light in your scene.

## Using the `DEPTH_BUFFER`

The `DEPTH_BUFFER` can be use to construct the world position for each pixel of our screen (see [this tutorial](https://docs.godotengine.org/en/stable/tutorials/shading/advanced_postprocessing.html#depth-texture) for more informations on how to proceed), thus, by-passing step 1 entirely.  
This trick'll save us a lot of GPU computation.  

# Screenshots

![screenshot 1](https://github.com/Eptwalabha/shadow-sdf-godot/blob/main/image/screen-02.png?raw=true )
![screenshot 2](https://github.com/Eptwalabha/shadow-sdf-godot/blob/main/image/screen-03.png?raw=true )

# How to implement this technique for your game?

:warning: You must be familiar with ray marching and SDF to use this technique. If this is not the case, I provided a list of ressources at the end of this page.

## 1. Set-up the `Camera` of your scene

Add a `QuadMesh` (`MeshInstance`) as a child of your camera. It must cover the entire field of view of your camera, so you have to set its size to `Vector2(2, 2)`.  
Finaly, add a `ShaderMaterial` with the shader in `shader/SDFShadow.shader`.

## 2. Set-up the SDF's scene

For this technique to work every elements in your scene (or at leat those that need to cast shadows) must have their counter-part in the SDF scene.  
The SDF scene should be defined in the `float map(vec3 p)` function in `shader/SDFShadow.shader`.  


# Drawbacks

If you wish to use this technique in your game, I must warn you thet it comes with a lot of drawbacks:
- Meshes that are not defined in the SDF scene will catch shadows but won't cast any.
- Moving meshes need to be updated every frame using `uniform`.
- Generating the SDF scene ~~can be~~ is cumbersome.
- Performances on low-end computer are atrocious.
- Performances tank rather quickly if your SDF contains too much geometry
- Same with lights  


# SDF/Ray marching ressources:

- mandatory [SDF](https://en.wikipedia.org/wiki/Signed_distance_function) and [Ray marching](https://en.wikipedia.org/wiki/Volume_ray_casting) articles
- Iñigo QUILEZ's [website](https://www.iquilezles.org/www/index.htm) and [youtube](https://www.youtube.com/user/mari1234mari) chanel
- The art of code [youtube](https://www.youtube.com/channel/UCcAlTqd9zID6aNX3TzwxJXg)
- another one of my [repo](https://github.com/Eptwalabha/raymarching-godot)
