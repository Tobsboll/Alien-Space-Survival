with Ada.Text_IO;             use Ada.Text_IO;
with Ada.Integer_Text_IO;     use Ada.Integer_Text_IO;
with TJa.Keyboard;            use TJa.Keyboard;
with TJa.Keyboard.Keys;       use TJa.Keyboard.Keys;
with TJa.Sockets;             use TJa.Sockets;
with Ada.Strings;             use Ada.Strings;
with TJa.Window.Text;         use TJa.Window.Text;
with Window_Handling;         use Window_Handling;
with Definitions;             use Definitions;
with Graphics;                use Graphics;

package Player_Handling is
   
   Player_Colour        : String(1..15); -- Vid inhämtning av spelarnas färger
   Player_Colour_Length : Integer;
   Keyboard_Input       : Key_Type;
   
   procedure Get_Input;
   
   procedure Get_Input(Key_Board_Input : out Key_Type);
   
   procedure Send_Input(Socket : in Socket_type);
   
   function Is_Esc return Boolean;
   
   procedure Get_String(Text        : out String;
			Text_Length : out Integer;
			Max_Text    : in Integer;
			X, Y        : in Integer;
		        Text_Col    : in Colour_Type;
			Back_Col    : in Colour_Type);
   
   ----------------------------------------------------------
   ----------------------------------------------| Server |--
   ---------------------------------------------------------- 
   procedure Put_Game_Data(Socket : Socket_Type;
		           Data : in Game_Data);
   procedure Add_Player(Listener : in Listener_Type;
			Socket   : in out Socket_Type;
			Player_Num : in integer);
   procedure Remove_Player(Socket     : in out Socket_Type; 
			   Player_Num : in Integer);
   procedure Sort_Scoreboard(Game : in out Game_Data;
			    Num_Players : in Integer);
   procedure Add_All_Players(Listener : in Listener_Type;
			     Sockets : in out Socket_Array;
			     Num_Players : out Integer);
   procedure Get_Players_Nick_Colour(Socket : in Socket_Type;
				     Player : in out Player_Type);
   procedure Send_Players_Nick_Colour(Socket : in Socket_Type;
				      Player : in Player_Type);
   
   ----------------------------------------------------------
   ----------------------------------------------| Client |--
   ---------------------------------------------------------- 
   procedure Get_Game_Data(Socket : Socket_Type;
			   Data : out Game_Data);
   procedure Put_Player_Ships (Data : in  Game_Data;
			       NumPlayers : in Integer);
   procedure Put_Score(Data        : in Game_Data; 
		       NumPlayers  : in Integer;
		       X           : in Integer;
		       Y           : in Integer;
		       Back_Colour : in Colour_Type;
		       Text_Colour : in Colour_Type);
   procedure Put_Player_Choice(Socket : in Socket_Type;
			       Choice : in Character;
			       Num_Players : in Integer);
   procedure Waiting_For_Players(Socket : in Socket_Type;
				 Num_Players : out Integer;
				 Klient_Number : out Integer);
   procedure Send_Player_Nick_Colour(Socket : in Socket_Type;
				     Player : in out Player_Type;
				     Klient_Number : in Integer);
   procedure Get_Player_Nick_Colour(Socket : in Socket_Type;
				    Player : in out Player_Type);

end Player_Handling;