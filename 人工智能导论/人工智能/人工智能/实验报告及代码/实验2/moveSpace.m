%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 以N节点为初始状态，寻找可执行的操作
% 包括上下左右等移动操作  
function [NODES,openList,closeList]=moveSpace(NODES,openList,closeList,N,dis)  
	% oprtList 数组中元素1-2-3-4分别表示空格向右-下-左-上四个方向移动
	
	nosSinOL = length(openList);
	nosSinCL = length(closeList);
	
	[x,y]=find(N.con==0);  
	[n,n]=size(N.con);
	oprtList=[];
	if y<n, oprtList = [oprtList,1];end
	if x<n, oprtList = [oprtList,2];end
	if y>1, oprtList = [oprtList,3];end
	if x>1, oprtList = [oprtList,4];end
	
	for i=1:length(oprtList)
		if     oprtList(i)==1,childState=gort(N);  
		elseif oprtList(i)==2,childState=godn(N);  
		elseif oprtList(i)==3,childState=golt(N);  
		elseif oprtList(i)==4,childState=goup(N);  
		else disp('value of oprtList can only be 1-4. ERROR');
		end		
        childState.pre=N.con;
        childState.father = N.id;
        childState.g = N.g+1;
        childState.h = calH(childState,dis);
        childState.cost = childState.g + childState.h;
		[NODES,flag]=checkState(NODES,childState,nosSinOL+nosSinCL);  
		if flag == 0 % flag=0,表示f状态没有出现在op、cl中； flag=1,表示f状态出现在op、cl中	
            nosSinOL = nosSinOL+1;
            childState.id = nosSinOL+nosSinCL;
			NODES(childState.id)=childState;
			openList = [openList,childState.id];
			NODES(N.id).children = [NODES(N.id).children,childState.id];
		end		
	end	
end  



% 查询是否存在重复节点
function [NODES,flag]=checkState(NODES,childState,nosNodes)  
	flag = 0;% flag=0,表示f状态没有出现在op、cl中； flag=1,表示f状态出现在op、cl中
	for i=1:nosNodes
		if  NODES(i).con==childState.con
			flag = 1;
            if childState.h~=NODES(i).h
                disp('sth strange');
            end
			if childState.g < NODES(i).g
				id=NODES(i).id;
                children = NODES(i).children;
                children = setdiff(children,childState.id);
                
				NODES(i) = childState;
				NODES(i).id=id;
                NODES(i).children=children;
                
                NODES(childState.father).children=[NODES(childState.father).children,NODES(i).id];
                
			end
			break  ;
		end  
	
	end
end  


%space goes up
function childState=goup(N)   
	childState=N;  	  
	[x,y]=find(childState.con==0);  
	t=childState.con(x-1,y);  
	childState.con(x-1,y)=0;  
	childState.con(x,y)=t;  
end  


%space goes left  
function childState=golt(N)  
	childState=N;  
	[x,y]=find(childState.con==0);  
	t=childState.con(x,y-1);  
	childState.con(x,y-1)=0;  
	childState.con(x,y)=t;  
end  


%space goes right
function childState=gort(N)  	
	childState=N;  	  
	[x,y]=find(childState.con==0);  
	t=childState.con(x,y+1);  
	childState.con(x,y+1)=0;  
	childState.con(x,y)=t;  	
end  


%space goes down  
function childState=godn(N)  
	childState=N;  
	[x,y]=find(childState.con==0);  
	t=childState.con(x+1,y);  
	childState.con(x+1,y)=0;  
	childState.con(x,y)=t;  
end  