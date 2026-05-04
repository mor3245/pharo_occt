Class {
	#name : 'MyContextMenuPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'wodenPresenter',
		'scene',
		'meshNodes'
	],
	#category : 'MyOpenCascade-UFFI',
	#package : 'MyOpenCascade-UFFI'
}

{ #category : 'as yet unclassified' }
MyContextMenuPresenter >> addBox [

	| shape mesh node |
	shape := (MyBoxMaker
		          tessellatedBoxDx: 1
		          dy: 1
		          dz: 1
		          deflection: 0.01).
	mesh := shape asWDMesh.
	node := mesh asSceneNode.

	scene add: node.
	meshNodes addLast: node -> shape.

	wodenPresenter adapter widget changed
]

{ #category : 'as yet unclassified' }
MyContextMenuPresenter >> buildContextMenu [

	^ SpMenuPresenter new addGroup: [ :group |
			  group addItem: [ :item |
					  item
						  name: 'Add Box';
						  action: [ self addBox ] ] ;
					addItem: [ :item |
						item
							name: 'Delete Box';
							action: [ self deleteBox ] ]
					
					
					] yourself
]

{ #category : 'as yet unclassified' }
MyContextMenuPresenter >> buildScene [

	"| mesh light lightNode |"
	| light lightNode |
	scene := WDScene new.

	"mesh := (MyBoxMaker
		         tessellatedBoxDx: 1
		         dy: 1
		         dz: 1
		         deflection: 0.01) asWDMesh."

	light := WDPointLightSource new
		         intensity: 5.0;
		         yourself.
	lightNode := light asSceneNode.
	lightNode position: (Vector3 x: -1.5 y: 1.5 z: 1.0).

	"scene add: mesh."
	scene add: lightNode.
	^ scene
]

{ #category : 'layout' }
MyContextMenuPresenter >> defaultLayout [ 

	^ SpBoxLayout newTopToBottom 
		add: wodenPresenter ;
		yourself
]

{ #category : 'as yet unclassified' }
MyContextMenuPresenter >> deleteBox [

	| entry |
	meshNodes ifEmpty: [ ^ self ].

	entry := meshNodes removeLast.
	scene remove: entry key.
	entry value free.

	wodenPresenter adapter widget changed
]

{ #category : 'as yet unclassified' }
MyContextMenuPresenter >> handleMouseEvent: anEvent [

	Transcript
		nextPutAll: 'Mouse button: ';
		nextPutAll: anEvent whichButton asString;
		cr.
	( anEvent yellowButtonPressed ) ifFalse: [ ^ self ].
	Transcript
		nextPutAll: 'Right-click detected - showing menu';
		cr.
	self showContextMenuAt: anEvent position
]

{ #category : 'initialization' }
MyContextMenuPresenter >> initializePresenters [

	super initializePresenters.

	meshNodes := OrderedCollection new.
	scene := self buildScene.

	wodenPresenter := self instantiate: WDSpInteractiveScenePresenter.
	wodenPresenter
		scene: scene;
		camera: (WDCamera new asSceneNode position: (Vector3 x: 0 y: 0 z: 3))
]

{ #category : 'initialization' }
MyContextMenuPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'Woden Render Area';
		initialExtent: 650 @ 500.

	aWindowPresenter whenOpenedDo: [ self setupContextMenu ]
]

{ #category : 'as yet unclassified' }
MyContextMenuPresenter >> openWithContextMenu [

	self open.
	self withWindowDo: [ :widnow | self setupContextMenu ]
]

{ #category : 'as yet unclassified' }
MyContextMenuPresenter >> setupContextMenu [

	| widget |
	widget := wodenPresenter adapter widget.
	widget ifNil: [ ^ self ].
	
	Transcript
		nextPutAll: 'Setting up context menu on: ';
		nextPutAll: widget asString;
		cr.
		
	widget on: #mouseDown send: #handleMouseEvent: to: self
]

{ #category : 'accessing' }
MyContextMenuPresenter >> showContextMenuAt: aPoint [

	| menu |
	menu := self buildContextMenu.
	menu openWithSpecAt: aPoint
]
