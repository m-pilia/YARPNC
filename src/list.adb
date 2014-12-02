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

package body List is
    procedure Push_Node(L: in out List; Content: in T) is
        New_Node: Node_Ptr;
        O: Node_Ptr;
    begin
        New_Node := new Node;
        New_Node.Content := Content;
        if L.Root = null then
            L.Root := New_Node;
            L.Size := L.Size + 1;
            return;
        end if;
        O := Node_Ptr(L.Root);
        while O.Next /= null loop
            O := O.Next;
        end loop;
        O.Next := New_Node;
        New_Node.Prev := O;
        L.Size := L.Size + 1;
    end Push_Node;

    function Pop_Node(L: in out List) return T is
        O: Node_Ptr;
        Node_To_Remove: Node_Ptr;
        Result: T;
    begin
        -- the list has 0 items
        if L.Root = null then
            return Result;
        end if;
        O := L.Root;
        -- the list has 1 item
        if O.Next = null then
            Result := O.Content;
            Free_Node(O);
            L.Root := null;
            L.Size := L.Size - 1;
            return Result;
        end if;
        -- the list has more items
        while O.Next /= null loop
            O := O.Next;
        end loop;
        Node_To_Remove := O;
        O := O.Prev;
        O.Next := null;
        Result := Node_To_Remove.Content;
        Free_Node(Node_To_Remove);
        L.Size := L.Size - 1;
        return Result;
    end Pop_Node;

    function Get_Iterator(L: List) return Iterator is
        I: Iterator;
    begin
        I.Lis := L;
        I.Pos := 0;
        return I;
    end Get_Iterator;

    function Next_Node(I: in out Iterator) return T is
        Result: T;
        O: Node_Ptr := I.Lis.Root;
        J: Integer := 0;
    begin
        while J < I.Pos loop
            J := J + 1;
            O := O.Next;
        end loop;
        if I.Pos < I.Lis.Size then
            I.Pos := I.Pos + 1;
        end if;
        Result := O.Content;
        return Result;
    end Next_Node;
end List;
