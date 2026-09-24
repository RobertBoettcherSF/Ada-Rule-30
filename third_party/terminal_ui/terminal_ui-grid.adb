with Terminal_UI.Frame; use Terminal_UI.Frame;

package body Terminal_UI.Grid is

   function Row_Line (G : Grid; R : Positive) return String is
      W    : constant Positive := G'Length (2);
      Line : String (1 .. W);
      C0   : constant Positive := G'First (2);
   begin
      for I in 1 .. W loop
         Line (I) := G (R, C0 + I - 1);
      end loop;
      return Line;
   end Row_Line;

   function Render_Grid (G : Grid) return String is
      Rows    : constant Positive := G'Length (1);
      Cols    : constant Positive := G'Length (2);
      Max_Len : constant Natural := Rows * (Cols + 1);
      Buf     : String (1 .. Max_Len);
      Last    : Natural := 0;
      R0      : constant Positive := G'First (1);
   begin
      for I in 0 .. Rows - 1 loop
         Append_Line (Buf, Last, Row_Line (G, R0 + I));
      end loop;
      return Buf (1 .. Last);
   end Render_Grid;

   function Render_Grid (G : Grid; Status : String) return String is
      Body_S : constant String := Render_Grid (G);
   begin
      return Body_S & Status;
   end Render_Grid;

   function Make_Status_Box
     (Messages    : String;
      Outer_Width : Positive;
      Border      : Character := '#') return String
   is
      --  Upper bound: border + many msg lines + border
      Max_Lines : constant Natural :=
        2 + (if Messages'Length = 0 then 0
             else Count_Lines (Messages));
      Max_Len   : constant Natural := Max_Lines * (Outer_Width + 1);
      Buf       : String (1 .. Max_Len);
      Last      : Natural := 0;

      procedure Emit_Msgs is
         Start : Natural := Messages'First;
         I     : Natural := Messages'First;
      begin
         if Messages'Length = 0 then
            return;
         end if;
         while I <= Messages'Last loop
            if Messages (I) = ASCII.LF then
               Append_Line
                 (Buf, Last,
                  Msg_Line
                    (Messages (Start .. I - 1), Outer_Width, Border));
               Start := I + 1;
            end if;
            I := I + 1;
         end loop;
         if Start <= Messages'Last then
            Append_Line
              (Buf, Last,
               Msg_Line
                 (Messages (Start .. Messages'Last), Outer_Width, Border));
         elsif Start = Messages'Last + 1
           and then Messages (Messages'Last) = ASCII.LF
         then
            --  trailing LF already handled; nothing more
            null;
         end if;
      end Emit_Msgs;
   begin
      Append_Line (Buf, Last, Border_Line (Outer_Width, Border));
      Emit_Msgs;
      Append_Line (Buf, Last, Border_Line (Outer_Width, Border));
      return Buf (1 .. Last);
   end Make_Status_Box;

end Terminal_UI.Grid;
