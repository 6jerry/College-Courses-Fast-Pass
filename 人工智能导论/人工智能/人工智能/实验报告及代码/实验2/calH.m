%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 计算该节点h(n)数值并返回

function cost=calH(node,dis)  
	cost=calH1(node,dis);
end  
function cost=calH0(node,dis)
	cost=0;
end
function cost=calH1(node,dis)
	cost = length(find(node.con~=dis));
end
function cost=calH2(node, dis)
              nosDim = 3;%%维度
    		  cost = 0;%%初始化
     for  i=0:(nosDim^2-1)%%寻找位置不符的数
          [m,n]=find(node.con==i); %当前
          [x,y]=find(dis == i);     %目标
           cost=abs (x-m) + abs(n-y) +cost;
      end   
end
function cost=calH3(node, dis)
           nosDim =3;%%维度
           a= reshape (node.con,1, nosDim^2);
           cost = nixudui(a);
end
function cost=calH4(node, dis)
cost = nixudui(node.con) *3+length(find(node.con~=dis));
end
function cost=calH5(node, dis)
    		 nosDim = 4;%维度
     		 cost = 0;%初始化
     for i=0:(nosDim^2-1)%查找不符的位置
         [m, n] =find(node.con==i);
         [x, y] =find (dis == i);
cost=cost+8*(abs(x-m) +abs(n-y));%系数8在后有讨论
end 
    		a=reshape (node.con,1, nosDim^2);
   	   cost = nixudui(a)*5.3+cost; ;%系数5.3在后有讨论
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
