package clases  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.controls.SWFLoader;
	
	public class Cargador extends MovieClip {
		
		
		
		private var fileRef:FileReference = new FileReference();
		private var fileAbrir:File = new File();
		
		
		public var cargador:SWFLoader=null;///el preload
		
		
		public function open():void {
			
			var textTypeFilter:FileFilter = new FileFilter("Text Files (*.png, *.jpg)", "*.png;*.jpg");
			
			fileAbrir.addEventListener(Event.SELECT, onFileSelected);
			fileRef.addEventListener(Event.OPEN, openHandler);
			fileRef.addEventListener(Event.COMPLETE, completeHandler);
			fileAbrir.browseForOpen("Imagen a seleccionar ",[textTypeFilter]);
			
		
		}//fin de la funcion 
		

		
		

		/*******************
		 * abiero el archivo pgn o jpg 
		 * 
		 * */
		public function onFileSelected(evt:Event):void 
        { 
            if(fileAbrir.exists)
			{
				
				var miURL :String = fileAbrir.url;
				var nombre:String="aux";
				var seccionse:Array = miURL.split("/");
					if(seccionse.length>0)
					{
						nombre=seccionse[seccionse.length-1];
					}
					
					
				nombre=getNombre(Global.RUTA_PRESENTACION+"img_ext/",nombre);
			   
				
				
				var rutaNuevo:String =Global.RUTA_PRESENTACION+"img_ext/"+nombre;
				var newFile:File =new  File(rutaNuevo);
				
				fileAbrir.copyTo(newFile,true); 
				actualizar(	Global.RUTA_PRESENTACION+"js/imagenes.js",nombre);
				
				
				
				
			}		
			
        } 
 
			

			
			function openHandler(event:Event):void
			{
			trace("...open...");
			}
			
			function completeHandler(event:Event):void
			{
				
				trace("COMPLETO")
			}
	
			
			
			
			/******************
			 * seleccion un nuevo nombre
			 * */
			private function getNombre(ruta:String, nombre:String):String
			{
				var miFile:File= new File(ruta+"/"+nombre);
				var max:int = 100;
				var min:int = 1;
				
				while(miFile.exists)
				{
					var nombre1:String= nombre.substr(0,nombre.length-4);					
					var nombre2:String= nombre.substr(nombre.length-4,nombre.length);					
					var NumeroAleatorio:Number = Math.floor(Math.random()*(max-min+1))+ min;
					
					
					nombre=nombre1+"-"+NumeroAleatorio+nombre2;
					miFile= new File(ruta+"/"+nombre);
				}
			
				
			return nombre;
			}
			
	/***********************
	 * selecccion de la carpeta para guarda el contenido de la presentacion
	 * **/		
	public function exportarPresentacion():void{		
		
		
		var ubicacionCarpeta:File=new File();
		//ubicacionCarpeta.addEventListener(Event.COMPLETE, onSeleccionCarpeta);
		
		//ubicacionCarpeta.addEventListener(Event.OPEN, onSeleccionCarpeta);
		ubicacionCarpeta.addEventListener(Event.SELECT, onSeleccionCarpeta);
		ubicacionCarpeta.browseForDirectory("Escoger Ubicacion");
	
		
	}		
			
	
	
	/***********************
	 * 
	 * en el momento de selecciona la carpeta
	 * */
	public function onSeleccionCarpeta(e:Event):void{
		
		
		var miCarpeta:File = e.target as File;
		var carpetaPresentacion:File= new File(Global.RUTA_PRESENTACION);


		carpetaPresentacion.copyToAsync(miCarpeta,true);
		cargador.visible=true;
		
		carpetaPresentacion.addEventListener(Event.COMPLETE,function(e:Event):void{
				var miScript:String="var datosPagina=\""+Global.PRINCIPAL_.presentacionJs_JSONPaginas() +"\";\n  "
									+" var datosElementos=\""+Global.PRINCIPAL_.presentacionJs_JSONElementos() +"\";\n "

									+" manejadorPaginas.cargarPaginas(datosPagina);\n"
									+" cargarJsonStringOf(datosElementos);\n"
									+" manejadorPaginas.banderaHabilitaEdicion=false;\n"

									+" manejadorPaginas.inicioPresentacion();\n";
			
				
				crearTxt(miScript,miCarpeta.nativePath+"/cargar_datos.js");
				cargador.visible=false;
				Alert.show(miCarpeta.nativePath+"","exportado");
					
			});
		
		
		
	
	}
		
	
	
	/*****************
	 *  
	 * crear un archivo de texto
	 * **/
	public function crearTxt(texto:String, ruta:String):void{
		var nuevoScript:File = new File(ruta);	
		
		var str:String = texto;
		//if (!nuevoScript.exists)
		{
			var stream:FileStream = new FileStream();
			stream.open(nuevoScript, FileMode.WRITE);
			stream.writeUTFBytes(str);
			stream.close();
		}
		
	
	}
	
	
	
	
	public function actualizar(ruta:String,nueva:String){
		var nuevoScript:File = new File(ruta);			
		var str:String = "";
		var strF:String = "";		
		var miArrayString:Array=new Array();
		var myFileStream:FileStream = new FileStream();
		
		
		nueva=",'"+nueva+"'";
		
		myFileStream.open(nuevoScript, FileMode.UPDATE);
		
		str = myFileStream.readUTFBytes(nuevoScript.size);
		miArrayString= str.split("\n");
		
		miArrayString[1]=(miArrayString[1] as String).substr(0,miArrayString[1].length-3)+nueva+"]\";\n";
			
		for(var i=0; i< miArrayString.length ;i++)
		{
			strF+= miArrayString[i]+"\n";
		}
		myFileStream.close();
	
		crearTxt(strF,ruta);	
		
		Global.PRINCIPAL_.presentacionJs_HtmlActulizarImagenesExternas((miArrayString[1] as String).substr(1,miArrayString[1].length-4));
	
	}
	
	
	
	
	
	
			
	}//fin de class
}//fin de package
