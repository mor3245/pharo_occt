Class {
	#name : 'MyCADRotationModeTest',
	#superclass : 'TestCase',
	#category : 'MyOpenCascade-CAD-GUI-Test',
	#package : 'MyOpenCascade-CAD-GUI-Test'
}

{ #category : 'asserting' }
MyCADRotationModeTest >> assertVector: actual closeTo: expected [

	self assert: (actual x - expected x) abs < 0.000001.
	self assert: (actual y - expected y) abs < 0.000001.
	self assert: (actual z - expected z) abs < 0.000001
]

{ #category : 'tests' }
MyCADRotationModeTest >> testNewRotationModeStartsInactive [

	| mode |
	mode := MyCADRotationMode new.

	self deny: mode isActive.
	self deny: mode hasCurrentRotation
]

{ #category : 'tests' }
MyCADRotationModeTest >> testRotateVectorAroundEachAxis [

	| mode |
	mode := MyCADRotationMode new.

	self
		assertVector: (mode rotateVector: (Vector3 x: 0 y: 1 z: 0) degrees: 90 axis: #x)
		closeTo: (Vector3 x: 0 y: 0 z: 1).
	self
		assertVector: (mode rotateVector: (Vector3 x: 0 y: 0 z: 1) degrees: 90 axis: #y)
		closeTo: (Vector3 x: 1 y: 0 z: 0).
	self
		assertVector: (mode rotateVector: (Vector3 x: 1 y: 0 z: 0) degrees: 90 axis: #z)
		closeTo: (Vector3 x: 0 y: 1 z: 0)
]

{ #category : 'tests' }
MyCADRotationModeTest >> testRotateVectorWithUnknownAxisLeavesVectorUnchanged [

	| mode vector |
	mode := MyCADRotationMode new.
	vector := Vector3 x: 1 y: 2 z: 3.

	self assert: (mode rotateVector: vector degrees: 90 axis: #unknown) == vector
]
