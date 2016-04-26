with Ada.Text_IO;        use Ada.Text_IO;



package body Box_Hantering is
   
   
   procedure Put_Box(X           : in Integer;        -- X Koordinat där den ska börja boxen
		     Y           : in Integer;        -- Y Koordinat där den ska börja boxen
		     Width       : in Integer;        -- Hur bred boxen ska vara.
		     Height      : in Integer;        -- Hur hög boxen ska vara.
		     Background  : in Colour_Type;    -- Bakgrundfärgen
		     Text_Colour : in Colour_Type) is -- Boxens färg
      
      Old_Background  : Colour_Type;
      Old_Text_Colour : Colour_Type;
      
      
   begin
      Old_Text_Colour := Get_Foreground_Colour;           -- Sparar den tidigare textfärgen
      Old_Background  := Get_Background_Colour;           -- Sparar den tidigare bakgrundsfärgen
      
      Set_Colours(Text_Colour, Background);               -- Ställer in dom inmatade färgerna.
      
      Set_Graphical_Mode(On);                             -- Startar grafiken.
      
      Goto_XY(X,Y);
      Put(Upper_Left_Corner);
      Put(Horisontal_Line,Width-2);
      Put(Upper_Right_Corner);
      
      for I in 1 .. Height-1 loop
	 Goto_XY(X,Y+I);
	 Put(Vertical_Line);
	 Goto_XY(X+Width-1,Y+I);
	 Put(Vertical_Line);
      end loop;
      
      Goto_XY(X,Y+Height);
      Put(Lower_Left_Corner);
      Put(Horisontal_Line,Width-2);
      Put(Lower_Right_Corner);
      
      Set_Graphical_Mode(Off);                            -- Stänger av grafiken
      
      Set_Colours(Old_Text_Colour, Old_Background);       -- Ställer tillbaka till dom tidigare färgerna.
      
   end Put_Box;
   
   
   procedure Put_Double_Line_Box(X           : in Integer;        -- X Koordinat där den ska börja boxen
				Y           : in Integer;        -- Y Koordinat där den ska börja boxen
				Width       : in Integer;        -- Hur bred boxen ska vara.
				Height      : in Integer;        -- Hur hög boxen ska vara.
				Background  : in Colour_Type;    -- Bakgrundfärgen
				Text_Colour : in Colour_Type) is -- Boxens färg
      
      Old_Background  : Colour_Type;
      Old_Text_Colour : Colour_Type;
      
      
   begin
      Old_Text_Colour := Get_Foreground_Colour;           -- Sparar den tidigare textfärgen
      Old_Background  := Get_Background_Colour;           -- Sparar den tidigare bakgrundsfärgen
      
      Set_Colours(Text_Colour, Background);               -- Ställer in dom inmatade färgerna.
      
--      Set_Graphical_Mode(On);                             -- Startar grafiken.
      
      Goto_XY(X,Y);
      Put("╔");
      for I in 1 .. Width-2 loop
	 Put("═");
      end loop;
      Put("╗");
      
      for I in 1 .. Height-1 loop
	 Goto_XY(X,Y+I);
	 Put("║");
	 Goto_XY(X+Width-1,Y+I);
	 Put("║");
      end loop;
      
      Goto_XY(X,Y+Height);
      Put("╚");
      for I in 1 .. Width-2 loop
	 Put("═");
      end loop;
      Put("╝");
      
--      Set_Graphical_Mode(Off);                            -- Stänger av grafiken
      
      Set_Colours(Old_Text_Colour, Old_Background);       -- Ställer tillbaka till dom tidigare färgerna.
      
   end Put_Double_Line_Box;
   
   procedure Put_Block_Box(X           : in Integer;        -- X Koordinat där den ska börja boxen
			   Y           : in Integer;        -- Y Koordinat där den ska börja boxen
			   Width       : in Integer;        -- Hur bred boxen ska vara.
			   Height      : in Integer;        -- Hur hög boxen ska vara.
			   Background  : in Colour_Type;    -- Bakgrundfärgen
			   Text_Colour : in Colour_Type) is -- Boxens färg
      
      Old_Background  : Colour_Type;
      Old_Text_Colour : Colour_Type;
      
      
   begin
      Old_Text_Colour := Get_Foreground_Colour;           -- Sparar den tidigare textfärgen
      Old_Background  := Get_Background_Colour;           -- Sparar den tidigare bakgrundsfärgen
      
      Set_Colours(Text_Colour, Background);               -- Ställer in dom inmatade färgerna.
      
      Goto_XY(X,Y);
      Put("▛");
      for I in 1 .. Width-2 loop
	 Put("▀");
      end loop;
      Put("▜");
      
      for I in 1 .. Height-1 loop
	 Goto_XY(X,Y+I);
	 Put("▌");
	 Goto_XY(X+Width-1,Y+I);
	 Put("▐");
      end loop;
      
      Goto_XY(X,Y+Height);
      Put("▙");
      for I in 1 .. Width-2 loop
	 Put("▄");
      end loop;
      Put("▟");      
      
      Set_Colours(Old_Text_Colour, Old_Background);       -- Ställer tillbaka till dom tidigare färgerna.
      
   end Put_Block_Box;

   
end Box_Hantering;
