with TJa.Window.Text;         use TJa.Window.Text;
with TJa.Window.Graphic;      use TJa.Window.Graphic;
with tja.window.Elementary;   use tja.window.Elementary;


package Box_Hantering is
   
   procedure Put_Box(X           : in Integer;        -- X Koordinat där den ska börja boxen
		     Y           : in Integer;        -- Y Koordinat där den ska börja boxen
		     Width       : in Integer;        -- Hur bred boxen ska vara.
		     Height      : in Integer;        -- Hur hög boxen ska vara.
		     Background  : in Colour_Type;    -- Bakgrundfärgen
		     Text_Colour : in Colour_Type);   -- Boxens färg
   
   procedure Put_Double_Line_Box(X           : in Integer;        -- X Koordinat där den ska börja boxen
				 Y           : in Integer;        -- Y Koordinat där den ska börja boxen
				 Width       : in Integer;        -- Hur bred boxen ska vara.
				 Height      : in Integer;        -- Hur hög boxen ska vara.
				 Background  : in Colour_Type;    -- Bakgrundfärgen
				 Text_Colour : in Colour_Type);   -- Boxens färg
   
   procedure Put_Block_Box(X           : in Integer;        -- X Koordinat där den ska börja boxen
			   Y           : in Integer;        -- Y Koordinat där den ska börja boxen
			   Width       : in Integer;        -- Hur bred boxen ska vara.
			   Height      : in Integer;        -- Hur hög boxen ska vara.
			   Background  : in Colour_Type;    -- Bakgrundfärgen
			   Text_Colour : in Colour_Type);   -- Boxens färg

   
end Box_Hantering;
