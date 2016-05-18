package body Menu_Handling is
   
   procedure Menu(Option : in Integer;
		  Mark   : in Integer;
		  X      : in Integer;
		  Y      : in Integer;
		  Width  : in Integer;
		  Height : in Integer;
		  Name   : in String) is
      
   begin
      Set_Colours(Menu_Text,Menu_Background);
      
      if Option = Mark then
	 Put_Block_Box(X, Y, Width, Height, Menu_Background, Menu_Selected);	 
      else
	 Put_Block_Box(X, Y, Width, Height, Menu_Background, Menu_Non_Selected);
      end if;
      
      Goto_XY(X+1, Y+1);
      Put(Name);
   end Menu;

   
   procedure Put_Menu(Choice        : in out Character;
		      NumPlayers    : in out Integer;
		      Portadress    : in out Integer;           -- Idea that you will have to enter
		      Ipadress      : in out String;            -- adress when you join/create a game
		      Player_Name   : in out String;
		      Player_Name_Length : in out Integer
		     ) is
      
      
      procedure Choose_Nickname_Window(X, Y : in Integer) is
	 
      begin
	 
	 Set_Colours(Black, Menu_Background);
	 Put_Block_Box(X, Y, 15, 5, Menu_Background, Nickname_Border_Box);
	 
	 
	 Goto_XY(X+1, Y+1);
	 Put(" Nickname    ");
	 Goto_XY(X+2, Y+3);
	 Put("           ");
	 
	 Put_Box(X+1, Y+2, 13, 2, Menu_Background, Nickname_Write_Box);
	 Goto_XY(X+2, Y+3);
	 
	 
      end Choose_Nickname_Window;
      
      
      Position_X : Integer := (Border_Width/2)-6;
      Position_Y : Integer := Gameborder_Y + 10;
      Max_Length : Integer := 10;
      
   begin
      if Choice = '0' then          -- At start enters nickname
	 Choose_Nickname_Window(Position_X-1, Position_Y+5);    -- A window for entering nickname
	 Cursor_Visible;
	 Get_String(Player_Name, Player_Name_Length, Max_Length,  -- procedure that gets and put what you write
		    Border_Width/2-5, Gameborder_Y+18, White, Menu_Background);
	 Cursor_Invisible;
	 Set_Echo(Off);
	 Choice := '1';
      end if;
      
      if  Choice = '1' then                -- Startmenu
      	 
	 Menu(Option, 1, Position_X, Position_Y   , 13, 2, "   Start   ");
	 Menu(Option, 2, Position_X, Position_Y+4 , 13, 2, "Multiplayer");
	 Menu(Option, 3, Position_X, Position_Y+8 , 13, 2, " Highscore ");
	 Menu(Option, 4, Position_X, Position_Y+12, 13, 2, "  Credits  ");
	 Menu(Option, 5, Position_X, Position_Y+16, 13, 2, "   Exit    ");
	 
	 if Is_Down_Arrow(Navigate_Input) then          -- Down
	    if Option = 5 then
	       Option := 1;
	    else
	       Option := Option + 1;
	    end if;
	 elsif Is_Up_Arrow(Navigate_Input) then        -- Up
	    if Option = 1 then
	       Option := 5;
	    else
	       Option := Option - 1;
	    end if;
	 elsif Is_Return(Navigate_Input) then
	    if Option = 1 then                  -- SingelPlayer
	       NumPlayers := 1;
	       Choice := 'C';
	    elsif Option = 2 then               -- Multiplayer
	       Choice := '2';	    
	       Option := 2;
	    elsif Option = 3 then               -- Highscore
	       Choice := '4';
	       Option := 1;
	    elsif Option = 4 then               -- Credits
	       null;
	    elsif Option = 5 then               -- Exit
	       Choice := 'E';
	    end if;
	 end if;
	 
      elsif Choice = '2' then           -- Multiplayer menu
	 
	 Menu(Option, 1, Position_X, Position_Y  , 13, 2, "   Join    ");
	 Menu(Option, 2, Position_X, Position_Y+4, 13, 2, "  Create   ");
	 Menu(Option, 3, Position_X, Position_Y+8, 13, 2, "   Back    ");
	 
	 
	 if Is_Down_Arrow(Navigate_Input) then        -- Up
	    if Option = 3 then
	       Option := 1;
	    else
	       Option := Option + 1;
	    end if;
	 elsif Is_Up_Arrow(Navigate_Input) then       -- Down
	    if Option = 1 then
	       Option := 3;
	    else
	       Option := Option - 1;
	    end if;
	    
	 elsif Is_Return(Navigate_Input) then         -- "Enter"
	    if Option = 1 then        -- Join
	       NumPlayers := 0;
	       Choice := 'J';
	    elsif Option = 2 then     -- Create Multiplayer
	       Choice := '3';
	       Option := 2;
	    elsif Option = 3 then     -- Back
	       Choice := '1';
	       Option := 1;
	    end if;
	 end if;
	 
      elsif Choice = '3' then                   -- Create Game window
	 
	 Menu(Option, 1, Position_X-15, Position_Y+4, 13, 2, " 2 Players ");
	 Menu(Option, 2, Position_X   , Position_Y+4, 13, 2, " 3 Players ");
	 Menu(Option, 3, Position_X+15, Position_Y+4, 13, 2, " 4 Players ");
	 Menu(Option, 4, Position_X   , Position_Y+8, 13, 2, "   Back    ");
	 
	 
	 if Is_Down_Arrow(Navigate_Input) then        -- Down
	    if Option = 4 then
	       Option := 2;
	    else
	       Option := 4;
	    end if;
	 elsif Is_Up_Arrow(Navigate_Input) then       -- Up
	    if Option = 4 then
	       Option := 2;
	    else
	       Option := 4;
	    end if;
	    
	 elsif Is_Return(Navigate_Input) then          -- Enter
	    if Option /= 4 then                -- Create game
	       Choice := 'C';
	       if Option = 1 then              -- 2 Player
		  NumPlayers := 2;
	       elsif Option = 2 then           -- 3 Player
		  NumPlayers := 3;
	       elsif Option = 3 then           -- 4 Player
		  NumPlayers := 4;
	       end if;	    
	    else
	       Choice := '2';
	       Option := 3;
	    end if;
	 elsif Is_Left_Arrow(Navigate_Input) then  -- Left
	    if Option in 2..3 then
	       Option := Option - 1;
	    elsif Option = 1 then
	       Option := 3;
	    end if;
	 elsif Is_Right_Arrow(Navigate_Input) then -- Right
	    if Option in 1..2 then
	       Option := Option + 1;
	    elsif Option = 3 then
	       Option := 1;
	    end if;
	 end if;
	 
      elsif Choice = '4' then                   -- Create Game window
	 
	 
	 Put_Block_Box(Position_X-17, Position_Y, 46, 20, Dark_Grey, Green);      
	 
	 Set_Colours(Red, Dark_Grey);
	 
	 for I in 1 .. 19 loop
	    Goto_XY(Position_X-16, Position_Y+I);
	    Put("                                            ");
	 end loop;
	 
	 Goto_XY(Position_X,Position_Y+1);
	 Put_Highscore(Position_X-9, Position_Y + 2, 10); -- Top 10
	 
	 Menu(Option, 1, Position_X   , Position_Y+16, 13, 2, "   Back    ");
	 
	 
	 if Is_Return(Navigate_Input) then          -- Enter
	    Choice := '1';
	    Option := 3;
	 end if;
	 
      end if;
      
      Get_Input(Navigate_Input);             -- Get Player navigation choice
      
   
   end Put_Menu;
   
   procedure Put_Gameover_Box(Data          : in Game_Data;
			      Klient_Number : in Integer;
			      Choice        : in out Character) is
      
      Position_X : Integer := 35;
      Position_Y : Integer := 15;
      Button_X   : Integer := 37;
      Button_Y   : Integer := 21;
        
   begin
      Set_Colours(HighScore_Border, Highscore_Background);
      
      Put_Block_Box(Position_X, Position_Y, 40, 9, HighScore_Background, HighScore_Border);      for I in 1 .. 8 loop
	 Goto_XY(36, 15+I);
	 Put("                                      ");
      end loop;
      
      Set_Foreground_Colour(Red);
      Goto_XY(51, 17);
      Put("GAME OVER");
      
      Goto_XY(40, 19);
      Put("You got a total of ");
      Set_Foreground_Colour(Green);
      Put(Data.Players(Klient_Number).Score, Width => 5);
      Set_Foreground_Colour(Red);
      Put(" Points");
      
      
      Menu(Option, 1, Button_X   , Button_Y   , 11, 2, " Restart ");
      Menu(Option, 2, Button_X+12, Button_Y   , 11, 2, "  Save   ");
      Menu(Option, 3, Button_X+24, Button_Y   , 11, 2, "  Exit   ");
      
      
      if Is_Return(Navigate_Input) then        -- Enter
	 if Option = 1 then                    -- Restart
	    Choice := 'R';
	 elsif Option = 2 then                 -- Save
	    Choice := 'S';
	 elsif Option = 3 then                 -- Exit
	    Choice := 'E';
	 end if;
      elsif Is_Left_Arrow(Navigate_Input) then  -- Left
	 if Option in 2..3 then
	    Option := Option - 1;
	 elsif Option = 1 then
	    Option := 3;
	 end if;
      elsif Is_Right_Arrow(Navigate_Input) then -- Right
	 if Option in 1..2 then
	    Option := Option + 1;
	 elsif Option = 3 then
	    Option := 1;
	 end if;
      end if;
      
   end Put_Gameover_Box;
   
end Menu_Handling;
