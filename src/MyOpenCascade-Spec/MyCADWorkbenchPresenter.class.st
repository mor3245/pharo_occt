Class {
	#name : 'MyCADWorkbenchPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'mainMenuBar',
		'viewportPresenter',
		'geometryTree',
		'updatingGeometryTree',
		'taskPanel',
		'propertyPanel'
	],
	#category : 'MyOpenCascade-Spec',
	#package : 'MyOpenCascade-Spec'
}

{ #category : 'layout' }
MyCADWorkbenchPresenter class >> defaultLayout [

	^ self layoutWithoutTaskPanel
]

{ #category : 'layout' }
MyCADWorkbenchPresenter class >> layoutWithTaskPanel [

	^ SpBoxLayout newVertical
		  add: #mainMenuBar withConstraints: [ :constraints | constraints height: self toolbarHeight ];
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 1 / 5;
				   add: (self leftPanelLayout);
				   add: (SpPanedLayout newHorizontal
						    positionOfSlider: 3 / 4;
						    add: #viewportPresenter;
						    add: #taskPanel;
						    yourself);
				   yourself);
		  yourself
]

{ #category : 'layout' }
MyCADWorkbenchPresenter class >> layoutWithoutTaskPanel [

	^ SpBoxLayout newVertical
		  add: #mainMenuBar withConstraints: [ :constraints | constraints height: self toolbarHeight ];
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 1 / 5;
				   add: self leftPanelLayout;
				   add: #viewportPresenter;
				   yourself);
		  yourself
]

{ #category : 'layout' }
MyCADWorkbenchPresenter class >> leftPanelLayout [

	^ SpPanedLayout newVertical
		  positionOfSlider: 2 / 3;
		  add: #geometryTree;
		  add: #propertyPanel;
		  yourself
]

{ #category : 'actions - edit' }
MyCADWorkbenchPresenter >> actionClearSelection [

	viewportPresenter clearSelection
]

{ #category : 'actions - edit' }
MyCADWorkbenchPresenter >> actionDeleteSelected [

	viewportPresenter deleteSelected
]

{ #category : 'actions - file' }
MyCADWorkbenchPresenter >> actionExit [

	self withWindowDo: [ :window | window close ]
]

{ #category : 'actions - file' }
MyCADWorkbenchPresenter >> actionImportBRep [

	StOpenFilePresenter new
		application: self application;
		openFolder: FileLocator workingDirectory;
		filter: (StCustomExtensionsFilter extensions: #( 'brep' ));
		title: 'Import BREP';
		okAction: [ :fileReference | viewportPresenter addShapeFromFile: fileReference ];
		openModal
]

{ #category : 'actions - file' }
MyCADWorkbenchPresenter >> actionNew [

	viewportPresenter clearAllShapes
]

{ #category : 'actions - edit' }
MyCADWorkbenchPresenter >> actionRenameSelected [

	viewportPresenter renameSelectedShape
]

{ #category : 'actions - file' }
MyCADWorkbenchPresenter >> actionSaveSelectedBRep [

	| selectedShape |
	selectedShape := viewportPresenter selectedShape.
	selectedShape ifNil: [ ^ self ].

	StSaveFilePresenter new
		application: self application;
		defaultFolder: FileLocator workingDirectory;
		filter: (StCustomExtensionsFilter extensions: #( 'brep' ));
		nameText: selectedShape name , '.brep';
		title: 'Export Selected BREP';
		okAction: [ :fileReference | viewportPresenter saveSelectedShapeTo: fileReference ];
		openModal
]

{ #category : 'menus' }
MyCADWorkbenchPresenter >> buildMainMenuBar [

	^ self newMenuBar
		  addGroup: [ :group |
				  group
					  addItem: [ :item |
							  item
								  name: 'File';
								  subMenu: self fileMenu ];
					  addItem: [ :item |
							  item
								  name: 'Edit';
								  subMenu: self editMenu ] ];
		  yourself
]

{ #category : 'menus' }
MyCADWorkbenchPresenter >> editMenu [

	^ self newMenu
		  addGroup: [ :group |
				  group
					  addItem: [ :item |
							  item
								  name: 'Rename Selected';
								  action: [ self actionRenameSelected ] ];
					  addItem: [ :item |
							  item
								  name: 'Delete Selected';
								  icon: (self iconNamed: #smallDeleteIcon);
								  shortcut: KeyboardKey delete asKeyCombination;
								  action: [ self actionDeleteSelected ] ];
					  addItem: [ :item |
							  item
								  name: 'Clear Selection';
								  action: [ self actionClearSelection ] ] ];
		  yourself
]

{ #category : 'menus' }
MyCADWorkbenchPresenter >> fileMenu [

	^ self newMenu
		  addGroup: [ :group |
				  group
					  addItem: [ :item |
							  item
								  name: 'New';
								  shortcut: $n command mac | $n control unix | $n control win;
								  action: [ self actionNew ] ];
					  addItem: [ :item |
							  item
								  name: 'Import BREP...';
								  icon: (self iconNamed: #openIcon);
								  shortcut: $o command mac | $o control unix | $o control win;
								  action: [ self actionImportBRep ] ];
					  addItem: [ :item |
							  item
								  name: 'Export Selected BREP...';
								  icon: (self iconNamed: #smallSaveAsIcon);
								  shortcut: $s command mac | $s control unix | $s control win;
								  action: [ self actionSaveSelectedBRep ] ] ];
		  addGroup: [ :group |
				  group addItem: [ :item |
						  item
							  name: 'Exit';
							  action: [ self actionExit ] ] ];
		  yourself
]

{ #category : 'initialization' }
MyCADWorkbenchPresenter >> initializePresenters [

	super initializePresenters.

	updatingGeometryTree := false.
	viewportPresenter := self instantiate: MyCADViewportPresenter.
	taskPanel := self instantiate: MyCADTransformPanelPresenter.
	mainMenuBar := self buildMainMenuBar.
	geometryTree := self newTreeTable.
	geometryTree
		addColumn: (SpStringTableColumn title: 'Geometry' evaluated: [ :cadObject | cadObject name ]);
		children: [ :cadObject | #(  ) ];
		beSingleSelection;
		whenSelectionChangedDo: [ :treeSelection |
			updatingGeometryTree ifFalse: [ viewportPresenter selectCADObject: treeSelection selectedItem ] ].

	propertyPanel := self instantiate: MyCADPropertyPanelPresenter.
	propertyPanel whenDimensionsChangedDo: [ :length :width :height |
		self resizeSelectedDimensionsLength: length width: width height: height ].

	viewportPresenter
		whenGeometryChangedDo: [ self updateGeometryTree ];
		whenSelectionChangedDo: [ self updateGeometryTreeSelection ];
		whenTransformModeChangedDo: [ :mode | self transformModeChanged: mode ];
		whenVisualChangedDo: [ self updatePropertyPanel ].

	taskPanel
		whenPreviewChangedDo: [ :translation | viewportPresenter previewTranslation: translation ];
		whenAcceptDo: [
				viewportPresenter confirmTranslationMode.
				self updatePropertyPanel ];
		whenCancelDo: [
				viewportPresenter cancelTranslationMode.
				self updatePropertyPanel ].

	self updateGeometryTree.
	self updatePropertyPanel
]

{ #category : 'initialization' }
MyCADWorkbenchPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'MyCAD';
		initialExtent: 1024 @ 768;
		whenOpenedDo: [ viewportPresenter setupContextMenu ]
]

{ #category : 'units' }
MyCADWorkbenchPresenter >> millimetersToModelUnits: aNumber [

	^ aNumber * taskPanel modelUnitsPerMillimeter
]

{ #category : 'units' }
MyCADWorkbenchPresenter >> modelUnitsToMillimeters: aNumber [

	^ aNumber / taskPanel modelUnitsPerMillimeter
]

{ #category : 'updating' }
MyCADWorkbenchPresenter >> resizeSelectedDimensionsLength: length width: width height: height [

	viewportPresenter resizeSelectedCADObjectToDimensions: (Vector3
			 x: (self millimetersToModelUnits: length)
			 y: (self millimetersToModelUnits: width)
			 z: (self millimetersToModelUnits: height)).
	self updatePropertyPanel
]

{ #category : 'updating' }
MyCADWorkbenchPresenter >> transformModeChanged: mode [

	mode = #translation
		ifTrue: [
				self layout: self class layoutWithTaskPanel.
				taskPanel activateForTranslation ]
		ifFalse: [
				taskPanel deactivate.
				self layout: self class layoutWithoutTaskPanel ].
	viewportPresenter setupContextMenu
]

{ #category : 'updating' }
MyCADWorkbenchPresenter >> updateGeometryTree [

	updatingGeometryTree := true.
	[
		geometryTree roots: (viewportPresenter visibleCADObjects).
		self updateGeometryTreeSelection ] ensure: [ updatingGeometryTree := false ]
]

{ #category : 'updating' }
MyCADWorkbenchPresenter >> updateGeometryTreeSelection [

	| selectedShape wasUpdating |
	wasUpdating := updatingGeometryTree.
	updatingGeometryTree := true.
	[
		selectedShape := viewportPresenter selectedCADObject.
		(selectedShape notNil and: [ selectedShape isAlive not ]) ifTrue: [ selectedShape := nil ].
		selectedShape ifNil: [ geometryTree unselectAll ] ifNotNil: [ geometryTree selectItems: { selectedShape } ].
		self updatePropertyPanel ] ensure: [ updatingGeometryTree := wasUpdating ]
]

{ #category : 'updating' }
MyCADWorkbenchPresenter >> updatePropertyPanel [

	| cadObject position dimensions |
	cadObject := viewportPresenter selectedCADObject.
	(cadObject isNil or: [ cadObject isAlive not ]) ifTrue: [
			propertyPanel clear.
			^ self ].

	position := cadObject displayPosition.
	dimensions := cadObject editableDimensions.
	propertyPanel
		showCADObject: cadObject
		placementMillimeters: (Vector3
				 x: (self modelUnitsToMillimeters: position x)
				 y: (self modelUnitsToMillimeters: position y)
				 z: (self modelUnitsToMillimeters: position z))
		dimensionsMillimeters: (Vector3
				 x: (self modelUnitsToMillimeters: dimensions x)
				 y: (self modelUnitsToMillimeters: dimensions y)
				 z: (self modelUnitsToMillimeters: dimensions z))
]

{ #category : 'accessing' }
MyCADWorkbenchPresenter >> viewportPresenter [

	^ viewportPresenter
]
