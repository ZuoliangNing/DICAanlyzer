function setStyleUIsEnable( app, opt )


if ~ishandle( app.StyleUIs.UIFigure ); return; end

app.StyleUIs.CLimPanel.Enable = opt;
app.StyleUIs.CMapDropDown.Enable = opt;
app.StyleUIs.CMapLabel.Enable = opt;
app.StyleUIs.ColorBar.Visible = opt;