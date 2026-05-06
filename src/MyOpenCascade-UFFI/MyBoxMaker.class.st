"
I am a utility class responsible for bridging Pharo Smalltalk with the OpenCascade C++ library via Unified FFI (UFFI). 

I specialize in the creation and initial processing of 3D box geometries. My primary role is to manage the lifecycle of external C++ objects and provide a high-level API for generating shapes without requiring the user to manually handle raw pointers or memory deallocation.

Responsibilities:
- Geometric Creation: I provide methods like #makeBoxDx:dy:dz: to instantiate 3D boxes by interfacing with 'CxxBoxLibrary'.
- Data Marshalling: I convert raw binary data (ByteArrays) from FFI calls into Smalltalk-native collections such as Float64Array or Int32Array.
- Tessellation: I support the generation of mesh data by delegating tessellation tasks to the shapes I create.

Public API:
- #makeBoxDx:dy:dz: - Returns a 'MyShape' instance representing a box with the given dimensions.
- #tessellatedBoxDx:dy:dz:deflection: - Creates a box and immediately calculates its mesh based on a deflection tolerance.

Implementation Notes:
My conversion methods (e.g., #float64ArrayFromBytes:) are designed to be robust across different Pharo images by checking for the existence of specialized array classes before falling back to standard Arrays. I strictly use little-endian byte ordering for numeric conversions to match the expected output of the underlying C++ library.

Example:
    box := MyBoxMaker makeBoxDx: 10.0 dy: 20.0 dz: 30.0.

Class {
	#name : 'MyBoxMaker',
	#superclass : 'Object',
	#category : 'MyOpenCascade-UFFI',
	#package : 'MyOpenCascade-UFFI'
}
"
Class {
	#name : 'MyBoxMaker',
	#superclass : 'Object',
	#category : 'MyOpenCascade-UFFI-Base',
	#package : 'MyOpenCascade-UFFI',
	#tag : 'Base'
}

{ #category : 'binary data marshalling' }
MyBoxMaker class >> doubleFromBytes: aByteArray byteIndex: byteIndex [
	"Robust across images where the selector differs."

	^ aByteArray doubleAt: byteIndex bigEndian: false
]

{ #category : 'binary data marshalling' }
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

{ #category : 'binary data marshalling' }
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

{ #category : 'binary data marshalling' }
MyBoxMaker class >> int32FromBytes: aByteArray byteIndex: byteIndex [

        ^ aByteArray longAt: byteIndex bigEndian: false
]

{ #category : 'factory' }
MyBoxMaker class >> makeBoxDx: dx dy: dy dz: dz [
	| makeBox shape |
	makeBox := CxxBoxLibrary cxxBoxNewDx: dx dy: dy dz: dz.
	(CxxBoxLibrary isDone: makeBox) = 0 ifTrue: [
		CxxBoxLibrary cxxMakeBoxDelete: makeBox.
		self error: 'cxxBoxNew failed (IsDone=0)' ].

	shape := CxxBoxLibrary cxxToShape: makeBox.
	CxxBoxLibrary cxxMakeBoxDelete: makeBox.
	^ MyShape on: shape
]

{ #category : 'factory' }
MyBoxMaker class >> tessellatedBoxDx: dx dy: dy dz: dz deflection: deflection [
	| shape |
	shape := self makeBoxDx: dx dy: dy dz: dz.
	shape tessellateDeflection: deflection.
	^ shape
]
