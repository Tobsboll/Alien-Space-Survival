with Ada.Text_IO;             use Ada.Text_IO;
with tja.window.Elementary;   use tja.window.Elementary;
with Object_Handling;         use Object_Handling;
with Enemy_ship_handling;     use Enemy_ship_handling;

package Graphics is
   
   --type XY_Type is array(1 .. 2) of Integer;
   
   --Skeppen tar upp en yta på skärmen enligt följande
   Player_Width : constant Integer := 5;
   Player_Height: constant Integer := 2;
   
   type Shot_Array_Graphics_Type is array (1..10) of Character;
   ShotGraphics : Shot_Array_Graphics_Type := ('|', --Normal laser
					       'O', --Laser Upgrade
					       ' ', --Hitech Laser [UNDEFINED]
					       ' ', --[î] --Missile
					       ' ',
					       ' ',
					       ' ',
					       ' ',
					       ' ', 
					       ' ');
   
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
   Obstacle_Light : constant String (1..Obstacle_Width) := "LLL";
   Obstacle_Hard : constant String (1..Obstacle_Width) := "HHH";
   Obstacle_Unbreakable : constant String (1..Obstacle_Width) := "UUU";
   
   type Obstacle_Graphics_Type is array (11..20) of String(1..3);
   Obstacle : Obstacle_Graphics_Type := (Obstacle_Light,
					 Obstacle_Hard, 
					 Obstacle_Unbreakable,
					 "   ",
					 "   ",
					 "   ",
					 "   ",
					 "   ",
					 "   ",
					 "   "
					);
   
   type PowerUp_Graphics_Type is array (21..30) of String(1..3);
   PowerUp : PowerUp_Graphics_Type := ( "(h)", --Health
					"(m)", --Missile Ammo
					"(o)", --Laser upgrade
					"(X)", --Hitech laser
					"( )", --Empty
					"( )",
					"( )",
					"( )",
					"( )",
					"( )"
				      );
   
   --  Ship_Width_Type is array (1..Player_Width) of Character;
   --  Ship_Type is array (1..Player_Height) of Ship_Width_Type;
   --  --Ships is array (1..Num_Different_Ships) of Ship_Type   --Olika skepp i framtiden?
   
   procedure Put_Player (X,Y : in Integer); -- XY_Type ger konflikt med andra program
   procedure Put_Objects ( L : in Object_List);
   procedure Put_Enemies (L : in Enemy_List);
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
