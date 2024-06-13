import * as THREE from 'three'
import { OrbitControls } from 'three/addons/controls/OrbitControls.js'
import GUI from 'lil-gui'
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js'

import holographicVertexShader from './shaders/holographic/vertex.glsl'
import holographicFragmentShader from './shaders/holographic/fragment.glsl'

/**
 * Base
 */
// Debug
const gui = new GUI()

// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()

// Loaders
const gltfLoader = new GLTFLoader()

/**
 * Sizes
 */
const sizes = {
  width: window.innerWidth,
  height: window.innerHeight,
}

window.addEventListener('resize', () => {
  // Update sizes
  sizes.width = window.innerWidth
  sizes.height = window.innerHeight

  // Update camera
  camera.aspect = sizes.width / sizes.height
  camera.updateProjectionMatrix()

  // Update renderer
  renderer.setSize(sizes.width, sizes.height)
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})

/**
 * Camera
 */
// Base camera
const camera = new THREE.PerspectiveCamera(
  25,
  sizes.width / sizes.height,
  0.1,
  100
)
camera.position.set(7, 7, 7)
scene.add(camera)

// Controls
const controls = new OrbitControls(camera, canvas)
controls.enableDamping = true

/**
 * Renderer
 */
const rendererParameters = {}
rendererParameters.clearColor = '#1d1f2a'

const renderer = new THREE.WebGLRenderer({
  canvas: canvas,
  antialias: true,
})
renderer.setClearColor(rendererParameters.clearColor)
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

gui.addColor(rendererParameters, 'clearColor').onChange(() => {
  renderer.setClearColor(rendererParameters.clearColor)
})

/**
 * Material
 *
 */

// *11 tweaks
const materialParameters = {}
materialParameters.color = '#70c1ff'

const material = new THREE.ShaderMaterial({
  vertexShader: holographicVertexShader,
  fragmentShader: holographicFragmentShader,
  transparent: true,
  uniforms: {
    uTime: new THREE.Uniform(0),
    uColor: new THREE.Uniform(new THREE.Color(materialParameters.color)), //* 10 Colors
  },
  //* 8 Backside
  //! we did with the Fresnel, we added 1.0 to the dot resulting in values going from 1.0 to 2.0 in the back,
  //! which is why it looks so bright now:
  //todo: To fix that, we are going to invert the normals, but only for the back side.-> fragmentShader
  side: THREE.DoubleSide,
  //? the front side occluding the back side because it is currently writing on the depth buffer.
  //? Set depthWrite to false on the material to stop rendering on the depth buffer:
  depthWrite: false,
  //? since holograms are supposedly composed of light, we can change the blending to AdditiveBlending in the material:
  blending: THREE.AdditiveBlending,
})

gui
  .addColor(materialParameters, 'color')
  .name('Model color')
  .onChange(() => material.uniforms.uColor.value.set(materialParameters.color))

/**
 * Objects
 */
// Torus knot
const torusKnot = new THREE.Mesh(
  new THREE.TorusKnotGeometry(0.6, 0.25, 128, 32),
  material
)
torusKnot.position.x = 3
scene.add(torusKnot)

// Sphere
const sphere = new THREE.Mesh(new THREE.SphereGeometry(), material)
sphere.position.x = -3
scene.add(sphere)

// Suzanne
let suzanne = null
gltfLoader.load('./suzanne.glb', (gltf) => {
  suzanne = gltf.scene
  suzanne.traverse((child) => {
    if (child.isMesh) child.material = material
  })
  scene.add(suzanne)
})

/**
 * Animate
 */
const clock = new THREE.Clock()

const tick = () => {
  const elapsedTime = clock.getElapsedTime()

  // Update material
  material.uniforms.uTime.value = elapsedTime

  // Rotate objects
  if (suzanne) {
    suzanne.rotation.x = -elapsedTime * 0.1
    suzanne.rotation.y = elapsedTime * 0.2
  }

  sphere.rotation.x = -elapsedTime * 0.1
  sphere.rotation.y = elapsedTime * 0.2

  torusKnot.rotation.x = -elapsedTime * 0.1
  torusKnot.rotation.y = elapsedTime * 0.2

  // Update controls
  controls.update()

  // Render
  renderer.render(scene, camera)

  // Call tick again on the next frame
  window.requestAnimationFrame(tick)
}

tick()
