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

with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Text_IO;
with Gdk.Event;
with Glib; use Glib;
with Gtk.Alignment;
with Gtk.Button;
with Gtk.Handlers;
with Gtk.Label;
with Gtk.Widget;
with List;
with Stack;

-- @summary
-- Types and subroutines implementing the functions. 
-- 
-- @description
-- This package collects the definition of the types and the subroutines
-- implementing the calculator logic.
-- 
package Components is
    
    -- the floating point type used in the calculator
    type My_Float is digits 18; 
    
    -- a string of 1 character
    type Digit_String is new String (1..1);
    
    -- access to Digit_String
    type Digit_String_Access is access all Digit_String;
   
    -- array of Gtk.Alignment
    type Align_Array is array (Integer range <>) of Gtk.Alignment.Gtk_Alignment;
    -- array of Gtk.Label
    type Display_Array is array (Integer range <>) of Gtk.Label.Gtk_Label;
    -- array of Gtk.Buttons
    type Button_Array is array (Integer range <>) of Gtk.Button.Gtk_Button;
    
     -- a string of 1 character
    type Sign is new String (1..1); -- ("+", "-")
    
    -- Type defining the possible angle measuer unit
    -- @value Deg degrees
    -- @value Rad radiants
    -- @value Grad centesimal
    type Angle_Type is (Deg, Rad, Grad);
    
    -- a type defining a part (integer part, decimal part, exponent part)
    -- of the input number
    -- @value Int_Part indicates the current part accepting input is integer
    -- @value Decimal_Part the current part accepting input is decimal
    -- @value Exponent_Part the current part accepting input is exponent
    type Number_Part is (Int_Part, Decimal_Part, Exponent_Part);

    -- a list of Digit_String type
    package List_Of_Digits is new List (Digit_String);
    
    -- a stack of My_Float type with null value set to 0.0
    package Stack_Of_Floats is new Stack (My_Float, 0.0);
    
    -- instantiation of Ada.Text_IO.Float_IO
    package IO is new Ada.Text_IO.Float_IO (My_Float);
    
    -- instantiation of Ada.Numerics.Generic_Elementary_Functions
    package Math is new Ada.Numerics.Generic_Elementary_Functions(My_Float);
    
    -- instantiation of Gtk.Handlers.Callback
    package Handlers is new Gtk.Handlers.Callback(
        Gtk.Widget.Gtk_Widget_Record);
    
    -- instantiation of Gtk.Handlers.Return_Callback
    package Key_Handlers is new Gtk.Handlers.Return_Callback(
        Gtk.Widget.Gtk_Widget_Record,
        Gint);

    -- instantiation of Gtk.Handlers.User_Callback
    package User_Callback_String is new Gtk.Handlers.User_Callback
      (Gtk.Widget.Gtk_Widget_Record, Digit_String_Access);
    
    -- A record type defining a number in input
    -- @field Int the integer part of the number
    -- @field Decimal the decimal part of the number
    -- @field Exponent the exponent part of the number
    -- @field Sign_Base sign of the number
    -- @field Sign_Exp sign for the exponent
    -- @field Part represents the current part of the number currently 
    --        accepting input
    -- @field LastX contains the last complete input parsed by Enter
    type Input_Number_Type is
        record
            Int: List_Of_Digits.List := (null, 0);
            Decimal: List_Of_Digits.List := (null, 0);
            Exponent: List_Of_Digits.List := (null, 0);
            Sign_Base: Sign := "+";
            Sign_Exp: Sign := "+";
            Part: Number_Part := Int_Part;
            LastX: My_Float := 0.0;
        end record;
    
    -- labels for the digit keys
    Digit_Labels: array (Integer range 0..9) of aliased Digit_String := (
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9");
   
    -- number of numeric displays
    Display_Number: constant Integer := 6;
    -- length (in characters) of each numeric display
    Display_Length: constant Integer := 30;
    -- maximum number length (digits number) without exponential notation
    Max_Without_Exp: constant Integer := 6;
   
    -- array of Gtk.Buttons conaining the buttons for functions
    Function_Buttons: Button_Array (1..18);

    -- array of Gtk.Alignment designed to contain numeric displays
    Display_Align: Align_Array (1 .. Display_Number);
    -- array of numeric displays (each is a Gtk.Label)
    Display: Display_Array (1 .. Display_Number);

    
    -- record containing current digits during input
    -- the record is flushed when enter is pressed
    Input_Number: aliased Input_Number_Type;

    -- stack representing the calc memory
    -- contains the numbers in memory
    Memory_Stack: Stack_Of_Floats.Stack;

    -- flag to commute between trigonometric and hyperbolic functions
    -- True: hyperbolic functions in use
    -- False: trigonometric function in use
    Hyp_State: Boolean := False;
    
    -- flag to commute trigonometric/hyperbolic function inversion
    -- True: inverse functions in use
    -- False: direct functions in use
    Inv_State: Boolean := False;
    
    -- variable conraining the current angle measure unit in use 
    Angle: Angle_Type := Rad;

    -- labels for trigonometric/hyperbolic functions
    -- under various combination of flags
    Trig_Labels: constant array (Integer range 1..3) of String(1..5) :=
        ("sin  ", " cos ", " tan ");
    Hyp_Labels: constant array (Integer range 1..3) of String(1..5) :=
        ("sinh ", " cosh", " tanh");
    Inv_Trig_Labels: constant array (Integer range 1..3) of String(1..5) :=
        ("asin ", "acos ", "atan ");
    Inv_Hyp_Labels: constant array (Integer range 1..3) of String(1..5) :=
     ("asinh", "acosh", "atanh");
   
    -- a procedure to reset the input number
    -- @param D the Input_Number to be resetted
    procedure Input_Number_Reset(D: in out Input_Number_Type);
    
    -- technical procs and funs
    procedure Destroy(Widget: access Gtk.Widget.Gtk_Widget_Record'Class);
    -- Destroy the Gtk.Widget
    -- @param Widget The target Gtk.Widget to be destroyed

    function Keyboard_Input(
        Widget: access Gtk.Widget.Gtk_Widget_Record'Class;
        Event: Gdk.Event.Gdk_Event) return Gint;
    -- Handles the keyboard input
    -- @param Widget The caller Gtk.Widget
    -- @param Event The keyboard event causing the function call 

    procedure Add_Digit(
        Widget: access Gtk.Widget.Gtk_Widget_Record'Class;
        Data: Digit_String_Access);
    -- This procedure is called when a digit key is pressed; 
    -- this adds a digit to the input number
    -- @param Widget The caller Gtk.Widget
    -- @param Data Access to the string representing the digit

    function Parse return String;
    -- This function parses the input number and returns a String
    -- containing a literal representation of its float value
    -- @return String representing the input number float value

    procedure Update_Display(Value: String := "none");
    -- Update the display. When an argument is provided, it is showed as
    -- content of display 1, and other displays show the content of 
    -- the memory stack. If no argument is passed, all displays show only
    -- the memory stack content
    -- @param Value Optional String to be show on display 1

    function Is_Input_Null return Boolean;
    -- Check if the input number contains something.
    -- @return True if the input number is void, False otherwise
    
    procedure Format_Num(S: in out String);
    -- Formats a String containing a number in a human readable format
    -- @param String The string to be formatted

    -- input keys
    procedure Dot(Button: access Gtk.Button.Gtk_Button_Record'Class);
    -- Terminates the input of the integer part of the input number, adds a 
    -- dot and begin to accept input in the decimal part
    -- This procedure changes the Input_Number.Part to Decimal
    -- @param Button the caller Gtk.Button
    
    procedure Exp(Button: access Gtk.Button.Gtk_Button_Record'Class);
    -- Terminates the input of the integer or decimal part of the input 
    -- number, adds a E and begin to accept input in the exponent part
    -- This procedure changes the Input_Number.Part to Exponent
    -- @param Button the caller Gtk.Button
    
    procedure Sign_Change(Button: access Gtk.Button.Gtk_Button_Record'Class);
    -- If the Input_Number is not empty: change the sign of the whole number
    -- if the current Input_Number.Part is Integer or Decimal, or changes the
    -- sign of the exponent when Input_Number.Part is Exponent
    -- If the input number is empty, changes the sign of the last element
    -- in the memory stack
    -- @param Button the caller Gtk.Button

    procedure Bks(Button: access Gtk.Button.Gtk_Button_Record'Class);
    -- Procedure for the Backspace key. The behaviour depends on the
    -- status of input number:
    -- * Input_Number.Part is set to Int, Decimal or Exponent and there
    --   is at least one digit in the relative digit list: then this
    --   procedure removes the last digit inserted
    -- * Input_Number.Part is set to Decimal and no decimal digit is present
    --   in input: then this procedure sets Input_Number.Part back to Int
    -- * Input_Number.Part is set to Exponent and no exponent digit is present
    --   in input: then this procedure sets Input_Number.Part back to Decimal
    --   if some decimal digit exists, otherwise it sets Input_Number.Part back
    --   to Int.
    -- * Input_Number.Part is set to Int and no int digit is present: then this
    --   procedure does nothing
    -- @param Button the caller Gtk.Button

    -- stack operators
    procedure Enter(Button: access Gtk.Button.Gtk_Button_Record'Class);
    -- Procedure for the Enter key. This procedure parses the current
    -- content of Input_Number record, saves it's float value in the memory
    -- stack and in the Input_Number.LastX field, then calls the Update_Screen
    -- @param Button the caller Gtk.Button
    
    procedure Drop(Button: access Gtk.Button.Gtk_Button_Record'Class);
    -- This procedure removes the last element entered in the memory stack
    -- @param Button the caller Gtk.Button

    procedure Commute(Button: access Gtk.Button.Gtk_Button_Record'Class);
    -- This procedure exchanges the position of the last two elements 
    -- inserted in the memory stack
    -- @param Button the calling Gtk.Button

    procedure LastX(Button: access Gtk.Button.Gtk_Button_Record'Class);
    -- Push the element from the Input_Number.LastX field to the memory stack
    -- @param Button the calling Gtk.Button
    
    procedure Clear(Button: access Gtk.Button.Gtk_Button_Record'Class);
    -- This procedure clear the memory stack removing all numbers in meory
    -- and clear the Input_Number
    
    -- base operators
    -- Each one of this procedures calls Enter(null) if the Input_Number 
    -- is not void, then takes the last two numbers from the memory stack, 
    -- computes the arithmetic and then the result is inserted in the 
    -- memory stack
    procedure Add(Button: access Gtk.Button.Gtk_Button_Record'Class);
    procedure Sub(Button: access Gtk.Button.Gtk_Button_Record'Class);
    procedure Mol(Button: access Gtk.Button.Gtk_Button_Record'Class);
    procedure Div(Button: access Gtk.Button.Gtk_Button_Record'Class);

    -- trascendent functions
    -- Each one of this procedures calls Enter(null) if the Input_Number
    -- is not void, then takes the last element from the memory stack, 
    -- computes the trigonometric or hyperbolic function, or its inverse,
    -- depending from the status of the Global_Vars.Hyp_State and Global_Vars.
    -- Inv_State flags, and then the result is saved in the memory stack
    procedure Sin(Button: access Gtk.Button.Gtk_Button_Record'Class);
    procedure Cos(Button: access Gtk.Button.Gtk_Button_Record'Class);
    procedure Tan(Button: access Gtk.Button.Gtk_Button_Record'Class);
    
    procedure Hyp(Button: access Gtk.Button.Gtk_Button_Record'Class);
    -- Commute the status of the Global_Vars.Hyp_State
    -- While the flag is set to True, the Sin, Cos and Tan procedures
    -- compute the value of the relative hyperbolic function, while it is set
    -- to false the trigonometric function is applied instead
    -- @param Button the caller Gtk.Button
    
    procedure Inv(Button: access Gtk.Button.Gtk_Button_Record'Class);
    -- Commute the status of the Global_Vars.Hyp_State
    -- While the flag is set to True, the Sin, Cos and Tan procedures
    -- compute the value of the inverse function (hyperbolic or trigonometric, 
    -- depending on the Hyp_State flag), while it is set to false the
    -- direct function is applied instead
    -- @param Button the caller Gtk.Button
    
    procedure Angle_Change(Button: access Gtk.Button.Gtk_Button_Record'Class);
    -- Commute the angle unit. It changes the value of Global_Vars.Angle:
    -- * current value: deg -> set to rad
    -- * current value: rad -> set to grad
    -- * current value: grad -> set to deg
    -- @param Button the caller Gtk.Button
    
    procedure Sqrt(Button: access Gtk.Button.Gtk_Button_Record'Class);
    -- This procedures calls Enter(null) if the Input_Number
    -- is not void, then takes the last (X) element from the memory stack, 
    -- computes its square root and then the result is saved in 
    -- the memory stack
    -- @param Button the caller Gtk.Button
    
    procedure YeX(Button: access Gtk.Button.Gtk_Button_Record'Class);
    -- This procedures calls Enter(null) if the Input_Number
    -- is not void, then takes the last (X) and penultimate (Y) elements
    -- from the memory stack, computes Y^X and then the result is saved in 
    -- the memory stack
    -- @param Button the caller Gtk.Button

    procedure Exponential(Button: access Gtk.Button.Gtk_Button_Record'Class);
    -- This procedures calls Enter(null) if the Input_Number
    -- is not void, then takes the last (X) element from the memory stack, 
    -- computes e^X and then the result is saved in the memory stack
    -- @param Button the caller Gtk.Button
    
    procedure Log(Button: access Gtk.Button.Gtk_Button_Record'Class);
    -- This procedures calls Enter(null) if the Input_Number
    -- is not void, then takes the last (X) element from the memory stack, 
    -- computes ln(X) and then the result is saved in the memory stack
    -- @param Button the caller Gtk.Button
    --
    procedure Factorial(Button: access Gtk.Button.Gtk_Button_Record'Class);
    -- This procedures calls Enter(null) if the Input_Number
    -- is not void, then takes the last (X) element from the memory stack and
    -- checks if X is an integer number. If X is not an integer nothing is
    -- done, otherwise the procedure computes X! and saves the result 
    -- in the memory stack
    -- @param Button the caller Gtk.Button
    
    procedure Pi(Button: access Gtk.Button.Gtk_Button_Record'Class);
    -- This procedure add a number with the value of pi to the memory stack
    -- @param Button the caller Gtk.Button
    
end Components;
