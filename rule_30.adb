package body Rule_30 is

   ----------------------------------------------------------------------
   --  Apply_Rule
   ----------------------------------------------------------------------
   function Apply_Rule (Left, Center, Right : Bit) return Bit is
     (Left xor (Center or Right));

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
         Left   := (if I = Grid'First then 0 else Old_Grid (I - 1));
         Center := Old_Grid (I);
         Right  := (if I = Grid'Last  then 0 else Old_Grid (I + 1));
         
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

      for I in Grid'Range loop
         Left   := (if I = Grid'First then Old_Grid (Grid'Last)  else Old_Grid (I - 1));
         Center := Old_Grid (I);
         Right  := (if I = Grid'Last  then Old_Grid (Grid'First) else Old_Grid (I + 1));
         
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
            Left   := (if I <= Grid'First     then 0 else Old_Grid (I - 1));
            Center := (if I in Grid'Range     then Old_Grid (I) else 0);
            Right  := (if I >= Grid'Last      then 0 else Old_Grid (I + 1));

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
