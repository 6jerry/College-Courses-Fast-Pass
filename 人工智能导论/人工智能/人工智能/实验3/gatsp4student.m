function gatsp()
	hold off
	nc = 10;		% 城市的个数
	N = 100;		% 染色体群体规模
	MAXITER = 10^3;	% 最大循环次数
	SelfAdj = 0; 	%SelfAdj = 1时为自适应
    
	pc = 0.85;		% 交叉概率
	pw = 0.15;		% 变异概率
	
	locationx=floor(rand(nc,1)*100);
	locationy=floor(rand(nc,1)*100);
	locations=[locationx,locationy];
    load locations10.mat;
    %load locations20.mat;
    %load locations100.mat;
	R = distCal(locations);
    
	
	% 步骤1，产生N个染色体的初始群体,保存在pop里面
	pop = initPop(N,nc);
	
	iter=0;
    tstart=clock;
	while iter<MAXITER
        iter = iter+1;
		trajLength=calLen(pop,R);				%步骤2：计算每个染色体的路径长度		
		fitness=calFitness(trajLength);			%      计算每个染色体的适应值	%函数需要重写
        [b,f,ind]=findBest(pop,fitness);
		if satified(fitness), break; end		%步骤3：如果满足某些标准，算法停止		
		pop = chooseNewP(pop,fitness);			%      否则，选取出一个新的群体	%函数需要重写
		pop = crossPop(pop,pc,fitness,SelfAdj);	%步骤4：交叉产生新染色体，得到新群体 %函数需要重写		
		pop = mutPop(pop,pw,fitness,SelfAdj); 	%步骤5：基因变异	%函数需要重写
		pop(1,:) = b(1,:);						% 保留上一代中适应值最高的染色体             
    end	    
	
	%输出最优染色体/路径
	disp(strcat('最优的路径长度为：',num2str(calLen(b(1,:),R)),'，适应值为：',num2str(f),'，对应的路径为：'));
	disp(b(1,:));			
    
	%计算运行时间
    tend=clock;
	disp(strcat('The program need : ',num2str(etime(tend,tstart)),' seconds.'));
	
	%显示最优路径图像
	drawTSP(locations, b(1,:));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 根据各城市的location，计算出各城市
% 间的距离矩阵R
function R = distCal(location)
	nc=size(location,1);
	R = zeros(nc);
	for i=1:nc
		for j=i+1:nc
			R(i,j) = sqrt(sum((location(i,:)-location(j,:)).^2));
		end
	end
	R = R+R';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 产生N个染色体的初始群体,保存在pop里
% 每个染色体代表TSP问题的某一个解（即所有城市都经过一次的轨迹）
function pop=initPop(N,nc)
	pop = zeros(N,nc);
	for i=1:N,pop(i,2:end) = randperm(nc-1)+1;end %使用随机函数生成N个染色体
	pop(:,1)=ones(N,1);  %所有染色体都从城市1开始，最后回到城市1.
end	



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%根据距离矩阵R ，计算pop中每个染色体所代表的轨迹的长度
function trajLength = calLen(pop,R)
	[N,nc]=size(pop);
    trajLength = zeros(1,N);
	for i=1:N
		f=0;
		traj = pop(i,:);
		traj_2 = [traj(2:end),traj(1)];
		for j=1:nc , f = f+R(traj(j),traj_2(j)); end
		trajLength(i) = f;
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 根据所有染色体分别的轨迹长度，计算各个染色体的适应值
% trajLength	: 各个染色体的轨迹长度
% fitness		：各个染色体的适应值
function fitness=calFitness(trajLength)  %函数需要重写
	fitness = ones(size(trajLength));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 根据染色体的适应值，按照一定的概率，生成新一代染色体群体
% pop		：所有染色体群体， N x nc的矩阵
% fitness	：各染色体的适应值，长度为N的向量
% newpop	：生成新的染色体群体，N x nc的矩阵
function newpop = chooseNewP(pop,fitness)	%函数需要重写
	newpop = pop;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 根据交叉概率pc，以及各染色体的适应值fitness，通过交叉的方式生成新群体
% SelfAdj = 1时为自适应，否则取固定的交叉概率pc
% pop		：所有染色体群体， N x nc的矩阵
% fitness	：各染色体的适应值，长度为N的向量
% cpop		：生成新的染色体群体，N x nc的矩阵
% pc		: 交叉概率
function cpop = crossPop(pop,pc,fitness,SelfAdj) %函数需要重写	
	cpop = pop;
	%[child1,child2] = genecross(partner1,partner2); %这个genecross函数可能会有用
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 父染色体partner1,partner2，通过交叉方式
% 生成两个子染色体child1,child2
% partner1/2	: 交叉前的两个染色体
% child1/2		：交叉后的两个染色体
function [child1,child2] = genecross(partner1,partner2)
	len = length(partner1);
	idx1 = randi(len-1)+1;
	idx2 = randi(len-1)+1;
	ind1 = min(idx1,idx2);
	ind2 = max(idx1,idx2);
	
	child1 = partner1;
	child2 = partner2;
	
	tem1 = child1(ind1:ind2);
	tem2 = child2(ind1:ind2);	
	
	temdff1 = setdiff(tem1,tem2);
	temdff2 = setdiff(tem2,tem1);	

	for i=1:length(temdff1)
		child1(find(child1==temdff2(i)))=temdff1(i);
		child2(find(child2==temdff1(i)))=temdff2(i);		
	end	
	
	child1(ind1:ind2) = tem2;
	child2(ind1:ind2) = tem1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 根据变异概率pw，以及各染色体的适应值fitness，通过变异的方式生成新群体
% %SelfAdj = 1时为自适应，否则取固定的变异概率pw
% pop		：所有染色体群体， N x nc的矩阵
% fitness	：各染色体的适应值，长度为N的向量
% mpop		：生成新的染色体群体，N x nc的矩阵
% pw		: 变异概率
function mpop = mutPop(pop,pw,fitness,SelfAdj) %函数需要重写
	mpop = pop;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 根据染色体群体pop已经对应的适应值fitness，
% 找到最高的适应值f，以及对应的染色体bst和其在pop中的编号/下标ind
function [bst,f,ind] = findBest(pop,fitness) 
    f = max(fitness);
	ind = find(fitness == f);
	bst = pop(ind,:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 程序运行到某个状态，符合某些标准，则停止运行。
% 在当前例子下，不设置具体停止标准。所以返回sat=0
function [sat]=satified(fitness)
	sat=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 根据染色体traj所规定的轨迹，以及各城市的位置locations，画出该轨迹
function drawTSP(locations, traj)
	nc = size(locations, 1);
	plot(0,0,'.'); hold on; plot(100,100,'.');
	for i = 1:nc
		indP = traj(i);
		strPx = locations(traj(i), 1);
		strPy = locations(traj(i), 2);
		endPx = locations(traj(mod(i,nc)+1), 1);
		endPy = locations(traj(mod(i,nc)+1), 2);		
		plot([strPx,endPx],[strPy,endPy],'ms-','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','g');
		text(strPx,strPy,['  ', int2str(indP)]);		
	end
end
 