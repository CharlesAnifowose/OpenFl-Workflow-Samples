package;


// import format.swf.instance.MovieClip;
import haxe.macro.Format;
import lime.ui.Mouse;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.Assets;
import openfl.events.MouseEvent;
import openfl.events.Event;
import openfl.external.ExternalInterface;
import haxe.Json;
import openfl.utils.Object;
import openfl.display.Stage;
import motion.Actuate;

import lib.PositioningDisplayUnit;
import lib.ChildDragManager;
import lib.State;

class Init {
	public static var passed:Bool;
}

class Main extends Sprite {
	
	
	public function new () {
		
		super ();
		
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		
	
		try {
			ExternalInterface.addCallback("getQTIPCIState", getState);
		}
		catch (msg : Dynamic) {
			trace ('Could not connect external interface');
		}
		
	}

	private var eventStage:Stage;
	private var mouseDownPotential:Bool = true;
	private var additionPointerHidePending:Bool = false;
	private var posDisUnitContainer:Sprite;
	private var childDragManager:ChildDragManager;
	private var intervalSize:Float;
	private var listOfSquares:Array<Dynamic>;
	private var newPointButton:Sprite;
	private var label_CadreDeRecherche:Sprite;
	private var snapShotHistory:Array<Object>;
	private var lastAutoSnapshotUnixTimestamp:Float;
	private var logInterval_seconds:Float = 15;
	
	private function onAddedToStage(_)
	{
		if (Init.passed) { return; }
		Init.passed = true;
		Assets.loadLibrary ("swf-library", onAssetsLoaded);
	}
	
	private function onAssetsLoaded(_)
	{
		var padding = 10;
		
		label_CadreDeRecherche = Assets.getMovieClip("swf-library:Label_CadreDeRecherche");
		label_CadreDeRecherche.y = padding;
		label_CadreDeRecherche.x = padding;
		addChild(label_CadreDeRecherche);
		
		newPointButton = Assets.getMovieClip("swf-library:NewPointButton");
		newPointButton.buttonMode = newPointButton.useHandCursor = true;
		newPointButton.y = padding;
		newPointButton.x = stage.stageWidth - newPointButton.width - padding;
		addChild(newPointButton);
		newPointButton.addEventListener(MouseEvent.MOUSE_DOWN, onNewBlockClick);
		
		eventStage = stage;
		eventStage.addEventListener(Event.REMOVED_FROM_STAGE, onRemove);

		reset();
	}
	
	private function onRemove(e:Event):Void
	{
		eventStage.removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
		eventStage = null;
	}
	
	private function reset():Void
	{
		listOfSquares = new Array();
		posDisUnitContainer = new Sprite();
		addChild(posDisUnitContainer);
		addChild(newPointButton);
		
		snapShotHistory = new Array();
		lastAutoSnapshotUnixTimestamp = getTimeStamp();

		childDragManager = new ChildDragManager();
		
		var t:PositioningDisplayUnit = new PositioningDisplayUnit( Assets.getMovieClip("swf-library:Block") );
		intervalSize = t.height * 1.15;
		var i:Int;
		//for (i in 0...5) {
			//addPosDisplayUnit(800 * Math.random(), 440 * Math.random());
		//}
	}
	
	private function getTimeStamp():Float {
		var moment:Date = Date.now();
		return moment.getTime();
	}
	
	private function saveState() {
		State.val = Json.stringify({
			finalState: takeBlockPositionSnapshot(),
			stateHistory: snapShotHistory,
			timestamp: getTimeStamp()
		});
	}
	
	
	
	public  function getState():String
	{
		return State.val;
	}
	
	
	public function logAutoSnapshot():Void
	{
		var currentUnixTimestamp:Float = getTimeStamp();
		if ( (currentUnixTimestamp - lastAutoSnapshotUnixTimestamp) / 1000 > logInterval_seconds ) {
			logSnapshot();
			lastAutoSnapshotUnixTimestamp = currentUnixTimestamp;
		}
		saveState();
	}
	
	private function logSnapshot()
	{
		snapShotHistory.push(takeBlockPositionSnapshot());
	}
	
	private function takeBlockPositionSnapshot():Object
	{
		var blockCoordinates:Array<Object> = new Array();
		var len = listOfSquares.length;
		var i:Int;
		for (i in 0...len) {
			if (listOfSquares[i]) {
				var t:PositioningDisplayUnit = listOfSquares[i];
				blockCoordinates.push( { x: Math.round(t.x / intervalSize), y:Math.round(t.y / intervalSize) } );
			}
		}
		return {blocks:blockCoordinates, timestamp:getTimeStamp()}
	}
	
	
	private function addPosDisplayUnit(x, y)
	{
		var t:PositioningDisplayUnit = new PositioningDisplayUnit( Assets.getMovieClip("swf-library:Block") );
		 t.x = x;
		 t.y = y; 
		 t.setChildDragManager(childDragManager);
		 t.setLogAutoSnapshot(this);
		 t.intervalSize = intervalSize;
		 addChild(t);
		 listOfSquares.push(t);
		 return t;
	}
	
	private function onNewBlockClick(e:MouseEvent)
	{
		var t:PositioningDisplayUnit = addPosDisplayUnit(mouseX-intervalSize/2, mouseY-intervalSize/2);
		t.startDragMode();
	}
	
}



