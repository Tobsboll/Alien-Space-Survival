with TJa.Window.Text;         use TJa.Window.Text;

package Definitions is
   
   World_X_Length : constant Integer := 62;
   World_Y_Length : constant Integer := 30;
   
   Up              : constant Integer := -1;
   Down            : constant Integer := 1;
   Light           : constant Integer := 1;
   Hard            : constant Integer := 5;
   Unbreakable     : constant Integer := 999;
   
   Move_Horisontal : constant Integer := 2;
   
   type XY_Type is array(1 .. 2) of Integer;
   
    --Types represented by integerz
   type Shot_Array_Type is array (1..10) of Integer;
   ShotType : Shot_Array_Type := (1, 2, 3, 4, 5, 6, 7, 8, 9, 10); 
     
   type Obstacle_Array_Type is array (1..10) of Integer;
   ObstacleType : Obstacle_Array_Type := (11, 12, 13, 14, 15, 16, 17, 18, 19, 20);
   type PowerUp_Array_Type is array (1..10) of Integer;
   PowerUpType : PowerUp_Array_Type := (21, 22, 23, 24, 25, 26, 27, 28, 29, 30);
   
   
   type Ranking_List is array (1 .. 4) of Integer;

   type Shot_Type is array (1 .. 5) of XY_Type;
   
   type Ship_spec is 
      record
  	 XY      : XY_Type; 
  	 Health   : Integer; 
  	 Laser_Type : Integer;
	 Missile_Ammo : Integer;
      end record;
   
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
   
   ---------------------------------------------------
   --| Inställningar
   ---------------------------------------------------
   type Setting_Type is
      record
	 Generate_Map   : Boolean;     -- Generering av banan Activ/Inaktiv
	 Astroid_Active : Boolean;     -- Generering av astroider Activ/Inaktiv
      end record;
   ---------------------------------------------------
   
   ---------------------------------------------------
   --| X,Y Koordinater för alla fönster
   ---------------------------------------------------
   SpelPlanen_X : constant Integer := 1; 
   SpelPlanen_Y : constant Integer := 1;
   
   Highscore_Ruta_X      : constant Integer := SpelPlanen_X+World_X_Length+2;
   Highscore_Ruta_Y      : constant Integer := SpelPlanen_Y;
   Highscore_Ruta_Width  : constant Integer := 30;
   Highscore_Ruta_Height : constant Integer := 2;
   
   Highscore_X : constant Integer := Highscore_Ruta_X+1;
   Highscore_Y : constant Integer := Highscore_Ruta_Y+1;
   ---------------------------------------------------
   
   ---------------------------------------------------
   --| Färginställningarna
   ---------------------------------------------------
   Background_Colour_1  : constant Colour_Type := Black;  -- Terminalen
   Text_Colour_1        : constant Colour_Type := White;  -- Terminalen
   Background_Colour_2  : constant Colour_Type := Black;  -- Scorewindow
   Text_Colour_2        : constant Colour_Type := White;  -- Scorewindow
   ---------------------------------------------------
   
   
end Definitions;
