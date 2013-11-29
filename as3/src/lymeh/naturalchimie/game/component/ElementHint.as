package lymeh.naturalchimie.game.component
{
	import lymeh.naturalchimie.game.core.Element;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class ElementHint extends Sprite
	{
		private const ELEMENT_MARGIN:int = 5;
		
		public function ElementHint()
		{
			super();
			build();
		}
		
		private function build():void
		{
			const BORDER_MARGING:int = 10;
			
			var element:Element;
			
			for (var i:int = 0; i<=Element.MAX_LEVEL; i++)
			{
				element = new Element();
				element.init(i, null);
				addChild(element);
				element.y = (element.height + ELEMENT_MARGIN)*(Element.MAX_LEVEL - i) + BORDER_MARGING;
				element.x = BORDER_MARGING;
			}
			
			var background:Quad = new Quad(this.width + BORDER_MARGING*2, this.height+BORDER_MARGING*2, 0xCCCCCC);
			addChildAt(background, 0);
		}
		
	}
}