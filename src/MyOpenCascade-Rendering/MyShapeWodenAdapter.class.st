Class {
	#name : 'MyShapeWodenAdapter',
	#superclass : 'Object',
	#instVars : [
		'renderStyle'
	],
	#category : 'MyOpenCascade-Rendering',
	#package : 'MyOpenCascade-Rendering'
}

{ #category : 'instance creation' }
MyShapeWodenAdapter class >> renderStyle: aRenderStyle [

	^ self new
		  renderStyle: aRenderStyle;
		  yourself
]

{ #category : 'converting' }
MyShapeWodenAdapter >> asWDDisplayNode: aShape edgeDeflection: edgeDeflection [
	"Converts a CAD shape into one scene node containing shaded faces and sampled topological edge lines."

	| faceMesh edgeMesh node |
	faceMesh := self asWDMesh: aShape.
	edgeMesh := self asWDEdgeMesh: aShape deflection: edgeDeflection.

	node := WDSceneNode new.
	node renderables: (edgeMesh ifNil: [ { faceMesh } ] ifNotNil: [
				 {
					 faceMesh.
					 edgeMesh } ]).
	^ node
]

{ #category : 'converting' }
MyShapeWodenAdapter >> asWDEdgeMesh: aShape deflection: edgeDeflection [
	"Converts sampled topological edges into a Woden line mesh."

	| edgeVertices edgeSegmentCount builder |
	aShape sampleEdgesDeflection: edgeDeflection.
	edgeVertices := aShape edgeVertices.
	edgeVertices isEmpty ifTrue: [ ^ nil ].

	edgeSegmentCount := aShape edgeSegmentCount.
	edgeSegmentCount <= 0 ifTrue: [ ^ nil ].

	builder := WDMeshBuilder new.
	builder currentMaterial: self renderStyle edgeMaterial.
	builder beginLines.

	0 to: (edgeVertices size // 3) - 1 do: [ :index |
			builder
				addPx: (edgeVertices at: index * 3 + 1)
				y: (edgeVertices at: index * 3 + 2)
				z: (edgeVertices at: index * 3 + 3) ].

	0 to: edgeSegmentCount - 1 do: [ :index |
			builder addLineI0: index * 2 i1: index * 2 + 1 ].

	^ builder mesh
]

{ #category : 'converting' }
MyShapeWodenAdapter >> asWDMesh: aShape [
	"Converts a tessellated MyShape into a WDMesh by feeding vertices, normals, and triangle indices into a WDMeshBuilder."

	| verts norms tris builder |
	verts := aShape vertices.
	norms := aShape normals.
	tris := aShape triangles.

	builder := WDMeshBuilder new.
	builder currentMaterial: self renderStyle faceMaterial.
	builder beginTriangles. "add vertices and normals"
	0 to: aShape vertexCount - 1 do: [ :i |
			builder addPx: (verts at: i * 3 + 1) y: (verts at: i * 3 + 2) z: (verts at: i * 3 + 3).
			builder addNx: (norms at: i * 3 + 1) y: (norms at: i * 3 + 2) z: (norms at: i * 3 + 3) ]. "add triangles"
	0 to: aShape triangleCount - 1 do: [ :i |
	builder addTriangleI0: (tris at: i * 3 + 1) i1: (tris at: i * 3 + 2) i2: (tris at: i * 3 + 3) ].

	^ builder mesh
]

{ #category : 'accessing' }
MyShapeWodenAdapter >> renderStyle [

	^ renderStyle ifNil: [ renderStyle := MyWodenRenderStyle default ]
]

{ #category : 'accessing' }
MyShapeWodenAdapter >> renderStyle: aRenderStyle [

	renderStyle := aRenderStyle
]
