package lymeh.naturalchimie.game.core
{
	import flash.geom.Point;

	// TO DO : code that ...
	public class ElementFactory
	{
		public function ElementFactory()
		{
			
		}
		
		public function recycle(element:Element):void
		{
			
		}
		
		public function getNew(elementLevel:int, elementPosX:int, elementPosY:int):Element
		{
			var element:Element = new Element();
			element.init(elementLevel, new Point(elementPosX, elementPosY));
			return element;
		}
	}
}