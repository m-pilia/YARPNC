-- This file is part of YARPNC.
-- 
-- YARPNC is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- YARPNC is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with YARPNC. If not, see <http://www.gnu.org/licenses/>.
--
-- Copyright (C) Martino Pilia, 2014

with Ada.Numerics;
with Gtk.Widget;
with Gtk.Button;
with Gtk.Enums;
with Gdk.Color;
with Gtk.Main;
with Gtk.Label;
with Gdk.Event;
with Gdk.Types;         use all type Gdk.Types.Gdk_Key_Type;
with Gdk.Types.Keysyms; use Gdk.Types.Keysyms;
with Ada.Text_IO;
with Glib;          use Glib;
with Components;    use all type Components.List_Of_Digits.Node_Ptr;
                    use all type Components.List_Of_Digits.Iterator;
                    use Components.List_Of_Digits;
                    use all type Components.Digit_String;
                    use Components;
with Global_Vars;   use Global_Vars;

package body Calls is
    procedure Destroy (Widget: access Gtk.Widget.Gtk_Widget_Record'Class) is
    begin
        Gtk.Main.Main_Quit;
    end Destroy;

    function Keyboard_Input(
            Widget: access Gtk.Widget.Gtk_Widget_Record'Class;
            Event: Gdk.Event.Gdk_Event) return Gint is
        Key: Gdk.Types.Gdk_Key_Type;
    begin
        Key := Gdk.Event.Get_Key_Val(Event);
        case Key is 
            when GDK_1 | GDK_KP_1 => Add_Digit(null, Digit_Labels(1)'Access);
            when GDK_2 | GDK_KP_2 => Add_Digit(null, Digit_Labels(2)'Access);
            when GDK_3 | GDK_KP_3 => Add_Digit(null, Digit_Labels(3)'Access);
            when GDK_4 | GDK_KP_4 => Add_Digit(null, Digit_Labels(4)'Access);
            when GDK_5 | GDK_KP_5 => Add_Digit(null, Digit_Labels(5)'Access);
            when GDK_6 | GDK_KP_6 => Add_Digit(null, Digit_Labels(6)'Access);
            when GDK_7 | GDK_KP_7 => Add_Digit(null, Digit_Labels(7)'Access);
            when GDK_8 | GDK_KP_8 => Add_Digit(null, Digit_Labels(8)'Access);
            when GDK_9 | GDK_KP_9 => Add_Digit(null, Digit_Labels(9)'Access);
            when GDK_0 | GDK_KP_0 => Add_Digit(null, Digit_Labels(0)'Access);
            when GDK_Plus | GDK_KP_Add => Add(null);
            when GDK_Minus | GDK_KP_Subtract => Sub(null);
            when GDK_Asterisk | GDK_KP_Multiply => Mol(null);
            when GDK_Slash | GDK_KP_Divide => Div(null);
            when GDK_Period | GDK_KP_Decimal => Dot(null);
            when GDK_Return | GDK_KP_Enter => Enter(null);
            when GDK_BackSpace => Bks(null);
            when GDK_LC_e => Exp(null); 
            when GDK_Delete => Clear(null);
            when others => null;
        end case;
        return Gint(0);
    end Keyboard_Input;

    procedure Add_Digit(
            Widget: access Gtk.Widget.Gtk_Widget_Record'Class; 
            Data: Digit_String_Access) is
    begin
        case Input_Number.Part is
            when Int_Part => Components.List_Of_Digits.Push_Node(
                Input_Number.Int, Data.all);
            when Decimal_Part => Components.List_Of_Digits.Push_Node(
                Input_Number.Decimal, Data.all);
            when Exponent_Part => Components.List_Of_Digits.Push_Node(
                Input_Number.Exponent, Data.all);
        end case;
        Update_Display(Parse);
    end Add_Digit;

    procedure Dot(Button: access Gtk.Button.Gtk_Button_Record'Class) is
    begin
        if Input_Number.Part = Int_Part then
            if Input_Number.Int.Size = 0 then
                Components.List_Of_Digits.Push_Node(
                    Input_Number.Int, 
                    "0");
            end if;
            Input_Number.Part := Decimal_Part;
            Update_Display(Parse);
        end if;
    end Dot;

    procedure Exp(Button: access Gtk.Button.Gtk_Button_Record'Class) is
    begin
        if Input_Number.Part = Int_Part 
        or Input_Number.Part = Decimal_Part then
            if Input_Number.Int.Size = 0 then
                Components.List_Of_Digits.Push_Node(
                    Input_Number.Int, 
                    "0");
            end if;
            Input_Number.Part := Exponent_Part;
            Update_Display(Parse);
        end if;
    end Exp;

    procedure Bks(Button: access Gtk.Button.Gtk_Button_Record'Class) is
        Dummy: Digit_String;
    begin
        if Is_Input_Null then
            return;
        end if;
        if Input_Number.Part = Int_Part then
            Dummy := Components.List_Of_Digits.Pop_Node(
                Input_Number.Int);
        elsif Input_Number.Part = Decimal_Part then
            if Input_Number.Decimal.Size /= 0 then
                Dummy := Components.List_Of_Digits.Pop_Node(
                    Input_Number.Decimal);
            else
                Input_Number.Part := Int_Part;
            end if;
        else
            if Input_Number.Exponent.Size /= 0 then
                Dummy := Components.List_Of_Digits.Pop_Node(
                    Input_Number.Exponent);
            elsif Input_Number.Decimal.Size /= 0 then
                Input_Number.Part := Decimal_Part;
            else
                Input_Number.Part := Int_Part;
            end if;
        end if;
        Update_Display(Parse);
    end Bks;

    procedure Sign(Button: access Gtk.Button.Gtk_Button_Record'Class) is
        F: My_Float;
    begin
        if not Is_Input_Null then
            if Input_Number.Part = Exponent_Part then
                if Input_Number.Sign_Exp = "+" then
                    Input_Number.Sign_Exp := "-";
                else
                    Input_Number.Sign_Exp := "+";
                end if;
            else
                if Input_Number.Sign_Base = "+" then
                    Input_Number.Sign_Base := "-";
                else
                    Input_Number.Sign_Base := "+";
                end if;
            end if;
            Update_Display(Parse);
        else
            F := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
            Components.Stack_Of_Floats.Push_Node(Memory_Stack, -F);
            Update_Display;
        end if;
    end Sign;

    function Parse return String is
        Str: String(1..Display_Length) := (others => ' ');
        Size_Int: Integer := Input_Number.Int.Size;
        Size_Dec: Integer := Input_Number.Decimal.Size;
        Size_Exp: Integer := Input_Number.Exponent.Size;
        It: Iterator;
        procedure Shift(S: in out String) is
        begin
            S(S'First .. S'Last - 1) := S(S'First + 1 .. S'Last);
        end Shift;
    begin
        if (Input_Number.Sign_Base = "-") then
            Str(Display_Length..Display_Length) 
                := String(Input_Number.Sign_Base(1..1));
        end if;
        It := Components.List_Of_Digits.Get_Iterator(
            Input_Number.Int);
        for i in 1 .. Size_Int loop
            Shift(Str);
            Str(Display_Length..Display_Length) := 
                String(Components.List_Of_Digits.Next_Node(It));
        end loop;
        if (Size_Dec /= 0 or Input_Number.Part = Decimal_Part) then
            Shift(Str);
            Str(Display_Length..Display_Length) := ".";
        end if;
        if (Size_Dec /= 0) then
            It := Components.List_Of_Digits.Get_Iterator(
                Input_Number.Decimal);
            for i in 1 .. Size_Dec loop
                Shift(Str);
                Str(Display_Length..Display_Length) := 
                    String(Components.List_Of_Digits.Next_Node(It));
            end loop;
        end if;
        if (Size_Exp /= 0 or Input_Number.Part = Exponent_Part) then
            Shift(Str);
            Str(Display_Length..Display_Length) := "E";
        end if;
        if Input_Number.Sign_Exp = "-" and 
        (Input_Number.Exponent.Size > 0 
        or Input_Number.Part = Exponent_Part) then
            Shift(Str);
            Str(Display_Length..Display_Length) := 
                String(Input_Number.Sign_Exp(1..1));
        end if;
        if (Size_Exp /= 0) then
            It := Components.List_Of_Digits.Get_Iterator(
                Input_Number.Exponent);
            for i in 1 .. Size_Exp loop
                Shift(Str);
                Str(Display_Length..Display_Length) := 
                    String(Components.List_Of_Digits.Next_Node(It));
            end loop;
        end if;
        return Str;
    end Parse;

    procedure Format_Num(S: in out String) is
        F: My_Float;
        Dot_Pos: Integer := 1;
        Dec_Digits_Number: Integer := 0;
    begin
        F := My_Float'Value(S);
        -- when F = 0
        if F = 0.0 then
            Components.IO.Put(
                S,
                F,
                Aft => Max_Without_Exp,
                Exp => 0);
            return;
        end if;
        -- when F /= 0, check for digit number from decimal dot
        if (F > 0.0 and then 
          abs Integer(
                My_Float'Ceiling(Math.Log(abs F, 10.0))) < Max_Without_Exp) 
          or (F  < 0.0 and then 
          abs Integer(
                My_Float'Floor(Math.Log(abs F, 10.0))) < Max_Without_Exp
                ) then
            Components.IO.Put(
                S,
                F,
                Aft => Max_Without_Exp,
                Exp => 0);
        end if;
    end Format_Num;

    procedure Update_Display(Value: String := "none") is
        It: Components.Stack_Of_Floats.Iterator;
    begin
        It := Components.Stack_Of_Floats.Get_Iterator(Memory_Stack);
        -- set the first display with the input value when present
        if Value /= "none" then
            Gtk.Label.Set_Label(Display(1), Value);
        end if;

        -- set other displays
        for i in 1 .. Display_Number - 1 loop
            if Memory_Stack.Size > i - 1 then
                declare
                    Str: String
                        := My_Float'Image(
                            Components.Stack_Of_Floats.Next_Node(It));
                begin
                    Format_Num(Str);
                    Gtk.Label.Set_Label(
                        (if Value = "none"
                            then Display(i) 
                            else Display(i + 1)),
                        Str);
                end;
            else
                Gtk.Label.Set_Label(
                    (if Value = "none"
                        then Display(i) 
                        else Display(i + 1)),
                    "");
            end if;
        end loop;
            
        -- set the first display to 0 if memory stack and 
        -- input number are empty
        if Value = "none" and Memory_Stack.Size = 0 and Is_Input_Null then
            Gtk.Label.Set_Label(Display(1), "0");
        end if;

        -- set the last display when needed
        if Memory_Stack.Size > Display_Number - 1 and Value = "none" then
            declare
                Str: String := 
                    My_Float'Image(Components.Stack_Of_Floats.Next_Node(It));
            begin
                Format_Num(Str);
                Gtk.Label.Set_Label(
                    Display(Display_Number),
                    Str);
            end;
        elsif Value = "none" then
            Gtk.Label.Set_Label(Display(Display_Number), "");
        end if;
    end Update_Display;
    
    procedure Enter(Button: access Gtk.Button.Gtk_Button_Record'Class) is
        F: My_Float;
    begin
        if Is_Input_Null then
            -- when the input number is empty,  duplicates 
            -- the last element in memory and return
            if Memory_Stack.Size > 0 then 
                declare
                    F: My_Float;
                begin
                    F := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
                    Components.Stack_Of_Floats.Push_Node(Memory_Stack, F);
                    Components.Stack_Of_Floats.Push_Node(Memory_Stack, F);
                end;
                Update_Display;
            end if;
            return;
        end if;
        -- verify if exponent is declared but not inserted
        -- eliminates it eventually
        if Input_Number.Part = Exponent_Part and
          Input_Number.Exponent.Size = 0 then
            Input_Number.Part := Decimal_Part;
        end if;
        -- parse the input number and save the value to the memory stack
        F := My_Float'Value(Parse);
        Components.Stack_Of_Floats.Push_Node(Memory_Stack, F);
        Components.Input_Number_Reset(Input_Number);
        Input_Number.LastX := F;
        Update_Display;
    end Enter;

    procedure LastX(Button: access Gtk.Button.Gtk_Button_Record'Class) is
    begin
        if not Is_Input_Null then
            Enter(null);
        end if;
        Components.Stack_Of_Floats.Push_Node(
            Memory_Stack, 
            Input_Number.LastX);
        Update_Display;
    end LastX;

    procedure Drop(Button: access Gtk.Button.Gtk_Button_Record'Class) is
        Dummy: My_Float;
    begin
        if not Is_Input_Null then
            Components.Input_Number_Reset(Input_Number);
        else
            Dummy := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
        end if;
        Update_Display;
    end Drop;

    procedure Commute(Button: access Gtk.Button.Gtk_Button_Record'Class) is
        Buf, Buf2: My_Float;
    begin
        if Memory_Stack.Size > 1 
                or (Memory_Stack.Size = 1 and not Is_Input_Null) then
            if not Is_Input_Null then
                Enter(null);
            end if;
            Buf := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
            Buf2 := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
            Components.Stack_Of_Floats.Push_Node(Memory_Stack, Buf);
            Components.Stack_Of_Floats.Push_Node(Memory_Stack, Buf2);
            Update_Display;
        end if;
    end Commute;

    procedure Hyp(Button: access Gtk.Button.Gtk_Button_Record'Class) is
        Active_Color: Gdk.Color.Gdk_Color;
    begin
        if Hyp_State then -- chenge state to compute trigonometric
            Hyp_State := False;
            -- change color of the button and labels of function buttons
            Gtk.Button.Modify_Bg(
                Function_Buttons(10),
                Gtk.Enums.State_Normal,
                Gdk.Color.Null_Color);
            if Inv_State then
                for i in 1..3 loop
                    Function_Buttons(6 + i).Set_Label(Inv_Trig_Labels(i));
                end loop;
            else
                for i in 1..3 loop
                    Function_Buttons(6 + i).Set_Label(Trig_Labels(i));
                end loop;
            end if;
        else -- change state to compute hyperbolic
            Hyp_State := True;
            -- change color of the button and labels of function buttons
            Gdk.Color.Set_Rgb(
                Active_Color,
                Guint16(16#FF#), Guint16(16#FF#), Guint16(0));
            Gtk.Button.Modify_Bg(
                Function_Buttons(10),
                Gtk.Enums.State_Normal,
                Active_Color);
            if Inv_State then
                for i in 1..3 loop
                    Function_Buttons(6 + i).Set_Label(Inv_Hyp_Labels(i));
                end loop;
            else
                for i in 1..3 loop
                    Function_Buttons(6 + i).Set_Label(Hyp_Labels(i));
                end loop;
            end if;
        end if;
    end Hyp;

    procedure Inv(Button: access Gtk.Button.Gtk_Button_Record'Class) is
        Active_Color: Gdk.Color.Gdk_Color;
    begin
        if Inv_State then -- change state to compute direct functions
            Inv_State := False;
            -- change color of the button and labels of function buttons
            Gtk.Button.Modify_Bg(
                Function_Buttons(11),
                Gtk.Enums.State_Normal,
                Gdk.Color.Null_Color);
            if Hyp_State then
                for i in 1..3 loop
                    Function_Buttons(6 + i).Set_Label(Hyp_Labels(i));
                end loop;
            else
                for i in 1..3 loop
                    Function_Buttons(6 + i).Set_Label(Trig_Labels(i));
                end loop;
            end if;
        else -- change state to compute inverse functions
            Inv_State := True;
            -- change color of the button and labels of function buttons
            Gdk.Color.Set_Rgb(
                Active_Color,
                Guint16(16#FF#), Guint16(16#FF#), Guint16(0));
            Gtk.Button.Modify_Bg(
                Function_Buttons(11),
                Gtk.Enums.State_Normal,
                Active_Color);
            if Hyp_State then
                for i in 1..3 loop
                    Function_Buttons(6 + i).Set_Label(Inv_Hyp_Labels(i));
                end loop;
            else
                for i in 1..3 loop
                    Function_Buttons(6 + i).Set_Label(Inv_Trig_Labels(i));
                end loop;
            end if;
        end if;
    end Inv;

    procedure Add(Button: access Gtk.Button.Gtk_Button_Record'Class) is
        First, Second, Result: My_Float;
    begin
        if not Is_Input_Null then
            Enter(null);
        end if;
        if Memory_Stack.Size < 2 then
            return;
        end if;
        Second := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
        First  := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
        Result := First + Second;
        Components.Stack_Of_Floats.Push_Node(
            Memory_Stack, Result);
        Update_Display;
    end Add;

    procedure Sub(Button: access Gtk.Button.Gtk_Button_Record'Class) is
        First, Second, Result: My_Float;
    begin
        if not Is_Input_Null then
            Enter(null);
        end if;
        if Memory_Stack.Size < 2 then
            return;
        end if;
        Second := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
        First  := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
        Result := First - Second;
        Components.Stack_Of_Floats.Push_Node(
            Memory_Stack, Result);
        Update_Display;
    end Sub;

    procedure Mol(Button: access Gtk.Button.Gtk_Button_Record'Class) is
        First, Second, Result: My_Float;
    begin
        if not Is_Input_Null then
            Enter(null);
        end if;
        if Memory_Stack.Size < 2 then
            return;
        end if;
        Second := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
        First  := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
        Result := First * Second;
        Components.Stack_Of_Floats.Push_Node(
            Memory_Stack, Result);
        Update_Display;
    end Mol;

    procedure Div(Button: access Gtk.Button.Gtk_Button_Record'Class) is
        First, Second: My_Float;
    begin
        if Memory_Stack.Size >= 2 or 
        (Memory_Stack.Size >= 1 and not Is_Input_Null) then
            if not Is_Input_Null then
                Enter(null);
            end if;
            Second := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
            First  := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
            if Second /= 0.0 then
                Components.Stack_Of_Floats.Push_Node(
                    Memory_Stack,
                    First / Second);
                Update_Display;
            else
                Update_Display("Error");
            end if;
        end if;
    end Div;

    function Is_Input_Null return Boolean is
    begin
        return Input_Number.Int.Size = 0
        and Input_Number.Decimal.Size = 0
        and Input_Number.Exponent.Size = 0;
    end Is_Input_Null;

    procedure Sin(Button: access Gtk.Button.Gtk_Button_Record'Class) is
        F: My_Float;
    begin
        if not Is_Input_Null then
            Enter(null);
        end if;
        F := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
        -- convert to rad if needed
        if not Hyp_State and not Inv_State then
            case Angle is
                when Deg => F := F / 360.0 * 2.0 * Ada.Numerics.Pi;
                when Rad => null;
                when Grad => F := F / 400.0 * 2.0 * Ada.Numerics.Pi;
            end case;
        end if;
        -- call right function
        if Hyp_State then
            if Inv_State then
                F := Math.Arcsinh(F);
            else
                F := Math.Sinh(F);
            end if;
        else
            if Inv_State then
                F := Math.Arcsin(F);
            else
                F := Math.Sin(F);
            end if;
        end if;
        -- convert result if needed
        if not Hyp_State and Inv_State then
            case Angle is
                when Deg => F := F * 360.0 / 2.0 / Ada.Numerics.Pi;
                when Rad => null;
                when Grad => F := F * 400.0 / 2.0 / Ada.Numerics.Pi;
            end case;
        end if;
        -- put result in memory
        Components.Stack_Of_Floats.Push_Node(Memory_Stack, F);
        Update_Display;
    end Sin;

    procedure Cos(Button: access Gtk.Button.Gtk_Button_Record'Class) is
        F: My_Float;
    begin
        if not Is_Input_Null then
            Enter(null);
        end if;
        F := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
        -- convert to rad if needed
        if not Hyp_State and not Inv_State then
            case Angle is
                when Deg => F := F / 360.0 * 2.0 * Ada.Numerics.Pi;
                when Rad => null;
                when Grad => F := F / 400.0 * 2.0 * Ada.Numerics.Pi;
            end case;
        end if;
        -- call right function
        if Hyp_State then
            if Inv_State then
                F := Math.Arccosh(F);
            else
                F := Math.Cosh(F);
            end if;
        else
            if Inv_State then
                F := Math.Arccos(F);
            else
                F := Math.Cos(F);
            end if;
        end if;
        -- convert result if needed
        if not Hyp_State and Inv_State then
            case Angle is
                when Deg => F := F * 360.0 / 2.0 / Ada.Numerics.Pi;
                when Rad => null;
                when Grad => F := F * 400.0 / 2.0 / Ada.Numerics.Pi;
            end case;
        end if;
        -- put result in memory
        Components.Stack_Of_Floats.Push_Node(Memory_Stack, F);
        Update_Display;
    end Cos;

    procedure Tan(Button: access Gtk.Button.Gtk_Button_Record'Class) is
        F: My_Float;
    begin
        if not Is_Input_Null then
            Enter(null);
        end if;
        F := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
        -- convert to rad if needed
        if not Hyp_State and not Inv_State then
            case Angle is
                when Deg => F := F / 360.0 * 2.0 * Ada.Numerics.Pi;
                when Rad => null;
                when Grad => F := F / 400.0 * 2.0 * Ada.Numerics.Pi;
            end case;
        end if;
        -- call right function
        if Hyp_State then
            if Inv_State then
                F := Math.Arctanh(F);
            else
                F := Math.Tanh(F);
            end if;
        else
            if Inv_State then
                F := Math.Arctan(F);
            else
                F := Math.Tan(F);
            end if;
        end if;
        -- convert result if needed
        if not Hyp_State and Inv_State then
            case Angle is
                when Deg => F := F * 360.0 / 2.0 / Ada.Numerics.Pi;
                when Rad => null;
                when Grad => F := F * 400.0 / 2.0 / Ada.Numerics.Pi;
            end case;
        end if;
        -- put result in memory
        Components.Stack_Of_Floats.Push_Node(Memory_Stack, F);
        Update_Display;
    end Tan;

    procedure Angle_Type(Button: access Gtk.Button.Gtk_Button_Record'Class) is
    begin
        case Angle is
            when Deg =>
                Angle := Rad;
                Gtk.Button.Set_Label(Function_Buttons(12), " rad ");
            when Rad =>
                Angle := Grad;
                Gtk.Button.Set_Label(Function_Buttons(12), " grad");
            when Grad =>
                Angle := Deg;
                Gtk.Button.Set_Label(Function_Buttons(12), " deg ");
        end case;
    end Angle_Type;

    procedure Pi(Button: access Gtk.Button.Gtk_Button_Record'Class) is
    begin
        Components.Stack_Of_Floats.Push_Node(
            Memory_Stack,
            Ada.Numerics.Pi);
        Update_Display;
    end Pi;

    -- ausiliary recursive function to compute factorial
    function Factorial_Rec(F: in My_Float) return My_Float is
    begin
        if F > 1.0 then
            return F * Factorial_Rec(F - 1.0);
        else
            return 1.0;
        end if;
    end Factorial_Rec;

    procedure Factorial(Button: access Gtk.Button.Gtk_Button_Record'Class) is
        F: My_Float;
    begin
        if not Is_Input_Null then
            Enter(null);
        end if;
        F := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
        if My_Float'Floor(F) = F then
            F := Factorial_Rec(abs F);
        end if;
        Components.Stack_Of_Floats.Push_Node(Memory_Stack, F);
        Update_Display;
    end Factorial;

    procedure Sqrt(Button: access Gtk.Button.Gtk_Button_Record'Class) is
        F: My_Float;
    begin
        if not Is_Input_Null then
            Enter(null);
        end if;
        F := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
        F := Math.Sqrt(F);
        Components.Stack_Of_Floats.Push_Node(Memory_Stack, F);
        Update_Display;
    end Sqrt;

    procedure YeX(Button: access Gtk.Button.Gtk_Button_Record'Class) is
        X, Y: My_Float;
    begin
        if Memory_Stack.Size >= 2 or 
        (Memory_Stack.Size >= 1 and not Is_Input_Null) then
            if not Is_Input_Null then
                Enter(null);
            end if;
            X := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
            Y := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
            Components.Stack_Of_Floats.Push_Node(
                Memory_Stack,
                Math."**"(Y, X));
            Update_Display;
        end if;
    end YeX;

    procedure Exponential(Button: access Gtk.Button.Gtk_Button_Record'Class) is
        F: My_Float;
    begin
        if not Is_Input_Null then
            Enter(null);
        end if;
        F := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
        F := Math.Exp(F);
        Components.Stack_Of_Floats.Push_Node(Memory_Stack, F);
        Update_Display;
    end Exponential;

    procedure Log(Button: access Gtk.Button.Gtk_Button_Record'Class) is
        F: My_Float;
    begin
        if not Is_Input_Null then
            Enter(null);
        end if;
        F := Components.Stack_Of_Floats.Pop_Node(Memory_Stack);
        if F > 0.0 then
            Components.Stack_Of_Floats.Push_Node(
                Memory_Stack,
                Math.Log(F));
            Update_Display;
        else
            Update_Display("Error");
        end if;
    end Log;

    procedure Clear(Button: access Gtk.Button.Gtk_Button_Record'Class) is
    begin
        Components.Stack_Of_Floats.Clear(Memory_Stack);
        Components.Input_Number_Reset(Input_Number);
        Update_Display;
    end Clear;
end Calls;
