classdef al_colors
    %AL_COLORS This class definition file specifies the 
    % properties and methods of a colors object
    %
    %   A color object contains color parameters in RGB.
    
    % Properties of the colors object
    % -------------------------------
    
    % Todo: Make sure that really all colors are part of this class.
    
    properties
        
        gold
        blue
        silver
        green
        black
        
    end
    
    % Methods of the colors object
    % ----------------------------
    
    methods
        
        function colorsobj = al_colors()
            % COLORSOBJ This function creates a colors object of
            % class al_colors
          
            colorsobj.gold = [255, 215, 0];
            colorsobj.blue = [122,96,215];
            colorsobj.silver = [160, 160, 160];
            colorsobj.green = [169, 227, 153];
            colorsobj.black = [0 0 0];
            
        end
    end
end



