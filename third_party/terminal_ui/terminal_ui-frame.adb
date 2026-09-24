with Ada.Strings.Fixed;

package body Terminal_UI.Frame is

   function Pad_Inner (S : String; Inner_Width : Positive) return String is
      T : String (1 .. Inner_Width) := [others => ' '];
      N : constant Natural := Natural'Min (S'Length, Inner_Width);
   begin
      if N > 0 then
         T (1 .. N) := S (S'First .. S'First + N - 1);
      end if;
      return T;
   end Pad_Inner;

   function Border_Line
     (Width : Positive; Fill : Character := '#') return String is
     (Ada.Strings.Fixed."*" (Width, Fill));

   function Msg_Line
     (S           : String;
      Outer_Width : Positive;
      Border      : Character := '#') return String
   is
      Inner : constant Positive := Outer_Width - 2;
   begin
      return Border & Pad_Inner (S, Inner) & Border;
   end Msg_Line;

   function Contains_ESC (S : String) return Boolean is
   begin
      for I in S'Range loop
         if S (I) = ASCII.ESC then
            return True;
         end if;
      end loop;
      return False;
   end Contains_ESC;

   function Count_Lines (S : String) return Natural is
      N : Natural := 0;
   begin
      if S'Length = 0 then
         return 0;
      end if;
      for I in S'Range loop
         if S (I) = ASCII.LF then
            N := N + 1;
         end if;
      end loop;
      if S (S'Last) /= ASCII.LF then
         N := N + 1;
      end if;
      return N;
   end Count_Lines;

   function Line_Width_OK (S : String; Expected : Positive) return Boolean is
      Start : Natural := S'First;
      I     : Natural := S'First;
   begin
      if S'Length = 0 then
         return True;
      end if;
      while I <= S'Last loop
         if S (I) = ASCII.LF then
            if I - Start /= Expected then
               return False;
            end if;
            Start := I + 1;
         end if;
         I := I + 1;
      end loop;
      if Start <= S'Last and then S'Last - Start + 1 /= Expected then
         return False;
      end if;
      return True;
   end Line_Width_OK;

   procedure Append
     (Buf   : in out String;
      Last  : in out Natural;
      Piece : String)
   is
   begin
      Buf (Last + 1 .. Last + Piece'Length) := Piece;
      Last := Last + Piece'Length;
   end Append;

   procedure Append_Line
     (Buf   : in out String;
      Last  : in out Natural;
      Piece : String)
   is
   begin
      Append (Buf, Last, Piece);
      Append (Buf, Last, [1 => ASCII.LF]);
   end Append_Line;

end Terminal_UI.Frame;
