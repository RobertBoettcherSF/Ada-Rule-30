--  Character grid rendering (no domain-specific cell types).

package Terminal_UI.Grid is

   type Grid is array (Positive range <>, Positive range <>) of Character;

   --  Each row becomes one LF-terminated line of width G'Length (2).
   function Render_Grid (G : Grid) return String
   with Pre => G'Length (1) > 0 and then G'Length (2) > 0;

   --  Grid lines followed by Status (caller-built LF-terminated box lines).
   --  Typical Status width should match G'Length (2).
   function Render_Grid (G : Grid; Status : String) return String
   with Pre => G'Length (1) > 0 and then G'Length (2) > 0;

   --  Two-line status box: top/bottom Border_Line, Messages as Msg_Lines.
   --  Messages is a LF-separated list of inner texts (no borders); empty OK.
   function Make_Status_Box
     (Messages    : String;
      Outer_Width : Positive;
      Border      : Character := '#') return String
   with Pre => Outer_Width >= 2;

end Terminal_UI.Grid;
