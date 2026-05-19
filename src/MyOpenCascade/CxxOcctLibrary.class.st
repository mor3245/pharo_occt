"
I am the low-level FFI bridge interface to the external C++ library responsible for OpenCascade geometric operations.

I contain the technical 'Unified FFI' (UFFI) signatures required to call foreign C++ functions. I act as a stateless provider of library calls, which higher-level classes like 'MyBoxMaker' and 'MyShape' use to perform 3D operations.

Responsibilities:
- FFI Mapping: I define the mapping between Pharo methods and external C++ functions, handling type conversions for doubles, int32, and void pointers.
- Geometry Interfacing: I expose functions to create box primitives, check their status via #isDone:, and extract shape handles.
- Data Extraction: I provide calls to populate raw memory buffers with vertex, normal, and triangle data (tessellation results).
- Memory Management: I provide the explicit deletion calls (#cxxMakeBoxDelete: and #cxxShapeDelete:) necessary to free memory allocated in the C++ heap.
- Debugging & Profiling: I include methods for memory checkpointing and tracking memory differences to assist in identifying leaks within the external library.

Technical Notes:
- My #ffiLibrary method returns 'MyOCPStLib', which defines the actual path to the dynamic library (.so, .dll, or .dylib) on the host system.
- Buffer methods like #cxxGetAllVertices:buffer: expect a pre-allocated ByteArray or ExternalAddress of the appropriate size (e.g., 8 bytes per double).

API Highlights:
- #cxxBoxNewDx:dy:dz: - Allocates a new box builder in C++.
- #cxxTessellate:deflection: - Triggers the mesh generation algorithm on a shape.
- #cxxVertexCount: / #cxxTriangleCount: - Returns the size of the mesh arrays.

Class {
	#name : 'CxxBoxLibrary',
	#superclass : 'Object',
	#category : 'MyOpenCascade-UFFI',
	#package : 'MyOpenCascade-UFFI'
}
"
Class {
	#name : 'CxxOcctLibrary',
	#superclass : 'Object',
	#category : 'MyOpenCascade-Base',
	#package : 'MyOpenCascade',
	#tag : 'Base'
}

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxBoxNewDx: dx dy: dy dz: dz [

	^ self ffiCall: #( MyShape* cxxBoxNew ( double dx, double dy, double dz ) )
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxCreateBoxDx: dx dy: dy dz: dz [
    ^ self ffiCall: #( MyShape* cxxCreateBox ( double dx, double dy, double dz ) )
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxCut: shape1 with: shape2 [
    ^ self ffiCall: #( MyShape* cxxCut ( MyShape* shape1, MyShape* shape2 ) )
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxCylinderNewRadius: radius height: height [

	^ self ffiCall: #(void* cxxCylinderNew(double radius, double height))
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxDumpMemoryDifference [
    ^ self ffiCall: #(void cxxDumpMemoryDifference())
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxGetAllNormals: shapeHandle buffer: bufferPtr [
	"bufferPtr points to `vertexCount*3` doubles (8 bytes each)."

	^ self ffiCall: #( void cxxGetAllNormals ( void* shapeHandle, void* bufferPtr ) )
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxGetAllTriangles: shapeHandle buffer: bufferPtr [
	"bufferPtr points to `triangleCount*3` int32 (4 bytes each)."

	^ self ffiCall: #( void cxxGetAllTriangles ( void* shapeHandle, void* bufferPtr ) )
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxGetAllVertices: shapeHandle buffer: bufferPtr [
	"bufferPtr points to `vertexCount*3` doubles (8 bytes each)."

	^ self ffiCall: #( void cxxGetAllVertices ( void* shapeHandle, void* bufferPtr ) )
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxGetNormalBufferLength: shape [
    ^ self ffiCall: #( int cxxGetNormalBufferLength ( MyShape* shape ) )
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxGetNormals: shape [
    ^ self ffiCall: #( void* cxxGetNormals ( MyShape* shape ) )
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxGetTriangleIndexCount: shape [
    ^ self ffiCall: #( int cxxGetTriangleIndexCount ( MyShape* shape ) )
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxGetTriangles: shape [
    ^ self ffiCall: #( void* cxxGetTriangles ( MyShape* shape ) )
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxGetVertexBufferLength: shape [
    ^ self ffiCall: #( int cxxGetVertexBufferLength ( MyShape* shape ) )
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxGetVertices: shape [
    ^ self ffiCall: #( void* cxxGetVertices ( MyShape* shape ) )
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxHasNoMemoryDifference [
    ^ self ffiCall: #(int cxxHasMemoryDifference())
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxIsDone: makeBoxHandle [
	"Returns 1/0."

	^ self ffiCall: #( int cxxIsDone ( void* makeBoxHandle ) )
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxMakeBoxDelete: makeBoxHandle [

	^ self ffiCall: #( void cxxMakeBoxDelete ( void* makeBoxHandle ) )
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxMakeCylinderDelete: handle [

	^ self ffiCall: #( void cxxMakeCylinderDelete(void* handle) )
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxMemoryCheckpoint [
    ^ self ffiCall: #(void cxxMemoryCheckpoint())
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxShapeDelete: shapeHandle [


	^ self ffiCall: #( void cxxShapeDelete ( MyShape* shapeHandle ) )
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxTessellate: shapeHandle deflection: deflection [


	^ self ffiCall: #( void cxxTessellate ( MyShape* shapeHandle, double deflection ) )
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxToShape: makeBoxHandle [

	^ self ffiCall: #( void* cxxToShape ( void* makeBoxHandle ) )
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxTriangleCount: shapeHandle [


	^ self ffiCall: #( int cxxTriangleCount ( MyShape* shapeHandle ) )
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxVertexCount: shapeHandle [


	^ self ffiCall: #( int cxxVertexCount ( MyShape* shapeHandle ) )
]

{ #category : 'accessing' }
CxxOcctLibrary class >> ffiLibrary [

	^ MyOCPStLib
]

{ #category : 'accessing' }
CxxOcctLibrary >> ffiLibrary [
	^ self class ffiLibrary
]
