package Window_Handling is
   
   type Echo_Type is (On, Off);
   
   procedure Clear_Window;
   
   procedure Goto_XY(X, Y : in Positive);
   
   procedure Set_Echo (Echo : in Echo_Type);
   
   procedure Set_Window_Title (Name : in String;
			       Number : in Integer := 0);
   
   procedure Cursor_Visible;
   
   procedure Cursor_Invisible;
   
end Window_Handling;
