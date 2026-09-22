--  Terminal Rule 30: classic top-seed spacetime (BW), # message box, 50 gens.
--  No color, no scale/slider — tip of the triangle stays at the top.

pragma Ada_2022;

with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Calendar;
with Ada.Strings.Fixed;
with Rule_30;           use Rule_30;

procedure Play is
   Width           : constant Positive := 50;
   Generations     : constant Positive := 50;  -- matches CURRENT GEN n/50
   --  One board row per generation so the tip (gen 0) never scrolls away.
   Board_Rows      : constant Positive := Generations + 1;  -- gens 0 .. 50
   Msg_Inner_Width : constant Positive := 48;
   Frame_Width     : constant Positive := 50;

   subtype Col is Positive range 1 .. Width;
   subtype Row is Positive range 1 .. Board_Rows;

   type Board is array (Row, Col) of Bit;

   Screen  : Board := [others => [others => 0]];
   Current : State_Array (1 .. Width) := [others => 0];
   Gen     : Natural := 0;  -- last filled generation index (0-based)

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

   procedure Store_Gen (G : Natural; Grid : State_Array) is
      R : constant Row := Row (G + 1);
   begin
      for C in Col loop
         Screen (R, C) := Grid (C);
      end loop;
   end Store_Gen;

   procedure Draw is
   begin
      Put (ASCII.ESC & "[H" & ASCII.ESC & "[2J");
      --  BW spacetime: row 1 = gen 0 (tip), later gens grow downward.
      for R in Row loop
         for C in Col loop
            if Screen (R, C) = 1 then
               Put ('#');
            else
               Put (' ');
            end if;
         end loop;
         New_Line;
      end loop;
      Put_Border_Row;
      --  Status like the reference UI, but text-only (no scale/slider).
      Put_Msg_Line
        ("CURRENT GEN  " & Trim_Nat (Gen) & " / " & Trim_Nat (Generations)
         & "          RULE  30");
      Put_Msg_Line ("BW  fixed-zero edges  center seed  make play");
      Put_Border_Row;
      Flush;
   end Draw;

   procedure Pause_Brief is
      use Ada.Calendar;
      T0 : constant Time := Clock;
   begin
      while Clock - T0 < 0.05 loop
         null;
      end loop;
   end Pause_Brief;

begin
   Current (Width / 2) := 1;
   Gen := 0;
   Store_Gen (0, Current);
   Draw;
   Pause_Brief;

   for Step in 1 .. Generations loop
      Evolve_Fixed_Zero (Current);
      Gen := Step;
      Store_Gen (Step, Current);
      Draw;
      Pause_Brief;
   end loop;
end Play;
