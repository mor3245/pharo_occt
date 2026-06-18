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
MyBoxMakerMemoryTest >> testShapeRehydratesNativeHandleFromDisk [
	"MyBoxMakerMemoryTest new testShapeRehydratesNativeHandleFromDisk"

	| shape file originalVertexCount |
	shape := MyBoxMaker
		         tessellatedBoxDx: 1
		         dy: 1
		         dz: 1
		         deflection: 0.01.
	file := shape storageFileReference.

	[
		self assert: file exists.
		originalVertexCount := shape vertexCount.

		shape releaseNativeHandle.
		self deny: shape hasNativeHandle.

		shape tessellateDeflection: 0.01.
		self assert: shape hasNativeHandle.
		self assert: shape vertexCount equals: originalVertexCount ]
		ensure: [ shape free ].

	self deny: file exists
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
