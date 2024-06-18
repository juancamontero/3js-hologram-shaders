uniform float uTime;
// * 10 color
uniform vec3 uColor;

//* 1 Stripes 
//? to use instead of the uv coords, using modelPosition
varying vec3 vPosition;

// *4  FRESNEL

varying vec3 vNormal;

void main() {

//* 1 Stripes 
// float stripes = vPosition.y;
//?gradient to get back to 0.0 when reaching 1.0 so that it repeats itself. We can achieve that using the mod function:
// float stripes = mod(vPosition.y, 1.0); 
//?Increase the frequency of the gradients by multiplying vPosition.y by 20.0:
// float stripes = mod(vPosition.y * 20.0, 1.0); 

//* 2 Animation
//?make ths stripes move on Y with time
    float stripes = mod((vPosition.y - uTime * 0.04) * 20.0, 1.0); 

//? apply a pow to take long to "take off"
    stripes = pow(stripes, 3.0);

// Final color
    // gl_FragColor = vec4(vec3(stripes), 1.0);

//* 3 Alpha
//?Until now, we have been using the stripes as the color. Let’s try it on the alpha of gl_FragColor and set the rest to 1.0:
//! enable transparent on material script: transparent: true,
    // gl_FragColor = vec4(1.0, 1.0, 1.0, stripes);

// *4  FRESNEL
//? Most of the time, holograms are represented with their outside looking brighter than the inside.
//? We can do that using the normal and the view angle.
//? We want a value to be 1.0 when the view angle is perpendicular to normal,
//? and 0.0 when the view angle is aligned with the normal: This effect is called “Fresnel”.
//? Si lo miro de frente lo veo medio transparente, pero veo los bordes del resto del modelo

// * Dot product
// ? the view vector is the vector from the CAMERA(cameraPosition uniform) to the VERTEX

//? we want to know the VIEW direction, can be done by substracting vertex pos - camera pos
// vec3 viewDirection = vPosition - cameraPosition;

//? the vector must be normalized so the DOT function can be applied
    vec3 viewDirection = normalize(vPosition - cameraPosition);

//? using DOT function we can know the angle beetwen 2 noramlized vectors:
//?  1, -1 : same direction, 0 perpendicular
// float fresnel = dot(viewDirection, vNormal); 

//? We can’t see anything because the normal vector is oriented toward the camera:
//? , I like to add 1.0 to the output of dot so that the value goes from 0.0 (opposite) to 1.0 (perpendicular) to 2.0 (same direction):
    // float fresnel = dot(viewDirection, vNormal) + 1.0;
 //* 5 Fix the normal orientation - start on vetx shader
 // Normal

 //? the normal lenght isn't 1 'cause the varyng are being interpolate and when the dot func is applied not always a 1 isthe result
 //? so a little gris pattern is visible
    vec3 normal = normalize(vNormal);

//* 8 Backside
//? to fix , invert the normals only the backside
//? There is a built-in variable named gl_FrontFacing which is a boolean being true if the fragment we are drawing is facing the camera and false otherwise.
    if(!gl_FrontFacing)
        normal *= -1.0;

    float fresnel = dot(viewDirection, normal) + 1.0;

//* Power
//? Let’s apply a power to the fresnel to make it sharper using the pow function:
//? the higyer the pow, the darker/transparent the center of the model
    fresnel = pow(fresnel, 1.75);

// * 7 Combine with sriptes
//?  holographic, which will be the final variable we use on the alpha of gl_FragColor and assign stripes to it, multiplieby fresnel:
    float holographic = stripes * fresnel;

//?We are going to add the fresnel on top of it and make it even stronger by multiplying it by 1.25:

//* 9 Falloff
//? We are going to fade out the alpha on the edges.

//?To do that, we are going to use the same Fresnel, but remap it using a smoothstep so that the value is 1.0 near the edge, and 
//?drops down smoothly to 0.0 at the very edge:

    float falloff = smoothstep(0.8, 0.0, fresnel);

    holographic += fresnel * 1.25;
    holographic *= falloff;

    gl_FragColor = vec4(uColor, holographic);

    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}