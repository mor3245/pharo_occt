Class {
	#name : 'MyWodenRenderStyle',
	#superclass : 'Object',
	#instVars : [
		'edgeDeflectionFactor'
	],
	#category : 'MyOpenCascade-Rendering',
	#package : 'MyOpenCascade-Rendering'
}

{ #category : 'instance creation' }
MyWodenRenderStyle class >> default [

	^ self new
]

{ #category : 'accessing' }
MyWodenRenderStyle >> edgeDeflectionFactor [

	^ edgeDeflectionFactor ifNil: [ 0.25 ]
]

{ #category : 'accessing' }
MyWodenRenderStyle >> edgeDeflectionFactor: aNumber [

	edgeDeflectionFactor := aNumber
]

{ #category : 'rendering' }
MyWodenRenderStyle >> edgeDeflectionFor: faceDeflection [

	^ faceDeflection * self edgeDeflectionFactor
]

{ #category : 'rendering' }
MyWodenRenderStyle >> edgeMaterial [
	"Answers a dark unlit material for topological edge overlays."

	^ WDUnlitMaterial new
		  colorFactor: (Color gray: 0.06);
		  yourself
]

{ #category : 'rendering' }
MyWodenRenderStyle >> faceMaterial [
	"Answers a neutral, non-metallic CAD material with enough roughness to show form without glossy glare."

	^ WDMetallicRoughnessMaterial new
		  baseColorFactor: (Color gray: 0.62);
		  metallicFactor: 0.0;
		  roughnessFactor: 0.55;
		  yourself
]
