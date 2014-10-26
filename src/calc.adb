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

with Ada.Text_IO;
with Calls;
with Components; use Components;
with Glib; use Glib;
with Global_Vars; use Global_Vars;
with Gtk.Alignment;
with Gtk.Box;
with Gtk.Button;
with Gtk.Enums; use all type Gtk.Enums.Gtk_Window_Position;
with Gtk.Frame;
with Gtk.Handlers;
with Gtk.Label;
with Gtk.Main;
with Gtk.Table;
with Gtk.Widget;
with Gtk.Window;

procedure Calc is
	Main_Window: Gtk.Window.Gtk_Window;
	type Button_Array is array (Integer range <>) of Gtk.Button.Gtk_Button;
	Digit_Buttons: Button_Array (0..9);
	Enter_Button: Gtk.Button.Gtk_Button;
	Enter_Label: constant String := "Enter";
	Dot_Button: Gtk.Button.Gtk_Button;
	Dot_Label: constant String := ".";
	Exp_Button: Gtk.Button.Gtk_Button;
	Exp_Label: constant String := "E";
	Sign_Button: Gtk.Button.Gtk_Button;
	Sign_Label: constant String := "+/-";
	Bks_Button: Gtk.Button.Gtk_Button;
	Bks_Label: constant  String := "Bks";
	Operator_Buttons: Button_Array (1..4);
	Title: constant String := "YARPNC";
	Width: constant Glib.Gint := 250;
	Height: constant Glib.Gint := 220;
	Keypad: Gtk.Table.Gtk_Table;
	Opspad: Gtk.Table.Gtk_Table;
	Funpad: Gtk.Table.Gtk_Table;
	General_Container: Gtk.Box.Gtk_Vbox;
	Pad_Container: Gtk.Box.Gtk_Hbox;
	Display_Frame: Gtk.Frame.Gtk_Frame;
	Display_Box: Gtk.Box.Gtk_Vbox;
	Operator_Labels: constant String_Array (1..4) := ("+", "-", "*", "/");
	Function_Labels: constant array (Integer range 1..18) of String (1..5) := (
		"     ", "     ", " drop", "x<->y", "lastx", "clear", --  1..6
		"sin  ", " cos ", " tan ", " hyp ", " f^-1", " rad ", --  7..12
		"sqrt ", " y^x ", " exp ", " ln  ", "  !  ", " pi  "  -- 13..18
	);
