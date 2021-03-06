with Definitions;                  use Definitions;
with Map_Handling;                 use Map_Handling;
with Enemy_Ship_Handling;          use Enemy_Ship_Handling;
with Game_Engine;                  use Game_Engine;
with Object_Handling;              use Object_Handling;
with Ada.Numerics.Discrete_Random;

package Level_Handling is
   
   
   subtype One_To_8 is Integer range 1..8;
   package One_To_8_Random is
      new Ada.Numerics.Discrete_Random(Result_Subtype => One_To_8);
   use One_To_8_Random;
   
   Gen       : Generator;
   Wall_Dirr : Integer;
   
   
   procedure Between_Levels(Loop_Counter  : in Integer;
			    Data          : in out Game_Data;
			    Astroid_List  : in out Object_List;
			    Obstacle_List : in out Object_List;
			    New_Level     : out Boolean);
   
   procedure Spawn_Level(Level         : in out Integer;
			 Difficulty    : in out Integer;
			 Waves         : out Enemy_List_Array;
			 Level_Cleared : out Boolean;
			 New_Level     : out Boolean;
			 Num_Players   : in Integer);
   
   
   ----------------------------------------------------------------------
   --| LEVELS
   ----------------------------------------------------------------------
   procedure Kamikazee_Level ( Wave : out Enemy_List_Array);
   
   procedure Shifting_Layer_Level (Waves : out Enemy_List_Array;
				   Difficulty : in Integer);
   
   procedure Hunter_Level (Waves       : out Enemy_List_Array;
			   Difficulty  : in Integer;
			   Num_Players : in Integer);
   
   procedure Bully_Level ( Wave : out Enemy_List_Array);
   
   procedure Nitro_Bomber_Level  ( Wave : out Enemy_List_Array);
   
   procedure Ambush_Level  ( Wave : out Enemy_List_Array);
   
   procedure Enemy_Frontline_Level  ( Wave : out Enemy_List_Array);
   
   ----------------------------------------------------------------------
   --| BOSS LEVELS
   ----------------------------------------------------------------------
   procedure Spawn_Super_Inceptor  ( Wave : out Enemy_List_Array);
   
end Level_Handling;
