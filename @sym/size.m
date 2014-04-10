function d = size(x)

  cmd = [ 'def fcn(_ins):\n'  ...
          '    x = _ins[0]\n'  ...
          '    #sys.stderr.write("pydb: size of " + str(x) + "\\n")\n'  ...  
          '    if x.is_Matrix:\n'  ...
          '        d = x.shape\n'  ...
          '    else:\n'  ...    
          '        d = (1,1)\n'  ...
          '    #sys.stderr.write("pydb: size of " + str(x) + " is " + str(d) + "\\n")\n'  ...      
          '    return (d[0],d[1],)\n' ];

  % do we need raw here?  todo: w/o size is called recursively?
  A = python_sympy_cmd_raw(cmd, x);
  d = [str2double(A{1}) str2double(A{3})];
