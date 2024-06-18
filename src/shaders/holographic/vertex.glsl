uniform float uTime;

//* 1 Stripes
//? to use instead of the uv coords, using modelPosition 
varying vec3 vPosition;

//? to be used to generate FRESNEL
varying vec3 vNormal;

#include ../includes/radom2d.glsl

void main() {
// Position,
    vec4 modelPosition = modelMatrix * vec4(position, 1.0);

    //* 11 Glitch effect
    //?At first, we are going to make all the vertices glitch and then make the effect more sporadic.
    //?First, we want the vertices to move randomly on the x and z axes
    // modelPosition.x += random2D(modelPosition.xz);

    //? We are using modelPosition.xz as the input so that we get different offsets for each vertex. 
    //? Yet, if the model stops moving, the glitch will look static
    //? What we can do to fix that, is retrieve the uTime uniform and add it to the modelPosition.xz:
    // modelPosition.x += random2D(modelPosition.xz + uTime);
    // modelPosition.z += random2D(modelPosition.zx + uTime);

    //? objects, although very fuzzy, aren’t at their initial position anymore:
    //?random2D() returns a value from 0.0 to 1.0 making it only positive which results in the vertices going in the same general direction.
    // modelPosition.x += random2D(modelPosition.xz + uTime) - 0.5;
    // modelPosition.z += random2D(modelPosition.zx + uTime) - 0.5;

    //* 12 Variation in time and space
    //?We now want that effect to look like waves going from the bottom to the top, sporadically.
    //?glitchStrength variable and assign the result of the sin function to it,
    //? with uTime as its input.
    // float glitchStrength = sin(uTime);

    //? move from the bottom to the top, we are going to subtract modelPosition.y from uTime:
    float glitchTime = uTime - modelPosition.y;
    
    //? so the glitchStrength goes to 0 to 1 according to time
    // float glitchStrength = sin(glitchTime);

   //? suma varios senos con diferente frecuencias para somular "random" en el tiempo
    float glitchStrength = sin(glitchTime) + sin(glitchTime * 2.34) + sin(glitchTime * 5.67);
    glitchStrength /= 3.0;

    //? We want the effect to appear less often and we need to remap it. We are going to use the usual smoothstep:
    glitchStrength = smoothstep(0.3, 1.0, glitchStrength);

    glitchStrength *= glitchStrength * 0.25;
    modelPosition.x += (random2D(modelPosition.xz + uTime) - 0.5) * glitchStrength;
    modelPosition.z += (random2D(modelPosition.zx + uTime) - 0.5) * glitchStrength;

    //! Final position

    gl_Position = projectionMatrix * viewMatrix * modelPosition;

    //* Varyings

     //? in this way the patterns will adjust the object transfomation
    // vPosition = position.xyz; 
    //? in this way the patterns will adjust the worls space transfomation
    vPosition = modelPosition.xyz; //! modelPosition is a vec4

        //* 5 Fix the normal orientation
    //* model noraml
    //? the fresnel value must not change with the object rotation
    //? by multiplieng modelMatrix with the normal we obtain the model normals

    //?When the fourth value is set to 1.0, it means that our vector is “homogeneous” and all 3 transformations 
    //? (translation, rotation, scale) implied by the modelMatrix will be applied, which is perfect in the case of a position.
    //?When the fourth value is set to 0.0, it means that our vector is not homogeneous and the translation won’t be applied, 
    //?which is ideal in the case of a normal, because the normal is not a position, it’s a direction.

    //? cuando el 4to valor es 1 es un vector homogéneo, se aplican scale, translate & rotaion igual, con 0 es no-homogeneo y translate no se aplica, que es ideal para las normales, porque las normales son posicione no direcciones
    vec4 modelNormal = modelMatrix * vec4(normal, 0.0);
    // vNormal = normal; 
    vNormal = modelNormal.xyz; //use this so the normal does not roate with the model
}