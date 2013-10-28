package lymeh.naturalchimie.game.core
{
	public class FusionGroup extends ElementGroup
	{
		private var _level:int = -1;
		
		public function FusionGroup(elementList:Vector.<Element>)
		{
			super(elementList);
			if (elementList != null && elementList.length > 0)
			{
				_level = elementList[0].getLevel();
			}
		}
		
		override public function addElement(element:Element):void
		{
			if (_level == -1)
			{
				super.addElement(element);
				_level = element.getLevel();
			}
			else
			{
				if (element.getLevel() == _level)
				{
					super.addElement(element);
				}
				else
				{
					throw new Error("Can't add an element with a different level in a fusion group (group="+_level+" element="+element.getLevel());
				}
			}
		}
		
		public function getLevel():int
		{
			return _level;
		}
	}
}