with TJa.Keyboard;                 use TJa.Keyboard;
with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Integer_Text_IO;          use Ada.Integer_Text_IO;
with Ada.Command_Line;             use Ada.Command_Line;
with TJa.Sockets;                  use TJa.Sockets;
with TJa.Window.Text;              use TJa.Window.Text;
with Enemy_ship_handling;          use Enemy_Ship_handling;
with Ada.Numerics.Discrete_Random; 

with Object_Handling;              use Object_Handling;
with Graphics;                     use Graphics;
with Definitions;                  use Definitions;
with Gnat.Sockets;

with Window_Handling;              use Window_Handling;
with Map_Handling;                 use Map_Handling;
with Game_Engine;                  use Game_Engine;

procedure Server is
   
   
   --------------------------------------------------
   -- Slut
   --------------------------------------------------
   
   
   

   
   Socket1, Socket2, Socket3, Socket4 : Socket_Type;
   Sockets : Socket_Array             := (Socket1, Socket2, Socket3, Socket4);
   Listener                           : Listener_Type;
   --Keyboard_Input                     : Character;
   
   --------------------------------------------------------------

   
   ---------------------------------------------------------------
   -- Skickar all Spelinformation till klienterna. / Eric
   ----------------------------------------------------------------
   procedure Put_Game_Data(Socket : Socket_Type;
		           Data : in Game_Data) is
      
      
      -- Skickar spelarens skeppdata    
      -------------------------------------------------
      procedure Put_Ship_Data(Socket : in Socket_Type;
			      Ship   : in Ship_Spec) is
      begin
	 
	 Put_Line(Socket,Ship.XY(1));
	 Put_Line(Socket,Ship.XY(2));
	 Put_Line(Socket,Ship.Health);
	 
	 
      end Put_Ship_Data;
      -------------------------------------------------
      
      
   begin
      --------------------------------------------------------
      -- Skickar spelarnas Information
      --------------------------------------------------------
      for I in Player_Array'Range loop
	 -- Skickar om spelaren spelar eller inte.

	 
	 if Data.Players(I).Playing = True then
	    
	    Put_Line(Socket,1);
	    
	    -- Skickar spelarens skeppdata
	    Put_Ship_Data(Socket,Data.Players(I).Ship);
	    
	    
	    -- Skickar spelarens poäng
	    Put_Line(Socket,Data.Players(I).Score);
	    
	    
	    -- Skickar inget mer om spelaren inte spelar.
	 elsif Data.Players(I).Playing = False then
	    Put_Line(Socket,0);
	 end if;

      end loop;
      
      for I in Ranking_List'Range loop
	 Put_Line(Socket, Data.Ranking(I));
      end loop;
      
      
   end Put_Game_Data;
   --------------------------------------------------
   
   --------------------------------------------------
   
   --------------------------------------------------
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
   --------------------------------------------------
   
   --------------------------------------------------
   procedure Remove_Player(Socket     : in out Socket_Type; 
			   Player_Num : in Integer) is
      
   begin
      
      Close(Socket);
      
      New_Line;
      Put("Player ");
      Put(Player_Num, 0);
      Put(" has left the game");
      
      
   end Remove_Player;
   --------------------------------------------------
   
   --------------------------------------------------

   --------------------------------------------------

   --------------------------------------------------


   
   

   ----------------------------------------------------------------------------------------------------
   --|
   --| DECLARATIONS
   --|
   ----------------------------------------------------------------------------------------------------				 
   Player_Choice          : Character;
   Num_Players            : Integer;
   Player_Joined          : Integer := 0;
   Temp_Integer           : Integer;
   
   Game                   : Game_Data;
   Loop_Counter           : Integer;
   
   --Enemies1, Enemies2, Enemies3, Enemies4 : Enemy_List;
   Waves                  : Enemy_List_Array;
   --Waves2                 : Enemy_List_Array_2;
   
   Shot_List              : Object_List; --shot_handling.ads
   Obstacle_List          : Object_List;
   Powerup_List           : Object_List;
   Obstacle_Y             : Integer;
   
   Player_Colour          : String(1..15);           -- Inhämtning (innan GameLoopen) av spelarnas färger
   Player_Colour_Length   : Integer;
   Background_Colour_1    : Colour_Type := Black;    -- Bakgrundsfärg till (Scoreboard, Hela Terminalen)
   Text_Colour_1          : Colour_Type := White;    -- Teckenfärg    till (Scoreboard, Hela Terminalen)
   
   
