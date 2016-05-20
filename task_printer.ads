with Print_Handling;      use Print_Handling;
with Definitions;         use Definitions;
with Object_Handling;     use Object_Handling;
with Enemy_ship_handling;     use Enemy_Ship_handling;

package Task_Printer is
   
   
   task Print_All is
      entry Print_Everything(D  : in Game_Data;
			     W  : in Enemy_List_array;
			     P  : in Object_List;
			     A  : in Object_List;
			     O  : in Object_List;
			     S  : in Object_List;
			     N  : in Integer;
			     K  : in Integer;
			     L  : in Integer;
			     LC : in Integer); 
      entry Get_Choice(C : out Character);
      entry Stop;
   end Print_All;
   
   procedure Printer(D  : in Game_Data;
		     W  : in Enemy_List_array;
		     P  : in Object_List;
		     A  : in Object_List;
		     O  : in Object_List;
		     S  : in Object_List;
		     N  : in Integer;
		     K  : in Integer;
		     L  : in Integer;
		     LC : in Integer) renames Print_All.Print_Everything;
   
   procedure Get_From_Printer(C : out Character) renames Print_All.Get_Choice;
   
   procedure Stop_Printer renames Print_All.Stop;
  
   
end Task_Printer;
