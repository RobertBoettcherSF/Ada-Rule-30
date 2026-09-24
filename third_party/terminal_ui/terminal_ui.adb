with Ada.Text_IO;
with Ada.Calendar;
with Interfaces.C; use Interfaces.C;

package body Terminal_UI is

   function C_System (Command : Interfaces.C.Char_Array) return Interfaces.C.int
     with Import, Convention => C, External_Name => "system";

   procedure Clear_Screen is
      RC : Interfaces.C.int;
   begin
      --  Prefer the real clear(1); ESC[2J is ignored on some Mint TTYs.
      RC := C_System (Interfaces.C.To_C ("clear 2>/dev/null"));
      if RC /= 0 then
         Ada.Text_IO.Put (ASCII.ESC & "[2J" & ASCII.ESC & "[H");
         Ada.Text_IO.Flush;
      end if;
   end Clear_Screen;

   procedure Put_Frame (S : String) is
   begin
      Ada.Text_IO.Put (S);
      Ada.Text_IO.Flush;
   end Put_Frame;

   procedure Pause_Seconds (Seconds : Duration) is
      use Ada.Calendar;
      T0 : constant Time := Clock;
   begin
      while Clock - T0 < Seconds loop
         null;
      end loop;
   end Pause_Seconds;

end Terminal_UI;
