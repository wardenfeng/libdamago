package com.threerings.ui.bounds {
import flash.display.DisplayObject;
import flash.geom.Point;
import com.threerings.flashbang.objects.SimpleSceneObject;
import com.threerings.flashbang.tasks.LocationTask;
import com.threerings.util.MathUtil;

public class SceneObjectBounded extends SimpleSceneObject
{
    public function SceneObjectBounded (d :DisplayObject, bounds :Bounds)
    {
        super(d);
        _bounds = bounds;
    }

    public function moveTo (locX :Number, locY :Number, speed :Number) :void
    {
        var targetV :Point = _bounds.getBoundedPointFromMove(x, y, locX, locY);
        var time :Number = MathUtil.distance(x, y, locX, locY) / speed;
        addNamedTask(MOVE_TASK, LocationTask.CreateLinear(targetV.x, targetV.y, time), true);
    }

    protected var _bounds :Bounds;

    protected static const MOVE_TASK :String = "moveTask";
}
}
