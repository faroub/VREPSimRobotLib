classdef pidController < handle


    properties (Access = private)
        integralSum % intergral value
        error_o % old error value
        kp %  proportional gain
        ki % integral gain
        kd % derivative gain
        stepTime % simulation step time
        max % max pid output
        min % min pid output       
    end
    
    methods  (Access = public)
        
        function obj = pidController(varargin) 
            
            arg = {1 0 0 0.02 100 -100}; 
            arg(1:nargin) = varargin(1:nargin);
            obj.kp = checkParameterData(obj, 'kp', arg{1});
            obj.ki = checkParameterData(obj, 'ki', arg{2});
            obj.kd = checkParameterData(obj, 'kd', arg{3});
            obj.stepTime = checkParameterData(obj, 'stepTime', arg{4});
            obj.max = checkParameterData(obj, 'max', arg{5});
            obj.min = checkParameterData(obj, 'min', arg{6});    
                                                                   
            % initialize properties
            obj.integralSum = 0;
            obj.error_o = 0;

        end
        
        function out = compute(obj,error) 
            
            if nargin == 1
                error = 0;
            end
            
            % proportional term
            pout = obj.kp * error;

            % integral term            
            obj.integralSum = obj.integralSum + error * obj.stepTime;
            iout = obj.ki * obj.integralSum;

            % derivative term
            dout = obj.kd * (error-obj.error_o)/obj.stepTime;
            obj.error_o = error;
            
            controlSignal = pout + iout + dout;
    
            out =checkLimits(obj, controlSignal);
      
        
        end
    
    
    
    end
    
    methods  (Access = private)
    
        function out = checkParameterData(~, type, arg) 
                       
                X = [type,' set to ',num2str(arg)];
                disp(X)   
                out=arg;
                
        end
    
        function out = checkLimits(obj, controlSignal) 
                       
            if controlSignal>obj.max                
                out = obj.max;
            elseif controlSignal<obj.min            
                out = obj.min;
            else
                out = controlSignal;
            end
                
        end
    
    
    end


end

