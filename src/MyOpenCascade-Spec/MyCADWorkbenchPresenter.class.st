Class {
	#name : 'MyCADWorkbenchPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'viewportPresenter',
		'geometryTree',
		'updatingGeometryTree'
	],
	#category : 'MyOpenCascade-Spec',
	#package : 'MyOpenCascade-Spec'
}

{ #category : 'layout' }
MyCADWorkbenchPresenter class >> defaultLayout [

	^ SpPanedLayout newHorizontal
		  positionOfSlider: 1 / 5;
		  add: #geometryTree;
		  add: #viewportPresenter;
		  yourself
]

{ #category : 'initialization' }
MyCADWorkbenchPresenter >> initializePresenters [

	super initializePresenters.

	updatingGeometryTree := false.
	viewportPresenter := self instantiate: MyCADViewportPresenter.
	geometryTree := self newTreeTable.
	geometryTree
		addColumn: (SpStringTableColumn title: 'Geometry' evaluated: [ :renderedShape | renderedShape name ]);
		children: [ :renderedShape | #(  ) ];
		beSingleSelection;
		whenSelectionChangedDo: [ :treeSelection |
			updatingGeometryTree ifFalse: [ viewportPresenter selectRenderedShape: treeSelection selectedItem ] ].

	viewportPresenter
		whenGeometryChangedDo: [ self updateGeometryTree ];
		whenSelectionChangedDo: [ self updateGeometryTreeSelection ].

	self updateGeometryTree
]

{ #category : 'initialization' }
MyCADWorkbenchPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'MyCAD';
		initialExtent: 1024 @ 768;
		whenOpenedDo: [ viewportPresenter setupContextMenu ]
]

{ #category : 'updating' }
MyCADWorkbenchPresenter >> updateGeometryTree [

	updatingGeometryTree := true.
	[
		geometryTree roots: viewportPresenter renderedShapes.
		self updateGeometryTreeSelection ] ensure: [ updatingGeometryTree := false ]
]

{ #category : 'updating' }
MyCADWorkbenchPresenter >> updateGeometryTreeSelection [

	| selectedShape wasUpdating |
	wasUpdating := updatingGeometryTree.
	updatingGeometryTree := true.
	[
		selectedShape := viewportPresenter selectedRenderedShape.
		selectedShape ifNil: [ geometryTree unselectAll ] ifNotNil: [ geometryTree selectItems: { selectedShape } ] ] ensure: [
		updatingGeometryTree := wasUpdating ]
]

{ #category : 'accessing' }
MyCADWorkbenchPresenter >> viewportPresenter [

	^ viewportPresenter
]
