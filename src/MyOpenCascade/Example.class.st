"
I represent the example usage of the classes in MyOpenCascade-UFFI package.

I contain executable methods.

I am not and should not be referenced
"
Class {
	#name : 'Example',
	#superclass : 'Object',
	#category : 'MyOpenCascade-Example',
	#package : 'MyOpenCascade',
	#tag : 'Example'
}

{ #category : 'examples' }
Example class >> exampleBoxRender [
	"Box display example."

	| shape mesh light lightNode |
	CxxOcctLibrary cxxMemoryCheckpoint. "create and tessellate the box via OCC"
	shape := MyBoxMaker
		         tessellatedBoxDx: 1
		         dy: 1
		         dz: 1
		         deflection: 0.01. "convert to WODEN mesh"
	[
		mesh := MyShapeWodenAdapter new asWDMesh: shape. "set up light"
		light := WDPointLightSource new
			         intensity: 5.0;
			         yourself.
		lightNode := light asSceneNode.
		lightNode position: (Vector3 x: -1.5 y: 1.5 z: 1.0). "render"
		WDScene new
			add: mesh;
			add: lightNode;
			openInWindow ] ensure: [ shape free ].

	CxxOcctLibrary cxxDumpMemoryDifference
]

{ #category : 'examples' }
Example class >> exampleBoxRenderWithContextMenu [
	"Example exampleBoxRenderWithContextMenu"

	CxxOcctLibrary cxxMemoryCheckpoint.
	MyContextMenuPresenter new open.
	CxxOcctLibrary cxxDumpMemoryDifference
]

{ #category : 'as yet unclassified' }
Example class >> exampleCutRender [
	"Boolean cut display example."

	| box cylinder cutShape mesh light lightNode |
	CxxOcctLibrary cxxMemoryCheckpoint.

	box := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.

	cylinder := MyCylinderMaker makeCylinderRadius: 0.25 height: 1.5.

	cutShape := MyShape on: (CxxOcctLibrary cxxCut: box handle with: cylinder handle).

	[
		cutShape tessellateDeflection: 0.01.

		mesh := MyShapeWodenAdapter new asWDMesh: cutShape.

		light := WDPointLightSource new
			         intensity: 5.0;
			         yourself.

		lightNode := light asSceneNode.
		lightNode position: (Vector3 x: -1.5 y: 1.5 z: 1.0).

		WDScene new
			add: mesh;
			add: lightNode;
			openInWindow ] ensure: [
			cutShape free.
			cylinder free.
			box free ].

	CxxOcctLibrary cxxDumpMemoryDifference
]
