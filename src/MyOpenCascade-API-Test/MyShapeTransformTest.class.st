Class {
	#name : 'MyShapeTransformTest',
	#superclass : 'TestCase',
	#category : 'MyOpenCascade-API-Test',
	#package : 'MyOpenCascade-API-Test'
}

{ #category : 'tests' }
MyShapeTransformTest >> testRotateAroundEachAxisKeepsNativeHandle [

	| shape center |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.
	center := Vector3 x: 0 y: 0 z: 0.

	[
		shape rotateDegrees: 15 aroundAxis: #x center: center.
		shape rotateDegrees: 15 aroundAxis: #y center: center.
		shape rotateDegrees: 15 aroundAxis: #z center: center.

		self assert: shape hasNativeHandle ] ensure: [ shape free ]
]

{ #category : 'tests' }
MyShapeTransformTest >> testRotationClearsTopologyInspectionData [

	| shape |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.

	[
		shape refreshTopologyForInspectionDepth: 0.
		self assert: shape hasTopologyInspectionData.
		shape rotateDegrees: 30 aroundAxis: #z center: (Vector3 x: 0 y: 0 z: 0).
		self deny: shape hasTopologyInspectionData ] ensure: [ shape free ]
]

{ #category : 'tests' }
MyShapeTransformTest >> testScaleClearsTopologyInspectionData [

	| shape |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.

	[
		shape refreshTopologyForInspectionDepth: 0.
		self assert: shape hasTopologyInspectionData.
		shape scaleBy: (Vector3 x: 2 y: 1 z: 1).
		self deny: shape hasTopologyInspectionData ] ensure: [ shape free ]
]

{ #category : 'tests' }
MyShapeTransformTest >> testTranslateKeepsNativeHandle [

	| shape |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.

	[
		shape translateBy: (Vector3 x: 1 y: 2 z: 3).
		self assert: shape hasNativeHandle ] ensure: [ shape free ]
]
