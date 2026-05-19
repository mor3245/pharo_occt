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
	#superclass : 'FFIOpaqueObject',
	#category : 'MyOpenCascade-Base',
	#package : 'MyOpenCascade',
	#tag : 'Base'
}

{ #category : 'as yet unclassified' }
MyShape >> cutWith: anotherShape [
	"Performs a Boolean cut of anotherShape from this shape via the C++ layer."

	CxxOcctLibrary cxxCut: handle with: anotherShape handle
]

{ #category : 'finalization' }
MyShape >> finalize [
	"Best-effort; prefer calling #free explicitly."

	"GC safety net: frees the C++ handle if #free was not called explicitly."

	self free
]

{ #category : 'finalization' }
MyShape >> free [
	"Releases the C++ Shape object and nulls the handle to prevent double-free."

	handle ifNil: [ ^ self ].
	handle isNull ifTrue: [ ^ self ].
	CxxOcctLibrary cxxShapeDelete: self.
	handle beNull
]

{ #category : 'accessing' }
MyShape >> handle [
	"Returns the raw ExternalAddress pointing to the C++ Shape object."

	^ handle
]

{ #category : 'accessing' }
MyShape >> handle: anObject [
	"Sets the raw ExternalAddress for this shape; used during construction."

	handle := anObject
]

{ #category : 'as yet unclassified' }
MyShape >> normalBufferLength [
	"Returns the number of doubles in the normal buffer (vertexCount * 3)."

	^ CxxOcctLibrary cxxGetNormalBufferLength: self
]

{ #category : 'accessing' }
MyShape >> normals [
	"Returns a Float64Array of per-vertex normals, or an empty array if not yet tessellated."

	| address |
	address := CxxOcctLibrary cxxGetNormals: self.
	address isNull ifTrue: [ ^ Float64Array new: 0 ].
	^ MyMakeShape float64ArrayFromExternalAddress: address count: self normalBufferLength
]

{ #category : 'converting' }
MyShape >> tessellateDeflection: deflection [
	"Instructs the C++ engine to generate a mesh for this shape at the given chord deflection."

	CxxOcctLibrary cxxTessellate: self deflection: deflection
]

{ #category : 'accessing' }
MyShape >> triangleCount [
	"Returns the number of triangles in the tessellated mesh."

	^ CxxOcctLibrary cxxTriangleCount: self
]

{ #category : 'as yet unclassified' }
MyShape >> triangleIndexCount [
	"Returns the total number of indices in the triangle buffer (triangleCount * 3)."

	^ CxxOcctLibrary cxxGetTriangleIndexCount: self
]

{ #category : 'access' }
MyShape >> triangles [
	"Returns an Array of triangle vertex indices, or an empty array if not yet tessellated."

	| address |
	address := CxxOcctLibrary cxxGetTriangles: self.
	address isNull ifTrue: [ ^ Array new: 0 ].
	^ MyMakeShape int32ArrayFromExternalAddress: address count: self triangleIndexCount
]

{ #category : 'as yet unclassified' }
MyShape >> vertexBufferLength [
	"Returns the number of doubles in the vertex buffer (vertexCount * 3)."

	^ CxxOcctLibrary cxxGetVertexBufferLength: self
]

{ #category : 'accessing' }
MyShape >> vertexCount [
	"Returns the number of vertices in the tessellated mesh."

	^ CxxOcctLibrary cxxVertexCount: self
]

{ #category : 'accessing' }
MyShape >> vertices [
	"Returns a Float64Array of vertex positions, or an empty array if not yet tessellated."

	| address |
	address := CxxOcctLibrary cxxGetVertices: self.
	address isNull ifTrue: [ ^ Float64Array new: 0 ].
	^ MyMakeShape float64ArrayFromExternalAddress: address count: self vertexBufferLength
]
