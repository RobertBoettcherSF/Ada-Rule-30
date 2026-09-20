package body Rule_30 is

   ----------------------------------------------------------------------
   --  Apply_Rule
   ----------------------------------------------------------------------
   function Apply_Rule (Left, Center, Right : Bit) return Bit is
   begin
      --  Applying the logical reduction of Wolfram's Rule 30 (00011110)
      return Left xor (Center or Right);
   end Apply_Rule;

   ----------------------------------------------------------------------
   --  Evolve_Fixed_Zero
   ----------------------------------------------------------------------
   procedure Evolve_Fixed_Zero (Grid : in out State_Array) is
      --  A frozen copy of the grid is required to ensure synchronous 
      --  updating. Otherwise, previous writes would pollute the read scope.
      Old_Grid : constant State_Array := Grid;
      Left, Center, Right : Bit;
   begin
      if Grid'Length = 0 then
         raise Invalid_Grid;
      end if;

      for I in Grid'Range loop
         --  Resolve left neighbor
         if I = Grid'First then
            Left := 0;
         else
            Left := Old_Grid (I - 1);
         end if;
         
         Center := Old_Grid (I);
         
         --  Resolve right neighbor
         if I = Grid'Last then
            Right := 0;
         else
            Right := Old_Grid (I + 1);
         end if;
         
         Grid (I) := Apply_Rule (Left, Center, Right);
      end loop;
   end Evolve_Fixed_Zero;

   ----------------------------------------------------------------------
   --  Evolve_Periodic
   ----------------------------------------------------------------------
   procedure Evolve_Periodic (Grid : in out State_Array) is
      Old_Grid : constant State_Array := Grid;
      Left, Center, Right : Bit;
   begin
      if Grid'Length = 0 then
         raise Invalid_Grid;
      end if;

      --  If grid consists of exactly one cell, its neighbors are itself.
      if Grid'Length = 1 then
         Left   := Old_Grid (Grid'First);
         Center := Old_Grid (Grid'First);
         Right  := Old_Grid (Grid'First);
         Grid (Grid'First) := Apply_Rule (Left, Center, Right);
         return;
      end if;

      for I in Grid'Range loop
         --  Resolve wrapped left neighbor
         if I = Grid'First then
            Left := Old_Grid (Grid'Last);
         else
            Left := Old_Grid (I - 1);
         end if;
         
         Center := Old_Grid (I);
         
         --  Resolve wrapped right neighbor
         if I = Grid'Last then
            Right := Old_Grid (Grid'First);
         else
            Right := Old_Grid (I + 1);
         end if;
         
         Grid (I) := Apply_Rule (Left, Center, Right);
      end loop;
   end Evolve_Periodic;

   ----------------------------------------------------------------------
   --  Evolve_Expanding
   ----------------------------------------------------------------------
   function Evolve_Expanding (Grid : State_Array) return State_Array is
   begin
      if Grid'Length = 0 then
         raise Invalid_Grid;
      end if;

      declare
         Old_Grid : constant State_Array := Grid;
         Result   : State_Array (Grid'First - 1 .. Grid'Last + 1);
         Left, Center, Right : Bit;
      begin
         for I in Result'Range loop
            --  Extrapolate left state against infinite background bounds
            if I <= Grid'First then
               Left := 0;
            else
               Left := Old_Grid (I - 1);
            end if;

            --  Extrapolate center state against infinite background bounds
            if I < Grid'First or else I > Grid'Last then
               Center := 0;
            else
               Center := Old_Grid (I);
            end if;

            --  Extrapolate right state against infinite background bounds
            if I >= Grid'Last then
               Right := 0;
            else
               Right := Old_Grid (I + 1);
            end if;

            Result (I) := Apply_Rule (Left, Center, Right);
         end loop;
         return Result;
      end;
   end Evolve_Expanding;

   ----------------------------------------------------------------------
   --  Evolve_And_Extract_Center
   ----------------------------------------------------------------------
   procedure Evolve_And_Extract_Center
     (Grid       : in out State_Array;
      Center_Bit : out Bit)
   is
   begin
      --  Reject if grid is empty or has no single unambiguous center cell
      if Grid'Length = 0 or else Grid'Length mod 2 = 0 then
         raise Invalid_Grid;
      end if;

      declare
         --  Index calculation truncates toward zero correctly in Ada
         Mid_Index : constant Integer := Grid'First + (Grid'Length / 2);
      begin
         Evolve_Fixed_Zero (Grid);
         Center_Bit := Grid (Mid_Index);
      end;
   end Evolve_And_Extract_Center;

end Rule_30;
