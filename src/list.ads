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

with Ada.Unchecked_Deallocation;

generic
	type T is private;
-- @summary
-- Implementation of a double linked list
--
-- @description
-- Implementation of a double linked list of generic type.
package List is
	type Node;
	type Node_Ptr is access Node;

	-- The list type
	-- @field Root access to the first node of the list
	-- @field Size integer equal to the number of nodes currently in the list
	type List is 
		record
			Root: Node_Ptr := null;
			Size: Integer := 0;
		end record;

	-- The node type
	-- @field Next access to the next node in the list
	-- @field Prev access to the previous node in the list
	-- @field Content the content of the node
	type Node is
		record
			Next: Node_Ptr := null;
			Prev: Node_Ptr := null;
			Content: T;
		end record;

	-- An iterator for the list type
	-- @field Lis list to be iterated
	-- @field Pos current position in the list
	type Iterator is
		record
			Lis: List;
			Pos: Integer := 0;
		end record;

	-- Procedure to free the memory deallocating a node
	procedure Free_Node is new Ada.Unchecked_Deallocation 
		(Object => Node, Name => Node_Ptr);

	-- This procedure creates a new node at the botttom of the list,
	-- containing the value T
	-- @param L list hosting the new node
	-- @param Content the value for the new node content
	procedure Push_Node(L: in out List; Content: in T);

	-- This function removes the first node and return its content
	-- @param L list to remove the node from
	-- @return the value of the removed node's content
	function Pop_Node(L: in out List) return T;
	
	-- This function return a new iterator for a list. The iterator is set 
	-- to the first node of the list
	-- @param L list to be iterated
	-- @return iterator for L
	function Get_Iterator(L: List) return Iterator;

	-- This function return the value of the node at the current iterator's 
	-- position (without remove the node from the list) and then the iterator's
	-- position along the list is incremented by one
	-- @param I iterator for the list
	-- @return value of the node at the current position of the iterator
	function Next_Node(I: in out Iterator) return T;
end List;
