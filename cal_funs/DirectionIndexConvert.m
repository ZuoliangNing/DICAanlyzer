function val = DirectionIndexConvert(ind,AxialRatio,ConvertMethod)
% convert a set of indices of crystal orientation
% from four-index into three-index
% ind ( N*4 )
switch ConvertMethod
    case 'OIM'
        val = [ 3*ind(:,1)/2 , ...
                sqrt(3)/2*( ind(:,1) + 2*ind(:,2) ), ...
                ind(:,4)*AxialRatio ];
    case 'CHANNEL5'
        val = [ ( 2*ind(:,1) + ind(:,2) )*sqrt(3)/2 , ...
                 3*ind(:,2)/2 , ...
                 ind(:,4)*AxialRatio ];
end
val = ( val./vecnorm(val,2,2) )';
end