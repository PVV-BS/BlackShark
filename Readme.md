Black Shark Graphics Engine is a simple 2D and 3D engine written in Pascal for developers to produce applications utilising hardware-accelerated graphics. It supports Lazarus (v. >= 2.0) and Delphi (Community Edition 10.3, another versions haven't been tested).
It's a young, a freely available, project that currently has a vector of development in the 2D area. Beside, if you want, you can create 3D objects (see tests example TBSTestMesh, TBSTestEarth in a unit bs.test.mesh.pas). A main purpose of the project is creating the simplest entities for simple access to OpenGL API abilities within of version >= ES2.

[shark.org](https://bshark.org/)  
[Repository](https://github.com/PVV-BS/BlackShark)  
[Telegram channel](https://t.me/BSharkGE)  

### 06.02.22  
###   Version 3.02:  
	+ improve TPath:  
		+ a support of multi color;  
		+ draws strokes if to set property StrokeLength > 0;  
		+ because of it changes in TPath, TPathMultiColored was marked as deprecated;  
	+ BSConfig.MaxFPS switched on for "tests/delphi/VCL/AppTestVCL" and "tests/lazarus/LazTests" projects;  
	+ now default behavior for TBlackSharkViewport - if BSConfig.MaxFPS is switched off then redraw occurs only when it receives events from OS.  


### 17.01.22  
###   Version 3.0:  
	+ all dependencies on LCL/VCL/FMX were removed from all units, for except "bs.viewport"  
	+ a new pure Black Shark application (see examples "/tests/delphi/BSApplication" and "/tests/lazarus/BSApplication"); it is also supported by delphi for linux target compilation;  
	+ a new own system of windows (see example "bs.test.windows.TBSTestWindows" through command line parameters in "BSApplicatoin");  
	+ a performance was improved for applications based on TBlackSharkViewPort (LCL/VCL);  
	+ a new own decoder of PNG images;  
	+ automatically support of 32-bit indexes was added for the mesh (for high polygonal meshes); if amount indexes to occur more 65536, then buffer indexes translates from 16-bit to 32-bit format;  
	+ bs.font - range errors were fixed (appeared in mode compiling "Range check error");  
	+ a new property "bs.renderer.TBlackSharkRenderer.FPS";  
	+ improve performance for TPath and its descendants: a path with thickness 1 pixel draws through GL_LINE_STRIP;  
	+ bs.align - a fix for right/bottom anchor;  
	+ https://t.me/BSharkGE  

### 05.10.2021  
###   Version 2.02:  
    + loader of 3d-scenes and 3d-objects for COLLADA free specification (for example see TBSTestCollada);  
    + implementation of skeletal animation;  
    + instancing 2d primitives implemented by TBlackSharkInstancing2d (for example see TBSTestInstancing2d);  
    + itself color was linked for an every instance in bs.instancing.TBlackSharkInstancing;  
    + in bs.canvas.TArc:  
      + a new porperty bs.canvas.TArc.Position2dCenter;  
      + a new property TArc.InterpolateFactor; it allows to adjust degree of smoothing;  
    + in bs.canvas.TPath:  
      + added a possibility to draw by arc (for example see TBSTestCanvasPathArc);  
      + a new property of curve smoothing InterpolateFactor;  
    + a new class TPathMultiColored - the path in which can set itself color for an every point;  
    + in TBSTest:  
      + possibility to move camera and key events;  
      + virtual methods for mouse input;  
      + added new actions above the camera by mouse: rotate and move;  
      + added a new property Allow3dManipulationByMouse;  
    + platform-dependent binary resources were divided by directory;  
    + new approach for using of shaders - selection of uniforms when they assigned to object instead explicit type conversion of the shader and get need uniform;  
    + new virtual method in bs.shader.TBlackSharkShader.DefaultName; it allows don't remember a name of a file for every shader;  
    + TheXmlWriter - a few bugfixes;  
  
### 15.05.2021  
###   Minor version 2.01:  
    + TBSpinEdit, TBScrollBar - added pending scroll (begins in second after hold a button);  
    + egl initialization fixed (EGLint define was wrong in header);  
    - remove wgl;  
    + TBCustomTable - generic method was removed because FPC 3.2.0 couldn't to compile it, only FPC 3.2.1;  
    + TBCustomTable - wrong motion of cursor of selection moved by keyboard (up/down) was fixed;  
    + TBCheckBox - remove very bad forgotten line;  
    + TBlackSharkKDTree - min and max boundary reduced to (-max(single); max(single)), otherwise FPC couldn't to copy limit values from double to single;  
    + new multisampling option: BSConfig.MultiSamplingSamples;  
    + improve KD-tree test: added motion of objects, option of drawing of nodes the tree in every second, help-panel;   
    + TBSTestScrollBox - brought back to normal state;  
    - TBSTestMemo, TBSTestTrueTypeSmiles - excluded until because are not ready (TBSTestTrueTypeSmiles on Linux);  
  
### 02.05.2021  
###   New version 2.0:  
    + license agreement was changed from custom on free LGPL;  
    + a support of hardware multisampling was added;  
    + FMX viewport support was added, I ran it only, while is not tested widely yet;  
    + the canvas (TBCanvas) and its objects:   
      + a new common mechanism of scale;  
      + options of align: anchors, margins, paddings, and patterns of align (TObjectAlign) were implemented;  
      + TFreeShape - a free shape builder with closed counters (see gallery);  
      + TFog - a simple rectangle background with a custom shader;  
      + TCanvasLayout - invisible and is not utilizing GPU resources rectangle object;  
      + TPath - added drag-drop for reference points;  
      + TrapezeRound;  
      + TMultiColoredShape;  
      + TColorSelector;  
      + TBiColoredSolidLines;  
      - TBlackSharkPen was removed;  
         
    + new controls:  
      + TBEdit;   
      + TBSpinEdit;   
      + TObjectInspector;  
      + TBForm;  
      + TBColorDialog;  
      + TBCustomColorBox;  
      + TBTrackBar;  
      + TBGroupBox;  
      + TBCheckBox;  
      + TBTable;  
      + TBComboBox;  
      
    + quality fonts rasterisation was a few improved;   
    + RTTI format translated from binary to xml for possibility compare differencies by VCS;  
    + KD-Tree was implemented with TBlackSharkKDTree;  
    + refactoring of the TBScene:  
      + rendering was taken out to bs.renderer;  
      + translated to KD-tree;  
    + refactoring controls: TBScrolledWindow, TBScrollBar, TBButton;  
    + added a new class THashTable<K, V> to bs.collection;   
    + context initialization:  
      + translated to a shared context;  
      + smart initialization - without eglChooseConfig by selection of attributes from desirable to supported;  
    + management of fonts, textures and shaders was translated to global mode, now they are have common manadgers for all contexts;  
    + new project for autotests (AutoTests.dpr);  
    + new methods in TBlackSharkViewPort for support of autotests (beginning from "Test");  
    + updated libEGL and libGLESv2 libraries for Windows;    
    + an option hardware multisampling was placed to BSConfig.Multisampling;  
    + now by default only one thread is run for animations and events (the same global GuiThread) (see bs.thread.CreateThreads); you can change it in any time;  
    + lot of bugs were fixed in space bs.scheme;  
    
### 28.05.2019  
  New minor version 1.02;    
  
### 18.05.2019  
  The first release!  
  