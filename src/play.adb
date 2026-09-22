--  Terminal Rule 30 (BW top-seed spacetime).
--  Default: compute all gens, print ONE clean frame (no ANSI) — fixes Mint
--  terminals that ignore ESC[H]/ESC[2J and otherwise stack scrolled frames.
--  Optional: play [N] --live  for ANSI in-place animation when the TTY honors it.

pragma Ada_2022;

with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Command_Line;  use Ada.Command_Line;
with Ada.Calendar;
with Rule_30;           use Rule_30;
with Rule_30.Terminal;  use Rule_30.Terminal;

procedure Play is
   Live : Boolean := False;
   Gens_Arg : Natural := 0;

   procedure Parse_Args is
   begin
      for I in 1 .. Argument_Count loop
         declare
            A : constant String := Argument (I);
            N : Integer;
         begin
            if A = "--live" or else A = "-l" then
               Live := True;
            elsif A = "--help" or else A = "-h" then
               Put_Line ("usage: play [generations] [--live]");
               Put_Line ("  generations  1 .." & Max_Gens'Image
                         & "  (default" & Default_Gens'Image & ")");
               Put_Line ("  --live       ANSI in-place animation (needs a TTY");
               Put_Line ("               that honors cursor home / clear)");
               Put_Line ("  default      print one final frame only (Mint-safe)");
               raise Program_Error;
            else
               begin
                  N := Integer'Value (A);
                  if N < 1 then
                     Gens_Arg := 1;
                  elsif N > Max_Gens then
                     Gens_Arg := Max_Gens;
                  else
                     Gens_Arg := Natural (N);
                  end if;
               exception
                  when Constraint_Error =>
                     Put_Line ("unknown argument: " & A);
                     raise;
               end;
            end if;
         end;
      end loop;
   end Parse_Args;

   Generations : Positive;
   Board_Rows  : Positive;
begin
   begin
      Parse_Args;
   exception
      when Program_Error =>
         return;  -- --help
   end;

   if Gens_Arg = 0 then
      Generations := Default_Gens;
   else
      Generations := Positive (Gens_Arg);
   end if;
   Board_Rows := Generations + 1;

   declare
      Screen  : Board (1 .. Board_Rows, Cell_Col) := [others => [others => 0]];
      Current : State_Array (1 .. Width) := [others => 0];
      Gen     : Natural := 0;

      procedure Store_Gen (G : Natural; Grid : State_Array) is
         R : constant Positive := G + 1;
      begin
         for C in Cell_Col loop
            Screen (R, C) := Grid (C);
         end loop;
      end Store_Gen;

      procedure Put_Frame (S : String) is
      begin
         Put (S);
         Flush;
      end Put_Frame;

      procedure Pause_Brief is
         use Ada.Calendar;
         T0 : constant Time := Clock;
      begin
         while Clock - T0 < 0.05 loop
            null;
         end loop;
      end Pause_Brief;

      procedure Draw_Live is
         S : constant String :=
           Render_Frame (Screen, Gen, Generations, Board_Rows);
      begin
         --  Full clear + home, then clean frame (no ESC inside S).
         Put (ASCII.ESC & "[2J" & ASCII.ESC & "[H");
         Put_Frame (S);
      end Draw_Live;
   begin
      Current (Width / 2) := 1;
      Gen := 0;
      Store_Gen (0, Current);

      if Live then
         Put (ASCII.ESC & "[?25l");
         Flush;
         Draw_Live;
         Pause_Brief;
         for Step in 1 .. Generations loop
            Evolve_Fixed_Zero (Current);
            Gen := Step;
            Store_Gen (Step, Current);
            Draw_Live;
            Pause_Brief;
         end loop;
         Put (ASCII.ESC & "[?25h");
         New_Line;
         Put_Line ("done —" & Generations'Image & " generations (--live).");
      else
         --  Mint-safe path: evolve fully, emit exactly one frame, no ANSI.
         for Step in 1 .. Generations loop
            Evolve_Fixed_Zero (Current);
            Gen := Step;
            Store_Gen (Step, Current);
         end loop;
         declare
            S : constant String :=
              Render_Frame (Screen, Gen, Generations, Board_Rows);
         begin
            if Contains_ESC (S) then
               Put_Line ("internal error: clean frame contains ESC");
               raise Program_Error;
            end if;
            Put_Frame (S);
         end;
         Put_Line ("done —" & Generations'Image
                   & " generations (single frame; use --live to animate).");
      end if;
   end;
end Play;
