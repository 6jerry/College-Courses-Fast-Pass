putNoiseDigit = 0;  	%如果要在将要预测的图片上自动加上噪点，则须 putNoiseDigit=1
toEditPredDigit = 0;  	%如果要把手动在将要预测的图片上画画，则须 toEditPredDigit=1
toShowDigitTest = 1;  	%如果要显示测试图片及其对应的判断结果，则须 toShowDigitTest = 1

%加载数字样本数据作为图像数据存储。imageDatastore 根据文件夹名称自动标记图像，
%并将数据存储为 ImageDatastore 对象。通过图像数据存储可以存储大图像数据，
%包括无法放入内存的数据，并在卷积神经网络的训练过程中高效分批读取图像。
digitDatasetPath = '.\';
imds = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','foldernames');
	
%显示数据存储中的部分图像。
figure;
perm = randperm(10000,20);
for i = 1:20
    subplot(4,5,i);
    imshow(imds.Files{perm(i)});
end


%计算每个类别中的图像数量。labelCount 是一个表，其中列出了标签，
%以及每个标签对应的图像数量。数据存储包含数字 0-9 的总共 10000 
%个图像，每个数字对应 1000 个图像。
labelCount = countEachLabel(imds);

%必须在网络的输入层中指定图像的大小。检查 digitData 中第一个图像的大小。
%每个图像的大小均为 28×28×1 像素 ,dim=28

img = readimage(imds,1);
[~,dim] = size(img);


%将数据划分为训练数据集和验证数据集，以使训练集中的每个类别包含 numTrainFiles 个图像，
%并且验证集包含对应每个标签的其余图像。splitEachLabel 将数据存储 digitData 
%拆分为两个新的数据存储 trainDigitData 和 valDigitData。
numTrainFiles = 995;
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');


%定义卷积神经网络架构
layers = [
    imageInputLayer([dim dim 1])    
	
    convolution2dLayer(4,1,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)    
    
    fullyConnectedLayer(size(labelCount,1))
    softmaxLayer
    classificationLayer];


% 指定训练选项。使用具有动量的随机梯度下降 (SGDM) 训练网络，初始学习率为 0.01。
% 将最大训练轮数设置为 1。一轮训练是对整个训练数据集的一个完整训练周期。
% 通过指定验证数据和验证频率，监控训练过程中的网络准确度。
% 每轮训练都会打乱数据。软件基于训练数据训练网络，并在训练过程中按固定时间间隔计算基于验证数据的准确度。
% 验证数据不用于更新网络权重。打开训练进度图，关闭命令行窗口输出。
options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',2, ...
    'Verbose',true ,...,
    'Plots','training-progress');

%使用训练数据训练网络
%查看系统弹出窗口
net = trainNetwork(imdsTrain,layers,options);	

save wrkspc.mat;
% load wrkspc.mat;


if toEditPredDigit==1
	% 通过OS系统小软件更改图片并保存
	% 注意留意系统提示.修改完图片后一定要使用“另存为”来保存新图片，否则会出错。
	editPredFigures(imdsValidation);
end


% 要在将要预测的图片上自动加上噪点
if putNoiseDigit==1
	noiseNum=10;
	puttingNoiseInDigit(imdsValidation,noiseNum);
end


%使用经过训练的网络预测验证数据的标签，并计算最终验证准确度。
%准确度是网络预测正确的标签的比例。
YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;
accuracy = sum(YPred == YValidation)/numel(YValidation) *100;
disp(strcat('系统分辨准确率达到：',num2str(accuracy),'%'));

if toShowDigitTest==1
    close all;
    showList = randperm(length(imdsValidation.Files));
    disp('图片中显示待测试/判断的数字图片，图片上方的文字表示判断的结果。（持续按空格使其切换）');
    for i=1:length(imdsValidation.Files)
        imshow(imdsValidation.Files{showList(i)});
        title(YPred(i),'FontSize',24);
        pause;
    end
    close all
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 以下是调用的函数
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function editPredFigures(imdsValidation)
    listToDraw = [7]; 			% 需要更改的图片在imdsValidation.Files中的序号，listToDraw可以是一个列表/向量
	disp('修改图片时，最好使用画图软件自带的颜色选取器来定颜色，而不是自行选定。');
	if any(listToDraw>length(imdsValidation.Files)) , error('wrong here');end
	for i=1:length(listToDraw)
		disp('修改后的图片一定要存放在下面的路径及文件名称（否则会出错）:');
		filename = strcat(imdsValidation.Files{listToDraw(i)},'.123.png');
		disp(filename);		
		command=strcat('mspaint',32,imdsValidation.Files{listToDraw(i)});
		system(command);
		imdsValidation.Files{listToDraw(i)} = filename;
		a = imread(imdsValidation.Files{listToDraw(i)});
		a = a(:,:,1);
		filenameFinal = strcat(filename,'.tmp');
		imwrite(a,filenameFinal,'png');		
		imdsValidation.Files{listToDraw(i)}=filenameFinal;
		
		command = strcat('del',32,filename);
		system(command);
		
	end
end



function puttingNoiseInDigit(imdsValidation,noiseNum)
    for fileInd=1:length(imdsValidation.Files)
		a=imread(imdsValidation.Files{fileInd});
        c=a;
		[x,y]=find(a);
		listChangeIdn=randperm(length(x),noiseNum);
		for i=1:noiseNum
			done = 0;
			while ~done
				x1=x(listChangeIdn(i))+floor(randn*1);
				if (x1>28 || x1<1) continue; end
				y1=y(listChangeIdn(i))+floor(randn*1);
				if (y1>28 || y1<1) continue; end
				if(a(x1,y1)==0) 
					done=1;
				end
			end
			rv = randn*5;
			c(x1,y1) = c(x(listChangeIdn(i)),y(listChangeIdn(i)))+floor(rv);
			c(x1,y1) = max(0,c(x1,y1));
			c(x1,y1) = min(255,c(x1,y1));			
		end
		imwrite(c,strcat(imdsValidation.Files{fileInd},'.tmp'),'png');
		imdsValidation.Files{fileInd}=strcat(imdsValidation.Files{fileInd},'.tmp');
	end
end
