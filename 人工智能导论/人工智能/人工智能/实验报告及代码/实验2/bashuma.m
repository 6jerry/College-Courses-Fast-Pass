function []=bashuma  
	clear
	close all;
	
	nosDim = 4; 	% 游戏面板的维度，八数码维度3，15数码维度4
	showPlot = 1; 	% 1,显示最后的游戏面板移动过程，0，不显示
	MAXITER = 10^10; %最大循环次数
	
	%%%%%%%%%%%%%%%%%%%%%%%
	% 数据结构
	node.pre=zeros(nosDim);  	%%%父节点状态
	node.con=zeros(nosDim);		% 节点的状态，即八数码的顺序
	node.id = 0;				% 节点自己的id号, 与该节点保存在NODES数组中的下标一致
	node.father = 0;   			% 父节点的id号,唯一
	node.children =[];			% 子节点的id号，可以有多个
	node.g=0;   				%%%当前状态的g(n)数值 
	node.h=0; 					%%%当前状态的h(n)数值 
	node.cost= 0;  				%%%当前状态的f(n)数值 
	% 
	%%%%%%%%%%%%%%%%%%%%%%%%
	NODES=repmat(node,1,10^4);
	
	iter=0;  %循环次数计数  
	
	nosSinOL=0; % openList 表中状态的数量
	nosSinCL=0; % closeList 表中状态的数量
	
	
	%初始化  
	dis=reshape([1:nosDim^2]-1,nosDim,nosDim); 					%目标状态
	initMatrix = reshape(randperm(nosDim^2)-1,nosDim,nosDim);  	%初始状态
	% initMatrix(:) = [ 4     1     3     0     8     5     7     6     2]; %tough init
	%initMatrix(:) = [ 8     1     0     5     7     2     6     3     4]; %tough init	 
	initMatrix(:) = [ 7 4 9 6 3 12 14 10 2 5 0  15 11 13 1 8];  %easy init	
	disp('初始状态：');
	disp(initMatrix);	
	disp('~~~~~~~~~');

	N.pre=zeros(nosDim);  %%%父亲状态
	N.con=initMatrix;		% 节点的状态，即八数码的顺序
	N.id = 1;				% 节点自己的id号, 与该节点保存在NODES数组中的下标一致
	N.father = 0;   		% 父节点的id号,唯一
	N.children =[];			% 子节点的id号，可以有多个
	N.g=0;   				%%%当前状态的g(n)数值 
	N.h=calH(N,dis); 		%%%当前状态的h(n)数值 
	N.cost= N.g + N.h;  	%%%当前状态的f(n)数值 
	
	NODES(1)=N;
	openList(1)=N.id; %初始化openList表  %书本步骤1（书本步骤2已省略）
	
	if ~avlbSol(N,dis)
		disp('doesnot exist solution. ERROR.');
		return;
	end
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% 开始搜索
	%
	tstart=clock;
	indexMin=0;
	y=dis;  
	while 1  
		%设置循环次数  
		iter=iter+1;  
		if iter==10^2,disp('iter==10^2');end
		if iter==10^3,disp('iter==10^3');end
		if iter==2*10^3,disp('iter==2*10^3');end
		if iter==5*10^3,disp('iter==5*10^3');end
		if iter==10^4,disp('iter==10^4');end
		if iter==10^5,disp('iter==10^5');end
		if iter==MAXITER  
			disp('too many loops, ERROR!!');  
			return;  
		end  	
		
		nosSinOL = length(openList);

		%  寻找openList表中代价最小值  
		for j=1:nosSinOL  
			if N.cost>NODES(openList(j)).cost  
				N=NODES(openList(j));  
				indexMin = j;
			end  
		end  

		%%把该状态添加至 closeList 表  
		nosSinCL = nosSinCL+1;
		closeList(nosSinCL)=N.id;   %%%书本步骤3

		%%把该状态从 openList 表中删除  
		if length(openList)== 1 	%openList 表只有一个元素
			openList=[];
		else 						%openList 表有多个元素
			if indexMin~=nosSinOL	%如果要删除的元素不是最后一个元素，则把最后元素与要删除元素位置对换
				openList(indexMin) = openList(nosSinOL);
			end
			openList=openList([1:nosSinOL-1]);
		end

		%%是否找到目的节点  %%%书本步骤4
		if goal(N,dis)  
			disp('success!!');  
			break;  
		end  

		%%扩展节点  %%%书本步骤5/6
		[NODES,openList,closeList]=moveSpace(NODES,openList,closeList,N,dis);  
		N.cost=inf; %%%初始化k.fuc数值，方便比较
        
        NODES=reflashValue(NODES,length(openList)+length(closeList)); %更新每个节点 g/h/cost数值
	end  	
	tend=clock;
	%
	% 结束搜索
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	disp(strcat('The program need : ',num2str(etime(tend,tstart)),' seconds.'));
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% 输出路径
	%
	s = N;
	indexList=[];
	while 1
		indexList=[s.id,indexList];
		if s.id == 1; break; end
		if sum(sum(s.con~=NODES(s.father).con))~=2
			disp('strange here');
		end
		s = NODES(s.father);
	end
	
	
	disp('----1-----');
	disp(strcat('length of indexList is:',num2str(length(indexList))));
	disp(strcat('length of openList  is:',num2str(length(openList))));
	disp(strcat('length of closeList is:',num2str(length(closeList))));
	if showPlot==1
		for j=1:length(indexList)  
			plotbubbles(NODES(indexList(j)).con);
			title(num2str(j));
			pause(1);
		end  	
	end
	%
	% 结束输出
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end  

%查询是否找到目标节点  
function ok=goal(N,dis)  
	ok=(N.con==dis);
end  

function flag=avlbSol(node,dis) %判断是否存在解
	con=node.con;	
	con=con';
	dis=dis';
	nosNXDcon = nixudui(con(:));
	nosNXDdis = nixudui(dis(:));
    if mod(nosNXDcon,2)==mod(nosNXDdis,2),flag=1;  %存在解
    else, flag=0;
    end
end
function nos=nixudui(list)
	list(list==0)=[];
	len = length(list);
	nos=0;
	for i=1:len
		index = find(list==i);
		nos = nos+index-1;
		list(list==i)=[];
	end
end


function NODES=reflashValue(NODES,nosNodes)
    refFlag=1;
    while refFlag == 1
        refFlag=0;
        for i=2:nosNodes
            if NODES(i).g ~= NODES(NODES(i).father).g+1
                NODES(i).g = NODES(NODES(i).father).g+1;
                NODES(i).cost = NODES(i).g +NODES(i).h;
                refFlag=1;
            end
        end        
    end
end





