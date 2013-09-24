package lymeh.naturalchimie.game.core
{
	public class ArrivalGroup extends ElementGroup
	{
		private var STATE_HORIZONTAL:int = 0;
		private var STATE_VERTICAL:int = 1;
		
		private var _currentState:int;
		
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
					_currentState = STATE_VERTICAL;
				else
					_currentState = STATE_HORIZONTAL;
			}
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
			}
			else
			{
				element = _elementList[0];
				var xOffset:int = 0;
				if (element.getPosition().x == Grid.GRID_WIDTH-1)
					xOffset = -1;
				element.setPosition(element.getPosition().x + 1 + xOffset, element.getPosition().y + 1);
				element = _elementList[1];
				element.setPosition(element.getPosition().x + xOffset, element.getPosition().y );
				_currentState = STATE_HORIZONTAL;
				
				_elementList[1] = _elementList[0];
				_elementList[0] = element;
			}
		}
	}
}