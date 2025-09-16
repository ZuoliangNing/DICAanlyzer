function visualizeAxes( axe, opt )

axe.XAxis.Visible = opt;
axe.YAxis.Visible = opt;

switch opt
    case 'on'
        axe.XTickMode = 'auto';
        axe.YTickMode = 'auto';
end
