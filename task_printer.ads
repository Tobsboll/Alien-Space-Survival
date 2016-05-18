with Map_Handling;        use Map_Handling;
with Definitions;         use Definitions;
with TJa.Window.Text;     use TJa.Window.Text;
with Enemy_ship_handling; use Enemy_Ship_handling;
with Object_Handling;     use Object_Handling;
with Player_Handling;     use Player_Handling;
with Score_Handling;      use Score_Handling;
with Window_Handling;     use Window_Handling;
with Background_Handling; use Background_Handling;
with Menu_Handling;       use Menu_Handling;
with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Graphics;            use Graphics;

package Task_Printer is
   
   
   task Print_All is
      entry Print_Everything(D  : in Game_Data;
			     W  : in Enemy_List_array;
			     A  : in Object_List;
			     S  : in Object_List;
			     O  : in Object_List;
			     P  : in Object_List;
			     N  : in Integer;
			     G  : in Integer;
			     K  : in Integer); 
      entry Get_Choice(C : out Character);
      entry Stop;
   end Print_All;
   
   procedure Printer(D  : in Game_Data;
		     W  : in Enemy_List_array;
		     A  : in Object_List;
		     S  : in Object_List;
		     O  : in Object_List;
		     P  : in Object_List;
		     N  : in Integer;
		     G  : in Integer;
		     K  : in Integer) renames Print_All.Print_Everything;
   
   procedure Get_From_Printer(C : out Character) renames Print_All.Get_Choice;
   
   procedure Stop_Printer renames Print_All.Stop;
   
   task Astroid is
      entry Print(L : Object_List);
   end Astroid;
   
   task Shot is
      entry Print(L:Object_List);
   end Shot;
   
   task Obstacle is
      entry Print(L:Object_List);
   end Obstacle;
   
   task Powerup is
      entry Print(L:Object_List);
   end Powerup; 
   
   
   
   
end Task_Printer;
