Class {
	#name : 'MyCADPropertyPanelPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'nameValue',
		'typeValue',
		'uValue',
		'vValue',
		'wValue',
		'dimensionOneLabel',
		'dimensionTwoLabel',
		'dimensionThreeLabel',
		'lengthInput',
		'widthInput',
		'heightInput',
		'trianglesValue',
		'verticesValue',
		'dimensionsChangedAction',
		'updating',
		'selectedCADObject'
	],
	#category : 'MyOpenCascade-Spec',
	#package : 'MyOpenCascade-Spec'
}

{ #category : 'layout' }
MyCADPropertyPanelPresenter class >> defaultLayout [

	^ self emptyLayout
]

{ #category : 'layout' }
MyCADPropertyPanelPresenter class >> emptyLayout [

	^ SpBoxLayout newVertical
]

{ #category : 'layout' }
MyCADPropertyPanelPresenter class >> propertyLayout [

	^ self propertyLayoutWithDimensionRows: 3
]

{ #category : 'layout' }
MyCADPropertyPanelPresenter class >> propertyLayoutWithDimensionRows: dimensionRowCount [

	| layout statisticsRow |
	layout := SpGridLayout new.
	layout
		add: 'Name' atPoint: 1 @ 1;
		add: #nameValue atPoint: 2 @ 1;
		add: 'Type' atPoint: 1 @ 2;
		add: #typeValue atPoint: 2 @ 2;
		add: 'Placement U (mm)' atPoint: 1 @ 3;
		add: #uValue atPoint: 2 @ 3;
		add: 'Placement V (mm)' atPoint: 1 @ 4;
		add: #vValue atPoint: 2 @ 4;
		add: 'Placement W (mm)' atPoint: 1 @ 5;
		add: #wValue atPoint: 2 @ 5.

	dimensionRowCount >= 1 ifTrue: [
			layout
				add: #dimensionOneLabel atPoint: 1 @ 6;
				add: #lengthInput atPoint: 2 @ 6 ].
	dimensionRowCount >= 2 ifTrue: [
			layout
				add: #dimensionTwoLabel atPoint: 1 @ 7;
				add: #widthInput atPoint: 2 @ 7 ].
	dimensionRowCount >= 3 ifTrue: [
			layout
				add: #dimensionThreeLabel atPoint: 1 @ 8;
				add: #heightInput atPoint: 2 @ 8 ].

	statisticsRow := 6 + (dimensionRowCount min: 3).
	layout
		add: 'Triangles' atPoint: 1 @ statisticsRow;
		add: #trianglesValue atPoint: 2 @ statisticsRow;
		add: 'Vertices' atPoint: 1 @ (statisticsRow + 1);
		add: #verticesValue atPoint: 2 @ (statisticsRow + 1).

	^ layout
]

{ #category : 'updating' }
MyCADPropertyPanelPresenter >> clear [

	selectedCADObject := nil.
	self layout: self class emptyLayout.

	updating := true.
	[
		nameValue label: ''.
		typeValue label: ''.
		uValue label: ''.
		vValue label: ''.
		wValue label: ''.
		dimensionOneLabel label: ''.
		dimensionTwoLabel label: ''.
		dimensionThreeLabel label: ''.
		lengthInput number: 0.0.
		widthInput number: 0.0.
		heightInput number: 0.0.
		trianglesValue label: ''.
		verticesValue label: '' ] ensure: [ updating := false ]
]

{ #category : 'actions' }
MyCADPropertyPanelPresenter >> dimensionsChanged [

	(updating or: [ selectedCADObject isNil ]) ifTrue: [ ^ self ].
	selectedCADObject editableDimensionLabels isEmpty ifTrue: [ ^ self ].

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
	dimensionOneLabel := self newLabel.
	dimensionTwoLabel := self newLabel.
	dimensionThreeLabel := self newLabel.
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
MyCADPropertyPanelPresenter >> labelForDimension: dimensionIndex in: dimensionLabels [

	dimensionIndex > dimensionLabels size ifTrue: [ ^ '' ].

	^ (dimensionLabels at: dimensionIndex) , ' (mm)'
]

{ #category : 'updating' }
MyCADPropertyPanelPresenter >> showCADObject: aCADObject placementMillimeters: placementVector dimensionsMillimeters: dimensionsVector [

	| dimensionLabels |
	aCADObject isAlive ifFalse: [
			self clear.
			^ self ].

	selectedCADObject := aCADObject.
	dimensionLabels := aCADObject editableDimensionLabels.
	self layout: (self class propertyLayoutWithDimensionRows: dimensionLabels size).
	updating := true.
	[
		nameValue label: aCADObject name.
		typeValue label: aCADObject typeName.
		uValue label: placementVector x asString.
		vValue label: placementVector y asString.
		wValue label: placementVector z asString.
		dimensionOneLabel label: (self labelForDimension: 1 in: dimensionLabels).
		dimensionTwoLabel label: (self labelForDimension: 2 in: dimensionLabels).
		dimensionThreeLabel label: (self labelForDimension: 3 in: dimensionLabels).
		dimensionLabels isEmpty
			ifFalse: [
					lengthInput number: dimensionsVector x.
					widthInput number: dimensionsVector y.
					heightInput number: dimensionsVector z ]
			ifTrue: [
					lengthInput number: 0.0.
					widthInput number: 0.0.
					heightInput number: 0.0 ].
		trianglesValue label: aCADObject triangleCount asString.
		verticesValue label: aCADObject vertexCount asString ] ensure: [ updating := false ]
]

{ #category : 'callbacks' }
MyCADPropertyPanelPresenter >> whenDimensionsChangedDo: aBlock [

	dimensionsChangedAction := aBlock
]
