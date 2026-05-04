Class {
	#name : 'MyBoxTest',
	#superclass : 'TestCase',
	#category : 'MyOpenCascade-UFFI-Test',
	#package : 'MyOpenCascade-UFFI-Test'
}

{ #category : 'tests' }
MyBoxTest >> testCreatingClass [
	"A test that will check if the creation of an object MyBox is done properly"

	| tmp |
	tmp := MyBox lengthX: 1 lengthY: 1 lengthZ: 1.
	self deny: tmp isNil
]

{ #category : 'tests' }
MyBoxTest >> testCreatingShape [
	"A test that will check if the foreign function returns a TopoDS_Shape handle properly"

	| myBox |
	myBox := MyBox lengthX: 1 lengthY: 1 lengthZ: 1.
	myBox toShape.
	self assert: myBox isDone.
	myBox freeCxxAddress
]
