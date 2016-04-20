with Ada.Command_Line;        use Ada.Command_Line;
with Ada.Exceptions;          use Ada.Exceptions;
with Ada.Text_IO;             use Ada.Text_IO;
with Ada.Integer_Text_IO;     use Ada.Integer_Text_IO;
with TJa.Window.Text;         use TJa.Window.Text;
with TJa.Window.Graphic;      use TJa.Window.Graphic;
with tja.window.Elementary;   use tja.window.Elementary;
with TJa.Sockets;             use TJa.Sockets;
with TJa.Keyboard;            use TJa.Keyboard;
with TJa.Keyboard.Keys;       use TJa.Keyboard.Keys;
with Ada.Strings;             use Ada.Strings;
with Ada.Characters.Latin_1;  use Ada.Characters.Latin_1;    -- Används för att använda Escape till att inakvtivera 
							     -- textensynligheten i terminalen
with Space_Map;


procedure Klient is
   
   
   -------------------------------------------------------------
   
   World_X_Length : constant Integer := 62;
   World_Y_Length : constant Integer := 30;
   
   -- Packet som hanterar banan.
   package Bana is
      new Space_map(X_Width => World_X_Length,
		    Y_Height => World_Y_Length);
   use Bana;
   
   --------------------------------------------------------------
   -- | Game Datan
   --------------------------------------------------------------
   type XY_Type is array(1 .. 2) of Integer;
   type Ranking_List is array (1 .. 4) of Integer;
   
   ------------------------------------------------
   --| Nya skott typen
   ------------------------------------------------
   type Shot_Type is
      record
	 XY     : XY_Type;
	 Active : Boolean;
      end record;
   
   type Shot_array is array (1 .. 5) of Shot_Type;
   ------------------------------------------------
   
   
   ------------------------------------------------
   --| Skepp Specifikationerna
   ------------------------------------------------
   type Ship_spec is 
      record
  	 XY      : XY_Type; 
  	 Health  : Integer; 
  	 Shot    : Shot_Array;
      end record;
   ------------------------------------------------
   
   
   
   ------------------------------------------------
   --| Spelarnas Specifikationerna
   ------------------------------------------------
   type Player_Type is
      record
  	 Playing    : Boolean;
  	 Name       : String(1..24);
  	 NameLength : Integer;
  	 Ship       : Ship_Spec;
	 Colour     : Colour_Type;
  	 Score      : Integer;
      end record;
   
   type Player_Array is array (1..4) of Player_Type;
   ------------------------------------------------
   
   
   
   ------------------------------------------------
   -- | Gamla enemies information.
   ------------------------------------------------
   type Enemy_Ship_Spec is
      record
   	 XY                 : XY_Type;
   	 Lives              : Integer;
   	 Shot               : Shot_Array;
   	 Shot_Difficulty    : Integer;
   	 Movement_Selector  : Integer; -- så att jag kan hålla koll på vad varje skepp har för rörelsemönster
   	                               --, då kan vi ha olika typer av fiender på skärmen samtidigt.
   	 Direction_Selector : Integer; -- kanske inte behövs, men håller i nuläget koll på om skeppet är på väg
   	                               -- åt höger eller vänster.
   	 Active             : Boolean;  
      end record;
   
   type Enemies is array (1 .. 50) of Enemy_Ship_Spec;
   ------------------------------------------------
   
   
   
   
   
   ------------------------------------------------
   -- | Nya enemies information.
   ------------------------------------------------
   --  type Enemy_Ship_Spec is
   --     record
   --  	 Active             : Boolean;
   --  	 XY                 : XY_Type;
   --  	 Health             : Integer;
   --  	 Shot               : Shot_Array;
   --     end record;
   
   --  type Enemies_Array is array (1 .. 50) of Enemy_Ship_Spec;   
   
   --  type Wave_Type is
   --     record
   --  	 Active             : Boolean;
   --  	 Enemies            : Enemies_Array;
   --  	 Difficult          : Integer;
   --  	 Movement_Selector  : Integer;     --  så att jag kan hålla koll på vad varje skepp har för rörelsemönster
   --  					   -- , då kan vi ha olika typer av fiender på skärmen samtidigt.
   --  	 Direction_Selector : Integer;      -- kanske inte behövs, men håller i nuläget koll på om skeppet är på väg
   --     end record;
   ------------------------------------------------
      
   
   type Game_Data is
      record
  	 Layout   : Bana.World;        -- Banan är i packetet så att både klienten och servern 
	                               -- hanterar samma datatyp / Eric
  	 Players  : Player_Array;      -- Underlättade informationsöverföringen mellan klient och server.
  	 Wave     : Enemies;
	 --Wave     : Wave_Type;         -- Nya Fiende våg.
	 Ranking  : Ranking_List;   -- Vem som har mest poäng
      end record; 
   -------------------------------------------------------------
   
   
   -- Tar emot datan som skickas från servern till klienten   
   --------------------------------------------------------------
   procedure Get_Game_Data(Socket : Socket_Type;
			   Data : out Game_Data) is
      
      
      -- Tar emot spelarens skeppdata    
      -------------------------------------------------
      procedure Get_Ship_Data(Socket : in Socket_Type;
			      Ship   : out Ship_Spec) is
	 
	 Shot_Active : Integer;	 
	 
      begin
	 
	 Get(Socket,Ship.XY(1));
	 Get(Socket,Ship.XY(2));
	 Get(Socket,Ship.Health);
	 
	 for I in Shot_Array'Range loop
	    Get(Socket, Shot_Active);
	    
	    if Shot_Active = 1 then
	       
	       Ship.Shot(I).Active := True;
	       
	       Get(Socket,Ship.Shot(I).XY(1));
	       Get(Socket,Ship.Shot(I).XY(2));
	    elsif Shot_Active = 0 Then
	       Ship.Shot(I).Active := False;
	    end if;
	 end loop;
	 
      end Get_Ship_Data;
      -------------------------------------------------
      
      Player_Playing    : Integer;
      Enemies_Active    : Integer;
      Wave_Active       : Integer;    -- För nya vågendatan
      Enemy_Active      : Integer;    -- För nya vågendatan
      Enemy_Shot_Active : Integer;    -- För nya vågendatan
      
   begin
      -- Tar emot Banan.
      for I in World'Range loop
	 for J in X_Led'Range loop
	    Get(Socket, Data.Layout(I)(J));
	 end loop;
      end loop;
      
      
      -- Tar emot spelarnas Information
      for I in Player_Array'Range loop
	 -- Tar emot om spelaren spelar.
	 Get(Socket,Player_Playing);
	 if Player_Playing = 1 then         -- Spelaren spelar och måste uppdateras
	    Data.Players(I).Playing := True;
	    
	    
	    -- Tar emot spelarens namn och namnlängd.
	    --Get_line(Socket,Data.Players(I).Name, Data.Players(I).NameLength ); -- Behöver bara skicka en gång (Ingen uppdatering)
	    
	    
	    -- Tar emot spelarens skeppdata
	    Get_Ship_Data(Socket,Data.Players(I).Ship);
	    
	    
	    -- Tar emot spelarens poäng
	    Get(Socket,Data.Players(I).Score);
	    
	    
	    -- Tar inte emot mer data om inte spelaren spelar.
	 elsif Player_Playing = 0 then
	    Data.Players(I).Playing := False;
	 end if;
	 
      end loop;	 
      
      ----------------------------------------------------------
      -- Tar emot Fiende vågen                             GAMLA
      ----------------------------------------------------------
      for I in Enemies'Range loop
      	 Get(Socket, Enemies_Active);
      	 if Enemies_Active = 1 then
	    
      	    Data.Wave(I).Active := True;
	    
      	    Get(Socket, Data.Wave(I).XY(1));
      	    Get(Socket, Data.Wave(I).XY(2));
	    
      	    Get(Socket, Data.Wave(I).Lives);    -- Kanske inte behövs skicka/ta emot
	    
	    
      	    for J in Shot_Array'Range loop
      	       Get(Socket, Data.Wave(I).Shot(J).XY(1));
      	       Get(Socket, Data.Wave(I).Shot(J).XY(2));
      	    end loop;
	    
      	    Get(Socket, Data.Wave(I).Movement_Selector);    -- Kanske inte behövs skicka/ta emot
      	    Get(Socket, Data.Wave(I).Direction_Selector);    -- Kanske inte behövs skicka/ta emot
	    
	    
      	    -- Tar inte emot mer data om Fienden inte är aktiv.
      	 elsif Enemies_Active = 0 then
      	    Data.Wave(I).Active := False;
      	 end if;
      end loop;
      
      
      ----------------------------------------------------------
      -- Tar emot Fiende vågen                               NYA
      ----------------------------------------------------------
      --  Get(Socket, Wave_Active);
      --  if Wave_Active = 1 then	                    -- Fiendevågen är aktiv och måste uppdateras

      --  	 Data.Wave.Active := True;
	 
      --  	 ---------------------------
      --  	 -- Hämtar Fienderna
      --  	 ----------------------------
      --  	 for I in Enemies_Array'Range loop
      --  	    Get(Socket, Enemy_Active);
      --  	    if Enemy_Active = 1 then	                       -- Fienden är aktiv i vågen.
      --  	       Data.Wave.Enemies(I).Active := True;
	       
      --  	       Get(Socket,Data.Wave.Enemies(I).XY(1));         -- Fiendens X-Koordinat
      --  	       Get(Socket,Data.Wave.Enemies(I).XY(2));         -- Fiendens Y-Koordinat
	       
      --  	       for J in Shot_Array'Range loop                  -- Fiendens skott
		  
      --  		  Get(Socket, Enemy_Shot_Active);
		  
      --  		  if Enemy_Shot_Active = 1 then                -- Skottet är aktiv
		     
      --  		     Data.Wave.Enemies(I).Shot(J).Active := True;
		     
      --  		     Get(Socket, Data.Wave.Enemies(I).Shot(J).XY(1));
      --  		     Get(Socket, Data.Wave.Enemies(I).Shot(J).XY(2));
		     
      --  		  elsif Enemy_Shot_Active = 0 then             -- Skottet är inaktiv
      --  		     Data.Wave.Enemies(I).Shot(J).Active := False;
      --  		  end if;
		     
      --  	       end loop; 
	       
      --  	    elsif Enemy_Active = 0 then
	       
      --  	       Data.Wave.Enemies(I).Active := False;	       -- Fienden är inaktiv
      --  	    end if;
      --  	 end loop;
      --  elsif Wave_Active = 0 then
      --  	 Data.Wave.Active := False;	                       -- Vågen är inaktiv.
      --  end if;
      
      for I in Ranking_List'Range loop
	 Get(Socket, Data.Ranking(I));
      end loop;
      
   end Get_Game_Data;
   ---------------------------------------------------------------
   
   
   --------------------------------------------------
   procedure Get_Input(Keyboard_Input : out Key_type) is
      
      Input : Boolean;
      
   begin
      

      
      Input := True;
      
      while Input loop
	 
	 Get_Immediate(Keyboard_Input, Input);
	 
	 if (Is_Character(Keyboard_Input) and then To_Character(Keyboard_Input)=' ')
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
   --------------------------------------------------
   procedure Send_Input(Keyboard_Input : in Key_Type;
		        Socket         : in Socket_type) is
      
   begin
      
      if Is_Up_Arrow(Keyboard_input) then Put_Line(Socket, 'w'); 
      elsif Is_Down_Arrow(Keyboard_input) then Put_Line(Socket, 's');
      elsif Is_Left_Arrow(Keyboard_input) then Put_Line(Socket, 'a');
      elsif Is_Right_Arrow(Keyboard_input) then Put_Line(Socket, 'd');
      elsif Is_Character(Keyboard_input) then Put_Line(Socket, ' '); 
      
      else Put_Line(Socket, 'o'); -- betyder "ingen input" för servern.
      end if;
      
   exception
      when Ada.Strings.INDEX_ERROR => null;
	 
	 
   end Send_Input;
   
   --------------------------------------------------
   
   procedure Put_Player_Ships (Data : in  Game_Data;
			       NumPlayers : in Integer;
			       X          : in Integer;    -- La till X koordinaterna för att ha samma variabel som till put_World och alla andra fönster
			       Y          : in Integer     -- samma anledning som ovan
			      ) is
     
      Old_Background  : Colour_Type;
      Old_Text_Colour : Colour_Type; 
      
   begin
      Old_Text_Colour := Get_Foreground_Colour;           -- Sparar den tidigare textfärgen
      Old_Background  := Get_Background_Colour;           -- Sparar den tidigare bakgrundsfärgen
      
      for I in 1..NumPlayers loop
	 if Data.Players(I).Playing then
	    Set_Colours(Data.Players(I).Colour, Old_Background);               -- Ställer in spelarens färg.
	    Goto_XY(Data.Players(I).Ship.XY(1)+X, Data.Players(I).Ship.XY(2)+Y);
	    Put("-/\-");                         -- Uppgraderas till en Put_Ship senare
	 end if;
	 
      end loop;
      
      Set_Colours(Old_Text_Colour, Old_Background);       -- Ställer tillbaka till dom tidigare färgerna.
      
   end Put_Player_Ships;
   
   procedure Put_Box(X           : in Integer;        -- X Koordinat där den ska börja boxen
		     Y           : in Integer;        -- Y Koordinat där den ska börja boxen
		     Width       : in Integer;        -- Hur bred boxen ska vara.
		     Height      : in Integer;        -- Hur hög boxen ska vara.
		     Background  : in Colour_Type;    -- Bakgrundfärgen
		     Text_Colour : in Colour_Type) is -- Boxens färg
      
      Old_Background  : Colour_Type;
      Old_Text_Colour : Colour_Type;
      
      
   begin
      Old_Text_Colour := Get_Foreground_Colour;           -- Sparar den tidigare textfärgen
      Old_Background  := Get_Background_Colour;           -- Sparar den tidigare bakgrundsfärgen
      
      Set_Colours(Text_Colour, Background);               -- Ställer in dom inmatade färgerna.
      
