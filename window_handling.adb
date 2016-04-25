with Ada.Text_IO;            use Ada.Text_IO;
with Ada.Integer_Text_IO;    use Ada.Integer_Text_IO;
with Ada.Characters.Latin_1; use Ada.Characters.Latin_1;
with System;

package body Window_Handling is
   
   
   ---------------------------------------------
   procedure Clear_Window is
      
   begin
      Put(Esc);    -- Hade varit bättre med CSI ist för Esc
                   -- Sparar då 1 tecken (Processorkraft) men men.
      
      Put("[H");   -- Flyttar markören längst upp till vänster
      Put(Esc);
      Put("[2J");  -- Rensar fönstret.
      Flush;
   end Clear_Window;
   ---------------------------------------------
   
      
   ---------------------------------------------
   procedure Goto_XY(X, Y : in Positive) is
      
   begin
      Put(Esc);
      Put('[');
      Put(Y, Width => 0);   -- Y Värdet
      Put(';');
      Put(X, Width => 0);   -- X Värdet
      Put('H');
      Flush;
   end Goto_XY;
   ---------------------------------------------
   
   
   ---------------------------------------------
   procedure Set_Echo (Echo : in Echo_Type) is
      
      procedure Execute (S : in String) is
   	 procedure System (S : in System.Address);
   	 pragma Import (C, System, "system");
   	 C_String : constant String := S & ASCII.NUL;
      begin
   	 System (C_String'Address);
      end Execute;
      pragma Inline (Execute);
      
   begin
      if Echo = Off then
   	 Execute ("stty -echo cbreak");
      else
   	 Execute ("stty echo");
      end if;
   end Set_Echo;
   ---------------------------------------------
   
   ---------------------------------------------
   procedure Set_Window_Title (Name : in String;
			       Number : in Integer := 0) is
      
   begin
      if Number = 0 then
	 Put(Esc);
	 Put("]0;");
	 Put(Name);
	 Put(Bel);     -- Avslutar med bell character (\007)
      else
	 Put(Esc);
	 Put("]0;");
	 Put(Name);
	 Put(" ");
	 Put(Number, Width => 0);
	 Put(Bel);     -- Avslutar med bell character (\007)
      end if;
	 
   end Set_Window_Title;
   ---------------------------------------------
   
   
   ---------------------------------------------
   procedure Cursor_Visible is
      
   begin
      Put(Esc);
      Put("[?25h");  -- Markören synlig (h)
      Flush;   
   end Cursor_Visible;
   ---------------------------------------------
   
   
   ---------------------------------------------
   procedure Cursor_Invisible is
      
   begin
      Put(Esc);
      Put("[?25l");  -- Markören onsynlig (l)
      Flush;   
   end Cursor_Invisible;
   ---------------------------------------------
   
end Window_Handling;
