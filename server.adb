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
with Space_Map;

procedure Server is
   
   
   --------------------------------------------------
   -- Slut
   --------------------------------------------------
   
   
   
   type Socket_Array is
     array (1..4) of Socket_Type;
   
   Socket1, Socket2, Socket3, Socket4 : Socket_Type;
   Sockets : Socket_Array             := (Socket1, Socket2, Socket3, Socket4);
   Listener                           : Listener_Type;
   Keyboard_Input                     : Character;
   
   --------------------------------------------------------------

   
   -- Paket som hanterar banan.
   package Bana is
      new Space_map(X_Width => World_X_Length,
		    Y_Height => World_Y_Length);
   use Bana;
   
   --------------------------------------------------------------
   --| Början på Game Datan
   --------------------------------------------------------------
   --------------------------------------------------------------
   type Game_Data is
      record
	 Layout   : Bana.World;     -- Måste klura lite till med detta.. / Eric
	 Players  : Player_Array;
	 
	 Ranking  : Ranking_List;   -- Vem som har mest poäng
	 Settings : Setting_Type;   -- Inställningar.
      end record; 
   
   --------------------------------------------------------------
   --------------------------------------------------------------
   --| Slut på Game Datan
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
      if Data.Settings.Generate_Map then            -- Skickar banan om den generarar väggar
	 
	 Put_Line(Socket, 1);
	 
	 for I in World'Range loop
	    for J in X_Led'Range loop
	       Put_line(Socket, Data.Layout(I)(J)); -- Skickar Banan till klienterna
	    end loop;
	 end loop;
	 
      elsif Data.Settings.Generate_Map = False then -- Genererar inte ny vägg ( Ingen uppdatering )
	 Put(Socket, 0);
      end if;
      
      
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
   
   --------------------------------------------------
   
   --------------------------------------------------
   function Player_Collide (X,Y : in Integer;
			    L   : in Object_List
			   ) return Boolean is
      Object_X : Integer; 
      Object_Y : Integer;
   begin
      if not Empty(L) then
	 Object_X := L.XY_Pos(1);
	 Object_Y := L.XY_Pos(2);
	 --------------------------------------------------
	 --Med hinder:
	 --------------------------------------------------
	 if L.Object_Type in 11..20 then
	    
	    --Jämför Hindrets koord. med hela ship top:
	    --------------------------------------------------
	    for A in 1..2 loop      --Obstacle height
	       for I in 1..3 loop      --Ship top
		  for K in 1..3 loop   --Obstacle width
		     
		     if X+I = Object_X+K-1 and Y = Object_Y+A-1 then
			return True;
		     end if;
		  end loop;
	       end loop;
	    end loop;
	    
	    --Jämför Hindrets koord. med hela ship bottom:
	    --------------------------------------------------
	    for A in 1..2 loop      --Obstacle height
	       for I in 1..5 loop      --Ship bottom
		  for K in 1..3 loop   --Obstacle width
		     
		     if X+I-1 = Object_X+K-1 and Y+1 = Object_Y+A-1 then
			return True;
		     end if;
		  end loop;
	       end loop;
	    end loop;
	    
	    
	    return Player_Collide(X,Y,L.Next);
	    --------------------------------------------------
	    --Med PowerUps:
	    --------------------------------------------------
	 elsif L.Object_Type in 21..30 then
	    
	    for I in 1..3 loop      --Ship top
	       for K in 1..3 loop   --Object width
		  
		  if X+I = Object_X+K-2 and Y = Object_Y then
		     return True;
		  end if;
	       end loop;
	    end loop;
	    
	    for I in 1..5 loop      --Ship bottom
	       for K in 1..3 loop   --Object width
		  
		  if X+I-1 = Object_X+K-2 and Y+1 = Object_Y then
		     return True;
		  end if;
	       end loop;
	    end loop;
	    
	    --return Player_Collide(X,Y,L.Next);
	    
	    --------------------------------------------------
	    --Med Skott:
	    --------------------------------------------------
	 elsif L.Object_Type in 1..10 then
	    for I in 1..3 loop      --Ship top
	       
	       if X+I = Object_X and Y = Object_Y then
		  return True;
	       end if;
	    end loop;
	    
	    
	    for I in 1..5 loop      --Ship bottom
	       
	       
	       if X+I-1 = Object_X and Y+1 = Object_Y then
		  return True;
	       end if;
	       
	    end loop;
	    --return Player_Collide(X,Y,L.Next);
	    
	 end if;
	 
      end if;
      
      --Vid listans slut: 
      return False;
      
   end Player_Collide;
   --------------------------------------------------
   procedure Player_Collide_In_Object ( X,Y         : in Integer;
					--Data        : out Integer;
					Player_Ship : in out Ship_Spec;
					L           : in out Object_List) is
      
   begin
      if not Empty(L) then
	 
	 if Player_Collide (X, Y, L) then
	    
	    --------------------------------------------------
	    --Beskjuten?
	    --------------------------------------------------
	    if L.Object_Type in 1..10 then
	       if L.Object_Type = ShotType(1) then
		  Player_Ship.Health := Player_Ship.Health-1;
		  
	       elsif L.Object_Type = ShotType(2) then
		  Player_Ship.Health := Player_Ship.Health-1;
	       end if;
	       Remove(L);
	       
	       --------------------------------------------------
	       --PowerUp?
	       --------------------------------------------------
	    elsif L.Object_Type in 21..30 then
	       
	       if L.Object_Type = PowerUpType(1) then
		  null; --Öka Ship.Health
	       elsif L.Object_Type = PowerUpType(2) then
		  
		  Player_Ship.Missile_Ammo := Player_Ship.Missile_Ammo + 10;
		  
	       elsif L.Object_Type = PowerUpType(3) then
		  Player_Ship.Laser_Type := ShotType(2);
		  
		  --else
		  --Rekursion:
		  -- Player_Collide_In_Object(X,Y,Player_Ship,L.Next);
	       end if;
	       Remove(L);
	       
	       
	    end if;
	 else
	    Player_Collide_In_Object(X,Y,Player_Ship, L.Next);
	 end if;
      end if;
      
      
   end Player_Collide_In_Object;
   
   --------------------------------------------------
   -- procedure Handle_PowerUp (
   
   --------------------------------------------------
   --| PLAYER INPUT                              |--===========|===|
   --------------------------------------------------
   procedure Get_Player_Input(Sockets : in Socket_Array;
			      Num_Players : in Integer; --Num_Players ej längre global
			      Data : in out Game_Data;
			      Shot_List : in out Object_List;
			      Obstacle_List : in Object_List;
			      Powerup_List  : in out Object_List
			     ) is
      X          : Integer;
      Y          : Integer;
      Laser_Type : Integer;
      Ammo       : Integer;
      --Player_Ship: Ship_Spec;
   begin
      
      for I in 1..Num_Players loop
	 X          := Data.Players(I).Ship.XY(1);
	 Y          := Data.Players(I).Ship.XY(2);
	 Laser_Type := Data.Players(I).Ship.Laser_Type;
	 Ammo       := Data.Players(I).Ship.Missile_Ammo;
	 --Player_Ship:= Data.Players(I).Ship;
	 
	 Get(Sockets(I), Keyboard_Input); -- får alltid något, minst ett 'o'
	 Skip_Line(Sockets(I)); -- DETTA kan bli problem om server går långsammare än klienterna!! /Andreas
				--------------------------------------------------
				--| Movement tjafs 
				--|
				--| #Bruteforce
				--------------------------------------------------
	 
	 if Keyboard_Input /= 'o' then -- = om det fanns nollskild, giltig input.        
	    
	    
	    if Keyboard_Input = 'w' and then not Player_Collide(X,Y-1, Obstacle_List) then 
	       Data.Players(I).Ship.XY(2) := Integer'Max(2 , Y-1);
	       
	    elsif Keyboard_Input = 's' and then not Player_Collide(X,Y+1, Obstacle_List) then 
	       Data.Players(I).Ship.XY(2) := Integer'Min(World_Y_Length-1 , Y+1);
	       
	    elsif Keyboard_Input = 'a' and then not Player_Collide(X-Move_Horisontal,Y, Obstacle_List) then
	       Data.Players(I).Ship.XY(1) := Integer'Max(2 , X - Move_Horisontal);
	       
	    elsif Keyboard_Input = 'd' and then not Player_Collide(X+Move_Horisontal, Y , Obstacle_List) then
	       Data.Players(I).Ship.XY(1) := Integer'Min(World_X_Length - Player_Width ,X + Move_Horisontal);
	    elsif Keyboard_input = ' ' then 
	       --Data.Players(I).Playing := False;  --Suicide
	       
	       Create_Object(ShotType(Laser_Type),
			     X+2,
			     Y,
			     Up,
			     Shot_List                );
	    elsif Keyboard_input = 'm' and then Ammo > 0 then
	       
	       Create_Object(ShotType(4), -- 4 = Missile
			     X+2,
			     Y,
			     Up,
			     Shot_List                );
	       Data.Players(I).Ship.Missile_Ammo := Ammo - 1;
	       
	    elsif Keyboard_Input = 'e' then exit; -- betyder "ingen input" för servern.
	    end if;
	    
	    Player_Collide_In_Object(X,Y, Data.Players(I).Ship, Powerup_List); -- Returnerar hur mycket extra ammo man får
									       --  Data.Players(I).Ship.Missile_Ammo := Data.Players(I).Ship.Missile_Ammo + Ammo;
	 end if;
	 
      end loop;
      
   end Get_Player_Input;
   
   
   --------------------------------------------------
   --|  DEFAULT VALUES
   --|  Här 
   --------------------------------------------------
   procedure Set_Default_Values (Num_Players : in Integer;
				 Game        : in out Game_Data
				   --World_X_Length, World_Y_Length : in Integer   --GLOBALA VARIABLER
				) is
      Xpos : Integer;
      Interval : constant Integer := World_X_Length/(1+Num_Players);
   begin
      --------------------------------------------------
      --| Ships
      --------------------------------------------------
      Xpos := 0;
      
      for K in 1..Num_Players loop
	 --Spawning
	 Game.Players(K).Ship.XY(2) := World_Y_Length - 1;  -- + border_Length
	 Game.Players(K).Ship.XY(1) := Xpos + Interval; -- + border_Length;
	 Game.Players(K).Playing := True; 
	 Xpos := Xpos + Interval;
	 
	 --Equipment
	 Game.Players(K).Ship.Health := 3;
	 Game.Players(K).Ship.Laser_Type := 1;
	 Game.Players(K).Ship.Missile_Ammo := 5;
      end loop;
      
      -------------------------------------------------
      --| Banan
      -------------------------------------------------
      Generate_World(Game.Layout);  -- Genererar en helt ny bana med raka väggar. / Eric
      Game.Settings.Generate_Map := False; -- Sätter i början att banan inte ska genereras.   
      
      --------------------------------------------------
      
      
      
   end Set_Default_Values;
   
   --------------------------------------------------
   --|  SHOT MOVEMENT
   --|  
   --------------------------------------------------
   
   procedure Shot_Movement ( L : in out Object_List ) is
      Direction : Integer; -- := L.Attribute;
      Ydiff     : constant Integer := 1;
   begin
      
      if not Empty(L) then
	 Direction := L.Attribute;
	 L.XY_Pos(2) := L.XY_Pos(2) + Ydiff*Direction;
	 if L.XY_Pos(2) = 0 or L.XY_Pos(2) = World_Y_Length+1 then
	    Remove(L);
	    Shot_Movement(L);
	 else
	    Shot_Movement(L.Next);
	 end if;
      end if;
      
   end Shot_Movement; 
   

   
   

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
   
   Enemies1, Enemies2, Enemies3, Enemies4 : Enemy_List;
   Waves                  : Enemy_List_Array;
   
   Shot_List              : Object_List; --shot_handling.ads
   Obstacle_List          : Object_List;
   Powerup_List           : Object_List;
   
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
   --     Get_Line(Sockets(I), Player_Colour,           -- Spelarens färgnamn.
   --  	       Player_Colour_Length);               -- Spelarens färgnamnlängd.
      
      
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
   
   for I in 1..Num_Players loop
      Game.Ranking(I) := I;
   end loop;
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
   Waves := (Enemies1, Enemies2, Enemies3, Enemies4);
   Loop_Counter := 1;
   
   
   -- Skickar startbanan till alla klienter 
   for I in 1..Num_Players loop
      for J in World'Range loop
	 for K in X_Led'Range loop
	    Put_line(Sockets(I), Game.Layout(J)(K)); -- Skickar Banan till klienterna
	 end loop;
      end loop;
   end loop;   
   
   
   --Testar att skapa olika typer av väggar
   Create_Object(ObstacleType(1), 2, 20, Light, Obstacle_List);
   Create_Object(ObstacleType(2), 10, 20, Hard , Obstacle_List);
   Create_Object(ObstacleType(3), 25, 20, Light, Obstacle_List);
   
   
   Create_Object(PowerUpType(2), 40, 15, 0, Powerup_List);
   Create_Object(PowerUpType(3), 50, 20, 0, Powerup_List);
   
   
   -----------------------------------
   -- SPAWN FIRST WAVE
   -----------------------------------
   
   Spawn_Wave(8, 1, 1, 1, waves(1));
   
   -----------------------------------
   -- end SPAWN FIRST WAVE
   -----------------------------------
   
   loop 
      

      delay(0.01);      -- En delay så att servern inte fyller socket bufferten till klienterna. / Eric
      
      
      --------------------------------------------------
      --| SCROLLING MAP 
      --| "Level 2" => därför ej nödvändig än
      --------------------------------------------------
      if Game.Settings.Generate_Map then       -- Bestämmer under spelet om banan ska börja genereras eller inte.
	 if Loop_Counter mod 4 = 0 then
	    New_Top_Row(Game.Layout);          -- Genererar två nya väggar längst upp på banan på var sida.
	    Move_Rows_Down(Game.Layout);       -- Flyttar ner hela banan ett steg.
	 end if;
      end if;    

      


      -- Hitbox_Procedure/compare_coordinates_procedure i en for loop för alla skepp/skott    //Andreas
      
      -- Skickar information till klienterna. / Eric
      
      
      for I in 1..Num_Players loop
	 if Game.Players(I).Ship.Health = 0 then
	    Game.Players(I).Playing := False;
	 end if;
	 
	 if Game.Players(I).Playing then
	    Player_Collide_In_Object( Game.Players(I).Ship.XY(1),
				      Game.Players(I).Ship.XY(2),
				      Game.Players(I).Ship, --Uppdaterar ship_spec
				      Shot_List);           --Om spelare träffas
	 end if;                                         --Av skott.

	 
	 Put(Sockets(I), Shot_List);
	 Put(Sockets(I), Obstacle_List);
	 Put(Sockets(I), Powerup_List);
      	 Put_Game_Data(Sockets(I),Game);
      end loop;
      
      Update_Enemy_Position(Waves(1), Shot_List);
           
      -----------------------------------
      -- PUT ENEMY SHIPS
      -----------------------------------
      
      for I in 1..Num_Players loop
	 for J in Waves'Range loop
	    Put_Enemy_ships(Waves(J), Sockets(I));
	 end loop;
      end loop;
      
      -----------------------------------
      -- end PUT ENEMY SHIPS
      -----------------------------------   
      
      Get_Player_Input(Sockets, Num_Players, Game, Shot_List, Obstacle_List, Powerup_List);
      
      --Uppdatera skottens position med delay
      --if Loop_Counter mod 2 = 1 then
      Shot_Movement(Shot_List);
      --end if;
      
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
      

end Server;

--gnatmake $(~TDDD11/TJa-lib/bin/tja_config)
