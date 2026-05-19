"
I am the high level API used for creating a Box for WODEN

Public API:
- #tessellatedBoxDx:dy:dz:deflection: - Creates a box and immediately calculates its mesh based on a deflection tolerance.
"
Class {
	#name : 'MyBoxMaker',
	#superclass : 'MyMakeShape',
	#category : 'MyOpenCascade-Base',
	#package : 'MyOpenCascade',
	#tag : 'Base'
}

{ #category : 'factory' }
MyBoxMaker class >> makeBoxDx: dx dy: dy dz: dz [
	"Creates a box shape via the direct C++ factory call. Raises an error if the result is null."

	| shape |
	shape := CxxOcctLibrary cxxCreateBoxDx: dx dy: dy dz: dz.
	shape isNull ifTrue: [ self error: 'cxxCreateBox failed' ].
	^ shape
]

{ #category : 'factory' }
MyBoxMaker class >> tessellatedBoxDx: dx dy: dy dz: dz deflection: deflection [
	"Creates a box and immediately tessellates it at the given deflection. Returns a ready-to-render shape."

	| shape |
	shape := self makeBoxDx: dx dy: dy dz: dz.
	shape tessellateDeflection: deflection.
	^ shape
]
