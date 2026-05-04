Class {
	#name : 'Example',
	#superclass : 'Object',
	#category : 'MyOpenCascade-UFFI',
	#package : 'MyOpenCascade-UFFI'
}

{ #category : 'examples' }
Example class >> exampleBoxRender [
	"Box display example."

	| shape mesh light lightNode |
	CxxBoxLibrary memoryCheckpoint. "create and tessellate the box via OCC"
	shape := MyBoxMaker
		         tessellatedBoxDx: 1
		         dy: 1
		         dz: 1
		         deflection: 0.01. "convert to WODEN mesh"
	[
		mesh := shape asWDMesh. "set up light"
		light := WDPointLightSource new
			         intensity: 5.0;
			         yourself.
		lightNode := light asSceneNode.
		lightNode position: (Vector3 x: -1.5 y: 1.5 z: 1.0). "render"
		WDScene new
			add: mesh;
			add: lightNode;
			openInWindow ] ensure: [ shape free ].

	CxxBoxLibrary dumpMemoryDifference
]

{ #category : 'as yet unclassified' }
Example class >> exampleBoxRenderWithContextMenu [
	"Example exampleBoxRenderWithContextMenu"
	
	CxxBoxLibrary memoryCheckpoint.
	MyContextMenuPresenter new open.
	CxxBoxLibrary dumpMemoryDifference
]
