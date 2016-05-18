with Definitions;           use Definitions;
with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Integer_Text_IO;   use Ada.Integer_Text_IO;
with Window_Handling;       use Window_Handling;
with TJa.Sockets;           use TJa.Sockets;
with TJa.Window.Text;       use TJa.Window.Text;
with Ada.Sequential_IO;

package Score_Handling is
   
   procedure Sort_Scoreboard(Game : in out Game_Data;
			     Num_Players : in Integer);
   procedure Put_Score(Data        : in Game_Data; 
		       NumPlayers  : in Integer;
		       X           : in Integer;
		       Y           : in Integer;
		       Back_Colour : in Colour_Type;
		       Text_Colour : in Colour_Type);
   function Does_File_Exist (Name : in String) return Boolean;
   procedure Save_Score(Player : in Player_Type);
   procedure Put_Highscore(X     : in Integer;
			   Y     : in Integer;
			   Total : in Integer);
   procedure Put_Score( Socket : in Socket_Type;
			Game   : in Game_Data);
   procedure Get_Score(Socket : in Socket_Type);
   
end Score_Handling;
