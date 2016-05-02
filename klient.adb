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
with Gnat.Sockets;

with Input;                   use Input;
with Background_Handling;     use Background_Handling;
with Menu_Handling;           use Menu_Handling;
with Window_Handling;         use Window_Handling;
with Box_Hantering;           use Box_Hantering;
with Map_Handling;            use Map_Handling;
with Game_Engine;             use Game_Engine;

procedure Klient is

   
   
   -- Tar emot datan som skickas från servern till klienten   
   --------------------------------------------------------------
   procedure Get_Game_Data(Socket : Socket_Type;
			   Data : out Game_Data) is
      
      
      -- Tar emot spelarens skeppdata    
      -------------------------------------------------
      procedure Get_Ship_Data(Socket : in Socket_Type;
			      Ship   : out Ship_Spec) is
      begin
	 
	 Get(Socket,Ship.XY(1));
	 Get(Socket,Ship.XY(2));
	 Get(Socket,Ship.Health);
	 

	 
      end Get_Ship_Data;
      -------------------------------------------------
      
      -- Får 1 för aktiv eller 0 för inaktiv från servern.
      Player_Playing    : Integer;    -- Spelare
      Gen_Map_Active    : Integer;    -- Generering av banan

      
   begin
      -- Tar emot spelarnas Information
      for I in Player_Array'Range loop
	 -- Tar emot om spelaren spelar.
	 Get(Socket,Player_Playing);
	 if Player_Playing = 1 then
	    Data.Players(I).Playing := True;
	    
	    --Tar emot spelarens skeppdata
	    Get_Ship_Data(Socket,Data.Players(I).Ship);
	    
	    -- Tar emot spelarens poäng
	    Get(Socket,Data.Players(I).Score);
	    
	    
	    -- Tar inte emot mer data om inte spelaren spelar.
	 elsif Player_Playing = 0 then
	    Data.Players(I).Playing := False;
	 end if;
	 
      end loop;
      
      for I in Ranking_List'Range loop
	 Get(Socket, Data.Ranking(I));
      end loop;
      
   end Get_Game_Data;
   ---------------------------------------------------------------
   
   
   
   --------------------------------------------------
   
   procedure Put_Player_Ships (Data : in  Game_Data;
			       NumPlayers : in Integer
			      ) is
      
      Old_Text_Colour : Colour_Type;
   begin
      Old_Text_Colour := Get_Foreground_Colour;           -- Sparar den tidigare textfärgen
      
      for I in 1..NumPlayers loop
	 if Data.Players(I).Playing then
	    
	    Set_Foreground_Colour(Data.Players(I).Colour);               -- Ställer in spelarens färg.
	    
	    --Goto_XY(Data.Players(I).Ship.XY(1), Data.Players(I).Ship.XY(2));
	    Put_Player(Data.Players(I).Ship.XY(1), Data.Players(I).Ship.XY(2));                         -- Uppgraderas till en Put_Ship senare
	 end if;
	 
      end loop;
      
      Set_Foreground_Colour(Old_Text_Colour);       -- Ställer tillbaka till den tidigare färgen.
      
      
   end Put_Player_Ships;
   
   --------------------------------------------------
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
	 
	 if Data.Players( Data.Ranking(I) ).Ship.Health = 0 then            -- Om död.
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
   --------------------------------------------------
   --------------------------------------------------
   
   
   ----------------------------------------------------------------------------------------------------
   --|
   --| DECLARATIONS
   --|
   ----------------------------------------------------------------------------------------------------
   
   Socket : Socket_Type; --Socket_type används för att kunna kommunicera med en server

   NumPlayers     : Integer;
   Keyboard_Input : Key_Type;
   -- Input          : Boolean;
   Esc            : constant Key_Code_Type := 27;
   Data           : Game_Data;    -- Spelinformation som tas emot från servern.
   
   Shot_List      : Object_List;
   Obstacle_List  : Object_List;
   Powerup_List   : Object_List;
   
   Enemies1, Enemies2, Enemies3, Enemies4 : Enemy_List;

   ---
   Waves          : Enemy_List_array;
   Enemies        : Object_List;
   --
   
   Klient_Number        : Integer;               -- Servern skickar klientnumret
   Player_Colour        : String(1..15);         -- Används i början till att överföra spelarnas färger
   Player_Colour_Length : Integer;               -- Används för att hålla koll hur lång färgnamnet är
   
   Ipadress   : String(1..9) := "localhost";
   Portadress : Integer      := 3400;
   
   Choice              : Character := 'S';    -- Player choice in the menu S = Start
   Move : Ship_Move_Type := (others => 0);    -- position av skepp i startanimeringen
   Shot : Ship_Shot_Type := (others => 0);    -- Position av skott
   
   
   

   
   
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
      
      --  --| Koden som är bortkommenterad nedanför är för själva startmenyn
      --  --| Den är bortkommenterad då det kanske är jobbigt att bläddra i menyn
      --  --| varje gång man vill testa sin kod.
      
      --  -------------------------------------------------------------
      --  --| Start of Menu -------------------------------------------    -- NYA
      --  -------------------------------------------------------------
      --  loop
      --  	 delay(0.1);
      --  	 Put_Spacebattle(Move, Shot, Gameborder_X, GameBorder_Y, 
      --  			 World_X_Length, World_Y_Length);
      
      --  	 Put_Menu(Choice, NumPlayers, Portadress, Ipadress, 
      --  		  Data.Players(1).Name, Data.Players(1).NameLength);
      
      --  	 exit when Choice = 'C' or Choice ='J' or Choice = 'E';
      
      --  end loop;
      --  -------------------------------------------------------------
      --  --| End of Menu ---------------------------------------------     -- NYA
      --  -------------------------------------------------------------
      
      
      --  if Choice = 'E' then -- Exit
      
      --  	 -- Put_Exiting_Game;                   -- A screen shuting down the game.
      
      --  	 exit;
      --  end if;
      
      begin
         Waves := (Enemies1, Enemies2, Enemies3, Enemies4);
	 --  	 -------------------------------------------------------------
	 --  	 --| Player setup before the game ----------------------------     -- NYA
	 --  	 -------------------------------------------------------------
	 
	 --  	 -- Initierar en socket, detta krävs för att kunna ansluta denna till
	 --  	 -- servern.
	 --  	 Initiate(Socket);
	 
	 --  	 --      Put_Waiting_For_Server;             -- A screen that waits for server.
	 --  	 Put_Line("Waiting for connection");
	 --  	 Connect(Socket, Argument(1), Positive'Value(Argument(2)));      -- Connects to the server
	 --  	 Put_Line("You are connected to the server");
	 
	 
	 --  	 Put(Socket, Choice);                        -- Sends the playerchoice (Join/Create)
	 --  	 Put_line(Socket, NumPlayers);               -- Join = 0 / Create = 1,2,3,4
	 
	 --  	 Set_Colours(Text_Colour_1, Background_Colour_1);  -- Change colour on the terminalen
	 --  	 Clear_Window;
	 
	 --  	 --------------------------------------
	 --  	 ------------------------------Tar Emot
	 --  	 Put_Line("Waiting for someone to create a game");
	 --  	 Get(Socket, NumPlayers);                -- Number of Players.
	 
	 --  	 if NumPlayers = 5 then                  -- If someone already created a game
	 --  	    Clear_Window;
	 --  	    Get(Socket, NumPlayers);             -- Gets the total number of player
	 --  	    Skip_Line(Socket);                   -- Ligger ett entertecken kvar i socketen.
	 --  	    Put("Someone was faster than you and created a game with ");
	 --  	    Put(NumPlayers, Width => 0);
	 --  	    Put_Line(" Players");
	 --  	    Put("Press Enter to join the game");
	 --  	    Skip_Line;
	 --  	    New_Line;
	 --  	 end if;
	 
	 --  	 Put_Line("Waiting for players to join the game");
	 --  	 Get(Socket, Klient_Number);                -- Players klient Number
	 
	 --  	 Set_Window_Title("Klient",Klient_Number);  -- Change the window title
	 --  						    --------------------------------------
	 --  						    --------------------------------------
	 
	 --  	 Skip_Line(Socket);                      -- Ligger ett entertecken kvar i socketen.
	 
	 --  	 --------------------------------------
	 --  	 -------------------------------Skickar
	 --  	 Put_Line(Socket, Data.Players(1).Name(1..Data.Players(1).NameLength)); -- Sends the players nickname
	 
	 --  	 if Klient_Number = 1 then
	 --  	    Put_Line(Socket,"Blue");        -- Player Colour
	 --  	 elsif Klient_Number = 2 then
	 --  	    Put_Line(Socket,"Green");
	 --  	 elsif Klient_Number = 3 then
	 --  	    Put_Line(Socket,"Yellow");
	 --  	 elsif Klient_Number = 4 then
	 --  	    Put_Line(Socket,"Red");
	 --  	 end if;
	 --  	 --------------------------------------
	 --  	 --------------------------------------   
	 
	 
	 --  	 --      Put_Waiting_For_Players(Socket);                     -- A screen that waits for players
	 
	 
	 --  	 Put_Line("Waiting for players");
	 --  	 --------------------------------------
	 --  	 ------------------------------Tar Emot   
	 --  	 for I in 1 .. NumPlayers loop
	 --  	    Get_Line(Socket, Data.Players(I).Name,                  -- Spelarnas Namn 
	 --  		     Data.Players(I).NameLength);                   -- Spelarnas Namn Längder
	 --  	    Get_Line(Socket, Player_Colour,                         -- Spelarnas Färger
	 --  		     Player_Colour_Length);                         -- Spelarnas Färg Längder
	 
	 
	 --  	    --| Översätter sträng till Colour_Type (Lite fult tyvärr...)        
	 --  	    if Player_Colour(1 .. Player_Colour_Length) = "Blue" then
	 --  	       Data.Players(I).Colour := Blue;
	 --  	    elsif Player_Colour(1 .. Player_Colour_Length) = "Green" then
	 --  	       Data.Players(I).Colour := Green;
	 --  	    elsif Player_Colour(1 .. Player_Colour_Length) = "Yellow" then
	 --  	       Data.Players(I).Colour := Yellow;
	 --  	    elsif Player_Colour(1 .. Player_Colour_Length) = "Red" then
	 --  	       Data.Players(I).Colour := Red;
	 --  	    end if;
	 --  	 end loop;	 
	 --  	 -------------------------------------------------------------
	 --  	 --| Done with the player setup ------------------------------   -- NYA
	 --  	 -------------------------------------------------------------
	 
	 
	 -------------------------------------------------------------
	 --| Player setup before the game ----------------------------     -- Gamla
	 -------------------------------------------------------------	 
	 -- Initierar en socket, detta krävs för att kunna ansluta denna till
	 -- servern.
	 Initiate(Socket);
	 
	 Set_Colours(Text_Colour_1, Background_Colour_1);  -- Ändrar färgen på terminalen
	 Clear_Window;
	 

	 
	 
	 Put("Join eller Create, J eller C: ");

	 
	 loop	 
	    Get(Choice);
	    if Choice = 'J' then
	       Put("Waiting for connection...");
	       Connect(Socket, Argument(1), Positive'Value(Argument(2)));
	       Put("You are connected!");
	       exit;
	    elsif Choice = 'C' then
	       New_Line;
	       Connect(Socket, Argument(1), Positive'Value(Argument(2)));
	       Put("Välj antal spelare ");
	       Get(NumPlayers);
	       Put_Line(Socket, NumPlayers);
	       New_Line;
	       Put("Waiting for players to join");
	       exit;
	    else
	       Put("Skriv C eller J!");

	    end if;
	 end loop;
	 


	 --------------------------------------
	 ------------------------------Tar Emot
	 Get(Socket, NumPlayers);                -- Antal spelare som spelar
	 Put(NumPlayers);
	 Get(Socket, Klient_Number);             -- Spelarens Klient nummer
	 Put(Klient_Number);
	 New_Line;
	 Set_Window_Title("Klient",Klient_Number);
	 --------------------------------------
	 --------------------------------------
	 
	 Skip_Line(Socket);                      -- Ligger ett entertecken kvar i socketen.
	 
	 Put_line("Skickar spelarens namn och färg");
	 --------------------------------------
	 -------------------------------Skickar
	 if Klient_Number = 1 then
	    Put_Line(Socket,"Andreas");     -- Namn
	    Put_Line(Socket,"Blue");        -- Spelarens Färg
	 elsif Klient_Number = 2 then
	    Put_Line(Socket,"Tobias");      -- and so on..  
	    Put_Line(Socket,"Green");
	 elsif Klient_Number = 3 then
	    Put_Line(Socket,"Eric");
	    Put_Line(Socket,"Yellow");
	 elsif Klient_Number = 4 then
	    Put_Line(Socket,"Kalle");
	    Put_Line(Socket,"Red");
	 end if;
	 --------------------------------------
	 --------------------------------------   
	 
	 
	 Put_line("Tar emot spelarnas namn och färger");
	 --------------------------------------
	 ------------------------------Tar Emot   
	 for I in 1 .. NumPlayers loop
	    Get_Line(Socket, Data.Players(I).Name,                  -- Spelarnas Namn 
	 	     Data.Players(I).NameLength);                   -- Spelarnas Namn Längder
	    Get_Line(Socket, Player_Colour,                         -- Spelarnas Färger
	 	     Player_Colour_Length);                         -- Spelarnas Färg Längder
	    
	    
	    --| Översätter sträng till Colour_Type (Lite fult tyvärr...)        
	    if Player_Colour(1 .. Player_Colour_Length) = "Blue" then
	       Data.Players(I).Colour := Blue;
	    elsif Player_Colour(1 .. Player_Colour_Length) = "Green" then
	       Data.Players(I).Colour := Green;
	    elsif Player_Colour(1 .. Player_Colour_Length) = "Yellow" then
	       Data.Players(I).Colour := Yellow;
	    elsif Player_Colour(1 .. Player_Colour_Length) = "Red" then
	       Data.Players(I).Colour := Red;
	    end if;
	 end loop;
	 
	 -------------------------------------------------------------
	 --| Done with the player setup ------------------------------   -- Gamla
	 -------------------------------------------------------------
	 
	 Put_line("Tar emot banan");
	 Get_Map(Socket, Data, Check_Update => False);
	 
	 
	 Put_line("Game loopen börjar");
	 ----------------------------------------------------------------------------------------------------
	 --|
	 --| Game loop
	 --|
	 ----------------------------------------------------------------------------------------------------
	 Set_Echo(Off);
	 Cursor_Invisible;
	 loop
	    -- Get(Socket,Loop_Counter);    -- tar emot serverns loop_counter
	    
	    
	    --Här får vi info om alla skottens koordinater
	    DeleteList(Shot_List);
	    Get(Socket, Shot_List);
	    DeleteList(Obstacle_List);
	    Get(Socket, Obstacle_List);
	    DeleteList(Powerup_List);
	    Get(Socket, Powerup_List);
	    
	    
	    --      Skip_Line(Socket);
	    
	    
	    --if Loop_Counter mod 2 = 1 then
	    -- Hämtar all data från servern
	    Get_Map(Socket, Data);        -- Map_Handling
	    Get_Game_Data(Socket,Data);
	    --end if;
	    
	    --Följande ballar ur.
	    --  if Players_Are_Dead(Data.Players) then
	    --     --exit;
	    --     raise GNAT.SOCKETS.SOCKET_ERROR;
	    --  end if;
	    
	    -----------------------------------
	    -- GET ENEMY WAVE
	    -----------------------------------
	    
	    for I in waves'range loop

	       Delete_enemy_list(Waves(I));

	       Get_Enemy_Ships(Waves(I), Socket); -- Tobias
						  --DeleteList(Enemies);
						  --Get(Socket, Enemies);
	    end loop;
	    
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
	    
	    
	    Clear_Window;
	    
	    -----------------------------------------------------------
	    --------------------------------------| Utskrift Börjar |--
	    -----------------------------------------------------------
	    
	    
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
	    
	    --------------------------------
	    --| Skriver ut banan
	    --------------------------------
	    Put_World(Data.Map, Gameborder_X, Gameborder_Y, Game_Wall_Background, Game_Wall_Line);     -- put world // Eric
	    Set_Colours(White, Black);
	    
	    --------------------------------
	    
	    Put_Player_Ships(Data, NumPlayers);          -- put Ships // Andreas
	    
	    for I in Waves'range loop					 
	       Put_enemies(Waves(I));
	       --Put(Enemies);
	    end loop;
	    
	    Put_Objects(Shot_List);
	    Put_Objects(Obstacle_List);
	    Put_Objects(Powerup_List);
	    Goto_XY(World_X_Length , World_Y_Length);
	    
	    --Put X Y koordinater för alla skott [TEST] [OK]
	    --Put(Shot_List);
	    
	    
	    
	    Set_Colours(White, Black);
	    
	    
	    -----------------------------------------------------------
	    ---------------------------------------| Utskrift klara |--
	    -----------------------------------------------------------


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
	    
	    for I in waves'range loop
	       
	       Delete_enemy_list(Waves(I));
	       
	    end loop;
	    -- Close(Socket);
	    Cursor_visible;
	    New_Line;
	    Put("Someone disconnected!");
	    exit;                              -- Meningen är att man kanske kommer tillbaka till menyn.
      end;
      
   end loop;
   Cursor_visible;
   Set_Echo(On);

   

end Klient;
