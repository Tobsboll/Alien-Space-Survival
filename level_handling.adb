
package body Level_Handling is
   
   procedure Between_Levels(Loop_Counter  : in Integer;
			    Data          : in out Game_Data;
			    Astroid_List  : in out Object_List;
			    Obstacle_List : in out Object_List;
			    New_Level     : out Boolean) is
      
      Map        : World;
      Difficulty : Integer;
      Obstacle_Y : Integer;
      
   begin
      Map        := Data.Map;
      Difficulty := Data.Settings.Difficulty;
      
      
      --------------------------------------------------
      --| MOVING MAP WITH ASTROIDS 
      --------------------------------------------------
      if Loop_Counter mod 2 = 0 then
	 if Loop_Counter mod 1000 > 1 and Loop_Counter mod 1000  < 60 then
	    New_Top_Row(Map, Close => True); -- Stänger väggar
	    
	 elsif Loop_Counter mod 1000 > 160 and Loop_Counter mod 1000  < 220 then
	    New_Top_Row(Map, Left => True); -- Vänster väggar
	    
	 elsif Loop_Counter mod 1000 > 320 and Loop_Counter mod 1000 < 440 then
	    New_Top_Row(Map, Right => True); -- Höger väggar
	    
	 elsif Loop_Counter mod 1000 > 540 and Loop_Counter mod 1000 < 600 then
	    New_Top_Row(Map, Left => True); -- Vänster väggar
	    
	 elsif Loop_Counter mod 1000 > 750 then
	    New_Top_Row(Map, Open => True); -- Öppnar väggar
	    
	 else
	    Spawn_Astroid(Astroid_List, Data.Settings, Map);
	    Spawn_Astroid(Astroid_List, Data.Settings, Map);
	    New_Top_Row(Map);       -- Randomisering väggar
	 end if;
	 Move_Rows_Down(Map);       -- Flyttar ner hela banan ett steg.
      end if;
      
      --------------------------------------------------
      --| NEW ASTROIDS
      --------------------------------------------------
      if Loop_Counter mod 1000 > 750 and Loop_Counter mod 1000 < 850 then
	 Spawn_Astroid(Astroid_List, Data.Settings, Map);
	 Spawn_Astroid(Astroid_List, Data.Settings, Map);
	 Spawn_Astroid(Astroid_List, Data.Settings, Map);	    
      end if;   
      
      -- Setting Up Before The New Level
      if Loop_Counter = 875 then
	 Obstacle_y := GameBorder_Y + World_Y_Length - 4;
	 for I in 1..7-(Difficulty*2) loop
	    Create_Wall(Obstacle_List, Obstacle_Y-(I*2));	 --| NEW COVER OBJECTS
	 end loop;
      end if;
      
      
      if Loop_Counter = 900 then
	 New_Level := True;
      end if;
      
      
      Data.Map                 := Map;
      Data.Settings.Difficulty := Difficulty;
	
   end Between_Levels;
   
   
   --------------------------------------------------
   --| NEW LEVEL
   --------------------------------------------------
   procedure Spawn_Level(Level         : in out Integer;
			 Difficulty    : in out Integer;
			 Waves         : out Enemy_List_Array;
			 Level_Cleared : out Boolean;
			 New_Level     : out Boolean) is
      
      Gen       : Generator;
      Gen_Level : Integer;
      
   begin
      
      ---------------------------------------------------------
      --| New Level Setting
      ---------------------------------------------------------
      Difficulty := Difficulty + 1;
      Level := Level + 1;
      Level_Cleared := False;
      New_Level := False;
      ---------------------------------------------------------
      
      
      ---------------------------------------------------------
      --| LEVELS
      ---------------------------------------------------------
      if Level = 5 then   	 -- Spawn MID Boss
	 null;
      elsif Level = 10 then 	 -- Spawn BIG boss
	 null;
	 
      else
	 Reset(Gen);
	 Gen_Level  := Random(Gen);
	 
	 if Gen_Level = 1 then
	    Spawn_Wave(10*Difficulty, --Antal
		       EnemyType(1), --Typ
		       1,
		       1,
		       Gameborder_Y +2,
		       waves(1));
	    
	    Spawn_Wave(Integer(0.5*Float(Difficulty)), --Antal
		       EnemyType(3), --Typ
		       3,
		       1,
		       Gameborder_Y +4,
		       waves(2));
	    
	 elsif Gen_Level = 2 then
	    null;
	 elsif Gen_Level = 3 then
	    null;
	 elsif Gen_Level = 4 then
	    null;
	 elsif Gen_Level = 5 then
	    null;
	 elsif Gen_Level = 6 then
	    null;
	 elsif Gen_Level = 7 then
	    null;
	 elsif Gen_Level = 8 then
	    null;
	 end if;
      end if;
      
   end Spawn_Level;
   
   
end Level_Handling;
