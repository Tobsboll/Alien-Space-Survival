with Map_Handling;        use Map_Handling;
with Definitions;         use Definitions;
with Enemy_ship_handling; use Enemy_Ship_handling;
with Object_Handling;     use Object_Handling;
with Game_Engine;         use Game_Engine;
with TJa.Sockets;         use TJa.Sockets;
with Player_Handling;      use Player_Handling;

package Task_Server_Communication is
   
   task Send_Data_To_Player is
      entry Send_Data(Socket        : in Socket_Type;
		      Astroid_List  : in Object_List;
		      Shot_List     : in Object_List;
		      Obstacle_List : in Object_List;
		      Powerup_List  : in Object_List;
		      Game          : in Game_Data;
		      Waves         : in Enemy_List_Array);		      
   end Send_Data_To_Player;
   
   procedure Put_Data(Socket        : in Socket_Type;
		      Astroid_List  : in Object_List;
		      Shot_List     : in Object_List;
		      Obstacle_List : in Object_List;
		      Powerup_List  : in Object_List;
		      Game          : in Game_Data;
		      Waves         : in Enemy_List_Array) renames Send_Data_To_Player.Send_Data;
   
end Task_Server_Communication;
