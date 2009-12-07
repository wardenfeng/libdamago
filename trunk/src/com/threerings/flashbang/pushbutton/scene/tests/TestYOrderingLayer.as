package com.threerings.flashbang.pushbutton.scene.tests {
import com.pblabs.engine.entity.PropertyReference;
import com.threerings.flashbang.components.EntityAppmode;
import com.threerings.flashbang.components.GameObjectEntity;
import com.threerings.flashbang.components.LocationComponent;
import com.threerings.flashbang.components.tasks.LocationTaskComponent;
import com.threerings.flashbang.util.Rand;
import com.threerings.flashbang.view.LocationComponentBasic;
import com.threerings.flashbang.view.Scene;
import com.threerings.flashbang.view.SceneEntityComponent;
import com.threerings.flashbang.view.SceneLayerYOrdering;
import com.threerings.flashbang.view.SceneView;
import com.threerings.util.DebugUtil;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
public class TestYOrderingLayer extends EntityAppmode
{
    public function TestYOrderingLayer ()
    {
        DebugUtil.fillRect(modeSprite, 1000, 1000, 0, 0);

        var view :SceneView = new SceneView(500, 500);

        _scene = new Scene();
        _scene.sceneView = view;
        _sortingLayer= new SceneLayerYOrdering();
        modeSprite.addChild(_sortingLayer);
        registerListener(_sortingLayer, Event.ENTER_FRAME, _sortingLayer.render);
//        _scene.addLayer(_sortingLayer, _layerName);
//        addComponentViaSameNamedEntity(_scene, _sceneName);
//        modeSprite.addChild(view);

        for (var ii :int = 0; ii < 10; ++ii) {
            var rect :Rectangle = new Rectangle(Rand.nextIntInRange(0, 200),
                                                Rand.nextIntInRange(100, 300),
                                                Rand.nextIntInRange(20, 50),
                                                Rand.nextIntInRange(50, 100));
            createRectObject(rect);
        }

        var moving :GameObjectEntity = createRectObject(new Rectangle(40, 40, 20, 50), 0xff0000);
        registerListener(modeSprite, MouseEvent.CLICK, function (...ignored) :void {
            moving.removeAllTasks();
            moving.addTask(LocationTaskComponent.CreateLinear(view.mouseX, view.mouseY, 3,
                moving.lookupComponentByType(LocationComponent) as LocationComponent));
        });
    }

    protected function createRectObject (rect :Rectangle, color :uint = 0) :GameObjectEntity
    {
        //The display component
        var sprite :Sprite = new Sprite();
        var g :Graphics = sprite.graphics;
        g.beginFill(color);
        g.drawRect(-rect.width / 2, -rect.height, rect.width, rect.height)
        g.endFill();
        g.lineStyle(1, 0xff0000);
        g.drawRect(-rect.width / 2, -rect.height, rect.width, rect.height)
        sprite.x = rect.x;
        sprite.y = rect.y;
        return createObjectFromSprite(sprite);
    }

    protected function createObjectFromSprite (sprite :Sprite) :GameObjectEntity
    {
        var obj :GameObjectEntity = new GameObjectEntity();

        //The location component
        var location :LocationComponentBasic = new LocationComponentBasic();
        location.x = sprite.x;
        location.y = sprite.y;
        var locationName :String = "location";
        obj.addComponent(location, locationName);


        var sceneComponent :SceneEntityComponent = new SceneEntityComponent();
        var sceneComponentName :String = "sceneComponent";
        sceneComponent.displayObject = sprite;
        sceneComponent.sceneLayerName = _layerName;
        obj.addComponent(sceneComponent, sceneComponentName);

        //Link the display to the location component
        sceneComponent.xProperty = new PropertyReference("@location.x");
        sceneComponent.yProperty = new PropertyReference("@location.y");

        //Add to the db
        this.addObject(obj);

        //Add to the scene
//        _scene.addSceneComponent(sceneComponent);
        _sortingLayer.addObject(sceneComponent, sceneComponent.displayObject);
        return obj;
    }



    protected var _sceneName :String = "scene";
    protected var _layerName :String = "someLayer";
    protected var _scene :Scene;
    protected var _sortingLayer :SceneLayerYOrdering;
}
}