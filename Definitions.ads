
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
   
   
end Definitions;
