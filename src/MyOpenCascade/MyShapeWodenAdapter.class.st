Class {
	#name : 'MyShapeWodenAdapter',
	#superclass : 'Object',
	#category : 'MyOpenCascade-Woden',
	#package : 'MyOpenCascade',
	#tag : 'Woden'
}

{ #category : 'converting' }
MyShapeWodenAdapter >> asWDMesh: aShape [
    | verts norms tris builder |
    verts := aShape vertices.
    norms := aShape normals.
    tris  := aShape triangles.

    builder := WDMeshBuilder new.
    builder beginTriangles.

    "add vertices and normals"
    0 to: aShape vertexCount - 1 do: [:i |
        builder
            addPx: (verts at: i*3 + 1)
             y: (verts at: i*3 + 2)
             z: (verts at: i*3 + 3).
        builder
            addNx: (norms at: i*3 + 1)
             y: (norms at: i*3 + 2)
             z: (norms at: i*3 + 3).
    ].

    "add triangles"
    0 to: aShape triangleCount - 1 do: [:i |
        builder
            addTriangleI0: (tris at: i*3 + 1)
            i1: (tris at: i*3 + 2)
            i2: (tris at: i*3 + 3).
    ].

    ^ builder mesh
]
