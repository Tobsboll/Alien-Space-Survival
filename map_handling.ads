with TJa.Window.Text;   use TJa.Window.Text;
with Definitions;       use Definitions;
with TJa.Sockets;       use TJa.Sockets;
with Object_Handling;   use Object_Handling;
   
package Map_Handling is

   
   --| Används till att hålla koll vart väggen är när genereringen utförs
   --------------------------------------------------------------------------
   Left_Border  : Integer := X_Led'First;
   Right_Border : Integer := X_Led'Last;
   Spawn_Y      : Integer := GameBorder_Y;
   
   
   ----------------------------------------------------------
   --| Tar emot banan från servern
   ----------------------------------------------------------  
   procedure Get_Map(Socket       : in  Socket_Type;
		     Data         : out Game_Data;
		     Check_Update : in  Boolean := True);
   
   
   ----------------------------------------------------------
   --| Skickar banan till klient
   ----------------------------------------------------------     
   procedure Send_Map(Socket       : in Socket_Type;
		      Data         : in Game_Data;
		      Check_Update : in Boolean := True);
   
   ----------------------------------------------------------
   --| Genererar en helt vanlig bana som har raka väggar
   ----------------------------------------------------------
   procedure Generate_World(Map : out Definitions.World); -- Behöver en variabel som innehåller banan.
   
   -----------------------------------------------------------
   --| Put a row with space with a selected colour.
   -----------------------------------------------------------
   procedure Put_Space(Width : in Integer;
		       Colour: in Colour_Type);
   
   
   ----------------------------------------------------------------
   --| Skriver ut hela banan där X,Y bestämmer vart i terminalen.
   ----------------------------------------------------------------
   procedure Put_World(Map             : World;
		       X               : Integer;
		       Y               : Integer;
		       Wall_Background : Colour_Type;
		       Wall_Line       : Colour_Type);
   
   --------------------------------------------------------------------
   --| Genererar en ny rad längst upp.
   --------------------------------------------------------------------
   procedure New_Top_Row(Map      : in out World;
			 Straight : in Boolean := False;
			 Open     : in Boolean := False;
			 Close    : in Boolean := False;
			 Left     : in Boolean := False;
			 Right    : in Boolean := False);
   
   
   --------------------------------------------------------------------
   --| Flyttar ner hela banan med 1 rad.
   --------------------------------------------------------------------
   procedure Move_Rows_Down(Map : in out Definitions.World);
   
   
   --------------------------------------------------------------
   --| Räknar hur långt in väggen är maximalt från varje sida.
   --------------------------------------------------------------
   procedure Border_Min_Max(Map : in Definitions.World;
			    Min : out Integer;
			    Max : out Integer);
   
   -------------------------------------------------------
   --| Räknar fram avståndet mellan väggarna
   -------------------------------------------------------
   function Border_Difference(Map : in World) return Integer;
   
   
   -------------------------------------------------------------------
   --| Returerar X-koordinaten på väggen till vänster på raden Y.
   -------------------------------------------------------------------
   procedure Border_Left(Map : in Definitions.World;
			 X   : out Integer;
			 Y   : in Integer);
   
   
   -------------------------------------------------------------------
   --| Returerar X-koordinaten på väggen till Höger på raden Y.
   -------------------------------------------------------------------
   procedure Border_Right(Map : in Definitions.World;
			  X   : out Integer;
			  Y   : in Integer);
   
      
   --------------------------------------------------------
   --| Räknar ut och skickar tillbaka vart vänster vägg är
   --------------------------------------------------------
   function Border_Left(Map : in Definitions.World;
			Y   : in Integer) return Integer;

   
   --------------------------------------------------------
   --| Räknar ut och skickar tillbaka vart höger vägg är
   --------------------------------------------------------
   function Border_Right(Map : in Definitions.World;
			 Y   : in Integer) return Integer;
      
      
   --| ASTROID |--
   
   procedure Create_Astroid (X, Y         : in Integer;
			     Astroid_List : in out Object_List);
   procedure Astroid_Generator(Spawn_X         : in Integer;
			       Astroid         : in Setting_Type;
			       Astroid_List    : in out Object_list);
   function Too_Close_Astroid(Spawn : in Integer;
			      L     : in Object_List) return Boolean;
   procedure Spawn_Astroid(Astroid_List : in out Object_List;
			   Astroid      : in Setting_Type;
			   Map          : in World);
   procedure Update_Astroid_Position(Astroid_List : in out Object_List);

end Map_Handling;
