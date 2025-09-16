function ProjectNewMenuSelectedFcn(~,~,app)

Name = [ app.TreeNodeTypes( app.Default.LanguageSelection ).Main, ...
        '-', num2str( app.Serial + 1 ) ];

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );

% ---------- Creat inputdlg ----------
answer = inputdlg( DisplayNames.ProjectNewMenuSelectedFcn_prompt, ...
    DisplayNames.cm_New, [1 35], {Name} );
if isempty(answer); return; end
% ------------------------------------

DICInstance( answer{1}, app );