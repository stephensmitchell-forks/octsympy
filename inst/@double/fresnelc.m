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
%% @defun fresnelc (@var{x})
%% Numerical fresnelc function.
%%
%% Example:
%% @example
%% @group
%% fresnelc (1.1)
%%   @result{} ans = 0.76381
%% @end group
%% @end example
%%
%% @strong{Note} this function may be slow for large numbers of inputs.
%% This is because it is not a native double-precision implementation
%% but rather the numerical evaluation of the SymPy function
%% @code{fresnelc}.
%%
%% Note: this file is autogenerated: if you want to edit it, you might
%% want to make changes to 'generate_functions.py' instead.
%%
%% @seealso{@@sym/fresnelc}
%% @end defun


function y = fresnelc (x)
  if (nargin ~= 1)
    print_usage ();
  end
  cmd = { 'L = _ins[0]'
          'A = [complex(fresnelc(complex(x))) for x in L]'
          'return A,' };
  c = python_cmd (cmd, num2cell(x(:)));
  assert (numel (c) == numel (x))
  y = x;
  for i = 1:numel (c)
    y(i) = c{i};
  end
end


%!test
%! x = 1.1;
%! y = sym(11)/10;
%! A = fresnelc (x);
%! B = double (fresnelc (y));
%! assert (A, B, -4*eps);

%!test
%! y = [2 3 sym(pi); exp(sym(1)) 5 6];
%! x = double (y);
%! A = fresnelc (x);
%! B = double (fresnelc (y));
%! assert (A, B, -4*eps);

%!test
%! % maple:
%! % > A := [1+2*I, -2 + 5*I, 100, 10*I, -1e-4 + 1e-6*I, -20 + I];
%! % > for a in A do evalf(FresnelC(a)) end do;
%! x = [1+2i; -2+5i; 100; 10i; -1e-4 + 1e-6*1i; -20-1i];
%! A = [  16.087871374125480424 - 36.225687992881650217*1i
%!        0.47688568479874574722e12  + 0.12213736710985573216e13*1i
%!        0.49999989867881789756
%!        0.49989869420551572361*1i
%!       -0.000099999999999999997535 + 0.99999999999999987665e-6*1i
%!        0.15391592966931193100e26  - 0.75738824160998910388e24*1i ];
%! B = fresnelc (x);
%! assert (A, B, -eps)
