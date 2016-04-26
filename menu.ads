with Ada.Text_IO;       use Ada.Text_IO;
with TJa.Keyboard;      use TJa.Keyboard;
with TJa.Keyboard.Keys; use TJa.Keyboard.Keys;
with TJa.Window.Text;   use TJa.Window.Text;
with Menu_Options;      use Menu_Options;
with Definitions;       use Definitions;
with Input;             use Input;
with Window_Handling;   use Window_Handling;


package Menu is
   
   Option         : Integer := 1;   -- Saves where you are in the menu
   Navigate_Input : Key_Type;       -- Players navigate input
   
   procedure Put_Menu(Choice     : in out Character;
		      NumPlayers : in out Integer;
		      Portadress : in out Integer;
		      Ipadress      : in out String; 
		      Player_Name   : in out String; 
		      Player_Name_Length : in out Integer
		     );
   
   
end Menu;
