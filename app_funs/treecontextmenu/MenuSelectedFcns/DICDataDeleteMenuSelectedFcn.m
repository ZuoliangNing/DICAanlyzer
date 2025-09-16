function DICDataDeleteMenuSelectedFcn( menu, ~, app )

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );

ProjectIndex = getProjectIndex( menu.Parent.UserData.Serial, app );
obj = app.Projects( ProjectIndex );

node = app.UIFigure.CurrentObject;
VariableName = node.UserData.VariableName;

msg = [ DisplayNames.DeleteMenuSelectedFcn_uiconfirm_msg, ...
        ' ', node.Text, '?' ];
title = DisplayNames.cm_Delete;
selection = uiconfirm( app.UIFigure, msg, title, ...
           'Options', { DisplayNames.uiopt_yes, DisplayNames.uiopt_no }, ...
           'DefaultOption', 2 );
if strcmp( selection, DisplayNames.uiopt_no ); return; end
% ------------------------------

obj.DIC.Data = rmfield( obj.DIC.Data, VariableName );
obj.DIC.CLim = rmfield( obj.DIC.CLim, VariableName );
obj.DIC.CLimCoeff = rmfield( obj.DIC.CLimCoeff, VariableName );
obj.DIC.CLimMethod = rmfield( obj.DIC.CLimMethod, VariableName );
obj.TreeNodes.DICData = rmfield( obj.TreeNodes.DICData, VariableName );

DIC = obj.DIC;
S = whos('DIC');
obj.DIC.MemorySize = S.bytes * 1e-6;

app.Projects( ProjectIndex ) = obj;

delete( node )