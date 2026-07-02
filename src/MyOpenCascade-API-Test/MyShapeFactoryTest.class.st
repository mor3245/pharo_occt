Class {
	#name : 'MyShapeFactoryTest',
	#superclass : 'TestCase',
	#category : 'MyOpenCascade-API-Test',
	#package : 'MyOpenCascade-API-Test'
}

{ #category : 'tests' }
MyShapeFactoryTest >> testDefaultBoxFactoryCreatesNamedNativeShape [

	| shape |
	shape := MyBoxMaker makeBoxDx: 1 dy: 2 dz: 3.

	[
		self assert: shape name equals: 'Box'.
		self assert: shape hasNativeHandle.
		self deny: shape isNull ] ensure: [ shape free ]
]

{ #category : 'tests' }
MyShapeFactoryTest >> testDefaultCylinderFactoryCreatesNamedNativeShape [

	| shape |
	shape := MyCylinderMaker makeCylinderRadius: 0.5 height: 2.

	[
		self assert: shape name equals: 'Cylinder'.
		self assert: shape hasNativeHandle.
		self deny: shape isNull ] ensure: [ shape free ]
]

{ #category : 'tests' }
MyShapeFactoryTest >> testNamedBoxFactoryTrimsAssignedName [

	| shape |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1 named: '  Cover Plate  '.

	[
		self assert: shape name equals: 'Cover Plate' ] ensure: [ shape free ]
]

{ #category : 'tests' }
MyShapeFactoryTest >> testTessellatedCylinderFactoryCreatesMesh [

	| shape |
	shape := MyCylinderMaker tessellatedCylinderRadius: 0.5 height: 2 deflection: 0.01.

	[
		self assert: shape name equals: 'Cylinder'.
		self assert: shape vertexCount > 0.
		self assert: shape triangleCount > 0.
		self assert: shape vertices size equals: shape vertexBufferLength.
		self assert: shape triangles size equals: shape triangleIndexCount ] ensure: [ shape free ]
]
