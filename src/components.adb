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

package body Components is
	procedure Input_Number_Reset(D: in out Input_Number_Type) is
	begin
		D.Int := (null, 0);
		D.Decimal := (null, 0);
		D.Exponent := (null, 0);
        D.Sign_Base := "+";
        D.Sign_Exp := "+";
        D.Part := Int_Part;
	end Input_Number_Reset;
end Components;
