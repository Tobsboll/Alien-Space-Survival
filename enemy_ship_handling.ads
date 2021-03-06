with Definitions;               use Definitions;
with TJa.Sockets;               use TJa.Sockets;
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Integer_Text_IO;       use Ada.Integer_Text_IO;
with Object_Handling;           use Object_Handling;
with Map_Handling;              use Map_Handling;
with Ada.Numerics.Discrete_Random;
with Ada.Unchecked_Deallocation;






package Enemy_Ship_Handling is
   
   
   --------------------------------------------------
   -- TYPES
   --------------------------------------------------

   
   type Enemy_List_Array is
     array (1..4) of Object_List;
	
   
   
   --------------------------------------------------
   --Randomgenerator för fiendeskeppens skott
   --------------------------------------------------
   subtype One_To_100 is Integer range 1..100;
   
   
   package One_To_100_Random is
      new Ada.Numerics.Discrete_Random(Result_Subtype => One_To_100);
   use One_To_100_Random;
   
   --  Chance_For_Shot : Generator;
   
   
   

   
   
   --------------------------------------------------
   -- PROCEDURES AND FUNCTIONS
   --------------------------------------------------
   
   procedure Insert_Ship_first(Ship : in out Object_Data_Type;
			       Enemies : in out Object_List);
   procedure Insert_Ship_ordered(Ship : in out Object_Data_Type;
				 Enemies : in out Object_list);
			       
   procedure Spawn_Ship(Enemy_Type, X, Y, Difficulty, Num_Lives, Direction, Movement_Type : in Integer;
			Enemies_List : in out Object_List);
   procedure Spawn_Wave(Num_To_Spawn  : in Integer;
                        Enemy_Type    : in Integer;
		        Movement_Type : in Integer;
		        Direction     : in Integer;
			X_Value       : in Integer;
		        Y_Value       : in Integer;
		        Difficulty    : in Integer;
		        Enemies_List  : in out Object_List);
   function Highest_Player(Players : in Player_array) return Integer;
   
   function Get_Closest_Player(Enemy_X : in Integer;
			       Players : in Player_Array;
			       Waves   : in Enemy_List_Array) return Integer;
   function Above_Wave(Player_Y : in Integer;
		       Enemies  : in Object_list) return Boolean;
   
   procedure Chase(Player_XY : in XY_Type; 
		   Enemies  : in out Object_List;
		   Waves    : in out Enemy_List_Array;
		   Shot_List : in out Object_list);
   
   procedure Kamikazee_Chase(Player_XY : in XY_Type; 
		             Enemies   : in out Object_List;
		             Waves     : in out Enemy_List_Array;
		             Shot_List : in out Object_list);
   
   
   procedure Update_Enemy_Position(Waves : in out Enemy_List_Array;
				   Shot_List : in out Object_List;
				   Obstacle_Y: in Integer;
				   Players : in Player_array;
				   Map     : in World);
   function Last_List(All_Enemies : in Enemy_List_Array) return Integer;
   function At_Lower_limit(Enemies : in Object_List;
			   Obstacle_Y : in Integer) return Boolean;
   function Next_To_Wall(Enemies : in Object_List;
			 Map     : in World) return Boolean;
   procedure Move_To_Side(Enemies : in out Object_List);
   procedure Change_Movement_Type(Enemies  : in out Object_List;
				  New_Type : in Integer);
   procedure Move_One_Up(Enemies : in out Object_list);
   procedure Move_One_Down(Enemies : in out Object_List);
   
   procedure Change_Direction(Enemies : in out Object_List);

   procedure Create_Enemy_Shot(Enemy_Type, X, Y : in Integer;
   			       Shot_List : in out Object_List);
   procedure Shot_Generator(Enemies : in out Object_List;
			    Waves   : in out Enemy_List_Array;
   			    Chance_For_Shot : in out Generator;
			    Shot_List : in out Object_List);

   function Ok_To_Shoot(X, Y, Delta_X : in Integer;
			Waves : in Enemy_List_Array) return Boolean;
   
   function Ok_To_Shoot_Single_List(X, Y, Delta_X : in Integer;
			Enemies : in Object_List) return Boolean;
   function Greatest_Y_Value(Y : in Integer;
			     Enemies : in Object_List) return Boolean;
   function All_Enemies_Dead(Waves : in Enemy_List_array) return Boolean;
   
  
   
  
end Enemy_Ship_Handling;


