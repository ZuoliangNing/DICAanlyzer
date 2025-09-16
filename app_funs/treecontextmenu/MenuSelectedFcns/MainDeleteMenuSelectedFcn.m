function MainDeleteMenuSelectedFcn(menu,~,app)

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );

n = length( menu.Parent.UserData.Serial );

% ---------- Creat uiconfirm ----------
if n == 1

    ProjectIndex = getProjectIndex( menu.Parent.UserData.Serial, app );
    msg = [ DisplayNames.DeleteMenuSelectedFcn_uiconfirm_msg, ...
        app.Projects(ProjectIndex).DisplayName, '?' ];

else

    ProjectIndex = arrayfun( @(n) ...
        getProjectIndex( n, app ), menu.Parent.UserData.Serial );
    msg = [ DisplayNames.DeleteMenuSelectedFcn_uiconfirm_msg, ...
        num2str(n), ...
        DisplayNames.DeleteMenuSelectedFcn_uiconfirm_msg2, '?' ];
end

title = DisplayNames.cm_Delete;
selection = uiconfirm( app.UIFigure, msg, title, ...
           'Options', { DisplayNames.uiopt_yes, DisplayNames.uiopt_no }, ...
           'DefaultOption', 2 );
if strcmp( selection, DisplayNames.uiopt_no ); return; end
% ------------------------------

arrayfun( @ delete, app.Projects( ProjectIndex ) );
% app.Projects( ProjectIndex ) = ...
%     arrayfun( @ delete, app.Projects( ProjectIndex ) );

app.Projects( ProjectIndex ) = [];

deleteAllImages( app )
TreeSelectionChangedFcn( app.Tree, [], app )

% deleteCurrentDICImage( app )
% if ishandle(app.CurrentImage2); delete(app.CurrentImage2); end