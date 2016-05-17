package body Player_Handling is
   -------------------------------------------------------------------------------------
   procedure Swap(A, B : in out Integer) is
      
      C : Integer := A;
      
   begin
      A := B;
      B := C;
   end Swap;
   -------------------------------------------------------------------------------------
   procedure Get_Input(Key_Board_Input : out Key_Type) is
      
      Input : Boolean;
      
   begin
      
      Input := True;
      while Input loop
	 
	 Get_Immediate(Key_Board_Input, Input);
	 
	 if Is_Up_Arrow(Key_Board_Input) 
	   or Is_Down_Arrow(Key_Board_Input) 
	   or Is_Left_Arrow(Key_Board_Input) 
	   or Is_Right_Arrow(Key_Board_Input) 
	   or Is_Return(Key_Board_Input) 
	   or Is_Esc(Key_Board_Input)  then 
	    exit;
	 end if;
      end loop;
      
   exception
      when Ada.Strings.INDEX_ERROR => null;
   end Get_Input;
   -------------------------------------------------------------------------------------
   procedure Get_Input is
      
      Input : Boolean;
      
   begin
      
      Input := True;
      while Input loop
	 
	 Get_Immediate(Keyboard_Input, Input);
	 
	 if (Is_Character(Keyboard_Input) and then To_Character(Keyboard_Input)=' ')
	   or (Is_Character(Keyboard_Input) and then To_Character(Keyboard_Input)='m')
	   or Is_Up_Arrow(Keyboard_input) 
	   or Is_Down_Arrow(Keyboard_input) 
	   or Is_Left_Arrow(Keyboard_input) 
	   or Is_Right_Arrow(Keyboard_input) 
	   or Is_Esc(Keyboard_input)  then 
	    exit;
	 end if;
      end loop;
      
   exception
      when Ada.Strings.INDEX_ERROR => null;
   end Get_Input;
   -------------------------------------------------------------------------------------
   procedure Send_Input(Socket         : in Socket_type) is
      
   begin
      
      if Is_Up_Arrow(Keyboard_input) then Put_Line(Socket, 'w'); 
      elsif Is_Down_Arrow(Keyboard_input) then Put_Line(Socket, 's');
      elsif Is_Left_Arrow(Keyboard_input) then Put_Line(Socket, 'a');
      elsif Is_Right_Arrow(Keyboard_input) then Put_Line(Socket, 'd');
      elsif (Is_Character(Keyboard_Input) and then To_Character(Keyboard_Input)='m') then 
	 Put_Line(Socket, 'm');
      elsif (Is_Character(Keyboard_Input) and then To_Character(Keyboard_Input)=' ') then 
	 Put_Line(Socket, ' '); 
	 
      else Put_Line(Socket, 'o'); -- betyder "ingen input" för servern.
      end if;
      
   exception
      when Ada.Strings.INDEX_ERROR => null;
	 
   end Send_Input;
   -------------------------------------------------------------------------------------
   function Is_Esc return Boolean is
      
   begin
      if Is_Esc(Keyboard_Input) then
	 return True;
      else
	 return False;
      end if;
   end Is_Esc;
   -------------------------------------------------------------------------------------
   procedure Get_String(Text        : out String;
			Text_Length : out Integer;
			Max_Text    : in Integer;
			X, Y        : in Integer;
		        Text_Col    : in Colour_Type;
			Back_Col    : in Colour_Type) is
      
      Temp_Text : String(1..Max_Text);
      
   begin
      Text_Length := 0;
      Set_Colours(Text_Col, Back_Col);
      
      loop
	 
	 Get_Immediate(Keyboard_Input);
	 
	 if Text_Length > 0 or (Is_Character(Keyboard_Input)) then
	    
	    if Is_Return(Keyboard_Input) then 
	       exit;
	    elsif Is_Backspace(Keyboard_Input) then
	       Text_Length := Text_Length - 1;
	    elsif Text_Length < Max_Text then
	       Text_Length := Text_Length + 1;
	       Temp_Text(Text_Length) := To_Character(Keyboard_Input);
	    end if;
	    
	    Goto_XY(X,Y);
	    for I in 1 .. Max_Text loop
	       Put(' ');
	    end loop;
	    Goto_XY(X,Y);
	    
	    Put( Temp_Text (1..Text_Length) );
	 end if;
      end loop;
      
      Text := Temp_Text;
      
   exception
      when Ada.Strings.INDEX_ERROR => null;
	 
   end Get_String;
   -------------------------------------------------------------------------------------
   -------------------------------------------------------------------------| Server |--
   -------------------------------------------------------------------------------------
   procedure Put_Game_Data(Socket : Socket_Type;
		           Data : in Game_Data) is
      
      -- Skickar spelarens skeppdata    
      -------------------------------------------------
      procedure Put_Ship_Data(Socket : in Socket_Type;
			      Ship   : in Ship_Spec) is
      begin
	 
	 Put_Line(Socket,Ship.XY(1));
	 Put_Line(Socket,Ship.XY(2));
	 
      end Put_Ship_Data;
      -------------------------------------------------
      
   begin
      --------------------------------------------------------
      -- Skickar spelarnas Information
      --------------------------------------------------------
      for I in Player_Array'Range loop
	 
	 Put(Socket, Data.Players(I).Ship.Health);
	 
	 if Data.Players(I).Ship.Health > 0 then
	    
	    Put_Ship_Data(Socket,Data.Players(I).Ship);
	    
	 end if;
	 
	 Put_Line(Socket,Data.Players(I).Score);
	 
      end loop;
      
      for I in Ranking_List'Range loop
	 Put_Line(Socket, Data.Ranking(I));
      end loop;
      
   end Put_Game_Data;
   -------------------------------------------------------------------------------------
   procedure Add_Player(Listener : in Listener_Type;
			Socket   : in out Socket_Type;
		        Player_Num : in integer) is
      
   begin
      
      Wait_For_Connection(Listener, Socket);
      
      Put("Player ");
      Put(Player_Num, 0);
      Put(" joined the game.");
      New_Line;
      
   end Add_Player;
   -------------------------------------------------------------------------------------
   procedure Remove_Player(Socket     : in out Socket_Type; 
			   Player_Num : in Integer) is
      
   begin
      
      Close(Socket);
      
      New_Line;
      Put("Player ");
      Put(Player_Num, 0);
      Put(" has left the game");
      
   end Remove_Player;
   -------------------------------------------------------------------------------------
   procedure Sort_Scoreboard(Game : in out Game_Data;
			     Num_Players : in Integer) is
   
   begin 
      
      if Num_Players > 1 then
	 for I in reverse 2..Num_Players loop
	    for J in Game.Ranking'Range loop
	       if Game.Players(  Game.Ranking(I-1)  ).Score < Game.Players(  Game.Ranking(I)  ).Score then
		  Swap (Game.Ranking(I-1),Game.Ranking(I));
	       end if;
	    end loop;
	 end loop;
      end if;
      
   end Sort_Scoreboard;
   -------------------------------------------------------------------------------------
   procedure Add_All_Players(Listener : in Listener_Type;
			     Sockets : in out Socket_Array;
			     Num_Players : out Integer) is
			    
      Player_Joined : Integer := 0;
      Player_Choice : Character;
      Temp_Integer  : Integer;
      
   begin
      loop
	 Player_Joined := Player_Joined + 1;
	 Add_Player(Listener, Sockets(Player_Joined), Player_Joined); -- Adding players
	 
	 Get(Sockets(Player_Joined), Player_Choice);
	 Get(Sockets(Player_Joined), Num_Players);
	 
	 Skip_Line(Sockets(Player_Joined));
	 
	 if Player_Choice = 'C' then      -- Checking if the player is the host
	    for I in 1 .. Player_Joined loop
	       Put_Line("Sending the total number of player to those who are waiting");
	       Put_Line(Sockets(I), Num_Players);  -- Sends the total number of players
						   -- to the players who are waiting.
	    end loop;
	    
	    if Num_Players > Player_Joined then
	       while Player_Joined < Num_Players Loop          -- Continues adding player
		  Player_Joined := Player_Joined + 1;
		  Add_Player(Listener, Sockets(Player_Joined), Player_Joined);
		  Get(Sockets(Player_Joined), Player_Choice);
		  
		  if Player_Choice = 'C' then                  -- Someone also choose host.
		     Put_Line(Sockets(Player_Joined), 5);      -- Client are informed.		 
		  end if;
		  
		  Put_Line(Sockets(Player_Joined), Num_Players);
		  Get(Sockets(Player_Joined), Temp_Integer);
		  Skip_Line(Sockets(Player_Joined));
		  
	       end loop;
	    end if;
	    
	    exit;   -- Done with adding players
	    
	 end if;
      end loop;
      
      ----------------------------------- Transmit
      --------------------------------------------
      for I in 1..Num_Players loop
	 Put_Line(Sockets(I), I);               -- Tells the client what number they have.
      end loop;
      --------------------------------------------
      --------------------------------------------
      
   end Add_All_Players;
   -------------------------------------------------------------------------------------
   procedure Get_Players_Nick_Colour(Socket : in Socket_Type;
				     Player : in out Player_Type) is
      
   begin
      Get_Line(Socket, Player.Name,    -- Spelarens namn
   	       Player.NameLength);         -- Spelarens namn längd
      
      if Player.NameLength = Player.Name'Last then
         Skip_Line(Socket);
      end if;
      
      Get_Line(Socket, Player_Colour,           -- Spelarens färgnamn.
   	       Player_Colour_Length);               -- Spelarens färgnamnlängd.
      
      if Player_Colour_Length = Player_Colour'Last then
   	 Skip_Line(Socket);
      end if;			     
      
   end Get_Players_Nick_Colour;
   -------------------------------------------------------------------------------------
   procedure Send_Players_Nick_Colour(Socket : in Socket_Type;
				      Player : in Player_Type) is
      
   begin
      Put_Line(Socket, Player.Name(1..Player.NameLength));  -- Spelarnas namn
      Put_Line(Socket, Player_Colour(1..Player_Colour_Length)); -- Spelarnas Färger
   end Send_Players_Nick_Colour;
   -------------------------------------------------------------------------------------
   -------------------------------------------------------------------------| Client |--
   -------------------------------------------------------------------------------------
   procedure Get_Game_Data(Socket : Socket_Type;
			   Data : out Game_Data) is
      
      
      -- Tar emot spelarens skeppdata    
      -------------------------------------------------
      procedure Get_Ship_Data(Socket : in Socket_Type;
			      Ship   : out Ship_Spec) is
      begin
	 
	 Get(Socket,Ship.XY(1));
	 Get(Socket,Ship.XY(2));
	 
      end Get_Ship_Data;
      -------------------------------------------------
      
   begin
      for I in Player_Array'Range loop
	 Get(Socket,Data.Players(I).Ship.Health);
	 if Data.Players(I).Ship.Health > 0 then
	    
	    Data.Players(I).Playing := True;
	    
	    --Tar emot spelarens skeppdata
	    Get_Ship_Data(Socket,Data.Players(I).Ship);
	    
	 else
	    Data.Players(I).Playing := False;   
	 end if;
	 
	 -- Tar emot spelarens poäng
	 Get(Socket,Data.Players(I).Score);
	 
      end loop;
      
      for I in Ranking_List'Range loop
	 Get(Socket, Data.Ranking(I));
      end loop;
   end Get_Game_Data;
   -------------------------------------------------------------------------------------
   procedure Put_Player_Ships (Data : in  Game_Data;
			       NumPlayers : in Integer) is
      
      Old_Text_Colour : Colour_Type;
      
   begin
      Old_Text_Colour := Get_Foreground_Colour;   -- Sparar färgen
      
      for I in 1..NumPlayers loop
	 if Data.Players(I).Playing then
	    
	    Set_Foreground_Colour(Data.Players(I).Colour); -- Ställer in spelarens färg.
	    Set_Text_Modes(Off,Off,On);                    -- Fet stil på utskriften
	    
	    Put_Player(Data.Players(I).Ship.XY(1), Data.Players(I).Ship.XY(2));
	    Set_Text_Modes(Off,Off,Off);  -- Reset utskriften
	 end if;
      end loop;
      
      Set_Foreground_Colour(Old_Text_Colour);  -- Återställer färgen.
      
   end Put_Player_Ships;
   -------------------------------------------------------------------------------------
   procedure Put_Score(Data        : in Game_Data; 
		       NumPlayers  : in Integer;
		       X           : in Integer;
		       Y           : in Integer;
		       Back_Colour : in Colour_Type;
		       Text_Colour : in Colour_Type) is
      
      Old_Background  : Colour_Type;
      Old_Text_Colour : Colour_Type;
      
   begin
      Old_Text_Colour := Get_Foreground_Colour;           -- Sparar den tidigare textfärgen
      Old_Background  := Get_Background_Colour;           -- Sparar den tidigare bakgrundsfärgen
      Set_Background_Colour(Back_Colour);
      Goto_XY(X+2,Y);	 
      Set_Text_Modes(On,Off,Off);  -- Understreck på utskriften
      Put("Nickname");
      Goto_XY(X+13,Y);
      Put(" Health  ");
      Goto_XY(X+25,Y);
      Put("Score");
      Set_Text_Modes(Off,Off,Off); -- Återställer utskrift inställningarna
      
      for I in 1 .. NumPlayers loop
	 Goto_XY(X,Y+I);
	 Put(I, Width => 0);       -- Skriver ut placeringen
	 Put('.');
         Set_Foreground_Colour(Data.Players( Data.Ranking(I) ).Colour);                       -- Ställer in Spelarens färg.
	 Set_Text_Modes(Off,Off,On);  -- Fet stil på utskriften
	 Put(Data.Players( Data.Ranking(I) ).Name( 1..Data.Players( Data.Ranking(I) ).NameLength)); -- Skriver ut spelarens namn.
	 
	 Set_Foreground_Colour(Red);                             -- Ställer in färgen på hjärtan.
	 Goto_XY(X+13,Y+I);
	 
	 if Data.Players( Data.Ranking(I) ).Ship.Health < 1 then            -- Om död.
	    Put("R.I.P.");
	    
	 elsif Data.Players( Data.Ranking(I) ).Ship.Health > 0 then         -- annars lever
	    
	    for J in 1 .. Data.Players( Data.Ranking(I) ).Ship.Health loop
	       if J = Data.Players( Data.Ranking(I) ).Ship.Health and J mod 2 = 1 then
		  Set_Foreground_Colour(Dark_Grey);
		  Put("♥ ");                                -- Ställer in färgen på hjärtan.
	       else
		  if J mod 2 = 0 then
		     Set_Foreground_Colour(Red);                             -- Ställer in färgen på hjärtan.
		     Put("♥ ");   
		  end if;
	       end if;                                            -- Antal liv
	    end loop;
	 end if;
	 Set_Text_Modes(Off,Off,Off);
	 Set_Foreground_Colour(Old_Text_Colour);                    -- Ställer tillbaka till text färgen.
	 Goto_XY(X+25,Y+I);
	 Put(Data.Players( Data.Ranking(I) ).Score, Width => 5);    -- skriver ut spelarens poäng
	 Set_BackGround_Colour(Old_Background);                     -- Ställer tillbaka till bakgrunds färgen.
      end loop;
   end Put_Score;
   -------------------------------------------------------------------------------------
   procedure Put_Player_Choice(Socket : in Socket_Type;
			       Choice : in Character;
			       Num_Players : in Integer) is
      
   begin
            
      Put(Socket, Choice);                        -- Sends the playerchoice (Join/Create)
      Put_line(Socket, Num_Players);               -- Join = 0 / Create = 1,2,3,4
      
   end Put_Player_Choice;
   -------------------------------------------------------------------------------------
   procedure Waiting_For_Players(Socket : in Socket_Type;
				 Num_Players : out Integer;
				 Klient_Number : out Integer) is
      
   begin
      Put_Line("Waiting for someone to create a game");
      Get(Socket, Num_Players);                -- Number of Players.
      
      if Num_Players = 5 then                  -- If someone already created a game
	 Clear_Window;
	 Get(Socket, Num_Players);             -- Gets the total number of player
	 Skip_Line(Socket);                   -- Ligger ett entertecken kvar i socketen.
	 Put("Someone was faster than you and created a game with ");
	 Put(Num_Players, Width => 0);
	 Put_Line(" Players");
	 Put("Press Enter to join the game");
	 Skip_Line;
	 New_Line;
      end if;
      
      Put_Line("Waiting for players to join the game");
      Get(Socket, Klient_Number);                -- Players klient Number
      Skip_Line(Socket);                      -- Ligger ett entertecken kvar i socketen.
   end Waiting_For_Players;
   -------------------------------------------------------------------------------------
   procedure Send_Player_Nick_Colour(Socket : in Socket_Type;
				     Player : in out Player_Type;
				     Klient_Number : in Integer) is
      
   begin
      Put_Line(Socket, Player.Name(1..Player.NameLength)); -- Sends the players nickname
	 
	 if Klient_Number = 1 then
	    Put_Line(Socket,"Blue");        -- Player Colour
	 elsif Klient_Number = 2 then
	    Put_Line(Socket,"Green");
	 elsif Klient_Number = 3 then
	    Put_Line(Socket,"Yellow");
	 elsif Klient_Number = 4 then
	    Put_Line(Socket,"Red");
	 end if;      
   end Send_Player_Nick_Colour;
   -------------------------------------------------------------------------------------
   procedure Get_Player_Nick_Colour(Socket : in Socket_Type;
				    Player : in out Player_Type) is
			 
   begin
      
      Get_Line(Socket, Player.Name, Player.NameLength);
      
      if Player.NameLength = Player.Name'Last then
	 Skip_Line(Socket);
      end if;
      
      Get_Line(Socket, Player_Colour, Player_Colour_Length);
            
      --| Översätter sträng till Colour_Type (Lite fult tyvärr...)        
      if Player_Colour(1 .. Player_Colour_Length) = "Blue" then
	 Player.Colour := Blue;
      elsif Player_Colour(1 .. Player_Colour_Length) = "Green" then
	 Player.Colour := Green;
      elsif Player_Colour(1 .. Player_Colour_Length) = "Yellow" then
	 Player.Colour := Yellow;
      elsif Player_Colour(1 .. Player_Colour_Length) = "Red" then
	 Player.Colour := Red;
      end if;
   end Get_Player_Nick_Colour;
   -------------------------------------------------------------------------------------
   
   function Check_Players_Choice(Players     : in Players_Choice_Array;
				 C           : in Character;
				 Num_Players : in Integer) return Boolean is
      
   begin
      for I in 1..Num_Players loop
	 if Players(I) = C then
	    return True;
	 end if;
      end loop;
      return False;
   end Check_Players_Choice;
   -------------------------------------------------------------------------------------
   
   procedure Get_Players_Choice( Players_Choice : in out Players_Choice_Array;
				 Sockets        : in Socket_Array;
				 Num_Players     : in Integer) is
      
      Temp_Char : Character;
      
   begin
      for I in 1..Num_Players loop
	 if Players_Choice(I) = 'o' or Players_Choice(I) = 'S' then
	    Get(Sockets(I), Players_Choice(I));
	 else
	    Get(Sockets(I), Temp_Char);
	 end if;
	 
	 if Players_Choice(I) = 'S' then
	    -- Save_Score(Game.Players(I));
	    null;
	 end if;
	 
      end loop;
   end Get_Players_Choice;
   -------------------------------------------------------------------------------------
   
end Player_Handling;
