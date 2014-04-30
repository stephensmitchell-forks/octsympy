%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn {Function File} {@var{y} =} log2 (@var{x})
%% Symbolic log base 2 function.
%%
%% @seealso{log,log10}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = log2(x)

  cmd = [ '(x,) = _ins\n' ...
          'y = sp.log(x,2)\n' ...
          'return (y,)' ];

  z = python_cmd (cmd, x);

end


%!assert (isequal (log2 (sym (1024)), sym (10)))
