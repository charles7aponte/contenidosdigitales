package cargas
{
	
	
	import clases.Global;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.sampler.NewObjectSample;
	
	import mx.controls.Alert;
	
	import spark.utils.DataItem;
	
	
	/**
	 * recorre los xml de preguntas
	 * */
	public class cargaXMLPreguntas
	{
		
		private var miXML:XML;
		private var cargar:URLLoader ;
		private var seCargo:Boolean;
		private var realizar:Function;
		private var maximoNumeroPreguntas:int=0;
		public var funcionError:Function=function (){};
		public var totalCapituos:int=0;
		public var preguntaPorCapitulo:int=0;
		public var listaPreguntasMaximasPorCapitulo:Array;
		
		
		
		
		public function cargaXMLPreguntas()
		{
			
		
			
		}
		
		
		
		/**
		 
		 constrcutro lee el XML
		 */
		public function leerXML(ruta:String):Boolean{			
			
			if(ruta=="")
				return false;
			
			seCargo=false;
			cargar= new URLLoader();
			
			cargar.addEventListener(IOErrorEvent.IO_ERROR, infoIOErrorEvent);
			
			cargar.addEventListener(Event.COMPLETE,accionCargarXML);
			cargar.load(new URLRequest(ruta));
			
			
			return true;
			
		}
		
		
		
		
		
		/***
		 * accion a relaizar si nuo encuertar xML
		 * */
		public function infoIOErrorEvent( e:IOErrorEvent ):void{
			trace( 'infoIOErrorEvent NO ENCOTRO LE XML DE CONTENIDO DE LA PREGUNTAS ------->' );
			
			funcionError();
		}
	

		
		
		
		/**
		 * ingresa la accion o  lo que debe hacer con cada nodo de opcion
		 * */
		public function accionPorOpcion(hacer:Function):void{
			realizar=hacer;
			
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
		 * genera el dataProvaider segun la vista buscada por su id
		 * 
		 * @return vista {vista => (contenido,pos_menu,vistas,cantidad,tipo,titulo), opciones:array}
		 * */
		/**
		 * 
		 * @param tipo
		 * @return 
		 * 
		 */
		public function consultarPreguntas():Array
		{
				
			var preguntas:Array=new Array();
			
		
			
			if(seCargo)
			{
				
		
				totalCapituos=int(miXML.conf.@cp);// se conoce el total de capitulos 
				preguntaPorCapitulo=int(miXML.conf.@p_cp);// se conoce la cantidad de preguntas a realizar por capitulo 
				
				maximoNumeroPreguntas=totalCapituos*preguntaPorCapitulo;
				Global.numeroPreguntasEvaluacion =maximoNumeroPreguntas;
				
				listaPreguntasMaximasPorCapitulo=new Array();
				for(var i=0;i<totalCapituos;i++)
					{
					listaPreguntasMaximasPorCapitulo.push(0);	
					
					}
				
				
				
				for(var i:uint=0; i<miXML.pregunta.length(); i++)// recorrido de preguntas 
				{
					
					//preguntas de seleccion 
					if(miXML.pregunta[i].@tipo == "SE1" || miXML.pregunta[i].@tipo == "SE2")
					{
					
						var pregunta:Object=construccionPreguntaSE1_2(miXML,i);
						pregunta.tipo=miXML.pregunta[i].@tipo;
						pregunta.ruta=miXML.pregunta[i].@ruta;
						
						
						
						
						
						preguntas.push(pregunta);
						
					}// termino de genera la pregunta que correspodia al SE1
					else  if(miXML.pregunta[i].@tipo == "AS1"){
						
						
						var pregunta:Object=construccionPreguntaAS(miXML,i);
						pregunta.tipo=miXML.pregunta[i].@tipo;
						pregunta.ruta=miXML.pregunta[i].@ruta;
						
						preguntas.push(pregunta);
						
					
					
					}
					
					
					
					
					
				}// fin del  de las preguntas 
			}
			
			
			
			// se reorganizan las preguntas
			preguntas=escogerPreguntasAleatorias(preguntas);
			
			return preguntas;
		
		}
		
		
		
		
		/**
		 * segun la posicion de la pregunta buscar y retonar la pregunta por el orden establecido
		 * @param miXML preguntaXML XML 
		 * @param i int la posicon donde fue encontrada una pregunta tipo SE1 o SE2
		 * @return Object la pregunta formada por sus opciones {puntos, pregunta,opciones}
		 */ 
		public function construccionPreguntaSE1_2(miXML:XML,i:int):Object{
		
			var pregunta:Object=new Object();
			
			// formar la estructura del el tipo de pregunta
			pregunta.puntos=int(miXML.pregunta[i].@puntos);
			pregunta.pregunta=miXML.pregunta[i].@texto;
			
			var opciones:Array=new Array();
			var  preguntaXML:XML=miXML.pregunta[i];
			
			for(var op:int=0;op<preguntaXML.opcion.length(); op++)
			{
				var opcion:Object=new Object();
				opcion.texto=preguntaXML.opcion[op] +"";
				opcion.puntaje= int(preguntaXML.opcion[op].@puntaje);
				
				
				opciones.push(opcion);
				
				
			}
			
			
			
			
			//reorganiza las opciones
			pregunta.opciones=this.organizaAletorio(opciones);
			
		
			
		return pregunta;
		}
		
		
		
		
		
		
		
		/**
		 * segun la posicion de la pregunta buscar y retonar la pregunta por el orden establecido
		 * @param miXML preguntaXML XML 
		 * @param i int la posicon donde fue encontrada una pregunta tipo ASOCIATIVAS
		 * @return Object la pregunta formada por sus opciones {puntos, pregunta,opciones}
		 */ 
		public function construccionPreguntaAS(miXML:XML,i:int):Object{
			
			var pregunta:Object=new Object();
			
			
			// formar la estructura del el tipo de pregunta
			pregunta.puntos=int(miXML.pregunta[i].@puntos);
			pregunta.pregunta=miXML.pregunta[i].@texto;
			
			var opcionesIz:Array=new Array();
			var opcionesDe:Array=new Array();
			var preguntaXML:XML=miXML.pregunta[i];
			var opciones:Array= new Array();
			
			// elementos del lado izquierdo
			for(var op:int=0;op<preguntaXML.izq.opcion.length(); op++)
			{
				var opcion:Object=new Object();
				var opcion1:Object=new Object();
				opcion.texto=preguntaXML.izq.opcion[op] +"";
				opcion.puntaje= int(preguntaXML.izq.opcion[op].@puntaje);
				opcion.tipo= ""+(preguntaXML.izq.opcion[op].@tipo);
				opcion.imagen= ""+(preguntaXML.izq.opcion[op].@imagen);
				
				
				opcion1.texto=opcion.texto+"";
				opcion1.puntaje=int(opcion.puntaje);
				opcion1.tipo=opcion.tipo;
				
			
				
				opcionesIz.push(opcion);
				opciones.push(opcion1);
					
			}
			
			
			//elementos del lado derecho
			for(var op:int=0;op<preguntaXML.de.opcion.length(); op++)
			{
				var opcion:Object=new Object();
				opcion.texto=preguntaXML.de.opcion[op] +"";
				opcion.puntaje= int(preguntaXML.de.opcion[op].@puntaje);
				opcion.tipo= ""+(preguntaXML.de.opcion[op].@tipo);
				opcion.imagen= ""+(preguntaXML.de.opcion[op].@imagen);
				
				
				opcionesDe.push(opcion);
				
				/// relacionar las opciones con su relacion 
				for(var con=0;con<opciones.length; con++)
				{
					
						if(opciones[con].puntaje==opcion.puntaje)
						{
						
							opciones[con].texto=opciones[con].texto+" - > "+opcion.texto;
						break;
						}
				}
				
			}
			
			
			
			//reorganiza las opciones
			pregunta.iz_opciones=opcionesIz;//this.organizaAletorio(opcionesIz);
			pregunta.de_opciones=this.organizaAletorio(opcionesDe);
			pregunta.opciones=opciones;
			
			
			
			for(var i=0;i<pregunta.iz_opciones.length; i++)
			{
			
				trace("desd buil -- "+i+"--->"+pregunta.iz_opciones[i].texto+" "+pregunta.iz_opciones[i].puntaje+" - "+pregunta.iz_opciones[i].imagen);
				//trace("desd buil-- "+i+"--->"+pregunta.de_opciones[i].texto+"  "+pregunta.de_opciones[i].puntaje+" - "+pregunta.de_opciones[i].imagen);
				//trace("desd buil-->>>>> "+i+"--->"+pregunta.opciones[i].puntaje+" puntaje "+"desd buil-->>>>> "+i+"--->"+pregunta.opciones[i].texto);
				
			
			}
		
			
			return pregunta;
		}
		
		
		
		
		
		/**
		 *  funcion para reorganiza las opciones en forma aleatoria
		 * @param opciones Array 
		 * @return retorna el array en un orden distinto
		 * */
		public function  organizaAletorio(opciones:Array):Array
		{
			var numeroAle:int= Math.random()*5;
			for(var i:int=0;i<(2+numeroAle);i++)// cantidad de reordenes
			{
				
			var posicion1Aleatoria:int=Math.random()*opciones.length;	
			var posicion2Aleatoria:int=Math.random()*opciones.length;
			var opcionAuxiliar:Object;
			
			opcionAuxiliar=opciones[posicion1Aleatoria];
			opciones[posicion1Aleatoria]=opciones[posicion2Aleatoria];
			opciones[posicion2Aleatoria]=opcionAuxiliar;
			
			
			}
		
		return opciones;
		}
		
		
		
		/**
		 * tomas las preguntas y escoge la cantidad que se desea  
		 * @param preguntas Array toma las preguntas 
		 * @param Array retorna la cantidad maxima que se escoge 
		 * */
		public function escogerPreguntasAleatorias(preguntas:Array):Array{
			var preguntasEscogidas:Array=new Array();
			var posicionesEscogidas:Array=new Array();
			
			
			
			
			
			//se toman las preguntas hasta obtenes el maximo de preguntas 
			while(preguntasEscogidas.length<maximoNumeroPreguntas
				&& preguntasEscogidas.length < preguntas.length /// se sale encaso que todas las preguntas sean menor que la cantidad de preguntas que se quiere
				  
			
				)	
				
			{
				var posicion:int = int ( Math.random()*preguntas.length);// se toma una posible poscion aleatoria (0,length)
				var seguir:Boolean=true;
				
				
				
				//valida si llego al maximo de preguntas por capitulos
				if(listaPreguntasMaximasPorCapitulo[int(preguntas[posicion].cp)-1] > preguntaPorCapitulo)
				{
					seguir=false
				}
				// valida si la posicion ya existe
				else 
					for(var pos:int=0;pos<posicionesEscogidas.length; pos++)
					{
					
						if(posicionesEscogidas[pos] as int == posicion )
						{	seguir=false
							break;
						}
					
					}
				
				
				
				// si se puede usa se usa 
				if(seguir)
				{
					// se guarda el numeros
					//trace("las poscion que he usados son : "+posicion)
					
					posicionesEscogidas.push(posicion);
					preguntasEscogidas.push(preguntas[posicion]);
					listaPreguntasMaximasPorCapitulo[int(preguntas[posicion].cp)-1]++;
				
				}
		 
			}// fin de escoger preguntas (while)
			
		return preguntasEscogidas; 
		}
		
		
	}
}