package body Menu is
   
   procedure Put_Menu(Choice        : in out Character;
		      NumPlayers    : in out Integer;
		      Portadress    : in out Integer;           -- Idea that you will have to enter
		      Ipadress      : in out String;            -- adress when you join/create a game
		      Player_Name   : in out String;
		      Player_Name_Length : in out Integer
		     ) is
      
      Position_X : Integer := Gameborder_X;
      Position_Y : Integer := Gameborder_Y;
      Max_Length : Integer := 10;
      
   begin
      if Choice = 'S' then          -- At start enters nickname
	 Choose_Nickname_Window;    -- A window for entering nickname
	 Cursor_Visible;
	 Get_String(Player_Name, Player_Name_Length, Max_Length,  -- procedure that gets and put what you write
		    (World_X_Length/2-5)+Gameborder_X, Gameborder_Y+18, White, Menu_Background);
	 Cursor_Invisible;
	 Set_Echo(Off);
	 Choice := '1';
      end if;
      
      if  Choice = '1' then                -- Startmenu
      	 Menu_Start(Option, Position_X, Position_Y);
	 
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
	    elsif Option = 3 then               -- Settings
	       null;
	    elsif Option = 4 then               -- Credits
	       null;
	    elsif Option = 5 then               -- Exit
	       Choice := 'E';
	    end if;
	    Option := 1;
	 end if;
	 
      elsif Choice = '2' then           -- Multiplayer menyn
	 Menu_Multiplayer(Option, Position_X, Position_Y);
	 
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
	       Choice := 'M';
	       Option := 2;
	    elsif Option = 3 then     -- Back
	       Choice := '1';
	       Option := 1;
	    end if;
	 end if;
	 
      elsif Choice = 'M' then                   -- Create Game window
	 Multiplayer_Create(Option,Position_X, Position_Y);
	  
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
	       Option := 1;
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
	 
	 
      end if;
      
      Get_Input(Navigate_Input);             -- Get Player navigation choice
      
   
   end Put_Menu;
   
end Menu;
