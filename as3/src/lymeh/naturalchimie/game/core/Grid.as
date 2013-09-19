package lymeh.naturalchimie.game.core
{
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	
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
				addElementOnGrid(element);
			}
		}
		
		public function addElementOnGrid(element:Element):void
		{
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
		
		public function moveElement(elementList:Vector.<Element>):void
		{
			var tween:Tween;
			for each (var element:Element in elementList)
			{
				tween = new Tween(element, 0.2);
				tween.moveTo(element.getPosition().x * CASE_SIZE, element.getPosition().y * CASE_SIZE);
				Starling.juggler.add(tween);
			}
		}
	}
}