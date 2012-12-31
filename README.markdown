# Morsel

## What is Morsel?

TODO

## Why is this needed?

	                 | Code                     | Interface Builder           |
	-----------------+--------------------------+-----------------------------+
	Springs & Struts | Springs & Struts in code | Springs & Struts in NIBs    |
	-----------------+--------------------------+-----------------------------+
	Autolayout       | Autolayout in code       | Autolayout in NIBs          |
	-----------------+--------------------------+-----------------------------+

	                 | Code                     | Interface Builder           |
	-----------------+--------------------------+-----------------------------+
	Springs & Struts | Sucky but Macho!!!       | OK but static content only  |
	-----------------+--------------------------+-----------------------------+
	Autolayout       | Verbose & anti-designer  | Why interface builder, why? |
	-----------------+--------------------------+-----------------------------+

## What else is out there like this?

TODO. Pixate

## What's with the name "Morsel"?

It's a play on the word "Nib". It's amusing. Laugh.

## Examples

TODO

## Tutorial

TODO

## Live Preview

TODO

## Extending Morsel

TODO

## Current Version

0.1 See section "Implemented"., 

## Known Issues

* Caveat: Xcode refactoring doesn't understand morsel files. This is unlikely to ever change unless this part of Xcode can be controlled via plug-ins.
* Caveat: Can load morsel files from web and do crazy things. This could be dangerous. (Of course nothing is stopping you from loading nib files from the web too).
* It's pretty easy to cause morsel processing to crash with incorrect files.

## Currently Implemented

Currently implemented in version 0.1:

* Loading of user interfaces from YAML based morsel files.
* Overriding behaviour with a global morsel file.
* Configuration of owner objects (usually view controllers)
* Outlets and actions/targets (include "smart" default target heuristics)

## Not yet implemented

This is a list of features that should be implemented before 0.1 is final:

* Delegates
* Idiot proof error handling. It should be extremely hard to cause to cause morsel processing to crash via incorrect source files.
* Efficient re-loading of morsel files. As much non-instance information as possible should be cached. Reloading subsequent views from one morsel file should benefit from this cached information.

## Wishlist

This is a list of features that may make it into Morsel some day.

* UITableView support (must have)
* Mac OS X (AppKit) support
* Storyboard support (this is a _big_ maybe)
* Other file formats for morsel (JSON, plists)
* Efficient binary morsel files (NSCoding based dictionaries with "atomic" objects (strings, integers, floats, some structs, colors, fonts, etc) encoded as freeze dried objects)
* Validator tool
* Compile tool (convert morsel files into the efficient binary format)
* Better preview tool (don't use polling HTTP, websockets perhaps?)
* Layer support
* Animation support (CoreAnimation…)
* SceneKits support (Kitchen Sink mode)
* UIGestureRecognizer support (might not be useful without some kind of scripting system)

## License

TODO (BSD 2 clause).

