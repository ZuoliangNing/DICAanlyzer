function UIAxesDisplayIndependentMenuSelectedFcn( ~, ~, app )


IndependentDisplay_UIFigure_size = [ 800,600 ];

AXE = app.UIFigure.CurrentObject;
if ~isa( AXE, 'matlab.ui.control.UIAxes' )
    AXE = AXE.Parent;
end

DisplayNames = app.OtherDisplayNames( app.Default.LanguageSelection );

dlg = uiprogressdlg( app.UIFigure, 'Indeterminate', 'on' );
dlg.Title = DisplayNames.cm_UIAxesDisplay2;
dlg.Message = DisplayNames.cm_UIAxesDisplay_Message;

Figure = figure( ...
    'Name', '', ...
    'NumberTitle', 'off', ...
    'CloseRequestFcn', @ FigureCloseRequestFcn );
%     'MenuBar', 'none', ...
Figure.Position = getMiddlePosition( app.UIFigure.Position, ...
    IndependentDisplay_UIFigure_size );


axe = copy( AXE, Figure );
ind = ~[axe.Children.Visible];
delete( axe.Children(ind) )
axe.FontName = 'Times New Roman';
axe.FontSize = 22;
axe.Units = 'normalized';

switch AXE.Parent.Parent.Tag
    case {'1','2'}

        NodeDisplayNames = app.TreeNodeTypes( app.Default.LanguageSelection );
        try
            Image = AXE.Children(end);
            ProjectIndex = getProjectIndex( Image.UserData.Serial, app );
        catch
            Image = AXE.Children(end-1);
            ProjectIndex = getProjectIndex( Image.UserData.Serial, app );
        end
        obj = app.Projects( ProjectIndex );
        if isfield( Image.UserData, 'EBSDSerial' )
            Name = [ obj.DisplayName,' / ', NodeDisplayNames.EBSD, ' / ', ...
                obj.EBSD.Data( getEBSDIndex( Image.UserData.EBSDSerial, obj ) ).DisplayName, ...
                ' / ', Image.UserData.Type ];
        else
            Name = [ obj.DisplayName,' / ', ...
                NodeDisplayNames.DIC, ' / ',Image.UserData.Type ];
        end
        Figure.Name = Name;
        Padding = 0.01;
        if ishandle( app.StyleUIs.UIFigure )
            colorbar( axe, 'FontSize', 14 )
            axe.Position = [ Padding, Padding, 1-4*Padding, 1-2*Padding ] ;
        else
            axe.Position = [ Padding, Padding, 1-2*Padding, 1-2*Padding ] ;
        end

    case {'3','4'}

        Figure.Name = AXE.Parent.Parent.Title;
        Padding = 0.07;
        axe.Position = [ Padding, Padding, 1-2*Padding, 1-2*Padding ] ;
        legend( axe )
        axe.XLim = AXE.XLim;
        axe.YLim = AXE.YLim;
end


close( dlg )


app.DisplayIndependentFlag = true;
app.DisplayIndependentFigure = Figure;




    function FigureCloseRequestFcn( fig, ~ )

        app.DisplayIndependentFlag = false;

        delete( fig )

    end

end