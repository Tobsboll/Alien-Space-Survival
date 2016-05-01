with TJa.Window.Text;   use TJa.Window.Text;
with Definitions;       use Definitions;
with TJa.Sockets;       use TJa.Sockets;
   
package Map_Handling is
   
   type Astroid_Spec is
      record
	 X    : Integer;
	 Y    : Integer := 0;
	 Form : Integer;
      end record;
   
   type Astroid_Type is array(1 .. world'Last) of Astroid_spec; 
   
   
   --| Används till att hålla koll vart väggen är när genereringen utförs
   --------------------------------------------------------------------------
   Left_Border  : Integer := X_Led'First;
   Right_Border : Integer := X_Led'Last;
   
   
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
   procedure New_Top_Row(Map     : in out World;
			 Straigt : in Boolean := False;
			 Open    : in Boolean := False;
			 Close   : in Boolean := False);
   
   
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
      
   
   -------------------------------------------------------------------
   --| Genererar astroider
   --------------------------------------------------------------------
   procedure Gen_Astroid(Map      : in Definitions.World;
			 Astroid  : in out Astroid_Type;  
			 Chance   : in Integer;          -- 1 = 10% .. 10 = 100% (Typ)
			 form     : in Integer);
   
   
   ---------------------------------------------------------------------
   --| Flyttar ner alla "fallande" astroider en Y-rad
   ---------------------------------------------------------------------
   procedure Move_Astroid(Astroid : in out Astroid_Type);
   
   
   --------------------------------------------------------------------
   --| Returerar Boolean om någon astroid finns vid X,Y koordinaterna.
   ---------------------------------------------------------------------
   function Is_Astroid_There(Astroid : in Astroid_Type;
			     X       : in Integer;
			     Y       : in Integer) return Boolean;
   
   
   -----------------------------------------------------------------------
   --| Returerar astroidens nummret i Astroid arrayen som finns på X,Y koordinaterna.
   -----------------------------------------------------------------------
   procedure Get_Astroid_Nr(Astroid : in Astroid_Type;
			    X       : in Integer;
			    Y       : in Integer;
			    Nr      : out Integer);
   
   
   
   
   ---------------------------------------------------------------------
   --| Tar bort och återställer en fallande Astroid med Astroid nummer
   ---------------------------------------------------------------------
   procedure Remove_Astroid(Astroid : in out Astroid_Type;
			    Nr      : in Integer);
   
   
   ---------------------------------------------------------------------
   --| Tar bort och återställer en fallande Astroid med X,Y koordinater.
   ---------------------------------------------------------------------
   procedure Remove_Astroid(Astroid : in out Astroid_Type;
			    X       : in Integer;
			    Y       : in Integer);
   
   
   ---------------------------------------------------------------------
   --| Skriver ut alla fallande (aktiva) astroider)
   ----------------------------------------------------------------------   
   procedure Put_Astroid(Astroid : in Astroid_Type;
			 X   : in Integer;
			 Y   : in Integer);
   

end Map_Handling;
