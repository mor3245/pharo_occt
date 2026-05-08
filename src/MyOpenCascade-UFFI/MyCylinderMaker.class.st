"
I am the high level API used for creating a Cylinder for WODEN

Public API:

•	#tessellatedBoxDx:dy:dz:deflection: - Creates a box and immediately calculates its mesh based on a deflection tolerance.
"
Class {
	#name : 'MyCylinderMaker',
	#superclass : 'MyMakeShape',
	#category : 'MyOpenCascade-UFFI-Base',
	#package : 'MyOpenCascade-UFFI',
	#tag : 'Base'
}

{ #category : 'factory' }
MyCylinderMaker class >> makeCylinderRadius: radius height: height [
	| makeCylinder shape |
	makeCylinder := CxxOcctLibrary cxxCylinderNewRadius: radius height: height.
	(CxxOcctLibrary isDone: makeCylinder) = 0 ifTrue: [
		CxxOcctLibrary cxxMakeCylinderDelete: makeCylinder.
		self error: 'cxxCylinderNew failed (IsDone=0)' ].

	shape := CxxOcctLibrary cxxToShape: makeCylinder.
	CxxOcctLibrary cxxMakeCylinderDelete: makeCylinder.
	^ MyShape on: shape
]

{ #category : 'factory' }
MyCylinderMaker class >> tessellatedCylinderRadius: radius height: height deflection: deflection [
	| shape |
	shape := self makeCylinderRadius: radius height: height.
	shape tessellateDeflection: deflection.
	^ shape
]
