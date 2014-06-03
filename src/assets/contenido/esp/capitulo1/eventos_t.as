package  {
	
	import flash.display.MovieClip;
	
	
	public class eventos_t extends MovieClip {
		
		
		public function eventos_t() {
			// constructor code
		}
			
		
		public var activar=function(event:KeyboardEvent):void
		{
		if(currentFrame == 6){
			var n:int = event.keyCode;
			//------------ Presion tecla "<-"  izquierdo  ----------//
		if(n == 37){
		laberinto.moveLeft=true;
					}	
			//------------ Presion tecla "->" derecha  ----------//
		if(n == 39){
		laberinto.moveRight=true;
					}
			//-----------  Presion tecla arriba ------------------//
		if(n == 38){
		laberinto.moveUp=true;	
					}
		if(n == 40){
		laberinto.moveDown=true;
						
					}					
		}	
		
		}
		
		public var liberar=function(event:KeyboardEvent):void
		{
			
		if(currentFrame == 6){
			var m:int = event.keyCode;
			
		
		//-------- libera freno "espacio" -------------//
		if(m == 37){
		laberinto.moveLeft=false;
		
		}
		//---------libera freno izquierdo "a"------------//
		if(m == 39){
		laberinto.moveRight=false;
		}
		
		//---------libera freno izquierdo "d"------------//
		if(m == 38){
		laberinto.moveUp=false;	
				}	
				
		if(m == 40){
		laberinto.moveDown=false;
					}	
		
		if(!laberinto.gano){
	laberinto.player.player1.sube.visible=false;
	laberinto.player.player1.baja.visible=false;
	laberinto.player.player1.gano.visible=false;
	laberinto.player.player1.retrocede.visible=false;
	laberinto.player.player1.avanza.visible=false;
	laberinto.player.player1.quieto.visible=true;
	laberinto.player.player1.quieto.gotoAndPlay(1);
	}
		
		
		
		}
		
		}
			
				
	}
	
}
