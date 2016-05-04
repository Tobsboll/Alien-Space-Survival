with Ada.Command_Line;        use Ada.Command_Line;
with Ada.Exceptions;          use Ada.Exceptions;
with Ada.Text_IO;             use Ada.Text_IO;
with Ada.Integer_Text_IO;     use Ada.Integer_Text_IO;
with TJa.Sockets;             use TJa.Sockets;
with TJa.Keyboard;            use TJa.Keyboard;
with TJa.Keyboard.Keys;       use TJa.Keyboard.Keys;
with TJa.Window.Text;         use TJa.Window.Text;
with Ada.Strings;             use Ada.Strings; 
with Enemy_ship_handling;     use Enemy_Ship_handling;

with Object_Handling;         use Object_Handling;
with Graphics;                use Graphics;
with Definitions;             use Definitions;
with Game_Engine;             use Game_Engine;
with Gnat.Sockets;

with Player_Handling;         use Player_Handling;
with Background_Handling;     use Background_Handling;
with Menu_Handling;           use Menu_Handling;
with Window_Handling;         use Window_Handling;
with Box_Hantering;           use Box_Hantering;
with Map_Handling;            use Map_Handling;

procedure Klient is

   ----------------------------------------------------------------------------------------------------
   --|
   --| DECLARATIONS
   --|
   ----------------------------------------------------------------------------------------------------
   
   Socket : Socket_Type; --Socket_type används för att kunna kommunicera med en server

   NumPlayers     : Integer;
   Keyboard_Input : Key_Type;
   Esc            : constant Key_Code_Type := 27;
   Data           : Game_Data;    -- Spelinformation som tas emot från servern.
   Shot_List      : Object_List;
   Obstacle_List  : Object_List;
   Powerup_List   : Object_List;
   Waves          : Enemy_List_array;
   Choice         : Character := '0';    -- Player choice in the menu 0 = Start
   Ship_Move      : Ship_Move_Type := (others => 0);    -- position av skepp i startanimeringen
   Ship_Shot      : Ship_Shot_Type := (others => 0);    -- Position av skott
   Ipadress       : String(1..9) := "localhost"; -- Tänkt att kunna skriva adress
   Portadress     : Integer      := 3400;        -- i menyn
   
   Klient_Number        : Integer;               -- Servern skickar klientnumret
   Player_Colour        : String(1..15);         -- Används i början till att överföra spelarnas färger
   Player_Colour_Length : Integer;               -- Används för att hålla koll hur lång färgnamnet är
   
   ----------------------------------------------------------------------------------------------------
   ----------------------------------------------------------------------------------------------------
   ----------------------------------------------------------------------------------------------------
   	
