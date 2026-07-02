"
I am responsible for translating byte arrays for Woden to understand.
"
Class {
	#name : 'MyMakeShape',
	#superclass : 'Object',
	#category : 'MyOpenCascade-Base',
	#package : 'MyOpenCascade',
	#tag : 'Base'
}

{ #category : 'as yet unclassified' }
MyMakeShape class >> float64ArrayFromExternalAddress: address count: count [
	"Reads count 64-bit doubles from a raw C pointer into a Float64Array (or plain Array if unavailable)."

	| array cls |
	cls := Smalltalk at: #Float64Array ifAbsent: [ nil ].
	array := cls ifNil: [ Array new: count ] ifNotNil: [ cls new: count ].

	1 to: count do: [ :i | array at: i put: (address doubleAt: i - 1 * 8 + 1) ].

	^ array
]

{ #category : 'as yet unclassified' }
MyMakeShape class >> int32ArrayFromExternalAddress: address count: count [
	"Reads count signed 32-bit integers from a raw C pointer into a Pharo Array."

	^ (1 to: count) collect: [ :i | address signedLongAt: i - 1 * 4 + 1 ]
]

{ #category : 'validation' }
MyMakeShape class >> validatePositiveDimension: aNumber named: label [
	"Primitive maker APIs reject invalid dimensions before calling into OCCT."

	(aNumber isNumber and: [ aNumber > 0 ]) ifFalse: [
		self error: label , ' must be positive' ]
]
