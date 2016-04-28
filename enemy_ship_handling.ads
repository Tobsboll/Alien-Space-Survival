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
   
   
   
   --------------------------------------------------
   --Randomgenerator för fiendeskeppens skott
   --------------------------------------------------
   subtype One_To_Twenty is Integer range 1..20;
   
   
   package One_To_Twenty_Random is
      new Ada.Numerics.Discrete_Random(Result_Subtype => One_To_Twenty);
   use One_To_Twenty_Random;
   
 --  Chance_For_Shot : Generator;
   
   --------------------------------------------------
   -- PROCEDURES AND FUNCTIONS
   --------------------------------------------------
   
   procedure Spawn_ship(Enemy_Type, X, Y, Difficulty, Num_Lives, Direction, Movement_Type : in Integer;
			Enemies_List : in out Enemy_List);
   procedure Spawn_Wave(Num_To_Spawn  : in Integer;
                        Enemy_Type    : in Integer;
		        Movement_Type : in Integer;
		        Direction     : in Integer;
		        Enemies_List  : in out Enemy_List);
   procedure Update_Enemy_Position(Enemies : in out Enemy_List;
				   Shot_List : in out Object_List;
				   Obstacle_Y: in Integer);
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
   			    Chance_For_Shot : in out Generator;
			    Shot_List : in out Object_List);
   procedure Delete_Enemy_list(Enemies : in out Enemy_List);
   function Empty(L : in Enemy_List) return Boolean;	
   
   
   
   procedure Free is
      new Ada.Unchecked_Deallocation(Enemy_Ship_Type, Enemy_List);

   

   
   
   
      
	
   
     
  
end Enemy_Ship_Handling;


