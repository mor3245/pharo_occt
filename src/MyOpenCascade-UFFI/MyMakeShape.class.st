"
I am responsible for translating byte arrays for Woden to understand.
"
Class {
	#name : 'MyMakeShape',
	#superclass : 'Object',
	#category : 'MyOpenCascade-UFFI-Base',
	#package : 'MyOpenCascade-UFFI',
	#tag : 'Base'
}

{ #category : 'binary data marshalling' }
MyMakeShape class >> doubleFromBytes: aByteArray byteIndex: byteIndex [
	"Robust across images where the selector differs."

	^ aByteArray doubleAt: byteIndex bigEndian: false
]

{ #category : 'binary data marshalling' }
MyMakeShape class >> float64ArrayFromBytes: aByteArray [
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

{ #category : 'binary data marshalling' }
MyMakeShape class >> int32ArrayFromBytes: aByteArray [
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

{ #category : 'binary data marshalling' }
MyMakeShape class >> int32FromBytes: aByteArray byteIndex: byteIndex [

        ^ aByteArray longAt: byteIndex bigEndian: false
]
