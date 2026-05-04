Class {
	#name : 'CxxBRepPrimAPI_MakeBoxTest',
	#superclass : 'TestCase',
	#category : 'MyOpenCascade-UFFI-Test',
	#package : 'MyOpenCascade-UFFI-Test'
}

{ #category : 'tests' }
CxxBRepPrimAPI_MakeBoxTest >> testCreatingBRepPrimAPI_MakeBox [
	"A test that will check if the BRepPrimAPI_MakeBox address is returned properly"

	| boxHandle boxMaker |
	boxMaker := CxxBRepPrimAPI_MakeBox new.
	self deny: boxMaker isNil.
	boxHandle := boxMaker lengthX: 10 lengthY: 10 lengthZ: 10.
	self assert: (boxHandle isKindOf: ExternalAddress)
]

{ #category : 'tests' }
CxxBRepPrimAPI_MakeBoxTest >> testCreatingClass [
	"A test that will check if the creation of an object CxxMyBoxFacade is done properly"

	| tmp |
	tmp := CxxBRepPrimAPI_MakeBox new.
	self deny: (tmp isNil)
]
