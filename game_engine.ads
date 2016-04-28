------------------------------------------------------------
--|
--| GAME ENGINE
--|
--| Här finns kod som utgör spelets maskineri. Dvs funktioner 
--| och procerurer som hanterar HUR spelet ska fortgå utefter
--| dess regler..
--|
--| Innehåll:
--|
--|
--|
--|
--|
--|
--|
--|


----------------------------------------------------
--| PAKET
----------------------------------------------------
with Object_Handling;        use Object_Handling; --
with Definitions;            use Definitions;     --
with Space_Map;              use Space_Map;       --
with TJa.Sockets;            use TJa.Sockets;     --
with Ada.Text_IO;            use Ada.Text_IO;     --
with TJa.Keyboard;           use TJa.Keyboard;    --
with Graphics;               use Graphics;        --
----------------------------------------------------

package Game_Engine is
   --Procedure Set_Default_Values fastställer alla startvärden som behövs innan
   --spelet börjar
   procedure Set_Default_Values (Num_Players : in Integer;
				 Game        : in out Game_Data);
   
   --Shot_Movement uppdaterar skottens position på banan i rätt riktning.
   --Riktningen anges som attribut till Object_Type när man skapar ett skott
   --med Create_Object från object_handling
   procedure Shot_Movement ( L : in out Object_List );
   
   --Get_Player_Input gör flera saker i naturlig ordning men är begränsad i vissa 
   --avseenden
   --För det första tar den in keyboard input från spelande deltagare,
   --sedan avgör den vilken tangent det var som togs emot:
   --1. Om detta var en tangent som kan flytta spelaren så måste även kravet att spelaren
   --inte kolliderar med ett hinder i samma riktning uppfyllas. Sedan kan man inte heller
   --förflytta sig utanför spelplanen. Spelaren flyttas.
   --2. Om detta var en tangent som skjuter så skapas ett skott på skeppets koordinater
   --Till sist tillkallas en annan procedur för att se om man har plockat upp någon 
   --uppgradering från spelplanen. Detta görs dock även om man ej har förflyttat sig och
   --alltså bara skjutit, för att slippa upprepning av kod.
   procedure Get_Player_Input(Sockets : in Socket_Array;
			      Num_Players : in Integer;
			      Data : in out Game_Data;
			      Shot_List : in out Object_List;
			      Obstacle_List : in Object_List;
			      Powerup_List  : in out Object_List
			     );
   
   -- Funktionen player_collide retunerar en boolean beroende på om spelarens grafiska
   -- koordinater krockar med andra objekts grafiska koordinater.
   -- Varje jämförelse är därför unik.
   --Tex skott, hinder, power-ups, fiender...
   function Player_Collide (X,Y : in Integer;
			    L   : in Object_List
			   ) return Boolean;

   --Player_Collide_In_Object hanterar vad som ska hända när spelaren kommer i kontakt
   --med olika objekt på spelplanen. (allt är specialfall)
   --Varje typ av objekt ger unika konsekvenser
   procedure Player_Collide_In_Object ( X,Y         : in Integer;
					Player_Ship : in out Ship_Spec;
					L           : in out Object_List);
   
   function Shot_Collide (Shot, obj : in Object_List) return boolean;
   procedure A_Shot_Collide_In_Object (Shot, Obj2 : in out Object_List);
   procedure Shots_Collide_In_Objects (Obj1, Obj2 : in out Object_List);
   
   --BETA:
   --Players_Are_Dead ska returnera true om ALLA spelare är döda
   --Detta för att kunna avbryta spelet när alla har dött...
   function Players_Are_Dead ( Player : in Player_Array) return Boolean;
   
   --
   procedure Create_Wall ( L : in out Object_List;
			     Ypos : in Integer);
   
end Game_Engine;
