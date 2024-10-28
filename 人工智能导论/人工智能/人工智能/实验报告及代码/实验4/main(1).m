function main()
	
	% 准备数据 input/target
	% input 是个 63 x nosDigits 的矩阵， 每一列是一个数字图片的像素序列 
	% target 是个 nosDigits x nosDigits 的对角线矩阵，对角线上都是1 ， 每列对应一个数字图片的相应输出，即判断是哪个数字
	nosDigits=2; 		% 需要识别的数字类别的数量
	[img]=loadimages(); % 把保存在loadimages.m文件里面的数字图片读取出来	
	for i=1:nosDigits
		imgdgt = img(:,:,i); 
		input(:,i)=imgdgt(:); 		%把数字图片矩阵调整为序列
	end
	target=diag(ones(nosDigits,1)); % 
	
	
	%%%%%%%%%%%%%%%
	% 设置系统参数
	toShowTestPredPlot=0;		%显示测试过程中图片的比较
	trainIter =1e4;	  			%训练样本数量
	testLength=1e2;				%测试样本数量
	nhidden=3;					%网络隐单元层神经元个数
	ninr = length(input(:,1));	%网络输入层神经元个数（由数据本身决定）
	nout = length(target(:,1));	%网络输出层神经元个数（由数据本身决定）
	learningRate=1e-2;			%网络学习步长
	nosChg10 = 3; 				%测试时，每个图片当中随机寻找nosChg10个数量的1像素改为0
	nosChg01 = 3;				%测试时，每个图片当中随机寻找nosChg01个数量的0像素改为1
	stage=[2:10]*trainIter/10;	%把训练分成多个连续的阶段，将会在每个训练阶段结束之后进行一次测试，（以便观察测试error是否比上个阶段降低）
	%
	%%%%%%%%%%%%%%%
	
	
	% 创建网络，保存在net
	net=createNet(ninr, nout, nhidden,learningRate);
    
    
    % 初始化
	errTrain=zeros(trainIter,1);				%保存训练过程中的error
	errTest=zeros(length(stage),testLength);	%保存在测试过程中的error
	
	iter = 0;
	for k = 1:length(stage) 		%分多个连续的阶段阶段，
	
		%%%%%%%%%%%%%%%%%%%%%%%%%
		% 开始训练
		while iter<stage(k)
			iter = iter +1 ;
			% 每次训练，随机选取训练样本（包括输入图片及对应输出）
			if rand>0.5,trainInput=input(:,1); trainTarg=target(:,1);	%选取第1个数字作为训练样本
			else, trainInput=input(:,2); trainTarg=target(:,2);			%选取第2个数字作为训练样本
			end
			% 训练后输出新网络，保存在net
			[net,error]=netTrain(net,trainInput,trainTarg);
			% 记录训练error
			errTrain(iter) = mean(abs(error));
		end
		errTrn1000 = mean(errTrain(iter-1000:iter));
		
		%%%%%%%%%%%%%%%%%%%%%%%%%
		% 开始测试
		for i=1:testLength
			% 每次训练，随机选取测试样本（包括输入图片及对应输出）
			if rand>0.5,testInput=input(:,1); testTarg=target(:,1); 	% 选取第1个数字作为测试样本
			else testInput=input(:,2); testTarg=target(:,2);			% 选取第2个数字作为测试样本
			end
			
			% 在图片中加入噪声/干扰
			testInput_backup = testInput; 		%保留痕迹
			testInput = putNoiseInImg(testInput,nosChg10,nosChg01);
			 
			% 使用干扰后的测试样本并执行网络，输出output,并计算测试Error
			[testOutput] = netTest(net,testInput,1);
			errTest(k,i) = mean(abs(testOutput-testTarg));	
			
			if toShowTestPredPlot==1
				showTestPredPlot(testInput,testOutput,input,target,testInput_backup);
			end 		
		end
		
		errTestMean = mean(errTest(k,:) );
		
		disp('------------');
		disp(strcat('当系统被训练 ',num2str(iter),'次后：'));
		disp(strcat('errTrn1000(最后1000个训练Error均值)为：',num2str(errTrn1000)));
		disp(strcat('errTestMean(测试Error均值)为：',num2str(errTestMean)));
	end
	% 显示训练和测试过程的error .
	figure (2),plot(errTrain(:)); title('Train Error');grid
	figure (1),plot(errTest(:));title('Test Error');grid; 
end


function showTestPredPlot(testInput,testOutput,input,target,testInput_backup)
	[~,nosDigits] = size(target);
	v=mean(abs(repmat(testOutput,1,nosDigits)-target),1);
	[~,ind]=min(v);
	figure(1),
	subplot(1,3,1),plotNum(testInput_backup);title('清晰的测试图片');
	subplot(1,3,2),plotNum(testInput);title('干扰的测试图片');
	subplot(1,3,3),plotNum(input(:,ind));title('判定的目标图片');
	pause;
	subplot(1,1,1);
end
				
function inputImg = putNoiseInImg(inputImg,nosChg10,nosChg01)
	% 把图片中部分的1改成0，改变数目为 nosChg10
	list=find(inputImg==1);
	nl=length(list);
	listChg10 = randperm(nl);
	listChg10 = listChg10(1:nosChg10);
	inputImg(list(listChg10))=0;		
	% 把图片中部分的0改成1，改变数目为 nosChg01
	list=find(inputImg==0);
	nl=length(list);
	listChg01 = randperm(nl);
	listChg01 = listChg01(1:nosChg01);
	inputImg(list(listChg01))=1;	
end


function net=createNet(ninr, nout, nhidden,learningRate)
	net.ninr = ninr;
	net.nout = nout;
	net.nhidden = nhidden;

	net.hidfn = 'sigmoid'; 
	net.outfn = 'sigmoid';

	% initial weight matrix
	noiseLevel=0.1;
	net.win = randn(nhidden,ninr)*noiseLevel;
	net.wout = randn(nout,nhidden)*noiseLevel;
	
	net.lr = learningRate; %learning rate
end


function [net,Verror]=netTrain(net,input,target)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% forward
	[outState,hidState]=netTest(net,input,1);
	net.err = outState-target;
    Verror = net.err;
	%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% backward
	if strcmp(net.outfn,'sigmoid')==1
		dm = outState.*(1-outState).*net.err;
	else
		error('other output functions has not beed done yet, pls complete here.');	
	end		
	if strcmp(net.hidfn,'sigmoid')==1
		dk = hidState.*(1-hidState).*(dm'*net.wout)';
	else
		error('other hidden functions has not beed done yet, pls complete here.');	
	end		
	%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%计算修正量
	aWout = - net.lr*dm*hidState';
	aWin  = - net.lr*dk*input';
	
	%修正网络参数
	net.wout = net.wout + aWout;
	net.win = net.win + aWin;
end



function [outState,hidState]=netTest(net,input,future)
	netin = net.win*input;
	if strcmp(net.hidfn,'tanh')==1
		hidState = tanh(netin);
	elseif strcmp(net.hidfn,'sigmoid')==1
        hidState = 1./(1+exp(-netin));    
	elseif strcmp(net.hidfn,'linear')==1
		hidState = netin;
	else
		error('no such hidden function')	
	end
	
	netout = net.wout*hidState;
	if strcmp(net.outfn,'tanh')==1
		outState = tanh(netout);
	elseif strcmp(net.outfn,'sigmoid')==1
        outState = 1./(1+exp(-netout));    
	elseif strcmp(net.outfn,'linear')==1
		outState = netout;
	else
		error('no such output function')	
	end
end
