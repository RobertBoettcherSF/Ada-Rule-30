with Ada.Strings.Fixed;
with Terminal_UI.Frame;
with Terminal_UI.Grid;

package body Rule_30.Terminal is

   function Trim_Nat (N : Natural) return String is
     (Ada.Strings.Fixed.Trim (N'Image, Ada.Strings.Left));

   function Render_Frame
     (Screen       : Board;
      Gen          : Natural;
      Generations  : Positive;
      Board_Rows   : Positive) return String
   is
      G : Terminal_UI.Grid.Grid (1 .. Board_Rows, 1 .. Frame_Width) :=
        [others => [others => ' ']];
   begin
      for R in 1 .. Board_Rows loop
         for C in Cell_Col loop
            if Screen (R, C) = 1 then
               G (R, C) := '#';
            end if;
         end loop;
      end loop;

      declare
         Status : constant String :=
           Terminal_UI.Grid.Make_Status_Box
             ("CURRENT GEN  " & Trim_Nat (Gen) & " / " & Trim_Nat (Generations)
              & "          RULE  30"
              & ASCII.LF
              & "BW  live default  make once|--once  N=1.."
              & Trim_Nat (Max_Gens),
              Frame_Width);
      begin
         return Terminal_UI.Grid.Render_Grid (G, Status);
      end;
   end Render_Frame;

   function Contains_ESC (S : String) return Boolean
     renames Terminal_UI.Frame.Contains_ESC;

   function Count_Lines (S : String) return Natural
     renames Terminal_UI.Frame.Count_Lines;

   function Line_Width_OK (S : String; Expected : Positive) return Boolean
     renames Terminal_UI.Frame.Line_Width_OK;

end Rule_30.Terminal;
