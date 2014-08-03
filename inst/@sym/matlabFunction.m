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
%% @deftypefn  {Function File} {@var{g} =} matlabFunction (@var{f})
%% @deftypefnx {Function File} {@var{g} =} matlabFunction (@var{f1}, ..., @var{fn})
%% @deftypefnx {Function File} {@var{g} =} matlabFunction (..., @var{param}, @var{value})
%% @deftypefnx {Function File} {@var{g} =} matlabFunction (..., 'vars', [@var{x} ... @var{z}])
%% @deftypefnx {Function File} {...} matlabFunction (..., 'file', @var{name})
%% @deftypefnx {Function File} {...} matlabFunction (..., 'outputs', [@var{o1} ... @var{on}])
%% Convert symbolic expression into a standard function.
%%
%% This can make anonymous functions from symbolic expressions:
%% @example
%% syms x y
%% f = x^2 + sin(y)
%% h = matlabFunction(f)
%% % output: h = @@(x,y) x.^2 + sin(y)
%% @end example
%% The order and number of inputs can be specified:
%% @example
%% syms x y
%% f = x^2 + sin(y)
%% h = matlabFunction(f, 'vars', [z y x])
%% % output: h = @@(z,y,x) x.^2 + sin(y)
%% @end example
%%
%% The name @code{matlabFunction} is for compatibility with the
%% Symbolic Math Toolbox in Matlab.
%%
%% OctSymPy can also generate an @code{.m} file from symbolic
%% expression:
%% @example
%% h = matlabFunction(f, 'file', 'myfcn')
%% % creates a file called myfcn.m and returns a handle
%% @end example
%% Passing an empty filename creates an anonymous function:
%% @example
%% h = matlabFunction(f, 'vars', [z y x], 'file', '')
%% @end example
%%
%% FIXME: naming outputs with @var{PARAM} as
%% 'outputs' not implemented.
%%
%% FIXME: does not ``optimize'' code, for example, using common
%% subexpression elimination.
%%
%% As of August 2014, the feature relies on code generation
%% features no yet committed to SymPy.  The workaround only works
%% for very simple expressions where the sympy function name is the
%% same as the Octave one.  Polynomials and trig functions are ok.
%%
%% @seealso{ccode, fortran, latex}
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function f = matlabFunction(varargin)

  [flg, meh] = codegen(varargin{:}, 'lang', 'octave');
  assert(flg == -1);
  [Nin, inputs, inputstr, Nout, param] = deal(meh{:});


  %% Outputs
  if (param.codegen) && (~isempty(param.fname))
    cmd = [ '(expr,fcnname,filename,showhdr,in_vars) = _ins\n' ...
            'from sympy.utilities.codegen import codegen\n' ...
            'out = codegen((fcnname,expr), "' ...
            param.lang ...
            '", filename, header=showhdr' ...
            ', argument_sequence=in_vars' ...
            ')\n' ...
            'return (out ,)\n'];

    % if filename ends with .m, do not add another
    if strcmpi(param.fname(end-1:end), '.m')
      param.fname = param.fname(1:end-2);
    end

    fname2 = param.fname; fcnname = param.fname;
    % FIXME: careful, inputs is from findsymbols not symvar, wrong
    % order?
    out = python_cmd (cmd, varargin(1:Nout), fcnname, fname2, param.show_header, inputs);
    M.name = out{1}{1};
    M.code = out{1}{2};

    [fid,msg] = fopen(M.name, 'w');
    assert(fid > -1, msg)
    fprintf(fid, '%s', M.code)
    fclose(fid);
    fprintf('Wrote file %s.\n', M.name);
    f = str2func(fcnname);

  else % output function handle

    exprstrs = {};
    for i=1:Nout
      expr = varargin{i};
      cmd = [ '(f,) = _ins\n' ...
              'try:\n' ...
              '    s = octave_code(f)\n' ...
              'except NameError, e:\n' ...
              '    return (False, str(e))\n' ...
              'return (True, s)\n'];
      [worked, codestr] = python_cmd (cmd, expr);
      %worked = false;
      if (worked)
        codestr = vectorize(codestr);
      else
        warning('Somewhat expected: SymPy has no octave codegen, working around');
        disp(codestr)
        %% As of Aug 2014, origin/master SymPy has no octave_code()
        % Instead, a crude workaround.  E.g., Abs, ceiling will fail.
        codestr = strtrim(disp(expr));
        % Matlab: ** to ^ substition.  On Octave, vectorize does this
        % automatically
        codestr = strrep(codestr, '**', '^');
        codestr = vectorize(codestr);
      end
      exprstr{i} = codestr;
    end

    if (Nout == 1)
      f = eval(sprintf('@(%s) %s', inputstr, exprstr{1}));
    else
      str = [ sprintf('@(%s) deal(', inputstr) ...
              sprintf('%s,', exprstr{:})];
      str = [str(1:end-1) ')'];
      f = eval(str);
    end
  end

  % Note: this fails in Matlab SMT too, so no need to live outside @sym
  %h = matlabFunction({x,y,z},'vars',{x y z})
