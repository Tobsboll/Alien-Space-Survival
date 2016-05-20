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

package Print_Handling is
   
   procedure Put_All(Game          : in Game_Data;
		     Waves         : in Enemy_List_Array;
		     Powerup_List  : in Object_List;
		     Astroid_List  : in Object_List;
		     Obstacle_List : in Object_List;
		     Shot_List     : in Object_List;
		     Num_Players   : in Integer;
		     Klient_Number : in Integer;
		     Level         : in Integer;
		     Loop_Counter  : in Integer;
		     Choice        : in out Character);
   
end Print_Handling;
