--  Rule-30 frame rendering via Terminal_UI (no ANSI in frame text).

package Rule_30.Terminal is

   Width           : constant Positive := 50;
   Default_Gens    : constant Positive := 16;
   Max_Gens        : constant Positive := 200;
   Msg_Inner_Width : constant Positive := 48;
   Frame_Width     : constant Positive := 50;
   Status_Lines    : constant Positive := 4;

   subtype Cell_Col is Positive range 1 .. Width;

   type Board is array (Positive range <>, Cell_Col range <>) of Bit;

   --  One complete frame: Board_Rows board lines + Status_Lines status lines.
   --  No ESC / control characters. Every line is exactly Frame_Width chars
   --  plus a trailing ASCII.LF (except we return a single string with LFs).
   function Render_Frame
     (Screen       : Board;
      Gen          : Natural;
      Generations  : Positive;
      Board_Rows   : Positive) return String
   with
     Pre => Screen'First (1) = 1
       and then Screen'Last (1) = Board_Rows
       and then Gen <= Generations
       and then Board_Rows = Generations + 1;

   function Frame_Line_Count (Board_Rows : Positive) return Positive is
     (Board_Rows + Status_Lines);

   --  True if S contains ESC (animation control leak into a "clean" frame).
   function Contains_ESC (S : String) return Boolean;

   --  Count LF-terminated lines (tolerates missing final LF).
   function Count_Lines (S : String) return Natural;

   function Line_Width_OK (S : String; Expected : Positive) return Boolean;
   --  Every line (except optional empty trailing) has length Expected.

end Rule_30.Terminal;
