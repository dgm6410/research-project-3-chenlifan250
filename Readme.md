Project 3
-------------------------------------------------------------

- My Topic: Unity Shader: Burning Shader

This Shader will make burning special effect when enemy dies.

![](https://github.com/dgm6410/research-project-3-chenlifan250/raw/master/image/monalisa1.jpg)

![](https://github.com/dgm6410/research-project-3-chenlifan250/raw/master/image/monalisa2.jpg)

![](https://github.com/dgm6410/research-project-3-chenlifan250/raw/master/image/monalisa3.jpg)

-------------------------------------------------------------
DEMO HERE:
-------------------------------------------------------------
Link: https://dgm6410.github.io/research-project-3-chenlifan250/demo/index

- Game Background:
  You, Tom, are a secret agent, and you are executing a mission. Recently, a criminal gang made lots of fake paintings for
  money. You are assigned to sneak into their base to destroy these fake paintings. Now, you just found one fake painting,
  《Mona Lisa》, and you are going to burn it. Be careful! The base of criminal gang is very dangerous.

- Game Process:
  1. You already found one fake painting, 《Mona Lisa》, burn it.
  2. You are exposed. The enemy summoned bugs to attack you. Burn all the bugs to survive.

- Game Instruction:
  Simple click mouse to burn.
  
-------------------------------------------------------------

List of Content:
-------------------------------------------------------------
- Source Code with comments
- Tech Blog
- Demo(webgl)
   (https://dgm6410.github.io/research-project-3-chenlifan250/demo/index)

Tech Blog:
-------------------------------------------------------------

### 1. Perlin Noise

Perlin noise is a type of gradient noise developed by Ken Perlin in 1983 as a result of his frustration with the "machine-like" look of computer graphics at the time. He formally described his findings in a SIGGRAPH paper in 1985 called An image Synthesizer.

![](https://github.com/dgm6410/research-project-3-chenlifan250/raw/master/image/PerlinNoise.png)

### 2. Alpha Texture:
Alpha mapping is a technique in 3D computer graphics involving the use of texture mapping to designate the amount of transparency/translucency of areas in a certain object.

Alpha mapping is used when the given object's transparency is not consistent: when the transparency amount is not the same for the entire object and/or when the object is not entirely transparent. If the object has the same level of transparency everywhere, one can either use a solid color alpha texture or an integer value.

The alpha map is often encoded in the alpha channel of an RGBA texture used for coloring instead of being a standalone greyscale texture. 

### 3. Alpha Test:
In Unity Shader, the same effect as described above can be implemented with an alpha test. The advantage of the alpha test is that it runs also on older hardware that doesn't support GLSL.

~~~
fixed cutout = tex2D(_NoiseTex, i.uvNoiseTex).r;
clip(cutout - _Threshold);
~~~

Here I use the value of perlin noise as the input of alpha test. The point with higher value than threshold will be transparent.

### 4. Edge Color
I set a edge color and then find the edge according to the value in perlin noise. The points whose value is near the threshold will be rendered as edge color.
~~~
//Properties
_EdgeLength("Edge Length", Range(0.0, 0.2)) = 0.1
_EdgeColor("Border Color", Color) = (1,1,1,1)
...
//Fragment
if(cutout - _Threshold < _EdgeLength)
    return _EdgeColor;
~~~

### 5. Make it animate
To make the burning effect animate actually is to set the threshold dynamically. I set the value of threshold in Update() function in C# script, which binds to the target object. This script will be trigger once the mouse clicked on it.
~~~
burnAmounting += Time.deltaTime * burningSpeed;
material.GetComponent<Renderer>().material.SetFloat("_BurnAmount", burnAmounting);
~~~
