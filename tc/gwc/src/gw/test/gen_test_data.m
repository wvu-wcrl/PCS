% gen_test_data.m
%
% create an example input structure for the code loaded by the test 
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.



InputParam.nnums = 10;                                        % generate 10 uniform random variates
FunctionPath = '/rhome/tferrett/cml2/iscml/wvu_pcs/wc/gw/test/'; % path to entry function
FunctionName = 'test';                                               % entry function

TaskParam.TaskParam = InputParam; % load input struct
TaskParam.FunctionPath = FunctionPath;
TaskParam.FunctionName = FunctionName;



save('test_task_1.mat', 'TaskParam');



%     This library is free software;
%     you can redistribute it and/or modify it under the terms of
%     the GNU Lesser General Public License as published by the
%     Free Software Foundation; either version 2.1 of the License,
%     or (at your option) any later version.
%
%     This library is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%     Lesser General Public License for more details.
%
%     You should have received a copy of the GNU Lesser General Public
%     License along with this library; if not, write to the Free Software
%     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
