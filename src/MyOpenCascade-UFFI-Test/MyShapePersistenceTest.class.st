Class {
	#name : 'MyShapePersistenceTest',
	#superclass : 'TestCase',
	#category : 'MyOpenCascade-UFFI-Test',
	#package : 'MyOpenCascade-UFFI-Test'
}

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

{ #category : 'tests' }
MyShapePersistenceTest >> testTopologyInspectionSubshapesAreNotPersisted [
	"Inspection-only faces must not create independent BREP files."

	| shape faces |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.

	[
		faces := shape faces.
		self deny: faces isEmpty.
		self assert: (faces allSatisfy: [ :face | face storagePath isNil ]) ] ensure: [
			faces ifNotNil: [ faces do: [ :face | face free ] ].
			shape free ]
]
