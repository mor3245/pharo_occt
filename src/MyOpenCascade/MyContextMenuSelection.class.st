Class {
	#name : 'MyContextMenuSelection',
	#superclass : 'Object',
	#instVars : [
		'presenter',
		'selectedRenderedShape',
		'selectedOriginalRenderables'
	],
	#category : 'MyOpenCascade-Woden',
	#package : 'MyOpenCascade',
	#tag : 'Woden'
}

{ #category : 'instance creation' }
MyContextMenuSelection class >> on: aPresenter [

	^ self new
		  presenter: aPresenter;
		  yourself
]

{ #category : 'selection' }
MyContextMenuSelection >> applyVisualTo: aNode [
	"Replaces the node's renderables with yellow unlit copies to indicate selection."

	selectedOriginalRenderables := aNode renderables.
	aNode renderables: (selectedOriginalRenderables collect: [ :each | each copyWithMaterial: self selectionMaterial ])
]

{ #category : 'selection' }
MyContextMenuSelection >> clear [
	"Restores selected visuals and clears selection state."

	self restoreVisual.
	self forget.
	presenter refreshScene
]

{ #category : 'selection' }
MyContextMenuSelection >> forget [
	"Clears selection state without touching scene visuals."

	selectedRenderedShape := nil.
	selectedOriginalRenderables := nil
]

{ #category : 'accessing' }
MyContextMenuSelection >> presenter: aPresenter [

	presenter := aPresenter
]

{ #category : 'selection' }
MyContextMenuSelection >> restoreVisual [
	"Puts the originally saved renderables back on the selected node."

	selectedRenderedShape ifNil: [ ^ self ].
	selectedOriginalRenderables ifNil: [ ^ self ].

	selectedRenderedShape node renderables: selectedOriginalRenderables.
	selectedOriginalRenderables := nil
]

{ #category : 'selection' }
MyContextMenuSelection >> selectFrom: pickedEntries [
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
MyContextMenuSelection >> selectedNode [
	"Returns the scene node of the currently selected entry, or nil if nothing is selected."

	^ selectedRenderedShape ifNil: [ nil ] ifNotNil: [ selectedRenderedShape node ]
]

{ #category : 'accessing' }
MyContextMenuSelection >> selectedRenderedShape [

	^ selectedRenderedShape
]

{ #category : 'geometry' }
MyContextMenuSelection >> selectedRotationCenter [
	"Returns the visible world-space center of the selected rendered node."

	| node box |
	selectedRenderedShape ifNil: [ ^ Vector3 x: 0 y: 0 z: 0 ].

	node := selectedRenderedShape node.
	box := node localBoundingBox transformedWith: node globalTransform.

	^ box center
]

{ #category : 'accessing' }
MyContextMenuSelection >> selectedShape [
	"Returns the MyShape of the currently selected entry, or nil if nothing is selected."

	^ selectedRenderedShape ifNil: [ nil ] ifNotNil: [ selectedRenderedShape shape ]
]

{ #category : 'accessing' }
MyContextMenuSelection >> selectionMaterial [
	"Returns a yellow unlit material used to highlight the selected object."

	^ WDUnlitMaterial new
		  colorFactor: Color yellow;
		  yourself
]
