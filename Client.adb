with Ada.Command_Line;    use Ada.Command_Line;
with Ada.Exceptions;      use Ada.Exceptions;
with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with TJa.Sockets;         use TJa.Sockets;
with TJa.Keyboard;        use TJa.Keyboard;
with TJa.Keyboard.Keys;   use TJa.Keyboard.Keys;

procedure Klient is
   
   
   --------------------------------------------------
   procedure Get_Input(Keyboard_Input : out Key_type) is
      
      Input : Boolean;
      
   begin
      
      Set_Buffer_Mode(Off);
      
      Input := True;
      
      while Input loop
	 
	 Get_Immediate(Keyboard_Input, Input);
	 
	 if Is_Up_Arrow(Keyboard_input) or Is_Down_Arrow(Keyboard_input) or Is_Left_Arrow(Keyboard_input) or Is_Right_Arrow(Keyboard_input) or (Is_Character(Keyboard_input) and To_Character(Keyboard_Input) = ' ') or Is_Esc(Keyboard_input)  then 
	    exit;
	 end if; -- gör att den endast går vidare i koden efter giltig input
      end loop;
      
   end Get_Input;
   --------------------------------------------------
   procedure Send_Input(Keyboard_Input : in Key_Type;
		        Socket         : in Socket_type) is
      
   begin
      
      if Is_Up_Arrow(Keyboard_input) then Put_Line(Socket, 'w'); 
      elsif Is_Down_Arrow(Keyboard_input) then Put_Line(Socket, 's');
      elsif Is_Left_Arrow(Keyboard_input) then Put_Line(Socket, 'a');
      elsif Is_Right_Arrow(Keyboard_input) then Put_Line(Socket, 'd');
      elsif Is_Character(Keyboard_input) then Put_Line(Socket, ' '); -- nu är det så att vi skjuter på alla bokstavsknappar!!	
      else Put_Line(Socket, 'O'); -- betyder "ingen input" för servern.
      end if;
      
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
      
   Put("Vi kom förbi geten");
   
   --------------------------------------------------
   --Game loop.
   
   loop
         
    Get_Input(Keyboard_input);
    
    if To_Key_Code_type(Keyboard_Input) = Key_Esc then-- måste ändras
       
       Put("Exiting...");
       Put_Line(Socket, 'e');
       exit;
    end if;
    
    Send_Input(Keyboard_Input, Socket);
    
    delay(0.01);
    
   end loop;
   
   
   --Innan programmet avslutar stängs socketen, detta genererar ett exception
   --hos servern, pss kommer denna klient få ett exception när servern avslutas
   Close(Socket);



end Klient;
