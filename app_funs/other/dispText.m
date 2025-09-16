function dispText( TextArea, NewText )


TextArea.Value = vertcat( TextArea.Value, {NewText} );

scroll( TextArea, 'bottom' );