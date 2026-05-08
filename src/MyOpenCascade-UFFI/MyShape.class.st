"
I represent a 3D geometric shape managed by the OpenCascade C++ engine. 

I act as a high-level wrapper around an external memory handle, providing a Smalltalk-friendly interface to access geometric data such as vertices, normals, and triangles. I am typically instantiated by 'MyBoxMaker'.

Responsibilities:
- Data Access: I retrieve raw geometric data from the C++ layer and coordinate with 'MyBoxMaker' to convert that data into Pharo-native arrays (Float64Array and Int32Array).
- Tessellation: I provide the ability to trigger surface tessellation at a specific deflection tolerance via the underlying library.
- Woden Integration: I can transform myself into a 'WDMesh' or a complete 'WDScene' for 3D rendering within the Woden engine.
- Resource Management: I manage the lifecycle of my external handle. I implement #free to explicitly release C++ memory and #finalize as a safety net during garbage collection.

Public API:
- #vertices / #normals / #triangles - Return Pharo arrays containing the mesh data.
- #asWDMesh - Converts the shape's geometry into a mesh compatible with the Woden engine.
- #tessellateDeflection: - Instructs the C++ engine to generate a mesh for the shape.
- #free - Manually releases the external C++ object.

Internal Representation:
- handle: An ExternalAddress pointing to the C++ 'Shape' object.

Example:
    shape := MyBoxMaker makeBoxDx: 1.0 dy: 1.0 dz: 1.0.
    shape tessellateDeflection: 0.1.
    mesh := shape asWDMesh.
    shape free.

Class {
	#name : 'MyShape',
	#superclass : 'Object',
	#instVars : [
		'handle'
	],
	#category : 'MyOpenCascade-UFFI',
	#package : 'MyOpenCascade-UFFI'
}
"
Class {
	#name : 'MyShape',
	#superclass : 'Object',
	#instVars : [
		'handle'
	],
	#category : 'MyOpenCascade-UFFI-Base',
	#package : 'MyOpenCascade-UFFI',
	#tag : 'Base'
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
	self free
]

{ #category : 'finalization' }
MyShape >> free [

	handle ifNil: [ ^ self ].
	CxxOcctLibrary cxxShapeDelete: handle.
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

{ #category : 'low level buffer management' }
MyShape >> normalsBytes [
	| count bytes |
	count := self vertexCount * 3.
	bytes := ByteArray new: count * 8.
	CxxOcctLibrary cxxGetAllNormals: handle buffer: bytes.
	^ bytes
]

{ #category : 'converting' }
MyShape >> tessellateDeflection: deflection [
	CxxOcctLibrary cxxTessellate: handle deflection: deflection
]

{ #category : 'accessing' }
MyShape >> triangleCount [
	^ CxxOcctLibrary cxxTriangleCount: handle
]

{ #category : 'access' }
MyShape >> triangles [
	^ MyBoxMaker int32ArrayFromBytes: self trianglesBytes
]

{ #category : 'low level buffer management' }
MyShape >> trianglesBytes [
	| count bytes |
	count := self triangleCount * 3.
	bytes := ByteArray new: count * 4.
	CxxOcctLibrary cxxGetAllTriangles: handle buffer: bytes.
	^ bytes
]

{ #category : 'accessing' }
MyShape >> vertexCount [
	^ CxxOcctLibrary cxxVertexCount: handle
]

{ #category : 'accessing' }
MyShape >> vertices [

	^ MyBoxMaker float64ArrayFromBytes: self verticesBytes
]

{ #category : 'low level buffer management' }
MyShape >> verticesBytes [
	| count bytes |
	count := self vertexCount * 3.
	bytes := ByteArray new: count * 8.
	CxxOcctLibrary cxxGetAllVertices: handle buffer: bytes.
	^ bytes
]
