--  Terminal Rule 30 (BW top-seed spacetime).
--  Default: live animation via Terminal_UI.Clear_Screen each frame.
--  --once: one clean final frame (no clear).

pragma Ada_2022;

with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Command_Line;  use Ada.Command_Line;
with Rule_30;           use Rule_30;
with Rule_30.Terminal;  use Rule_30.Terminal;
with Terminal_UI;

procedure Play is
   Live      : Boolean := True;  -- default: animate
   Show_Help : Boolean := False;
   Gens_Arg  : Natural := 0;

   procedure Parse_Args is
   begin
      for I in 1 .. Argument_Count loop
         declare
            A : constant String := Argument (I);
            N : Integer;
         begin
            if A = "--live" or else A = "-l" then
               Live := True;
            elsif A = "--once" or else A = "-o" then
               Live := False;
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
                     Put_Line ("usage: play [generations] [--live|--once]");
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
      Put_Line ("usage: play [generations] [--live|--once]");
      Put_Line ("  generations  1 .." & Max_Gens'Image
                & "  (default" & Default_Gens'Image & ")");
      Put_Line ("  (default)    --live at" & Default_Gens'Image & " gens (clear each frame)");
      Put_Line ("  --live       animate (default)");
      Put_Line ("  --once       single final frame, no clear (no animation)");
      Put_Line ("make play / make play GEN=40 / make once");
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

      procedure Draw_Live is
         S : constant String :=
           Render_Frame (Screen, Gen, Generations, Board_Rows);
      begin
         Terminal_UI.Clear_Screen;
         Terminal_UI.Put_Frame (S);
      end Draw_Live;
   begin
      Current (Width / 2) := 1;
      Gen := 0;
      Store_Gen (0, Current);

      if Live then
         Draw_Live;
         Terminal_UI.Pause_Seconds (0.12);
         for Step in 1 .. Generations loop
            Evolve_Fixed_Zero (Current);
            Gen := Step;
            Store_Gen (Step, Current);
            Draw_Live;
            Terminal_UI.Pause_Seconds (0.12);
         end loop;
         New_Line;
         Put_Line ("done —" & Generations'Image
                   & " generations (live via clear).");
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
            Terminal_UI.Put_Frame (S);
         end;
         Put_Line ("done —" & Generations'Image
                   & " generations (--once single frame).");
      end if;
   end;
end Play;
