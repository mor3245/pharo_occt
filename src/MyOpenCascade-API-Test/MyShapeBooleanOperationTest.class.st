Class {
	#name : 'MyShapeBooleanOperationTest',
	#superclass : 'TestCase',
	#category : 'MyOpenCascade-API-Test',
	#package : 'MyOpenCascade-API-Test'
}

{ #category : 'tests' }
MyShapeBooleanOperationTest >> testCutResultPreservesTargetName [

	| target tool result |
	target := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1 named: 'Base Plate'.
	tool := MyCylinderMaker makeCylinderRadius: 0.25 height: 1 named: 'Drill Tool'.

	[
		result := target cutWith: tool.
		self deny: result isNil.
		self assert: result name equals: 'Base Plate'.
		self deny: (result name includesSubstring: tool name) ]
		ensure: [
			result ifNotNil: [ result free ].
			tool free.
			target free ]
]

{ #category : 'tests' }
MyShapeBooleanOperationTest >> testCutWithSeparatedSolidsReturnsNamedResultShapes [

	| target tool results |
	target := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1 named: 'Base Plate'.
	tool := MyCylinderMaker makeCylinderRadius: 0.25 height: 1 named: 'Drill Tool'.

	[
		results := target cutWithSeparatedSolids: tool.
		self deny: results isEmpty.
		self assert: (results allSatisfy: [ :each | each name beginsWith: 'Base Plate' ]).
		self deny: (results anySatisfy: [ :each | each name includesSubstring: tool name ]) ] ensure: [
			results ifNotNil: [ results do: [ :each | each free ] ].
			tool free.
			target free ]
]

{ #category : 'tests' }
MyShapeBooleanOperationTest >> testDerivedBodyNamesDoNotNest [

	| shape |
	shape := MyShape new.
	shape setName: 'Box 1 - Body 1 - Body 2'.

	self assert: shape rootBodyName equals: 'Box 1'.
	self assert: (shape derivedBodyNameAt: 1) equals: 'Box 1 - Body 1'.
	self assert: (shape derivedBodyNameAt: 2) equals: 'Box 1 - Body 2'
]

{ #category : 'tests' }
MyShapeBooleanOperationTest >> testDerivedBodyNamesIncrementExistingBodyNumber [

	| shape |
	shape := MyShape new.
	shape setName: 'Box 1 - Body 2'.

	self assert: (shape derivedBodyNameAt: 1) equals: 'Box 1 - Body 2'.
	self assert: (shape derivedBodyNameAt: 2) equals: 'Box 1 - Body 3'
]

{ #category : 'tests' }
MyShapeBooleanOperationTest >> testDerivedBodyNamesRecoverFromNonNumericSuffix [

	| shape |
	shape := MyShape new.
	shape setName: 'Box 1 - Body left'.

	self assert: shape rootBodyName equals: 'Box 1'.
	self assert: (shape derivedBodyNameAt: 1) equals: 'Box 1 - Body 1'.
	self assert: (shape derivedBodyNameAt: 2) equals: 'Box 1 - Body 2'
]
