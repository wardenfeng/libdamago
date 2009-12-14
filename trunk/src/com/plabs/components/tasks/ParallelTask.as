// Flashbang - a framework for creating Flash games
// http://code.google.com/p/flashbang/
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 Three Rings Design
//
// $Id: ParallelTask.as 14 2009-10-05 19:21:31Z tconkling $

package com.plabs.components.tasks {

import com.threerings.flashbang.ObjectTask;

public class ParallelTask extends TaskContainer
{
    public function ParallelTask (...subtasks)
    {
        super(TaskContainer.TYPE_PARALLEL, subtasks);
    }
}

}
