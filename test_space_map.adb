with Space_Map;
with Ada.Text_IO; use Ada.Text_IO;
with tja.window.Elementary;             use tja.window.Elementary;

procedure Test_Space_map is
   
   X : Integer := 120;
   Y : Integer := 30;
   
   package Bana is
      new Space_map(X_Width => X,
		Y_Height => Y);
   use Bana;
   
   Map : World;
   Stones : Astroid_Type;
   Count : Integer := 0;
   Astroid_Nummer : Integer;
   
begin
   Cursor_Invisible; -- Gör så att Markören blir onsynlig.
   
   
   -- Genererar en helt ny bana med raka kanter
   ----------------------------------------------
   Generate(Map);
   loop
      -- Räknar antal loopar som används tillsammans med andra koder nedanför
      -------------------------------------------------------------------------
      Count := Count +1;
      delay(0.1);
      Clear_Window;
      
      -- Flyttar ner astroiderna en Y koordinat
      ------------------------------------------
      Move_Astroid(Stones);
      
      
      -- Skriver ut allt, Banan och astroiderna
      -----------------------------------------------
      Put_World(Map,1,1);
      Put_Astroid(Stones,1,1);
      
      -- Genererar och flyttar ner banan en Y koordinat så att det ser ut
      -- att astroiderna faller mycket snabbare.
      ------------------------------------------------
      if Count mod 4 = 0 then
	 New_Top_Row(Map);
	 Move_Rows_Down(Map);
      end if;
      
      
      
      -- Genererar en större astroid vad 5e loop
      -----------------------------------------
      if Count mod 5 = 0 then
	 Gen_Astroid(Map,Stones,10,2);
      end if;
      
      -- Genererar en mindre astroid
      ----------------------------------------
      Gen_Astroid(Map,Stones,10,1);
      
      
      -- Testar Remove_Astroid med X,Y koordinater
      --------------------------------------------
      Goto_XY(50,20);
      Put("X");
      Remove_Astroid (Stones,50,20);
      
      
      -- Testar Is_Astroid_There
      --        Get_Astroid_Nr
      --        Remove_Astroid
      -----------------------------
      Goto_XY(55,20);
      Put("O");
      if Is_Astroid_There(Stones,55,20) then
	 Get_Astroid_Nr(Stones,55,20,Astroid_Nummer);
	 Remove_Astroid (Stones,Astroid_Nummer);
      end if;
      
      
   end loop;      
   Cursor_Visible;
end Test_Space_map;
