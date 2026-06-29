Class {
	#name : 'MyCADTranslationMode',
	#superclass : 'Object',
	#instVars : [
		'presenter',
		'active',
		'startNodePosition'
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
	selectedRenderedShape isAlive ifFalse: [ ^ self ].

	active := true.
	startNodePosition := selectedRenderedShape node position.
]

{ #category : 'activation' }
MyCADTranslationMode >> cancel [
	"Restores the selected node to its position before translation mode started."

	self isActive ifFalse: [ ^ self ].

	presenter selectedRenderedShape ifNotNil: [ :selectedRenderedShape |
			(selectedRenderedShape isAlive and: [ startNodePosition notNil ]) ifTrue: [
				selectedRenderedShape node position: startNodePosition ] ].

	self reset.
	presenter refreshScene.
	presenter visualChanged.
	presenter transformModeChanged: #none
]

{ #category : 'activation' }
MyCADTranslationMode >> confirm [
	"Accepts the current rendered-node translation and bakes it into the CAD shape."

	| selectedRenderedShape change |
	self isActive ifFalse: [ ^ self ].

	selectedRenderedShape := presenter selectedRenderedShape.
	(selectedRenderedShape notNil and: [ selectedRenderedShape isAlive ]) ifTrue: [
			presenter restoreSelectedVisual.

			change := selectedRenderedShape bakeTranslation.
			presenter applyRenderNodeChange: change.
			presenter applySelectedVisualTo: selectedRenderedShape node ].

	self reset.
	presenter refreshScene.
	presenter visualChanged.
	presenter transformModeChanged: #none
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
			(selectedRenderedShape isAlive and: [ startNodePosition notNil ]) ifTrue: [
				selectedRenderedShape node position: startNodePosition + aVector ] ].
	presenter refreshScene
]

{ #category : 'initialization' }
MyCADTranslationMode >> reset [
	"Clears transient translation-mode state."

	active := false.
	startNodePosition := nil
]

{ #category : 'mouse' }
MyCADTranslationMode >> updateAt: aPoint [
	"Mouse-drag translation is intentionally disabled.
	Translation is edited through the transform panel's U/V/W fields and committed with OK."

	^ self
]
