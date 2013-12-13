package lymeh.naturalchimie.game.ui
{
	import flash.utils.Dictionary;
	
	import lymeh.mobile.utils.SM;
	import lymeh.naturalchimie.game.core.Element;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class LootPopup extends Sprite
	{
		private var _backGround:Quad;
		private var _titleTF:TextField
		
		private var _zoneLoot:Quad;
		private var _descriptionLootTF:TextField;		
		
		public function LootPopup()
		{
			super();
			
			_backGround = new Quad(SM.getStarlingStageWidth()*0.8, 400, 0x969696);
			addChild(_backGround);
			
			_titleTF = new TextField(_backGround.width, 100, "Félicitations", "Verdana", 50);
			_titleTF.hAlign = HAlign.CENTER;
			_titleTF.vAlign = VAlign.TOP;
			_titleTF.autoScale = true;
			_titleTF.y = 15;
			addChild(_titleTF);
			
			_zoneLoot = new Quad(_backGround.width * 0.8, 200, 0xBBBBBB);
			_zoneLoot.x = (_backGround.width - _zoneLoot.width)/2;
			_zoneLoot.y = 150;
			addChild(_zoneLoot);
			
			_descriptionLootTF = new TextField(_zoneLoot.width - 20, 200, "Voici tes gains pour cette partie :", "Verdana", 20);
			_descriptionLootTF.x = _zoneLoot.x + 5;
			_descriptionLootTF.y = _zoneLoot.y + 5;
			_descriptionLootTF.hAlign = HAlign.LEFT;
			_descriptionLootTF.vAlign = VAlign.TOP;
			_descriptionLootTF.autoScale = true;
			addChild(_descriptionLootTF);
			
		}
		
		public function init(elementValueList:Vector.<int>):void
		{
			// a list of value variety 
			var elementCountList:Array = new Array();
			var elementCountByValue:Dictionary = new Dictionary();
			for each (var value:int in elementValueList)
			{
				if (elementCountByValue[value] != null)
				{
					elementCountByValue[value] ++;
				}
				else
				{
					elementCountByValue[value] = 1;
					elementCountList.push(value);
				}
			}
			elementCountList.sort(Array.NUMERIC);
			
			var lootCont:Sprite = createLootContainer(elementCountList, elementCountByValue);
		}
		
		private function createLootContainer(elementCountList:Array, elementCountByValue:Dictionary):Sprite
		{
			var lootContainer:Sprite = new Sprite();
			var numElement:int = elementCountList.length;
			var elementValue:int;
			for (var i:int = 0; i<numElement; i++)
			{
				elementValue = elementCountList[i];
				
			}
			return lootContainer;
		}
	}
}