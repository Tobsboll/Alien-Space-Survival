with Ada.Text_IO;             use Ada.Text_IO;
with TJa.Keyboard;            use TJa.Keyboard;
with TJa.Keyboard.Keys;       use TJa.Keyboard.Keys;
with TJa.Sockets;             use TJa.Sockets;
with Ada.Strings;             use Ada.Strings;
with TJa.Window.Text;         use TJa.Window.Text;
with Window_Handling;         use Window_Handling;

package Input is
   
   Keyboard_Input : Key_Type;
   
   procedure Get_Input;
   
   procedure Get_Input(Key_Board_Input : out Key_Type);
   
   procedure Send_Input(Socket : in Socket_type);
   
   function Is_Up_Arrow return Boolean;
   
   function Is_Down_Arrow return Boolean;
   
   function Is_Left_Arrow return Boolean;
   
   function Is_Right_Arrow return Boolean;
   
   function Is_Return return Boolean;
   
   function Is_Esc return Boolean;
   
   procedure Get_String(Text        : out String;
			Text_Length : out Integer;
			Max_Text    : in Integer;
			X, Y        : in Integer;
		        Text_Col    : in Colour_Type;
			Back_Col    : in Colour_Type);
   
   
end Input;
