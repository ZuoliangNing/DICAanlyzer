function ProjectOpenMenuSelectedFcn(~,~,app)


DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );
% ------ SELECT FILES ------

[ Files, path ] = uigetfile( ...
    [ app.Default.Path.ProjectOpen, '*.mat' ], ...
    DisplayNames.ProjectOpen_Text, ...
    'MultiSelect', 'on' );
if ~path; return; end
app.Default.Path.ProjectOpen = path;
if ~iscell( Files ); Files = {Files}; end

dlg = uiprogressdlg( app.UIFigure );
dlg.Title = DisplayNames.ProjectOpen_Text;
n = length(Files); val1 = 1/n; val2 = val1/2;

for i = 1:n
    dlg.Value = i*val1 - val2;
    dlg.Message = [ DisplayNames.ProjectOpen_dlg, ...
        Files{i}, '...' ];
    DICInstance.load( [path, Files{i}], app )
end


