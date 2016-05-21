
with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Integer_Text_IO;          use Ada.Integer_Text_IO;

package body Level_Handling is
   
   procedure Between_Levels(Loop_Counter  : in Integer;
			    Data          : in out Game_Data;
			    Astroid_List  : in out Object_List;
			    Obstacle_List : in out Object_List;
			    New_Level     : out Boolean) is
      
      Map        : World;
      Difficulty : Integer;
      
   begin
      Map        := Data.Map;
      Difficulty := Data.Settings.Difficulty;
      
      
      --------------------------------------------------
      --| MOVING MAP WITH ASTROIDS 
      --------------------------------------------------
      if Loop_Counter mod 20 = 0  and Loop_Counter < 300 then
	 Reset(Gen);
	 Wall_Dirr  := Random(Gen);
      end if;
      
      if Loop_Counter mod 2 = 0 then
	 if Loop_Counter < 40 then
	    New_Top_Row(Map, Close => True); -- Stänger väggar
	 elsif Loop_Counter > 150 then
	    New_Top_Row(Map, Open => True);  -- Öppnar väggar
	 else
	    
	    if Wall_Dirr = 1 then
	       New_Top_Row(Map, Close => True); -- Stänger väggar
	       
	    elsif Wall_Dirr = 2 then
	       New_Top_Row(Map, Open => True);  -- Öppnar väggar
	       
	    elsif Wall_Dirr = 3 then
	       New_Top_Row(Map, Left => True);  -- Vänster väggar
	       
	    elsif Wall_Dirr = 4 then
	       New_Top_Row(Map, Right => True); -- Höger väggar
	       
	    else                                -- Randomisering väggar
	       New_Top_Row(Map);
	    end if;
	 end if;
	 Move_Rows_Down(Map);       -- Flyttar ner hela banan ett steg.
	 
      end if;
      
      --------------------------------------------------
      --| NEW ASTROIDS
      --------------------------------------------------
      if Loop_Counter mod 1000 < 250 then
	 Spawn_Astroid(Astroid_List, Data.Settings, Map);
	 Spawn_Astroid(Astroid_List, Data.Settings, Map);
	 Spawn_Astroid(Astroid_List, Data.Settings, Map);	    
      end if;   
      
      if Loop_Counter = 300 then
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
			 New_Level     : out Boolean;
			 Num_Players   : in Integer) is
      
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

      Reset(Gen);
      Gen_Level  := Random(Gen);
      if Gen_Level = 1 or level = 1 then
	 Spawn_Wave(10*Difficulty, --Antal
		    EnemyType(1), --Typ
		    1,
		    1,
		    Gameborder_X +1,
		    Gameborder_Y +4,
		    Difficulty,
		    waves(1));
	 
	 -- Tror den nedan kan vara ett bättre alternativ i
	 -- det generella fallet, eftersom interceptors
	 -- inte fungerar om de ligger i samma lista i nuläget // Tobias
	 
	 ---------------  

	 for I in 2..Integer(0.5*Float(Difficulty)) loop
	    
	    if I < 4 then
	       
	       Spawn_Wave(1, --Antal
			  EnemyType(3), --Typ
			  3,
			  1,
			  Gameborder_X +1,
			  Gameborder_Y +2,
			  Difficulty,
			  waves(I));
	       
	    end if;
	    
	 end loop;
	 -------------------   
	 
      elsif Gen_Level = 2 then
	 Kamikazee_Level(Waves);
      elsif Gen_Level = 3 then
	 Shifting_Layer_Level(Waves, Difficulty);
      elsif Gen_Level = 4 then
	 Hunter_Level(Waves, Difficulty, Num_Players);
      elsif Gen_Level = 5 then
	 null;
      elsif Gen_Level = 6 then
	 null;
      elsif Gen_Level = 7 then
	 null;
      elsif Gen_Level = 8 then
	 null;
      end if;
      
   end Spawn_Level;
   
    ----------------------------------------------------------------------
   --| DIFFERENT LEVELS:
   ----------------------------------------------------------------------
   
   procedure Kamikazee_Level ( Wave : out Enemy_List_Array) is
      
   begin
      for I in 0..1 loop
	 Spawn_Ship(EnemyType(4), Gameborder_X + (World_X_Length/4),
		    Gameborder_Y-10   - 20*I, 
		   
		    1, --Difficulty
		    5, --health
		    1,
		    4,
		    Wave(1+I));
	 
	 Spawn_Ship(EnemyType(4), Gameborder_X+(World_X_Length*3/4), 
	 	    Gameborder_Y  - 20*I,
	 	    1, --Difficulty
	 	    5, --health
	 	    1,
	 	    4,
	 	    Wave(3+I));
      end loop;

   end Kamikazee_Level;
   
      -----------------------------------
      -- SHIFTING_LAYER_LEVEL
      -----------------------------------
      
   procedure Shifting_Layer_Level (Waves : out Enemy_List_Array;
				   Difficulty : in Integer) is
	 
	 
	 
      begin
	 	    
	 Spawn_Wave(10,
		    Minion,
		    1,
		    1,
		    Gameborder_X +1,
		    Gameborder_Y +2,
		    Difficulty,
		    Waves(1));
	 
	 Spawn_Wave(1,
		    Kamikazee,
		    4,
		    -1,
		    Gameborder_X +1,
		    Gameborder_Y +6,
		    Difficulty,
		    Waves(2));
	 
	 Spawn_Wave(16,
		    Minion,
		    1,
		    -1,
		    Gameborder_X +1,
		    Gameborder_Y +10,
		    Difficulty,
		    Waves(3));
	 
	 Spawn_Wave(1,
		    Interceptor,
		    3,
		    1,
		    Gameborder_X +1,
		    Gameborder_Y +16,
		    Difficulty,
		    Waves(4));

	 
	 
	 
      end Shifting_Layer_Level;
      
            -----------------------------------
      -- SHIFTING_LAYER_LEVEL
      -----------------------------------
      
   procedure Hunter_Level (Waves       : out Enemy_List_Array;
			   Difficulty  : in Integer;
			   Num_Players : in Integer) is
      
      
      
      
      Space_Diff     : constant Integer := (World_X_Length/(Num_Players+1));
      Spawn_X        : Integer := Gameborder_X+75-(World_X_Length/(Num_Players+1))*Num_Players;
      Spawn_Y        : Integer := GameBorder_Y+16;
      Count_Spawn    : Integer := 1;
      New_Difficulty : Integer := Integer(Float'Ceiling(0.2 * Float(Difficulty)));
      
   begin
      for J in 1 .. Num_Players loop
	 Spawn_Wave(1,
		    Interceptor,
		    3,
		    1,
		    Spawn_X,
		    Spawn_Y,
		    Difficulty,
		    Waves(Count_Spawn));
	 
	 Spawn_X := Spawn_X + Space_Diff;
	 Count_Spawn := Count_Spawn + 1;
	 Spawn_Y := Spawn_Y - 4;   
	 
      end loop;
      
      Spawn_X  := -10;
      Spawn_Y  := Gameborder_Y;
      for I in 1 .. 2 loop
	 if Count_Spawn <= Waves'last then
	    Spawn_Wave(1,
		       Kamikazee,
		       4,
		       1,
		       Spawn_X,
		       Spawn_Y,
		       Difficulty,
		       Waves(Count_Spawn));
	    
	    Count_Spawn := Count_Spawn + 1 ;
	    Spawn_X := GameBorder_X+55;
	    
	 end if;
      end loop;
      
	 
      end Hunter_Level;
   
end Level_Handling;
