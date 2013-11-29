package lymeh.naturalchimie
{	
	import lymeh.mobile.utils.SM;
	import lymeh.naturalchimie.game.GameScreen;
	
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.AssetManager;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class Main extends Sprite
	{
		private static var _assets:AssetManager;
		private var _loaderTF:TextField;
		private var _gameScreen:GameScreen;
		
		public function Main()
		{
			super();
		}
		
		public function start(assets:AssetManager):void
		{
			// the asset manager is available from everywhere simply by calling
			// Main.assets
			_assets = assets;
			
			// The AssetManager must now create the textures from the raw data. It could take some time
			// so we add a progress bar
			/*var progressBar:ProgressBar = new ProgressBar();
			progressBar.x = (Constants.STAGE_WIDTH - progressBar.width) / 2;
			progressBar.y = Constants.STAGE_HEIGHT * 0.90;
			this.addChild(progressBar);
			*/
			_loaderTF = new TextField(100, 100, "0%");
			_loaderTF.x = SM.getStarlingStageWidth()/2 - _loaderTF.width/2;
			_loaderTF.y = SM.getStarlingStageHeight()/2 - _loaderTF.height/2;
			_loaderTF.hAlign = HAlign.CENTER;
			_loaderTF.vAlign = VAlign.CENTER;
			addChild(_loaderTF);
			
			assets.loadQueue(onProgress);
			
		}
		
		private function onProgress(ratio:Number):void
		{
			_loaderTF.text = int(ratio*100)+"%";
			
			if (ratio == 1)
			{
				removeChild(_loaderTF);
				_gameScreen = new GameScreen();
				addChild(_gameScreen);
			}
			
			/*progressBar.ratio = ratio;
			
			// a progress bar should always show the 100% for a while,
			// so we show the main menu only after a short delay. 
			
			if (ratio == 1)
				Starling.juggler.delayCall(function():void
				{
					progressBar.removeFromParent(true);
					// TODO : remove background here
					removeChildAt(0, true);
					background = null;
					backgroundImg = null;
					// TODO : essayer d'appler le loadAsset pour le gérer également
					SoundEngine.instance.registerSound("click", _assets.getSound("clic1"));
					SoundEngine.instance.registerSound("click", _assets.getSound("clic2"), true);
					SoundEngine.instance.registerSound("theme", _assets.getSound("theme"));
					SoundEngine.instance.playMusic("theme", 0.5);
					_navigator.showScreen(TITLE_SCREEN);
				}, 0.1);*/
		}
		
		/**	get the AssetManager	 */
		public static function get assets():AssetManager { return _assets; }
		
	}
}