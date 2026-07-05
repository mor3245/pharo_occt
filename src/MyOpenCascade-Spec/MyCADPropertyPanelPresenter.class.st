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

	| layout rowCount |
	rowCount := dimensionRowCount min: 3.
	layout := SpBoxLayout newVertical.
	layout
		add: (self propertyRowLabel: 'Name' value: #nameValue)
		withConstraints: [ :constraints | constraints height: self propertyRowHeight ];
		add: (self propertyRowLabel: 'Type' value: #typeValue)
		withConstraints: [ :constraints | constraints height: self propertyRowHeight ];
		add: (self propertyRowLabel: 'Placement U (mm)' value: #uValue)
		withConstraints: [ :constraints | constraints height: self propertyRowHeight ];
		add: (self propertyRowLabel: 'Placement V (mm)' value: #vValue)
		withConstraints: [ :constraints | constraints height: self propertyRowHeight ];
		add: (self propertyRowLabel: 'Placement W (mm)' value: #wValue)
		withConstraints: [ :constraints | constraints height: self propertyRowHeight ].

	rowCount >= 1 ifTrue: [
			layout
				add: (self propertyRowLabel: #dimensionOneLabel value: #dimensionOneInput)
				withConstraints: [ :constraints | constraints height: self propertyRowHeight ] ].
	rowCount >= 2 ifTrue: [
			layout
				add: (self propertyRowLabel: #dimensionTwoLabel value: #dimensionTwoInput)
				withConstraints: [ :constraints | constraints height: self propertyRowHeight ] ].
	rowCount >= 3 ifTrue: [
			layout
				add: (self propertyRowLabel: #dimensionThreeLabel value: #dimensionThreeInput)
				withConstraints: [ :constraints | constraints height: self propertyRowHeight ] ].

	layout
		add: (self propertyRowLabel: 'Triangles' value: #trianglesValue)
		withConstraints: [ :constraints | constraints height: self propertyRowHeight ];
		add: (self propertyRowLabel: 'Vertices' value: #verticesValue)
		withConstraints: [ :constraints | constraints height: self propertyRowHeight ].


	^ layout
]

{ #category : 'layout' }
MyCADPropertyPanelPresenter class >> propertyRowHeight [

	^ 21

]

{ #category : 'layout' }
MyCADPropertyPanelPresenter class >> propertyRowLabel: labelPresenter value: valuePresenter [

	^ SpBoxLayout newHorizontal
		  add: labelPresenter;
		  add: valuePresenter withConstraints: [ :constraints | constraints width: self propertyValueWidth ];
		  yourself
]

{ #category : 'layout' }
MyCADPropertyPanelPresenter class >> propertyValueWidth [

	^ 76
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
	selectedCADObject hasEditableDimensions ifFalse: [ ^ self ].


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
