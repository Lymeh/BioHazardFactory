package lymeh.naturalchimie.game.core
{
	import flash.geom.Point;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.utils.Color;
	
	public class Element extends Sprite
	{
		private const COLOR_BY_LEVEL:Vector.<int> = new <int>[Color.MAROON, Color.RED, 0xFF6600, Color.YELLOW, Color.LIME, Color.GREEN, Color.TEAL, Color.BLUE, Color.NAVY, Color.PURPLE, Color.FUCHSIA, Color.BLACK];
		
		public static const LEVEL_0:int = 0;
		public static const LEVEL_1:int = 1;
		public static const LEVEL_2:int = 2;
		public static const LEVEL_3:int = 3;
		public static const LEVEL_4:int = 4;
		public static const LEVEL_5:int = 5;
		public static const LEVEL_6:int = 6;
		public static const LEVEL_7:int = 7;
		public static const LEVEL_8:int = 8;
		public static const LEVEL_9:int = 9;
		public static const LEVEL_10:int = 10;
		public static const LEVEL_11:int = 11;
		
		public static const MAX_LEVEL:int = LEVEL_11;
		
		/**
		 * Appearence probability for each element (in %) 
		 */		
		public static const PROBABILITY_BY_LEVEL:Vector.<int> = new <int>[22,22,22,8,6,5,4,3,3,2,2,1];
		
		private var _position:Point;
		private var _level:int;
		private var _quad:Quad;
		
		public function Element()
		{
			_position = new Point();
			_level = -1;
			super();
		}
		
		public function init(level:int, position:Point):void
		{
			_level = level;
			if (position)
			{
				_position.x = position.x;
				_position.y = position.y;
			}
			if (_quad != null)
			{
				removeChild(_quad);
			}
			_quad = new Quad(Grid.CASE_SIZE - 2, Grid.CASE_SIZE-2, COLOR_BY_LEVEL[_level]);
			addChild(_quad);
		}
		
		public function levelUp():void
		{
			if (_level == MAX_LEVEL)
				return;
			_level++;
			removeChild(_quad);
			_quad = new Quad(Grid.CASE_SIZE - 2, Grid.CASE_SIZE-2, COLOR_BY_LEVEL[_level]);
			addChild(_quad);
		}
		
		public function setPosition(x:int, y:int):void
		{
			_position.x = x;
			_position.y = y;
		}
		
		public function getPosition():Point
		{
			return _position;
		}
		
		public function getLevel():int
		{
			return _level;
		}
	}
}