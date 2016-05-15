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
   
   
   -- Sannolikheten att en astroid börjar falla
   ---------------------------------------------------------------------------
   subtype One_To_10 is Integer range 1..10;
   package One_To_10_Random is
      new Ada.Numerics.Discrete_Random(Result_Subtype => One_To_10);
   
   
   -- Generera en X-position som Astroiden kan börja på
   ---------------------------------------------------------------------------
   subtype Left_To_Right is Integer range Left_Border .. Right_Border-1;
   package Spawn_Range is
      new Ada.Numerics.Discrete_Random(Result_Subtype => Left_To_Right);
   
   
   
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
   procedure Make_Straight_Wall(Map          : in out World;
				Border_Number : in Integer) is
     
     
   begin
      Map(1)(Border_Number) := ('3');
   end Make_Straight_Wall;

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
   procedure New_Top_Row(Map      : in out Definitions.World;
			 Straight : in Boolean := False;
			 Open     : in Boolean := False;
			 Close    : in Boolean := False;
			 Left     : in Boolean := False;
			 Right    : in Boolean := False) is
      
      G,M : Wall_Generation.Generator;
      Wall_Left_Randomize : Integer;
      Wall_Right_Randomize : Integer;
      
   begin
      Wall_Generation.Reset(G);
      Map(1) := (others => '0');
                        
	 
	 if Straight then                          --┃       ┃
	    Make_Straight_Wall(Map, Left_Border);  --┃       ┃
	    Make_Straight_Wall(Map, Right_Border); --┃       ┃
	    
	 elsif Open then
	    
	    if Left_Border > 1 then               --┗┓     ┏┛
	       Make_Left_Wall(Map, Left_Border);  -- ┗┓   ┏┛
	    else                                  --  ┗┓ ┏┛
	       Make_Straight_Wall(Map, Left_Border);
	    end if;
	    
	    if Right_Border < World_X_Length then
	       Make_Right_Wall(Map, Right_Border);
	    else
	       Make_Straight_Wall(Map, Right_Border);
	    end if;  	 
	 elsif Left then
	    
	    if Left_Border > 1 then               --┗┓     ┗┓
	       Make_Left_Wall(Map, Left_Border);  -- ┗┓     ┗┓
	    else                                  --  ┗┓     ┗┓
	       Make_Straight_Wall(Map, Left_Border);
	    end if;
	    
	    if Border_Difference(Map) > 5 then
	       Make_Left_Wall(Map, Right_Border);
	    else
	       Make_Straight_Wall(Map, Right_Border);
	    end if;  	 
	 elsif Right then
	    if Border_Difference(Map) > 5 then    --  ┏┛    ┏┛
	       Make_Right_Wall(Map, Left_Border); -- ┏┛    ┏┛
	    else                                  --┏┛    ┏┛
	       Make_Straight_Wall(Map, Left_Border);
	    end if;
	    
	    if Right_Border < World_X_Length then
	       Make_Right_Wall(Map, Right_Border);
	    else
	       Make_Straight_Wall(Map, Right_Border);
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
		  Make_Straight_Wall(Map, Left_Border);-- ┃
	       end if;
	       
	    elsif Wall_Left_Randomize = -1 then        -- Moves to the Left
	       Make_Left_Wall(Map, Left_Border);       -- ┗┓
	       
	    elsif Wall_Left_Randomize = 1 then         -- Moves to the Right
	       Make_Right_Wall(Map, Left_Border);      -- ┏┛
	       
	    else
	       Make_Straight_Wall(Map, Left_Border);   -- ┃
	    end if;
	    
	    -------------
	    --| Right |--
	    -------------	 
	    Wall_Right_Randomize := Wall_Generation.Random(G);
	    
	    if Right_Border = World_X_Length then          -- Furthest to the right wall 	 
	       if Wall_Right_Randomize = 1 then
		  Make_Left_Wall(Map, Right_Border);       -- ┗┓
	       else
		  Make_Straight_Wall(Map, Right_Border);   -- ┃
	       end if;
	       
	    elsif Wall_Right_Randomize = 1 then            -- Moves to the Right 
	       Make_Right_Wall(Map, Right_Border);         -- ┏┛
	       
	    elsif Wall_Right_Randomize = -1 then           -- Moves to the Left
	       Make_Left_Wall(Map, Right_Border);          -- ┗┓
	       
	    else
	       Make_Straight_Wall(Map, Right_Border);      -- ┃
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
   
   -------------------------------------------------------
   --| Räknar fram avståndet mellan väggarna
   -------------------------------------------------------
   function Border_Difference(Map : in World) return Integer is
      
      Min, Max : Integer;
      Diff     : Integer := World_X_Length;
   begin
      -- Går igeom alla rader (Y-led)
      for I in World'First+1 .. World'last loop
	 -- Startvärdern
	 Max := World_X_Length;
	 Min := 1;
	 
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
	 if Max-Min < Diff then
	    Diff := Max-Min;
	 end if;
      end loop;
      
      return Diff;
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

   ------------------------------------------------------------------------------------------------------------
   ------------------------------------------------------------------------------------------------------------
   ------------------------------------------------------------------------------------------------------------
   ------------------------------------------------------------------------------------------------------------
   ------------------------------------------------------------------------------------------------------------
   
   
   -----------------------------------------------------------
                                        --| CREATE ASTROID |--
   -----------------------------------------------------------
   procedure Create_Astroid (X, Y         : in Integer;
			     Astroid_List : in out Object_List) is
      
   begin
      
      Create_Object(ShotType(8), X, Y, Down, Astroid_List);
      
   end Create_Astroid;   
   -----------------------------------------------------------
   --| END CREATE ASTROID |--
   -----------------------------------------------------------
   
   
   
   
   -----------------------------------------------------------
                                     --| ASTROID GENERATOR |--
   -----------------------------------------------------------
   procedure Astroid_Generator(Spawn_X         : in Integer;
			       Astroid         : in Setting_Type;
			       Astroid_List    : in out Object_list) is
      
      Astroid_Probability : Integer;
      Chance_To_Spawn :  One_To_10_Random.Generator;
      
   begin
      
      One_To_10_Random.Reset(Chance_To_Spawn);
      Astroid_Probability := One_To_10_Random.Random(Chance_To_Spawn);
      
      if Astroid_Probability <= Astroid.Difficulty then
	 Create_Astroid(Spawn_X, Spawn_Y, Astroid_List);
      end if;
      
   end Astroid_Generator;
   -----------------------------------------------------------
   --| END ASTROID GENERATOR |--
   -----------------------------------------------------------
   
   
   
   -----------------------------------------------------------
                                    --| CHECK NEAR ASTROID |--
   -----------------------------------------------------------
   function Too_Close_Astroid(Spawn : in Integer;
			      L     : in Object_List) return Boolean is
      Margin : Integer := 2;
      
   begin
      
      if not Empty(L) then  
	 
	 if L.XY_Pos(2) in Spawn_Y..Spawn_Y+Margin then --| koller om någon astroid
						  --| har samma Y position
	    
	    
	    --| Om samma Y position, koller så att 
	    --| astroiden inte har samma X position.
	    if L.XY_Pos(1) not in (Spawn - 1)..(Spawn + 1) then 
	       return Too_Close_Astroid(Spawn, L.Next);  --| Rekursion
	    else
	       return True;
	    end if;
	    
	 else
	    return Too_Close_Astroid(Spawn, L.Next);  --| Rekursion
	 end if;
	 
      else
	 return False;
      end if;
   end Too_Close_Astroid;
   -----------------------------------------------------------
   --| END CHECK NEAR ASTROID |--
   -----------------------------------------------------------
   
   
   
   
   -----------------------------------------------------------
                                        --| SPAWN ASTROID  |--
   -----------------------------------------------------------
   procedure Spawn_Astroid(Astroid_List : in out Object_List;
			   Astroid      : in Setting_Type;
			   Map          : in World) is
      
      X_Coord  : Spawn_Range.Generator;
      Spawn_X  : Integer;
      
   begin
      Spawn_Range.Reset(X_Coord);
      Spawn_X := Spawn_Range.Random(X_Coord)+GameBorder_X;
      
      if Spawn_X-GameBorder_X in Border_Left(Map, 1)+2..Border_Right(Map, 1)-5 then
	 
	 if not Too_Close_Astroid(Spawn_X, Astroid_List) then
	    Astroid_Generator(Spawn_X, Astroid, Astroid_List);
	 end if;
	 
      end if;
   end Spawn_Astroid;
   -----------------------------------------------------------
   --| END SPAWN ASTROID  |--
   -----------------------------------------------------------
   

end Map_Handling;
