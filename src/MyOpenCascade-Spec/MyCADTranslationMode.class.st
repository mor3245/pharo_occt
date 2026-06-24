Class {
	#name : 'MyCADTranslationMode',
	#superclass : 'Object',
	#instVars : [
		'presenter',
		'active',
		'startNodePosition',
		'startScreenPosition',
		'axisLock',
		'dragPlanePoint',
		'dragPlaneNormal',
		'startWorldPoint'
	],
	#category : 'MyOpenCascade-Spec',
	#package : 'MyOpenCascade-Spec'
}

{ #category : 'activation' }
MyCADTranslationMode >> activateFor: aPresenter [
	"Starts interactive translation for the selected rendered node."

	| selectedRenderedShape |
	presenter := aPresenter.
	selectedRenderedShape := presenter selectedRenderedShape.
	selectedRenderedShape ifNil: [ ^ self ].

	active := true.
	axisLock := nil.
	startNodePosition := selectedRenderedShape node position.
	startScreenPosition := nil.
	dragPlanePoint := startNodePosition.
	dragPlaneNormal := presenter cameraForwardDirection.
	startWorldPoint := nil.

	presenter focusWodenWidget
]

{ #category : 'geometry' }
MyCADTranslationMode >> axisDirection [
	"Returns the global direction for the current axis lock."

	axisLock = #x ifTrue: [ ^ Vector3 x: 1 y: 0 z: 0 ].
	axisLock = #y ifTrue: [ ^ Vector3 x: 0 y: 1 z: 0 ].
	axisLock = #z ifTrue: [ ^ Vector3 x: 0 y: 0 z: 1 ].

	^ nil
]

{ #category : 'geometry' }
MyCADTranslationMode >> axisTranslationAtScreenPosition: aPoint [
	"Returns the world-space translation for the locked axis from screen movement."

	| axis delta amount |
	axis := self axisDirection.
	axis ifNil: [ ^ Vector3 x: 0 y: 0 z: 0 ].

	startScreenPosition ifNil: [ startScreenPosition := aPoint ].

	delta := aPoint - startScreenPosition.
	amount := self translationAmountForScreenDelta: delta.

	^ axis * amount
]

{ #category : 'activation' }
MyCADTranslationMode >> cancel [
	"Restores the selected node to its position before translation mode started."

	self isActive ifFalse: [ ^ self ].

	presenter selectedRenderedShape ifNotNil: [ :selectedRenderedShape |
		startNodePosition ifNotNil: [ selectedRenderedShape node position: startNodePosition ] ].

	self reset.
	presenter refreshScene.
	presenter transformModeChanged: #none
]

{ #category : 'activation' }
MyCADTranslationMode >> confirm [
	"Accepts the current rendered-node translation and bakes it into the CAD shape."

	| selectedRenderedShape change |
	self isActive ifFalse: [ ^ self ].

	selectedRenderedShape := presenter selectedRenderedShape.
	selectedRenderedShape ifNotNil: [
			presenter restoreSelectedVisual.

			change := selectedRenderedShape bakeTranslation.
			presenter applyRenderNodeChange: change.
			presenter applySelectedVisualTo: selectedRenderedShape node ].

	self reset.
	presenter refreshScene.
	presenter transformModeChanged: #none
]

{ #category : 'geometry' }
MyCADTranslationMode >> dragPlanePointAtScreenPosition: aPoint [
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

{ #category : 'geometry' }
MyCADTranslationMode >> freeTranslationAtScreenPosition: aPoint [
	"Returns the free-drag translation on the camera-facing drag plane."

	| currentWorldPoint |
	currentWorldPoint := self dragPlanePointAtScreenPosition: aPoint.
	currentWorldPoint ifNil: [ ^ Vector3 x: 0 y: 0 z: 0 ].

	startWorldPoint ifNil: [ startWorldPoint := currentWorldPoint ].

	^ currentWorldPoint - startWorldPoint
]

{ #category : 'keyboard' }
MyCADTranslationMode >> handleAxisKey: key [
	"Handles X/Y/Z axis lock keys."

	(#( 'x' 'y' 'z' ) includes: key) ifFalse: [ ^ false ].
	
	axisLock := key asSymbol.
	startWorldPoint := nil.
	startScreenPosition := nil.
	^ true
]

{ #category : 'keyboard' }
MyCADTranslationMode >> handleCancellationKey: key [
	"Handles translation cancellation keys."

	key = 'escape' ifFalse: [ ^ false ].
	
	self cancel.
	^ true
]

{ #category : 'keyboard' }
MyCADTranslationMode >> handleCompletionKey: key [
	"Handles translation confirmation keys."

	(#( 'enter' 'return' ) includes: key) ifFalse: [ ^ false ].
	self confirm.
	^ true
]

{ #category : 'keyboard' }
MyCADTranslationMode >> handleKey: key [
	"Handles a normalized key string. Answers whether the key was consumed."

	self isActive ifFalse: [ ^ false ].

	(self handleAxisKey: key) ifTrue: [ ^ true ].
	(self handleCompletionKey: key) ifTrue: [ ^ true ].
	(self handleCancellationKey: key) ifTrue: [ ^ true ].

	^ false
]

{ #category : 'initialization' }
MyCADTranslationMode >> initialize [

	super initialize.
	self reset
]

{ #category : 'testing' }
MyCADTranslationMode >> isActive [

	^ active
]

{ #category : 'geometry' }
MyCADTranslationMode >> previewTranslation: aVector [
	"Moves the selected rendered node to the absolute preview translation measured from the activation point."

	self isActive ifFalse: [ ^ self ].
	presenter selectedRenderedShape ifNotNil: [ :selectedRenderedShape |
		startNodePosition ifNotNil: [ selectedRenderedShape node position: startNodePosition + aVector ] ].
	presenter refreshScene
]

{ #category : 'initialization' }
MyCADTranslationMode >> reset [
	"Clears transient translation-mode state."

	active := false.
	startNodePosition := nil.
	startScreenPosition := nil.
	axisLock := nil.
	dragPlanePoint := nil.
	dragPlaneNormal := nil.
	startWorldPoint := nil
]

{ #category : 'geometry' }
MyCADTranslationMode >> translationAmountForScreenDelta: aPoint [
	"Returns the signed world distance for the locked axis from screen movement."

	| scale |
	scale := self translationUnitsPerPixel.

	axisLock = #x ifTrue: [ ^ aPoint x * scale ].

	^ aPoint y negated * scale
]

{ #category : 'geometry' }
MyCADTranslationMode >> translationUnitsPerPixel [
	"World units moved per screen pixel during axis-locked translation."

	^ 0.01
]

{ #category : 'mouse' }
MyCADTranslationMode >> updateAt: aPoint [
	"Moves the selected rendered node by dragging freely or along the locked global axis."

	| selectedRenderedShape node translation newPosition |
	selectedRenderedShape := presenter selectedRenderedShape.
	selectedRenderedShape ifNil: [ ^ self ].

	node := selectedRenderedShape node.
	translation := axisLock
		               ifNil: [ self freeTranslationAtScreenPosition: aPoint ]
		               ifNotNil: [ self axisTranslationAtScreenPosition: aPoint ].

	newPosition := startNodePosition + translation.

	node position: newPosition.
	presenter refreshScene
]
