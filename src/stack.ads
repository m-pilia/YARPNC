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
    type T is private; -- type of the node content
    Null_Value: T; -- default value returned by Pop_Node when the stack is empty
--
-- @summary
-- Implementation of a stack
--
-- @description
-- Implementation of a stack of a generic type with a default value returned 
-- when the stack is empty 
package Stack is
    type Node;
    type Node_Ptr is access Node;

    -- The stack type
    -- @field Root access to the last node in the stack
    -- @field Size an integer containing the actual number of nodes in the stack
    type Stack is 
        record
            Root: Node_Ptr := null;
            Size: Integer := 0;
        end record;

    -- The node type
    -- @field Next access to the next node in the stack
    -- @field Prev access to the previous node in the stack
    -- @field Content content of the current node
    type Node is
        record
            Next: Node_Ptr := null;
            Prev: Node_Ptr := null;
            Content: T;
        end record;

    -- An iterator for the stack
    -- @field Stack the stack to be iterated
    -- @field Pos an Integer containing the current position of the iterator
    --   in the stack
    type Iterator is
        record
            S: Stack;
            Pos: Integer := 0;
        end record;

    -- procedure to free a node, deallocating memory
    procedure Free_Node is new Ada.Unchecked_Deallocation 
        (Object => Node, Name => Node_Ptr);

    -- Procedure to add to the stack a Node of value T
    -- @param S stack to add the node to
    -- @param Content the value for the new node content
    procedure Push_Node(S: in out Stack; Content: in T);

    -- This function removes the last node from the stack, returning its 
    -- content; if the stack is empty, the Null_Value is returned 
    -- @param S stack to remove the node from
    -- @return the value of the last node, if any node present; 
    --   Null_Value otherwise
    function Pop_Node(S: in out Stack) return T;

    -- Remove all nodes from the stack
    -- @param S stack to be cleaned
    procedure Clear(S: in out Stack);
    
    -- Return an Iterator for the stack
    -- @param S stack to be itarated
    -- @return an iterator for S, pointing to the last node of S
    function Get_Iterator(S: Stack) return Iterator;

    -- Return the content of the node in the current position of I, and then 
    -- advance the position of the iterator
    -- @param I the iterator for the stack
    -- @return the value of the node at the current iterator position
    function Next_Node(I: in out Iterator) return T;
end Stack;
