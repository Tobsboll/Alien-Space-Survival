with Ada.Command_Line;        use Ada.Command_Line;
with Ada.Exceptions;          use Ada.Exceptions;
with Ada.Text_IO;             use Ada.Text_IO;
with Ada.Integer_Text_IO;     use Ada.Integer_Text_IO;
with TJa.Sockets;             use TJa.Sockets;
with TJa.Keyboard;            use TJa.Keyboard;
with TJa.Keyboard.Keys;       use TJa.Keyboard.Keys;
with TJa.Window.Text;         use TJa.Window.Text;
with Ada.Strings;             use Ada.Strings;          

with Object_Handling;         use Object_Handling;
with Graphics;                use Graphics;
with Definitions;             use Definitions;
with Gnat.Sockets;

with Input;                   use Input;
with Background_Battle;       use Background_Battle;
with Menu;                    use Menu;
with Window_Handling;         use Window_Handling;
with Box_Hantering;           use Box_Hantering;
with Space_Map;  

procedure Klient is

   
   -------------------------------------------------------------

   -- Packet som hanterar banan.
   package Bana is
      new Space_map(X_Width => World_X_Length,
		    Y_Height => World_Y_Length);
   use Bana;
   
   --------------------------------------------------------------
   --------------------------------------------------------------
   --| Början på Game Datan
   --------------------------------------------------------------
   --------------------------------------------------------------
   type Game_Data is
      record
   	 Layout   : Bana.World;        -- Banan är i packetet så att både klienten och servern 
   	                               -- hanterar samma datatyp / Eric
   	 Players  : Player_Array;      -- Underlättade informationsöverföringen mellan klient och server.
	 
   	 Ranking  : Ranking_List;      -- Vem som har mest poäng
   	 Settings : Setting_Type;      -- Inställningar.
      end record; 
   -------------------------------------------------------------
   -------------------------------------------------------------
   
   
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
      -- Tar emot Banan.
      Get(Socket, Gen_Map_Active);
      if Gen_Map_Active = 1 then
	 Data.Settings.Generate_Map := True;       -- Generering av banan är inaktiv
	 for I in World'Range loop
	    for J in X_Led'Range loop
	       Get(Socket, Data.Layout(I)(J));      -- Tar emot Banan.
	    end loop;
	 end loop;
      elsif Gen_Map_Active = 0 then
	 Data.Settings.Generate_Map := False;       -- Generering av banan är inaktiv
      end if;
      
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
      Goto_XY(X+15,Y);
      Put("Health");
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
	 
	 for J in 1 .. (13-Data.Players( Data.Ranking(I) ).NameLength) loop  -- Fyller ut mellan namn och liv
	    Put(' ');
	 end loop;
	 
	 Set_Foreground_Colour(Red);                             -- Ställer in färgen på hjärtan.
	 
	 
	 if Data.Players( Data.Ranking(I) ).Ship.Health = 0 then            -- Om död.
	    Put("R.I.P.");
	    
	 elsif Data.Players( Data.Ranking(I) ).Ship.Health > 0 then         -- annars lever
	    
	    for J in 1 .. Data.Players( Data.Ranking(I) ).Ship.Health loop
	       Put("♥ ");                                               -- Antal liv
	    end loop;
	    
	    for J in 1 .. 3-Data.Players( Data.Ranking(I) ).Ship.Health loop
	       Put(' ');                                               -- Ersätter förloarade liv med mellanrum.
	       Put(' ');    
	    end loop;
	 end if;
	 Set_Text_Modes(Off,Off,Off);
	 Set_Foreground_Colour(Old_Text_Colour);                    -- Ställer tillbaka till text färgen.
	 Put(Data.Players( Data.Ranking(I) ).Score, Width => 9);    -- skriver ut spelarens poäng
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
      
      --| Koden som är bortkommenterad nedanför är för själva startmenyn
      --| Den är bortkommenterad då det kanske är jobbigt att bläddra i menyn
      --| varje gång man vill testa sin kod.
      
      -------------------------------------------------------------
      --| Start of Menu -------------------------------------------    -- NYA
      -------------------------------------------------------------
      loop
      	 delay(0.1);
      	 Put_Spacebattle(Move, Shot, Gameborder_X, GameBorder_Y, 
      			 World_X_Length, World_Y_Length);
	 
      	 Put_Menu(Choice, NumPlayers, Portadress, Ipadress, 
      		  Data.Players(1).Name, Data.Players(1).NameLength);
	 
      	 exit when Choice = 'C' or Choice ='J' or Choice = 'E';
	 
      end loop;
      -------------------------------------------------------------
      --| End of Menu ---------------------------------------------     -- NYA
      -------------------------------------------------------------
      
      
      if Choice = 'E' then -- Exit
	 
      	 -- Put_Exiting_Game;                   -- A screen shuting down the game.
	 
      	 exit;
      end if;
      
      begin
	 -------------------------------------------------------------
	 --| Player setup before the game ----------------------------     -- NYA
	 -------------------------------------------------------------
	 
	 -- Initierar en socket, detta krävs för att kunna ansluta denna till
	 -- servern.
	 Initiate(Socket);
	 
	 --      Put_Waiting_For_Server;             -- A screen that waits for server.
	 Put_Line("Waiting for connection");
	 Connect(Socket, Argument(1), Positive'Value(Argument(2)));      -- Connects to the server
	 Put_Line("You are connected to the server");
	 
	 
	 Put(Socket, Choice);                        -- Sends the playerchoice (Join/Create)
	 Put_line(Socket, NumPlayers);               -- Join = 0 / Create = 1,2,3,4
	 
	 Set_Colours(Text_Colour_1, Background_Colour_1);  -- Change colour on the terminalen
	 Clear_Window;
	 
	 --------------------------------------
	 ------------------------------Tar Emot
	 Put_Line("Waiting for someone to create a game");
	 Get(Socket, NumPlayers);                -- Number of Players.
	 
	 if NumPlayers = 5 then                  -- If someone already created a game
	    Clear_Window;
	    Get(Socket, NumPlayers);             -- Gets the total number of player
	    Put("Someone was faster than you and created a game with ");
	    Put(NumPlayers, Width => 0);
	    Put_Line(" Players");
	    Put("Press Enter to join the game");
	    Skip_Line;
	    New_Line;
	 end if;
	 
	 Put_Line("Waiting for players to join the game");
	 Get(Socket, Klient_Number);                -- Players klient Number
	 
	 Set_Window_Title("Klient",Klient_Number);  -- Change the window title
						    --------------------------------------
						    --------------------------------------
	 
	 Skip_Line(Socket);                      -- Ligger ett entertecken kvar i socketen.
	 
	 --------------------------------------
	 -------------------------------Skickar
	 Put_Line(Socket, Data.Players(1).Name(1..Data.Players(1).NameLength)); -- Sends the players nickname
	 
	 if Klient_Number = 1 then
	    Put_Line(Socket,"Blue");        -- Player Colour
	 elsif Klient_Number = 2 then
	    Put_Line(Socket,"Green");
	 elsif Klient_Number = 3 then
	    Put_Line(Socket,"Yellow");
	 elsif Klient_Number = 4 then
	    Put_Line(Socket,"Red");
	 end if;
	 --------------------------------------
	 --------------------------------------   
	 
	 
	 --      Put_Waiting_For_Players(Socket);                     -- A screen that waits for players
	 
	 
	 Put_Line("Waiting for players");
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
	 --| Done with the player setup ------------------------------   -- NYA
	 -------------------------------------------------------------
	 
	 
	 --  -------------------------------------------------------------
	 --  --| Player setup before the game ----------------------------     -- Gamla
	 --  -------------------------------------------------------------	 
	 --  -- Initierar en socket, detta krävs för att kunna ansluta denna till
	 --  -- servern.
	 --  Initiate(Socket);
	 
	 --  Set_Colours(Text_Colour_1, Background_Colour_1);  -- Ändrar färgen på terminalen
	 --  Clear_Window;
	 

	 
	 
	 --  Put("Join eller Create, J eller C: ");

	 
	 --  loop	 
	 --     Get(Choice);
	 --     if Choice = 'J' then
	 --        Put("Waiting for connection...");
	 --        Connect(Socket, Argument(1), Positive'Value(Argument(2)));
	 --        Put("You are connected!");
	 --        exit;
	 --     elsif Choice = 'C' then
	 --        New_Line;
	 --        Connect(Socket, Argument(1), Positive'Value(Argument(2)));
	 --        Put("Välj antal spelare ");
	 --        Get(NumPlayers);
	 --        Put_Line(Socket, NumPlayers);
	 --        New_Line;
	 --        Put("Waiting for players to join");
	 --        exit;
	 --     else
	 --        Put("Skriv C eller J!");

	 --     end if;
	 --  end loop;
	 


	 --  --------------------------------------
	 --  ------------------------------Tar Emot
	 --  Get(Socket, NumPlayers);                -- Antal spelare som spelar
	 --  Put(NumPlayers);
	 --  Get(Socket, Klient_Number);             -- Spelarens Klient nummer
	 --  Put(Klient_Number);
	 --  New_Line;
	 --  Set_Window_Title("Klient",Klient_Number);
	 --  --------------------------------------
	 --  --------------------------------------
	 
	 --  Skip_Line(Socket);                      -- Ligger ett entertecken kvar i socketen.
	 
	 --  Put_line("Skickar spelarens namn och färg");
	 --  --------------------------------------
	 --  -------------------------------Skickar
	 --  if Klient_Number = 1 then
	 --     Put_Line(Socket,"Andreas");     -- Namn
	 --     Put_Line(Socket,"Blue");        -- Spelarens Färg
	 --  elsif Klient_Number = 2 then
	 --     Put_Line(Socket,"Tobias");      -- and so on..  
	 --     Put_Line(Socket,"Green");
	 --  elsif Klient_Number = 3 then
	 --     Put_Line(Socket,"Eric");
	 --     Put_Line(Socket,"Yellow");
	 --  elsif Klient_Number = 4 then
	 --     Put_Line(Socket,"Kalle");
	 --     Put_Line(Socket,"Red");
	 --  end if;
	 --  --------------------------------------
	 --  --------------------------------------   
	 
	 
	 --  Put_line("Tar emot spelarnas namn och färger");
	 --  --------------------------------------
	 --  ------------------------------Tar Emot   
	 --  for I in 1 .. NumPlayers loop
	 --     Get_Line(Socket, Data.Players(I).Name,                  -- Spelarnas Namn 
	 --  	     Data.Players(I).NameLength);                   -- Spelarnas Namn Längder
	 --     Get_Line(Socket, Player_Colour,                         -- Spelarnas Färger
	 --  	     Player_Colour_Length);                         -- Spelarnas Färg Längder
	    
	    
	 --     --| Översätter sträng till Colour_Type (Lite fult tyvärr...)        
	 --     if Player_Colour(1 .. Player_Colour_Length) = "Blue" then
	 --        Data.Players(I).Colour := Blue;
	 --     elsif Player_Colour(1 .. Player_Colour_Length) = "Green" then
	 --        Data.Players(I).Colour := Green;
	 --     elsif Player_Colour(1 .. Player_Colour_Length) = "Yellow" then
	 --        Data.Players(I).Colour := Yellow;
	 --     elsif Player_Colour(1 .. Player_Colour_Length) = "Red" then
	 --        Data.Players(I).Colour := Red;
	 --     end if;
	 --  end loop;
	 
	 --  -------------------------------------------------------------
	 --  --| Done with the player setup ------------------------------   -- Gamla
	 --  -------------------------------------------------------------
	 
	 Put_line("Tar emot banan");
	 for I in World'Range loop
	    for J in X_Led'Range loop
	       Get(Socket, Data.Layout(I)(J));      -- Tar emot Banan.
	    end loop;
	 end loop;
	 
	 
	 
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
	    Get_Game_Data(Socket,Data);
	    --end if;
	    
	    Clear_Window;
	    --------------------------------
	    --| Skriver ut banan
	    --------------------------------
	    Put_World(Data.Layout, Gameborder_X, Gameborder_Y, Background_Colour_1, Text_Colour_1, true);              -- put world // Eric
	    Put_Double_Line_Box(World_Box_X, World_Box_Y, World_Box_Length, 
				World_Box_Heigth, Background_Colour_1, Text_Colour_1);            -- En låda runt spelplanen / Eric
												  --  Put_Box(Spelplanen_X, SpelPlanen_Y, World_X_Length-2, 
												  --  	      World_Y_Length, Background_Colour_1, Text_Colour_1);            -- En låda runt spelplanen / Eric
	    
	    --------------------------------
	    
	    Put_Player_Ships(Data, NumPlayers);          -- put Ships // Andreas
							 -- Put_Enemies();
	    Put_Objects(Shot_List);
	    Put_Objects(Obstacle_List);
	    Put_Objects(Powerup_List);
	    Goto_XY(World_X_Length , World_Y_Length);
	    
	    --Put X Y koordinater för alla skott [TEST] [OK]
	    --Put(Shot_List);
	    
	    
	    --------------------------------
	    --| Highscore fönster
	    --------------------------------
	    Put_Box(Highscore_Window_X, Highscore_Window_Y, Highscore_Window_Width, 
		    Highscore_Window_Height+NumPlayers, Background_Colour_2, Text_Colour_2);     -- En låda runt scorelistan Eric
	    
	    Put_Score(Data, NumPlayers, Highscore_X, Highscore_Y, 
		      Background_Colour_2, Text_Colour_2);    -- Skriver ut den sorterade scorelistan / Eric
	    
	    --------------------------------
	    
	    --------------------------------
	    --| Där man skriver för att chatta
	    --------------------------------
	    Put_Box(Chatt_Window_X, Chatt_Window_Y,                    -- Ett litet fönster för att skriva i. / Eric 
		    World_X_Length, 2, Background_Colour_1, Text_Colour_1); 
	    Goto_XY(Gameborder_X+1,Gameborder_Y+World_Y_Length+2);
	    Put("Här skriver man.");
	    --------------------------------
	    
	    
	    Get_Input;
	    
	    --------------------------------------------------
	    if Is_Esc then-- måste ändras
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
