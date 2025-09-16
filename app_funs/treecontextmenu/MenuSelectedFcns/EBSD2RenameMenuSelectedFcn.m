function EBSD2RenameMenuSelectedFcn( menu, ~, app )

ProjectIndex = getProjectIndex( menu.Parent.UserData.Serial, app );
obj = app.Projects( ProjectIndex );

node = app.UIFigure.CurrentObject;
EBSDSerial = getEBSDIndex( node.NodeData.EBSDSerial, obj );

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );

% ---------- Creat inputdlg ----------
OldName = obj.EBSD.Data( EBSDSerial ).DisplayName;
answer = inputdlg( DisplayNames.RenameMenuSelectedFcn_prompt, ...
    DisplayNames.cm_Rename, [1 35], {OldName} );
if isempty(answer); return; end
% ------------------------------------

NewName = answer{1};
obj.EBSD.Data( EBSDSerial ).DisplayName = NewName;
node.Text = NewName;

app.Projects( ProjectIndex ) = obj;