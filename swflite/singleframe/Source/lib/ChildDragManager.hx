package lib;

import openfl.display.DisplayObject;

class ChildDragManager 
{
	
	public var isDragging:Bool = false;
	public var dragElementList:Array<Dynamic>;
	
	public function new() 
	{
		dragElementList = new Array();
	}
	
	private function findDragElement(d:DisplayObject):Int
	{
		var i:Int;
		for (i in 0...dragElementList.length - 1) {
			if (d == dragElementList[i]) {
				return i;
			}
		}
		return -1;
	}
	
	public function registerDragStart(d:DisplayObject)
	{
		var i:Int = findDragElement(d);
		if ( i == -1 ) {
			dragElementList.push(d);
			isDragging = true;
		}
	}
	public function registerDragEnd(d:DisplayObject)
	{
		var i:Int = findDragElement(d);
		if ( i != -1 ) {
			dragElementList.splice(i, 1);
		}
		if (dragElementList.length == 0) {
			isDragging = false;
		}
	}
	
}

