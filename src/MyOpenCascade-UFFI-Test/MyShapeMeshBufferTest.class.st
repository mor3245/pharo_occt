Class {
	#name : 'MyShapeMeshBufferTest',
	#superclass : 'TestCase',
	#category : 'MyOpenCascade-UFFI-Test',
	#package : 'MyOpenCascade-UFFI-Test'
}

{ #category : 'tests' }
MyShapeMeshBufferTest >> testEdgeSamplingBufferMatchesSegmentCount [

	| shape edgeVertices |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.

	[
		shape sampleEdgesDeflection: 0.01.
		edgeVertices := shape edgeVertices.

		self assert: shape edgeSegmentCount > 0.
		self assert: shape edgeVertexBufferLength equals: shape edgeSegmentCount * 2 * 3.
		self assert: edgeVertices size equals: shape edgeVertexBufferLength ] ensure: [ shape free ]
]

{ #category : 'tests' }
MyShapeMeshBufferTest >> testMeshBuffersMatchReportedCounts [

	| shape vertices normals triangles |
	shape := MyBoxMaker
		         tessellatedBoxDx: 1
		         dy: 1
		         dz: 1
		         deflection: 0.01.

	[
		vertices := shape vertices.
		normals := shape normals.
		triangles := shape triangles.

		self assert: shape vertexCount > 0.
		self assert: shape triangleCount > 0.
		self assert: shape vertexBufferLength equals: shape vertexCount * 3.
		self assert: shape normalBufferLength equals: shape vertexCount * 3.
		self assert: shape triangleIndexCount equals: shape triangleCount * 3.
		self assert: vertices size equals: shape vertexBufferLength.
		self assert: normals size equals: shape normalBufferLength.
		self assert: triangles size equals: shape triangleIndexCount ] ensure: [ shape free ]
]

{ #category : 'tests' }
MyShapeMeshBufferTest >> testUntessellatedShapeAnswersEmptyMeshBuffers [

	| shape |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.

	[
		self assert: shape vertexCount equals: 0.
		self assert: shape triangleCount equals: 0.
		self assert: shape vertices isEmpty.
		self assert: shape normals isEmpty.
		self assert: shape triangles isEmpty ] ensure: [ shape free ]
]
