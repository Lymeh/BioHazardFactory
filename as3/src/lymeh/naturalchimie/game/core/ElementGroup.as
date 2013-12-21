package lymeh.naturalchimie.game.core
{
	import lymeh.naturalchimie.game.GameScreen;

	public class ElementGroup
	{
		protected var _elementList:Vector.<Element>;
		
		public function ElementGroup(elementList:Vector.<Element>)
		{
			_elementList = elementList;
			if (_elementList == null)
			{
				_elementList = GameScreen.getElementFactory().getNewList();
			}
		}
		
		public function addElement(element:Element):void
		{
			if (_elementList.indexOf(element) != -1)
				throw new Error("Element already added");
			else
				_elementList.push(element);
		}
		
		public function getSize():int
		{
			return _elementList.length;
		}
		
		public function getElementList():Vector.<Element>
		{
			return _elementList;
		}
	}
}