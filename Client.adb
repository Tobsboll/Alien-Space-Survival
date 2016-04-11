with Ada.Command_Line;    use Ada.Command_Line;
with Ada.Exceptions;      use Ada.Exceptions;
with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with TJa.Sockets;         use TJa.Sockets;

procedure Klient is
   
   --Socket_type används för att kunna kommunicera med en server
   Socket : Socket_Type;

   Val      : Character; --Används för att ta emot text från användaren
   NumPlayers : Integer;
   Textlangd : Natural;        --Kommer innehålla längden på denna text
   Resultat  : Natural;        --Resultatet från servern


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
   Skip_Line;
   Skip_Line;
      
 
   
   --Innan programmet avslutar stängs socketen, detta genererar ett exception
   --hos servern, pss kommer denna klient få ett exception när servern avslutas
   Close(Socket);



end Klient;
