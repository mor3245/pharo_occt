Class {
	#name : 'BaselineOfPharoOCCT',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfPharoOCCT',
	#package : 'BaselineOfPharoOCCT'
}

{ #category : 'baselines' }
BaselineOfPharoOCCT >> baseline: spec [
	<baseline>

	spec for: #common do: [
		spec
			baseline: 'WodenSceneGraph'
				with: [
					spec
						repository: 'github://mor3245/woden-core-scene-graph:master' ];
			package: 'LibImports-UFFI-CWrap';
			package: 'MyOpenCascade'
				with: [ spec requires: #( 'LibImports-UFFI-CWrap' ) ];
			package: 'MyOpenCascade-Rendering'
				with: [ spec requires: #( 'MyOpenCascade' 'WodenSceneGraph' ) ];
			package: 'MyOpenCascade-Model'
				with: [ spec requires: #( 'MyOpenCascade' 'MyOpenCascade-Rendering' ) ];
			package: 'MyOpenCascade-Spec'
				with: [ spec requires: #( 'MyOpenCascade-Model' 'MyOpenCascade-Rendering' 'WodenSceneGraph' ) ];
			package: 'MyOpenCascade-API-Test'
				with: [ spec requires: #( 'MyOpenCascade' ) ];
			package: 'MyOpenCascade-CAD-GUI-Test'
				with: [ spec requires: #( 'MyOpenCascade-Spec' ) ].

		spec
			group: 'Core' with: #( 'LibImports-UFFI-CWrap' 'MyOpenCascade' );
			group: 'Rendering' with: #( 'MyOpenCascade-Rendering' );
			group: 'Model' with: #( 'MyOpenCascade-Model' );
			group: 'UI' with: #( 'MyOpenCascade-Spec' );
			group: 'API Tests' with: #( 'MyOpenCascade-API-Test' );
			group: 'CAD GUI Tests' with: #( 'MyOpenCascade-CAD-GUI-Test' );
			group: 'Tests' with: #( 'API Tests' 'CAD GUI Tests' );
			group: 'default' with: #( 'Core' 'Rendering' 'Model' 'UI' 'Tests' );
			group: 'all' with: #( 'default' ) ].
]