end


%!shared x,y,z
%! syms x y z

%!test
%! % basic test
%! h = matlabFunction(2*x);
%! assert(isa(h, 'function_handle'))
%! assert(h(3)==6)

%!test
%! % autodetect inputs
%! h = matlabFunction(2*x*y, x+y);
%! [t1, t2] = h(3,5);
%! assert(t1 == 30 && t2 == 8)

%!test
%! % specified inputs
%! h = matlabFunction(2*x*y, 'vars', [x y]);
%! assert(h(3,5)==30)
%! h = matlabFunction(2*x*y, x+y, 'vars', [x y]);
%! [t1, t2] = h(3,5);
%! assert(t1 == 30 && t2 == 8)

%!test
%! % cell arrays for vars list
%! h = matlabFunction(2*x*y, x+y, 'vars', {x y});
%! [t1, t2] = h(3,5);
%! assert(t1 == 30 && t2 == 8)
%! h = matlabFunction(2*x*y, x+y, 'vars', {'x' 'y'});
%! [t1, t2] = h(3,5);
%! assert(t1 == 30 && t2 == 8)

%!test
%! % cell arrays specfies order, overriding symvar order
%! h = matlabFunction(x*y, 12/y, 'vars', {y x});
%! [t1, t2] = h(3, 6);
%! assert(t1 == 18 && t2 == 4)
%! h = matlabFunction(x*y, 12/y, 'vars', [y x]);
%! [t1, t2] = h(3, 6);
%! assert(t1 == 18 && t2 == 4)

%!test
%! % cell arrays specfies order, overriding symvar order
%! h = matlabFunction(x*y, 12/y, 'vars', {y x});
%! [t1, t2] = h(3, 6);
%! assert(t1 == 18 && t2 == 4)
%! h = matlabFunction(x*y, 12/y, 'vars', [y x]);
%! [t1, t2] = h(3, 6);
%! assert(t1 == 18 && t2 == 4)

%!xtest
%! % Functions with different names in Sympy.
%! % (will fail unless Sympy has Octave codegen)
%! f = abs(x);  % becomes Abs(x)
%! h = matlabFunction(f);
%! assert(h(-10) == 10)
%! f = ceil(x);
%! h = matlabFunction(f);
%! assert(h(10.1) == 11)

%!test
%! % 'file' with empty filename returns handle
%! h = matlabFunction(2*x*y, 'file', '');
%! assert(isa(h, 'function_handle'))
%! assert(h(3,5)==30)
%! h = matlabFunction(2*x*y, 'vars', {x y}, 'file', '');
%! assert(isa(h, 'function_handle'))
%! assert(h(3,5)==30)

%!xtest
%! % output to disk
%! % (will fail unless Sympy has Octave codegen)
%! f = matlabFunction(2*x*y, 2^x, 'vars', {x y z}, 'file', 'temp_test_output1');
%! assert( isa(f, 'function_handle'))
%! [a,b] = f(10,20,30);
%! assert (isnumeric (a) && isnumeric (b))
%! assert (a == 400)
%! assert (b == 1024)
%! delete('temp_test_output1.m')

%!xtest
%! % output to disk: also works with .m specified
%! % (will fail unless Sympy has Octave codegen)
%! f = matlabFunction(2*x*y, 2^x, 'vars', {x y z}, 'file', 'temp_test_output2.m');
%! assert( isa(f, 'function_handle'))
%! [a,b] = f(10,20,30);
%! assert (isnumeric (a) && isnumeric (b))
%! assert (a == 400)
%! assert (b == 1024)
%! delete('temp_test_output2.m')

%!xtest
%! % non-scalar outputs
%! % (will fail unless Sympy has Octave codegen)
%! H = [x y z];
%! M = [x y; z 16];
%! V = [x;y;z];
%! h = matlabFunction(H, M, V);
%! [t1,t2,t3] = h(1,2,3);
%! assert(isequal(t1, [1 2 3]))
%! assert(isequal(t2, [1 2; 3 16]))
%! assert(isequal(t3, [1;2;3]))

%!xtest
%! % non-scalar outputs in .m files
%! % (will fail unless Sympy has Octave codegen)
%! H = [x y z];
%! M = [x y; z 16];
%! V = [x;y;z];
%! h = matlabFunction(H, M, V, 'vars', {x y z}, 'file', 'temp_test_output3');
%! assert( isa(h, 'function_handle'))
%! [t1,t2,t3] = h(1,2,3);
%! assert(isequal(t1, [1 2 3]))
%! assert(isequal(t2, [1 2; 3 16]))
%! assert(isequal(t3, [1;2;3]))
%! delete('temp_test_output3.m')