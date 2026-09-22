--  Terminal Rule 30 (BW top-seed spacetime).
--  Default: one clean final frame (no ANSI) — Mint-safe.
--  --live: clear(1) before each frame, then print a clean Render_Frame.
--  ANSI ESC clear/home is unreliable on some Linux Mint terminals.

pragma Ada_2022;

with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Command_Line;  use Ada.Command_Line;
with Ada.Calendar;
with Interfaces.C; use Interfaces.C;
with Rule_30;           use Rule_30;
with Rule_30.Terminal;  use Rule_30.Terminal;

procedure Play is
   Live      : Boolean := False;
   Show_Help : Boolean := False;
   Gens_Arg  : Natural := 0;

   function C_System (Command : Interfaces.C.Char_Array) return Interfaces.C.int
     with Import, Convention => C, External_Name => "system";

   procedure Clear_Terminal is
      RC : Interfaces.C.int;
   begin
      --  Prefer the real clear(1); ESC[2J is ignored on some Mint TTYs.
      RC := C_System (Interfaces.C.To_C ("clear 2>/dev/null"));
      if RC /= 0 then
         --  Last-ditch ANSI; still may be a no-op on broken TTYs.
         Put (ASCII.ESC & "[2J" & ASCII.ESC & "[H");
         Flush;
      end if;
   end Clear_Terminal;

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
               Show_Help := True;
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
                     Put_Line ("usage: play [generations] [--live]");
                     raise;
               end;
            end if;
         end;
      end loop;
   end Parse_Args;

   Generations : Positive;
   Board_Rows  : Positive;
begin
   Parse_Args;
   if Show_Help then
      Put_Line ("usage: play [generations] [--live]");
      Put_Line ("  generations  1 .." & Max_Gens'Image
                & "  (default" & Default_Gens'Image & ")");
      Put_Line ("  (default)    print one final frame (Mint-safe)");
      Put_Line ("  --live       animate: run clear(1) before each frame");
      Put_Line ("make live / make live GEN=40 / make play LIVE=1");
      return;
   end if;

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
         while Clock - T0 < 0.12 loop
            null;
         end loop;
      end Pause_Brief;

      procedure Draw_Live is
         S : constant String :=
           Render_Frame (Screen, Gen, Generations, Board_Rows);
      begin
         Clear_Terminal;
         Put_Frame (S);
      end Draw_Live;
   begin
      Current (Width / 2) := 1;
      Gen := 0;
      Store_Gen (0, Current);

      if Live then
         Draw_Live;
         Pause_Brief;
         for Step in 1 .. Generations loop
            Evolve_Fixed_Zero (Current);
            Gen := Step;
            Store_Gen (Step, Current);
            Draw_Live;
            Pause_Brief;
         end loop;
         New_Line;
         Put_Line ("done —" & Generations'Image
                   & " generations (--live via clear).");
      else
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
                   & " generations (single frame; make live to animate).");
      end if;
   end;
end Play;
