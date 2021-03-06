with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with TJa.Keyboard;        use TJa.Keyboard;
with TJa.Keyboard.Keys;   use TJa.Keyboard.Keys;
with TJa.Window.Text;     use TJa.Window.Text;
with Definitions;         use Definitions;
with Player_Handling;     use Player_Handling;
with Window_Handling;     use Window_Handling;
with Score_Handling;      use Score_Handling;


package Menu_Handling is
   
   Menu_Text       : Colour_Type := Black;
   Menu_Background : Colour_Type := Dark_Grey;
   Option          : Integer := 1;   -- Saves where you are in the menu
   Choice          : Character := '0';
   Navigate_Input  : Key_Type;       -- Players navigate input
   
   procedure Put_Menu(Choice     : in out Character; -- 0 = Choose Nickname
		                                     -- 1 = Start Menu
		                                     -- 2 = Multiplayer Menu
		                                     -- 3 = Create Game Window
						     -- 4 = Highscore
		      NumPlayers : in out Integer;
		      Portadress : in out Integer;
		      Ipadress      : in out String; 
		      Player_Name   : in out String; 
		      Player_Name_Length : in out Integer
		     );
   
   procedure Put_Gameover_Box(Data          : in Game_Data;
			      Klient_Number : in Integer;
			      Choice        : in out Character);
		  
end Menu_Handling;
