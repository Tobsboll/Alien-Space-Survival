generic
   
   X_Width     : Integer;
   Y_Height    : Integer;
   Num_Players : Integer := 2;
   Difficult   : Integer := 1; -- Easy 1, Normal 2, Hard 3.
   
package Space_Map is
   
   type World is private;
   type Astroid_Type is private;
   
   
   ----------------------------------------------------------
   -- Genererar en helt vanlig bana som har raka väggar
   ----------------------------------------------------------
   procedure Generate(Map : out World); -- Behöver en variabel som innehåller banan.
   
   
   ----------------------------------------------------------------
   -- Skriver ut hela banan där X,Y bestämmer vart i terminalen.
   ----------------------------------------------------------------
   procedure Put_World(Map : in World;
		       X   : in Integer;
		       Y   : in Integer;
		       Top_Border : Boolean := True);
   
   
   --------------------------------------------------------------------
   -- Genererar en ny rad längst upp.
   --------------------------------------------------------------------
   procedure New_Top_Row(Map : in out World);
   
   
   --------------------------------------------------------------------
   -- Flyttar ner hela banan med 1 rad.
   --------------------------------------------------------------------
   procedure Move_Rows_Down(Map : in out World);
   
   
   -------------------------------------------------------------------
   -- Returerar X-koordinaten på väggen till vänster på raden Y.
   -------------------------------------------------------------------
   procedure Border_Left(Map : in World;
			 X   : out Integer;
			 Y   : in Integer);
   
   
   -------------------------------------------------------------------
   -- Returerar X-koordinaten på väggen till Höger på raden Y.
   -------------------------------------------------------------------
   procedure Border_Right(Map : in World;
			  X   : out Integer;
			  Y   : in Integer);
   
   
   -------------------------------------------------------------------
   -- Genererar astroider
   --------------------------------------------------------------------
   procedure Gen_Astroid(Map      : in World;
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
   
private
   
   type X_Led is array(1 .. X_width) of Character;
   type World is array(1 .. Y_height) of X_Led;
   
   type Astroid_Spec is
      record
	 X    : Integer;
	 Y    : Integer := 0;
	 Form : Integer;
      end record;
   
   type Astroid_Type is array(1 .. (Y_Height*Difficult)/Num_Players) of Astroid_spec; 
   
   
   -- Används till att hålla koll vart väggen är när genereringen utförs
   --------------------------------------------------------------------------
   Left_Border  : Integer := X_Led'First;
   Right_Border : Integer := X_Led'Last;
   
   
end Space_Map;
