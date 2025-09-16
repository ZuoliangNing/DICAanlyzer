function getDICCalculateMethods(app)

%   ---↓↓↓--- DEFINE DIC Calculate methods ---↓↓↓---

% ------------- BASIC METHODS -------------

%       --- 1 - 'EffectiveShear'
Methods.EffectiveShear.Name = ...
    { 'Effective Shear Strain', '有效剪切应变' };
Methods.EffectiveShear.Type = 'basic';

%       --- 2 - 'EquivalentStrain'
Methods.EquivalentStrain.Name = ...
    { 'Equivalent Strain', '等效应变' };
Methods.EquivalentStrain.Type = 'basic';

%       --- 3 - 'MaterialRotation'
Methods.MaterialRotation.Name = ...
    { 'Material Rotation Z', '物质旋转-Z' };
Methods.MaterialRotation.Type = 'basic';

%       --- 4 - 'ezz'
Methods.ezz.Name = ...
    { 'Normal Strain Z', '正应变-Z' };
Methods.ezz.Type = 'basic';

%       --- 5 - 'Recalculated_exx'
Methods.Recalculated_exx.Name = ...
    { 'Recalculated exx', '重新计算-正应变-X' };
Methods.Recalculated_exx.Type = 'basic';

%       --- 6 - 'Recalculated_exy'
Methods.Recalculated_exy.Name = ...
    { 'Recalculated exy', '重新计算-剪应变-XY' };
Methods.Recalculated_exy.Type = 'basic';

%       --- 7 - 'Recalculated_eyy'
Methods.Recalculated_eyy.Name = ...
    { 'Recalculated eyy', '重新计算-正应变-Y' };
Methods.Recalculated_eyy.Type = 'basic';

%       --- 8 - 'Hxy'
Methods.Hxy.Name = ...
    { 'Hxy', '位移梯度-XY' };
Methods.Hxy.Type = 'basic';
%       --- 9 - 'Hyx'
Methods.Hyx.Name = ...
    { 'Hyx', '位移梯度-YX' };
Methods.Hyx.Type = 'basic';


% ------------- EBSD-BASED METHODS -------------

%       --- 1 - 'AverageGrainEffectiveShear'
Methods.AverageGrainEffectiveShear.Name = ...
    { 'Average Grain Effective Shear Strain', '晶粒平均有效剪切应变' };
Methods.AverageGrainEffectiveShear.Type = 'ebsd';

%       --- 2 - 'cAxisEnlongation'
Methods.cAxisEnlongation.Name = ...
    { 'Enlongation Along c-axis', 'c轴伸缩度' };
Methods.cAxisEnlongation.Type = 'ebsd';

%       --- 3 - 'cAxisAngle'
Methods.cAxisAngle.Name = ...
    { 'Angle between c-axis and xy-plane', 'c轴与xy平面夹角' };
Methods.cAxisAngle.Type = 'ebsd';

app.DICCalculateMethods = Methods;