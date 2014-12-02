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

with Components; use Components;
with Gtk.Alignment;
with Gtk.Button;
with Gtk.Label;

-- @summary
-- Global types and variables
--
-- @description
-- This package defines some types and variables globally needed in the project.
package Global_Vars is

    -- number of numeric displays
    Display_Number: constant Integer := 6;
    -- length (in characters) of each numeric display
    Display_Length: constant Integer := 30;
    -- maximum number length (digits number) without exponential notation
    Max_Without_Exp: constant Integer := 6;
    
    -- array of Gtk.Alignment
    type Align_Array is array (Integer range <>) of Gtk.Alignment.Gtk_Alignment;
    -- array of Gtk.Label
    type Display_Array is array (Integer range <>) of Gtk.Label.Gtk_Label;
    -- array of Gtk.Buttons
    type Button_Array is array (Integer range <>) of Gtk.Button.Gtk_Button;

    -- array of Gtk.Alignment designed to contain numeric displays
    Display_Align: Align_Array (1 .. Display_Number);
    -- array of numeric displays (each is a Gtk.Label)
    Display: Display_Array (1 .. Display_Number);

    -- labels for the digit keys
    Digit_Labels: array (Integer range 0..9) of aliased Digit_String := (
            "0", "1", "2", "3", "4", "5", "6", "7", "8", "9");
    -- array type of 1-character strings
    type String_Array is array (Integer range <>) of aliased String(1..1);

    -- record containing current digits during input
    -- the record is flushed when enter is pressed
    Input_Number: aliased Components.Input_Number_Type;

    -- stack representing the calc memory
    -- contains the numbers in memory
    Memory_Stack: Components.Stack_Of_Floats.Stack;

    -- array of Gtk.Buttons conaining the buttons for functions
    Function_Buttons: Button_Array (1..18);

    -- flag to commute between trigonometric and hyperbolic functions
    -- True: hyperbolic functions in use
    -- False: trigonometric function in use
    Hyp_State: Boolean := False;
    
    -- flag to commute trigonometric/hyperbolic function inversion
    -- True: inverse functions in use
    -- False: direct functions in use
    Inv_State: Boolean := False;
    
    -- Type defining the possible angle measuer unit
    -- @value Deg degrees
    -- @value Rad radiants
    -- @value Grad centesimal
    type Angle_Type is (Deg, Rad, Grad);

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
    
end Global_Vars;
