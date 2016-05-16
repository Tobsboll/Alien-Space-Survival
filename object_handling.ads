with TJa.Sockets;                  use TJa.Sockets;
with Ada.Text_IO;                    use Ada.Text_IO;
with Ada.Integer_Text_IO;            use Ada.Integer_Text_IO;
with Ada.Unchecked_Deallocation;
with Definitions;                    use Definitions;

package Object_Handling is
   

   
  
   

   
   --------------------------------------------------
   --| TYPES;
   --|
   --| -shots
   --| -walls
   --| -obstacles
   --| -enemies
   --------------------------------------------------
   

   
   type Object_Data_Type;
   type Object_List is access Object_Data_Type;
   type Object_Data_Type is 
      record
	 Object_Type    : Integer; --Bestämmer vilken typ av objekt
	                           --Skott 1..10
	                           --Vägg 11..20
	                           --PowerUp 21..30
	 XY_Pos         : XY_Type; 
	 Attribute      : Integer; --Kan vara:
	                           --Skott: Direction Up/Down
	                           --Obstacle: Hårdhet Light/Hard/Unbreakable
		                   --Enemy:    Num_Lives "Health"
	 
	 -- För Spelarskotten
	 Player         : Integer;
	 
	 --För fiendeskepp exklusivt:
	 Direction      : Integer ;
	 Movement_Type  : Integer;
	 Difficulty     : Integer;
	 
	 Next           : Object_List;
	 
      end record;
   
   --------------------------------------------------
 
   
   
   procedure Put(Socket : in Socket_Type; L : in Object_List);
   procedure Put(L: in Object_List);
   procedure Get(Socket: in Socket_Type; L:in out Object_List);
   procedure Create_Object(Type_Of_Object : in Integer;
			   X,Y            : in Integer;
			   Attr           : in Integer;
			   L              : in out Object_List;
			   Player         : in Integer := 0;
			   Dir            : in Integer := 0);
   
   procedure Insert_Last  (Type_Of_Object : in Integer ;
			   X, Y           : in Integer ;
			   Attr           : in Integer ;
			   L              : in out Object_List;
			   Player         : in Integer := 0;
			   Dir            : in Integer := 0);
   
   function Highest_Y_Position(List : in Object_List;	
			       Y    : in Integer := GameBorder_Y+World_Y_Length-2) return Integer;
   function Lowest_Y_Position(List : in Object_List;
			      Y    : in Integer := 0) return Integer;
     function Lowest_X_Position(List : in Object_List;
				X    : in Integer := GameBorder_X+World_X_Length) return Integer;
   function Highest_X_Position(List : in Object_List;
			       X    : in Integer := 0) return Integer;
   --  function Length(L : in Shot_Fired) return Integer;
   function Empty(L : in Object_List) return Boolean;
   --  --  procedure Insert(Data : in Shot_Data_Type;
   --  		    L    : in out Shot_Fired);
   procedure DeleteList(L : in out Object_List);
   procedure Delete_Object_In_List(L  : in out Object_List;
				   Obj : in Integer);
   --  --function Member (Key : in Key_Type;
--		    L   : in List_Type) return Boolean;
   procedure Remove (L   : in out Object_List);
   

   
private
      procedure Free is
      new Ada.Unchecked_Deallocation(Object_Data_Type, Object_List);

   

   

   
end Object_Handling;
