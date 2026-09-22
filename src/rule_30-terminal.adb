with Ada.Strings.Fixed;

package body Rule_30.Terminal is

   function Trim_Nat (N : Natural) return String is
     (Ada.Strings.Fixed.Trim (N'Image, Ada.Strings.Left));

   function Pad_Inner (S : String) return String is
      T : String (1 .. Msg_Inner_Width) := [others => ' '];
      N : constant Natural := Natural'Min (S'Length, Msg_Inner_Width);
   begin
      if N > 0 then
         T (1 .. N) := S (S'First .. S'First + N - 1);
      end if;
      return T;
   end Pad_Inner;

   function Board_Line (Screen : Board; R : Positive) return String is
      Line : String (1 .. Frame_Width) := [others => ' '];
   begin
      for C in Cell_Col loop
         if Screen (R, C) = 1 then
            Line (C) := '#';
         end if;
      end loop;
      return Line;
   end Board_Line;

   function Border_Line return String is
     (Ada.Strings.Fixed."*" (Frame_Width, '#'));

   function Msg_Line (S : String) return String is
     ('#' & Pad_Inner (S) & '#');

   function Render_Frame
     (Screen       : Board;
      Gen          : Natural;
      Generations  : Positive;
      Board_Rows   : Positive) return String
   is
      --  Upper bound: each line Frame_Width + LF
      Max_Len : constant Natural :=
        Frame_Line_Count (Board_Rows) * (Frame_Width + 1);
      Buf     : String (1 .. Max_Len);
      Last    : Natural := 0;

      procedure Append (Piece : String) is
      begin
         Buf (Last + 1 .. Last + Piece'Length) := Piece;
         Last := Last + Piece'Length;
      end Append;

      procedure Append_Line (Piece : String) is
      begin
         Append (Piece);
         Append ([1 => ASCII.LF]);
      end Append_Line;
   begin
      for R in 1 .. Board_Rows loop
         Append_Line (Board_Line (Screen, R));
      end loop;
      Append_Line (Border_Line);
      Append_Line
        (Msg_Line
           ("CURRENT GEN  " & Trim_Nat (Gen) & " / " & Trim_Nat (Generations)
            & "          RULE  30"));
      Append_Line
        (Msg_Line
           ("BW  play [N] [--once|--live]  N=1.." & Trim_Nat (Max_Gens)
            & "  default=" & Trim_Nat (Default_Gens)));
      Append_Line (Border_Line);
      return Buf (1 .. Last);
   end Render_Frame;

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

end Rule_30.Terminal;
