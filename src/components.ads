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
with Gtk.Handlers;
with Gtk.Widget;
with List;
with Stack;

-- @summary
-- Various types
-- 
-- @description
-- This package collects the definition of some types used in various places
-- in the project
package Components is
	-- the floating point type used in the calculator
	type My_Float is digits 18; 
	
	-- a string of 1 character
	type Digit_String is new String (1..1);
	
	-- access to Digit_String
	type Digit_String_Access is access all Digit_String;
	
	-- a string of 1 character
	type Sign is new String (1..1); -- ("+", "-")
	
	-- a list of Digit_String type
	package List_Of_Digits is new List (Digit_String);
	
	-- a stack of My_Float type with null value set to 0.0
	package Stack_Of_Floats is new Stack (My_Float, 0.0);
	
	-- instantiation of Ada.Text_IO.Float_IO
	package IO is new Ada.Text_IO.Float_IO (My_Float);
	
	-- instantiation of Ada.Numerics.Generic_Elementary_Functions
	package Math is new Ada.Numerics.Generic_Elementary_Functions(My_Float);
	
	-- a type defining a part (integer part, decimal part, exponent part)
	-- of the input number
	-- @value Int_Part indicates the current part accepting input is integer
	-- @value Decimal_Part the current part accepting input is decimal
	-- @value Exponent_Part the current part accepting input is exponent
	type Number_Part is (Int_Part, Decimal_Part, Exponent_Part);

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
	
	-- a procedure to reset the input number
	-- @param D the Input_Number to be resetted
	procedure Input_Number_Reset(D: in out Input_Number_Type);
	
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
	
end Components;
