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
	#name : 'CxxBoxLibrary',
	#superclass : 'Object',
	#category : 'MyOpenCascade-UFFI-Base',
	#package : 'MyOpenCascade-UFFI',
	#tag : 'Base'
}

{ #category : 'ffi-calls' }
CxxBoxLibrary class >> cxxBoxNewDx: dx dy: dy dz: dz [

	^ self ffiCall: #( void* cxxBoxNew ( double dx, double dy, double dz ) )
]

{ #category : 'ffi-calls' }
CxxBoxLibrary class >> cxxBoxShape: makeBoxHandle [

	^ self ffiCall: #( void* cxxBoxShape ( void* makeBoxHandle ) )
]

{ #category : 'ffi-calls' }
CxxBoxLibrary class >> cxxGetAllNormals: shapeHandle buffer: bufferPtr [
	"bufferPtr points to `vertexCount*3` doubles (8 bytes each)."

	^ self ffiCall: #( void cxxGetAllNormals ( void* shapeHandle, void* bufferPtr ) )
]

{ #category : 'ffi-calls' }
CxxBoxLibrary class >> cxxGetAllTriangles: shapeHandle buffer: bufferPtr [
	"bufferPtr points to `triangleCount*3` int32 (4 bytes each)."

	^ self ffiCall: #( void cxxGetAllTriangles ( void* shapeHandle, void* bufferPtr ) )
]

{ #category : 'ffi-calls' }
CxxBoxLibrary class >> cxxGetAllVertices: shapeHandle buffer: bufferPtr [
	"bufferPtr points to `vertexCount*3` doubles (8 bytes each)."

	^ self ffiCall: #( void cxxGetAllVertices ( void* shapeHandle, void* bufferPtr ) )
]

{ #category : 'ffi-calls' }
CxxBoxLibrary class >> cxxMakeBoxDelete: makeBoxHandle [

	^ self ffiCall: #( void cxxMakeBoxDelete ( void* makeBoxHandle ) )
]

{ #category : 'ffi-calls' }
CxxBoxLibrary class >> cxxShapeDelete: shapeHandle [


	^ self ffiCall: #( void cxxShapeDelete ( void* shapeHandle ) )
]

{ #category : 'ffi-calls' }
CxxBoxLibrary class >> cxxTessellate: shapeHandle deflection: deflection [


	^ self ffiCall: #( void cxxTessellate ( void* shapeHandle, double deflection ) )
]

{ #category : 'ffi-calls' }
CxxBoxLibrary class >> cxxTriangleCount: shapeHandle [


	^ self ffiCall: #( int cxxTriangleCount ( void* shapeHandle ) )
]

{ #category : 'ffi-calls' }
CxxBoxLibrary class >> cxxVertexCount: shapeHandle [


	^ self ffiCall: #( int cxxVertexCount ( void* shapeHandle ) )
]

{ #category : 'ffi-calls' }
CxxBoxLibrary class >> dumpMemoryDifference [
    ^ self ffiCall: #(void cxxDumpMemoryDifference())
]

{ #category : 'accessing' }
CxxBoxLibrary class >> ffiLibrary [

	^ MyOCPStLib
]

{ #category : 'ffi-calls' }
CxxBoxLibrary class >> hasNoMemoryDifference [
    ^ self ffiCall: #(int cxxHasMemoryDifference())
]

{ #category : 'ffi-calls' }
CxxBoxLibrary class >> isDone: makeBoxHandle [
	"Returns 1/0."

	^ self ffiCall: #( int IsDone ( void* makeBoxHandle ) )
]

{ #category : 'ffi-calls' }
CxxBoxLibrary class >> memoryCheckpoint [
    ^ self ffiCall: #(void cxxMemoryCheckpoint())
]

{ #category : 'accessing' }
CxxBoxLibrary >> ffiLibrary [
	^ self class ffiLibrary
]
