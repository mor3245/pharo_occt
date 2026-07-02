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
MyBoxMakerMemoryTest >> testBooleanCutDoesNotLeakNativeMemory [

	CxxOcctLibrary cxxMemoryCheckpoint.

	50 timesRepeat: [
			| target tool result |
			target := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.
			tool := MyCylinderMaker makeCylinderRadius: 0.25 height: 1.

			[
				result := target cutWith: tool.
				self deny: result isNil ] ensure: [
					result ifNotNil: [ result free ].
					tool free.
					target free ] ].

	Smalltalk garbageCollect.

	self assert: self cxxHasNoMemoryDifference
]

{ #category : 'tests' }
MyBoxMakerMemoryTest >> testBoxCreationAndFreeDoesNotLeakNativeMemory [

	CxxOcctLibrary cxxMemoryCheckpoint.

	100 timesRepeat: [
			| shape |
			shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.
			shape free ].

	Smalltalk garbageCollect.

	self assert: self cxxHasNoMemoryDifference
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
MyBoxMakerMemoryTest >> testTessellatedCylinderDoesNotLeakNativeMemory [

	CxxOcctLibrary cxxMemoryCheckpoint.

	100 timesRepeat: [
			| shape |
			shape := MyCylinderMaker
				         tessellatedCylinderRadius: 0.5
				         height: 1
				         deflection: 0.01.

			[ shape vertices ] ensure: [ shape free ] ].

	Smalltalk garbageCollect.

	self assert: self cxxHasNoMemoryDifference
]

{ #category : 'tests' }
MyBoxMakerMemoryTest >> testTopologyInspectionDoesNotLeakNativeMemory [

	CxxOcctLibrary cxxMemoryCheckpoint.

	50 timesRepeat: [
			| shape faces edges vertices |
			shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.

			[
				faces := shape faces.
				edges := shape edges.
				vertices := shape topologicalVertices.

				self assert: faces size equals: 6.
				self assert: edges size equals: 12.
				self assert: vertices size equals: 8 ] ensure: [
					faces ifNotNil: [ faces do: [ :each | each free ] ].
					edges ifNotNil: [ edges do: [ :each | each free ] ].
					vertices ifNotNil: [ vertices do: [ :each | each free ] ].
					shape free ] ].

	Smalltalk garbageCollect.

	self assert: self cxxHasNoMemoryDifference
]
