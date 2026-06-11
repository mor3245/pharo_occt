Class {
	#name : 'MyContextMenuTranslationMode',
	#superclass : 'Object',
	#instVars : [
		'presenter',
		'active',
		'startNodePosition',
		'axisLock',
		'dragPlanePoint',
		'dragPlaneNormal',
		'startWorldPoint'
	],
	#category : 'MyOpenCascade-Woden',
	#package : 'MyOpenCascade',
	#tag : 'Woden'
}

{ #category : 'activation' }
MyContextMenuTranslationMode >> activateFor: aPresenter [
	"Starts interactive translation for the selected rendered node."

	| selectedRenderedShape |
	presenter := aPresenter.
	selectedRenderedShape := presenter selectedRenderedShape.
	selectedRenderedShape ifNil: [ ^ self ].

	active := true.
	axisLock := nil.
	startNodePosition := selectedRenderedShape node position.
	dragPlanePoint := startNodePosition.
	dragPlaneNormal := presenter cameraForwardDirection.
	startWorldPoint := nil.

	presenter focusWodenWidget
]

{ #category : 'activation' }
MyContextMenuTranslationMode >> cancel [
	"Restores the selected node to its position before translation mode started."

	self isActive ifFalse: [ ^ self ].

	presenter selectedRenderedShape ifNotNil: [ :selectedRenderedShape |
		startNodePosition ifNotNil: [ selectedRenderedShape node position: startNodePosition ] ].

	self reset.
	presenter refreshScene
]

{ #category : 'activation' }
MyContextMenuTranslationMode >> confirm [
	"Accepts the current rendered-node translation."

	self reset.
	presenter refreshScene
]

{ #category : 'geometry' }
MyContextMenuTranslationMode >> constrainedTranslation: aVector [
	"Constrains a drag translation to the selected global axis."

	| axis amount |
	axisLock ifNil: [ ^ aVector ].

	axisLock = #x ifTrue: [ axis := Vector3 x: 1 y: 0 z: 0 ].
	axisLock = #y ifTrue: [ axis := Vector3 x: 0 y: 1 z: 0 ].
	axisLock = #z ifTrue: [ axis := Vector3 x: 0 y: 0 z: 1 ].

	amount := aVector dot: axis.
	^ axis * amount
]

{ #category : 'geometry' }
MyContextMenuTranslationMode >> dragPlanePointAtScreenPosition: aPoint [
	"Returns the point where the screen ray intersects the current drag plane."

	| ray denominator distance |
	dragPlanePoint ifNil: [ ^ nil ].
	dragPlaneNormal ifNil: [ ^ nil ].

	ray := presenter rayForScreenPosition: aPoint.

	denominator := ray direction dot: dragPlaneNormal.
	denominator abs < 1.0e-6 ifTrue: [ ^ nil ].

	distance := (dragPlanePoint - ray origin dot: dragPlaneNormal) / denominator.
	distance < 0 ifTrue: [ ^ nil ].

	^ ray pointAtDistance: distance
]

{ #category : 'keyboard' }
MyContextMenuTranslationMode >> handleKey: key [
	"Handles a normalized key string. Answers whether the key was consumed."

	self isActive ifFalse: [ ^ false ].

	key = 'x' ifTrue: [
			axisLock := #x.
			^ true ].
	key = 'y' ifTrue: [
			axisLock := #y.
			^ true ].
	key = 'z' ifTrue: [
			axisLock := #z.
			^ true ].
	(key = 'enter' or: [ key = 'return' ]) ifTrue: [
			self confirm.
			^ true ].
	key = 'escape' ifTrue: [
			self cancel.
			^ true ].

	^ false
]

{ #category : 'initialization' }
MyContextMenuTranslationMode >> initialize [

	super initialize.
	self reset
]

{ #category : 'testing' }
MyContextMenuTranslationMode >> isActive [

	^ active = true
]

{ #category : 'initialization' }
MyContextMenuTranslationMode >> reset [
	"Clears transient translation-mode state."

	active := false.
	startNodePosition := nil.
	axisLock := nil.
	dragPlanePoint := nil.
	dragPlaneNormal := nil.
	startWorldPoint := nil
]

{ #category : 'mouse' }
MyContextMenuTranslationMode >> updateAt: aPoint [
	"Moves the selected rendered node by dragging across a camera-facing world plane."

	| selectedRenderedShape node currentWorldPoint translation newPosition |
	selectedRenderedShape := presenter selectedRenderedShape.
	selectedRenderedShape ifNil: [ ^ self ].

	currentWorldPoint := self dragPlanePointAtScreenPosition: aPoint.
	currentWorldPoint ifNil: [ ^ self ].

	startWorldPoint ifNil: [ startWorldPoint := currentWorldPoint ].

	node := selectedRenderedShape node.
	translation := currentWorldPoint - startWorldPoint.
	translation := self constrainedTranslation: translation.

	newPosition := startNodePosition + translation.

	node position: newPosition.
	presenter refreshScene
]
