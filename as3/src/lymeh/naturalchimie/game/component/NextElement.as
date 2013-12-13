package lymeh.naturalchimie.game.component
{
	import lymeh.naturalchimie.game.GameScreen;
	import lymeh.naturalchimie.game.core.ArrivalGroup;
	import lymeh.naturalchimie.game.core.Element;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class NextElement extends Sprite
	{		
		private const ELEMENT_MARGIN:int = 5;
		
		private var _backGround:Quad;
		private var _nextArrivalGroup:ArrivalGroup;
		private var _firstElement:Element;
		private var _secondElement:Element;
		
		public function NextElement()
		{
			super();
			build();
		}
		
		private function build():void
		{
			_backGround = new Quad(150,100, 0xCCCCCC);
			addChild(_backGround);
		}
		
		public function clean():void
		{
			GameScreen.getElementFactory().recycleList(_nextArrivalGroup.getElementList());
			removeChild(_firstElement);
			removeChild(_secondElement);
		}
		
		public function setNextArrivalGroup(arrivalGroup:ArrivalGroup):void
		{
			_nextArrivalGroup = arrivalGroup;
			// first element
			if (!_firstElement)
			{
				_firstElement = new Element();
			}
			_firstElement.init(arrivalGroup.getElementList()[0].getLevel(), null);
			_firstElement.x = (_backGround.width - _firstElement.width*2 - ELEMENT_MARGIN)/2;
			_firstElement.y = (_backGround.height - _firstElement.height)/2;
			addChild(_firstElement);
			
			if (!_secondElement)
			{
				_secondElement = new Element();
			}
			_secondElement.init(arrivalGroup.getElementList()[1].getLevel(), null);	
			_secondElement.x = _firstElement.x + _firstElement.width + ELEMENT_MARGIN;
			_secondElement.y = (_backGround.height - _secondElement.height)/2;
			addChild(_secondElement);
		}
		
		public function getNextArrivalGroup():ArrivalGroup
		{
			return _nextArrivalGroup;
		}
	}
}