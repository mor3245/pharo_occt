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
    | array cls |
    cls := Smalltalk at: #Float64Array ifAbsent: [ nil ].
    array := cls
        ifNil: [ Array new: count ]
        ifNotNil: [ cls new: count ].

    1 to: count do: [ :i |
        array
            at: i
            put: (address doubleAt: ((i - 1) * 8) + 1) ].

    ^ array
]

{ #category : 'as yet unclassified' }
MyMakeShape class >> int32ArrayFromExternalAddress: address count: count [
    | array |
    array := Array new: count.

    1 to: count do: [ :i |
        array
            at: i
            put: (address signedLongAt: ((i - 1) * 4) + 1) ].

    ^ array

]
