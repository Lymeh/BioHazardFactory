package lymeh.naturalchimie.game
{	
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import lymeh.naturalchimie.Constants;
	import lymeh.naturalchimie.game.core.ArrivalGroup;
	import lymeh.naturalchimie.game.core.Element;
	import lymeh.naturalchimie.game.core.ElementFactory;
	import lymeh.naturalchimie.game.core.Grid;
	
	import starling.animation.Juggler;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class GameScreen extends Sprite
	{
		//time under which the game consider you want to rotate the current pieces (in ms)
		private const TIME_TOUCH_ROTATE:int = 250;
		// time minimum inter 2 move interpretation (when the touch is moving)
		private const TIME_INTER_MOVE_INTERPRETATION:int = 100;
		
		// minimum distance needed to be considered as a drop gesture
		private const MINIMAL_DROP_DISTANCE:int = 30;
		private const MINIMAL_MOVE_DISTANCE:int = 30;
		
		private const TOUCH_PHASE_INACTIVE:int = 0;
		private const TOUCH_PHASE_BEGAN:int = 1;
		private const TOUCH_PHASE_MOVE:int = 2;
		private const TOUCH_PHASE_RELEASE:int = 3;
		
		private var _probabilityElementList:Vector.<int>;
		private var _probabilityElementListHighestLevel:int;
		
		private var _grid:Grid;
		
		private var _highestElementBuilt:int;
		
		private var _elementFactory:ElementFactory;
		
		// Handle the gesture interaction
		private var _touchPhase:int;
		private var _touchStartTime:int;
		private var _lastMoveInterpretationTime:int;
		private var _touchStartPosition:Point;
		// true if one movement has been done between the TouchPhase.BEGAN and TouchPhase.ENDED
		private var _hasMoved:Boolean;
		
		// TO DO : create his personnal juggler
		private var juggler:Juggler;
		
		public function GameScreen()
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			super();
			
			checkElementProbability();
			_elementFactory = new ElementFactory();
		}
		
		
		/**
		 * A kind of unit test to be sure that element probability sum is always equals to 1 
		 * 
		 */
		private function checkElementProbability():void
		{
			var sum:int = 0;
			for each (var prob:int in Element.PROBABILITY_BY_LEVEL)
			{
				sum+= prob;
			}
			if (sum != 100)
			{
				throw new Error ("Check you probability by element, sum is equals to "+sum);
			}
		}
		
		private function addedToStageHandler(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			init();
		}
		
		private function init():void
		{
			// game backGround
			addChild(new Quad(Constants.STAGE_WIDTH, Constants.STAGE_HEIGHT, 0xAAAAAA));
			
			_grid = new Grid();
			addChild(_grid);
			_grid.x = Constants.STAGE_WIDTH / 2 - _grid.width/2;
			_grid.y = Constants.STAGE_HEIGHT / 2 - _grid.height/2;
			_highestElementBuilt = Element.LEVEL_2;
			addNextArrivalGroup();
			_grid.addEventListener(Grid.FUSION, fusionCompleteHandler);
			
			addTouchListener();
			_touchStartPosition = new Point();
		}
		
		private function fusionCompleteHandler(event:Event):void
		{
			if (event.data > _highestElementBuilt)
			{
				_highestElementBuilt = event.data as int;
			}
		}
		
		private function addTouchListener():void
		{
			_touchPhase = TOUCH_PHASE_INACTIVE;
			addEventListener(TouchEvent.TOUCH, touchHandler);	
		}
		
		private function touchHandler(event:TouchEvent):void
		{
			var touch:Touch;
			if (_touchPhase == TOUCH_PHASE_INACTIVE)
			{
				touch = event.getTouch(this, TouchPhase.BEGAN);
				if (touch)
				{
					_touchStartTime = getTimer();
					_touchStartPosition.x = touch.globalX;
					_touchStartPosition.y = touch.globalY;
					_touchPhase = TOUCH_PHASE_BEGAN;
					_hasMoved = false;
				}
			}
			else if (_touchPhase == TOUCH_PHASE_BEGAN)
			{
				touch = event.getTouch(this, TouchPhase.MOVED);
				if (touch)
				{
					_touchPhase = TOUCH_PHASE_MOVE;
					handleTouchMoved(touch.globalX, touch.globalY);
				}
				else
				{
					touch = event.getTouch(this, TouchPhase.ENDED);
					if (touch)
					{
						handleTouchEnded(new Point(touch.globalX, touch.globalY));
					}
				}
			}
			else if (_touchPhase == TOUCH_PHASE_MOVE)
			{
				touch = event.getTouch(this, TouchPhase.ENDED);
				if (touch)
				{
					handleTouchEnded(new Point(touch.globalX, touch.globalY));
				}
				else
				{
					touch = event.getTouch(this, TouchPhase.MOVED);
					if (!touch)
						throw new Error ("Strange error, there is no moved neither ended but we are in the MOVE state");
					handleTouchMoved(touch.globalX, touch.globalY);
				}
			}
		}
		
		private function handleTouchMoved(currentGlobalX:int, currentGlobalY:int):void
		{
			var time:int = getTimer() - _lastMoveInterpretationTime;
			if (time > TIME_INTER_MOVE_INTERPRETATION)
			{
				var yDistance:int = _touchStartPosition.y - currentGlobalY;
				if (yDistance < 0)
					yDistance *= -1;
				var xDistance:int = currentGlobalX - _touchStartPosition.x;
				if (xDistance < 0)
					xDistance *= -1;
				//trace ("touch moved : xDistance="+xDistance+"  yDistance="+yDistance);
				if (_touchStartPosition.y < currentGlobalY - MINIMAL_DROP_DISTANCE)
				{	
					// to be sure the vertical distance need to be at least twice the horizontal distance. 	
					if (yDistance > xDistance*2)
					{
						dropElement();
						removeEventListener(TouchEvent.TOUCH, touchHandler);
					}
				}
				else if (xDistance > MINIMAL_MOVE_DISTANCE)
				{
					if (currentGlobalX > _touchStartPosition.x)
					{
						// move to the right
						_grid.moveArrivalElement(1);
						_hasMoved = true;
					}
					else
					{
						// move to the left
						_grid.moveArrivalElement(-1);
						_hasMoved = true;
					}
					_touchStartPosition.setTo(currentGlobalX, currentGlobalY);
				}
				
				_lastMoveInterpretationTime = getTimer();
			}
		}
		
		private function handleTouchEnded(endGlobalPos:Point):void
		{
			var time:int = getTimer() - _touchStartTime;
			if (time < TIME_TOUCH_ROTATE)
			{
				var distance:int = Point.distance(endGlobalPos, _touchStartPosition);
				if (distance < 100 && !_hasMoved)
					_grid.rotateElement();
				else
				{
					// TO DO : check that =S + refactor with the touchMoveHandler
					if (_touchStartPosition.y < endGlobalPos.y - MINIMAL_DROP_DISTANCE)
					{
						var yDistance:int = _touchStartPosition.y - endGlobalPos.y;
						if (yDistance < 0)
							yDistance *= -1;
						// to be sure the vertical distance need to be at least twice the horizontal distance. 
						var xDistance:int = endGlobalPos.x - _touchStartPosition.x;
						if (xDistance < 0)
							xDistance *= -1;
						if (yDistance > xDistance*2)
						{
							dropElement();
							removeEventListener(TouchEvent.TOUCH, touchHandler);
						}
					}
				}
			}
			_touchPhase = TOUCH_PHASE_INACTIVE;
		}
		
		private function dropElement():void
		{
			_grid.dropElement();
			_grid.addEventListener(Event.COMPLETE, dropCompleteHandler);
		}
		
		private function dropCompleteHandler(event:Event):void
		{
			addNextArrivalGroup();
			addTouchListener();
		}
		
		private function addNextArrivalGroup():void
		{
			var elementList:Vector.<Element> = new Vector.<Element>();
			var elementLevel:int = getNextElementLevel();
			elementList[0] = _elementFactory.getNew(elementLevel, 2, 1);
			elementLevel = getNextElementLevel();
			elementList[1] = _elementFactory.getNew(elementLevel, 3, 1);
			var arrivalGroup:ArrivalGroup = new ArrivalGroup(elementList);
			_grid.addNewArrivalGroup(arrivalGroup);
		}
		
		private function getNextElementLevel():int
		{
			if (_probabilityElementListHighestLevel < _highestElementBuilt)
			{
				updateProbabilityElementList();
			}
			
			return _probabilityElementList[int(_probabilityElementList.length * Math.random())];
		}
		
		private function updateProbabilityElementList():void
		{
			trace ("UpdateProbability");
			_probabilityElementList = new Vector.<int>();
			
			// count the total probability for the currently created element
			// level1.prob + level2.prob. ... + leveln.prob
			// where n is the highest element level created on this game
			var totalProba:int = 0;
			for (var level:int = 0; level<=_highestElementBuilt; level++)
			{
				totalProba += Element.PROBABILITY_BY_LEVEL[level];
			}
			
			var numElement:int;
			for (level=0; level <= _highestElementBuilt; level++)
			{
				numElement = Element.PROBABILITY_BY_LEVEL[level] / totalProba * 100;
				trace (numElement+" element of level "+level);
				for (var i:int = 0; i<numElement; i++)
				{
					_probabilityElementList.push(level); 
				}
			}
			
			if (_probabilityElementList.length < 100)
			{
				var count:int = 0;
				// add as much element as needed to get 100 elements (we add the most probable element first then the other (one of each))
				while (_probabilityElementList.length < 100)
				{
					_probabilityElementList.push(count++);
				}
				trace ("On this run we needed to add "+count+" elements (max level :"+(count-1)+")");
			}
			
			// update the highestLevel of the probability list to don't update it on each request
			_probabilityElementListHighestLevel = _highestElementBuilt;
		}
		
		/**
		 * Return a element level depending on their own appearance probability;
		 */
		private function getRandomElementLevel():int
		{
			return 0;
		}
	}
}