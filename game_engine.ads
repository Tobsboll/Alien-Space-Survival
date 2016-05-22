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
with Map_Handling;           use Map_Handling;    --
with TJa.Sockets;            use TJa.Sockets;     --
with Ada.Text_IO;            use Ada.Text_IO;     --
with TJa.Keyboard;           use TJa.Keyboard;    --
with Graphics;               use Graphics;        --
with Ada.Numerics.Discrete_Random;                --
						  ----------------------------------------------------

package Game_Engine is
   
   subtype One_To_ten is Integer range 1..10;
   package Powerup_random is
      new Ada.Numerics.Discrete_Random(Result_Subtype => One_To_Ten);
   use Powerup_Random;
   
   Gen       : Generator;

   --Procedure Set_Default_Values fastställer alla startvärden som behövs innan
   --spelet börjar
   procedure Set_Default_Values (Num_Players    : in Integer;
				 Game           : in out Game_Data;
				 Loop_Counter   : out Integer;
				 Players_Choice : out Players_Choice_Array;
				 Level          : out Integer;
				 Level_Cleared  : out Boolean;
				 New_Level      : out Boolean;
				 Wall_List      : in out Object_List
				);
   
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
   
   --Overlapping_X returnerar true om två intervall i x-led har samma värde
   function Overlapping_X (X1, X2 : in Integer;
			   X1_Width, X2_Width : in Integer;
			   X1_Offset : in Integer := 0) return Boolean;
   
   --Overlapping_Y returnerar true om två intervall i y-led har samma värde
   function Overlapping_Y (Y1, Y2 : in Integer;
			   Y1_Length, Y2_Length : in Integer;
			   Y1_Offset : in Integer := 0) return Boolean;
   
   --Overlapping_XY är en kombination av ovanstående och returnerar därför
   --true om två fyrkanter överlappar varandra
   function Overlapping_XY  (XY1, XY2 : in XY_Type;
			     X1_Width, Y1_Length, X2_Width, Y2_Length : in Integer;
			     X1_Offset : in Integer :=0;
			     Y1_Offset : in Integer := 0
			    ) return Boolean;
   
   --Ship_Overlapping är en funktion som ovan fast utformad för skeppets unika
   --form
   function Ship_Overlapping (X1,Y1, X2,Y2, X2_Width,Y2_Length: in Integer
			     ) return Boolean;
   
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
					Player      : in out Player_Type;
					L           : in out Object_List;
					Player_To_Revive    : out Integer
				      );
   
   function Shot_Collide (Shot, obj : in Object_List) return boolean;
   procedure A_Shot_Collide_In_Object (Shot, Obj2 : in out Object_List;
				       Game        : in out Game_Data;
				       Powerup_List : in out Object_List
				      );
   procedure Shots_Collide_In_Objects (Obj1, Obj2 : in out Object_List;
				       Game        : in out Game_Data;
				       Powerup_List : in out Object_List
				      );
   
   --BETA:
   --Players_Are_Dead ska returnera true om ALLA spelare är döda
   --Detta för att kunna avbryta spelet när alla har dött...
   function Players_Are_Dead ( Player : in Player_Array) return Boolean;
   
   --
   procedure Create_Wall ( L : in out Object_List;
			   Xpos, Ypos : in Integer);
   
   --------------------------------------------------
   -- TILLÄGG FRÅN TOBIAS:
   -- två funktioner som hanterar väntetid mellan händelser
   -- set_waiting_time räknar ut et slutligt värde på loop_counter,
   -- Waiting kollar om loop_counter har det värdet.
   
   function Set_Waiting_Time(Loop_Counter, Rounds_To_Wait : in Integer) return Integer;
   function Waiting(Loop_Counter, When_Done : in Integer) return Boolean;
   --------------------------------------------------
   
   --Update_Player_Recharge uppdaterar bara en integer i ship_spec för ett skepp
   --eftersom man kan bara skjuta om den är lika med noll.
   procedure Update_Player_Recharge (Player : in out Player_Type);
   
   --Som det låter:
   procedure Kill_Player (Player : in out Player_Type;
			  Player_Number : in Integer;
			  Explosion_List : in out Object_List;
			  PowerUp_List   : in out Object_List);
   
   procedure Revive_Player(PlayerNumber : in Integer;
			   Player       : in out Player_Array);
   
   procedure Spawn_Powerup(X, Y         : in Integer;
			   Powerup_List : in out Object_List);
   
   procedure Create_Explosion_Big (L : in out Object_List;
				   X, Y : in Integer);
   
   procedure Create_Explosion_Medium (L : in out Object_List;
				      X, Y : in Integer);
   procedure Create_Explosion_Small (L : in out Object_List;
				     X , Y  : in Integer);
   procedure Create_Ricochet (L             : in out Object_List;
			      X , Y         : in Integer);
   procedure Create_Nitro_Explosion (L : in out Object_List;
				     X, Y    : in Integer);
   procedure Create_Hitech_Explosion ( L     : in out Object_List;
				       X , Y : in Integer);
   procedure Create_Nuke (L : in out Object_List;
			  X, Y : in Integer);
   
   procedure Detonate (L : in out Object_List;
		       Expl : in out Object_List;
		       XOffset : in Integer := 0;
		       YOffset : in Integer := 0);
   
   procedure Activate_Thrusters (L : in out Object_List;
				 X, Y : in Integer);
   procedure Create_Side_Thrust ( L          : in out Object_List;
				  X , Y      : in Integer);
end Game_Engine;