begin
   --Denna rutin kontrollerar att programmet startas med två parametrar.
   --Annars kastas ett fel.
   --Argumentet skall vara serverns adress och portnummer, t.ex.:
   --> klient localhost 3400
   if Argument_Count /= 2 then
      Raise_Exception(Constraint_Error'Identity,
                      "Usage: " & Command_Name & " remotehost remoteport");
   end if;
   
   loop

      -------------------------------------------------------------
      --| Start of Menu -------------------------------------------
      -------------------------------------------------------------
      loop
      	 delay(0.1);
      	 Put_Spacebattle(Ship_Move, Ship_Shot, Gameborder_X, GameBorder_Y, 
      			 World_X_Length, World_Y_Length);
	 
      	 Put_Menu(Choice, NumPlayers, Portadress, Ipadress, 
      		  Data.Players(1).Name, Data.Players(1).NameLength);
	 
      	 exit when Choice = 'C' or Choice ='J' or Choice = 'E';
	 
      end loop;
      -------------------------------------------------------------
      --| End of Menu ---------------------------------------------
      -------------------------------------------------------------
      
      
      if Choice = 'E' then -- Exit
	 
      	 -- Put_Exiting_Game;                   -- A screen shuting down the game.
	 
      	 exit;
      end if;
      
      begin
         -- Initierar en socket, detta krävs för att kunna ansluta denna till
	 -- servern.
	 Initiate(Socket);
	 
	 Put_Line("Waiting for connection");
	 Connect(Socket, Argument(1), Positive'Value(Argument(2)));  -- Connects to the server
	 Put_Line("You are connected to the server");

	 Set_Colours(Text_Colour_1, Background_Colour_1);  -- Change colour on the terminalen
	 Clear_Window;
	 
	 -------------------------------------------------------------
	 --| Player setup before the game ----------------------------
	 -------------------------------------------------------------
	 
	 Put_Player_Choice(Socket, Choice, NumPlayers);
	 
	 Waiting_For_Players(Socket, NumPlayers, Klient_Number);
	 
	 Set_Window_Title("Klient",Klient_Number);  -- Change the window title
	 
	 Send_Player_Nick_Colour(Socket, Data.Players(1), Klient_Number); 
	 
	 --      Put_Waiting_For_Players(Socket);    -- A screen that waits for players
	 
	 for I in 1 .. NumPlayers loop
	    Get_Player_Nick_Colour(Socket, Data.Players(I));
	 end loop;
	 
	 Get_Map(Socket, Data, Check_Update => False);
	 
	 -------------------------------------------------------------
	 --| Done with the player setup ------------------------------
	 -------------------------------------------------------------
	 
	 Put_line("Game loopen börjar");
	 ----------------------------------------------------------------------------------------------------
	 --|
	 --| Game loop
	 --|
	 ----------------------------------------------------------------------------------------------------
	 Set_Echo(Off);
	 Cursor_Invisible;
	 loop
	 
	    ---------------------------------------------------------------------
            -- TA EMOT DATA
            ---------------------------------------------------------------------	    
            
            -- Get(Socket,Loop_Counter);    -- tar emot serverns loop_counter
	    
	    --Här får vi info om alla skottens koordinater
	    DeleteList(Shot_List);
	    Get(Socket, Shot_List);
	    DeleteList(Obstacle_List);
	    Get(Socket, Obstacle_List);
	    DeleteList(Powerup_List);
	    Get(Socket, Powerup_List);
	    
	    Get_Map(Socket, Data);        -- Map_Handling
	    Get_Game_Data(Socket,Data);
	    
            --Enemies tas emot som objekt
	    for I in 1..4 loop
	       DeleteList(Waves(I));
	       Get(Socket, Waves(I));
	    end loop;
            ---------------------------------------------------------------------
            -- SKRIV UT DATA
            ---------------------------------------------------------------------
	    Clear_Window;
	    if Background then
	       Put_Background(NumPlayers);
	    end if;
	    
	    -------------------------------------------------
	    --| Highscore fönster
	    -------------------------------------------------
	    Put_Block_Box(Highscore_Window_X, Highscore_Window_Y, Highscore_Window_Width, 
			  Highscore_Window_Height+NumPlayers, HighScore_Background, HighScore_Border);     -- En låda runt scorelistan Eric
	    
	    Goto_XY(Highscore_Window_X+1, Highscore_Window_Y+1);
	    Put_Space(Highscore_Window_Width-2, HighScore_Background);
	    Goto_XY(Highscore_Window_X+1, Highscore_Window_Y+2);
	    Put_Space(Highscore_Window_Width-2, HighScore_Background);
	    Put_Score(Data, NumPlayers, Highscore_X, Highscore_Y, 
		      HighScore_Background, White);    -- Skriver ut den sorterade scorelistan / Eric
	    
	    -------------------------------------------------
	    
	    -------------------------------------------------
	    --| Där man skriver för att chatta
	    -------------------------------------------------
	    Put_Block_Box(Chatt_Window_X, Chatt_Window_Y,                    -- Ett litet fönster för att skriva i. / Eric 
			  World_X_Length, 2, Chatt_Background, Chatt_Border); 
	    Goto_XY(Gameborder_X+1,Gameborder_Y+World_Y_Length+2);
	    Put("Här skriver man.");
	    -------------------------------------------------

	    Put_Player_Ships(Data, NumPlayers);          -- put Ships // Andreas
	    
	    for I in Waves'range loop	
	       Put_Objects(Waves(I));
	    end loop;
	    
	    Put_Objects(Shot_List);
	    Put_Objects(Obstacle_List);
	    Put_Objects(Powerup_List);
	    Goto_XY(World_X_Length , World_Y_Length);
	    
	    Put_World(Data.Map, Gameborder_X, Gameborder_Y, Game_Wall_Background, Game_Wall_Line);
	    Set_Colours(White, Black);
	    
	    
            --------------------------------------------------------------------
            -- SKICKA DATA
            --------------------------------------------------------------------
	    
	    Get_Input;
	    
	    --------------------------------------------------
	    if Is_Esc
	      --or Players_Are_Dead(Data.Players)
	    then -- måste ändras
	       Put("Exiting...");
	       Skip_Line;
	       Put_Line(Socket, 'e');
	       exit;
	    end if;
	    --------------------------------------------------
	    
	    --Sänder ut användarens input från tangentbordet
	    Send_Input(Socket);
            --------------------------------------------------------------------
            -- Done
            --------------------------------------------------------------------	    
	    
	    ----------------------------------------
	    --| Delay depending on |----------------    -- // Eric
	    ----------------------------------------
	    
	    --| Number of Players |--
	    if NumPlayers = 1 then    -- Just nu är det ingen skillnad
	       delay(0.04);           -- Men det kanske kommer ändras 
	    elsif NumPlayers = 2 then -- beroende på vad servern gör.
	       delay(0.04);
	    elsif NumPlayers = 3 then
	       delay(0.04);
	    elsif NumPlayers = 4 then
	       delay(0.04);
	    end if;
	    
	    ----------------------------------------
	    ----------------------------------------
	    ----------------------------------------
	    
	    --Följande ballar ur.
	    --  if Players_Are_Dead(Data.Players) then
	    --     --exit;
	    --     raise GNAT.SOCKETS.SOCKET_ERROR;
	    --  end if;
	    
	    -----------------------------------
	    -- GET ENEMY WAVE
	    -----------------------------------
	    
	    --for I in waves'range loop

	      -- Delete_enemy_list(Waves(I));

	     --  Get_Enemy_Ships(Waves(I), Socket); -- Tobias
						  --DeleteList(Enemies);
						  --Get(Socket, Enemies);
	    -- end loop;
	    
	    -----------------------------------
	    -- end GET ENEMY WAVE
	    -----------------------------------
	    
	    --  if NumPlayers = 1 then
	    --     delay(0.001);
	    --  elsif NumPlayers = 2 then
	    --     delay(0.05);
	    --  elsif NumPlayers = 3 then
	    --     delay(0.05);
	    --  elsif NumPlayers = 4 then
	    --     delay(0.05);
	    --  end if;

	    --delay(0.005); -- senare bra om vi gör så att server och
	    -- klient synkar exakt!
	    -- Loop_Counter := Loop_Counter + 1;
	    
	    --exit when Players_Are_Dead(Data.Players);  --Ballar ur.
	 end loop;
	 
	 --Fria allokerat minne
	 DeleteList(Shot_List);
	 DeleteList(Obstacle_List);
	 DeleteList(Powerup_List);
	 
	 --Innan programmet avslutar stängs socketen, detta genererar ett exception
	 --hos servern, pss kommer denna klient få ett exception när servern avslutas
	 Close(Socket);
	 
      exception
	 when GNAT.SOCKETS.SOCKET_ERROR =>
	    
	    DeleteList(Shot_List);
	    DeleteList(Obstacle_List);
	    DeleteList(Powerup_List);
	    Cursor_visible;
	    New_Line;
	    Put("Someone disconnected!");
	    exit;                              -- Meningen är att man kanske kommer tillbaka till menyn.
      end;
      
   end loop;
   Cursor_visible;
   Set_Echo(On);

end Klient;
