package lymeh.mobile.utils
{
	import flash.geom.Rectangle;

	public class SM
	{
		public static var STANDARD_WIDTH:int = 480;
		public static var STANDARD_HEIGHT:int = 800;
		
		public static const ORIENTATION_PORTAIT:int = 0;
		public static const ORIENTATION_LANDSCAPE:int = 1;
		
		private var _orientation:int = ORIENTATION_PORTAIT;
		
		private var _starlingStage:Rectangle;
		private var _fixedGameRect:Rectangle;
		
		/**
		 *Stage Manager 
		 * 
		 */		
		
		private static var _instance:SM;
		
		/**
		 *Must be inited at the start of the projet (as soon as possible to avoid null call) 
		 * 
		 */		
		public function SM()
		{
			
		}
		
		public static function init(orientation:int):void
		{
			if (_instance == null)
				_instance = new SM();
			if (orientation != ORIENTATION_LANDSCAPE && orientation != ORIENTATION_PORTAIT)
				throw new Error("Orientation not handled");
			if (_instance._orientation != orientation)
			{
				_instance._orientation = orientation;
				var stamp:int = STANDARD_WIDTH;
				STANDARD_WIDTH = STANDARD_HEIGHT;
				STANDARD_HEIGHT = stamp;
			}
		}
		
		public static function setViewPort(screenWidth:int, screenHeight:int):void
		{
			if (screenWidth >= STANDARD_WIDTH && screenHeight >= STANDARD_HEIGHT)
			{
				_instance.setUpScaledViewPort(screenWidth, screenHeight);
			}
			else
			{
				_instance.setDownScaledViewPort(screenWidth, screenHeight);
			}
			
			/*trace ("Sum up :");
			trace ("Device Screen : width="+screenWidth+" height="+screenHeight);
			trace ("starling stage : width = "+_starlingStage.width+" height="+_starlingStage.height);
			trace ("Fixed Screen : x="+_fixedGameRect.x+" y="+_fixedGameRect.y+" width = "+_fixedGameRect.width+" height="+_fixedGameRect.height);*/
		}
		
		

		private function setUpScaledViewPort(screenWidth:int, screenHeight:int):void
		{
			trace ("For upscale");				
			var widthRatio:Number = screenWidth/STANDARD_WIDTH;
			var heightRatio:Number =  screenHeight/STANDARD_HEIGHT;
			
			var wantedRatio:Number;
			_fixedGameRect = new Rectangle(0,0,STANDARD_WIDTH, STANDARD_HEIGHT);
			
			if (widthRatio==heightRatio)
			{
				_fixedGameRect = _starlingStage.clone();
			}
			else if (widthRatio > heightRatio)
			{
				wantedRatio = heightRatio;
				_fixedGameRect.x = (screenWidth/wantedRatio - _fixedGameRect.width)/2;
				_starlingStage = new Rectangle(0,0,_fixedGameRect.x*2+_fixedGameRect.width, _fixedGameRect.height);
			}
			else
			{
				wantedRatio = widthRatio;
				_fixedGameRect.y = (screenHeight/wantedRatio - _fixedGameRect.height)/2;
				_starlingStage = new Rectangle(0,0,_fixedGameRect.width, _fixedGameRect.y*2+_fixedGameRect.height);
			}
		}
		
		private function setDownScaledViewPort(screenWidth:int, screenHeight:int):void
		{
			throw new Error("Not implement yet");
		}
		
		public static function getStarlingStageWidth():int
		{
			return _instance._starlingStage.width;
		}
		
		public static function getStarlingStageHeight():int
		{
			return _instance._starlingStage.height;
		}
				
	}
}