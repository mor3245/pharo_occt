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
MyShapeNamingTest >> testDefaultShapeNameAndStorageIdentityAreCreatedLazily [

	| shape storageId |
	shape := MyShape new.
	storageId := shape storageId.

	self assert: shape name equals: 'Shape'.
	self deny: storageId isNil.
	self assert: shape storageId equals: storageId.
	self assert: (shape storageFileName endsWith: storageId , '.brep')
]

{ #category : 'tests' }
MyShapeNamingTest >> testLegacyStoragePathInfersNameAndCreatesStorageId [

	| shape file storageId |
	shape := MyShape new.
	file := FileLocator temp / 'Legacy Housing.brep'.
	shape storagePath: file fullName.
	storageId := shape storageId.

	self assert: shape name equals: 'Legacy Housing'.
	self deny: storageId isNil.
	self assert: shape storageFileName equals: 'Legacy Housing--' , storageId , '.brep'
]

{ #category : 'tests' }
MyShapeNamingTest >> testNameSetterDelegatesToRename [

	| shape |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1 named: 'Box'.

	[
		shape name: '  Rear Cover  '.
		self assert: shape name equals: 'Rear Cover' ] ensure: [ shape free ]
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

{ #category : 'tests' }
MyShapeNamingTest >> testStorageFileNameUsesSafeNameAndStableStorageId [

	| shape storageId |
	shape := MyShape new.
	shape setName: 'Gear:Left/Right'.
	shape storageId: 'fixed-id'.
	storageId := shape storageId.

	self assert: storageId equals: 'fixed-id'.
	self assert: shape storageFileName equals: 'Gear-Left-Right--fixed-id.brep'

]
