Class {
	#name : 'MyBoxMakerMemoryTest',
	#superclass : 'TestCase',
	#category : 'MyOpenCascade-API-Test',
	#package : 'MyOpenCascade-API-Test'
}

{ #category : 'testing' }
MyBoxMakerMemoryTest >> cxxHasNoMemoryDifference [ 

	^ CxxOcctLibrary cxxHasNoMemoryDifference = 0
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
