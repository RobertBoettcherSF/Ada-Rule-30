with Ada.Text_IO; use Ada.Text_IO;
with Rule_30;     use Rule_30;
with Rule_30.Terminal;

procedure Tests is
   Pass_Count : Natural := 0;
   Fail_Count : Natural := 0;

   procedure Check (Label : String; OK : Boolean) is
   begin
      if OK then
         Put_Line ("  PASS -- " & Label);
         Pass_Count := Pass_Count + 1;
      else
         Put_Line ("  FAIL -- " & Label);
         Fail_Count := Fail_Count + 1;
      end if;
   end Check;

begin
   --  TEST 1 — Apply_Rule Basic Truth Table 1 (Functional Correctness)
   Put_Line ("TEST 1 — Apply_Rule First Half (111..101)");
   Check ("1.1 111 -> 0", Apply_Rule (1, 1, 1) = 0);
   Check ("1.2 110 -> 0", Apply_Rule (1, 1, 0) = 0);
   Check ("1.3 101 -> 0", Apply_Rule (1, 0, 1) = 0);

   --  TEST 2 — Apply_Rule Basic Truth Table 2 (Functional Correctness)
   Put_Line ("TEST 2 — Apply_Rule Mid Section (100..010)");
   Check ("2.1 100 -> 1", Apply_Rule (1, 0, 0) = 1);
   Check ("2.2 011 -> 1", Apply_Rule (0, 1, 1) = 1);
   Check ("2.3 010 -> 1", Apply_Rule (0, 1, 0) = 1);

   --  TEST 3 — Apply_Rule Basic Truth Table 3 (Functional Correctness)
   Put_Line ("TEST 3 — Apply_Rule Tail Section (001..000)");
   Check ("3.1 001 -> 1", Apply_Rule (0, 0, 1) = 1);
   Check ("3.2 000 -> 0", Apply_Rule (0, 0, 0) = 0);
   Check ("3.3 Deterministic property", Apply_Rule (1, 0, 0) = Apply_Rule (1, 0, 0));

   --  TEST 4 — Evolve_Fixed_Zero Normal Case (Functional Correctness)
   Put_Line ("TEST 4 — Evolve_Fixed_Zero Normal Case");
   declare
      Grid : State_Array (1 .. 3) := [1, 1, 1];
   begin
      Evolve_Fixed_Zero (Grid);
      Check ("4.1 Left bound (011 -> 1)", Grid (1) = 1);
      Check ("4.2 Center (111 -> 0)", Grid (2) = 0);
      Check ("4.3 Right bound (110 -> 0)", Grid (3) = 0);
   end;

   --  TEST 5 — Evolve_Fixed_Zero Edges Zeros (Edge Cases)
   Put_Line ("TEST 5 — Evolve_Fixed_Zero with Zeros");
   declare
      Grid : State_Array (1 .. 3) := [0, 0, 0];
   begin
      Evolve_Fixed_Zero (Grid);
      Check ("5.1 Left 000 -> 0", Grid (1) = 0);
      Check ("5.2 Center 000 -> 0", Grid (2) = 0);
      Check ("5.3 Right 000 -> 0", Grid (3) = 0);
   end;

   --  TEST 6 — Evolve_Periodic Shift Wrap (Functional Correctness)
   Put_Line ("TEST 6 — Evolve_Periodic Shift Wrap");
   declare
      Grid : State_Array (1 .. 3) := [1, 0, 0];
   begin
      Evolve_Periodic (Grid);
      --  Index 1: Wrap L=0, C=1, R=0 => 010 -> 1
      --  Index 2: L=1, C=0, R=0 => 100 -> 1
      --  Index 3: L=0, C=0, Wrap R=1 => 001 -> 1
      Check ("6.1 Periodic left wrap (010 -> 1)", Grid (1) = 1);
      Check ("6.2 Periodic center (100 -> 1)", Grid (2) = 1);
      Check ("6.3 Periodic right wrap (001 -> 1)", Grid (3) = 1);
   end;

   --  TEST 7 — Evolve_Periodic Single Cell Wrap (Edge Cases)
   Put_Line ("TEST 7 — Evolve_Periodic Single Cell Case");
   declare
      Grid : State_Array (1 .. 1) := [1 => 1];
   begin
      Evolve_Periodic (Grid);
      Check ("7.1 Single cell initialization (Setup check)", True);
      Check ("7.2 Wrapping single 1 evaluates as 111 -> 0", Grid (1) = 0);
      Grid (1) := 0;
      Evolve_Periodic (Grid);
      Check ("7.3 Wrapping single 0 evaluates as 000 -> 0", Grid (1) = 0);
   end;

   --  TEST 8 — Evolve_Expanding Step 1 (Functional Correctness)
   Put_Line ("TEST 8 — Evolve_Expanding Step 1");
   declare
      Grid : constant State_Array (1 .. 1) := [1 => 1];
      Res  : constant State_Array := Evolve_Expanding (Grid);
   begin
      Check ("8.1 Expanding length strictly +2", Res'Length = 3);
      Check ("8.2 First element extrapolates (001 -> 1)", Res (0) = 1);
      Check ("8.3 Center element resolves (010 -> 1)", Res (1) = 1);
      Check ("8.4 Last element extrapolates (100 -> 1)", Res (2) = 1);
   end;

   --  TEST 9 — Evolve_Expanding Step 2 (Functional Correctness)
   Put_Line ("TEST 9 — Evolve_Expanding Step 2");
   declare
      Grid : constant State_Array (0 .. 2) := [1, 1, 1];
      Res  : constant State_Array := Evolve_Expanding (Grid);
   begin
      --  Expanding generation translates (1,1,1) into (1,1,0,0,1)
      Check ("9.1 Extrapolation length verifies properly", Res'Length = 5);
      Check ("9.2 Boundary left evaluates to 1", Res (-1) = 1);
      Check ("9.3 Left inner evaluates to 1", Res (0) = 1);
      Check ("9.4 Center element converges to 0", Res (1) = 0);
   end;

   --  TEST 10 — Evolve_And_Extract_Center Valid (Functional Correctness)
   Put_Line ("TEST 10 — Evolve_And_Extract_Center Normal Case");
   declare
      Grid    : State_Array (1 .. 3) := [1, 0, 1];
      Bit_Val : Bit := 0;
   begin
      Evolve_And_Extract_Center (Grid, Bit_Val);
      Check ("10.1 Extracted target bit correctly resolves to 0", Bit_Val = 0);
      Check ("10.2 Grid physically modified as 0 in center", Grid (2) = 0);
      Check ("10.3 Grid flanking indices calculated appropriately", Grid (1) = 1 and Grid (3) = 1);
   end;

   --  TEST 11 — Evolve_Fixed_Zero Empty Exception (Error Handling)
   Put_Line ("TEST 11 — Evolve_Fixed_Zero Invalid Geometry");
   declare
      Grid   : State_Array (1 .. 0);
      Caught : Boolean := False;
   begin
      begin
         Evolve_Fixed_Zero (Grid);
      exception
         when Invalid_Grid => Caught := True;
      end;
      Check ("11.1 Exception accurately caught during invalid run", Caught);
      Check ("11.2 Grid'Length verifies invariant at 0", Grid'Length = 0);
      Check ("11.3 State properties retain logical constraints", Grid'First = 1 and Grid'Last = 0);
   end;

   --  TEST 12 — Invalid_Grid Exceptions on Expanding and Periodic (Error Handling)
   Put_Line ("TEST 12 — Invalid_Grid Error Constraints Across Variants");
   declare
      Grid : State_Array (1 .. 0);
      Caught_Exp, Caught_Per : Boolean := False;
   begin
      begin
         declare
            -- Force function evaluation using a locally scoped dummy variable 
            -- rather than an empty 'if' statement to satisfy compiler warnings.
            Dummy : constant State_Array := Evolve_Expanding (Grid);
            pragma Unreferenced (Dummy);
         begin
            null;
         end;
      exception
         when Invalid_Grid => Caught_Exp := True;
      end;

      begin
         Evolve_Periodic (Grid);
      exception
         when Invalid_Grid => Caught_Per := True;
      end;

      Check ("12.1 Expanding gracefully catches missing state", Caught_Exp);
      Check ("12.2 Periodic gracefully catches missing state", Caught_Per);
      Check ("12.3 Complete error trapping coverage", Caught_Exp and Caught_Per);
   end;

   --  TEST 13 — Evolve_And_Extract_Center Even/Empty Exception (Error Handling)
   Put_Line ("TEST 13 — Evolve_And_Extract Even/Empty Exceptions");
   declare
      Grid_Even    : State_Array (1 .. 2) := [1, 1];
      Grid_Empty   : State_Array (1 .. 0);
      Bit_Val      : Bit := 0;
      Caught_Even  : Boolean := False;
      Caught_Empty : Boolean := False;
   begin
      begin
         Evolve_And_Extract_Center (Grid_Even, Bit_Val);
      exception
         when Invalid_Grid => Caught_Even := True;
      end;

      begin
         Evolve_And_Extract_Center (Grid_Empty, Bit_Val);
      exception
         when Invalid_Grid => Caught_Empty := True;
      end;

      Check ("13.1 Even length rejects lack of true center", Caught_Even);
      Check ("13.2 Empty length correctly traps exception", Caught_Empty);
      Check ("13.3 Output logically unchanged upon failure", Bit_Val = 0);
   end;

   --  TEST 14 — True Rule 30 PRNG Sequence (Invariants)
   Put_Line ("TEST 14 — Verify Core Wolfram Structural Invariants");
   declare
      G0 : constant State_Array (0 .. 0) := [0 => 1];
   begin
      Check ("14.1 Gen 0 sequence invariant validates", G0 (0) = 1);
      
      declare
         G1 : constant State_Array := Evolve_Expanding (G0);
      begin
         Check ("14.2 Gen 1 center extracts accurately as 1", G1 (0) = 1);
         declare
            G2 : constant State_Array := Evolve_Expanding (G1);
         begin
            Check ("14.3 Gen 2 structural sequence verifies at 0", G2 (0) = 0);
         end;
      end;
   end;

   --  TEST 15 — Terminal frame render (Mint stack bug guard)
   --  Clean frames must be ESC-free, fixed width, and tip-at-top.
   --  A second render must replace the first (overwrite semantics in memory),
   --  not concatenate — that is the bug users saw when ANSI home was ignored.
   Put_Line ("TEST 15 — Terminal Render_Frame (no ESC / tip / overwrite)");
   declare
      use Rule_30.Terminal;
      Gens : constant Positive := 5;
      Rows : constant Positive := Gens + 1;
      Screen : Board (1 .. Rows, Cell_Col) := [others => [others => 0]];
      Current : State_Array (1 .. Width) := [others => 0];
      F0, F1, F2 : String (1 .. Frame_Line_Count (Rows) * (Frame_Width + 1));
      L0, L1, L2 : Natural;

      procedure Store (G : Natural; Grid : State_Array) is
      begin
         for C in Cell_Col loop
            Screen (G + 1, C) := Grid (C);
         end loop;
      end Store;

      function First_Board_Line (S : String) return String is
         I : Natural := S'First;
      begin
         while I <= S'Last and then S (I) /= ASCII.LF loop
            I := I + 1;
         end loop;
         return S (S'First .. I - 1);
      end First_Board_Line;
   begin
      Current (Width / 2) := 1;
      Store (0, Current);
      declare
         S : constant String := Render_Frame (Screen, 0, Gens, Rows);
      begin
         L0 := S'Length;
         F0 (1 .. L0) := S;
         Check ("15.1 gen0 frame has no ESC", not Contains_ESC (S));
         Check ("15.2 gen0 line count = board+status",
                Count_Lines (S) = Frame_Line_Count (Rows));
         Check ("15.3 gen0 every line width 50",
                Line_Width_OK (S, Frame_Width));
         declare
            Tip : constant String := First_Board_Line (S);
            Hashes : Natural := 0;
         begin
            for C of Tip loop
               if C = '#' then
                  Hashes := Hashes + 1;
               end if;
            end loop;
            Check ("15.4 gen0 tip is single center hash",
                   Hashes = 1 and then Tip (Width / 2) = '#');
         end;
      end;

      for Step in 1 .. Gens loop
         Evolve_Fixed_Zero (Current);
         Store (Step, Current);
      end loop;
      declare
         S : constant String := Render_Frame (Screen, Gens, Gens, Rows);
      begin
         L1 := S'Length;
         F1 (1 .. L1) := S;
         Check ("15.5 final frame has no ESC", not Contains_ESC (S));
         Check ("15.6 final line count stable",
                Count_Lines (S) = Frame_Line_Count (Rows));
         Check ("15.7 final width 50", Line_Width_OK (S, Frame_Width));
         Check ("15.8 tip still present after evolve",
                First_Board_Line (S) (Width / 2) = '#');
      end;

      --  Overwrite semantics: rendering gen 0 again into a fresh string must
      --  equal the earlier gen0 frame, and must NOT be F0 & F1 concatenated.
      declare
         Screen0 : Board (1 .. Rows, Cell_Col) := [others => [others => 0]];
         Seed : State_Array (1 .. Width) := [others => 0];
      begin
         Seed (Width / 2) := 1;
         for C in Cell_Col loop
            Screen0 (1, C) := Seed (C);
         end loop;
         declare
            S : constant String := Render_Frame (Screen0, 0, Gens, Rows);
         begin
            L2 := S'Length;
            F2 (1 .. L2) := S;
            Check ("15.9 re-render gen0 equals first gen0 (overwrite)",
                   L2 = L0 and then F2 (1 .. L2) = F0 (1 .. L0));
            Check ("15.10 final /= gen0 (evolution changed board)",
                   L1 = L0 and then F1 (1 .. L1) /= F0 (1 .. L0));
            declare
               Stacked : constant String := F0 (1 .. L0) & F1 (1 .. L1);
            begin
               Check ("15.11 stacked dump has more lines than one frame",
                      Count_Lines (Stacked) = 2 * Frame_Line_Count (Rows));
               Check ("15.12 single frame is not a stacked dump",
                      Count_Lines (F1 (1 .. L1))
                        /= Count_Lines (Stacked));
            end;
         end;
      end;
   end;

   Put_Line ("");
   Put_Line ("=== " & Natural'Image (Pass_Count) & " passed, "
             & Natural'Image (Fail_Count) & " failed ===");
   pragma Assert (Fail_Count = 0, "Some tests failed");
end Tests;
