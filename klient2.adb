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
with Score_Handling;          use Score_Handling;
with Map_Handling;            use Map_Handling;
--with Task_Printer;            use Task_Printer;

procedure Klient is

   ----------------------------------------------------------------------------------------------------
   --|
   --| DECLARATIONS
   --|
   ----------------------------------------------------------------------------------------------------
   
   Socket : Socket_Type; --Socket_type används för att kunna kommunicera med en server

   NumPlayers     : Integer := 1;
   Gameover       : Integer := 0;
   Klient_Number  : Integer := 1;               -- Servern skickar klientnumret
   Klient_Waiting : Character := 'o';
   
   Keyboard_Input : Key_Type;
   Esc            : constant Key_Code_Type := 27;
   Data           : Game_Data;    -- Spelinformation som tas emot från servern.
   Shot_List      : Object_List;
   Astroid_List   : Object_List;
   Obstacle_List  : Object_List;
   Powerup_List   : Object_List;
   Waves          : Enemy_List_array;
   Players_Choice : Players_Choice_Array := ('o', 'o', 'o', 'o');
   Choice         : Character := '0';    -- Player choice in the menu 0 = Start
   Ship_Move      : Ship_Move_Type := (others => 0);    -- position av skepp i startanimeringen
   Ship_Shot      : Ship_Shot_Type := (others => 0);    -- Position av skott
   Ipadress       : String(1..9) := "localhost"; -- Tänkt att kunna skriva adress
   Portadress     : Integer      := 3400;        -- i menyn
   
   
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
	 exit when Choice = 'C' or Choice ='J' or Choice = 'E' or Choice = 'R';
	 
      	 Put_Spacebattle(Ship_Move, Ship_Shot, Gameborder_X, GameBorder_Y, 
      			 World_X_Length, World_Y_Length);
	 
      	 Put_Menu(Choice, NumPlayers, Portadress, Ipadress, 
      		  Data.Players(1).Name, Data.Players(1).NameLength);
	 
      end loop;
      -------------------------------------------------------------
      --| End of Menu ---------------------------------------------
      -------------------------------------------------------------

      
      begin
         -- Initierar en socket, detta krävs för att kunna ansluta denna till
	 -- servern.
	 if not Check_Players_Choice(Players_Choice, 'R', NumPlayers) and Choice /= 'E' then
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
	 end if;
	 
	 if Choice /='E' then
	 Get_Map(Socket, Data, Check_Update => False);
	    Players_Choice := ('o', 'o', 'o', 'o');
	    Choice := 'J';
	 
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
	    
	    --| Syncing with Server
	    --------------------------------------|
	    if Klient_Number = 1 then           --|
	       Put(Socket, '$');                --|
	       while Klient_Waiting /= '$' loop --|
		  Get(Socket, Klient_Waiting);  --|
	       end loop;                        --|
	       Klient_Waiting := 'o';           --|
	    end if;                             --|
	    
	    --------------------------------------|
	    
	    
	    ---------------------------------------------------------------------
            -- TA EMOT DATA
            ---------------------------------------------------------------------	    
            
	    --Här får vi info om alla skottens koordinater
	    DeleteList(Astroid_List);
	    Get(Socket,Astroid_List);
	    DeleteList(Shot_List);
	    Get(Socket, Shot_List);
	    DeleteList(Obstacle_List);
	    Get(Socket, Obstacle_List);
	    DeleteList(Powerup_List);
	    Get(Socket, Powerup_List);
	    
	    Get_Map(Socket, Data);       -- Map_Handling
	    Get_Game_Data(Socket,Data); 
	    
            --Enemies tas emot som objekt
	    for I in 1..4 loop
	       DeleteList(Waves(I));
	       Get(Socket, Waves(I)); 
	    end loop;
	    
	    Get(Socket, Gameover);
	    
            ---------------------------------------------------------------------
            -- SKRIV UT DATA
            ---------------------------------------------------------------------
            
            -- Task_Printer
