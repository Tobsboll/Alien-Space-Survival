with Ada.Text_IO;                       use Ada.Text_IO;
with Ada.Integer_Text_IO;               use Ada.Integer_Text_IO;
with tja.window.Elementary;             use tja.window.Elementary;
with Ada.Numerics.Discrete_Random;

package body Space_Map is
   
   -- Används till att bestämma om väggen ska gå till vänster eller höger
   ---------------------------------------------------------------------------
   subtype MinusOne_To_One is Integer range -1 .. 1;
   package Random is
      new Ada.Numerics.Discrete_Random(Result_Subtype => MinusOne_To_One);
   
   
   
   -- Används till att generera en x-position som Astroiden kan börja på
   ---------------------------------------------------------------------------
   subtype Left_To_Right is Integer range Left_Border+1 .. Right_Border-1;
   package SpawnCoordinate is
      new Ada.Numerics.Discrete_Random(Result_Subtype => Left_To_Right);
   
   
   
   -- Används till att sammanställa sannolikheten att en astroid börjar falla
   ---------------------------------------------------------------------------
   subtype One_To_Ten is Integer range 1 .. 10;
   package Chance_To_Spawn is
      new Ada.Numerics.Discrete_Random(Result_Subtype => One_To_Ten);
   
   
   
   ----------------------------------------------------------
   -- Genererar en helt vanlig bana som har raka väggar
   ----------------------------------------------------------
   procedure Generate_World(Map : out World) is
      
   begin  
      for I in World'Range loop
	 for J in X_Led'Range loop
	    if (J) = (X_Led'first) then
	       Map(I)(J) := '|';
	    elsif (J) = (X_Led'Last) then
	       Map(I)(J) := '|';
	    else
	       Map(I)(J) := ' ';
	    end if;
	 end loop;
      end loop;
   end Generate_World;
   
   
   ----------------------------------------------------------
   -- Skriver ut banan
   -----------------------------------------------------------
   procedure Put_World(Map : World;
		       X   : Integer;
		       Y   : Integer;
		       Top_Border : Boolean := True) is
      
   begin
      
      -- Skriver ut banan vid X,Y -Koordinater
      -------------------------------------------
      Goto_XY(X,Y);
      for I in World'Range loop
	 for J in X_Led'First .. X_Led'last loop
	    Put(Map(I)(J));
	 end loop;
	 New_Line;
	 Goto_XY(X,Y+I);
      end loop;
      
      -- Skriver ut ett tak som följer bredden mellan höger och vänster vägg.
      -----------------------------------------------------------------------
      if Top_Border then
	 Goto_XY(X,Y);
	 if Left_Border /= 1 then
	    for I in 1 .. Left_Border-1 loop
	       Put(' ');
	    end loop;
	 end if;
	 for I in Left_Border .. Right_Border loop
	    Put('_');
	 end loop;
	 
	 for I in Right_Border .. X_Led'Last loop
	    Put(' ');
	 end loop;
	 Goto_XY(X,World'Last+1);
      end if;      
   end Put_World;
   
   
   ---------------------------------------------------------------
   -- Genererar en ny vägg kant på var sida.
   --------------------------------------------------------------
   procedure New_Top_Row(Map : in out World) is
      
      G,M : Random.Generator;
      A,R,O : Integer := 0;
      Left_Max  : Boolean := False;
      Right_Max : Boolean := False;
      
      
   begin
      
      loop
	 Random.Reset(G);
	 
	 -- Får en mer livlig vägg då generatorn bara byter typ var 0.5 sek
	 -------------------------------------------------------------------
	 if A = O then
	    A := Random.Random(G);
	 else
	    if A = -1 then
	       A := 1;
	    elsif A = 1 then
	       A := -1;
	    else
	       A := 1;
	    end if;
	 end if;
	 
	 
	 -- Om Left_Border är längst till Vänster så ska
	 -- den endast generera vägg upp eller höger.
	 -----------------------------------------------

	 if Left_Border = X_Led'first then
	    if A = 1 then
	       Left_Border := Left_Border + A;
	       Map(1)(Left_Border) := '/';
	       Left_Border := Left_Border + A;
	       Map(1)(Left_Border-2) := ' ';
	    else 
	       Map(1)(Left_Border) := '|';
	       Map(1)(Left_Border+1) := ' ';
	    end if;
	    A := O;
	    exit;
	    
	    
	    -- Om Left_Border är mellan vänsterväggen och begränsningen
	    -----------------------------------------------
	 elsif Left_Border > 2 and 
	   Left_Border < X_Led'Last/(3+Num_Players-Difficult) then -- Begränsningen
	    if A = -1 and Map(2)(Left_Border) = '|' then 
	       Left_Border := Left_Border + A;
	       Map(1)(Left_Border) := '\';
	       Left_Border := Left_Border + A;
	       Map(1)(Left_Border - (2*A)) := ' ';
	       O := A;
	       exit;
	    elsif A = 0 and Map(2)(Left_Border-1) = '/' then 
	       Map(1)(Left_Border) := '|';
	       Map(1)(Left_Border-1) := ' ';
	       O := A;
	       exit;
	    elsif A = 0 and Map(2)(Left_Border+1) = '\'  then 
	       Map(1)(Left_Border) := '|';
	       Map(1)(Left_Border+1) := ' ';
	       O := A;
	       exit;
	    elsif A = 1 and Map(2)(Left_Border) = '|' then 
	       Left_Border := Left_Border + A;
	       Map(1)(Left_Border) := '/';
	       Left_Border := Left_Border + A;
	       Map(1)(Left_Border -(2*A)) := ' ';
	       O := A;
	       exit;
	    else
	       Map(1)(Left_Border) := '|';
	       Map(1)(Left_Border+1) := ' ';
	       Map(1)(Left_Border-1) := ' ';
	       exit;
	    end if;
	 else
	    --- Om Left_Border har uppnått den maximala gränsen
	    ---------------------------------------------------
	    Map(1)(Left_Border-1) := '\';
	    Left_Border := Left_Border -2;
	    exit;
	 end if;
      end loop;
      
      loop
        
	 Random.Reset(G);
	 
	 -- Får en mer livlig vägg då generatorn bara byter typ var 0.5 sek
	 -------------------------------------------------------------------
	    if A = O then
	       A := Random.Random(M);
	    else
	       if A = 1 then
		  A := -1;
	       elsif A = -1 then
		  A := 1;
	       else
		  A := -1;
	       end if;
	    end if;
	    
	    -- Om Right_Border är längst till höger så ska
	    -- den endast generera vägg upp eller vänster.
	    -----------------------------------------------
	    if Right_Border = X_Led'Last then
	       if A = -1 then
		  Right_Border := Right_Border + A;
		  Map(1)(Right_Border) := '\';
		  Right_Border := Right_Border + A;
		  Map(1)(Right_Border+2) := ' ';
	       else 
		  Map(1)(Right_Border) := '|';
		  Map(1)(Right_Border-1) := ' ';
	       end if;
	       A := O;
	       exit;
	       
	    
	    -- Om Right_Border är mellan högerväggen och begränsningen
	    -----------------------------------------------
	    elsif Right_Border < X_Led'Last-1 and                        -- Högerväggen
	      Right_Border > X_Led'Last-(X_Led'Last/(3+Num_Players-Difficult)) then-- Begränsningen
	       if A = -1 and Map(2)(Right_Border) = '|' then 
		  Right_Border := Right_Border + A;
		  Map(1)(Right_Border) := '\';
		  Right_Border := Right_Border + A;
		  Map(1)(Right_Border - (2*A)) := ' ';
		  O := A;
		  exit;
	       elsif A = 0 and Map(2)(Right_Border-1) = '/' then 
		  Map(1)(Right_Border) := '|';
		  Map(1)(Right_Border-1) := ' ';
		  O := A;
		  exit;
	       elsif A = 0 and Map(2)(Right_Border+1) = '\'  then 
		  Map(1)(Right_Border) := '|';
		  Map(1)(Right_Border+1) := ' ';
		  O := A;
		  exit;
	       elsif A = 1 and Map(2)(Right_Border) = '|' then 
		  Right_Border := Right_Border + A;
		  Map(1)(Right_Border) := '/';
		  Right_Border := Right_Border + A;
		  Map(1)(Right_Border -(2*A)) := ' ';
		  O := A;
		  exit;
	       else
		  Map(1)(Right_Border) := '|';
		  Map(1)(Right_Border+1) := ' ';
		  Map(1)(Right_Border-1) := ' ';
		  exit;
	       end if;
	    else
	       --- Om Right_Border har uppnått den maximala gränsen
	       ---------------------------------------------------
	       Map(1)(Right_Border+1) := '/';
	       Right_Border := Right_Border + 2; 
	       exit;
	    end if;
      end loop;
      
   end New_Top_Row;
   
   
   ----------------------------------------------
   -- Flyttar ner alla rader
   -----------------------------------------------
   procedure Move_Rows_Down(Map : in out World) is
      
   begin
      for I in reverse World'First+1 .. World'last  loop
	 for J in X_Led'Range loop
	    Map(I)(J) := Map(I-1)(J);	    
	 end loop;
      end loop;
   end Move_Rows_Down;
   
   
   --------------------------------------------------------
   -- Räknar ut och skickar tillbaka vart vänster vägg är
   --------------------------------------------------------
   procedure Border_Left(Map : in World;
			 X   : out Integer;
			 Y   : in Integer) is
      
   begin
      X  := X_Led'First;
      for J in X_Led'Range loop	    
	 if Map(Y)(J) /= ' ' then
	    X := J;
	    exit;
	 end if;
      end loop;
   end Border_Left;
   
   
   
   --------------------------------------------------------
   -- Räknar ut och skickar tillbaka vart höger vägg är
   --------------------------------------------------------
   procedure Border_Right(Map : in World;
			  X   : out Integer;
			  Y   : in Integer) is
      
   begin
      X := X_Led'Last;
      for J in reverse X_Led'Range loop
	 if Map(Y)(J) /= ' ' then
	    X := J;        
	    exit;
	 end if;
      end loop;
   end Border_Right;
   
   --------------------------------------------------------------
   --- Räknar hur långt in väggen är maximalt från varje sida.
   --------------------------------------------------------------
   procedure Border_Min_Max(Map : in World;
			    Min : out Integer;
			    Max : out Integer) is
      
   begin
      -- Startvärdern
      Max := X_Led'last;
      Min := X_Led'First;
      
      -- Går igeom alla rader (Y-led)
      for I in World'Range loop
	 
	 --- Går igenom vänsersidan
	 for J in X_Led'Range loop	    
	    if Map(I)(J) /= ' ' then
	       if J > Min then     -- Byter ut om den hittat en vägg
		  Min := J;        -- som är längre in
	       end if;
	       exit;
	    end if;
	 end loop;
	 
	 --- Går igenom högersidan 
	 for J in reverse X_Led'Range loop
	    if Map(I)(J) /= ' ' then
	       if J < Max then     -- Byter ut om den hittat en vägg
		  Max := J;        -- som är längre in
	       end if;
	       exit;
	    end if;
	 end loop;
      end loop;
   end Border_Min_Max;
   
   
   ---------------------------------------------------------------------
   --- Kollar om astroiden är ledig
   ---------------------------------------------------------------------
   function Free_Astroid(Astroid : in Astroid_spec) return Boolean is
      
   begin
      if Astroid.Y = 0 then
	 return True;
      else
	 return False;
      end if;
   end Free_Astroid;
   
   
   ----------------------------------------------------------------------
   --- Skickar tillbaka den första astroiden som är ledig.
   ----------------------------------------------------------------------
   procedure Find_Free_Astroid(Astroid : in Astroid_Type;
			       FreeAstroid : out Integer) is
      
   begin
      -- Går igenom alla astroider.
      -------------------------------
      for I in Astroid_Type'Range loop
	 
	 -- Kollar om astroiden är ledig
	 ---------------------------------
	 if Free_Astroid(Astroid(I)) then
	    FreeAstroid := I;              -- Hittat en ledig astroid och
	    exit;                          -- avslutar proceduren.
	 end if;
      end loop;
   end Find_Free_Astroid;
   
   
   -----------------------------------------------------------------
   --- Kontrollerar så att inga andra Astroider ligger i närheten
   -----------------------------------------------------------------
   procedure Spawn_Point(Astroid     : in Astroid_Type;
			 SpawnPoint  : out Integer) is
      
      type Spawn_Array is array (1 .. Astroid_Type'Last) of Integer; 
      
      -------------------------------------------------------------
      -- Kollar om någon annan astorid har samma X värde.
      -------------------------------------------------------------
      function Is_X_Spawn_OK(Astroid : in Astroid_Type;
			   Spawn   : in Integer) return Boolean is
	 Check : Boolean := True;
      begin
	 
	 -- Går igenom alla Astroider
	 --------------------------------
	 for I in Astroid_Type'Range loop
	    if Astroid(I).X /= Spawn then
	       Check := True;
	    else
	       Check := False;
	       exit;
	    end if;
	 end loop;
	 
	 --- skickar tillbaka resultatet
	 -------------------------------
	 if Check then
	    return True;
	 else
	    return False;
	 end if;
	 
      end Is_X_Spawn_OK;
      -------------------------------------------------------------
      
      -------------------------------------------------------------
      -- Kollar om någon annan astroid har flyttats 3 rutor.
      -------------------------------------------------------------
      function Is_Y_Spawn_OK(Astroid : in Astroid_Type) return Boolean is
	 
	 Check : Boolean := True;
	 
      begin
	 
	 -- Går igenom alla Astroider
	 --------------------------------
	 for I in Astroid_Type'Range loop
	    if Astroid(I).Y > 6-Difficult or Astroid(I).Y = 0 then
	       Check := True;
	    else
	       Check := False;
	       exit;
	    end if;
	 end loop;
	 
	 -- Skickar tillbaka resultatet.
	 ---------------------------------
	 if Check then
	    return True;
	 else
	    return False;
	 end if;
	 
      end Is_Y_Spawn_OK;
      -------------------------------------------------------------
      
      
      Spawn : Spawn_Array;
      K     : SpawnCoordinate.Generator;
      
   begin
      SpawnCoordinate.Reset(K);
      for I in Spawn_Array'range loop
	 --- Generate random values where it can spawn
	 ------------------------------------------------
	 Spawn(I) := SpawnCoordinate.Random(K);
	 
	 -- Check if same X Value
	 ---------------------------------------------------
	 if Is_X_Spawn_Ok(Astroid,Spawn(I)) then
	    
	    -- Check if last Astroid have travled __
	    -----------------------------------------------
	    if Is_Y_Spawn_Ok(Astroid) then
	       SpawnPoint := Spawn(I);
	       exit;
	    end if;
	 end if;
      end loop;
      
   end Spawn_Point;
   
   
   -----------------------------------------------------------
   --- Genererar Astroider om möjlig!
   -----------------------------------------------------------
   procedure Gen_Astroid(Map     : in World;
			 Astroid : in out Astroid_Type;  
			 Chance  : in Integer;
			 form    : in Integer) is
      
      X            : Chance_To_Spawn.Generator;
      X_Min, X_Max : Integer;
      Spawn        : Integer;
      FreeAstroid  : Integer;
      
   begin
      -- Sannolikheten att den spawnar en astroid.
      -- 1 = 10% .. 10 = 100% (Det är inte helt 100% då andra variablar under påverkar)
      --------------------------------------------
      Chance_To_Spawn.Reset(X);
      if Chance_To_Spawn.Random(X) in 1 .. Chance then
      
	 --- Räknar hur långt in väggen är maximalt från varje sida.
	 ----------------------------------------------------------------
	 Border_Min_Max(Map, X_Min, X_Max);
	 
	 
	 --- Kontrollerar så att inga andra Astroider har samma spawn point.
	 --- Och skickar tillbaka en ledig Astroid.
	 -----------------------------------------------------------------
	 Spawn_Point(Astroid, Spawn);
	 
	 
	 --- Letar upp en ledig astroid
	 --------------------------------------
	 Find_Free_Astroid(Astroid, FreeAstroid);
	 
	 
	 --- Kontrollerar om spawn positionen är innanför väggarna
	 --- Med lite marginal & säkerhetskontrollerar FreeAstroid
	 -----------------------------------------------------------------
	 if (X_Min + form) < Spawn and (X_Max - 1 - Form) > Spawn and 
	   FreeAstroid in Astroid_Type'Range then -- FreeAstroid kan annars få 
	                                          -- sjukt höga värden och ställa
	                                          -- till det i koden under.
	    Astroid(FreeAstroid).X := Spawn;
	    Astroid(FreeAstroid).Y := 1;
	    Astroid(FreeAstroid).Form := Form;
	    
	 end if;
	 
      end if;	 
   end Gen_Astroid;
   
   
   --- Flyttar ner alla aktiva astroider 
   -----------------------------------------------------------
   procedure Move_Astroid(Astroid : in out Astroid_Type) is
      
   begin
      for I in Astroid_Type'Range loop
	 if Astroid(I).Y /= 0 then
	    if Astroid(I).Y > Y_Height then
	       Astroid(I).Y := 0;
	    else
	       Astroid(I).Y := Astroid(I).Y +1;
	    end if;
	 end if;
      end loop;
   end Move_Astroid;
   
   
   --------------------------------------------------------------------
   -- Returerar Boolean om någon astroid finns vid X,Y koordinaterna.
   ---------------------------------------------------------------------
   function Is_Astroid_There(Astroid : in Astroid_Spec;
			     X       : in Integer;
			     Y       : in Integer) return Boolean is
      
      Check : Boolean := False;
      
   begin
      
      if Astroid.Form = 1 then
	 if (Astroid.Y = Y or Astroid.Y = Y-1) and
	   (Astroid.X = X or Astroid.X = X-1) then
	    Check := True;
	 else
	    Check := False;
	 end if;
	 
      elsif Astroid.Form = 2 then
	 if Astroid.Y = Y and Astroid.X = X-1 then
	    Check := True;
	 elsif (Astroid.Y = Y-1 or Astroid.Y = Y-2) and
	   (Astroid.X = X or Astroid.X = X-1 or Astroid.X = X-2) then
	    Check := True;
	 else
	    Check := False;
	 end if;
      end if;
      
      if Check then
	 return True;
      else
	 return False;
      end if;
   end Is_Astroid_There;
   
   
   
   --------------------------------------------------------------------
   -- Returerar Boolean om någon astroid finns vid X,Y koordinaterna.
   ---------------------------------------------------------------------
   function Is_Astroid_There(Astroid : in Astroid_Type;
			     X       : in Integer;
			     Y       : in Integer) return Boolean is
      
      Check : Boolean := False;
      
   begin
      for I in Astroid_Type'Range loop
	 if Is_Astroid_There(Astroid(I),X,Y) then
	    Check := True;
	    exit;
	 else
	    Check := False;
	 end if;
      end loop;
      
      if Check then
	 return True;
      else
	 return False;
      end if;
      
   end Is_Astroid_There;
   
   
   -----------------------------------------------------------------------
   -- Returerar astroidens nummret i Astroid arrayen som finns på X,Y koordinaterna.
   -----------------------------------------------------------------------
   procedure Get_Astroid_Nr(Astroid : in Astroid_Type;
			    X       : in Integer;
			    Y       : in Integer;
			    Nr      : out Integer) is
      
   begin
      for I in Astroid_Type'Range loop
	 if Is_Astroid_There(Astroid(I),X,Y) then
	    Nr := I;
	    exit;
	 else Nr := 0;
	 end if;
      end loop;
   end Get_Astroid_Nr;
   
   
   
   ---------------------------------------------------------------------
   -- Tar bort och återställer en fallande Astroid med Astroid nummer
   ---------------------------------------------------------------------
   procedure Remove_Astroid(Astroid : in out Astroid_Type;
			    Nr      : in Integer) is
      
   begin
      Astroid(Nr).Y := 0;
   end Remove_Astroid;
      
   
   ---------------------------------------------------------------------
   -- Tar bort och återställer en fallande Astroid med X,Y koordinater.
   ---------------------------------------------------------------------
   procedure Remove_Astroid(Astroid : in out Astroid_Type;
			    X       : in Integer;
			    Y       : in Integer) is
      
   begin
      for I in Astroid_Type'Range loop
	 if Is_Astroid_There(Astroid(I),X,Y) then
	    Astroid(I).Y := 0;
	 end if;
      end loop;
   end Remove_Astroid;
   
   
   --- Skriver ut alla astroider.
   ------------------------------------------------------------
   procedure Put_Astroid(Astroid : in Astroid_Type;
			 X   : in Integer;
			 Y   : in Integer) is
      
      procedure Put_Form(Item : in Astroid_spec;
			 X   : in Integer;
			 Y   : in Integer) is
	 
      begin
	 if Item.Form = 1 then
	    Goto_XY(Item.X+X-1,Item.Y+Y-1);
	    Put('/');
	    Put('\');
	    Goto_XY(Item.X+X-1,Item.Y+Y);
	    Put('\');
	    Put('/');
	 elsif Item.Form = 2 then
	    Goto_XY(Item.X+X,Item.Y+Y-1);
	    Put('_');
	    Goto_XY(Item.X+X-1,Item.Y+Y);
	    Put('/');
	    Put(' ');
	    Put('\');
	    Goto_XY(Item.X+X-1,Item.Y+Y+1);
	    Put('\');
	    Put('_');
	    Put('/');
	 end if;
      end Put_Form;
      
   begin
      -- Går igenom och kollar vilka astroider som faller
      -------------------------------------------------------
      for I in Astroid_Type'Range loop
	 if Astroid(I).Y /= 0 then
	    Put_Form(Astroid(I),X,Y);
	 end if;
      end loop;
   end Put_Astroid;
end Space_Map;
