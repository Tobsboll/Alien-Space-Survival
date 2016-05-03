with Definitions;               use Definitions;
with TJa.Sockets;               use TJa.Sockets;
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Integer_Text_IO;       use Ada.Integer_Text_IO;
with Object_Handling;           use Object_Handling;
with Ada.Numerics.Discrete_Random;
with Ada.Unchecked_Deallocation;






package Enemy_Ship_Handling is
   
   
   --------------------------------------------------
   -- TYPES
   --------------------------------------------------
   
   type Enemy_Ship_Type;
   
   type Enemy_List is
     access Enemy_Ship_Type;
   
   type Enemy_Ship_Type is
      record
	 Enemy_Type        : Integer;
	 Direction         : Integer; -- +/- 1
	 Movement_Type     : Integer;
	 XY                : XY_Type;
	 Num_Lives         : Integer;
	 Difficulty        : Integer;
	 Next              : Enemy_List;
      end record;
   
   type Enemy_List_Array is
     array (1..4) of Enemy_List;
   
      type Enemy_List_Array_2 is	
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
   
   procedure Insert_Ship_first(Ship : in out Enemy_Ship_Type;
			       Enemies : in out Enemy_List);
   procedure Insert_Ship_ordered(Ship : in out Enemy_Ship_Type;
				 Enemies : in out Enemy_list);
			       
   procedure Spawn_Ship(Enemy_Type, X, Y, Difficulty, Num_Lives, Direction, Movement_Type : in Integer;
			Enemies_List : in out Enemy_List);
   procedure Spawn_Wave(Num_To_Spawn  : in Integer;
                        Enemy_Type    : in Integer;
		        Movement_Type : in Integer;
		        Direction     : in Integer;
		        Enemies_List  : in out Enemy_List);
   function Get_Closest_Player(Enemy_X : in Integer;
			       Players : in Player_Array) return Integer;
   procedure Chase(Player_X : in Integer; 
		   Enemies  : in out Enemy_List;
		   Waves    : in out Enemy_List_Array;
		   Shot_List : in out Object_list);
   
   procedure Update_Enemy_Position(Waves : in out Enemy_List_Array;
				   Shot_List : in out Object_List;
				   Obstacle_Y: in Integer;
				   Players : in Player_array);
   function Last_List(All_Enemies : in Enemy_List_Array) return Integer;
   function At_Lower_limit(Enemies : in Enemy_List) return Boolean;
   function Next_To_Wall(Enemies : in Enemy_List) return Boolean;
   procedure Move_To_Side(Enemies : in out Enemy_List);
   procedure Change_Movement_Type(Enemies  : in out Enemy_List;
				  New_Type : in Integer);
   procedure Change_Direction(Enemies : in out Enemy_List);
   procedure Remove_Ship(Enemies : in out Enemy_List);
   procedure Destroy_Ship(Enemies   : in out Enemy_List;
			  Hit_Coord : in XY_Type);
   procedure Put_Enemy_Ships(Enemies : in Enemy_List;
			     Socket  : in Socket_Type);
   procedure Get_Enemy_Ships(Enemies : in out Enemy_List;
   			     Socket  : in Socket_Type);
   procedure Create_Enemy_Shot(Enemy_Type, X, Y : in Integer;
   			       Shot_List : in out Object_List);
   procedure Shot_Generator(Enemies : in out Enemy_List;
			    Waves   : in out Enemy_List_Array;
   			    Chance_For_Shot : in out Generator;
			    Shot_List : in out Object_List);
   procedure Delete_Enemy_list(Enemies : in out Enemy_List);
   function Empty(L : in Enemy_List) return Boolean;
   function Ok_To_Shoot(X, Y, Delta_X : in Integer;
			Waves : in Enemy_List_Array) return Boolean;
   
   function Ok_To_Shoot_Single_List(X, Y, Delta_X : in Integer;
			Enemies : in Enemy_List) return Boolean;
   function Greatest_Y_Value(Y : in Integer;
			     Enemies : in Enemy_List) return Boolean;
   
   
   
   
   procedure Free is
      new Ada.Unchecked_Deallocation(Enemy_Ship_Type, Enemy_List);

   

   
   
   
      
	
   
     
  
end Enemy_Ship_Handling;


