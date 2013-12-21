package lymeh.naturalchimie.game.ui
{
	import flash.utils.Dictionary;
	
	import lymeh.mobile.utils.SM;
	import lymeh.naturalchimie.game.GameScreen;
	import lymeh.naturalchimie.game.core.Element;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class LootPopup extends Sprite
	{
		public static const BOOK:String = "book";
		public static const REPLAY:String = "replay";
		
		private var _backGround:Quad;
		private var _titleTF:TextField
		
		private var _zoneLoot:Quad;
		private var _descriptionLootTF:TextField;
		
		private var _receipeBookBtn:Sprite;
		private var _replayBtn:Sprite;
		
		// just use to facilitate the recycle;
		private var _elementList:Vector.<Element>;
		
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
			
			_receipeBookBtn = new Sprite();
			var receipeBookBG:Quad = new Quad(120, 50, 0xB8B8B8);
			_receipeBookBtn.addChild(receipeBookBG);
			var receipeBookTF:TextField = new TextField(receipeBookBG.width, receipeBookBG.height, "Book", "Verdana", 50);
			receipeBookTF.autoScale = true;
			receipeBookTF.hAlign = HAlign.CENTER;
			receipeBookTF.vAlign = VAlign.CENTER;
			_receipeBookBtn.addChild(receipeBookTF);
			_receipeBookBtn.addEventListener(TouchEvent.TOUCH, receipeBookTriggered);
			addChild(_receipeBookBtn);
			
			_replayBtn = new Sprite();
			var replayBG:Quad = new Quad(120, 50, 0xD8D8D8);
			_replayBtn.addChild(replayBG);
			var replayTF:TextField = new TextField(receipeBookBG.width, receipeBookBG.height, "Replay", "Verdana", 50);
			replayTF.autoScale = true;
			replayTF.hAlign = HAlign.CENTER;
			replayTF.vAlign = VAlign.CENTER;
			_replayBtn.addChild(replayTF);
			_replayBtn.addEventListener(TouchEvent.TOUCH, replayTriggered);
			addChild(_replayBtn);
			
			_receipeBookBtn.y = _replayBtn.y = _zoneLoot.y + _zoneLoot.height + 20;
			
			_receipeBookBtn.x = (_backGround.width - (_receipeBookBtn.width + _replayBtn.width + 30))/2;
			_replayBtn.x = _receipeBookBtn.x + _receipeBookBtn.width + 30;
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
			lootCont.x = _zoneLoot.x + 10;
			lootCont.y = _zoneLoot.y + (_zoneLoot.height - lootCont.height)/2;
			addChild(lootCont);
		}
		
		private function replayTriggered(event:TouchEvent):void
		{
			if (event.getTouch(_replayBtn, TouchPhase.BEGAN))
				dispatchEventWith(REPLAY);
		}
		
		private function receipeBookTriggered(event:TouchEvent):void
		{
			if (event.getTouch(_receipeBookBtn, TouchPhase.BEGAN))
				dispatchEventWith(BOOK);
		}
		
		public function destroy():void
		{
			_receipeBookBtn.removeEventListener(TouchEvent.TOUCH, receipeBookTriggered);
			_replayBtn.removeEventListener(TouchEvent.TOUCH, replayTriggered);
			
			// clean the element (recycle);
			GameScreen.getElementFactory().recycleList(_elementList);
		}
		
		private function createLootContainer(elementCountList:Array, elementCountByValue:Dictionary):Sprite
		{
			var lootContainer:Sprite = new Sprite();
			var numElement:int = elementCountList.length;
			var elementValue:int;
			var elementCont:Sprite;
			var element:Element;
			var elementTF:TextField;
			_elementList = GameScreen.getElementFactory().getNewList();
			for (var i:int = 0; i<numElement; i++)
			{
				elementValue = elementCountList[i];
				elementCont = new Sprite();
				element = GameScreen.getElementFactory().getNew(elementValue, 0, 0);
				_elementList.push(element);
				elementCont.addChild(element);
				if (elementCountByValue[elementValue] > 1)
				{
					elementTF = new TextField(element.width/2, element.height/2, "x"+elementCountByValue[elementValue], "Verdana", 50);
					elementTF.autoScale = true;
					elementTF.x = element.width / 2;
					elementTF.y = element.height / 2;
					elementCont.addChild(elementTF);
				}
				
				lootContainer.addChild(elementCont);
				// 12 is just the margin
				elementCont.x = (element.width + 12)*i;
			}
			return lootContainer;
		}
	}
}