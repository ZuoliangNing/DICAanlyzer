function MainRenameMenuSelectedFcn(menu,~,app)


ProjectIndex = getProjectIndex( menu.Parent.UserData.Serial, app );
obj = app.Projects( ProjectIndex );

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );

% ---------- Creat inputdlg ----------
answer = inputdlg( DisplayNames.RenameMenuSelectedFcn_prompt, ...
    DisplayNames.cm_Rename, [1 35], {obj.DisplayName} );
if isempty(answer); return; end
% ------------------------------------

obj.DisplayName = answer{1};
obj.TreeNodes.Main.Text = obj.DisplayName;
obj.Tree2Nodes.Main.Text = obj.DisplayName;

app.Projects( ProjectIndex ) = obj;