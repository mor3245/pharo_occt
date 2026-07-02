Class {
	#name : 'MyShapePersistenceTest',
	#superclass : 'TestCase',
	#category : 'MyOpenCascade-API-Test',
	#package : 'MyOpenCascade-API-Test'
}

{ #category : 'tests' }
MyShapePersistenceTest >> testDeleteStorageFileRemovesFileAndClearsPath [

	| shape file |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1 named: 'Disposable Shape'.
	file := FileLocator temp / ('disposable-shape-' , UUID new asString , '.brep').
	shape saveToFile: file.

	[
		self assert: file exists.
		shape deleteStorageFile.
		self deny: file exists.
		self assert: shape storagePath isNil ] ensure: [
			shape free.
			file exists ifTrue: [ file delete ] ]
]

{ #category : 'tests' }
MyShapePersistenceTest >> testFreeLeavesExplicitStorageFileOnDisk [

	| shape file |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1 named: 'Stored Shape'.
	file := FileLocator temp / ('stored-shape-' , UUID new asString , '.brep').
	shape saveToFile: file.

	[
		self assert: file exists.
		shape free.
		self deny: shape hasNativeHandle.
		self assert: file exists ] ensure: [
			shape free.
			file exists ifTrue: [ file delete ] ]
]

{ #category : 'tests' }
MyShapePersistenceTest >> testLoadFromCorruptFileRaisesError [

	| file |
	file := FileLocator temp / ('corrupt-shape-' , UUID new asString , '.brep').
	file writeStreamDo: [ :stream | stream nextPutAll: 'not a brep file' ].

	[
		self
			should: [ MyShape loadFromFile: file ]
			raise: Error ] ensure: [
				file exists ifTrue: [ file delete ] ]
]

{ #category : 'tests' }
MyShapePersistenceTest >> testLoadFromFileRestoresNameAndIdentity [

	| original loaded file storageId |
	original := MyBoxMaker
		            makeBoxDx: 1
		            dy: 1
		            dz: 1
		            named: 'Drive Housing'.

	storageId := original storageId.
	file := FileLocator temp / original storageFileName.
	original saveToFile: file.
	original releaseNativeHandle.

	[
		loaded := MyShape loadFromFile: file.
		self assert: loaded name equals: 'Drive Housing'.
		self assert: loaded storageId equals: storageId ] ensure: [
			loaded ifNotNil: [ loaded free ].
			original free.
			file exists ifTrue: [ file delete ] ]
]

{ #category : 'tests' }
MyShapePersistenceTest >> testLoadFromMissingFileRaisesError [

	| file |
	file := FileLocator temp / ('missing-shape-' , UUID new asString , '.brep').
	file exists ifTrue: [ file delete ].

	self
		should: [ MyShape loadFromFile: file ]
		raise: Error
]

{ #category : 'tests' }
MyShapePersistenceTest >> testNamedShapeIsNotAutomaticallyPersisted [

	| shape |
	shape := MyBoxMaker
		         makeBoxDx: 1
		         dy: 1
		         dz: 1
		         named: 'Mounting Bracket'.

	[
		self assert: shape name equals: 'Mounting Bracket'.
		self assert: shape storageFileReference isNil ] ensure: [ shape free ]
]

{ #category : 'tests' }
MyShapePersistenceTest >> testPersistWithoutNativeHandleRaisesError [

	| shape file |
	shape := MyShape new.
	file := FileLocator temp / ('no-handle-' , UUID new asString , '.brep').
	shape storagePath: file fullName.

	[
		self
			should: [ shape persistToDisk ]
			raise: Error.
		self deny: file exists ] ensure: [
			shape free.
			file exists ifTrue: [ file delete ] ]
]

{ #category : 'tests' }
MyShapePersistenceTest >> testPersistWithoutSaveDestinationRaisesError [

	| shape |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.

	[
		self
			should: [ shape persistToDisk ]
			raise: Error ] ensure: [ shape free ]
]

{ #category : 'tests' }
MyShapePersistenceTest >> testRenameDoesNotWriteOrMoveBRepFile [

	| shape oldFile oldStorageId newFile |
	shape := MyBoxMaker
		         makeBoxDx: 1
		         dy: 1
		         dz: 1
		         named: 'Box 1'.
	oldStorageId := shape storageId.
	oldFile := FileLocator temp / ('Box 1-' , UUID new asString , '.brep').
	shape saveToFile: oldFile.

	[
		shape renameTo: 'Front Mount'.
		newFile := shape storageFileReference.

		self assert: shape name equals: 'Front Mount'.
		self assert: shape storageId equals: oldStorageId.
		self assert: newFile fullName equals: oldFile fullName.
		self assert: oldFile exists ] ensure: [
			shape free.
			oldFile exists ifTrue: [ oldFile delete ] ]
]

{ #category : 'tests' }
MyShapePersistenceTest >> testSaveToFileUsesRequestedBasenameAsShapeName [

	| shape file |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1 named: 'Original Name'.
	file := FileLocator temp / ('requested-name-' , UUID new asString , '.brep').

	[
		shape saveToFile: file.
		self assert: shape name equals: file basenameWithoutExtension.
		self assert: shape storageFileReference fullName equals: file fullName.
		self assert: file exists ] ensure: [
			shape free.
			file exists ifTrue: [ file delete ] ]
]

{ #category : 'tests' }
MyShapePersistenceTest >> testShapeRehydratesNativeHandleFromDisk [
	"MyShapePersistenceTest new testShapeRehydratesNativeHandleFromDisk"

	| shape file originalVertexCount |
	shape := MyBoxMaker
		         tessellatedBoxDx: 1
		         dy: 1
		         dz: 1
		         deflection: 0.01.
	file := FileLocator temp / ('rehydration-' , UUID new asString , '.brep').
	shape saveToFile: file.

	[
		self assert: file exists.
		originalVertexCount := shape vertexCount.

		shape releaseNativeHandle.
		self deny: shape hasNativeHandle.

		shape tessellateDeflection: 0.01.
		self assert: shape hasNativeHandle.
		self assert: shape vertexCount equals: originalVertexCount ] ensure: [ shape free ].

	self assert: file exists.
	file delete
]
