package lymeh.naturalchimie.game.core
{
	public class ArrivalGroup extends ElementGroup
	{
		private var STATE_HORIZONTAL:int = 0;
		private var STATE_VERTICAL:int = 1;
		
		private var _currentState:int;
		
		// keep the current position of the group;
		private var _left:int;
		private var _right:int;
		private var _top:int;
		private var _bottom:int;
		
		public function ArrivalGroup(elementList:Vector.<Element>=null)
		{
			super(elementList);
			
			if (_elementList.length!=2)
			{
				throw new Error("Arrival group must be 2 length sized");
			}
			else
			{
				if (_elementList[0].getPosition().x == _elementList[1].getPosition().x)
				{
					_currentState = STATE_VERTICAL;
					_left = _right = _elementList[0].getPosition().x;
					_bottom = _elementList[0].y;
					_top = _bottom - 1;
				}
				else
				{
					_currentState = STATE_HORIZONTAL;
					_top = _bottom = _elementList[0].getPosition().y;
					_left = _elementList[0].getPosition().x;
					_right = _left + 1;					
				}
			}
		}
		
		public function move(xOffset:int):void
		{
			var numElement:int = _elementList.length;
			var element:Element;
			for (var i:int = 0; i<numElement; i++)
			{
				element = _elementList[i];
				element.setPosition(element.getPosition().x + xOffset, element.getPosition().y);
			}
			_left += xOffset;
			_right += xOffset;
		}
		
		public function rotate():void
		{
			var element:Element;
			if (_currentState == STATE_HORIZONTAL)
			{
				element = _elementList[0];
				element.setPosition(element.getPosition().x, element.getPosition().y - 1);
				element = _elementList[1];
				element.setPosition(element.getPosition().x -1, element.getPosition().y); 
				_currentState = STATE_VERTICAL;
				_elementList[1] = _elementList[0];
				_elementList[0] = element;
				
				_bottom = element.getPosition().y;
				_top = _bottom - 1;
				_left = _right = element.getPosition().x;
			}
			else
			{
				element = _elementList[1];
				var xOffset:int = 0;
				if (element.getPosition().x == Grid.GRID_WIDTH-1)
					xOffset = -1;
				element.setPosition(element.getPosition().x + 1 + xOffset, element.getPosition().y + 1);
				element = _elementList[0];
				element.setPosition(element.getPosition().x + xOffset, element.getPosition().y );
				_currentState = STATE_HORIZONTAL;
				
				_top = _bottom = element.getPosition().y;
				_left = element.getPosition().x;
				_right = _left+1;
			}
		}
		
		public function getLeft():int
		{
			return _left;
		}
		
		public function getRight():int
		{
			return _right;
		}
		
		public function getTop():int
		{
			return _top;
		}
		
		public function getBottom():int
		{
			return _bottom;
		}
	}
}