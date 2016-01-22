%% Copyright (C) 2016 Colin B. Macdonald
%%
%% This file is part of OctSymPy.
%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @deftypefn  {Function File}  {@var{s} =} finiteset (@var{a}, @var{b}, @dots{})
%% @deftypefnx {Function File}  {@var{e} =} finiteset ()
%% Return a set containing the inputs without duplicates.
%%
%% Example:
%% @example
%% @group
%% syms x
%% finiteset(1, pi, x, 1, 1)
%%   @result{} ans = (sym) @{1, π, x@}
%% @end group
%% @end example
%%
%% You can also use this to make the empty set:
%% @example
%% @group
%% finiteset()
%%   @result{} ans = (sym) ∅
%% @end group
%% @end example
%%
%% @seealso{interval, ismember, union, intersect, setdiff, setxor}
%% @end deftypefn

function S = finiteset(varargin)

  varargin = sym(varargin);

  S = python_cmd ('return FiniteSet(*_ins),', varargin{:});

end


%!test
%! s1 = finiteset(sym(1), 2, 2);
%! s2 = finiteset(sym(1), 2, 2, 2);
%! assert (isequal (s1, s2))

%!test
%! s1 = finiteset(sym(0), 1);
%! s2 = finiteset(sym(0), 2, 3);
%! s = finiteset(sym(0), 1, 2, 3);
%! assert (isequal (s1 + s2, s))

%!test
%! e = finiteset();
%! s = finiteset(sym(1));
%! s2 = e + s;
%! assert (isequal (s, s2))