with Definitions;       use Definitions;

package Menu_Options is
   
   procedure Choose_Nickname_Window;
   
   procedure Menu_Start(Option : in Integer;
			X      : in Integer;
			Y      : in Integer);
   
   procedure Menu_Multiplayer(Option : in Integer;
			      X      : in Integer;
			      Y      : in Integer);
   
   procedure Multiplayer_Create(Option : in Integer;
				X      : in Integer;
				Y      : in Integer);
   
end Menu_Options;
