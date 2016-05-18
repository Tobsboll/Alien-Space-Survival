with Definitions;           use Definitions;
with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Integer_Text_IO;   use Ada.Integer_Text_IO;
with Window_Handling;       use Window_Handling;
with Ada.Sequential_IO;

package Score_Handling is
   
   
   
   function Does_File_Exist (Name : in String) return Boolean;
   procedure Save_Score(Player : in Player_Type);
   procedure Put_Highscore(X     : in Integer;
			   Y     : in Integer;
			   Total : in Integer);
   
   
end Score_Handling;