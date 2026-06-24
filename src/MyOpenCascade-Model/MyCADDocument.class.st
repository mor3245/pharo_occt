"
I am the CAD document model for the workbench.

I own CAD objects, not Woden nodes. During the current migration each CAD object
still wraps a MyRenderedShape, but presenters should talk to this document layer
instead of treating rendered nodes as document objects.
"
Class {
	#name : 'MyCADDocument',
	#superclass : 'Object',
	#instVars : [
		'objects'
	],
	#category : 'MyOpenCascade-Model',
	#package : 'MyOpenCascade-Model'
}

{ #category : 'adding' }
MyCADDocument >> addObject: aCADObject [

	objects addLast: aCADObject.
	^ aCADObject
]

{ #category : 'removing' }
MyCADDocument >> clear [

	objects removeAll
]

{ #category : 'initialization' }
MyCADDocument >> initialize [

	super initialize.
	objects := OrderedCollection new
]

{ #category : 'accessing' }
MyCADDocument >> objectForRenderedShape: aRenderedShape [

	aRenderedShape ifNil: [ ^ nil ].
	^ objects
		  detect: [ :each | each renderedShape == aRenderedShape ]
		  ifNone: [ nil ]
]

{ #category : 'accessing' }
MyCADDocument >> objects [

	^ objects asArray
]

{ #category : 'removing' }
MyCADDocument >> removeObject: aCADObject [

	objects remove: aCADObject ifAbsent: [ ]
]

{ #category : 'replacing' }
MyCADDocument >> replaceObject: oldObject withAll: newObjects [

	| oldIndex oldObjects |
	oldIndex := objects indexOf: oldObject ifAbsent: [ 0 ].
	oldIndex = 0 ifTrue: [
			objects addAll: newObjects.
			^ self ].

	oldObjects := objects asArray.
	objects removeAll.
	1 to: oldIndex - 1 do: [ :index | objects addLast: (oldObjects at: index) ].
	objects addAll: newObjects.
	oldIndex + 1 to: oldObjects size do: [ :index | objects addLast: (oldObjects at: index) ]
]
