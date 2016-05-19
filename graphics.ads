with Ada.Text_IO;             use Ada.Text_IO;
with tja.window.Elementary;   use tja.window.Elementary;
with Object_Handling;         use Object_Handling;
with Enemy_ship_handling;     use Enemy_ship_handling;
with Definitions;             use Definitions;
with Tja.Window.Text;         use Tja.Window.Text; --Finns i definitions men funkar inte utan detta?? 

package Graphics is
   
   --type XY_Type is array(1 .. 2) of Integer;
   
   --Skeppen tar upp en yta på skärmen enligt följande
   Player_Width : constant Integer := 5;
   Player_Height: constant Integer := 2;
   
   type Shot_Array_Graphics_Type is array (1..15) of Character;
   ShotGraphics : Shot_Array_Graphics_Type := ('|', --1.  Normal laser
					       'O', --2.  Laser Upgrade
					       ' ', --3.  Hitech Laser [UNDEFINED]
					       ' ', --4.  [î] --Missile
					       ' ', --5.  Explosion
					       ' ', --6.  Diagonal Laser
					       ' ', --7.  Nitro_Shot
					       ' ', --8.  Astroid
					       ' ', --9.  Vänster vägg
					       ' ',--10. Höger vägg
					       ' ',--11. Ricochet
					       ' ',--12
					       ' ',--13
					       ' ',--14
					       ' ');--15
   
   --  Player ship-prototypes
   --
   --   _|_
   --  /_._\
   --
   --   /"\    3
   --  <_._>   5
   --
   Ship_Top    : constant String (1..Player_Width) :=  " /'\ ";
   Ship_Bottom : constant String (1..Player_Width) :=  "<_:_>";
   --
   --
   --
   --
   --
   --
   Obstacle_Width : constant Integer := 3;
   Obstacle_Radius : constant Integer := 1;
   --  Obstacle_Light : constant String (1..Obstacle_Width) := "LLL";
   --  Obstacle_Hard : constant String (1..Obstacle_Width) := "HHH";
   --  Obstacle_Unbreakable : constant String (1..Obstacle_Width) := "UUU";
   
   type Obstacle_Graphics_Type is array (16..18) of Colour_Type;
   Obstacle : Obstacle_Graphics_Type := (Obstacle_Light_Colour,
					  Obstacle_Hard_Colour, 
					  Obstacle_Unbreakable_Colour
					    --"   ",
					 --"   " --2st lediga
			        
					 );
   
   type PowerUp_Graphics_Type is array (21..30) of String(1..3);
   PowerUp : PowerUp_Graphics_Type := ( "(h)", --Health
					"(m)", --Missile Ammo
					"(o)", --Laser upgrade
					"(X)", --Hitech laser
					"(3)", --Tri-Laser
					"(V)", --Diagonal-laser
					"(N)", --Nitro-shot
					"(M)", --Super Missile
					"<|>", --Revive Friend
					"( )"
				      );
   
   ---
   type Ship_Parts is array (1..2) of String(1..3); --skeppets topp och botten
   Enemy_1 : Ship_Parts := ("|'|",
			    "\V/");
   
   type Enemy_Graphics_Type is array(31..40) of Ship_Parts;
   Enemy : Enemy_Graphics_Type; --:= (Enemy_1,
				   --  Enemy_1,
				   --  Enemy_1,
				   --  Enemy_1,
				   --  Enemy_1,
				   --  Enemy_1,
				   --  Enemy_1,
				   --  Enemy_1,
				   --  Enemy_1,
				   --  Enemy_1);
			      
   ---
     
   --  Ship_Width_Type is array (1..Player_Width) of Character;
   --  Ship_Type is array (1..Player_Height) of Ship_Width_Type;
   --  --Ships is array (1..Num_Different_Ships) of Ship_Type   --Olika skepp i framtiden?
   
   procedure Put_Player (X,Y : in Integer); -- XY_Type ger konflikt med andra program
   procedure Put_Objects ( L : in Object_List);
   --procedure Put_Enemies (L : in Enemy_List);
   --
   --
   --  |*_*|
   --  |'|'|
   --      
   --       
   --      
   --
   --
   --
   --
   --
   --
   --
   
   
   
   
end Graphics;
