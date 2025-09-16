function refreshCLimSlider( CLimSlider, CLim )


CLimSlider.Limits = CLim;
maxval = CLim(2);
minval = CLim(1);

N = ceil( log10( maxval - minval ) );

CLimSlider.Step = ....
    round( ( maxval - minval ) / 1000, -(N-4) );

CLimSlider.Value = CLimSlider.Limits;

temp = round( linspace( minval, maxval, 5 ), -(N-2) );
CLimSlider.MajorTicks = temp;

CLimSlider.MinorTicks = cell2mat( arrayfun( ...
    @(i) linspace( temp(i), temp(i+1), 5 ), ...
    1:length(temp)-1, 'UniformOutput', false ));

% CLimSliderValueChangedFcn( app.CLimSlider, [], app )