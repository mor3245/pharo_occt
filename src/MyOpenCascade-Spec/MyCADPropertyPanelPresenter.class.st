Class {
	#name : 'MyCADPropertyPanelPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'nameValue',
		'typeValue',
		'uValue',
		'vValue',
		'wValue',
		'lengthInput',
		'widthInput',
		'heightInput',
		'trianglesValue',
		'verticesValue',
		'dimensionsChangedAction',
		'updating',
		'selectedRenderedShape'
	],
	#category : 'MyOpenCascade-Spec',
	#package : 'MyOpenCascade-Spec'
}

{ #category : 'layout' }
MyCADPropertyPanelPresenter class >> defaultLayout [

	^ SpGridLayout new
		  add: 'Name' atPoint: 1 @ 1;
		  add: #nameValue atPoint: 2 @ 1;
		  add: 'Type' atPoint: 1 @ 2;
		  add: #typeValue atPoint: 2 @ 2;
		  add: 'Placement U (mm)' atPoint: 1 @ 3;
		  add: #uValue atPoint: 2 @ 3;
		  add: 'Placement V (mm)' atPoint: 1 @ 4;
		  add: #vValue atPoint: 2 @ 4;
		  add: 'Placement W (mm)' atPoint: 1 @ 5;
		  add: #wValue atPoint: 2 @ 5;
		  add: 'Box Length (mm)' atPoint: 1 @ 6;
		  add: #lengthInput atPoint: 2 @ 6;
		  add: 'Box Width (mm)' atPoint: 1 @ 7;
		  add: #widthInput atPoint: 2 @ 7;
		  add: 'Box Height (mm)' at: 1 @ 8;
		  add: #heightInput at: 2 @ 8;
		  add: 'Triangles' at: 1 @ 9;
		  add: #trianglesValue at: 2 @ 9;
		  add: 'Vertices' at: 1 @ 10;
		  add: #verticesValue at: 2 @ 10;
		  yourself
]

{ #category : 'updating' }
MyCADPropertyPanelPresenter >> clear [

	selectedRenderedShape := nil.
	updating := true.
	[
		nameValue label: ''.
		typeValue label: ''.
		uValue label: ''.
		vValue label: ''.
		wValue label: ''.
		lengthInput number: 0.0.
		widthInput number: 0.0.
		heightInput number: 0.0.
		trianglesValue label: ''.
		verticesValue label: '' ] ensure: [ updating := false ]
]

{ #category : 'actions' }
MyCADPropertyPanelPresenter >> dimensionsChanged [

	(updating or: [ selectedRenderedShape isNil ]) ifTrue: [ ^ self ].
	selectedRenderedShape editableDimensionLabels isEmpty ifTrue: [ ^ self ].

	dimensionsChangedAction value: lengthInput number value: widthInput number value: heightInput number
]

{ #category : 'initialization' }
MyCADPropertyPanelPresenter >> initializePresenters [

	super initializePresenters.

	updating := false.
	dimensionsChangedAction := [ :length :width :height |  ].

	nameValue := self newLabel.
	typeValue := self newLabel.
	uValue := self newLabel.
	vValue := self newLabel.
	wValue := self newLabel.
	trianglesValue := self newLabel.
	verticesValue := self newLabel.

	lengthInput := self newNumberInput
		               beFloat;
		               yourself.
	widthInput := self newNumberInput
		              beFloat;
		              yourself.
	heightInput := self newNumberInput
		               beFloat;
		               yourself.

	lengthInput whenNumberChangedDo: [ :newNumber | self dimensionsChanged ].
	widthInput whenNumberChangedDo: [ :newNumber | self dimensionsChanged ].
	heightInput whenNumberChangedDo: [ :newNumber | self dimensionsChanged ].

	self clear
]

{ #category : 'updating' }
MyCADPropertyPanelPresenter >> showRenderedShape: aRenderedShape placementMillimeters: placementVector dimensionsMillimeters: dimensionsVector [

	aRenderedShape isAlive ifFalse: [
			self clear.
			^ self ].

	selectedRenderedShape := aRenderedShape.
	updating := true.
	[
		nameValue label: aRenderedShape name.
		typeValue label: ((aRenderedShape respondsTo: #typeName)
				 ifTrue: [ aRenderedShape typeName ]
				 ifFalse: [ aRenderedShape shape class name ]).
		uValue label: placementVector x asString.
		vValue label: placementVector y asString.
		wValue label: placementVector z asString.
		aRenderedShape editableDimensionLabels isEmpty
			ifFalse: [
					lengthInput number: dimensionsVector x.
					widthInput number: dimensionsVector y.
					heightInput number: dimensionsVector z ]
			ifTrue: [
					lengthInput number: 0.0.
					widthInput number: 0.0.
					heightInput number: 0.0 ]. "Old static layout still labels these as Box dimensions. The selected CAD object now controls
		whether the fields are meaningful; the next property-panel refactor can make labels dynamic."
		trianglesValue label: aRenderedShape shape triangleCount asString.
		verticesValue label: aRenderedShape shape vertexCount asString ] ensure: [ updating := false ]
]

{ #category : 'callbacks' }
MyCADPropertyPanelPresenter >> whenDimensionsChangedDo: aBlock [

	dimensionsChangedAction := aBlock
]
