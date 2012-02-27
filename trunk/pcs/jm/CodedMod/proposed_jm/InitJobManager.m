  function JobManagerParam = InitJobManager(obj,cfgRootIn)
            % Initialize job manager's parameters in JobManagerParam structure.
            %
            % Calling syntax: JobManagerParam = InitJobManager([cfgRootIn])
            % JobManagerParam fields:
            %       HomeRoot,Check4NewUserPeriod,LogFileName,vqFlag,MaxTimes.
            %
            % Version 1, 02/07/2011, Terry Ferrett.
            % Version 2, 01/11/2012, Mohammad Fanaei.
            % Version 3, 02/13/2012, Mohammad Fanaei.
            
            % Named constants.
            
            
            
            if( nargin<1 || isempty(cfgRootIn) )
                if ispc
                    cfgRoot = fullfile(pwd,'cfg');
                else
                    cfgRoot = fullfile(filesep,'home','pcs','jm','CodedMod','cfg');
                end
            else
                cfgRoot = cfgRootIn;
            end
            CFG_Filename = 'CodedModJobManager_cfg.txt';
            
            % Find CFG_Filename file, i.e. job manager's configuration file.
            cfgFile = fullfile(cfgRoot, CFG_Filename);
            cfgFileDir = dir(cfgFile);
            
            if( ~isempty(cfgFileDir) )
                heading1 = '[GeneralSpec]';
                
                % Read root directory in which the job manager looks for users of the system.
                key = 'HomeRoot';
                out = fp(cfgFile, heading1, key);
                %JobManagerParam.HomeRoot = eval(out);
                obj.HomeRoot = eval(out);
                
                % Read period by which the job manager looks for newly-added users to the system.
                key = 'Check4NewUserPeriod';
                out = fp(cfgFile, heading1, key);
                %JobManagerParam.Check4NewUserPeriod = str2num(out);
                obj.Check4NewUserPeriod = str2num(out);
                
                heading2 = '[LogSpec]';
                
                % Read job manager log filename.
                key = 'LogFileName';
                out = fp(cfgFile, heading2, key);
                %JobManagerParam.LogFileName = eval(out);
                obj.LogFileName = eval(out);
                
                % Read verbose/quiet mode of intermediate message logging.
                key = 'vqFlag';
                out = fp(cfgFile, heading2, key);
                %JobManagerParam.vqFlag = str2num(out);
                obj.vqFlag = str2num(out);
                      
                heading3 = '[eTimeTrialSpec]';
                
                % Read maximum number of recent trial numbers and processing times of each worker node saved for billing purposes.
                key = 'MaxTimes';
                out = fp(cfgFile, heading3, key);
                %JobManagerParam.MaxTimes = str2num(out);
                obj.MaxTimes = str2num(out);
            else
                if ispc, obj.HomeRoot = pwd;
                else obj.HomeRoot = [filesep 'home'];
                end
                obj.Check4NewUserPeriod = 50;
                % JobManagerParam.LogFileName = fullfile(filesep,'rhome','pcs','jm','CodedMod','log','CodedModJMLog.log');
                obj.LogFileName = 0;
                obj.vqFlag = 0;
                obj.MaxTimes = 20;
            end
            
            
            
            
        end
        