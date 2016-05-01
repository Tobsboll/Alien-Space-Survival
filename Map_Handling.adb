with Ada.Text_IO;                       use Ada.Text_IO;
with Ada.Integer_Text_IO;               use Ada.Integer_Text_IO;
with tja.window.Elementary;             use tja.window.Elementary;
with Ada.Numerics.Discrete_Random;

package body Map_Handling is
   
   -- Används till att bestämma om väggen ska gå till vänster eller höger
   ---------------------------------------------------------------------------
   subtype MinusTwo_To_Two is Integer range -2 .. 2;
   package Wall_Generation is
      new Ada.Numerics.Discrete_Random(Result_Subtype => MinusTwo_To_Two);
   
   
   
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
   -- Tar emot banan från servern
   ----------------------------------------------------------  
   procedure Get_Map(Socket       : in  Socket_Type;
		     Data         : out Game_Data;
		     Check_Update : in  Boolean := True) is
      
      Gen_Map_Active : Integer := 1;
      
   begin
      if Check_Update then	 
	 Get(Socket, Gen_Map_Active);              -- Check if new map
      end if;
      
      if Gen_Map_Active = 1 then
	 
   	 Data.Settings.Generate_Map := True;       -- Randomize of wall is active
	 
	 for I in World'Range loop
	    for J in X_Led'Range loop
	       Get(Socket, Data.Map(I)(J));        -- Recives the map.
	    end loop;
	 end loop;
	 
      elsif Gen_Map_Active = 0 then
	 
   	 Data.Settings.Generate_Map := False;      -- Randomize of wall is inactive
	 
      end if;
   end Get_Map;
   
   ----------------------------------------------------------
   -- Skickar banan till klient
   ----------------------------------------------------------  
   procedure Send_Map(Socket       : in Socket_Type;
		      Data         : in Game_Data;
		      Check_Update : in Boolean := True) is
      
   begin
      if Check_Update then
	 if Data.Settings.Generate_Map then            -- Skickar banan om den generarar väggar
	    
	    Put_Line(Socket, 1);
	    
	 elsif Data.Settings.Generate_Map = False then -- Genererar inte ny vägg ( Ingen uppdatering )
	    
	    Put(Socket, 0);
	    
	 end if;
      end if;
      
      if not Check_Update or Data.Settings.Generate_Map then
	 for I in World'Range loop
	    for J in X_Led'Range loop
	       Put_line(Socket, Data.Map(I)(J)); -- Skickar Banan till klienterna
	    end loop;
	 end loop;   
      end if;      
      
   end Send_Map;
   
   
   ----------------------------------------------------------
   -- Genererar en helt vanlig bana som har raka väggar
   ----------------------------------------------------------
   procedure Generate_World(Map : out Definitions.World) is
      
   begin  
      for I in World'Range loop
	 for J in X_Led'Range loop
	    if (J) = (X_Led'first) then
	       Map(I)(J) := '3';
	    elsif (J) = (X_Led'Last) then
	       Map(I)(J) := '3';
	    else
	       Map(I)(J) := '0';
	    end if;
	 end loop;
      end loop;
   end Generate_World;
   
   procedure Put_Space(Width : in Integer;
		       Colour: in Colour_Type) is
      
   begin
      Set_Background_Colour(Colour);
      for I in 1 .. Width loop
	 Put(' ');
      end loop;
   end Put_Space;
   
   
   ----------------------------------------------------------
   -- Skriver ut banan
   -----------------------------------------------------------
   procedure Put_World(Map             : World;
		       X               : Integer;
		       Y               : Integer;
		       Wall_Background : Colour_Type;
		       Wall_Line       : Colour_Type) is
      
   begin
      
      for I in World'First+1..World'last loop
	 
	 -----------------
	 --| Left Side |--
	 -----------------
      	 Goto_XY(X, Y+I-1);
	 if Map(I)(Border_Left(Map,I)) ='3' then  -- Straigt
	    Put_Space(Border_Left(Map,I)-1,Wall_Background);
	    Set_Colours(Game_Wall_Worm, Wall_Line);
	    Put("┃");
	 else
	    Put_Space(Border_Left(Map,I)-2,Wall_Background);
	    Set_Colours(Game_Wall_Worm, Wall_Line);
	    if Map(I)(Border_Left(Map,I)) = '2' then -- Turn Left
	       
	       Put("┗"); Put("┓");
	       
	    elsif Map(I)(Border_Left(Map,I)) = '5' then -- Turn Right
	       
	       Put("┏"); Put("┛");
		  
	    end if;
	 end if;
	 
	 ------------------
	 --| Right Side |--
	 ------------------
	 Goto_XY(X+Border_Right(Map,I)-1, Y+I-1);
	 if Map(I)(Border_Right(Map,I)) ='3' then -- Straigt
	    Put("┃");
	    Put_Space(World_X_Length-Border_Right(Map,I),Wall_Background);
	 else
	    if Map(I)(Border_Right(Map,I)) = '1' then -- Turn Left
	       
	       Put("┗"); Put("┓");
	       
	    elsif Map(I)(Border_Right(Map,I)) = '4' then -- Turn Right
	       
	       Put("┏"); Put("┛");
		  
	    end if;
	    Put_Space(World_X_Length-Border_Right(Map,I)-1,Wall_Background);
	 end if;
	 
      end loop;
      
   end Put_World;
   
   --------------------------------------------------------------
   --| Gör en rak vägg.
   --------------------------------------------------------------
   procedure Make_Straigt_Wall(Map          : in out World;
			      Border_Number : in Integer) is
     
     
   begin
      Map(1)(Border_Number) := ('3');
   end Make_Straigt_Wall;

   --------------------------------------------------------------
   --| Gör en vägg åt vänster
   --------------------------------------------------------------
   procedure Make_Left_Wall(Map           : in out World;
			    Border_Number : in out Integer) is
     
     
   begin
      Map(1)(Border_Number-1..Border_Number) := ('1','2');
      Border_Number := Border_Number - 1;
   end Make_Left_Wall;
   
   --------------------------------------------------------------
   --| Gör en vägg åt Höger
   --------------------------------------------------------------
   procedure Make_Right_Wall(Map           : in out World;
			     Border_Number : in out Integer) is
      
      
   begin
      Map(1)(Border_Number..Border_Number+1) := ('4','5');
      Border_Number := Border_Number + 1;
   end Make_Right_Wall;
   
   --------------------------------------------------------------
   --| Genererar en ny vägg kant på var sida.
   --------------------------------------------------------------
   procedure New_Top_Row(Map     : in out Definitions.World;
			 Straigt : in Boolean := False;
			 Open    : in Boolean := False;
			 Close   : in Boolean := False) is
      
      G,M : Wall_Generation.Generator;
      Wall_Left_Randomize : Integer;
      Wall_Right_Randomize : Integer;
      Wall_Left_Max  : Integer;
      Wall_Right_Max : Integer;
      
   begin
      Wall_Generation.Reset(G);
      Map(1) := (others => '0');
      Border_Min_Max(Map, Wall_Left_Max, Wall_Right_Max);
      
      if Border_Difference(Map) < 30 and Left_Border > 1 and
	   Right_Border < World_X_Length then 
	                                      
	 Make_Right_Wall(Map, Right_Border);  -- ┗┓   ┏┛
	 Make_Left_Wall(Map, Left_Border);    --  ┗┓ ┏┛
	 
      else                      
	 
	 if Straigt then                         --┃       ┃
	    Make_Straigt_Wall(Map, Left_Border); --┃       ┃
	    Make_Straigt_Wall(Map, Right_Border);--┃       ┃
	    
	 elsif Open then
	    
	    if Left_Border > 1 then                --┗┓     ┏┛
	       Make_Right_Wall(Map, Right_Border); -- ┗┓   ┏┛
	    else                                   --  ┗┓ ┏┛
	       Make_Straigt_Wall(Map, Right_Border);
	    end if;
	    
	    if Right_Border < World_X_Length then
	       Make_Left_Wall(Map, Left_Border);
	    else
	       Make_Straigt_Wall(Map, Left_Border);
	    end if;  
	    
	 elsif Close then                        --  ┏┛ ┗┓
	    Make_Right_Wall(Map, Left_Border);   -- ┏┛   ┗┓
	    Make_Left_Wall(Map, Right_Border);   --┏┛     ┗┓
	 else
	    
	    
	    
	    ------------
	    --| LEFT |--
	    ------------	 
	    Wall_Left_Randomize := Wall_Generation.Random(G);
	    
	    if Left_Border = 1 then                    -- Furthest to the left wall
	       if Wall_Left_Randomize = 1 then
		  Make_Right_Wall(Map, Left_Border);   -- ┏┛
	       else
		  Make_Straigt_Wall(Map, Left_Border); -- ┃
	       end if;
	       
	    elsif Wall_Left_Randomize = -1 then        -- Moves to the Left
	       Make_Left_Wall(Map, Left_Border);       -- ┗┓
	       
	    elsif Wall_Left_Randomize = 1 then         -- Moves to the Right
	       Make_Right_Wall(Map, Left_Border);      -- ┏┛
	       
	    else
	       Make_Straigt_Wall(Map, Left_Border);    -- ┃
	    end if;
	    
	    -------------
	    --| Right |--
	    -------------	 
	    Wall_Right_Randomize := Wall_Generation.Random(G);
	    
	    if Right_Border = World_X_Length then          -- Furthest to the right wall 	 
	       if Wall_Right_Randomize = 1 then
		  Make_Left_Wall(Map, Right_Border);       -- ┗┓
	       else
		  Make_Straigt_Wall(Map, Right_Border);    -- ┃
	       end if;
	       
	    elsif Wall_Right_Randomize = 1 then            -- Moves to the Right 
	       Make_Right_Wall(Map, Right_Border);         -- ┏┛
	       
	    elsif Wall_Right_Randomize = -1 then           -- Moves to the Left
	       Make_Left_Wall(Map, Right_Border);          -- ┗┓
	       
	    else
	       Make_Straigt_Wall(Map, Right_Border);       -- ┃
	    end if;
	 end if;
      end if;
   end New_Top_Row;
   
   
   ----------------------------------------------
   -- Flyttar ner alla rader
   -----------------------------------------------
   procedure Move_Rows_Down(Map : in out Definitions.World) is
      
   begin
      for I in reverse World'First+1 .. World'last  loop
	 for J in X_Led'Range loop
	    Map(I)(J) := Map(I-1)(J);	    
	 end loop;
      end loop;
   end Move_Rows_Down;
   
   --------------------------------------------------------------
   --- Räknar hur långt in väggen är maximalt från varje sida.
   --------------------------------------------------------------
   procedure Border_Min_Max(Map : in Definitions.World;
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
	    if Map(I)(J) /= '0' then
	       if J > Min then     -- Byter ut om den hittat en vägg
		  Min := J;        -- som är längre in
	       end if;
	       exit;
	    end if;
	 end loop;
	 
	 --- Går igenom högersidan 
	 for J in reverse X_Led'Range loop
	    if Map(I)(J) /= '0' then
	       if J < Max then     -- Byter ut om den hittat en vägg
		  Max := J;        -- som är längre in
	       end if;
	       exit;
	    end if;
	 end loop;
      end loop;
   end Border_Min_Max;
   
   -------------------------------------------------------
   --| Räknar fram avståndet mellan väggarna
   -------------------------------------------------------
   function Border_Difference(Map : in World) return Integer is
      
      Max : Integer;
      Min : Integer;
      
   begin
      Border_Min_Max(Map, Min, Max);
      return Max-Min;
   end Border_Difference;
   
   
   --------------------------------------------------------
   -- Räknar ut och skickar tillbaka vart vänster vägg är
   --------------------------------------------------------
   procedure Border_Left(Map : in Definitions.World;
			 X   : out Integer;
			 Y   : in Integer) is
      
   begin
      X  := X_Led'First;
      for J in X_Led'Range loop	    
	 if Map(Y)(J) /= '0' then
	    X := J;
	    exit;
	 end if;
      end loop;
   end Border_Left;
   
   
   
   --------------------------------------------------------
   -- Räknar ut och skickar tillbaka vart höger vägg är
   --------------------------------------------------------
   procedure Border_Right(Map : in Definitions.World;
			  X   : out Integer;
			  Y   : in Integer) is
      
   begin
      X := X_Led'Last;
      for J in reverse X_Led'Range loop
	 if Map(Y)(J) /= '0' then
	    X := J;        
	    exit;
	 end if;
      end loop;
   end Border_Right;
   
   
   --------------------------------------------------------
   -- Räknar ut och skickar tillbaka vart vänster vägg är
   --------------------------------------------------------
   function Border_Left(Map : in Definitions.World;
			Y   : in Integer) return Integer is
      
      The_Wall : Integer;
      
   begin
      for J in X_Led'Range loop	    
	 if Map(Y)(J) /= '0' then
	    if Map(Y)(J) = '4' or Map(Y)(J) = '1' then
	       The_Wall := J+1;
	    else
	       The_Wall := J;
	    end if;
	    exit;
	 end if;
      end loop;
      
      return The_Wall;
   end Border_Left;
   
   
   
   --------------------------------------------------------
   -- Räknar ut och skickar tillbaka vart höger vägg är
   --------------------------------------------------------
   function Border_Right(Map : in Definitions.World;
			 Y   : in Integer) return Integer is
      
      The_Wall : Integer;
      
   begin
      for J in reverse X_Led'Range loop
	 if Map(Y)(J) /= '0' then
	    if Map(Y)(J) = '2' or Map(Y)(J) = '5' then
	       The_Wall := J-1;
	    else
	       The_Wall := J;
	    end if;
	    exit;
	 end if;
      end loop;
      
      return The_Wall;
   end Border_Right;
   
   
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
	    if Astroid(I).Y > 6 or Astroid(I).Y = 0 then
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
	    if Astroid(I).Y > World_Y_Length then
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
end Map_Handling;
