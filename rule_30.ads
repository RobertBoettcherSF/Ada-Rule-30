package Rule_30 is
   pragma Pure;

   --  A discrete bit type perfectly models the binary states of Rule 30 cells.
   --  Using a modular type allows native use of bitwise logic operators.
   type Bit is mod 2;
   
   --  A 1D grid representing a single generation of the cellular automaton.
   type State_Array is array (Integer range <>) of Bit;
   pragma Pack (State_Array);
   
   Invalid_Grid : exception;
   --  Raised if the provided grid array has a length of 0.

   --  ========================================================================
   --  Helper: Apply Rule 30 to a 3-cell neighborhood
   --  P = Left, Q = Center, R = Right
   --  Rule 30 logically reduces to: P XOR (Q OR R)
   --  ========================================================================
   function Apply_Rule (Left, Center, Right : Bit) return Bit
     with Global => null;

   --  ========================================================================
   --  Variant 1: Evolve with Fixed Zero Boundary (Synchronous)
   --  Cells outside the array boundaries are strictly evaluated as 0 (dead).
   --  The automaton is updated in-place representing a synchronous state jump.
   --  ========================================================================
   procedure Evolve_Fixed_Zero (Grid : in out State_Array)
     with Global => null,
          Pre => Grid'Length > 0;

   --  ========================================================================
   --  Variant 2: Evolve with Periodic Boundary (Wrap-around / Synchronous)
   --  The spatial grid acts as a torus. The leftmost cell's left neighbor 
   --  is the rightmost cell, and the rightmost cell's right neighbor is the 
   --  leftmost cell.
   --  ========================================================================
   procedure Evolve_Periodic (Grid : in out State_Array)
     with Global => null,
          Pre => Grid'Length > 0;

   --  ========================================================================
   --  Variant 3: Evolve with Expanding Boundaries (Infinite Zero Background)
   --  Models the true theoretical behavior of a bounded block growing into an 
   --  infinite background of 0s. The returned generation natively expands 
   --  its coordinate space by +1 on both the left and right per step.
   --  ========================================================================
   function Evolve_Expanding (Grid : State_Array) return State_Array
     with Global => null,
          Pre => Grid'Length > 0 
                 and then Grid'First > Integer'First 
                 and then Grid'Last < Integer'Last,
          Post => Evolve_Expanding'Result'Length = Grid'Length + 2;

   --  ========================================================================
   --  Variant 4: Extract Pseudorandom Center Bit
   --  Evolves a bounded grid by one step and extracts the center column's 
   --  state. This mechanism was classically used as a PRNG in Mathematica.
   --  ========================================================================
   procedure Evolve_And_Extract_Center
     (Grid       : in out State_Array;
      Center_Bit : out Bit)
     with Global => null,
          Pre => Grid'Length > 0 and then Grid'Length mod 2 /= 0;

end Rule_30;
