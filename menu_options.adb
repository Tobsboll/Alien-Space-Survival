with Window_Handling;         use Window_Handling;
with Box_Hantering;           use Box_Hantering;
with TJa.Window.Text;         use TJa.Window.Text;
with Ada.Text_IO;             use Ada.Text_IO;

package body Menu_options is
   
   procedure Choose_Nickname(Option : in Integer;
			     X : in Integer;
			     Y : in Integer) is
      
      Position_X   : Integer := 40 + X;
      Position_Y   : Integer := 15 + Y;
      Selected     : Colour_Type := Green;
      Non_Selected : Colour_Type := Green;
      
   begin
      
      Set_Colours(Black,Dark_Grey);
      Put_Block_Box(Position_X,Position_Y,15,5,Dark_Grey,Non_Selected);
     
      
      Goto_XY(Position_X+1, Position_Y+1);
      Put(" Nickname    ");
      Goto_XY(Position_X+2, Position_Y+3);
      Put("           ");
      
      
      if Option = 1 then
      Put_Box(Position_X+1,Position_Y+2,13,2,Dark_Grey,Selected);	 
      else
      Put_Box(Position_X+1,Position_Y+2,13,2,Dark_Grey,Non_Selected);
      end if;
      
      
      Goto_XY(Position_X+2,Position_Y+3);
      
   end Choose_Nickname;
   
   
   procedure Menu_Start(Option : in Integer;
			X      : in Integer;
			Y      : in Integer) is
      
      Position_X   : Integer := 44 + X;
      Position_Y   : Integer := 10 + Y;
      Selected     : Colour_Type := Blue;
      Non_Selected : Colour_Type := Green;
      
   begin
      Set_Colours(Black,Dark_Grey);
      
      if Option = 1 then
      Put_Block_Box(Position_X,Position_Y,13,2,Dark_Grey,Selected);	 
      else
      Put_Block_Box(Position_X,Position_Y,13,2,Dark_Grey,Non_Selected);
      end if;
      
      Goto_XY(Position_X+1, Position_Y+1);
      Put("   START   ");
      
      if Option = 2 then
      Put_Block_Box(Position_X,Position_Y+4,13,2,Dark_Grey,Selected);	 
      else
	 Put_Block_Box(Position_X,Position_Y+4,13,2,Dark_Grey,Non_Selected);
      end if;
      Goto_XY(Position_X+1, Position_Y+5);
      Put("Multiplayer");
            
      if Option = 3 then
      Put_Block_Box(Position_X,Position_Y+8,13,2,Dark_Grey,Selected);	 
      else
      Put_Block_Box(Position_X,Position_Y+8,13,2,Dark_Grey,Non_Selected);
      end if;
      Goto_XY(Position_X+1, Position_Y+9);
      Put(" Settings  ");
                    
      if Option = 4 then
      Put_Block_Box(Position_X,Position_Y+12,13,2,Dark_Grey,Selected);	 
      else 
      Put_Block_Box(Position_X,Position_Y+12,13,2,Dark_Grey,Non_Selected);
      end if;
      Goto_XY(Position_X+1, Position_Y+13);
      Put("  Credits  ");
            
      if Option = 5 then
      Put_Block_Box(Position_X,Position_Y+16,13,2,Dark_Grey,Selected);	 
      else
      Put_Block_Box(Position_X,Position_Y+16,13,2,Dark_Grey,Non_Selected);
      end if;
      Goto_XY(Position_X+1, Position_Y+17);
      Put("   Exit    ");
      
   end Menu_Start;
   
   procedure Menu_Multiplayer(Option : in Integer;
			      X      : in Integer;
			      Y      : in Integer) is
      
      Position_X   : Integer := 44 + X;
      Position_Y   : Integer := 10 + Y;
      Selected     : Colour_Type := Blue;
      Non_Selected : Colour_Type := Green;
      
   begin
      Set_Colours(Black,Dark_Grey);
      
      if Option = 1 then
      Put_Block_Box(Position_X,Position_Y,13,2,Dark_Grey,Selected);	 
      else
      Put_Block_Box(Position_X,Position_Y,13,2,Dark_Grey,Non_Selected);
      end if;
      
      Goto_XY(Position_X+1, Position_Y+1);
      Put("   Join    ");
      
      if Option = 2 then
      Put_Block_Box(Position_X,Position_Y+4,13,2,Dark_Grey,Selected);	 
      else
	 Put_Block_Box(Position_X,Position_Y+4,13,2,Dark_Grey,Non_Selected);
      end if;
      Goto_XY(Position_X+1, Position_Y+5);
      Put("  Create   ");
            
      if Option = 3 then
      Put_Block_Box(Position_X,Position_Y+8,13,2,Dark_Grey,Selected);	 
      else
      Put_Block_Box(Position_X,Position_Y+8,13,2,Dark_Grey,Non_Selected);
      end if;
      Goto_XY(Position_X+1, Position_Y+9);
      Put("   Back    ");
      
   end Menu_Multiplayer;
   
   
   
   procedure Multiplayer_Create(Option : in Integer;
				X      : in Integer;
				Y      : in Integer) is
      
      Position_X : Integer := X + 44;
      Position_Y : Integer := Y + 14;
      Selected     : Colour_Type := Blue;
      Non_Selected : Colour_Type := Green;
      
   begin
      Set_Colours(Black,Dark_Grey);
      
      if Option = 1 then
      Put_Block_Box(Position_X-15,Position_Y,13,2,Dark_Grey,Selected);	 
      else
      Put_Block_Box(Position_X-15,Position_Y,13,2,Dark_Grey,Non_Selected);
      end if;
      
      Goto_XY(Position_X-14, Position_Y+1);
      Put(" 2 Players ");
      
      if Option = 2 then
      Put_Block_Box(Position_X,Position_Y,13,2,Dark_Grey,Selected);	 
      else
	 Put_Block_Box(Position_X,Position_Y,13,2,Dark_Grey,Non_Selected);
      end if;
      Goto_XY(Position_X+1, Position_Y+1);
      Put(" 3 Players ");
            
      if Option = 3 then
      Put_Block_Box(Position_X+15,Position_Y,13,2,Dark_Grey,Selected);	 
      else
      Put_Block_Box(Position_X+15,Position_Y,13,2,Dark_Grey,Non_Selected);
      end if;
      Goto_XY(Position_X+16, Position_Y+1);
      Put(" 4 Players ");
      

      if Option = 4 then
      Put_Block_Box(Position_X,Position_Y+4,13,2,Dark_Grey,Selected);	 
      else
      Put_Block_Box(Position_X,Position_Y+4,13,2,Dark_Grey,Non_Selected);
      end if;
      Goto_XY(Position_X+1, Position_Y+5);
      Put("   Back    ");
      
   end Multiplayer_Create;
   
end Menu_Options;
