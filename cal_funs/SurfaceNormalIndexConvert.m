function val = SurfaceNormalIndexConvert(ind,AxialRatio,ConvertMethod)
% convert a set of indices of crystal face 
% from four-index into three-index
switch ConvertMethod
    case 'OIM'
        val = [ sqrt(3)*ind(:,1) , ...
                ind(:,1) + 2*ind(:,2) , ...
                sqrt(3)*ind(:,4)*(1/AxialRatio) ];
    case 'CHANNEL5'
        val = [ 2*ind(:,1) + ind(:,2) , ...
                sqrt(3)*ind(:,2) , ...
                sqrt(3)*ind(:,4)*(1/AxialRatio) ];
end
val = ( val./vecnorm(val,2,2) )'; % ( 3*m )
end