Class {
	#name : 'MyCADTransformPanelPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'titleLabel',
		'statusLabel',
		'uInput',
		'vInput',
		'wInput',
		'okButton',
		'cancelButton',
		'previewAction',
		'acceptAction',
		'cancelAction',
		'updating',
		'active'
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
				   add: 'U (mm)' atPoint: 1 @ 1;
				   add: #uInput atPoint: 2 @ 1;
				   add: 'V (mm)' atPoint: 1 @ 2;
				   add: #vInput atPoint: 2 @ 2;
				   add: 'W (mm)' atPoint: 1 @ 3;
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
MyCADTransformPanelPresenter >> activateForTranslation [

	active := true.
	statusLabel label: 'Translation'.
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
	statusLabel label: 'No active transform'
]

{ #category : 'initialization' }
MyCADTransformPanelPresenter >> initializePresenters [

	super initializePresenters.

	active := false.
	updating := false.
	previewAction := [ :translation |  ].
	acceptAction := [ ].
	cancelAction := [ ].

	titleLabel := self newLabel
		              label: 'Transform';
		              yourself.
	statusLabel := self newLabel
		               label: 'No active transform';
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

	uInput whenNumberChangedDo: [ :newNumber | self previewChanged ].
	vInput whenNumberChangedDo: [ :newNumber | self previewChanged ].
	wInput whenNumberChangedDo: [ :newNumber | self previewChanged ].

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
	previewAction value: self translationVector
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
MyCADTransformPanelPresenter >> translationVector [

	^ Vector3
		  x: uInput number * self modelUnitsPerMillimeter
		  y: vInput number * self modelUnitsPerMillimeter
		  z: wInput number * self modelUnitsPerMillimeter
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
