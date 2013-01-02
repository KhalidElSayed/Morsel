# Morsel

## What is Morsel?

TODO

## Why is this needed?

TODO

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

[Pixate](Pixate) seems to be doing at least superficially something similar, but using CSS and SVG instead of it's own file format. They made a rather healthy [$61K on Kickstart](Kicketstarter) so there must be at least _some_ demand for this kind of technology.

  [Pixate]: http://www.pixate.com
  [Kickstarter]: http://www.kickstarter.com/projects/pixate/beautiful-native-mobile-apps?ref=live

## What's with the name "Morsel"?

It's a play on the word "[Nib](Nib)". It's amusing. Laugh.

  [Nib]: http://en.wikipedia.org/wiki/Nib_file

## Why YAML?

TODO

## Editing YAML

YAML does not allow tab characters to be used for indentation and by convention you should be using 2 character soft tabs. The following modeline works in both BBEdit and Sublime Text (although Sublime Text doesn't recognise the mode: yaml part).

	# -*- tab-width: 2; x-auto-expand-tabs: true; indent-tabs-mode: nil; coding: utf-8; mode: yaml; -*-

TextMate doesn't understand modelines at all without a plugin (which doesn't work in TextMate 2).

Xcode needs to be configured on a per file basis. In the Text Editing section of the file inspectors set it to indent via spaces and use 2 space tabs and indents.

## Examples

### Example #1: Creating a view without an owning view controller.

#### Morsel Specification File

	# Example_1.yaml
	# -*- tab-width: 2; x-auto-expand-tabs: true; indent-tabs-mode: nil; coding: utf-8; mode: yaml; -*-
	objects:
	- class: UIView
	  id: root
	  backgroundColor: green 
	  size: [ 320, 416 ]

#### Objective-C

	// Example_1.m
	NSError *theError = NULL;
	CMorsel *theMorsel = [[CMorsel alloc] initWithName:@"_test" bundle:NULL error:&theError];
	// Handle errors here.
	NSDictionary *theObjects = [theMorsel instantiateWithOwner:NULL options:NULL error:&theError];
	// Handle errors here.
	UIView *theView = theObjects[@"root"];

### Example #2

#### Morsel Specification File

	owner:
	  class: CExampleViewController
	  view: root

	objects:
	- class: UIView
	  subviews:
	  - class: UILabel
	    id: nameLabel
	    text: 'Name:'
	    outlet: 'nameLabel'

## Tutorial

TODO

## Types

### UIColor

	backgroundColor: red
	backgroundColor: ff0000
	backgroundColor: rgb(100%, 0%, 0%)

### Points

	point: [0, 0]
	point: { x: 0, y: 0 }
	

## Live Editing & Preview

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
* Creating (simple) bezier paths in code. (Handy for clipping and shadow paths)

## License

Morsel is released under the 2-clause BSD license. See the LICENSE file accompanying the source code and the header comments in the source.

