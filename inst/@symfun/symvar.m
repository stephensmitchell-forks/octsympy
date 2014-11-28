%% Copyright (C) 2014 Colin B. Macdonald and others
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
%% @deftypefn {Function File} {@var{vars} =} symvar (@var{f})
%% @deftypefnx {Function File} {@var{vars} =} symvar (@var{f}, @var{n})
%% Find symbols in symfun and return them as a symbolic vector.
%%
%% If @var{n} specified, we take from the explicit function variables
%% first followed by the output of @code{symvar} on any other symbols
%% in the sym (expression) of the symfun.
%%
%% Example:
%% @example
%% syms a x f(t, s)
%% symvar (f, 1);  % t
%% symvar (f, 2);  % [t s]
%% @end example
%% Note preference for the variables of @code{f}:
%% @example
%% h = a*f + x
%% symvar (f, 1);  % t
%% symvar (f, 2);  % [t s]
%% symvar (f, 3);  % [t s x]
%% symvar (f, 4);  % [t s x a]
%% @end example
%% But:
%% @example
%% symvar (f);  % [x a s t]
%% @end example
%%
%% Compatibility with other implementations: the output should
%% match the equivalent command in the Matlab Symbolic Toolbox
%% version 2014a.  FIXME: without @var{n} not same:
%% @example
%% syms x y s t
%% f(t, s) = 1  % constant symfun
%% symvar (f, 1);  % t
%% symvar (f, 2);  % [t s]
%% symvar (f);     % [t s], SMT gives [] 
%% @end example
%%
%% If two variables have the same symbol but different assumptions,
%% they will both appear in the output.  It is not well-defined
%% in what order they appear.
%%
%% @seealso{findsym, findsymbols}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function vars = symvar(F, Nout)

  if (nargin == 1)
    warning('FIXME: symvar(symfun) differs from SMT... OK?')
    vars = symvar([F.vars{:} F.sym(:)]);

  else
    assert(Nout >= 0, 'number of requested symbols should be positive')

    M = length(F.vars);

    vars = sym([]);
    % take first few from F.vars
    for i = 1:min(Nout, M)
      vars(i) = F.vars{i};
    end

    if (Nout == length(vars))
      return
    end

    symvars = symvar(F.sym, inf);
    symvars = remove_dupes(symvars, vars);
    vars = [vars symvars(1:min(end, Nout-M))];
  end
end

function a = remove_dupes(symvars, vars)
  M = length(vars);
  % ones(1, 3, 'logical') doesn't work in Matlab
  keep = logical(ones(1, length(symvars)));
  for j = 1:length(symvars)
    for i = 1:M
      if (strcmp(char(symvars(j)), char(vars(i))))
        keep(j) = false;
        break
      end
    end
  end
  a = symvars(keep);
end


%!test
%! % basic, quotes are oct 3.6 workaround
%! syms 'f(t, s)'
%! assert (isequal (symvar (f, 0), sym([])))
%! assert (isequal (symvar (f, 1), t))
%! assert (isequal (symvar (f, 2), [t s]))
%! assert (isequal (symvar (f, 3), [t s]))

%!test
%! % note preference for vars of symfun, if n requested
%! syms x f(y)
%! assert (isequal (symvar(f*x, 1), y))
%! assert (isequal (symvar(f(y)*x, 1), x))

%!test
%! % symfun, checked smt
%! syms x f(y)
%! a = f*x;
%! b = f(y)*x;
%! assert (isequal (symvar(a), [x y]))
%! assert (isequal (symvar(b), [x y]))

%!test
%! % preference for the explicit variables
%! syms a x 'f(t, s)'
%! h = f*a + x;
%! assert (isequal (symvar (h, 1), t))
%! assert (isequal (symvar (h, 2), [t s]))
%! assert (isequal (symvar (h, 3), [t s x]))
%! assert (isequal (symvar (h, 4), [t s x a]))
%! assert (isequal (symvar (h, 5), [t s x a]))
%! assert (isequal (symvar (h), [a s t x]))

%!test
%! % symfun dep on some vars only, matches smt w/ n
%! syms x s t
%! f(s) = x;
%! g(s, t) = x*s;
%! assert (isequal (symvar(f, 1), s))
%! assert (isequal (symvar(f, 2), [s x]))
%! assert (isequal (symvar(g, 1), s))
%! assert (isequal (symvar(g, 2), [s t]))
%! assert (isequal (symvar(g, 3), [s t x]))

%!xtest
%! % symfun dep on some vars only, differs from smt w/o n
%! % FIXME: decide if we want this...
%! syms x s t
%! f(s) = x;
%! g(s, t) = x*s;
%! assert (isequal (symvar(f), x))  % no s
%! assert (isequal (symvar(g), [s x]))  % no t