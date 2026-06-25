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
		'trianglesValue',
		'verticesValue',
		'dimensionsChangedAction',
		'updating',
		'selectedCADObject',
		'dimensionOneInput',
		'dimensionTwoInput',
		'dimensionThreeInput'
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
MyCADPropertyPanelPresenter class >> propertyLayoutWithDimensionRows: dimensionRowCount [

	| layout rowCount statisticsRow |
	rowCount := dimensionRowCount min: 3.
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

	rowCount >= 1 ifTrue: [
			layout
				add: #dimensionOneLabel atPoint: 1 @ 6;
				add: #dimensionOneInput atPoint: 2 @ 6 ].
	rowCount >= 2 ifTrue: [
			layout
				add: #dimensionTwoLabel atPoint: 1 @ 7;
				add: #dimensionTwoInput atPoint: 2 @ 7 ].
	rowCount >= 3 ifTrue: [
			layout
				add: #dimensionThreeLabel atPoint: 1 @ 8;
				add: #dimensionThreeInput atPoint: 2 @ 8 ].

	statisticsRow := 6 + rowCount.
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
		dimensionOneInput number: 0.0.
		dimensionTwoInput number: 0.0.
		dimensionThreeInput number: 0.0.
		trianglesValue label: ''.
		verticesValue label: '' ] ensure: [ updating := false ]
]

{ #category : 'actions' }
MyCADPropertyPanelPresenter >> dimensionsChanged [

	(updating or: [ selectedCADObject isNil ]) ifTrue: [ ^ self ].
	selectedCADObject editableDimensionLabels isEmpty ifTrue: [ ^ self ].

	dimensionsChangedAction value: dimensionOneInput number value: dimensionTwoInput number value: dimensionThreeInput number
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

	dimensionOneInput := self newNumberInput
		                     beFloat;
		                     yourself.
	dimensionTwoInput := self newNumberInput
		                     beFloat;
		                     yourself.
	dimensionThreeInput := self newNumberInput
		                       beFloat;
		                       yourself.

	dimensionOneInput whenNumberChangedDo: [ :newNumber | self dimensionsChanged ].
	dimensionTwoInput whenNumberChangedDo: [ :newNumber | self dimensionsChanged ].
	dimensionThreeInput whenNumberChangedDo: [ :newNumber | self dimensionsChanged ].

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
					dimensionOneInput number: dimensionsVector x.
					dimensionTwoInput number: dimensionsVector y.
					dimensionThreeInput number: dimensionsVector z ]
			ifTrue: [
					dimensionOneInput number: 0.0.
					dimensionTwoInput number: 0.0.
					dimensionThreeInput number: 0.0 ].
		trianglesValue label: aCADObject triangleCount asString.
		verticesValue label: aCADObject vertexCount asString ] ensure: [ updating := false ]
]

{ #category : 'callbacks' }
MyCADPropertyPanelPresenter >> whenDimensionsChangedDo: aBlock [

	dimensionsChangedAction := aBlock
]
