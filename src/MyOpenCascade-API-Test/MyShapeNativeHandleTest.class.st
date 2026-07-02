Class {
	#name : 'MyShapeNativeHandleTest',
	#superclass : 'TestCase',
	#category : 'MyOpenCascade-API-Test',
	#package : 'MyOpenCascade-API-Test'
}

{ #category : 'tests' }
MyShapeNativeHandleTest >> testFreeIsIdempotent [

	| shape |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.

	shape free.
	self deny: shape hasNativeHandle.
	shape free.
	self deny: shape hasNativeHandle
]

{ #category : 'tests' }
MyShapeNativeHandleTest >> testIsNullAnswersTrueForShapeWithoutHandleOrStorage [

	| shape |
	shape := MyShape new.

	self assert: shape isNull
]

{ #category : 'tests' }
MyShapeNativeHandleTest >> testIsNullRehydratesFromExistingStorage [

	| shape file |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.
	file := FileLocator temp / ('is-null-rehydrate-' , UUID new asString , '.brep').
	shape saveToFile: file.

	[
		shape releaseNativeHandle.
		self deny: shape hasNativeHandle.
		self deny: shape isNull.
		self assert: shape hasNativeHandle ] ensure: [
			shape free.
			file exists ifTrue: [ file delete ] ]
]

{ #category : 'tests' }
MyShapeNativeHandleTest >> testReleaseNativeHandleIsIdempotent [

	| shape |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.

	[
		self assert: shape hasNativeHandle.
		shape releaseNativeHandle.
		self deny: shape hasNativeHandle.
		shape releaseNativeHandle.
		self deny: shape hasNativeHandle ] ensure: [ shape free ]
]
