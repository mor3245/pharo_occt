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
	"Allocates a new BRepPrimAPI_MakeBox builder in C++ and returns its handle."
	
	^ self ffiCall: #( MyShape* cxxBoxNew ( double dx, double dy, double dz ) )
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxCreateBoxDx: dx dy: dy dz: dz [
	"Creates and returns a completed box shape directly, bypassing the MakeBox builder step."
	
    ^ self ffiCall: #( MyShape* cxxCreateBox ( double dx, double dy, double dz ) )
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxCreateCylinderRadius: radius height: height [
	"Creates and returns a completed cylinder shape directly, bypassing the MakeBox builder step."

	^ self ffiCall: #( MyShape* cxxCreateCylinder ( double radius, double height ) )
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxCut: shape1 with: shape2 [
	"Performs a Boolean cut of shape2 from shape1 and returns the resulting shape handle."
	
    ^ self ffiCall: #( MyShape* cxxCut ( MyShape* shape1, MyShape* shape2 ) )
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxCylinderNewRadius: radius height: height [
	"Allocates a new BRepPrimAPI_MakeCylinder builder in C++ and returns its handle."
	
	^ self ffiCall: #(void* cxxCylinderNew(double radius, double height))
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxDumpMemoryDifference [
	"Prints the memory difference since the last checkpoint to the C++ side log."

    ^ self ffiCall: #(void cxxDumpMemoryDifference())
]

{ #category : 'unused' }
CxxOcctLibrary class >> cxxGetAllNormals: shapeHandle buffer: bufferPtr [
	"Fills bufferPtr with vertexCount*3 doubles representing per-vertex normals."

	^ self ffiCall: #( void cxxGetAllNormals ( void* shapeHandle, void* bufferPtr ) )
]

{ #category : 'unused' }
CxxOcctLibrary class >> cxxGetAllTriangles: shapeHandle buffer: bufferPtr [
	"Fills bufferPtr with triangleCount*3 int32 values representing triangle index triples."

	^ self ffiCall: #( void cxxGetAllTriangles ( void* shapeHandle, void* bufferPtr ) )
]

{ #category : 'unused' }
CxxOcctLibrary class >> cxxGetAllVertices: shapeHandle buffer: bufferPtr [
	 "Fills bufferPtr with vertexCount*3 doubles representing vertex positions."

	^ self ffiCall: #( void cxxGetAllVertices ( void* shapeHandle, void* bufferPtr ) )
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxGetNormalBufferLength: shape [
	"Returns the total number of doubles in the normal buffer (vertexCount * 3)."
	
    ^ self ffiCall: #( int cxxGetNormalBufferLength ( MyShape* shape ) )
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxGetNormals: shape [
	"Returns a raw pointer to the tessellated normal data buffer."
	
    ^ self ffiCall: #( void* cxxGetNormals ( MyShape* shape ) )
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxGetTriangleIndexCount: shape [
	"Returns the total number of int32 indices in the triangle buffer (triangleCount * 3)."
	
    ^ self ffiCall: #( int cxxGetTriangleIndexCount ( MyShape* shape ) )
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxGetTriangles: shape [
	"Returns a raw pointer to the tessellated triangle index buffer."
	
    ^ self ffiCall: #( void* cxxGetTriangles ( MyShape* shape ) )
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxGetVertexBufferLength: shape [
	"Returns the total number of doubles in the vertex buffer (vertexCount * 3)."
	
    ^ self ffiCall: #( int cxxGetVertexBufferLength ( MyShape* shape ) )
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxGetVertices: shape [
	"Returns a raw pointer to the tessellated vertex position buffer."
	
    ^ self ffiCall: #( void* cxxGetVertices ( MyShape* shape ) )
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxHasNoMemoryDifference [
	"Returns non-zero if no memory change has occurred since the last checkpoint."
	
    ^ self ffiCall: #(int cxxHasMemoryDifference())
]

{ #category : 'unused' }
CxxOcctLibrary class >> cxxIsDone: makeBoxHandle [
	"Returns 1 if the builder finished successfully, 0 otherwise."

	^ self ffiCall: #( int cxxIsDone ( void* makeBoxHandle ) )
]

{ #category : 'unused' }
CxxOcctLibrary class >> cxxMakeBoxDelete: makeBoxHandle [
	"Frees the BRepPrimAPI_MakeBox builder allocated on the C++ heap."

	^ self ffiCall: #( void cxxMakeBoxDelete ( void* makeBoxHandle ) )
]

{ #category : 'unused' }
CxxOcctLibrary class >> cxxMakeCylinderDelete: handle [
	"Frees the BRepPrimAPI_MakeCylinder builder allocated on the C++ heap."

	^ self ffiCall: #( void cxxMakeCylinderDelete(void* handle) )
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxMemoryCheckpoint [
	 "Records the current C++ heap state so later calls can compute a memory difference."

    ^ self ffiCall: #(void cxxMemoryCheckpoint())
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxRotateShape: shape xDegrees: xDegrees yDegrees: yDegrees zDegrees: zDegrees [
	"Applies Euler rotations in degrees to the underlying OpenCascade shape."

	^ self ffiCall: #( void cxxRotateShapeDegrees ( MyShape* shape, double xDegrees, double yDegrees, double zDegrees ) )
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxScaleShape: shape sx: sx sy: sy sz: sz [
	"Applies non-uniform scale to the underlying OpenCascade shape."

	^ self ffiCall: #( void cxxScaleShape ( MyShape* shape, double sx, double sy, double sz ) )
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxShapeDelete: shapeHandle [
	"Frees the C++ Shape object, releasing its tessellation and geometry data."

	^ self ffiCall: #( void cxxShapeDelete ( MyShape* shapeHandle ) )
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxTessellate: shapeHandle deflection: deflection [
	"Runs the BRep mesh algorithm on shapeHandle at the given chord deflection tolerance."

	^ self ffiCall: #( void cxxTessellate ( MyShape* shapeHandle, double deflection ) )
]

{ #category : 'unused' }
CxxOcctLibrary class >> cxxToShape: makeBoxHandle [
	"Extracts the completed TopoDS_Shape from the builder and returns its handle."

	^ self ffiCall: #( void* cxxToShape ( void* makeBoxHandle ) )
]

{ #category : 'as yet unclassified' }
CxxOcctLibrary class >> cxxTranslateShape: shape x: x y: y z: z [
	"Applies a translation to the underlying OpenCascade shape."

	^ self ffiCall: #( void cxxTranslateShape ( MyShape* shape, double x, double y, double z ) )
 
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxTriangleCount: shapeHandle [
	"Returns the number of triangles in the tessellated mesh."

	^ self ffiCall: #( int cxxTriangleCount ( MyShape* shapeHandle ) )
]

{ #category : 'ffi-calls' }
CxxOcctLibrary class >> cxxVertexCount: shapeHandle [
	"Returns the number of vertices in the tessellated mesh."

	^ self ffiCall: #( int cxxVertexCount ( MyShape* shapeHandle ) )
]

{ #category : 'accessing' }
CxxOcctLibrary class >> ffiLibrary [
	"Returns the library descriptor that locates the native .so/.dll/.dylib."

	^ MyOCPStLib
]

{ #category : 'accessing' }
CxxOcctLibrary >> ffiLibrary [
	^ self class ffiLibrary
]
