Class {
	#name : 'CxxBoxLibrary',
	#superclass : 'Object',
	#category : 'MyOpenCascade-UFFI',
	#package : 'MyOpenCascade-UFFI'
}

{ #category : 'as yet unclassified' }
CxxBoxLibrary class >> cxxBoxNewDx: dx dy: dy dz: dz [

	^ self ffiCall: #( void* cxxBoxNew ( double dx, double dy, double dz ) )
]

{ #category : 'as yet unclassified' }
CxxBoxLibrary class >> cxxBoxShape: makeBoxHandle [

	^ self ffiCall: #( void* cxxBoxShape ( void* makeBoxHandle ) )
]

{ #category : 'as yet unclassified' }
CxxBoxLibrary class >> cxxGetAllNormals: shapeHandle buffer: bufferPtr [
	"bufferPtr points to `vertexCount*3` doubles (8 bytes each)."
	
	^ self ffiCall: #( void cxxGetAllNormals ( void* shapeHandle, void* bufferPtr ) )
]

{ #category : 'as yet unclassified' }
CxxBoxLibrary class >> cxxGetAllTriangles: shapeHandle buffer: bufferPtr [
	"bufferPtr points to `triangleCount*3` int32 (4 bytes each)."
	
	^ self ffiCall: #( void cxxGetAllTriangles ( void* shapeHandle, void* bufferPtr ) )
]

{ #category : 'as yet unclassified' }
CxxBoxLibrary class >> cxxGetAllVertices: shapeHandle buffer: bufferPtr [
	"bufferPtr points to `vertexCount*3` doubles (8 bytes each)."
	
	^ self ffiCall: #( void cxxGetAllVertices ( void* shapeHandle, void* bufferPtr ) )
]

{ #category : 'as yet unclassified' }
CxxBoxLibrary class >> cxxMakeBoxDelete: makeBoxHandle [

	^ self ffiCall: #( void cxxMakeBoxDelete ( void* makeBoxHandle ) )
]

{ #category : 'as yet unclassified' }
CxxBoxLibrary class >> cxxShapeDelete: shapeHandle [


	^ self ffiCall: #( void cxxShapeDelete ( void* shapeHandle ) )
]

{ #category : 'as yet unclassified' }
CxxBoxLibrary class >> cxxTessellate: shapeHandle deflection: deflection [


	^ self ffiCall: #( void cxxTessellate ( void* shapeHandle, double deflection ) )
]

{ #category : 'as yet unclassified' }
CxxBoxLibrary class >> cxxTriangleCount: shapeHandle [


	^ self ffiCall: #( int cxxTriangleCount ( void* shapeHandle ) )
]

{ #category : 'as yet unclassified' }
CxxBoxLibrary class >> cxxVertexCount: shapeHandle [


	^ self ffiCall: #( int cxxVertexCount ( void* shapeHandle ) )
]

{ #category : 'as yet unclassified' }
CxxBoxLibrary class >> dumpMemoryDifference [
    ^ self ffiCall: #(void cxxDumpMemoryDifference())
]

{ #category : 'accessing' }
CxxBoxLibrary class >> ffiLibrary [

	^ MyOCPStLib
]

{ #category : 'testing' }
CxxBoxLibrary class >> hasNoMemoryDifference [
    ^ self ffiCall: #(int cxxHasMemoryDifference())
]

{ #category : 'testing' }
CxxBoxLibrary class >> isDone: makeBoxHandle [
	"Returns 1/0."
	
	^ self ffiCall: #( int IsDone ( void* makeBoxHandle ) )
]

{ #category : 'as yet unclassified' }
CxxBoxLibrary class >> memoryCheckpoint [
    ^ self ffiCall: #(void cxxMemoryCheckpoint())
]

{ #category : 'accessing' }
CxxBoxLibrary >> ffiLibrary [
	^ self class ffiLibrary
]
