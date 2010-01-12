package com.threerings.ui.snapping {
import com.threerings.ui.bounds.Bounds;

import flash.display.DisplayObject;
import flash.geom.Point;

public interface ISnappingObject
{
//    function get boundsDisplayObject () :DisplayObject;

    function get displayObject () :DisplayObject;
	
	function snapCenterToGlobal (p :Point) :void;
	
	function beginSnapping () :void;
	function endSnapping () :void;

    /**
     * x and y are GLOBAL coords.  Convert if necessary.
     */
//    function centerOn (globalPoint :Point) :void;


    function get globalBounds () :Bounds;//Global bounds
    function get localBounds () :Bounds;//Local bounds

    function get x () :Number;
    function get y () :Number;

    function set x (val :Number) :void;
    function set y (val :Number) :void;
	
//	function get currentSnapAnchor () :ISnapAnchor;
//	function set currentSnapAnchor (val :ISnapAnchor) :void;
}
}
