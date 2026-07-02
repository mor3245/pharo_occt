Class {
	#name : 'MyCADTransformPanelPresenterTest',
	#superclass : 'TestCase',
	#category : 'MyOpenCascade-CAD-GUI-Test',
	#package : 'MyOpenCascade-CAD-GUI-Test'
}

{ #category : 'tests' }
MyCADTransformPanelPresenterTest >> testDefaultLayoutIsDefined [

	self deny: MyCADTransformPanelPresenter defaultLayout isNil
]

{ #category : 'tests' }
MyCADTransformPanelPresenterTest >> testModelUnitsPerMillimeterIsOne [

	self assert: MyCADTransformPanelPresenter new modelUnitsPerMillimeter equals: 1
]
