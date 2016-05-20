with TJa.Window.Text;         use TJa.Window.Text;
with Ada.Text_IO;             use Ada.Text_IO;


package Window_Handling is
   
   type Echo_Type is (On, Off);
   
   procedure Put_Box(X           : in Integer;
		     Y           : in Integer;
		     Width       : in Integer;
		     Height      : in Integer;
		     Background  : in Colour_Type;
		     Text_Colour : in Colour_Type);
   
   procedure Put_Double_Line_Box(X           : in Integer;
				 Y           : in Integer;
				 Width       : in Integer;
				 Height      : in Integer;
				 Background  : in Colour_Type;
				 Text_Colour : in Colour_Type);
   
   procedure Put_Block_Box(X           : in Integer;
			   Y           : in Integer;
			   Width       : in Integer;
			   Height      : in Integer;
			   Background  : in Colour_Type;
			   Text_Colour : in Colour_Type);
   
   procedure Put_Space_Box(X           : in Integer;
			   Y           : in Integer;
			   Width       : in Integer; 
			   Height      : in Integer;
			   Background  : in Colour_Type);
   
   procedure Put_Line_Space_Box(X           : in Integer;     
				Y           : in Integer; 
				Width       : in Integer;
				Height      : in Integer;
				Background  : in Colour_Type;
				Text_Colour : in Colour_Type);
   
   procedure Clear_Window;
   
   procedure Goto_XY(X, Y : in Positive);
   
   procedure Set_Echo (Echo : in Echo_Type);
   
   procedure Set_Window_Title (Name   : in String;
			       Number : in Integer := 0);
   
   procedure Cursor_Visible;
   
   procedure Cursor_Invisible;
   
end Window_Handling;
