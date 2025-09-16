function setUIControlDisplayNames(app)

% uifigure & menus & uicontrols & labels
uinames = fieldnames(app.UIControlDisplayNames);
field_names = {'Name','Text','Title'};
index = app.UIControlDisplayNamesIndex;
for j = 1:length(index)
    for i = index{j}
        name = uinames{i};
        dispname = app.UIControlDisplayNames( ...
            app.Default.LanguageSelection).(name);
        app.(name).(field_names{j}) = dispname;
    end
end

% tree nodes
arrayfun( @(obj) setNodesText( app, obj ), app.Projects )


% context menus
DisplayNames = app.OtherDisplayNames(app.Default.LanguageSelection);

structfun( @(cm) arrayfun( @(menu) ...
    set( menu, 'Text', DisplayNames.( [ 'cm_', menu.UserData ] ) ), ...
    cm.Children ), app.TreeContextMenu )

app.UIAxesContextMenu.Children(2).Text = DisplayNames.cm_UIAxesDisplay;
app.UIAxesContextMenu.Children(1).Text = DisplayNames.cm_UIAxesDisplay2;

app.Tree2ContextMenu.Children.Text = DisplayNames.cm_Delete;