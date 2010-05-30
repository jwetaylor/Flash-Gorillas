﻿package dee.moly.gamestates {
	
	import dee.moly.gameobjects.Banana;
	import dee.moly.gameobjects.CharChain;
	import dee.moly.gameobjects.CityScape;
	import dee.moly.gameobjects.Gorilla;
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import dee.moly.gameobjects.Sun;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	/**
	 * the main level with the gorillas and the buildings and such
	 * @author moly
	 */
	
	public class GameStateLevel extends GameState{
		
		// the game setings for this round
		private var gameSettings:GameSettings;
		
		// the cityscape in the background
		private var cityScape:CityScape;
		
		// two gorillas
		private var gorilla1:Gorilla;
		private var gorilla2:Gorilla;
		
		// names
		private var player1NameText:CharChain;
		private var player2NameText:CharChain;
		
		// score
		private var scoreText:CharChain;
		
		// angle/velocity prompts
		private var angleText:CharChain;
		private var angleInput:CharChain;
		private var velocityText:CharChain;
		private var velocityInput:CharChain;
		private var angle:Number;
		private var velocity:Point;
		
		// the input to add to
		private var currentInput:CharChain;
		
		// which players turn it is
		private var playerTurn:int;
		
		// the projectile
		private var banana:Banana;
		
		// a smiley sun
		private var sun:Sun;
		
		private var state:int;
		
		// state constants
		private static const ANGLE_INPUT:int = 5;
		private static const VELOCITY_INPUT:int = 6;
		private static const BANANA_THROWN:int = 0;
		private static const GORILLA1_HIT:int = 1;
		private static const GORILLA2_HIT:int = 2;
		private static const BUILDING_HIT:int = 3;
		
		public function GameStateLevel(gameSettings:GameSettings) {
			
			this.gameSettings = gameSettings;
			
			gorilla1 = new Gorilla();
			gorilla2 = new Gorilla();
			
			player1NameText = new CharChain(gameSettings.player1Name, 0, 3);
			player2NameText = new CharChain(gameSettings.player2Name, Main.SCREEN_WIDTH - (gameSettings.player2Name.length * 8) - 8, 3);
			
			scoreText = new CharChain("0>Score<0", 0, Main.SCREEN_HEIGHT - 38);
			scoreText.centre();
			
			angleText = new CharChain("Angle:", 0, 18);
			angleInput = new CharChain("", 0, 18, CharChain.SOLID, CharChain.NUMERIC);
			
			velocityText = new CharChain("Velocity:", 0, 33);
			velocityInput = new CharChain("", 0, 33, CharChain.SOLID, CharChain.NUMERIC);
			
			sun = new Sun();
			
			banana = new Banana();
			
			cityScape = new CityScape();
			
			playerTurn = 1;
			
			newGame();
			
		}
		
		// reset everything, build a new skyline etc
		private function newGame():void {
			
			cityScape.buildSkyline();
			cityScape.placeGorillas(gorilla1, gorilla2);
			angleText.x = (playerTurn - 1) * 520;
			currentInput = angleInput;
			currentInput.x = ((playerTurn - 1) * 520) + 50;
			state = ANGLE_INPUT;
			
		}
		
		// move the banana around
		override public function update(elapsed:Number):void {
			
			switch(state) {
				
				case BANANA_THROWN:
				
					banana.update(elapsed);
			
					if (banana.hasCollidedWith(sun))
						sun.shock();
				
					if (banana.hasCollidedWith(cityScape)){
						cityScape.createExplosion(banana.x, banana.y);
						state = BUILDING_HIT;
					}
				
					if (banana.hasCollidedWith(gorilla1)) {
						//gorilla1.explode();
						state = GORILLA1_HIT;
					}
				
					if (banana.hasCollidedWith(gorilla2)) {
						//gorilla2.explode();
						state = GORILLA2_HIT;
					}
					
					if (banana.x > Main.SCREEN_WIDTH || banana.x < 0 || banana.y > Main.SCREEN_HEIGHT){
						state = BUILDING_HIT;
						nextStep();
					}
					
					break;
					
				case BUILDING_HIT:
				
					cityScape.update(elapsed);
					
					if (cityScape.explosionFinished)
						nextStep();
						
					break;
					
				case GORILLA1_HIT:
				
					gorilla1.update(elapsed);
					gorilla2.update(elapsed);
					
					//if (gorilla1.finishedExploding)
						//gorilla2.startDance();
						
					//if (gorilla2.finishedDancing)
						nextStep();
						
					break;
					
				case GORILLA2_HIT:
				
					gorilla2.update(elapsed);
					gorilla1.update(elapsed);
					
					//if (gorilla2.finishedExploding)
						//gorilla1.startDance();
						
					//if (gorilla1.finishedDancing)
						nextStep();
						
					break;
					
			}
					
		}
		
		// draw everything to the screen
		override public function draw(canvas:BitmapData):void {
			
			canvas.fillRect(canvas.rect, 0xFF0000AD);
			
			cityScape.draw(canvas);
			
			player1NameText.draw(canvas);
			player2NameText.draw(canvas);
			
			canvas.fillRect(new Rectangle(scoreText.x - 3, scoreText.y - 2, (scoreText.length * 8) + 5, 14), 0xFF0000AD);
			scoreText.draw(canvas);
			
			gorilla1.draw(canvas);
			gorilla2.draw(canvas);
			
			if (state == ANGLE_INPUT || state == VELOCITY_INPUT) {
				
				angleText.draw(canvas);
				angleInput.draw(canvas);
				
				if (state == VELOCITY_INPUT) {
					velocityText.draw(canvas);
					velocityInput.draw(canvas);
				}
				
			} 
			
			if (state == BANANA_THROWN){
				banana.draw(canvas);
			}
			
			sun.draw(canvas);
			
		}
		
		// put the input into the right places
		override public function onKeyDown(e:KeyboardEvent):void {
			
			if (state == BANANA_THROWN)
				return;
			
			currentInput.addChar(e.charCode);
			
			if (e.keyCode == Keyboard.ENTER && currentInput.text != "")
				nextStep();
				
			if (e.keyCode == Keyboard.BACKSPACE)
				currentInput.backspace();
			
		}
		
		// move on to the next step of the level
		private function nextStep():void {
			
			switch (state) {
				
				// if an angle has just been entered, change the active input to velocity
				case ANGLE_INPUT:
					angleInput.removeCursor();
					currentInput = velocityInput;
					currentInput.x = (520 * (playerTurn - 1)) + 74;
					state = VELOCITY_INPUT;
					break;
			
				// if a velocity has just been entered, throw the banana
				case VELOCITY_INPUT:
				
					var angle:int = int(angleInput.text);
					var velocity:int = int(velocityInput.text);
				
					if (playerTurn == 1){
						var startPoint:Point = new Point(gorilla1.x, gorilla1.y - 7);
						//gorilla1.throwAnimation();
					}
				
					if (playerTurn == 2){
						angle = 180 - angle;
						startPoint = new Point(gorilla2.x + 25, gorilla2.y - 7);
						//gorilla2.throwAnimation();
					}
				
					banana.launch(angle, velocity, gameSettings.gravity, cityScape.windSpeed, startPoint);
					
					state = BANANA_THROWN;
					
					break;
			
				// if the banana has just landed, it's the other players turn
				case GORILLA1_HIT:
				case GORILLA2_HIT:
				case BUILDING_HIT:
					playerTurn = 3 - playerTurn;
					angleInput.text = "";
					angleInput.showCursor();
					velocityInput.text = "";
					currentInput = angleInput;
					currentInput.x = (520 * (playerTurn - 1)) + 50;
					angleText.x = 520 * (playerTurn - 1);
					velocityText.x = 520 * (playerTurn - 1);
					sun.reset();
					state = ANGLE_INPUT;
					break;
					
			}
						
		}
		
	}

}