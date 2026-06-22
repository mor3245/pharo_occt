Class {
	#name : 'MyBoxMakerMemoryTest',
	#superclass : 'TestCase',
	#category : 'MyOpenCascade-UFFI-Test',
	#package : 'MyOpenCascade-UFFI-Test'
}

{ #category : 'testing' }
MyBoxMakerMemoryTest >> cxxHasNoMemoryDifference [ 
	^ CxxOcctLibrary cxxHasNoMemoryDifference = 0
]

{ #category : 'tests' }
MyBoxMakerMemoryTest >> testCutResultPreservesTargetName [

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
MyBoxMakerMemoryTest >> testDerivedBodyNamesDoNotNest [

	| shape |
	shape := MyShape new.
	shape setName: 'Box 1 - Body 1 - Body 2'.

	self assert: shape rootBodyName equals: 'Box 1'.
	self assert: (shape derivedBodyNameAt: 1) equals: 'Box 1 - Body 1'.
	self assert: (shape derivedBodyNameAt: 2) equals: 'Box 1 - Body 2'
]

{ #category : 'tests' }
MyBoxMakerMemoryTest >> testDerivedBodyNamesIncrementExistingBodyNumber [

	| shape |
	shape := MyShape new.
	shape setName: 'Box 1 - Body 2'.

	self assert: (shape derivedBodyNameAt: 1) equals: 'Box 1 - Body 2'.
	self assert: (shape derivedBodyNameAt: 2) equals: 'Box 1 - Body 3'
]

{ #category : 'tests' }
MyBoxMakerMemoryTest >> testLoadFromFileRestoresNameAndIdentity [

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
MyBoxMakerMemoryTest >> testNamedShapeIsNotAutomaticallyPersisted [

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
MyBoxMakerMemoryTest >> testRenameDoesNotWriteOrMoveBRepFile [

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
MyBoxMakerMemoryTest >> testShapeRehydratesNativeHandleFromDisk [
	"MyBoxMakerMemoryTest new testShapeRehydratesNativeHandleFromDisk"

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
MyBoxMakerMemoryTest >> testTessellatedBoxDoesNotLeakNativeMemory [
	"MyBoxMakerMemoryTest new testTessellatedBoxDoesNotLeakNativeMemory"

	CxxOcctLibrary cxxMemoryCheckpoint.

	100 timesRepeat: [
			| shape |
			shape := MyBoxMaker
				         tessellatedBoxDx: 1
				         dy: 1
				         dz: 1
				         deflection: 0.01.

			[ shape vertices ] ensure: [ shape free ] ].

	Smalltalk garbageCollect.

	self assert: self cxxHasNoMemoryDifference
]

{ #category : 'tests' }
MyBoxMakerMemoryTest >> testTessllatedBoxWillLeakNativeMemory [

	CxxOcctLibrary cxxMemoryCheckpoint.

	100 timesRepeat: [
			| shape |
			shape := MyBoxMaker
				         tessellatedBoxDx: 1
				         dy: 1
				         dz: 1
				         deflection: 0.01.

			[ shape vertices ] ].

	Smalltalk garbageCollect.

	self deny: self cxxHasNoMemoryDifference
]

{ #category : 'tests' }
MyBoxMakerMemoryTest >> testTopologyInspectionSubshapesAreNotPersisted [
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
