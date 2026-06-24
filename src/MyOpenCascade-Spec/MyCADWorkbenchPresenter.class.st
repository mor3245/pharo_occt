Class {
	#name : 'MyCADWorkbenchPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'mainMenuBar',
		'viewportPresenter',
		'geometryTree',
		'updatingGeometryTree',
		'taskPanel',
		'propertyTable'
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

{ #category : 'as yet unclassified' }
MyCADWorkbenchPresenter class >> leftPanelLayout [

	^ SpPanedLayout newVertical
		  positionOfSlider: 2 / 3;
		  add: #geometryTree;
		  add: #propertyTable;
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
		addColumn: (SpStringTableColumn title: 'Geometry' evaluated: [ :renderedShape | renderedShape name ]);
		children: [ :renderedShape | #(  ) ];
		beSingleSelection;
		whenSelectionChangedDo: [ :treeSelection |
			updatingGeometryTree ifFalse: [ viewportPresenter selectRenderedShape: treeSelection selectedItem ] ].

	propertyTable := self newTreeTable.
	propertyTable
		addColumn: (SpStringTableColumn title: 'Property' evaluated: [ :association | association key ]);
		addColumn: (SpStringTableColumn title: 'Value' evaluated: [ :association | association value ]);
		children: [ :association | #(  ) ];
		beSingleSelection.

	viewportPresenter
		whenGeometryChangedDo: [ self updateGeometryTree ];
		whenSelectionChangedDo: [ self updateGeometryTreeSelection ];
		whenTransformModeChangedDo: [ :mode | self transformModeChanged: mode ];
		whenVisualChangedDo: [ self updatePropertyTable ].

	taskPanel
		whenPreviewChangedDo: [ :translation | viewportPresenter previewTranslation: translation ];
		whenAcceptDo: [
				viewportPresenter confirmTranslationMode.
				self updatePropertyTable ];
		whenCancelDo: [
				viewportPresenter cancelTranslationMode.
				self updatePropertyTable ].

	self updateGeometryTree.
	self updatePropertyTable
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
MyCADWorkbenchPresenter >> modelUnitsToMillimeters: aNumber [

	^ aNumber / taskPanel modelUnitsPerMillimeter
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
		selectedShape ifNil: [ geometryTree unselectAll ] ifNotNil: [ geometryTree selectItems: { selectedShape } ].
		self updatePropertyTable ] ensure: [ updatingGeometryTree := wasUpdating ]
]

{ #category : 'updating' }
MyCADWorkbenchPresenter >> updatePropertyTable [

	| renderedShape propertiesTemp position |
	renderedShape := viewportPresenter selectedRenderedShape.
	renderedShape ifNil: [
			propertyTable roots: #(  ).
			^ self ].

	position := renderedShape displayPosition.
	propertiesTemp := OrderedCollection new.
	propertiesTemp
		add: 'Name' -> renderedShape name;
		add: 'Type' -> renderedShape shape class name;
		add: 'U position (mm)' -> (self modelUnitsToMillimeters: position x) asString;
		add: 'V position (mm)' -> (self modelUnitsToMillimeters: position y) asString;
		add: 'W position (mm)' -> (self modelUnitsToMillimeters: position z) asString;
		add: 'Triangles' -> renderedShape shape triangleCount asString;
		add: 'Vertices' -> renderedShape shape vertexCount asString.

	propertyTable roots: propertiesTemp asArray
]

{ #category : 'accessing' }
MyCADWorkbenchPresenter >> viewportPresenter [

	^ viewportPresenter
]
