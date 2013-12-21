package lymeh.naturalchimie.game.core
{	
	import flash.geom.Point;
	
	import lymeh.naturalchimie.game.GameScreen;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Grid extends Sprite
	{
		public static const FUSION:String = "fusion";
		public static const COMBO:String = "COMBO";
		
		public static const CASE_SIZE:int = 50;
		
		public static const GRID_WIDTH:int = 6;
		public static const GRID_HEIGHT:int = 10;
		
		public static const GRID_THRESHOLD:int = 7;
		
		private const FUSION_TWEEN_DURATION:Number = 0.3;
		private const FUSION_TWEEN_DELAY:Number = 0.1;
		private const MOVE_TWEEN_DURATION:Number = 0.2;
		
		private var _grid:Vector.<Vector.<Element>>;
		private var _arrivalGroup:ArrivalGroup;
		private var _lastMovedElement:Vector.<Element>;
		
		private var _numActiveFusion:int;
		
		public function Grid()
		{
			super();
			touchable = false;
			// grid background
			addChild(new Quad(CASE_SIZE * GRID_WIDTH, CASE_SIZE*GRID_HEIGHT, 0xCCCCCC));
			// threshold background (the playable part);
			addChild(new Quad(CASE_SIZE * GRID_WIDTH, CASE_SIZE * (GRID_HEIGHT-GRID_THRESHOLD)));   
			_grid = new Vector.<Vector.<Element>>(GRID_WIDTH, true);
			for (var i:int = 0; i<GRID_WIDTH; i++)
			{
				_grid[i] = new Vector.<Element>(GRID_HEIGHT, true);
			}
			_lastMovedElement = GameScreen.getElementFactory().getNewList();
		}
		
		public function addNewArrivalGroup(arrivalGroup:ArrivalGroup):void
		{
			_arrivalGroup = arrivalGroup;
			var elementList:Vector.<Element> = _arrivalGroup.getElementList();
			for each (var element:Element in elementList)
			{
				addElementOnGrid(element, false);
			}
		}
		
		public function isFull():Boolean
		{
			for (var i:int = 0; i<GRID_WIDTH; i++)
			{
				if (_grid[i][GRID_HEIGHT - GRID_THRESHOLD - 1] != null)
				{
					return true;
				}
			}
			return false;
		}
		
		public function clean():void
		{
			var element:Element;
			for (var x:int = 0; x<GRID_WIDTH; x++)
			{
				for (var y:int = GRID_HEIGHT-1; y>-1; y--)
				{
					element = _grid[x][y];
					if (element)
					{
						removeChild(element);
						GameScreen.getElementFactory().recycle(element);
					}
					_grid[x][y] = null;
				}
			}
		}
		
		public function addElementOnGrid(element:Element, addToGrid:Boolean):void
		{
			if (addToGrid)
				_grid[element.getPosition().x][element.getPosition().y] = element;
			element.x = element.getPosition().x * CASE_SIZE;
			element.y = element.getPosition().y * CASE_SIZE;
			addChild(element);
		}
		
		public function rotateElement():void
		{
			if (_arrivalGroup != null)
			{
				_arrivalGroup.rotate();
				moveElement(_arrivalGroup.getElementList(), false);
			}
		}
		
		public function dropElement():void
		{
			if (_arrivalGroup != null)
			{
				var numElement:int = _arrivalGroup.getSize();
				var element:Element;
				var dropRowIndex:int;
				var tween:Tween;
				var longestTween:Tween;
				for (var i:int=0; i<numElement; i++)
				{
					element = _arrivalGroup.getElementList()[i];
					dropRowIndex = getDropIndex(element.getPosition().x);
					var offset:int = dropRowIndex - element.getPosition().y;
					element.setPosition(element.getPosition().x, dropRowIndex);
					_grid[element.getPosition().x][element.getPosition().y] = element;
					tween = new Tween(element, 0.1* offset, Transitions.EASE_IN);
					tween.moveTo(element.getPosition().x * CASE_SIZE, element.getPosition().y * CASE_SIZE);
					if (!longestTween || longestTween.totalTime < tween.totalTime)
						longestTween = tween;
					Starling.juggler.add(tween);
					_lastMovedElement.push(element);
				}
				longestTween.onComplete = dropComplete;
				_arrivalGroup.clean();
				_arrivalGroup = null;
			}
		}
		
		/**
		 *	Make fall all elements  
		 * 
		 */		
		private function handleElementFall():void
		{
			var element:Element;
			var offset:int;
			var elementToMove:Vector.<Element> = GameScreen.getElementFactory().getNewList();
			for (var x:int = 0; x<GRID_WIDTH; x++)
			{
				offset = 0;
				for (var y:int = GRID_HEIGHT-1; y>-1; y--)
				{
					element = _grid[x][y];
					if (!element)
					{
						offset++;
					}
					else
					{
						if (offset>0)
						{
							element.setPosition(element.getPosition().x, element.getPosition().y+offset);
							_grid[x][y] = null;
							_grid[x][y+offset] = element;
							elementToMove.push(element);
						}
					}
				}
			}
			if (elementToMove.length>0)
			{
				moveElement(elementToMove, true, dropComplete);
				GameScreen.getElementFactory().recycleList(elementToMove, false);
			}
			else
			{
				dropComplete();
			}
		}
		
		/**
		 * Deplace the element to the left or the right (1 => right, -1 => left)  
		 * @param xOffset
		 * 
		 */		
		public function moveArrivalElement(xOffset:int):void
		{
			if (_arrivalGroup.getLeft() + xOffset >= 0 && _arrivalGroup.getRight() + xOffset < GRID_WIDTH)
			{
				_arrivalGroup.move(xOffset);
				moveElement(_arrivalGroup.getElementList(), false);
			}
			else
			{
				// could be good to do a little bounce animation to show that you can't go this way.
			}
		}
		
		private function dropComplete():void
		{
			if (!checkForCombo())
			{
				_lastMovedElement.splice(0, _lastMovedElement.length);
				dispatchEventWith(Event.COMPLETE);
			}
			else
			{
				_lastMovedElement.splice(0, _lastMovedElement.length);
				dispatchEventWith(Grid.COMBO);
			}
		}
		
		/**
		 * Check if there is combo with the last moved elements and return true is there is combo 
		 * @return 
		 * 
		 */		
		private function checkForCombo():Boolean
		{
			var numElementToCheck:int = _lastMovedElement.length;
			var element:Element;
			var hasCombo:Boolean;
			for (var i:int=0; i<numElementToCheck; i++)
			{
				element = _lastMovedElement[i];
				if (checkForElementCombo(element))
				{
					hasCombo = true;
				}
			}
			return hasCombo;
		}
		
		private function checkForElementCombo(element:Element):Boolean
		{
			var checkedElement:Vector.<Element> = GameScreen.getElementFactory().getNewList();
			var fusionGroup:FusionGroup = new FusionGroup(null);
			fusionGroup.addElement(element);
			checkedElement.push(element);
			checkNeighbourghFusion(element, fusionGroup, checkedElement);
			GameScreen.getElementFactory().recycleList(checkedElement, false);
			if (fusionGroup.getSize() > 2 && fusionGroup.getLevel() < Element.MAX_LEVEL)
			{
				//trace ("there is a combo of "+fusionGroup.getSize()+" elements of level "+fusionGroup.getLevel());
				executeGroupFusion(fusionGroup);
				return true;
			}
			else
			{
				return false;
			}
		}
		
		private function executeGroupFusion(fusionGroup:FusionGroup):void
		{
			_numActiveFusion++;
			var lowestElement:Element = getLowestElement(fusionGroup);
			var numElement:int = fusionGroup.getSize();
			var element:Element;
			var tween:Tween;
			for (var i:int = 0; i<numElement; i++)
			{
				element = fusionGroup.getElementList()[i];
				if (element !== lowestElement)
				{
					_grid[element.getPosition().x][element.getPosition().y] = null;
					tween = new Tween(element, FUSION_TWEEN_DURATION, Transitions.EASE_OUT);
					tween.delay = FUSION_TWEEN_DELAY;
					tween.moveTo(lowestElement.getPosition().x * CASE_SIZE, lowestElement.getPosition().y * CASE_SIZE);
					tween.onComplete = removeElement;
					tween.onCompleteArgs = [element];
					Starling.juggler.add(tween);
				}
				else
				{
					tween = new Tween(element, FUSION_TWEEN_DURATION, Transitions.EASE_OUT);
					tween.delay = FUSION_TWEEN_DELAY;
					tween.onComplete = fusionComplete;
					tween.onCompleteArgs = [element, fusionGroup.getSize()];
					Starling.juggler.add(tween);
				}
			}
		}
		
		private function fusionComplete(element:Element, size:int):void
		{
			element.levelUp();
			// add to check it's neighbour
			_lastMovedElement.push(element);
			_numActiveFusion--;
			if (_numActiveFusion == 0)
			{
				handleElementFall();	
			}
			
			dispatchEventWith(Grid.FUSION, false, {level:element.getLevel()-1, size:size});
		}
		
		/**
		 * Remove an element from the grid 
		 * @param element	The element to remove (it must be already removed from the grid)
		 * 
		 */		
		private function removeElement(element:Element):void
		{
			//_grid[element.getPosition().x][element.getPosition().y] = null;
			removeChild(element);
		}
		
		private function getLowestElement(fusionGroup:FusionGroup):Element
		{
			var lowestElement:Vector.<Element> = GameScreen.getElementFactory().getNewList();
			var elementList:Vector.<Element> = fusionGroup.getElementList();
			var numElement:int = elementList.length;
			var element:Element;
			var lowestElementIndex:int = 0;
			for (var i:int = 0; i<numElement; i++)
			{
				element = elementList[i];
				if (element.getPosition().y >= lowestElementIndex)
				{
					if (element.getPosition().y > lowestElementIndex)
					{
						lowestElementIndex = element.getPosition().y;
						lowestElement.splice(0, lowestElement.length);
					}
					lowestElement.push(element);
				}
			}
			
			// if several elements get the one the most at left;
			if (lowestElement.length>1)
			{
				numElement = lowestElement.length;
				lowestElementIndex = GRID_WIDTH;
				var lefterElement:Element; // bad name :p
				for (i=0; i<numElement; i++)
				{
					element = lowestElement[i];
					if (element.getPosition().x < lowestElementIndex)
					{
						lowestElementIndex = element.getPosition().x;
						lefterElement = element;
					}
				}
				GameScreen.getElementFactory().recycleList(lowestElement, false);
				return lefterElement;
			}
			else
			{
				GameScreen.getElementFactory().recycleList(lowestElement, false);
				return lowestElement[0];
			}
		}
		
		/**
		 * Check for element with the same level which can be fusionned 
		 * @param element	The basic element
		 * @param fusionGroup	The fusion group to add the neighbourgh with the same level
		 * @param checkedElementList	The element already checked to avoid double addition
		 * 
		 */		
		private function checkNeighbourghFusion(element:Element, fusionGroup:FusionGroup, checkedElementList:Vector.<Element>):void
		{
			var way:Point = new Point(0,1);
			checkForFusion(element, way, fusionGroup, checkedElementList);
			way.setTo(0, -1);
			checkForFusion(element, way, fusionGroup, checkedElementList);
			way.setTo(1, 0);
			checkForFusion(element, way, fusionGroup, checkedElementList);
			way.setTo(-1, 0);
			checkForFusion(element, way, fusionGroup, checkedElementList);
		}
		
		private function checkForFusion(element:Element, way:Point, fusionGroup:FusionGroup, checkedElementList:Vector.<Element>):void
		{
			var elementPosition:Point = way.add(element.getPosition());
			if (elementPosition.x >= 0 && elementPosition.x < GRID_WIDTH && elementPosition.y > (GRID_HEIGHT - GRID_THRESHOLD -1 - 2) && elementPosition.y < GRID_HEIGHT)
			{
				// check if element is on th grid
				var testedElement:Element = _grid[elementPosition.x][elementPosition.y];
				if (testedElement != null)
				{
					// check if not already checked
					if (checkedElementList.indexOf(testedElement) == -1)
					{
						checkedElementList.push(testedElement);
						// compare level
						if (testedElement.getLevel() == fusionGroup.getLevel())
						{
							fusionGroup.addElement(testedElement);
							checkNeighbourghFusion(testedElement, fusionGroup, checkedElementList);
						}
					}
				}
			}
		}
		
		 /**
		  *	 Return the lowest empty index of a column 
		  */
		private function getDropIndex(columnIndex:int):int
		{
			for (var i:int = 0; i< GRID_HEIGHT; i++)
			{
				if (_grid[columnIndex][i])
				{
					return i-1;
				}
			}
			return GRID_HEIGHT-1;
		}
		
		private function moveElement(elementList:Vector.<Element>, addToLastMoved:Boolean, onComplete:Function=null, onCompleteArgs:Array=null):void
		{
			var tween:Tween;
			var distance:Number;
			var from:Point = new Point();
			var to:Point = new Point();
			var longestTween:Tween;
			var longestTweenTime:Number = 0;
			var duration:Number = 0;
			for each (var element:Element in elementList)
			{
				from.setTo(element.x, element.y);
				to.setTo(element.getPosition().x * CASE_SIZE, element.getPosition().y * CASE_SIZE);
				distance = Point.distance(from, to);
				duration = distance/CASE_SIZE*MOVE_TWEEN_DURATION;
				tween = new Tween(element, duration, Transitions.EASE_OUT);
				if (duration > longestTweenTime)
				{
					longestTween = tween;
					longestTweenTime = duration;
				}
				tween.moveTo(to.x, to.y);
				Starling.juggler.add(tween);
				if(addToLastMoved)
				{
					_lastMovedElement.push(element);
				}
			}
			if (onComplete)
			{
				longestTween.onComplete = onComplete;
				if (onCompleteArgs)
				{
					longestTween.onCompleteArgs = onCompleteArgs;
				}
			}
		}
	}
}