--  Terminal Rule 30: BW top-seed spacetime + # message box.
--  Redraw: home cursor, paint the whole frame with spaces, then draw
--  (works on Linux Mint terminals that ignore or mishandle ESC[2J).

pragma Ada_2022;

with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Command_Line;     use Ada.Command_Line;
with Ada.Calendar;
with Ada.Strings.Fixed;
with Rule_30;              use Rule_30;

procedure Play is
   Width           : constant Positive := 50;
   Default_Gens    : constant Positive := 50;
   Max_Gens        : constant Positive := 200;
   Msg_Inner_Width : constant Positive := 48;
   Frame_Width     : constant Positive := 50;
   --  Board rows + 1 border + 2 msg + 1 border
   Status_Lines    : constant Positive := 4;

   subtype Col is Positive range 1 .. Width;

   function Trim_Nat (N : Natural) return String is
     (Ada.Strings.Fixed.Trim (N'Image, Ada.Strings.Left));

   function Parse_Generations return Positive is
      N : Integer;
   begin
      if Argument_Count < 1 then
         return Default_Gens;
      end if;
      begin
         N := Integer'Value (Argument (1));
      exception
         when others =>
            Put_Line ("usage: play [generations]   (1 .."
                      & Max_Gens'Image & ", default"
                      & Default_Gens'Image & ")");
            raise;
      end;
      if N < 1 then
         return 1;
      elsif N > Max_Gens then
         return Max_Gens;
      else
         return Positive (N);
      end if;
   end Parse_Generations;

   Generations : constant Positive := Parse_Generations;
   Board_Rows  : constant Positive := Generations + 1;
   Frame_Lines : constant Positive := Board_Rows + Status_Lines;

   type Board is array (Positive range <>, Col range <>) of Bit;

   Screen  : Board (1 .. Board_Rows, Col) := [others => [others => 0]];
   Current : State_Array (1 .. Width) := [others => 0];
   Gen     : Natural := 0;

   Blank_Line : constant String (1 .. Frame_Width) := [others => ' '];

   function Pad_Inner (S : String) return String is
      T : String (1 .. Msg_Inner_Width) := [others => ' '];
      N : constant Natural := Natural'Min (S'Length, Msg_Inner_Width);
   begin
      if N > 0 then
         T (1 .. N) := S (S'First .. S'First + N - 1);
      end if;
      return T;
   end Pad_Inner;

   procedure Cursor_Home is
   begin
      Put (ASCII.ESC & "[H");
   end Cursor_Home;

   procedure Wipe_Frame is
   begin
      --  Overwrite the previous frame with spaces so leftover glyphs vanish
      --  even when the terminal does not honor clear-screen (Mint/CJK etc.).
      Cursor_Home;
      for I in 1 .. Frame_Lines loop
         Put (Blank_Line);
         New_Line;
      end loop;
      Cursor_Home;
   end Wipe_Frame;

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
      R : constant Positive := G + 1;
   begin
      for C in Col loop
         Screen (R, C) := Grid (C);
      end loop;
   end Store_Gen;

   procedure Draw is
   begin
      Wipe_Frame;
      for R in 1 .. Board_Rows loop
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
      Put_Msg_Line
        ("CURRENT GEN  " & Trim_Nat (Gen) & " / " & Trim_Nat (Generations)
         & "          RULE  30");
      Put_Msg_Line
        ("BW  play [N]  N=1.." & Trim_Nat (Max_Gens)
         & "  default=" & Trim_Nat (Default_Gens));
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
   --  Hide cursor for cleaner animation; show again on exit.
   Put (ASCII.ESC & "[?25l");
   Flush;

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

   Put (ASCII.ESC & "[?25h");
   New_Line;
   Put_Line ("done — " & Trim_Nat (Generations) & " generations.");
exception
   when others =>
      Put (ASCII.ESC & "[?25h");
      raise;
end Play;
