classdef BlackWhite2D
    properties (Access = private)
        image0 % Original unmodified binary image
    end
    
    properties
        mask % Square binary mask
    end
    
    methods
        % Constructor
        function obj = BlackWhite2D(img_init, mask_init)
            if nargin < 1 || isempty(img_init)
                error('An initial binary image is required.');
            end
            obj.image0 = logical(img_init); % Ensure binary format
            
            if nargin < 2 || isempty(mask_init)
                obj.mask = [0 1 0; 1 1 1; 0 1 0]; % Default mask
            else
                obj.mask = logical(mask_init); % Use provided mask
            end
        end

        % Grow method
        function output = grow(obj, iternum, newmask)
            if nargin < 2, iternum = 1; end % Default iterations
            if nargin == 3, obj.mask = logical(newmask); end
            
            R = floor(size(obj.mask, 1) / 2); % Half-width of the mask
            padded_img = obj.customPad(obj.image0, R, 0); % Pad with zeros
            
            for iter = 1:iternum
                temp_img = padded_img; % Copy for updates
                
                for i = 1 + R:size(padded_img, 1) - R
                    for j = 1 + R:size(padded_img, 2) - R
                        sub_img = temp_img(i-R:i+R, j-R:j+R);
                        neighbors = sub_img(obj.mask > 0);
                        padded_img(i, j) = any(neighbors); % Update center pixel
                    end
                end
                
                output = padded_img(R+1:end-R, R+1:end-R); % Crop to original size
            end
        end

        % Shrink method
        function output = shrink(obj, iternum, newmask)
            if nargin < 2, iternum = 1; end % Default iterations
            if nargin == 3, obj.mask = logical(newmask); end

            R = floor(size(obj.mask, 1) / 2); % Half-width of the mask
            padded_img = obj.customPad(obj.image0, R, 1); % Pad with ones
            
            for iter = 1:iternum
                temp_img = padded_img; % Copy for updates
                
                for i = 1 + R:size(padded_img, 1) - R
                    for j = 1 + R:size(padded_img, 2) - R
                        sub_img = temp_img(i-R:i+R, j-R:j+R);
                        neighbors = sub_img(obj.mask > 0);
                        padded_img(i, j) = all(neighbors); % Update center pixel
                    end
                end
                
                output = padded_img(R+1:end-R, R+1:end-R); % Crop to original size
            end
        end

        % Custom padding function
        function padded_img = customPad(~, img, pad_size, pad_value)
            [rows, cols] = size(img);
            padded_img = pad_value * ones(rows + 2 * pad_size, cols + 2 * pad_size); % Full padded matrix
            padded_img(pad_size + 1:end - pad_size, pad_size + 1:end - pad_size) = img; % Place original image
        end
    end
end

