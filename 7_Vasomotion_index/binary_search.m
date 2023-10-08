function index = binary_search(sorted,value)
   l = 1;
   r = length(sorted);
   while l < r
      index = 1 + floor((l + r - 1) / 2);
      if sorted(index) > value
        r = index - 1; 
      elseif sorted(index) <= value
        l = index;
      end
   end
   if l == r
      index = r; 
   end
%    if sorted(index) > value
%      index = -1;
%    end
end