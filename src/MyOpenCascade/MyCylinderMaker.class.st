"
I am the high level API used for creating a Cylinder for WODEN

Public API:

•	#tessellatedBoxDx:dy:dz:deflection: - Creates a box and immediately calculates its mesh based on a deflection tolerance.
"
Class {
	#name : 'MyCylinderMaker',
	#superclass : 'MyMakeShape',
	#category : 'MyOpenCascade-Base',
	#package : 'MyOpenCascade',
	#tag : 'Base'
}

{ #category : 'factory' }
MyCylinderMaker class >> makeCylinderRadius: radius height: height [
	"Creates a cylinder shape via the direct C++ factory call. Raises an error if the result is null."

	| shape |
	shape := CxxOcctLibrary cxxCreateCylinderRadius: radius height: height.
	shape isNull ifTrue: [ self error: 'cxxCreateCylinder failed' ].
	^ shape
]

{ #category : 'factory' }
MyCylinderMaker class >> tessellatedCylinderRadius: radius height: height deflection: deflection [
	"Creates a cylinder and immediately tessellates it at the given deflection. Returns a ready-to-render shape."

	| shape |
	shape := self makeCylinderRadius: radius height: height.
	shape tessellateDeflection: deflection.
	^ shape
]
