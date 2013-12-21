package lymeh.mobile.navigation
{
	import feathers.controls.Screen;
	
	import starling.display.DisplayObject;
	
	public class Screen extends feathers.controls.Screen
	{
		public function Screen()
		{
			super();
		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			if (!child is IScreenElement)
			{
				throw new Error ("this element must implement IScreenElement");	
			}
			return super.addChild(child);
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if (!child is IScreenElement)
			{
				throw new Error ("this element must implement IScreenElement");	
			}
			return super.addChildAt(child, index);
		}
		
		override public function removeChild(child:DisplayObject, dispose:Boolean=false):DisplayObject
		{
			(child as IScreenElement).desactive();
			return super.removeChild(child, dispose);
		}
		
		override public function removeChildAt(index:int, dispose:Boolean=false):DisplayObject
		{
			(child as IScreenElement).desactive();
			return super.removeChildAt(index, dispose);
		}
	}
}