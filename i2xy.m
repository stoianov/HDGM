% index-to-xy transformation
function xy=i2xy(i,ny)
 if size(i,1)==1, i=i'; end % If vector-row, then transpose it.
 i=single(i);
 xy = [ ceil(i./ny) rem(i-1,ny)+1 ];
end
