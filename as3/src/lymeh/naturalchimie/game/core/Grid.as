package lymeh.naturalchimie.game.core
{	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Grid extends Sprite
	{
		public static const CASE_SIZE:int = 35;
		
		public static const GRID_WIDTH:int = 6;
		public static const GRID_HEIGHT:int = 10;
		
		public static const GRID_THRESHOLD:int = 7;
		
		private var _grid:Vector.<Vector.<Element>>;
		private var _arrivalGroup:ArrivalGroup;
		
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
				moveElement(_arrivalGroup.getElementList());
			}
		}
		
		public function dropElement():void
		{
			if (_arrivalGroup != null)
			{
				trace ("DROP");
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
				}
				longestTween.onComplete = dropComplete;
				_arrivalGroup = null;
			}
		}
		
		private function dropComplete():void
		{
			if (!checkForCombo())
			{
				dispatchEventWith(Event.COMPLETE);
			}
		}
		
		/**
		 * Check if there is combo with the last moved elements and return true is there is combo 
		 * @return 
		 * 
		 */		
		private function checkForCombo():Boolean
		{
			return false;
		}
		
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
		
		public function moveElement(elementList:Vector.<Element>):void
		{
			var tween:Tween;
			for each (var element:Element in elementList)
			{
				tween = new Tween(element, 0.2, Transitions.EASE_OUT);
				tween.moveTo(element.getPosition().x * CASE_SIZE, element.getPosition().y * CASE_SIZE);
				Starling.juggler.add(tween);
			}
		}
	}
}