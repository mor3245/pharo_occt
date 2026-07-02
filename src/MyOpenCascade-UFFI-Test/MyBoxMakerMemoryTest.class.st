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
MyBoxMakerMemoryTest >> testTessellatedBoxWillLeakNativeMemory [

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
