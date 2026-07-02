Class {
	#name : 'MyShapeFactoryTest',
	#superclass : 'TestCase',
	#category : 'MyOpenCascade-API-Test',
	#package : 'MyOpenCascade-API-Test'
}

{ #category : 'tests' }
MyShapeFactoryTest >> testBoxFactoryRejectsNegativeDimension [

	self
		should: [ MyBoxMaker makeBoxDx: -1 dy: 1 dz: 1 ]
		raise: Error
]

{ #category : 'tests' }
MyShapeFactoryTest >> testBoxFactoryRejectsNonnumericDimension [

	self
		should: [ MyBoxMaker makeBoxDx: 'wide' dy: 1 dz: 1 ]
		raise: Error
]

{ #category : 'tests' }
MyShapeFactoryTest >> testBoxFactoryRejectsZeroDimension [

	self
		should: [ MyBoxMaker makeBoxDx: 0 dy: 1 dz: 1 ]
		raise: Error
]

{ #category : 'tests' }
MyShapeFactoryTest >> testCylinderFactoryRejectsNegativeHeight [

	self
		should: [ MyCylinderMaker makeCylinderRadius: 0.5 height: -1 ]
		raise: Error
]

{ #category : 'tests' }
MyShapeFactoryTest >> testCylinderFactoryRejectsNonnumericRadius [

	self
		should: [ MyCylinderMaker makeCylinderRadius: 'wide' height: 1 ]
		raise: Error
]

{ #category : 'tests' }
MyShapeFactoryTest >> testCylinderFactoryRejectsZeroRadius [

	self
		should: [ MyCylinderMaker makeCylinderRadius: 0 height: 1 ]
		raise: Error
]

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
MyShapeFactoryTest >> testSmallPositiveBoxCreatesNativeShape [

	| shape |
	shape := MyBoxMaker makeBoxDx: 0.001 dy: 0.001 dz: 0.001.

	[
		self assert: shape hasNativeHandle.
		self assert: shape name equals: 'Box' ] ensure: [ shape free ]
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
