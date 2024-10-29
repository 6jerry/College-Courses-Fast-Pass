

WashM=readfis('washmachine.fis'); %模糊控制的模型已经初步建立，并保存在'washmachine.fis'文件中，通过‘readfis’命令读取并存放在WashM变量中


% 按照书本的模糊控制规则表，定义了9个对应的规则
rule1="dust==SD & gas==NG => washtime=VS";
rule2="dust==SD & gas==MG => washtime=M";
rule3="dust==SD & gas==LG => washtime=L";
rule4="dust==MD & gas==NG => washtime=S";
rule5="dust==MD & gas==MG => washtime=M";
rule6="dust==MD & gas==LG => washtime=L";
rule7="dust==LD & gas==NG => washtime=M";
rule8="dust==LD & gas==MG => washtime=L";
rule9="dust==LD & gas==LG => washtime=VL";


% 用‘addrule’命令，把以上9个规则增加到washmachine模型中
WashM=addrule(WashM,rule9);
WashM=addrule(WashM,rule5);
WashM=addrule(WashM,rule1);

WashM=addrule(WashM,rule2);
WashM=addrule(WashM,rule3);
WashM=addrule(WashM,rule4);
WashM=addrule(WashM,rule6);
WashM=addrule(WashM,rule7);
WashM=addrule(WashM,rule8);

ruleview(WashM); %用‘ruleview’命令查看上述规则的结果，会弹出GUI界面

%在GUI界面左下方input框中以[x y]的形式输入污泥和油脂的数值，如[60 70],可以观察到右上方的washtime后面数值的变化。
%同样，输入不同的[x y]数值，观察washtime的变化
%也可以在GUI界面拉动dust 和 gas对应的红轴线，观察washtime数值的变化

%点击view菜单中surface，查看推论结果立体图


writefis(WashM,'newwashmachine.fis');  %把最新更改后的WashM模型保存到文件'newwashmachine.fis'中
fuzzy('newwashmachine.fis');  %用命令fuzzy查看该模型input和output的隶属函数的设定