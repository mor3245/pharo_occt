Class {
	#name : 'MyShapeTopologyInspectionTest',
	#superclass : 'TestCase',
	#category : 'MyOpenCascade-API-Test',
	#package : 'MyOpenCascade-API-Test'
}

{ #category : 'tests' }
MyShapeTopologyInspectionTest >> testClearTopologyInspectionDataRemovesCachedChildren [

	| shape |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.

	[
		shape refreshTopologyForInspectionDepth: 1.
		self deny: shape topologyChildrenForInspection isEmpty.

		shape clearTopologyInspectionData.
		self deny: shape hasTopologyInspectionData.
		self assert: shape topologyChildrenForInspection isEmpty ] ensure: [ shape free ]
]

{ #category : 'tests' }
MyShapeTopologyInspectionTest >> testDepthZeroRefreshPopulatesCountsOnly [

	| shape |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.

	[
		shape refreshTopologyForInspectionDepth: 0.
		self assert: shape hasTopologyInspectionData.
		self assert: shape topologyChildrenForInspection isEmpty ] ensure: [ shape free ]
]

{ #category : 'tests' }
MyShapeTopologyInspectionTest >> testSeparatedSolidsOfSimpleBoxAnswersNamedSolid [

	| shape solids |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1 named: 'Base Box'.

	[
		solids := shape separatedSolids.
		self assert: solids size equals: 1.
		self assert: solids first class equals: MyShape.
		self assert: solids first name equals: 'Base Box' ] ensure: [
			solids ifNotNil: [ solids do: [ :each | each free ] ].
			shape free ]
]

{ #category : 'tests' }
MyShapeTopologyInspectionTest >> testTopologyAliasesReuseCachedSubshapes [

	| shape faces edges vertices |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.

	[
		faces := shape faces.
		edges := shape edges.
		vertices := shape topologicalVertices.

		self assert: shape topologicalFaces == faces.
		self assert: shape topologicalEdges == edges.
		self assert: shape topologicalVertices == vertices ] ensure: [
			faces ifNotNil: [ faces do: [ :each | each free ] ].
			edges ifNotNil: [ edges do: [ :each | each free ] ].
			vertices ifNotNil: [ vertices do: [ :each | each free ] ].
			shape free ]
]

{ #category : 'tests' }
MyShapeTopologyInspectionTest >> testTopologyCacheIsClearedAfterTransform [

	| shape |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.

	[
		shape refreshTopologyForInspectionDepth: 0.
		self assert: shape hasTopologyInspectionData.
		shape translateBy: (Vector3 x: 1 y: 2 z: 3).
		self deny: shape hasTopologyInspectionData ] ensure: [ shape free ]
]

{ #category : 'tests' }
MyShapeTopologyInspectionTest >> testTopologyInspectionAnswersTypedSubshapes [

	| shape solids faces edges vertices |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.

	[
		solids := shape solids.
		faces := shape faces.
		edges := shape edges.
		vertices := shape topologicalVertices.

		self assert: solids size equals: 1.
		self assert: faces size equals: 6.
		self assert: edges size equals: 12.
		self assert: vertices size equals: 8.
		self assert: (solids allSatisfy: [ :each | each class = MySolid ]).
		self assert: (faces allSatisfy: [ :each | each class = MyFace ]).
		self assert: (edges allSatisfy: [ :each | each class = MyEdge ]).
		self assert: (vertices allSatisfy: [ :each | each class = MyVertex ]) ] ensure: [
			solids ifNotNil: [ solids do: [ :each | each free ] ].
			faces ifNotNil: [ faces do: [ :each | each free ] ].
			edges ifNotNil: [ edges do: [ :each | each free ] ].
			vertices ifNotNil: [ vertices do: [ :each | each free ] ].
			shape free ]
]

{ #category : 'tests' }
MyShapeTopologyInspectionTest >> testTopologyInspectionSubshapesAreNotPersisted [
	"Inspection-only faces must not create independent BREP files."

	| shape faces |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.

	[
		faces := shape faces.
		self deny: faces isEmpty.
		self assert: (faces allSatisfy: [ :face | face storagePath isNil ]) ] ensure: [
			faces ifNotNil: [ faces do: [ :face | face free ] ].
			shape free ]
]

{ #category : 'tests' }
MyShapeTopologyInspectionTest >> testUnsupportedSubshapeTypeAnswersEmptyCollection [

	| shape |
	shape := MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1.

	[
		self assert: (shape subshapesOfType: 999 as: MyShape) isEmpty ] ensure: [ shape free ]
]
