Class {
	#name : 'MyCADTransformPanelPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'titleLabel',
		'statusLabel',
		'uLabel',
		'vLabel',
		'wLabel',
		'uInput',
		'vInput',
		'wInput',
		'okButton',
		'cancelButton',
		'previewAction',
		'acceptAction',
		'cancelAction',
		'updating',
		'active',
		'mode',
		'activeRotationAxis'
	],
	#category : 'MyOpenCascade-Spec',
	#package : 'MyOpenCascade-Spec'
}

{ #category : 'layout' }
MyCADTransformPanelPresenter class >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: #titleLabel withConstraints: [ :constraints | constraints height: 26 ];
		  add: #statusLabel withConstraints: [ :constraints | constraints height: 44 ];
		  add: (SpGridLayout new
				   add: #uLabel atPoint: 1 @ 1;
				   add: #uInput atPoint: 2 @ 1;
				   add: #vLabel atPoint: 1 @ 2;
				   add: #vInput atPoint: 2 @ 2;
				   add: #wLabel atPoint: 1 @ 3;
				   add: #wInput atPoint: 2 @ 3;
				   yourself);
		  add: (SpBoxLayout newHorizontal
				   add: #okButton;
				   add: #cancelButton;
				   yourself)
		  withConstraints: [ :constraints | constraints height: 32 ];
		  yourself
]

{ #category : 'actions' }
MyCADTransformPanelPresenter >> accept [

	active ifFalse: [ ^ self ].
	acceptAction value
]

{ #category : 'activation' }
MyCADTransformPanelPresenter >> activateForRotation [

	active := true.
	mode := #rotation.
	statusLabel label: 'Rotation'.
	uLabel label: 'X (deg)'.
	vLabel label: 'Y (deg)'.
	wLabel label: 'Z (deg)'.
	self resetValues.
	self previewChanged
]

{ #category : 'activation' }
MyCADTransformPanelPresenter >> activateForTranslation [

	active := true.
	mode := #translation.
	activeRotationAxis := #z.
	statusLabel label: 'Translation'.
	uLabel label: 'U (mm)'.
	vLabel label: 'V (mm)'.
	wLabel label: 'W (mm)'.
	self resetValues.
	self previewChanged
]

{ #category : 'actions' }
MyCADTransformPanelPresenter >> cancel [

	active ifFalse: [ ^ self ].
	cancelAction value.
	self deactivate
]

{ #category : 'activation' }
MyCADTransformPanelPresenter >> deactivate [

	active := false.
	mode := nil.
	activeRotationAxis := nil.
	statusLabel label: 'No active transform'
]

{ #category : 'initialization' }
MyCADTransformPanelPresenter >> initializePresenters [

	super initializePresenters.

	active := false.
	mode := nil.
	activeRotationAxis := nil.
	updating := false.
	previewAction := [ :transformValues |  ].
	acceptAction := [ ].
	cancelAction := [ ].

	titleLabel := self newLabel
		              label: 'Transform';
		              yourself.
	statusLabel := self newLabel
		               label: 'No active transform';
		               yourself.
	uLabel := self newLabel
		          label: 'U (mm)';
		          yourself.
	vLabel := self newLabel
		          label: 'V (mm)';
		          yourself.
	wLabel := self newLabel
		          label: 'W (mm)';
		          yourself.

	uInput := self newNumberInput
		          beFloat;
		          yourself.
	vInput := self newNumberInput
		          beFloat;
		          yourself.
	wInput := self newNumberInput
		          beFloat;
		          yourself.

	uInput whenNumberChangedDo: [ :newNumber | self valueChangedForAxis: #x ].
	vInput whenNumberChangedDo: [ :newNumber | self valueChangedForAxis: #y ].
	wInput whenNumberChangedDo: [ :newNumber | self valueChangedForAxis: #z ].


	okButton := self newButton
		            label: 'OK';
		            whenActivatedDo: [ self accept ];
		            yourself.
	cancelButton := self newButton
		                label: 'Cancel';
		                whenActivatedDo: [ self cancel ];
		                yourself.

	self resetValues
]

{ #category : 'units' }
MyCADTransformPanelPresenter >> modelUnitsPerMillimeter [
	"Answers the current display/model scale for translation input.
	The transform panel is edited in millimeters, while the current scene behaves as meter-like model units."

	^ 1
]

{ #category : 'actions' }
MyCADTransformPanelPresenter >> previewChanged [

	(active not or: [ updating ]) ifTrue: [ ^ self ].
	previewAction value: self transformValues
]

{ #category : 'activation' }
MyCADTransformPanelPresenter >> resetValues [

	updating := true.
	[
		uInput number: 0.0.
		vInput number: 0.0.
		wInput number: 0.0 ] ensure: [ updating := false ]
]

{ #category : 'accessing' }
MyCADTransformPanelPresenter >> transformValues [

	mode = #translation ifTrue: [
			^ Vector3
				  x: uInput number * self modelUnitsPerMillimeter
				  y: vInput number * self modelUnitsPerMillimeter
				  z: wInput number * self modelUnitsPerMillimeter ].

	mode = #rotation ifTrue: [
			activeRotationAxis = #x ifTrue: [ ^ Vector3 x: uInput number y: 0 z: 0 ].
			activeRotationAxis = #y ifTrue: [ ^ Vector3 x: 0 y: vInput number z: 0 ].
			activeRotationAxis = #z ifTrue: [ ^ Vector3 x: 0 y: 0 z: wInput number ] ].

	^ Vector3 x: 0 y: 0 z: 0
]

{ #category : 'actions' }
MyCADTransformPanelPresenter >> valueChangedForAxis: axisSymbol [

	(active and: [ mode = #rotation ]) ifFalse: [ ^ self previewChanged ].
	updating ifTrue: [ ^ self ].

	activeRotationAxis := axisSymbol.
	updating := true.
	[
		axisSymbol = #x ifFalse: [ uInput number: 0.0 ].
		axisSymbol = #y ifFalse: [ vInput number: 0.0 ].
		axisSymbol = #z ifFalse: [ wInput number: 0.0 ] ] ensure: [ updating := false ].
	self previewChanged
]

{ #category : 'callbacks' }
MyCADTransformPanelPresenter >> whenAcceptDo: aBlock [

	acceptAction := aBlock
]

{ #category : 'callbacks' }
MyCADTransformPanelPresenter >> whenCancelDo: aBlock [

	cancelAction := aBlock
]

{ #category : 'callbacks' }
MyCADTransformPanelPresenter >> whenPreviewChangedDo: aBlock [

	previewAction := aBlock
]
