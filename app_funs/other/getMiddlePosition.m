function position = getMiddlePosition(pos_0,pos_1)

val = (pos_0(3:4)-pos_1)./2;
position = [pos_0(1:2)+val,pos_1];