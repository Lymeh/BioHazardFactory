package lymeh.naturalchimie.game
{	
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import lymeh.mobile.utils.SM;
	import lymeh.naturalchimie.game.component.ElementHint;
	import lymeh.naturalchimie.game.component.NextElement;
	import lymeh.naturalchimie.game.core.ArrivalGroup;
	import lymeh.naturalchimie.game.core.Element;
	import lymeh.naturalchimie.game.core.ElementFactory;
	import lymeh.naturalchimie.game.core.Grid;
	import lymeh.naturalchimie.game.ui.LootPopup;
	
	import starling.animation.Juggler;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	
	public class GameScreen extends Sprite
	{
		//time under which the game consider you want to rotate the current pieces (in ms)
		private const TIME_TOUCH_ROTATE:int = 250;
		// time minimum inter 2 move interpretation (when the touch is moving)
		private const TIME_INTER_MOVE_INTERPRETATION:int = 50;
		
		// minimum distance needed to be considered as a drop gesture
		private const MINIMAL_DROP_DISTANCE:int = 30;
		private const MINIMAL_MOVE_DISTANCE:int = 20;
		
		private const TOUCH_PHASE_INACTIVE:int = 0;
		private const TOUCH_PHASE_BEGAN:int = 1;
		private const TOUCH_PHASE_MOVE:int = 2;
		private const TOUCH_PHASE_RELEASE:int = 3;
		
		private var _probabilityElementList:Vector.<int>;
		private var _probabilityElementListHighestLevel:int;
		
		private var _grid:Grid;
		private var _elementHint:ElementHint;
		private var _nextElement:NextElement;
		private var _scoreTF:TextField;
		
		private var _highestElementBuilt:int;
		
		private static var _elementFactory:ElementFactory;
		
		// Handle the gesture interaction
		private var _touchPhase:int;
		private var _touchStartTime:int;
		private var _lastMoveInterpretationTime:int;
		private var _touchStartPosition:Point;
		// true if one movement has been done between the TouchPhase.BEGAN and TouchPhase.ENDED
		private var _hasMoved:Boolean;
		
		private var _score:int = 0;
		private var _currentCombo:Number = 1;
		
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
			addChild(new Quad(SM.getStarlingStageWidth(), SM.getStarlingStageHeight(), 0xAAAAAA));
			
			_grid = new Grid();
			addChild(_grid);
			_grid.x = SM.getStarlingStageWidth() / 2 - _grid.width/2;
			_grid.y = SM.getStarlingStageHeight() / 2 - _grid.height/2;
			_highestElementBuilt = Element.LEVEL_2;
			_grid.addEventListener(Grid.FUSION, fusionCompleteHandler);
			_grid.addEventListener(Grid.COMBO, comboHandler);
			
			_elementHint = new ElementHint();
			_elementHint.x = _grid.x - _elementHint.width - 20;
			_elementHint.y = _grid.y;
			_elementHint.height = _grid.height;
			_elementHint.scaleX = _elementHint.scaleY;
			addChild(_elementHint);
			
			_nextElement = new NextElement();
			_nextElement.setNextArrivalGroup(generateArrivalGroup());
			_nextElement.x = _grid.x + _grid.width/2 - _nextElement.width/2;
			_nextElement.y = _grid.y - 20 - _nextElement.height;
			_nextElement.scaleX = _nextElement.scaleY = _elementHint.scaleX;
			addChild(_nextElement);
			
			addNextArrivalGroup();
			addTouchListener();
			_touchStartPosition = new Point();
			
			_scoreTF = new TextField(200, 70, "0000000", "Verdana", 50);
			_scoreTF.x = SM.getStarlingStageWidth() - _scoreTF.width;
			_scoreTF.autoScale = true;
			addChild(_scoreTF);
			
			//displayGameOver();
		}
		
		private function fusionCompleteHandler(event:Event):void
		{
			if (event.data > _highestElementBuilt)
			{
				_highestElementBuilt = event.data as int;
			}
			
			// score handler
			trace ("value of fusion element "+event.data.level+" : "+Math.pow(3, event.data.level));
			var scoreDelta:int = Math.pow(3, event.data.level) * event.data.size * _currentCombo;
			trace ("scored : "+scoreDelta);
			_score += scoreDelta;
			updateScore(_score);
		}
		
		private function updateScore(_score:int):void
		{
			var scoreStr:String = _score+"";
			
			while(scoreStr.length < _scoreTF.text.length)
			{
				scoreStr = "0"+scoreStr;
			}
			
			_scoreTF.text = scoreStr;
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
			if (isGameOver())
			{
				handleGameOver();
			}
			else
			{
				resetCombo();
				addNextArrivalGroup();
				addTouchListener();
			}
		}
		
		private function resetCombo():void
		{
			_currentCombo = 0.9;
		}
		
		private function comboHandler():void
		{
			_currentCombo += 0.1;
		}
		
		private function handleGameOver():void
		{
			displayGameOver();
		}
		
		private function displayGameOver():void
		{
			var gameOverClip:Sprite = new Sprite();
			
			var gameOverBackGround:Quad = new Quad(240, 100, 0x888888);
			gameOverClip.addChild(gameOverBackGround);
			
			var gameOverTF:TextField = new TextField(160, 60, "GAME OVER", "Verdana", 50);
			gameOverTF.autoScale = true;
			gameOverTF.x = (gameOverBackGround.width - gameOverTF.width)/2;
			gameOverTF.y = (gameOverBackGround.height - gameOverTF.height)/3;
			gameOverClip.addChild(gameOverTF);
			
			gameOverClip.x = (SM.getStarlingStageWidth() - gameOverClip.width)/2;
			gameOverClip.y = (SM.getStarlingStageHeight() - gameOverClip.height)/2;
			
			addChild(gameOverClip);
			gameOverClip.addEventListener(TouchEvent.TOUCH, clickGameOverHandler);
		}
		
		private function clickGameOverHandler(event:TouchEvent):void
		{
			var gameOverClip:Sprite = (event.currentTarget as Sprite)
			if (event.getTouch(gameOverClip, TouchPhase.BEGAN))
			{
				gameOverClip.removeEventListener(TouchEvent.TOUCH, clickGameOverHandler);
				removeChild(gameOverClip);
				displayPlayerLoot();
			}
		}
		
		private function displayPlayerLoot():void
		{
			var lootPopup:LootPopup = new LootPopup();
			lootPopup.x = (SM.getStarlingStageWidth() - lootPopup.width)/2;
			lootPopup.y = (SM.getStarlingStageHeight() - lootPopup.height)/2;
			
			var lootLevelList:Vector.<int> = new <int>[];
			// to change wih the user data (level)
			const numLoot:int = 5;
			for (var i:int = 0; i<numLoot; i++)
			{
				lootLevelList.push(getNextElementLevel());
			}
			lootPopup.init(lootLevelList);
			lootPopup.addEventListener(LootPopup.BOOK, redirectToBook);
			lootPopup.addEventListener(LootPopup.REPLAY, askForReplay);
			addChild(lootPopup);
		}
		
		private function redirectToBook(event:Event):void
		{
			trace ("can't redirect now ... have to code it =D");
		}
		
		private function askForReplay(event:Event):void
		{
			var lootPopup:LootPopup = event.target as LootPopup;
			lootPopup.removeEventListener(LootPopup.BOOK, redirectToBook);
			lootPopup.removeEventListener(LootPopup.REPLAY, askForReplay);
			
			removeChild(lootPopup);
			lootPopup.destroy();
			restartGame();
		}
		
		private function restartGame():void
		{
			_grid.clean();
			_nextElement.clean();
			
			_highestElementBuilt = Element.LEVEL_2;
			_probabilityElementListHighestLevel = _highestElementBuilt - 1;
			
			addNextArrivalGroup();
			addTouchListener();
		}
		
		private function isGameOver():Boolean
		{
			return _grid.isFull();
		}
		
		private function addNextArrivalGroup():void
		{
			if (_nextElement.getNextArrivalGroup())
			{
				_grid.addNewArrivalGroup(_nextElement.getNextArrivalGroup());
			}
			else
			{
				// first run
				_grid.addNewArrivalGroup(generateArrivalGroup());
			}
			_nextElement.setNextArrivalGroup(generateArrivalGroup());
		}

		private function generateArrivalGroup():ArrivalGroup
		{
			var elementList:Vector.<Element> = GameScreen.getElementFactory().getNewList();
			var elementLevel:int = getNextElementLevel();
			elementList[0] = _elementFactory.getNew(elementLevel, 2, 1);
			elementLevel = getNextElementLevel();
			elementList[1] = _elementFactory.getNew(elementLevel, 3, 1);
			return new ArrivalGroup(elementList);
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
		
		public static function getElementFactory():ElementFactory
		{
			return _elementFactory;
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