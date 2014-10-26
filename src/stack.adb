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

package body Stack is
	procedure Push_Node(S: in out Stack; Content: in T) is
		New_Node: Node_Ptr;
		O: Node_Ptr;
	begin
		New_Node := new Node;
		New_Node.Content := Content;
		if S.Root = null then
			S.Root := New_Node;
			S.Size := S.Size + 1;
			return;
		end if;
		O := S.Root;
		O.Prev := New_Node;
		New_Node.Next := O;
		S.Root := New_Node;
		S.Size := S.Size + 1;
	end Push_Node;

	function Pop_Node(S: in out Stack) return T is
		O: Node_Ptr;
		Node_To_Remove: Node_Ptr;
		Result: T := Null_Value;
	begin
		if S.Root = null then
			return Result;
		end if;
		O := S.Root;
		-- 1 item
		if O.Next = null then
			Result := O.Content;
			Free_Node(O);
			S.Root := null;
			S.Size := S.Size - 1;
			return Result;
		end if;
		-- more items
		Node_To_Remove := O;
		O := O.Next;
		O.Prev := null;
		Result := Node_To_Remove.Content;
		Free_Node(Node_To_Remove);
		S.Root := O;
		S.Size := S.Size - 1;
		return Result;
	end Pop_Node;

	function Get_Iterator(S: Stack) return Iterator is
		I: Iterator;
	begin
		I.S := S;
		I.Pos := 0;
		return I;
	end Get_Iterator;

	function Next_Node(I: in out Iterator) return T is
		Result: T;
		O: Node_Ptr := I.S.Root;
		J: Integer := 0;
	begin
		while J < I.Pos loop
			J := J + 1;
			O := O.Next;
		end loop;
		if I.Pos < I.S.Size then
			I.Pos := I.Pos + 1;
		end if;
		Result := O.Content;
		return Result;
	end Next_Node;

	procedure Clear(S: in out Stack) is
		Buf: T;
	begin
		for i in 1..S.Size loop
			Buf := Pop_Node(S);
		end loop;
	end Clear;
end Stack;
