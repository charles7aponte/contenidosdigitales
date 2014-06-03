package clases
{
	
	
	import clases.Global;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import spark.utils.DataItem;
	
	
	
	public class XmlPath
	{	
		private var miXML:XML;
		private var cargar:URLLoader ;
		private var seCargo:Boolean;
		private var realizar:Function;
		
	
		
		//
		private var accionError:Function= function():void{};
		

		
		
		
		/**
		* 
		* constrcutro lee el XML
		*/
		public function leerXML(ruta:String):void {			
			
			seCargo=false;
			cargar= new URLLoader();
			
			cargar.addEventListener(IOErrorEvent.IO_ERROR, infoIOErrorEvent);
			cargar.addEventListener(Event.COMPLETE,accionCargarXML);
			
			cargar.load(new URLRequest(ruta));
			
			//encaso de error 
			
			
		}
		
		
	

		/***
		 * accion a relaizar si nuo encuertar xML
		 * */
		public function infoIOErrorEvent( e:IOErrorEvent ):void{
			trace( 'infoIOErrorEvent NO ENCOTRO LE XML DE CONTENIDO------->' );
			
			
			accionError();
		}
		
		
		
		/**
		 * ingresa la accion o  lo que debe hacer con cada nodo de opcion
		 * */
		public function accionAlCargar(hacer:Function):void{
			realizar=hacer;
			
		}
		
		
		
		
		/**
		 * ingrea lo q  debe hacer anter un error
		 * */
		public function accionPorError(hacer:Function):void{
			accionError=hacer;
			
		}
		
		
		
		/**
		 los datos han sido cargados y realiza una accion desde el exterior
		 */
		private function accionCargarXML(e:Event):void{
			miXML = new XML(cargar.data);//
			seCargo=true;
			realizar();
			
			
			//recorrerXML(idMenu);
			
		}
		
		
		
		
		/**
		 * 
		 consulta las rutas 
		 * @return Array de las rutas de contenidos
		 * 
		 * */
		public function consultaRutas():Array
		{
			
			var rutas:Array=new Array();
			
			if(seCargo)
			{
				
				//trace(miXML.menu.length()+"----------->");
				for(var i:uint=0;i<miXML.path.length();i++)
				{
					
					// añade las rutas que encuentra 
					rutas.push( miXML.path[i].@ruta+"");	
					
					trace("-la rutas "+rutas[i]);
					
				}// fin del recorrido
				
				
			
			}
			return rutas;
		
		}
		
		
		
			
	
	
	}
}