begin
	Gtk.Main.Init;
	Gtk.Window.Gtk_New(Main_Window);
	Gtk.Window.Set_Title(Main_Window, Title);
	Gtk.Window.Set_Default_Size(Main_Window, Width, Height);
	Gtk.Window.Set_Position(
		Main_Window, Win_Pos_Center);
	Handlers.Connect(
		Main_Window,
		"destroy",
		Handlers.To_Marshaller(Calls.Destroy'Access));
	Key_Handlers.Connect(
		Main_Window,
		"key_press_event",
		Key_Handlers.To_Marshaller(Calls.Keyboard_Input'Access));

	Gtk.Table.Gtk_New(Keypad, 4, 3, True);
	Gtk.Table.Gtk_New(Opspad, 2, 2, True);
	Gtk.Table.Gtk_New(Funpad, 3, 6, True);

	-- add numbers 1-9
	for i in reverse 1..9 loop
		Digit_Buttons(i) := 
			Gtk.Button.Gtk_Button_New_With_Label(String(Digit_Labels(i)));
		User_Callback_String.Connect(
			Digit_Buttons(i),
			"clicked",
			User_Callback_String.To_Marshaller(Calls.Add_Digit'Access),
			User_Data => Digit_Labels(i)'Access);
		Gtk.Table.Attach_Defaults(
			Keypad,
			Digit_Buttons(i),
			Guint((i - 1) mod 3),
			Guint((i - 1) mod 3 + 1),
			Guint((9 - i) / 3),
			Guint((9 - i) / 3 + 1));
		Gtk.Button.Show(Digit_Buttons(i));
		Gtk.Button.Set_Can_Focus(Digit_Buttons(i), False);
	end loop;
	
	-- add 0
	Gtk.Button.Gtk_New(Digit_Buttons(0), String(Digit_Labels(0)));
	Gtk.Button.Show(Digit_Buttons(0));
	Gtk.Table.Attach_Defaults(
		Keypad,
		Digit_Buttons(0),
		Guint(0),
		Guint(1),
		Guint(3),
		Guint(4));
	User_Callback_String.Connect(
		Digit_Buttons(0),
		"clicked",
		User_Callback_String.To_Marshaller(Calls.Add_Digit'Access),
		User_Data => Digit_Labels(0)'Access);
	Gtk.Button.Set_Can_Focus(Digit_Buttons(0), False);

	-- add dot
	Gtk.Button.Gtk_New(Dot_Button, Dot_Label);
	Gtk.Button.Show(Dot_Button);
	Gtk.Table.Attach_Defaults(
		Keypad,
		Dot_Button,
		Guint(1),
		Guint(2),
		Guint(3),
		Guint(4));
	Dot_Button.On_Clicked(Calls.Dot'Access);
	Gtk.Button.Set_Can_Focus(Dot_Button, False);

	-- add sign
	Gtk.Button.Gtk_New(Sign_Button, Sign_Label);
	Gtk.Button.Show(Sign_Button);
	Gtk.Table.Attach_Defaults(
		Keypad,
		Sign_Button,
		Guint(2),
		Guint(3),
		Guint(3),
		Guint(4));
	Sign_Button.On_Clicked(Calls.Sign'Access);
	Gtk.Button.Set_Can_Focus(Sign_Button, False);

	-- add enter
	Gtk.Button.Gtk_New(Enter_Button, Enter_Label);
	Gtk.Button.Show(Enter_Button);
	Gtk.Table.Attach_Defaults(
		Opspad,
		Enter_Button,
		Guint(0),
		Guint(2),
		Guint(3),
		Guint(4));
	Enter_Button.On_Clicked(Calls.Enter'Access);
	Gtk.Button.Set_Can_Focus(Enter_Button, False);

	-- add exp
	Gtk.Button.Gtk_New(Exp_Button, Exp_Label);
	Gtk.Button.Show(Exp_Button);
	Gtk.Table.Attach_Defaults(
		Opspad,
		Exp_Button,
		Guint(0),
		Guint(1),
		Guint(0),
		Guint(1));
	Exp_Button.On_Clicked(Calls.Exp'Access);
	Gtk.Button.Set_Can_Focus(Exp_Button, False);

	-- add bks
	Gtk.Button.Gtk_New(Bks_Button, Bks_Label);
	Gtk.Button.Show(Bks_Button);
	Gtk.Table.Attach_Defaults(
		Opspad,
		Bks_Button,
		Guint(1),
		Guint(2),
		Guint(0),
		Guint(1));
	Bks_Button.On_Clicked(Calls.Bks'Access);
	Gtk.Button.Set_Can_Focus(Bks_Button, False);

	-- add operators
	for i in 1..4 loop
		Gtk.Button.Gtk_New(Operator_Buttons(i), Operator_Labels(i));
		Gtk.Button.Show(Operator_Buttons(i));
		Gtk.Table.Attach_Defaults(
			Opspad,
			Operator_Buttons(i),
			Guint((i - 1) mod 2),
			Guint((i - 1) mod 2 + 1),
			Guint(2 - i / 3),
			Guint(3 - i / 3));
		Gtk.Button.Set_Can_Focus(Operator_Buttons(i), False);
	end loop;
	Operator_Buttons(1).On_Clicked(Calls.Add'Access);
	Operator_Buttons(2).On_Clicked(Calls.Sub'Access);
	Operator_Buttons(3).On_Clicked(Calls.Mol'Access);
	Operator_Buttons(4).On_Clicked(Calls.Div'Access);
	
	-- add function buttons
	for i in 1..18 loop
		Gtk.Button.Gtk_New(Function_Buttons(i), Function_Labels(i));
		Gtk.Button.Show(Function_Buttons(i));
		Gtk.Table.Attach_Defaults(
			Funpad,
			Function_Buttons(i),
			Guint((i - 1) mod 6),
			Guint((i - 1) mod 6 + 1),
			Guint((i - 1) / 6),
			Guint((i - 1) / 6 + 1));
		Gtk.Button.Set_Can_Focus(Function_Buttons(i), False);
	end loop;
	Function_Buttons(3).On_Clicked(Calls.Drop'Access);
	Function_Buttons(4).On_Clicked(Calls.Commute'Access);
	Function_Buttons(5).On_Clicked(Calls.LastX'Access);
	Function_Buttons(6).On_Clicked(Calls.Clear'Access);
	Function_Buttons(7).On_Clicked(Calls.Sin'Access);
	Function_Buttons(8).On_Clicked(Calls.Cos'Access);
	Function_Buttons(9).On_Clicked(Calls.Tan'Access);
	Function_Buttons(10).On_Clicked(Calls.Hyp'Access);
	Function_Buttons(11).On_Clicked(Calls.Inv'Access);
	Function_Buttons(12).On_Clicked(Calls.Angle_Type'Access);
	Function_Buttons(13).On_Clicked(Calls.Sqrt'Access);
	Function_Buttons(14).On_Clicked(Calls.YeX'Access);
	Function_Buttons(15).On_Clicked(Calls.Exponential'Access);
	Function_Buttons(16).On_Clicked(Calls.Log'Access);
	Function_Buttons(17).On_Clicked(Calls.Factorial'Access);
	Function_Buttons(18).On_Clicked(Calls.Pi'Access);

	Gtk.Table.Show(Keypad);
	Gtk.Table.Show(Opspad);
	Gtk.Table.Show(Funpad);

	Gtk.Box.Gtk_New_Vbox(Display_Box);
	Gtk.Box.Show(Display_Box);
	for i in 1 .. Display_Number loop
		Gtk.Alignment.Gtk_New(
			Display_Align(i),
			Gfloat(1),
			Gfloat(0.5),
			Gfloat(0),
			Gfloat(0));
		Gtk.Box.Pack_End(Display_Box, Display_Align(i));
		Gtk.Alignment.Show(Display_Align(i));
	end loop;
	for i in 1 .. Display_Number loop
		Gtk.Label.Gtk_New(Display(i), "");
		Gtk.Label.Show(Display(i));
		Gtk.Label.Set_Justify(Display(i), Gtk.Enums.Justify_Right);
		Gtk.Alignment.Add(Display_Align(i), Display(i));
	end loop;
	Gtk.Label.Set_Label(Display(1), "0");

	Gtk.Frame.Gtk_New(Display_Frame);
	Gtk.Frame.Add(Display_Frame, Display_Box);
	Gtk.Frame.Show(Display_Frame);

	Gtk.Box.Gtk_New_Hbox(Pad_Container, False, Gint(10));
	Gtk.Box.Gtk_New_Vbox(General_Container, False, Gint(20));
	Gtk.Box.Pack_Start(Pad_Container, Keypad, True, True);
	Gtk.Box.Pack_Start(Pad_Container, Opspad, True, True);
	Gtk.Box.Pack_Start(General_Container, Display_Frame, False, False);
	Gtk.Box.Pack_Start(General_Container, Funpad, False, False);
	Gtk.Box.Pack_Start(General_Container, Pad_Container, True, True);
	Gtk.Box.Show(Pad_Container);
	Gtk.Box.Show(General_Container);

	Gtk.Window.Add(Main_Window, General_Container);

	Gtk.Window.Show(Main_Window);
	Gtk.Main.Main;
end Calc;
