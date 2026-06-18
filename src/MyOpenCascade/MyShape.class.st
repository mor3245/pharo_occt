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
		'storagePath',
		'solidCount',
		'shellCount',
		'faceCount',
		'wireCount',
		'edgeCount',
		'topologicalVertexCount',
		'solids',
		'shells',
		'faces',
		'wires',
		'edges',
		'topologicalVertices'
	],
	#category : 'MyOpenCascade-Base',
	#package : 'MyOpenCascade',
	#tag : 'Base'
}

{ #category : 'persistence' }
MyShape class >> loadFromFile: aFileReference [
	"Loads an independently stored OCCT BREP file into a new MyShape."

	| file shape |
	file := aFileReference asFileReference.
	file exists ifFalse: [ self error: 'The OCCT shape file does not exist' ].

	shape := CxxOcctLibrary cxxReadBRepFile: file fullName.
	(shape isNil or: [ shape hasNativeHandle not ]) ifTrue: [
		self error: 'Could not read the OCCT shape file' ].
	shape storagePath: file fullName.
	^ shape
]

{ #category : 'persistence' }
MyShape class >> newStoragePath [
	"Answers a unique default path for one disk-backed OCCT shape."

	^ (self storageDirectory / (UUID new asString , '.brep')) fullName
]

{ #category : 'persistence' }
MyShape class >> storageDirectory [
	"Answers the directory containing persistent OCCT shape files."

	| directory |
	directory := FileLocator imageDirectory / 'occt-shapes'.
	directory ensureCreateDirectory.
	^ directory
]

{ #category : 'inspection' }
MyShape >> clearTopologyInspectionData [
	"Clears cached topology arrays and counts used by the raw inspector."

	solidCount := nil.
	shellCount := nil.
	faceCount := nil.
	wireCount := nil.
	edgeCount := nil.
	topologicalVertexCount := nil.
	solids := nil.
	shells := nil.
	faces := nil.
	wires := nil.
	edges := nil.
	topologicalVertices := nil
]

{ #category : 'boolean operation' }
MyShape >> cutWith: anotherShape [
	"Performs a Boolean cut of anotherShape from this shape via the C++ layer."

	| result |
	self ensureNativeHandle.
	anotherShape ensureNativeHandle.
	result := CxxOcctLibrary cxxCut: self with: anotherShape.
	result ifNil: [ ^ nil ].
	result persistToDisk.
	^ result
]

{ #category : 'boolean operation' }
MyShape >> cutWithSeparatedSolids: anotherShape [
	"Performs a Boolean cut and answers one MyShape per OCCT solid in the result."

	| result solids |
	result := self cutWith: anotherShape.
	result ifNil: [ ^ #(  ) ].

	solids := result separatedSolids.
	solids size > 1 ifTrue: [
			result free.
			^ solids ].

	solids do: [ :each | each free ].
	^ Array with: result
]

{ #category : 'persistence' }
MyShape >> deleteStorageFile [
	"Deletes this shape's persistent BREP file, if present."

	| file |
	file := self storageFileReference.
	file ifNotNil: [ file exists ifTrue: [ file delete ] ].
	storagePath := nil
]

{ #category : 'topology constants' }
MyShape >> edgeType [

	^ 6
]

{ #category : 'topology' }
MyShape >> edges [
	"Answers the unique edges contained in this shape."

	edges ifNil: [ edges := self subshapesOfType: self edgeType as: MyEdge ].
	^ edges
]

{ #category : 'private' }
MyShape >> ensureNativeHandle [
	"Recreates the native OCCT shape from its BREP file after an image restart."

	| file restored |
	self hasNativeHandle ifTrue: [ ^ self ].
	file := self storageFileReference.
	(file isNil or: [ file exists not ]) ifTrue: [ ^ self ].

	restored := CxxOcctLibrary cxxReadBRepFile: file fullName.
	(restored isNil or: [ restored hasNativeHandle not ]) ifTrue: [ ^ self ].

	handle := restored getHandle.
	restored setHandle: nil
]

{ #category : 'persistence' }
MyShape >> ensureStoragePath [

	storagePath ifNil: [ storagePath := self class newStoragePath ]
]

{ #category : 'topology constants' }
MyShape >> faceType [

	^ 4
]

{ #category : 'topology' }
MyShape >> faces [
	"Answers the unique faces contained in this shape."

	faces ifNil: [ faces := self subshapesOfType: self faceType as: MyFace ].
	^ faces
]

{ #category : 'finalization' }
MyShape >> finalize [
	"Release only process-local native memory. Disk data remains independent."

	self releaseNativeHandle
]

{ #category : 'finalization' }
MyShape >> free [
	"Permanently releases this shape's native memory and backing BREP file."

	self releaseNativeHandle.
	self deleteStorageFile
]

{ #category : 'private' }
MyShape >> hasNativeHandle [
	"Answers whether the native pointer is currently usable without rehydration."

	^ handle notNil and: [ handle isNull not ]
]

{ #category : 'inspection' }
MyShape >> hasTopologyInspectionData [
	"Answers whether the raw-inspector topology cache has already been populated."

	^ solidCount notNil
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

{ #category : 'persistence' }
MyShape >> persistToDisk [
	"Writes the current OCCT shape to its independent BREP file."

	| file succeeded |
	self hasNativeHandle ifFalse: [ self error: 'Cannot persist a shape without a native handle' ].
	self ensureStoragePath.
	file := self storageFileReference.
	file parent ensureCreateDirectory.

	succeeded := CxxOcctLibrary
		cxxWriteBRepFile: self
		path: file fullName.
	succeeded = 1 ifFalse: [ self error: 'Could not write the OCCT shape file' ].
	^ self
]

{ #category : 'inspection' }
MyShape >> refreshTopologyChildrenForInspection [
	"Populates cached topology child arrays for the raw inspector."

	solids := self subshapesOfType: self solidType as: MySolid.
	shells := self subshapesOfType: self shellType as: MyShell.
	faces := self subshapesOfType: self faceType as: MyFace.
	wires := self subshapesOfType: self wireType as: MyWire.
	edges := self subshapesOfType: self edgeType as: MyEdge.
	topologicalVertices := self subshapesOfType: self vertexType as: MyVertex
]

{ #category : 'inspection' }
MyShape >> refreshTopologyCountsForInspection [
	"Populates cached topology counts for the raw inspector."

	self ensureNativeHandle.
	solidCount := CxxOcctLibrary cxxSubshapeCount: self type: self solidType.
	shellCount := CxxOcctLibrary cxxSubshapeCount: self type: self shellType.
	faceCount := CxxOcctLibrary cxxSubshapeCount: self type: self faceType.
	wireCount := CxxOcctLibrary cxxSubshapeCount: self type: self wireType.
	edgeCount := CxxOcctLibrary cxxSubshapeCount: self type: self edgeType.
	topologicalVertexCount := CxxOcctLibrary cxxSubshapeCount: self type: self vertexType
]

{ #category : 'inspection' }
MyShape >> refreshTopologyForInspection [
	"Populates topology counts and child arrays for the raw inspector."

	^ self refreshTopologyForInspectionDepth: 6
]

{ #category : 'inspection' }
MyShape >> refreshTopologyForInspectionDepth: depth [
	"Populates this shape and a bounded number of descendants for raw inspection."

	self clearTopologyInspectionData.
	self refreshTopologyCountsForInspection.
	depth <= 0 ifTrue: [ ^ self ].

	self refreshTopologyChildrenForInspection.
	self topologyChildrenForInspection do: [ :each | each refreshTopologyForInspectionDepth: depth - 1 ].
	^ self
]

{ #category : 'finalization' }
MyShape >> releaseNativeHandle [
	"Releases only the process-local C++ shape, retaining its disk representation."

	handle ifNil: [ ^ self ].
	handle isNull ifTrue: [ ^ self ].
	CxxOcctLibrary cxxShapeDelete: self.
	handle beNull
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
	self clearTopologyInspectionData.
	self persistToDisk
]

{ #category : 'persistence' }
MyShape >> saveToFile: aFileReference [
	"Changes the backing file and writes the current OCCT shape to it."

	storagePath := aFileReference asFileReference fullName.
	^ self persistToDisk
]

{ #category : 'transforming' }
MyShape >> scaleBy: aVector [
	"Applies CAD-level non-uniform scale to the underlying OpenCascade shape."

	CxxOcctLibrary
		cxxScaleShape: self
		sx: aVector x
		sy: aVector y
		sz: aVector z.
	self clearTopologyInspectionData.
	self persistToDisk
]

{ #category : 'topology' }
MyShape >> separatedSolids [
	"Answer new MyShape handles for each OCCT solid contained in this shape."

	| count solidsTemp solid |
	self ensureNativeHandle.

	count := CxxOcctLibrary cxxSolidCount: self.
	count <= 0 ifTrue: [ ^ #(  ) ].

	solidsTemp := OrderedCollection new.
	0 to: count - 1 do: [ :index |
			solid := CxxOcctLibrary cxxSolidAt: self index: index.
			(solid notNil and: [ solid isNull not ]) ifTrue: [
					solid persistToDisk.
					solidsTemp add: solid ] ].

	^ solidsTemp asArray
]

{ #category : 'topology constants' }
MyShape >> shellType [

	^ 3
]

{ #category : 'topology' }
MyShape >> shells [
	"Answers the unique shells contained in this shape."

	shells ifNil: [ shells := self subshapesOfType: self shellType as: MyShell ].
	^ shells
]

{ #category : 'topology constants' }
MyShape >> solidType [

	^ 2
]

{ #category : 'topology' }
MyShape >> solids [
	"Answers the unique solids contained in this shape."

	solids ifNil: [ solids := self subshapesOfType: self solidType as: MySolid ].
	^ solids
]

{ #category : 'persistence' }
MyShape >> storageFileReference [

	storagePath ifNil: [ ^ nil ].
	^ storagePath asFileReference
]

{ #category : 'persistence' }
MyShape >> storagePath [

	^ storagePath
]

{ #category : 'persistence' }
MyShape >> storagePath: aString [

	storagePath := aString
]

{ #category : 'topology' }
MyShape >> subshapesOfType: typeNumber as: shapeClass [
	"Answers owned typed MyShape instances for the requested OCCT subshape kind."

	| count subshapes subshape |
	self ensureNativeHandle.

	count := CxxOcctLibrary cxxSubshapeCount: self type: typeNumber.
	count <= 0 ifTrue: [ ^ #(  ) ].

	subshapes := OrderedCollection new.
	0 to: count - 1 do: [ :index |
			subshape := CxxOcctLibrary cxxSubshapeAt: self type: typeNumber index: index.
			(subshape notNil and: [ subshape isNull not ]) ifTrue: [
					subshapes add: (self transferShape: subshape to: shapeClass) ] ].

	^ subshapes asArray
]

{ #category : 'converting' }
MyShape >> tessellateDeflection: deflection [
	"Instructs the C++ engine to generate a mesh for this shape at the given chord deflection."

	self ensureNativeHandle.
	CxxOcctLibrary cxxTessellate: self deflection: deflection
]

{ #category : 'topology' }
MyShape >> topologicalEdges [
	"Answers the unique edges contained in this shape."

	^ self edges
]

{ #category : 'topology' }
MyShape >> topologicalFaces [
	"Answers the unique faces contained in this shape."

	^ self faces
]

{ #category : 'topology' }
MyShape >> topologicalShells [
	"Answers the unique shells contained in this shape."

	^ self shells
]

{ #category : 'topology' }
MyShape >> topologicalSolids [
	"Answers the unique solids contained in this shape."

	^ self solids
]

{ #category : 'topology' }
MyShape >> topologicalVertices [
	"Answers the unique vertices contained in this shape."

	topologicalVertices ifNil: [ topologicalVertices := self subshapesOfType: self vertexType as: MyVertex ].
	^ topologicalVertices
]

{ #category : 'topology' }
MyShape >> topologicalWires [
	"Answers the unique wires contained in this shape."

	^ self wires
]

{ #category : 'inspection' }
MyShape >> topologyChildrenForInspection [
	"Answers cached topology child nodes to refresh recursively for the raw inspector."

	| children |
	children := OrderedCollection new.
	solids ifNotNil: [ children addAll: solids ].
	shells ifNotNil: [ children addAll: shells ].
	faces ifNotNil: [ children addAll: faces ].
	wires ifNotNil: [ children addAll: wires ].
	edges ifNotNil: [ children addAll: edges ].
	topologicalVertices ifNotNil: [ children addAll: topologicalVertices ].
	^ children asArray
]

{ #category : 'private' }
MyShape >> transferShape: aShape to: shapeClass [
	"Transfers a native handle from a generic MyShape into a typed MyShape subclass."

	| typedShape |
	typedShape := shapeClass new.
	typedShape setHandle: aShape getHandle.
	typedShape storagePath: aShape storagePath.
	aShape storagePath: nil.
	^ typedShape
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
	self clearTopologyInspectionData.
	self persistToDisk
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

{ #category : 'topology constants' }
MyShape >> vertexType [

	^ 7
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

{ #category : 'topology constants' }
MyShape >> wireType [

	^ 5
]

{ #category : 'topology' }
MyShape >> wires [
	"Answers the unique wires contained in this shape."

	wires ifNil: [ wires := self subshapesOfType: self wireType as: MyWire ].
	^ wires
]
