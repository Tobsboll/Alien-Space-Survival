with Definitions;               use Definitions;
with TJa.Sockets;               use TJa.Sockets;
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Integer_Text_IO;       use Ada.Integer_Text_IO;
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
   
   --------------------------------------------------
   -- PROCEDURES AND FUNCTIONS
   --------------------------------------------------
   
   procedure Spawn_ship(Enemy_Type, X, Y, Difficulty, Num_Lives, Direction, Movement_Type : in Integer;
			Enemies_List : in out Enemy_List);
   procedure Update_Enemy_Position(Enemies : in out Enemy_List);
   function Next_To_Wall(Enemies : in Enemy_List) return Boolean;
   procedure Move_To_Side(Enemies : in out Enemy_List);
   procedure Change_Direction(Enemies : in out Enemy_List);
   
   procedure Free is
      new Ada.Unchecked_Deallocation(Enemy_Ship_Type, Enemy_List);
   
      
      
	
   
     
  
end Enemy_Ship_Handling;


