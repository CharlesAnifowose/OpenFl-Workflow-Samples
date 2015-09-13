package lib;

import haxe.Constraints.Function;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.events.MouseEvent;
import openfl.events.Event;
import openfl.utils.Object;
import motion.Actuate;

class PositioningDisplayUnit extends MovieClip 
{
	
	public var delayedRelease:Bool = false;
	private var eventStage:Stage;
	private var childDragManager:ChildDragManager;
	private var currentDrag:Object;
	public var intervalSize:Float;
	private var displayObject:Sprite;
	private var main:Main;
	
	public function new(_displayObject:Sprite) 
	{
		super();
		
		displayObject = _displayObject;
		addChild(displayObject);
		
		addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
		addEventListener(MouseEvent.MOUSE_OUT,  _onMouseDut);
		addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
		
		this.buttonMode = this.useHandCursor = true;
		this.mouseChildren = false;
		
	}
	

	public function setChildDragManager(_childDragManager:ChildDragManager)
	{
		childDragManager = _childDragManager;
	}

	public function setLogAutoSnapshot(_main:Main)
	{
		main = _main;
	}
	
	private function _onMouseDown(e:MouseEvent):Void 
	{
		startDragMode();
	}
	
	public function startDragMode():Void
	{
		currentDrag = {
			x: this.parent.mouseX - x,
			y: this.parent.mouseY - y,
			wantX: this.x,
			wantY: this.y
		};
		delayedRelease = false;
		Actuate.transform (displayObject, 1).color (0x3366FF, 1);
		childDragManager.registerDragStart(this);
		
		eventStage = stage;
		eventStage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
		addEventListener(Event.ENTER_FRAME, dragPositionUpdate);			
	}
	
	
	private function dragPositionUpdate(e)
	{
		var elastic;
		elastic = 0.7;
		currentDrag.wantX = ((1 - elastic) * currentDrag.wantX) + (elastic * (this.parent.mouseX - currentDrag.x));
		currentDrag.wantY = ((1 - elastic) * currentDrag.wantY) + (elastic * (this.parent.mouseY - currentDrag.y))		;	
		elastic = 0.3;
		this.x = ((1 - elastic) * this.x) + (elastic * roundToInterval(currentDrag.wantX) );
		this.y = ((1 - elastic) * this.y) + (elastic * roundToInterval(currentDrag.wantY) );
		elastic = 0.1;
		this.x = ((1 - elastic) * this.x) + (elastic * (currentDrag.wantX) );
		this.y = ((1 - elastic) * this.y) + (elastic * (currentDrag.wantY) );
	}
	
	private function roundToInterval(num:Float) {
		return Math.round(num / intervalSize) * intervalSize;
	}
	
	private function _onMouseDut(e:MouseEvent):Void 
	{
		if (childDragManager.isDragging) {
			delayedRelease = true;				
		}
		else {
			Actuate.transform (displayObject, 1).color (0x6FC427, 0);
		}
	}
	
	private function _onMouseOver(e:MouseEvent):Void 
	{
		if (childDragManager.isDragging) {
			delayedRelease = false;				
		}
		else {
			Actuate.transform (displayObject, 0.4).color (0x6FC427, 1);
		}			
	}
	

	private function _onMouseUp(e:MouseEvent):Void 
	{
		this.stopDrag();
		childDragManager.registerDragEnd(this);
		eventStage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
		removeEventListener(Event.ENTER_FRAME, dragPositionUpdate);			
		eventStage = null;
		
		Actuate.transform (displayObject, 0.7).color (0x3366FF, 0);
		Actuate.tween(this, 0.2,   { x:roundToInterval(this.x), y:roundToInterval(this.y) } );
		
		main.logAutoSnapshot();
	}
	
	
}
