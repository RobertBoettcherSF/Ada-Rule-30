--  Terminal Rule 30: 20 visible rows x 50 cells, # message box, 60 gens.

pragma Ada_2022;

with Ada.Text_IO;              use Ada.Text_IO;
with Ada.Calendar;
with Ada.Strings.Fixed;
with Rule_30;                  use Rule_30;

procedure Play is
   Width           : constant Positive := 50;
   Visible_Rows    : constant Positive := 20;
   Generations     : constant Positive := 60;
   Msg_Inner_Width : constant Positive := 48;  -- # + 48 chars + #
   Frame_Width     : constant Positive := 50;  -- outer # border width

   subtype Col is Positive range 1 .. Width;
   subtype Row is Positive range 1 .. Visible_Rows;

   type Board is array (Row, Col) of Bit;
   --  Scroll: row 1 is oldest visible, row Visible_Rows is newest.

   Screen : Board := [others => [others => 0]];
   Current : State_Array (1 .. Width) := [others => 0];
   Gen     : Natural := 0;
   Alive   : Natural;

   function Cell_Char (B : Bit) return Character is
     (if B = 1 then '#' else ' ');

   function Pad_Inner (S : String) return String is
      T : String (1 .. Msg_Inner_Width) := [others => ' '];
      N : constant Natural :=
        Natural'Min (S'Length, Msg_Inner_Width);
   begin
      if N > 0 then
         T (1 .. N) := S (S'First .. S'First + N - 1);
      end if;
      return T;
   end Pad_Inner;

   procedure Put_Border_Row is
   begin
      Put_Line (Ada.Strings.Fixed."*" (Frame_Width, '#'));
   end Put_Border_Row;

   procedure Put_Msg_Line (S : String) is
   begin
      Put ('#');
      Put (Pad_Inner (S));
      Put_Line ("#");
   end Put_Msg_Line;

   procedure Count_Alive (Grid : State_Array; N : out Natural) is
   begin
      N := 0;
      for I in Grid'Range loop
         if Grid (I) = 1 then
            N := N + 1;
         end if;
      end loop;
   end Count_Alive;

   procedure Push_Row (Grid : State_Array) is
   begin
      --  Scroll up one row; newest lands on the bottom.
      for R in 1 .. Visible_Rows - 1 loop
         for C in Col loop
            Screen (R, C) := Screen (R + 1, C);
         end loop;
      end loop;
      for C in Col loop
         Screen (Visible_Rows, C) := Grid (C);
      end loop;
   end Push_Row;

   procedure Draw is
   begin
      --  Home cursor + clear (ANSI); plain terminals still get a full redraw.
      Put (ASCII.ESC & "[H" & ASCII.ESC & "[2J");
      for R in Row loop
         for C in Col loop
            Put (Cell_Char (Screen (R, C)));
         end loop;
         New_Line;
      end loop;
      Put_Border_Row;
      Put_Msg_Line
        ("Rule 30  gen "
         & Ada.Strings.Fixed.Trim (Gen'Image, Ada.Strings.Left)
         & "/"
         & Ada.Strings.Fixed.Trim (Generations'Image, Ada.Strings.Left)
         & "  alive="
         & Ada.Strings.Fixed.Trim (Alive'Image, Ada.Strings.Left)
         & "  width="
         & Ada.Strings.Fixed.Trim (Width'Image, Ada.Strings.Left));
      Put_Msg_Line ("Fixed-zero edges. Live=#  empty=space.");
      Put_Msg_Line ("make play  |  60 gens  |  MIT Ada-Rule-30");
      Put_Border_Row;
      Flush;
   end Draw;

   procedure Pause_Brief is
      use Ada.Calendar;
      T0 : constant Time := Clock;
   begin
      while Clock - T0 < 0.08 loop
         null;
      end loop;
   end Pause_Brief;

begin
   --  Classic single seed in the center.
   Current (Width / 2) := 1;
   Count_Alive (Current, Alive);
   Push_Row (Current);
   Gen := 0;
   Draw;

   for Step in 1 .. Generations loop
      Evolve_Fixed_Zero (Current);
      Gen := Step;
      Count_Alive (Current, Alive);
      Push_Row (Current);
      Draw;
      Pause_Brief;
   end loop;

   Put_Line ("done — " & Generations'Image & " generations.");
end Play;
