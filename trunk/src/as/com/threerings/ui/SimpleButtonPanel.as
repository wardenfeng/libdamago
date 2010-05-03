package com.threerings.ui {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;

import com.threerings.util.DebugUtil;
import com.threerings.util.EventHandlerManager;
import com.threerings.util.F;
import com.threerings.util.SpriteUtil;

public class SimpleButtonPanel
{
    public function SimpleButtonPanel (type :OrientationType, parent :DisplayObjectContainer = null,
        locX :Number = 0, locY :Number = 0)
    {
        _arrayView = new ArrayView(type);
        if (parent != null) {
            parent.addChild(_arrayView);
        }
        _arrayView.x = locX;
        _arrayView.y = locY;
    }

    public function get display () :DisplayObject
    {
        return _arrayView;
    }

    public function createAndAddButton (name :String, onClick :Function) :SimpleTextButton
    {
        var b :SimpleTextButton = new SimpleTextButton(name);
        _events.registerListener(b, MouseEvent.CLICK, F.adapt(onClick));
        _arrayView.add(b);
        return b;
    }

    public function createAndAddMouseDownButton (name :String, onMouseDown :Function) :Sprite
    {
        var b :Sprite = SpriteUtil.createSprite(true, true);
        DebugUtil.fillRect(b, 50, 30, 0xffffff, 0);
        var g :Graphics = b.graphics;
        g.lineStyle(0, 0, 0);
        g.beginFill(0xffffff, 1);
        g.drawRect(5, 5, 40, 20);
        g.endFill();

        b.addChild(TextBits.createText(name));
        _events.registerListener(b, MouseEvent.MOUSE_DOWN, F.adapt(onMouseDown));
        _arrayView.add(b);
        return b;
    }

    public function shutdown () :void
    {
        _events.freeAllHandlers();
        _arrayView.shutdown();
    }

    protected var _arrayView :ArrayView;

    protected var _events :EventHandlerManager = new EventHandlerManager();
}
}