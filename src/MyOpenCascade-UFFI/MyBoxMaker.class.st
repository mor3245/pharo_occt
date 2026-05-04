Class {
	#name : 'MyBoxMaker',
	#superclass : 'Object',
	#category : 'MyOpenCascade-UFFI',
	#package : 'MyOpenCascade-UFFI'
}

{ #category : 'as yet unclassified' }
MyBoxMaker class >> doubleFromBytes: aByteArray byteIndex: byteIndex [
	"Robust across images where the selector differs."

	^ aByteArray doubleAt: byteIndex bigEndian: false
]

{ #category : 'as yet unclassified' }
MyBoxMaker class >> float64ArrayFromBytes: aByteArray [
	| count array cls |
	count := aByteArray size // 8.
	cls := Smalltalk at: #Float64Array ifAbsent: [ nil ].
	array := cls
		ifNil: [ Array new: count ]
		ifNotNil: [ cls new: count ].

	1 to: count do: [ :i |
		array at: i put: (self doubleFromBytes: aByteArray byteIndex: ((i - 1) * 8) + 1) ].
	^ array
]

{ #category : 'as yet unclassified' }
MyBoxMaker class >> int32ArrayFromBytes: aByteArray [
	| count array cls |
	count := aByteArray size // 4.
	cls := Smalltalk at: #Int32Array ifAbsent: [ nil ].
	array := cls
		ifNil: [ Array new: count ]
		ifNotNil: [ cls new: count ].

	1 to: count do: [ :i |
		array at: i put: (self int32FromBytes: aByteArray byteIndex: ((i - 1) * 4) + 1) ].
	^ array
]

{ #category : 'as yet unclassified' }
MyBoxMaker class >> int32FromBytes: aByteArray byteIndex: byteIndex [

        ^ aByteArray longAt: byteIndex bigEndian: false 

]

{ #category : 'as yet unclassified' }
MyBoxMaker class >> makeBoxDx: dx dy: dy dz: dz [
	| makeBox shape |
	makeBox := CxxBoxLibrary cxxBoxNewDx: dx dy: dy dz: dz.
	(CxxBoxLibrary isDone: makeBox) = 0 ifTrue: [
		CxxBoxLibrary cxxMakeBoxDelete: makeBox.
		self error: 'cxxBoxNew failed (IsDone=0)' ].

	shape := CxxBoxLibrary cxxBoxShape: makeBox.
	CxxBoxLibrary cxxMakeBoxDelete: makeBox.
	^ MyShape on: shape
]

{ #category : 'as yet unclassified' }
MyBoxMaker class >> primMakeBoxDelete: aHandle [
    ^ self ffiCall: #(void cxxMakeBoxDelete(void* aHandle))
]

{ #category : 'as yet unclassified' }
MyBoxMaker class >> tessellatedBoxDx: dx dy: dy dz: dz deflection: deflection [
	| shape |
	shape := self makeBoxDx: dx dy: dy dz: dz.
	shape tessellateDeflection: deflection.
	^ shape
]
