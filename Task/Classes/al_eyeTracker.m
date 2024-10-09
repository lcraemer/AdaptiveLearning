classdef al_eyeTracker
    %AL_EYETRACKER This class-definition file specifies the
    % properties and methods of an eye-tracker object
    %
    %   An eye-tracker object stores relevant device parameters

    % Properties of the eye-tracker object
    % ------------------------------------

    properties

        dist % viewing distance in cm
        width % physical width of the screen in cm
        height % physical height of the screen in cm
        frameDur % duration of one frame
        frameRate % in Hz
        et_file_name % current file name
        ppd % estimated pixels per degree
        resolutionX % x resolution (in pixels)
        saccThres % threshold value
        el %SMI instance
            
    end

    % Methods of the eye-tracker object
    % ---------------------------------

    methods

        function self = al_eyeTracker(display)
            % This function creates an object of
            % class al_eyeTracker
            %
            %   Input
            %       display: display-object instance
            %
            %   Output
            %       None


            self.dist = 40;
            self.width = 30;
            self.height = 21;
            self.frameDur = Screen('GetFlipInterval', display.window.onScreen);
            self.frameRate = Screen('NominalFrameRate', display.window.onScreen);
            self.saccThres = 1;
        end

        function self = initializeEyeLink(self, taskParam, et_file_name_suffix)
            % INITIALIZEEYELINK This function initialzes the eye-tracker
            % !! NOW ACTUALLY INITIALIZES SMI NOT EYELINK !! name kept for
            % easier implementation.
            %   Input
            %       taskParam: Task-parameter-object instance
            %       et_file_name_suffix: Suffix of file name
            %
            %   Output:
            %       el: Eye-link object


            self.et_file_name = sprintf('%s%s', taskParam.subject.ID, et_file_name_suffix);
            self.et_file_name = [self.et_file_name]; % todo: check if this is really necessary
            
            
            settings = SMITE.getDefaults('HiSpeed');
            settings.connectInfo    = {'192.168.1.1',4444,'192.168.1.2',5555};
            settings.doAverageEyes  = false;
            settings.cal.bgColor    = taskParam.colors.background;
            settings.freq           = 500;
%             settings.trackMode      = 'MONOCULAR';
            settings.trackEye       = 'EYE_RIGHT';
            settings.logFileName    = 'test_log.txt';
            settings.save.allowFileTransfer = false;
            
            % Todo test if we can also pass object instead instead of new structure
%             settings.dist = self.dist;
%             settings.width = self.width;
%             settings.height = self.height;
%             settings.window_rect = taskParam.display.windowRect;
%             settings.frameDur = self.frameDur;
%             settings.frameRate = self.frameRate;

            % initialize SMI
            self.el         = SMITE(settings);
            %EThndl         = EThndl.setDummyMode();
            self.el.init();
            self.el.calibrate(taskParam.display.window.onScreen, false);
            
            
            %[el, ~] = ELconfig(taskParam.display.window.onScreen, self.et_file_name, settings);
            
            % Calibrate the eye tracker
            % EyelinkDoTrackerSetup(el);
            
            

        end

        function self = estimatePixelsPerDegree(self)
            % ESTIMATEPIXELSPERDEGREE This function estimates the number of
            % pixels per degree for online saccade detection
            %
            %   Input
            %       self: eye-tracker-object instance
            %
            %   Output
            %       self: eye-tracker-object instance
            %
            % Credit: Donner lab


            o = tan(0.5*pi/180)*self.dist; % self.dist = distance from screen (cm)
            self.ppd = 2*o*self.resolutionX/self.width; % options.resolution(1) = x resolution (in pixels); self.width = width of screen (cm)

        end

        function sacc = checkSaccade(self, eye, zero)
            % CHECKSACCADE This function detects saccades online
            %
            %   Input
            %       eye: Tracked eye
            %       zero: central fixation position
            %
            %   Output
            %       sacc: Detected saccades
            %
            %   Credit: Donner lab
            
            error('this is the SMI version, no saccades implemented for now.')
            
            % Short break
            pause(0.002)

            % Extract samples from eye-link
            [samples, ~, ~] = Eyelink('GetQueuedData');
            
            % Extract relevant samples depending on tracked eye
            if eye==0
                x = (samples(14,:)-zero(1))/self.ppd;
                y = (samples(16,:)-zero(2))/self.ppd;
            else
                x = (samples(15,:)-zero(1))/self.ppd;
                y = (samples(17,:)-zero(2))/self.ppd;
            end
            
            % Compute deviation from fixation spot and categorize saccades
            d = (x.^2 + y.^2).^.5;
            a = d(2:length(d));
            if any(a>self.saccThres)
                sacc = 1;
            else 
                sacc = 0;
            end
        end
    end

    methods(Static)

        function taskParam = startRecording(taskParam)
            % STARTRECORDING This function starts the eyeLink eye-tracker
            %
            %   Input
            %       taskParam: Task-parameter-object instance
            %
            %   Output
            %       taskParam: Task-parameter-object instance
                
            
            % Eyelink('StartRecording');
            % WaitSecs(0.1);
            % Eyelink('message', 'Start recording Eyelink');
            
            taskParam.eyeTracker.el.startRecording()
%             taskParam.eyeTracker.el.startBuffer()
            WaitSecs(0.1);
            taskParam.eyeTracker.el.sendMessage('Start recording SMI');
            
            % Reference time stamp
            taskParam.timingParam.ref = GetSecs();
        end
    end
end
