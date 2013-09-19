package lymeh.naturalchimie.game
{	
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
		//time under which the game consider you want to rotate the current pieces
		private const TIME_TOUCH_ROTATE:int = 250;
		
		private const TOUCH_PHASE_INACTIVE:int = 0;
		private const TOUCH_PHASE_BEGAN:int = 1;
		private const TOUCH_PHASE_MOVE:int = 2;
		private const TOUCH_PHASE_RELEASE:int = 3;
		
		private var _probabilityElementList:Vector.<int>;
		private var _probabilityElementListHighestLevel:int;
		
		private var _grid:Grid;
		
		private var _highestElementBuild:int;
		
		private var _elementFactory:ElementFactory;
		
		private var _touchPhase:int;
		private var _touchStartTime:int
		
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
			_highestElementBuild = Element.LEVEL_2;
			addNextArrivalGroup();
			
			addTouchListener();
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
					_touchPhase = TOUCH_PHASE_BEGAN;
				}
			}
			else if (_touchPhase == TOUCH_PHASE_BEGAN)
			{
				touch = event.getTouch(this, TouchPhase.MOVED);
				if (touch)
				{
					handleTouchMoved();
				}
				else
				{
					touch = event.getTouch(this, TouchPhase.ENDED);
					if (touch)
					{
						handleTouchEnded();
					}
				}
			}
			else if (_touchPhase == TOUCH_PHASE_MOVE)
			{
				touch = event.getTouch(this, TouchPhase.ENDED);
				if (touch)
				{
					handleTouchEnded();
				}
				else
				{
					handleTouchMoved();
				}
			}
		}
		
		private function handleTouchMoved():void
		{
			_touchPhase = TOUCH_PHASE_MOVE;
		}
		
		private function handleTouchEnded():void
		{
			var time:int = getTimer() - _touchStartTime;
			if (time < TIME_TOUCH_ROTATE)
			{
				_grid.rotateElement();
			}
			_touchPhase = TOUCH_PHASE_INACTIVE;
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
			if (_probabilityElementListHighestLevel < _highestElementBuild)
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
			var totalProba:int = 0;
			for (var level:int = 0; level<=_highestElementBuild; level++)
			{
				totalProba += Element.PROBABILITY_BY_LEVEL[level];
			}
			
			var numElement:int;
			for (level=0; level <= _highestElementBuild; level++)
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
			_probabilityElementListHighestLevel = _highestElementBuild;
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