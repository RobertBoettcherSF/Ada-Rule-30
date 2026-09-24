--  Clean frame string helpers (no ANSI). Fixed-width pads, borders, checks.

package Terminal_UI.Frame is

   --  Left-align S into exactly Inner_Width spaces (truncated if longer).
   function Pad_Inner (S : String; Inner_Width : Positive) return String;

   --  Width copies of Fill.
   function Border_Line
     (Width : Positive; Fill : Character := '#') return String;

   --  '#' & Pad_Inner(S, Outer_Width-2) & '#'  (Outer_Width includes borders).
   function Msg_Line
     (S           : String;
      Outer_Width : Positive;
      Border      : Character := '#') return String
   with Pre => Outer_Width >= 2;

   function Contains_ESC (S : String) return Boolean;

   --  Count LF-terminated lines (tolerates missing final LF).
   function Count_Lines (S : String) return Natural;

   --  Every line (except optional empty trailing) has length Expected.
   function Line_Width_OK (S : String; Expected : Positive) return Boolean;

   --  Append helpers for building multi-line frames in a fixed buffer.
   procedure Append
     (Buf  : in out String;
      Last : in out Natural;
      Piece : String)
   with Pre => Last + Piece'Length <= Buf'Last;

   procedure Append_Line
     (Buf  : in out String;
      Last : in out Natural;
      Piece : String)
   with Pre => Last + Piece'Length + 1 <= Buf'Last;

end Terminal_UI.Frame;
