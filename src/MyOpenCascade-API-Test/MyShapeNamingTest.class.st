Class {
	#name : 'MyShapeNamingTest',
	#superclass : 'TestCase',
	#category : 'MyOpenCascade-API-Test',
	#package : 'MyOpenCascade-API-Test'
}

{ #category : 'tests' }
MyShapeNamingTest >> testBlankShapeNameIsRejected [

	| shape |
	shape := MyShape new.

	self
		should: [ shape setName: '   ' ]
		raise: Error
]

{ #category : 'tests' }
MyShapeNamingTest >> testRenameTrimsName [

	| shape |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1 named: 'Box'.

	[
		shape renameTo: '  Front Mount  '.
		self assert: shape name equals: 'Front Mount' ] ensure: [ shape free ]
]

{ #category : 'tests' }
MyShapeNamingTest >> testSafeFileComponentReplacesUnsafeCharacters [

	self
		assert: (MyShape safeFileComponentFor: 'Gear:Left/Right*')
		equals: 'Gear-Left-Right-'.
	self
		assert: (MyShape safeFileComponentFor: 'Bracket -- A')
		equals: 'Bracket - A'.
	self assert: (MyShape safeFileComponentFor: '') equals: 'Shape'
]
