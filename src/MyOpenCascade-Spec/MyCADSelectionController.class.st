Class {
	#name : 'MyCADSelectionController',
	#superclass : 'Object',
	#instVars : [
		'presenter',
		'selectedRenderedShape',
		'selectedOriginalRenderables'
	],
	#category : 'MyOpenCascade-Spec',
	#package : 'MyOpenCascade-Spec'
}

{ #category : 'instance creation' }
MyCADSelectionController class >> on: aPresenter [

	^ self new
		  presenter: aPresenter;
		  yourself
]

{ #category : 'selection' }
MyCADSelectionController >> applyVisualTo: aNode [
	"Replaces the node's renderables with yellow unlit copies to indicate selection."

	selectedOriginalRenderables := aNode renderables.
	aNode renderables: (selectedOriginalRenderables collect: [ :each | each copyWithMaterial: self selectionMaterial ])
]

{ #category : 'selection' }
MyCADSelectionController >> clear [
	"Restores selected visuals and clears selection state."

	self restoreVisual.
	self forget.
	presenter refreshScene
]

{ #category : 'selection' }
MyCADSelectionController >> forget [
	"Clears selection state without touching scene visuals."

	selectedRenderedShape := nil.
	selectedOriginalRenderables := nil
]

{ #category : 'accessing' }
MyCADSelectionController >> presenter: aPresenter [

	presenter := aPresenter
]

{ #category : 'selection' }
MyCADSelectionController >> restoreVisual [
	"Puts the originally saved renderables back on the selected node."

	selectedRenderedShape ifNil: [ ^ self ].
	selectedOriginalRenderables ifNil: [ ^ self ].

	selectedRenderedShape node renderables: selectedOriginalRenderables.
	selectedOriginalRenderables := nil
]

{ #category : 'selection' }
MyCADSelectionController >> selectFrom: pickedEntries [
	"Picks the next rendered shape from the entries under the cursor."

	| pickedIndex pickedEntry |
	pickedEntries ifEmpty: [
			self clear.
			^ self ].

	pickedIndex := selectedRenderedShape ifNil: [ 0 ] ifNotNil: [ pickedEntries indexOf: selectedRenderedShape ifAbsent: [ 0 ] ].

	pickedEntry := pickedEntries at: pickedIndex \\ pickedEntries size + 1.

	self restoreVisual.
	selectedRenderedShape := pickedEntry.
	self applyVisualTo: selectedRenderedShape node.

	presenter refreshScene
]

{ #category : 'accessing' }
MyCADSelectionController >> selectedNode [
	"Returns the scene node of the currently selected entry, or nil if nothing is selected."

	^ selectedRenderedShape ifNil: [ nil ] ifNotNil: [ selectedRenderedShape node ]
]

{ #category : 'accessing' }
MyCADSelectionController >> selectedRenderedShape [

	^ selectedRenderedShape
]

{ #category : 'geometry' }
MyCADSelectionController >> selectedRotationCenter [
	"Returns the visible world-space center of the selected rendered node."

	| node box |
	selectedRenderedShape ifNil: [ ^ Vector3 x: 0 y: 0 z: 0 ].

	node := selectedRenderedShape node.
	box := node localBoundingBox transformedWith: node globalTransform.

	^ box center
]

{ #category : 'accessing' }
MyCADSelectionController >> selectedShape [
	"Returns the MyShape of the currently selected entry, or nil if nothing is selected."

	^ selectedRenderedShape ifNil: [ nil ] ifNotNil: [ selectedRenderedShape shape ]
]

{ #category : 'accessing' }
MyCADSelectionController >> selectionMaterial [
	"Returns a yellow unlit material used to highlight the selected object."

	^ WDUnlitMaterial new
		  colorFactor: Color yellow;
		  yourself
]
