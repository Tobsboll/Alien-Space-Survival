with Ada.Command_Line;        use Ada.Command_Line;
with Ada.Exceptions;          use Ada.Exceptions;
with Ada.Text_IO;             use Ada.Text_IO;
with Ada.Integer_Text_IO;     use Ada.Integer_Text_IO;
with tja.window.Elementary;   use tja.window.Elementary;
with TJa.Sockets;             use TJa.Sockets;
with TJa.Keyboard;            use TJa.Keyboard;
with TJa.Keyboard.Keys;       use TJa.Keyboard.Keys;
with Ada.Strings;             use Ada.Strings;
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
   
   --  type X_Led is array(1 .. World_X_Length) of Character;
   --  type World is array(1 .. World_Y_Length) of X_Led;
   
   type XY_Type is array(1 .. 2) of Integer;
   type Shot_Type is array (1 .. 5) of XY_Type;
   
   type Ship_spec is 
      record
  	 XY      : XY_Type; 
  	 Lives   : Integer; 
  	 S       : Shot_Type;
      end record;
   
   type Enemy_Ship_Spec is
      record
	 XY                 : XY_Type;
	 Lives              : Integer;
	 Shot               : Shot_Type;
	 Movement_Selector  : Integer; -- så att jag kan hålla koll på vad varje skepp har för rörelsemönster
	                               --, då kan vi ha olika typer av fiender på skärmen samtidigt.
	 Direction_Selector : Integer; -- kanske inte behövs, men håller i nuläget koll på om skeppet är på väg
	                               -- åt höger eller vänster.
	 Active             : Boolean;
      end record;
   
   
   type Player_Type is
      record
  	 Playing    : Boolean;
  	 Name       : String(1..24);
  	 NameLength : Integer;
  	 Ship       : Ship_Spec;
  	 Score      : Integer;
      end record;
   
   type Player_Array is array (1..4) of Player_Type;
   
   type Enemies is array (1 .. 50) of Enemy_Ship_Spec;
   
   type Game_Data is
      record
  	 Layout   : Bana.World;        -- Banan är i packetet så att både klienten och servern 
	                               -- hanterar samma datatyp / Eric
  	 Players   : Player_Array;     -- Underlättade informationsöverföringen mellan klient och server.
  	 Wave     : Enemies;
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
      begin
	 
	 Get(Socket,Ship.XY(1));
	 Get(Socket,Ship.XY(2));
	 Get(Socket,Ship.Lives);
	 
	 for I in Shot_Type'Range loop
	    Get(Socket,Ship.S(I)(1));
	    Get(Socket,Ship.S(I)(2));
	 end loop;
	 
      end Get_Ship_Data;
      -------------------------------------------------
      
      Player_Playing : Integer;
      Enemies_Active : Integer;
      
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
	 if Player_Playing = 1 then
	    Data.Players(I).Playing := True;
	    
	    
	    -- Tar emot spelarens namn och namnlängd.
	    Get_line(Socket,Data.Players(I).Name, Data.Players(I).NameLength );
	    
	    
	    -- Tar emot spelarens skeppdata
	    Get_Ship_Data(Socket,Data.Players(I).Ship);
	    
	    
	    -- Tar emot spelarens poäng
	    Get(Socket,Data.Players(I).Score);
	    
	    
	    -- Tar inte emot mer data om inte spelaren spelar.
	 elsif Player_Playing = 0 then
	    Data.Players(I).Playing := False;
	 end if;
    
      end loop;	 
      
      -- Tar emot Fiende vågen.
      for I in Enemies'Range loop
	 Get(Socket,Enemies_Active);
	 if Enemies_Active = 1 then
	    
	    Data.Wave(I).Active := True;
	    
	    Get(Socket,Data.Wave(I).XY(1));
	    Get(Socket,Data.Wave(I).XY(2));
	    
	    Get(Socket,Data.Wave(I).Lives);    -- Kanske inte behövs skicka/ta emot
	    
	    
	    for J in Shot_Type'Range loop
	       Get(Socket,Data.Wave(I).Shot(J)(1));
	       Get(Socket,Data.Wave(I).Shot(J)(2));
	    end loop;
	    
	    Get(Socket, Data.Wave(I).Movement_Selector);    -- Kanske inte behövs skicka/ta emot
	    Get(Socket, Data.Wave(I).Direction_Selector);    -- Kanske inte behövs skicka/ta emot
	    
	    
	    -- Tar inte emot mer data om Fienden inte är aktiv.
	 elsif Enemies_Active = 0 then
	    Data.Wave(I).Active := False;
	 end if;
      end loop;

      
      
   end Get_Game_Data;
   ---------------------------------------------------------------
   
   
   --------------------------------------------------
   procedure Get_Input(Keyboard_Input : out Key_type) is
      
      Input : Boolean;
      
   begin
      
      Set_Buffer_Mode(Off);
    --  Set_Echo_Mode(Off);
      
      Input := True;
      
      while Input loop
	 
	 Get_Immediate(Keyboard_Input, Input);
	 
	 if Is_Up_Arrow(Keyboard_input) 
	   or Is_Down_Arrow(Keyboard_input) 
	   or Is_Left_Arrow(Keyboard_input) 
	   or Is_Right_Arrow(Keyboard_input) 
	  or Is_Character(Keyboard_input)-- and
      	 --  To_Character(Keyboard_input) = ' ') 
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
   
   
   
   --Socket_type används för att kunna kommunicera med en server
   Socket : Socket_Type;

   Val      : Character; --Används för att ta emot text från användaren
   NumPlayers : Integer;
   Textlangd : Natural;        --Kommer innehålla längden på denna text
   Resultat  : Natural;        --Resultatet från servern
   Keyboard_Input : Key_Type;
   -- Input          : Boolean;
   Esc     : constant Key_Code_Type := 27;
   Data         : Game_Data;    -- Innehåller all spelinformation som tas emot från servern.
   Loop_Counter : Integer;      -- Innehåller Serverns loopar (Kanske kan kontrollera syncningen lite mer)
   

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
   


    

      
   Get(Socket, NumPlayers);
 -- Skip_Line;
  Skip_Line;
   
   --------------------------------------------------
   --Game loop.
  --------------------------------------------------
  
  
   loop
      Get(Socket,Loop_Counter);    -- tar emot serverns loop_counter
      Clear_Window;
      -- Hämtar all data från servern
      Get_Game_Data(Socket,Data);
      
      Put_World(Data.Layout,1,1);  -- put world // Eric
      -- put Ships // Andreas
      
    Get_Input(Keyboard_input);
    
    if Is_Esc(Keyboard_Input) then-- måste ändras
       
       Put("Exiting...");
       Put_Line(Socket, 'e');
       exit;
    end if;
    
--    Send_Input(Keyboard_Input, Socket);    -- Funkade inte o köra scriptet / Eric
    
    delay(0.01); -- senare bra om vi gör så att server och
                 -- klient synkar exakt!
    
   end loop;
   
   
   --Innan programmet avslutar stängs socketen, detta genererar ett exception
   --hos servern, pss kommer denna klient få ett exception när servern avslutas
   Close(Socket);



end Klient;
