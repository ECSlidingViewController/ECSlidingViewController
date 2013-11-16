//////////////
// Settings //
//////////////

#define kDCIntrospectFlashOnRedrawColor [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.4f]			// UIColor
#define kDCIntrospectFlashOnRedrawFlashLength 0.03f													// NSTimeInterval
#define kDCIntrospectOpaqueColor [UIColor redColor]													// UIColor
#define kDCIntrospectTemporaryDisableDuration 10.                           // Seconds

//////////////////
// Key Bindings //
//////////////////

// '' is equivalent to page up (copy and paste this character to use)
// '' is equivalent to page down (copy and paste this character to use)

// Global //
#define kDCIntrospectKeysInvoke							@" "		// starts introspector
#define kDCIntrospectKeysToggleViewOutlines				@"o"		// shows outlines for all views
#define kDCIntrospectKeysToggleNonOpaqueViews			@"O"		// changes all non-opaque view background colours to red (destructive)
#define kDCIntrospectKeysToggleHelp						@"?"		// shows help
#define kDCIntrospectKeysToggleFlashViewRedraws			@"f"		// toggle flashing on redraw for all views that implement [[DCIntrospect sharedIntrospector] flashRect:inView:] in drawRect:
#define kDCIntrospectKeysToggleShowCoordinates			@"c"		// toggles the coordinates display
#define kDCIntrospectKeysEnterBlockMode					@"b"		// enters block action mode

// When introspector is invoked and a view is selected //
#define kDCIntrospectKeysNudgeViewLeft					@"4"		// nudges the selected view in given direction
#define kDCIntrospectKeysNudgeViewRight					@"6"		//
#define kDCIntrospectKeysNudgeViewUp					@"8"		//
#define kDCIntrospectKeysNudgeViewDown					@"2"		//
#define kDCIntrospectKeysCenterInSuperview				@"5"		// centers the selected view in it's superview
#define kDCIntrospectKeysIncreaseWidth					@"9"		// increases/decreases the width/height of selected view
#define kDCIntrospectKeysDecreaseWidth					@"7"		//
#define kDCIntrospectKeysIncreaseHeight					@"3"		//
#define kDCIntrospectKeysDecreaseHeight					@"1"		//
#define kDCIntrospectKeysLogCodeForCurrentViewChanges	@"0"		// prints code to the console of the changes to the current view.  If the view has not been changed nothing will be printed.  For example, if you nudge a view or change it's rect with the nudge keys, this will log '<#view#>.frame = CGRectMake(50.0, ..etc);'.  Or if you set it's name using setName:forObject:accessedWithSelf: it will use the name provided, for example 'myView.frame = CGRectMake(...);'.  Setting accessedWithSelf to YES would output 'self.myView.frame = CGRectMake(...);'.

#define kDCIntrospectKeysIncreaseViewAlpha				@"+"		// increases/decreases the selected views alpha value
#define kDCIntrospectKeysDecreaseViewAlpha				@"-"		//

#define kDCIntrospectKeysSetNeedsDisplay				@"d"		// calls setNeedsDisplay on selected view
#define kDCIntrospectKeysSetNeedsLayout					@"l"		// calls setNeedsLayout on selected view
#define kDCIntrospectKeysReloadData						@"r"		// calls reloadData on selected view if it's a UITableView
#define kDCIntrospectKeysLogProperties					@"p"		// logs all properties of the selected view
#define kDCIntrospectKeysLogAccessibilityProperties		@"a"		// logs accessibility info (useful for automated view tests - thanks to @samsoffes for the idea)
#define kDCIntrospectKeysLogViewRecursive				@"v"		// calls private method recursiveDescription which logs selected view heirachy

#define kDCIntrospectKeysMoveUpInViewHierarchy			@"y"		// changes the selected view to it's superview
#define kDCIntrospectKeysMoveBackInViewHierarchy		@"t"		// changes the selected view back to the previous view selected (after using the above command)

#define kDCIntrospectKeysMoveDownToFirstSubview			@"h"
#define kDCIntrospectKeysMoveToNextSiblingView			@"j"
#define kDCIntrospectKeysMoveToPrevSiblingView			@"g"

#define kDCIntrospectKeysEnterGDB						@"`"			// enters GDB
#define kDCIntrospectKeysDisableForPeriod		@"~"			// disables DCIntrospect for a given period (see kDCIntrospectTemporaryDisableDuration)