--      Set_Graphical_Mode(On);                             -- Startar grafiken.
      
      Goto_XY(X,Y);
      Put(Upper_Left_Corner);
      Put(Horisontal_Line,Width);
      Put(Upper_Right_Corner);

      for I in 1 .. Height loop
	 Goto_XY(X,Y+I);
	 Put("│");
	 Goto_XY(X+Width+1,Y+I);
	 Put("│");
      end loop;
      
      Goto_XY(X,Y+Height);
      Put(Lower_Left_Corner);
      Put(Horisontal_Line,Width);
      Put(Lower_Right_Corner);
      
      Set_Graphical_Mode(Off);                            -- Stänger av grafiken
      
      Set_Colours(Old_Text_Colour, Old_Background);       -- Ställer tillbaka till dom tidigare färgerna.
      
   end Put_Box;
   
   ----------------------------------------------------------------------------------------------------
   --|
   --| DECLARATIONS
   --|
   ----------------------------------------------------------------------------------------------------
   
   Socket         : Socket_Type;    -- Socket_type används för att kunna kommunicera med en server
   Val            : Character;      -- Används för att ta emot text från användaren
   NumPlayers     : Integer;        -- Antal Spelare
   Textlangd      : Natural;        -- Kommer innehålla längden på denna text
   Resultat       : Natural;        -- Resultatet från servern
   Data           : Game_Data;      -- Innehåller all spelinformation som tas emot från servern.
   Loop_Counter   : Integer;        -- Innehåller Serverns loopar (Kanske kan kontrollera syncningen lite mer)
   Keyboard_Input : Key_Type;       -- Spelarens knapptryckning
   Esc            : constant Key_Code_Type := 27;
   Escape         : Character renames Ada.Characters.Latin_1.ESC;  -- Används för att använda Escape till att inakvtivera 
							           -- textensynligheten i terminalen
   Background_Colour_1  : Colour_Type := Black;  -- Bakgrundsfärg till (Scoreboard, Hela Terminalen)
   Text_Colour_1        : Colour_Type := White;  -- Teckenfärg    till (Scoreboard, Hela Terminalen)
   Klient_Number        : Integer;               -- Servern skickar klientnumret
   Player_Colour        : String(1..15);         -- Används i början till att överföra spelarnas färger
   Player_Colour_Length : Integer;               -- Används för att hålla koll hur lång färgnamnet är
   
   
   
   ---------------------------------------------------
   -- X,Y Koordinater för alla fönster
   ---------------------------------------------------
   SpelPlanen_X : Integer := 2; 
   SpelPlanen_Y : Integer := 1;
   
   Highscore_Ruta_X      : Integer := SpelPlanen_X+World_X_Length+1;
   Highscore_Ruta_Y      : Integer := SpelPlanen_Y;
   Highscore_Ruta_Width  : Integer := 30;
   Highscore_Ruta_Height : Integer := 6;
   ---------------------------------------------------
   
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

   -- Initierar en socket, detta krävs för att kunna ansluta denna till
   -- servern.
   Initiate(Socket);
   
   Set_Colours(Text_Colour_1, Background_Colour_1);  -- Ändrar färgen på terminalen
   Clear_Window;
   
   Put("Join eller Create, J eller C: ");

   
   loop	 
      Get(Val);
      if Val = 'J' then
	 Put("Waiting for connection...");
	 Connect(Socket, Argument(1), Positive'Value(Argument(2)));
	 Put("You are connected!");
	 exit;
      elsif Val = 'C' then
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
   Get(Socket, Klient_Number);             -- Spelarens Klient nummer
   --------------------------------------
   --------------------------------------
   
   Skip_Line(Socket);                      -- Ligger ett entertecken kvar i socketen.
   
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
   --------------------------------------
   -------------------------------------- 
   
   
   
   ----------------------------------------------------------------------------------------------------
   --|
   --| Game loop
   --|
   ----------------------------------------------------------------------------------------------------
   Set_Buffer_Mode(Off);
   Set_Echo_Mode(Off);
   Cursor_Invisible;
   loop
      --Get(Socket,Loop_Counter);    -- tar emot serverns loop_counter
      
      
      -- Hämtar all data från servern
      Get_Game_Data(Socket,Data);
      Clear_Window;
--      Put (Escape & "[m");                         -- Aktiverar Textsynligheten i Terminalen.
      -- Skriv era puts efter denna rad -------
      
      --------------------------------
      --| Skriver ut banan
      --------------------------------
      Put_World(Data.Layout, Spelplanen_X+1, Spelplanen_Y, Background_Colour_1, Text_Colour_1, false);              -- put world // Eric
      Put_Box(Spelplanen_X, SpelPlanen_Y, World_X_Length-2, 
	      World_Y_Length, Background_Colour_1, Text_Colour_1);            -- En låda runt spelplanen / Eric
      --------------------------------
      
      Put_Player_Ships(Data, NumPlayers, Spelplanen_X, Spelplanen_Y);         -- put Ships // Andreas
      -- Put_Enemies();                                                       -- Tobias
      
      --------------------------------
      -- Highscore fönster
      --------------------------------
      Put_Box(Highscore_Ruta_X, Highscore_Ruta_Y, Highscore_Ruta_Width, 
   	      Highscore_Ruta_Height, Background_Colour_1, Text_Colour_1);     -- / Eric
            
      Goto_XY(Highscore_Ruta_X+1,Highscore_Ruta_Y+1);
      Put("  Nickname       Lives   Score");                                  -- Kan vara i Put_Score senare / Eric
      
      -- Sort_Score(Data.Players, List);                                      -- Sorterar vem som leder / Eric
      -- Put_Score(List,Highscore_Ruta_X+1,Highscore_Ruta_Y+2);               -- Skriver ut den sorterade scorelistan / Eric
        
      Goto_XY(Highscore_Ruta_X+1,Highscore_Ruta_Y+2);                         -- Ett exempel på hur jag tänkt ska se ut
      Put("1.Andreas        ♡♡♡       152");  
      Goto_XY(Highscore_Ruta_X+1,Highscore_Ruta_Y+3);
      Put("2.Tobias         ♡♡         94");  
      Goto_XY(Highscore_Ruta_X+1,Highscore_Ruta_Y+4);
      Put("3.Eric           ♡          26");  
      Goto_XY(Highscore_Ruta_X+1,Highscore_Ruta_Y+5);
      Put("4.Kalle          RIP         2");  
      --------------------------------
      
      --------------------------------
      -- Där man skriver för att chatta
      --------------------------------
      Put_Box(SpelPlanen_X, SpelPlanen_Y+World_Y_Length+1,                    -- Ett litet fönster för att skriva i. / Eric 
	      World_X_Length-2, 2, Background_Colour_1, Text_Colour_1); 
      Goto_XY(SpelPlanen_X+1,SpelPlanen_Y+World_Y_Length+2);
      Put("Här skriver man.");
      --------------------------------
      
      
      -- Inga mer puts efter denna rad -------
--      Put (Escape & "[8m");                        -- Inaktiverar Textsynligheten i Terminalen.
      Get_Input(Keyboard_input);
      
      if Is_Esc(Keyboard_Input) then-- måste ändras
	 
	 Put("Exiting...");
	 Put_Line(Socket, 'e');
	 exit;
      end if;
      
      Send_Input(Keyboard_Input, Socket);    -- Funkade inte o köra scriptet / Eric
      
      --delay(0.01); -- senare bra om vi gör så att server och
      -- klient synkar exakt!
      
   end loop;
   Set_Echo_Mode(On);
   Set_Buffer_Mode(On);

   
   --Innan programmet avslutar stängs socketen, detta genererar ett exception
   --hos servern, pss kommer denna klient få ett exception när servern avslutas
   Close(Socket);
   Cursor_visible;



end Klient;
