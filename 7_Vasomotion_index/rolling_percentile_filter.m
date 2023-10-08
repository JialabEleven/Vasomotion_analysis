function [output] = rolling_percentile_filter(input,window,prc)
    if ~isvector(input)
        error('Input not one dimensional');
    end
    output = zeros(size(input));
    prc_index = round(window * prc / 100);
    
    sorted = sort(input(1:window));
    output(1:ceil(window/2)) = sorted(prc_index);
    
    for j = ceil(window/2) + 1 : length(input) - floor(window/2)
        last_point = input(j - ceil(window/2));
        last_point_index = binary_search(sorted,last_point);
        sorted = [sorted(1:last_point_index-1) sorted(last_point_index+1:end)];        
        new_point = input(j + floor(window/2));
        new_point_index = binary_search(sorted,new_point);
        sorted = [sorted(1:new_point_index) new_point sorted(new_point_index+1:end)];
        output(j) = sorted(prc_index);
    end
    
    output(length(input) - floor(window/2) + 1 : end) = sorted(prc_index);
end