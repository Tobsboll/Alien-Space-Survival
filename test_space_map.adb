with Space_Map;
with tja.window.Elementary;             use tja.window.Elementary;

procedure Test_Space_map is
   
   X : Integer := 120;
   Y : Integer := 60;
   
   package Bana is
      new Space_map(X_Width => X,
		Y_Height => Y);
   use Bana;
   
   Map : World;
   
begin
   
   Generate(Map);
   loop
      Clear_Window;
      Put_World(Map);
      delay(0.3);
      New_Top_Row(Map);
      Move_Rows_Down(Map);
   end loop;      
end Test_Space_map;
