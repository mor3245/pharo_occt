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
	#instVars : [
		'brepData'
	],
	#category : 'MyOpenCascade-Base',
	#package : 'MyOpenCascade',
	#tag : 'Base'
}

{ #category : 'persistence' }
MyShape >> brepData [
	"Answers the Smalltalk-owned OCCT BREP snapshot used to recreate the native handle."

	^ brepData
]

{ #category : 'persistence' }
MyShape >> captureBRepData [
	"Refreshes the Smalltalk-owned BREP snapshot from the current native shape."

	| size buffer written |
	self hasNativeHandle ifFalse: [ ^ self ].

	size := CxxOcctLibrary cxxExportBRepSize: self.
	size <= 0 ifTrue: [ ^ self ].

	buffer := ByteArray new: size.
	written := CxxOcctLibrary cxxExportBRep: self buffer: buffer length: size.
	written = size ifFalse: [ ^ self ].

	brepData := buffer
]

{ #category : 'boolean operation' }
MyShape >> cutWith: anotherShape [
	"Performs a Boolean cut of anotherShape from this shape via the C++ layer."

	| result |
	self ensureNativeHandle.
	anotherShape ensureNativeHandle.
	result := CxxOcctLibrary cxxCut: self with: anotherShape.
	result isNil ifTrue: [ ^ nil ].
	result captureBRepData.
	^ result
]

{ #category : 'private' }
MyShape >> ensureNativeHandle [
	"Recreates the native OCCT shape from the BREP snapshot after an image restart."

	| restored |
	self hasNativeHandle ifTrue: [ ^ self ].
	(brepData isNil or: [ brepData isEmpty ]) ifTrue: [ ^ self ].

	restored := CxxOcctLibrary cxxImportBRep: brepData length: brepData size.
	(restored isNil or: [ restored hasNativeHandle not ]) ifTrue: [ ^ self ].

	handle := restored handle.
	restored handle: nil
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

{ #category : 'private' }
MyShape >> hasNativeHandle [
	"Answers whether the native pointer is currently usable without rehydration."

	^ handle notNil and: [ handle isNull not ]
]

{ #category : 'testing' }
MyShape >> isNull [
	"Answers whether this shape has no valid native handle."

	self ensureNativeHandle.
	^ self hasNativeHandle not
]

{ #category : 'accessing' }
MyShape >> normalBufferLength [
	"Returns the number of doubles in the normal buffer (vertexCount * 3)."

	self ensureNativeHandle.
	^ CxxOcctLibrary cxxGetNormalBufferLength: self
]

{ #category : 'accessing' }
MyShape >> normals [
	"Returns a Float64Array of per-vertex normals, or an empty array if not yet tessellated."

	| address |
	self ensureNativeHandle.
	address := CxxOcctLibrary cxxGetNormals: self.
	address isNull ifTrue: [ ^ Float64Array new: 0 ].
	^ MyMakeShape float64ArrayFromExternalAddress: address count: self normalBufferLength
]

{ #category : 'transforming' }
MyShape >> rotateDegrees: degrees aroundAxis: axisSymbol center: centerPoint [
	"Applies CAD-level rotation around one global axis and a world-space center point."

	axisSymbol = #x ifTrue: [
			^ self
				  rotateDegreesOnX: degrees
				  y: 0
				  z: 0
				  around: centerPoint ].

	axisSymbol = #y ifTrue: [
			^ self
				  rotateDegreesOnX: 0
				  y: degrees
				  z: 0
				  around: centerPoint ].

	axisSymbol = #z ifTrue: [
			^ self
				  rotateDegreesOnX: 0
				  y: 0
				  z: degrees
				  around: centerPoint ]
]

{ #category : 'transforming' }
MyShape >> rotateDegreesOnX: xDegrees y: yDegrees z: zDegrees around: centerPoint [
	"Applies CAD-level Euler rotation around a world-space center point."

	self ensureNativeHandle.
	CxxOcctLibrary
		cxxRotateShape: self
		xDegrees: xDegrees
		yDegrees: yDegrees
		zDegrees: zDegrees
		centerX: centerPoint x
		centerY: centerPoint y
		centerZ: centerPoint z.
	self captureBRepData
]

{ #category : 'transforming' }
MyShape >> scaleBy: aVector [
	"Applies CAD-level non-uniform scale to the underlying OpenCascade shape."

	CxxOcctLibrary
		cxxScaleShape: self
		sx: aVector x
		sy: aVector y
		sz: aVector z
]

{ #category : 'converting' }
MyShape >> tessellateDeflection: deflection [
	"Instructs the C++ engine to generate a mesh for this shape at the given chord deflection."

	self ensureNativeHandle.
	CxxOcctLibrary cxxTessellate: self deflection: deflection
]

{ #category : 'transforming' }
MyShape >> translateBy: aVector [
	"Applies a CAD-level translation to the underlying OpenCascade shape."

	self ensureNativeHandle.
	CxxOcctLibrary
		cxxTranslateShape: self
		x: aVector x
		y: aVector y
		z: aVector z.
	self captureBRepData
]

{ #category : 'accessing' }
MyShape >> triangleCount [
	"Returns the number of triangles in the tessellated mesh."

	self ensureNativeHandle.
	^ CxxOcctLibrary cxxTriangleCount: self
]

{ #category : 'accessing' }
MyShape >> triangleIndexCount [
	"Returns the total number of indices in the triangle buffer (triangleCount * 3)."

	self ensureNativeHandle.
	^ CxxOcctLibrary cxxGetTriangleIndexCount: self
]

{ #category : 'accessing' }
MyShape >> triangles [
	"Returns an Array of triangle vertex indices, or an empty array if not yet tessellated."

	| address |
	self ensureNativeHandle.
	address := CxxOcctLibrary cxxGetTriangles: self.
	address isNull ifTrue: [ ^ Array new: 0 ].
	^ MyMakeShape int32ArrayFromExternalAddress: address count: self triangleIndexCount
]

{ #category : 'accessing' }
MyShape >> vertexBufferLength [
	"Returns the number of doubles in the vertex buffer (vertexCount * 3)."

	self ensureNativeHandle.
	^ CxxOcctLibrary cxxGetVertexBufferLength: self
]

{ #category : 'accessing' }
MyShape >> vertexCount [
	"Returns the number of vertices in the tessellated mesh."

	self ensureNativeHandle.
	^ CxxOcctLibrary cxxVertexCount: self
]

{ #category : 'accessing' }
MyShape >> vertices [
	"Returns a Float64Array of vertex positions, or an empty array if not yet tessellated."

	| address |
	self ensureNativeHandle.
	address := CxxOcctLibrary cxxGetVertices: self.
	address isNull ifTrue: [ ^ Float64Array new: 0 ].
	^ MyMakeShape float64ArrayFromExternalAddress: address count: self vertexBufferLength
]