--	    Printer(Data, Waves, Astroid_List, Shot_List, Obstacle_List, Powerup_List, NumPlayers, Gameover, Klient_Number);
	    
	    Clear_Window;
	    Set_Echo(Off);
	    
	    Put_Player_Ships(Data, NumPlayers);
	    
	    for I in Waves'range loop
	       Put_Objects(Waves(I));
	    end loop;
	    
	    Put_Objects(Powerup_List);
	    Put_Objects(Astroid_List);
	    --shot.prit ev här
	    Put_Objects(Obstacle_List);
	    Put_Objects(Shot_List);
	    
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
	    
	    --  -------------------------------------------------
	    --  --| Där man skriver för att chatta
	    --  -------------------------------------------------
	    --  Put_Block_Box(Chatt_Window_X, Chatt_Window_Y,                    -- Ett litet fönster för att skriva i. / Eric 
	    --  		  World_X_Length, 2, Chatt_Background, Chatt_Border); 
	    --  Goto_XY(Gameborder_X+1,Gameborder_Y+World_Y_Length+2);
	    --  Put("Här skriver man.");
	    --  -------------------------------------------------

	    Put_World(Data.Map);
	    
	    if Gameover = 1 then 
	       Get_Input(Navigate_Input);             -- Get Player navigation choice
	       
	       Put_Gameover_Box(Data, Klient_Number, Choice);
	    end if;
	    
	    Set_Colours(White, Black);

	    
            --------------------------------------------------------------------
            -- SKICKA DATA
            --------------------------------------------------------------------
	    
	    delay(0.01);
	       
	      	    -- Skickar Till servern
	       if Gameover /= 1 then
		  Get_Input;
		  
		  Send_Input(Socket); 
		  
	       elsif Gameover = 1 then
--		  if (Choice /= 'E' and Choice /= 'R') then
		  if Players_Choice(Klient_Number) /= 'E' and	
		    Players_Choice(Klient_Number) /= 'R' then
		     
		     if Is_Return(Navigate_Input) then
			
--			Get_From_Printer(Choice);
			
			Put(Socket, Choice);
			
		     else
			Put(Socket, 'o');   
		     end if;
		 end if;
		 
		 if Choice = 'E' or Choice = 'R' then
--		    Put("Waiting for players");
		    Put(Socket, 'o');
		 end if;
		 
		 
		 for I in 1..NumPlayers loop
		       
		    Get(Socket, Players_Choice(I));
		    
		 end loop;   
	       end if;
	       
	       exit when not Check_Players_Choice( Players_Choice, 'o', NumPlayers);

	    
	    end loop;
	    
	    Get_Score(Socket); -- Update highscore 
	    
	    Put(Socket, '$');      
	    
	    
	    
	 end if;
	 

	 
	 --Fria allokerat minne
	 DeleteList(Shot_List);
	 DeleteList(Obstacle_List);
	 DeleteList(Powerup_List);
	 DeleteList(Astroid_List);
	 
	 
      exception
	 when GNAT.SOCKETS.SOCKET_ERROR =>
	    
	    DeleteList(Shot_List);
	    DeleteList(Obstacle_List);
	    DeleteList(Powerup_List);
	    DeleteList(Astroid_List);
	    Cursor_visible;
	    New_Line;
	    Put("Someone disconnected!");
	    exit;                              -- Meningen är att man kanske kommer tillbaka till menyn.
      end;
      
      Clear_Window;
      if Choice = 'E' then
	 Put("Closing the program.");
	 for I in 1..3 loop
	    delay(0.5);
	    Put('.');
	 end loop;
	 exit;
      elsif Check_Players_Choice(Players_Choice, 'E', NumPlayers) then
      
	 Put("Someone has closed the game!");
	 exit;
      end if;
      
   end loop;
   Cursor_visible;
   Set_Echo(On);
--   Stop_Printer;

   --Innan programmet avslutar stängs socketen, detta genererar ett exception
   --hos servern, pss kommer denna klient få ett exception när servern avslutas
   Close(Socket);

   Put("Innan end!");

end Klient;
