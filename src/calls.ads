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
with Gdk.Event;
with Glib; use Glib;
with Gtk.Button;
with Gtk.Handlers;
with Gtk.Widget;

-- @summary
-- Procedures and functions called by the main program
--
-- @description
-- This package contains various procedures and functions called by the
-- graphical interface and the main program core
package Calls is
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
	
	procedure Sign(Button: access Gtk.Button.Gtk_Button_Record'Class);
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
	
	procedure Angle_Type(Button: access Gtk.Button.Gtk_Button_Record'Class);
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
	
end Calls;
