package com.threerings.flashbang.pushbutton.debug {
import com.pblabs.engine.core.sprintf;
import com.threerings.util.Log;

import flash.utils.getTimer;

/**
 * Modified version of the PBE Profiler to fit OOO logging.
 *
 * Simple, static hierarchical block profiler.
 *
 * Currently it is hardwired to start measuring when you press P, and dump
 * results to the log when you let go of P. Eventually something more
 * intelligent will be appropriate.
 *
 * Use it by calling Profiler.enter("CodeSectionName"); before the code you
 * wish to measure, and Profiler.exit("CodeSectionName"); afterwards. Note
 * that Enter/Exit calls must be matched - and if there are any branches, like
 * an early return; statement, you will need to add a call to Profiler.exit()
 * before the return.
 *
 * Min/Max/Average times are reported in milliseconds, while total and non-sub
 * times (times including children and excluding children respectively) are
 * reported in percentages of total observed time.
 */
public class Profiler
{
    public static var enabled :Boolean = false;
    public static var indentAmount :int = 3;
    public static var nameFieldWidth :int = 50;

    /**
     * Call this outside of all Enter/Exit calls to make sure that things
     * have not gotten unbalanced. If all enter'ed blocks haven't been
     * exit'ed when this function has been called, it will give an error.
     *
     * Useful for ensuring that profiler statements aren't mismatched.
     */
    public static function ensureAtRoot () :void
    {
        if (_stackDepth)
            throw new Error("Not at root!");
    }

    /**
     * Indicate we are entering a named execution block.
     */
    public static function enter (blockName :String) :void
    {
        if (_currentNode == null) {
            _rootNode = new ProfileInfo("Root")
            _currentNode = _rootNode;
        }

        // If we're at the root then we can update our internal enabled state.
        if (_stackDepth == 0) {
            // Hack - if they press, then release insert, start/stop and dump
            // the profiler.
            //              if(PBE.isKeyDown(InputKey.P))
            //              {
            //                  if(!enabled)
            //                  {
            //                      _wantWipe = true;
            //                      enabled = true;
            //                  }
            //              }
            //              else
            //              {
//                              if(enabled)
//                              {
//                                  _wantReport = true;
//                                  enabled = false;
//                              }
            //              }

            _reallyEnabled = enabled;

            if (_wantWipe) {
                doWipe();
            }

            if (_wantReport) {
                doReport();
            }
        }

        // Update stack depth and early out.
        _stackDepth++;
        if (!_reallyEnabled) {
            return;
        }

        // Look for child; create if absent.
        var newNode :ProfileInfo = _currentNode.children[blockName];
        if (!newNode) {
            newNode = new ProfileInfo(blockName, _currentNode);
            _currentNode.children[blockName] = newNode;
        }

        // Push onto stack.
        _currentNode = newNode;

        // Start timing the child node. Too bad you can't QPC from Flash. ;)
        _currentNode.startTime = flash.utils.getTimer();
    }

    /**
     * Indicate we are exiting a named exection block.
     */
    public static function exit (blockName :String) :void
    {
        // Update stack depth and early out.
        _stackDepth--;
        if (!_reallyEnabled) {
            return;
        }

        if (blockName != _currentNode.name){
            throw new Error("Mismatched Profiler.enter/Profiler.exit calls, got '" + _currentNode.
                name + "' but was expecting '" + blockName + "'");
        }

        // Update stats for this node.
        var elapsedTime :int = flash.utils.getTimer() - _currentNode.startTime;
        _currentNode.activations++;
        _currentNode.totalTime += elapsedTime;
        if (elapsedTime > _currentNode.maxTime) {
            _currentNode.maxTime = elapsedTime;
        }
        if (elapsedTime < _currentNode.minTime) {
            _currentNode.minTime = elapsedTime;
        }

        // Pop the stack.
        _currentNode = _currentNode.parent;
    }

    /**
     * Dumps statistics to the log next time we reach bottom of stack.
     */
    public static function report () :void
    {
        if (_stackDepth) {
            _wantReport = true;
            return;
        }

        doReport();
    }

    /**
     * Reset all statistics to zero.
     */
    public static function wipe () :void
    {
        if (_stackDepth) {
            _wantWipe = true;
            return;
        }

        doWipe();
    }

    protected static function doReport () :void
    {
        _wantReport = false;

        var header :String = "\n" + sprintf("%-" + nameFieldWidth + "s%-8s%-8s%-8s%-8s%-8s%-8s", "name",
            "Calls", "Total%", "NonSub%", "AvgMs", "MinMs", "MaxMs");
        log.debug(header + report_R(_rootNode, 0));
//        Logger.print(Profiler, header);
//        report_R(_rootNode, 0);
    }

    protected static function doWipe (pi :ProfileInfo = null) :void
    {
        _wantWipe = false;

        if (!pi) {
            doWipe(_rootNode);
            return;
        }

        pi.wipe();
        for each (var childPi :ProfileInfo in pi.children)
            doWipe(childPi);
    }

    protected static function report_R (pi :ProfileInfo, indent :int) :String
    {
        var s :String = "";
        // Figure our display values.
        var selfTime :Number = pi.totalTime;

        var hasKids :Boolean = false;
        var totalTime :Number = 0;
        for each (var childPi :ProfileInfo in pi.children) {
            hasKids = true;
            selfTime -= childPi.totalTime;
            totalTime += childPi.totalTime;
        }

        // Fake it if we're root.
        if (pi.name == "Root")
            pi.totalTime = totalTime;

        var displayTime :Number = -1;
        if (pi.parent)
            displayTime = Number(pi.totalTime) / Number(_rootNode.totalTime) * 100;

        var displayNonSubTime :Number = -1;
        if (pi.parent)
            displayNonSubTime = selfTime / Number(_rootNode.totalTime) * 100;

        // Print us.
        var entry :String = null;
        if (indent == 0) {
            entry = "\n+Root";
        } else {
            entry = "\n" + 
                sprintf("%-" + (indent * indentAmount) + "s%-" + (nameFieldWidth - indent *
                indentAmount) + "s%-8s%-8s%-8s%-8s%-8s%-8s", "", (hasKids ? "+" : "-") + pi.name,
                pi.activations, displayTime.toFixed(2), displayNonSubTime.toFixed(2),
                (Number(pi.totalTime) / Number(pi.activations)).toFixed(1), pi.minTime, pi.maxTime);
        }
        s += entry;
//        Logger.print(Profiler, entry);

        // Sort and draw our kids.
        var tmpArray :Array = new Array();
        for each (childPi in pi.children) {
            tmpArray.push(childPi);
        }
        tmpArray.sortOn("totalTime", Array.NUMERIC | Array.DESCENDING);
        for each (childPi in tmpArray) {
            s += report_R(childPi, indent + 1);
        }
        
        return s;
    }

    protected static var _currentNode :ProfileInfo;

    /**
     * Because we have to keep the stack balanced, we can only enabled/disable
     * when we return to the root node. So we keep an internal flag.
     */
    protected static var _reallyEnabled :Boolean = true;

    protected static var _rootNode :ProfileInfo;
    protected static var _stackDepth :int = 0;
    protected static var _wantReport :Boolean = false, _wantWipe :Boolean = false;
    protected static const log :Log = Log.getLog(Profiler);
}
}

final class ProfileInfo
{
    public var children :Object = {};
    public var maxTime :int = int.MIN_VALUE;
    public var minTime :int = int.MAX_VALUE;
    public var name :String;
    public var parent :ProfileInfo;

    public var startTime :int, totalTime :int, activations :int;

    final public function ProfileInfo (n :String, p :ProfileInfo = null)
    {
        name = n;
        parent = p;
    }

    final public function wipe () :void
    {
        startTime = totalTime = activations = 0;
        maxTime = int.MIN_VALUE;
        minTime = int.MAX_VALUE;
    }
}