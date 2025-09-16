function clearAllGraphicObjects( app )


arrayfun( @(sr) delete( sr.GraphicObject ), [ app.Projects.StatisticResults ] )
