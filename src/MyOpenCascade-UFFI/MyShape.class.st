Class {
	#name : 'MyShape',
	#superclass : 'Object',
	#instVars : [
		'handle'
	],
	#category : 'MyOpenCascade-UFFI',
	#package : 'MyOpenCascade-UFFI'
}

{ #category : 'instance creation' }
MyShape class >> on: anExternalHandle [


	^ self new initializeOn: anExternalHandle
]

{ #category : 'converting' }
MyShape >> asWDMesh [
    | verts norms tris builder |
    verts := self vertices.
    norms := self normals.
    tris  := self triangles.

    builder := WDMeshBuilder new.
    builder beginTriangles.

    "add vertices and normals"
    0 to: self vertexCount - 1 do: [:i |
        builder
            addPx: (verts at: i*3 + 1)
             y: (verts at: i*3 + 2)
             z: (verts at: i*3 + 3).
        builder
            addNx: (norms at: i*3 + 1)
             y: (norms at: i*3 + 2)
             z: (norms at: i*3 + 3).
    ].

    "add triangles"
    0 to: self triangleCount - 1 do: [:i |
        builder
            addTriangleI0: (tris at: i*3 + 1)
            i1: (tris at: i*3 + 2)
            i2: (tris at: i*3 + 3).
    ].

    ^ builder mesh
]

{ #category : 'converting' }
MyShape >> asWodenSceneNode [
    | meshBuilder mesh scene |
    meshBuilder := WDMeshBuilder new.

    "Populate meshBuilder here from self vertices / triangles / normals."

    mesh := meshBuilder mesh.
    scene := WDScene new.
    scene add: mesh.
    scene add: ((WDPointLightSource new
                    color: (Vector3 x: 0.8 y: 0.8 z: 0.2);
                    intensity: 5.0;
                    influenceRadius: 4.0;
                    asSceneNode)
                    position: (Vector3 x: -1.5 y: 1.5 z: 1.6);
                    yourself).
    ^ scene
]

{ #category : 'finalization' }
MyShape >> finalize [
	"Best-effort; prefer calling #free explicitly."
	self free.
]

{ #category : 'finalization' }
MyShape >> free [

	handle ifNil: [ ^ self ].
	CxxBoxLibrary cxxShapeDelete: handle.
	handle := nil
]

{ #category : 'initialization' }
MyShape >> initializeOn: anExternalHandle [


	handle := anExternalHandle.
	^ self
]

{ #category : 'accessing' }
MyShape >> normals [
	^ MyBoxMaker float64ArrayFromBytes: self normalsBytes
]

{ #category : 'as yet unclassified' }
MyShape >> normalsBytes [
	| count bytes |
	count := self vertexCount * 3.
	bytes := ByteArray new: count * 8.
	CxxBoxLibrary cxxGetAllNormals: handle buffer: bytes.
	^ bytes
]

{ #category : 'as yet unclassified' }
MyShape >> tessellateDeflection: deflection [
	CxxBoxLibrary cxxTessellate: handle deflection: deflection.
]

{ #category : 'as yet unclassified' }
MyShape >> triangleCount [
	^ CxxBoxLibrary cxxTriangleCount: handle
]

{ #category : 'as yet unclassified' }
MyShape >> triangles [
	^ MyBoxMaker int32ArrayFromBytes: self trianglesBytes
]

{ #category : 'as yet unclassified' }
MyShape >> trianglesBytes [
	| count bytes |
	count := self triangleCount * 3.
	bytes := ByteArray new: count * 4.
	CxxBoxLibrary cxxGetAllTriangles: handle buffer: bytes.
	^ bytes
]

{ #category : 'accessing' }
MyShape >> vertexCount [
	^ CxxBoxLibrary cxxVertexCount: handle
]

{ #category : 'accessing' }
MyShape >> vertices [

	^ MyBoxMaker float64ArrayFromBytes: self verticesBytes
]

{ #category : 'as yet unclassified' }
MyShape >> verticesBytes [
	| count bytes |
	count := self vertexCount * 3.
	bytes := ByteArray new: count * 8.
	CxxBoxLibrary cxxGetAllVertices: handle buffer: bytes.
	^ bytes
]