begin
   Set_Window_Title("Server");
   
   Set_Colours(Text_Colour_1, Background_Colour_1);  -- Ändrar färgen på terminalen
   
   -- "öppna dörren". För tillfället endast lokalt, ändra sedan.
   Initiate(Listener, Integer'Value(Argument(1)), Localhost => true);
   
   Put_Line("Servern är igång, väntar på connection");
   
   --  --| Koden som är bortkommenterad nedanför är för själva startmenyn
   --  --| Den är bortkommenterad då det kanske är jobbigt att bläddra i menyn
   --  --| varje gång man vill testa sin kod.
   
   --  -------------------------------------------------------------
   --  --| Player setup before the game ----------------------------     -- NYA
   --  -------------------------------------------------------------
   --  loop
   --     Player_Joined := Player_Joined + 1;
   --     Add_Player(Listener, Sockets(Player_Joined), Player_Joined); -- Adding players
      
   --     Get(Sockets(Player_Joined), Player_Choice);
   --     Put(Player_Choice);
   --     Get(Sockets(Player_Joined), Num_Players);
   --     Put(Num_Players);
   --     Skip_Line(Sockets(Player_Joined));
      
      
   --     if Player_Choice = 'C' then      -- Checking if the player is the host
   --  	 for I in 1 .. Player_Joined loop
   --  	    Put_Line("Sending the total number of player to those who are waiting");
   --  	    Put_Line(Sockets(I), Num_Players);        -- Sends the total number of players
   --  	                                              -- to the players who are waiting.
   --  	 end loop;
	 
   --  	 if Num_Players > Player_Joined then
   --  	    while Player_Joined < Num_Players Loop          -- Continues adding player
   --  	       Player_Joined := Player_Joined + 1;
   --  	       Add_Player(Listener, Sockets(Player_Joined), Player_Joined);
   --  	       Get(Sockets(Player_Joined), Player_Choice);
	       
   --  	       if Player_Choice = 'C' then                  -- Someone also choose host.
   --  		  Put_Line(Sockets(Player_Joined), 5);      -- Client are informed.		 
   --  	       end if;
	       
   --  	       Put_Line(Sockets(Player_Joined), Num_Players);
   --  	       Get(Sockets(Player_Joined), Temp_Integer);
   --  	       Skip_Line(Sockets(Player_Joined));
	       
   --  	    end loop;
   --  	 end if;
	 
   --  	 exit;                         -- Done with adding players
	 
   --     end if;
      
   --  end loop;
   
   --  Put_Line("The server are finished with adding players");
   
   --  -------------------------------------Skickar
   --  --------------------------------------------
   --  for I in 1..Num_Players loop
   --     Put_Line(Sockets(I), I);               -- Tells the client what number they have.
   --  end loop;
   --  --------------------------------------------
   --  --------------------------------------------
   
   
   --  ------------------------------------Tar Emot
   --  --------------------------------------------   
   --  for I in 1..Num_Players loop
   --     Get_Line(Sockets(I), Game.Players(I).Name,    -- Spelarens namn
   --  	       Game.Players(I).NameLength);         -- Spelarens namn längd
      
   --     if Game.Players(I).NameLength = Game.Players(I).Name'Last then
   --  	 Skip_Line(Sockets(I));
   --     end if;
      
      
   --     Get_Line(Sockets(I), Player_Colour,           -- Spelarens färgnamn.
   --  	       Player_Colour_Length);               -- Spelarens färgnamnlängd.
      
   --     if Player_Colour_Length = Player_Colour'Last then
   --  	 Skip_Line(Sockets(I));
   --     end if;
      
   --     -------------------------------------Skickar
   --     --------------------------------------------   
   --     for J in 1..Num_Players loop
   --  	 Put_Line(Sockets(J), Game.Players(I).
   --  		    Name(1..Game.Players(I).NameLength));  -- Spelarnas namn
   --  	 Put_Line(Sockets(J), 
   --  		  Player_Colour(1..Player_Colour_Length)); -- Spelarnas Färger

   --     end loop;
   --     --------------------------------------------
   --     --------------------------------------------
   --  end loop;
   --  -------------------------------------------------------------
   --  --| Done with the player setup ------------------------------   -- NYA
   --  -------------------------------------------------------------
   
   
   -------------------------------------------------------------
   --| Player setup before the game ----------------------------     -- Gamla
   -------------------------------------------------------------	 
   
   -- vänta på spelare 1
   Add_Player(Listener, Sockets(1), 1);
   Get(Sockets(1), Num_Players); -- spelare 1 bestämmer hur många som ska spela.
   Skip_Line(Sockets(1));                    -- Låg ett entertecken kvar i socketen

   Put_line("Waiting for players...");
   
   -- lägg till wait_for_connections för så många spelare som angetts!
   for I in 2..Num_Players loop
      Add_Player(Listener, Sockets(I), I);
   end loop;
   
   New_Line;
   Put("All players have joined the game.");
   
   
   -------------------------------------Skickar
   --------------------------------------------
   for I in 1..Num_Players loop
      Put_Line(Sockets(I), Num_Players);     -- Hur många spelare som spelar
      Put_Line(Sockets(I), I);               -- Vad för klient nr man har.
   end loop;
   --------------------------------------------
   --------------------------------------------
   
   
   
   ------------------------------------Tar Emot
   --------------------------------------------   
   for I in 1..Num_Players loop
      Get_Line(Sockets(I), Game.Players(I).Name,    -- Spelarens namn
   	       Game.Players(I).NameLength);         -- Spelarens namn längd
      Get_Line(Sockets(I), Player_Colour,           -- Spelarens färgnamn.
   	       Player_Colour_Length);               -- Spelarens färgnamnlängd.
      
      
      -------------------------------------Skickar
      --------------------------------------------   
      for J in 1..Num_Players loop
   	 Put_Line(Sockets(J), Game.Players(I).
   		    Name(1..Game.Players(I).NameLength));  -- Spelarnas namn
   	 Put_Line(Sockets(J), 
   		  Player_Colour(1..Player_Colour_Length)); -- Spelarnas Färger
      end loop;
      --------------------------------------------
      --------------------------------------------
   end loop;
   -------------------------------------------------------------
   --| Done with the player setup ------------------------------   -- Gamla
   -------------------------------------------------------------
   
   
   ---------------------------------------------------------------
   --| Används endast för att testa utskrift av poängtavlan + liv
   --| Tas bort senare när vi har en räknare för detta
   ---------------------------------------------------------------
   Game.Players(1).Score := 152;
   Game.Players(2).Score :=  94;
   Game.Players(3).Score :=  26;
   Game.Players(4).Score :=   2;
   ---------------------------------------------------------------

   
   Put_line("Spelet är igång!");
   --------------------------------------------------
   --------------------------------------------------
   
   

   
   
   
   ----------------------------------------------------------------------------------------------------
   --|
   --| Game loop
   --|
   ----------------------------------------------------------------------------------------------------
   Set_Default_Values(Num_Players, Game);
   --Waves := (Enemies1, Enemies2, Enemies3, Enemies4);
   Loop_Counter := 1;
   
   
   for I in 1..Num_Players loop
      Game.Ranking(I) := I;  -- Ställer bara in poängplaceringen.
      
      -- Skickar startbanan till alla klienter 
      Send_Map(Sockets(I), Game, Check_Update => False);     -- Map_Handling
   end loop;    
   
   Obstacle_Y := Obstacle_Y_Pos; --konstant från definitions, men kan varieras nedan. (Jag har en plan)
   
   
   --Testar att skapa olika typer av väggar
   --Create_Object(ObstacleType(1), 2, Obstacle_Y, Light, Obstacle_List);
   
   Create_Object(ObstacleType(2), 10, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 15, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 20, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 25, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 30, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 35, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 40, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 45, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 50, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 55, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 60, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 65, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 70, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 75, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 80, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 85, 20, Obstacle_Y, Obstacle_List);

   
    -- Create_Object(ObstacleType(3), 25, 20, Obstacle_Y, Obstacle_List);
    
   --for I in 1..6 loop
   --Create_Wall(Obstacle_List, Obstacle_Y-(I*2));
   -- end loop;
   --Create_Wall(Obstacle_List, Obstacle_Y);
   
   Create_Object(PowerUpType(2), 40, Obstacle_Y_Pos+3, 0, Powerup_List);
   Create_Object(PowerUpType(3), 50, Obstacle_Y_Pos+5, 0, Powerup_List);
   
   
   -----------------------------------
   -- SPAWN FIRST WAVE
   -----------------------------------
   
   Spawn_Wave(30, --Antal
   	      EnemyType(1), --Typ
   	      1,
   	      1,
   	      waves(1));
   
   Spawn_Wave(1, --Antal
   	      EnemyType(3), --Typ
   	      3,
   	      1,
	      waves(2));
   
   
   --  Spawn_Wave(2, --Antal
   --  	      EnemyType(1), --Typ
   --  	      4,
   --  	      1,
   --  	      waves(3));
   
   -----------------------------------
   -- end SPAWN FIRST WAVE
   -----------------------------------
   
   loop 
      
      --  if Num_Players = 1 then
      --  	 delay(0.05);
      --  elsif Num_Players = 2 then
      --  	 delay(0.01);
      --  elsif Num_Players = 3 then
      --  	 delay(0.01);
      --  elsif Num_Players = 4 then
      --  	 delay(0.01);
      --  end if;
      
      --------------------------------------------------
      --| SCROLLING MAP 
      --| "Level 2" => därför ej nödvändig än
      --------------------------------------------------
      if Game.Settings.Generate_Map then       -- Bestämmer under spelet om banan ska börja genereras eller inte.
      	 if Loop_Counter mod 4 = 0 then
      	    if Loop_Counter > 50 and Loop_Counter < 100 then

      	       New_Top_Row(Game.Map, Close => True);  -- Banan blir mindre
	       

      	    elsif Loop_Counter > 150 and Loop_Counter < 225 then
	       
      	       New_Top_Row(Game.Map);                 -- Vanlig randomisering
      	    else

      	       New_Top_Row(Game.Map, Straigt => True);-- Raka väggar
	       
      	    end if;   
      	    Move_Rows_Down(Game.Map);       -- Flyttar ner hela banan ett steg.
      	 end if;
      end if;
      

      if Loop_Counter > 225 then
      	 Loop_Counter := 1;
      end if;
      


      -- Hitbox_Procedure/compare_coordinates_procedure i en for loop för alla skepp/skott    //Andreas
      
      -- Skickar information till klienterna. / Eric
      
      
      for I in 1..Num_Players loop
	 if Game.Players(I).Ship.Health <= 0 then
	    Game.Players(I).Playing := False;
	 end if;
	 
	--exit when Players_Are_Dead(Game.Players);  --detta ballar ur.
	 
	 if Game.Players(I).Playing then
	    Player_Collide_In_Object( Game.Players(I).Ship.XY(1),
				      Game.Players(I).Ship.XY(2),
				      Game.Players(I).Ship, --Uppdaterar ship_spec
				      Shot_List);           --Om spelare träffas
				                            --Av skott.
				                            
		for K in 1..4 loop
	       		Player_Collide_In_Object( Game.Players(I).Ship.XY(1),
						 Game.Players(I).Ship.XY(2),
						 Game.Players(I).Ship, --Uppdaterar ship_spec
						 Waves(K));        -- Om spelare krashar i fiende
	    end loop;
	 end if;                                         

	 
	 Put(Sockets(I), Shot_List);
	 Put(Sockets(I), Obstacle_List);
	 Put(Sockets(I), Powerup_List);
	 Send_Map(Sockets(I), Game);      -- Map_Handling
      	 Put_Game_Data(Sockets(I),Game);

      end loop;
      

      -----------------------------------
      -- Update Enemy ships
      -----------------------------------
     
	Update_Enemy_Position(Waves, Shot_List, Obstacle_Y, Game.Players);
  
      -----------------------------------
      -- PUT ENEMY SHIPS
      -----------------------------------
      
      for I in 1..Num_Players loop
	 for J in Waves'Range loop
	    Put_Enemy_ships(Waves(J), Sockets(I));
	 end loop;
      end loop;
      
      --  for I in 1..Num_Players loop
      --  	 for J in 1..4 loop
      --  	   --Waves2'Range loop
      --  	    Put(Sockets(I), Waves2(J));
      --  	    Put('1');
      --  	 end loop;
      --  end loop;
      --Put('!');
      -----------------------------------
      -- end PUT ENEMY SHIPS
      -----------------------------------   
      
      Get_Player_Input(Sockets, Num_Players, Game, Shot_List, Obstacle_List, Powerup_List);
      
      --Uppdatera skottens position
      Shot_Movement(Shot_List);
      Shots_Collide_In_Objects(Shot_List, Obstacle_List);
      for B in Waves'Range loop
	 Shots_Collide_In_Objects(Shot_List, Waves(B));
      end loop;
      
      Loop_Counter := Loop_Counter + 1;
      
   end loop;
   
   ----------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------GAME LOOP END----
   ----------------------------------------------------------------------------------------------------
   
   --Efter spelets slut.
   
   for I in 1..Num_Players loop
      
      Remove_Player(Sockets(I), I);
      
   end loop; 
exception
   when GNAT.SOCKETS.SOCKET_ERROR => 
      
      DeleteList(Shot_List);
      DeleteList(Obstacle_List);
      DeleteList(Powerup_List);
      New_Line;
      Put("Someone disconnected!");
   when STORAGE_ERROR =>
      DeleteList(Shot_List);
      DeleteList(Obstacle_List);
      DeleteList(Powerup_List);
      New_Line;
      Put("VI HAR EN MINNESLÄCKAA!");
      

end Server;

--gnatmake $(~TDDD11/TJa-lib/bin/tja_config)
