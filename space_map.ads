with TJa.Window.Text;   use TJa.Window.Text;
with Definitions;       use Definitions;
   
package Space_Map is
   

   
   type Astroid_Spec is
      record
	 X    : Integer;
	 Y    : Integer := 0;
	 Form : Integer;
      end record;
   
   type Astroid_Type is array(1 .. world'Last) of Astroid_spec; 
   
   
   -- Används till att hålla koll vart väggen är när genereringen utförs
   --------------------------------------------------------------------------
   Left_Border  : Integer := X_Led'First;
   Right_Border : Integer := X_Led'Last;
   
   ----------------------------------------------------------
   -- Genererar en helt vanlig bana som har raka väggar
   ----------------------------------------------------------
   procedure Generate_World(Map : out Definitions.World); -- Behöver en variabel som innehåller banan.
   
   
   ----------------------------------------------------------------
   -- Skriver ut hela banan där X,Y bestämmer vart i terminalen.
   ----------------------------------------------------------------
   procedure Put_World(Map : in Definitions.World;
		       X   : in Integer;
		       Y   : in Integer;
		       Background : Colour_Type;
		       Text       : Colour_Type;
		       Boarder    : Boolean := True);
   
   --------------------------------------------------------------------
   -- Genererar en ny rad längst upp.
   --------------------------------------------------------------------
   procedure New_Top_Row(Map : in out World);
   
   
   --------------------------------------------------------------------
   -- Flyttar ner hela banan med 1 rad.
   --------------------------------------------------------------------
   procedure Move_Rows_Down(Map : in out Definitions.World);
   
   
   -------------------------------------------------------------------
   -- Returerar X-koordinaten på väggen till vänster på raden Y.
   -------------------------------------------------------------------
   procedure Border_Left(Map : in Definitions.World;
			 X   : out Integer;
			 Y   : in Integer);
   
   
   -------------------------------------------------------------------
   -- Returerar X-koordinaten på väggen till Höger på raden Y.
   -------------------------------------------------------------------
   procedure Border_Right(Map : in Definitions.World;
			  X   : out Integer;
			  Y   : in Integer);
   
      
   --------------------------------------------------------
   -- Räknar ut och skickar tillbaka vart vänster vägg är
   --------------------------------------------------------
   function Border_Left(Map : in Definitions.World;
			Y   : in Integer) return Integer;

   
   --------------------------------------------------------
   -- Räknar ut och skickar tillbaka vart höger vägg är
   --------------------------------------------------------
   function Border_Right(Map : in Definitions.World;
			 Y   : in Integer) return Integer;
      
   
   -------------------------------------------------------------------
   -- Genererar astroider
   --------------------------------------------------------------------
   procedure Gen_Astroid(Map      : in Definitions.World;
			 Astroid  : in out Astroid_Type;  
			 Chance   : in Integer;          -- 1 = 10% .. 10 = 100% (Typ)
			 form     : in Integer);
   
   
   ---------------------------------------------------------------------
   -- Flyttar ner alla "fallande" astroider en Y-rad
   ---------------------------------------------------------------------
   procedure Move_Astroid(Astroid : in out Astroid_Type);
   
   
   --------------------------------------------------------------------
   -- Returerar Boolean om någon astroid finns vid X,Y koordinaterna.
   ---------------------------------------------------------------------
   function Is_Astroid_There(Astroid : in Astroid_Type;
			     X       : in Integer;
			     Y       : in Integer) return Boolean;
   
   
   -----------------------------------------------------------------------
   -- Returerar astroidens nummret i Astroid arrayen som finns på X,Y koordinaterna.
   -----------------------------------------------------------------------
   procedure Get_Astroid_Nr(Astroid : in Astroid_Type;
			    X       : in Integer;
			    Y       : in Integer;
			    Nr      : out Integer);
   
   
   
   
   ---------------------------------------------------------------------
   -- Tar bort och återställer en fallande Astroid med Astroid nummer
   ---------------------------------------------------------------------
   procedure Remove_Astroid(Astroid : in out Astroid_Type;
			    Nr      : in Integer);
   
   
     ---------------------------------------------------------------------
   -- Tar bort och återställer en fallande Astroid med X,Y koordinater.
   ---------------------------------------------------------------------
   procedure Remove_Astroid(Astroid : in out Astroid_Type;
			    X       : in Integer;
			    Y       : in Integer);
   
   
   ---------------------------------------------------------------------
   -- Skriver ut alla fallande (aktiva) astroider)
   ----------------------------------------------------------------------   
   procedure Put_Astroid(Astroid : in Astroid_Type;
			 X   : in Integer;
			 Y   : in Integer);
   

end Space_Map;
