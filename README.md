# Pharo OCCT

Pharo OCCT is a Pharo/OpenCascade experiment for building and viewing CAD
shapes from Smalltalk. The repository contains:

- low-level UFFI bindings to the native OpenCascade C wrapper
- Smalltalk wrappers for OCCT shapes and primitive makers
- a CAD document model
- a Woden rendering bridge
- Spec presenters for the MyCAD workbench

## Install

Load the baseline from a Pharo Playground:

```smalltalk
Metacello new
  baseline: 'PharoOCCT';
  repository: 'github://mor3245/pharo_occt:master/src';
  onConflictUseIncoming;
  load.
```

The Playground should evaluate the script and show the loaded baseline state:

| Before | After |
| --- | --- |
| ![Pharo Playground before loading the PharoOCCT baseline](docs/images/install-before.png) | ![Pharo Playground after loading the PharoOCCT baseline](docs/images/install-after.png) |

The baseline loads the application packages and depends on the Woden scene graph
fork at:

```text
github://mor3245/woden-core-scene-graph:master
```

## Native Libraries

The OpenCascade wrapper is a native DLL. Keep the wrapper DLL and its dependent
OpenCascade DLLs beside the Pharo image:

```text
<image directory>/my_occt_c_wrapper.dll
<image directory>/TKBRep.dll
<image directory>/TKPrim.dll
<image directory>/TKernel.dll
...
```

This avoids installing the DLLs OS-wide and matches the Windows loader behavior
used by the working images. If `my_occt_c_wrapper.dll` is moved into a nested
folder without also configuring the DLL search path, Windows may find the wrapper
but fail to load one of its dependent DLLs.

To check the path Pharo will use:

```smalltalk
MyOCPStLib uniqueInstance win32LibraryName
```

## Open The Workbench

After loading the baseline and placing the native DLLs, open the workbench from
the Pharo world menu:

![Pharo Library menu showing the Pharo CAD command](docs/images/open-workbench-menu.png)

Choose `Library > Pharo CAD` to start the MyCAD workbench. The workbench can
create box and cylinder primitives, import and export BREP files, select
objects, edit primitive dimensions, and apply transforms.

## Package Layout

- `LibImports-UFFI-CWrap`: native library lookup for the C wrapper
- `MyOpenCascade`: low-level OCCT/UFFI wrapper objects
- `MyOpenCascade-Rendering`: OCCT shape to Woden scene bridge
- `MyOpenCascade-Model`: CAD document and object model
- `MyOpenCascade-Spec`: Spec UI presenters
- `MyOpenCascade-UFFI-Test`: native wrapper tests
- `BaselineOfPharoOCCT`: Metacello baseline
