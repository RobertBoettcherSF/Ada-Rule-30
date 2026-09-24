--  Terminal output helpers: clear, print a frame, brief pause.
--  Domain-free (no cellular-automaton / game types).

package Terminal_UI is

   --  Prefer clear(1); fall back to ANSI ESC[2J / ESC[H if clear fails.
   procedure Clear_Screen;

   --  Write S and Flush (no clear).
   procedure Put_Frame (S : String);

   --  Busy-wait pause (portable; no delay statement required).
   procedure Pause_Seconds (Seconds : Duration);

end Terminal_UI;
