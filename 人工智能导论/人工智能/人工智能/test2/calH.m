%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 计算该节点h(n)数值并返回

function cost=calH(node,dis)  
	cost=calH0(node,dis);
end  
function cost=calH0(node,dis)
	cost=0;
end
function cost=calH1(node,dis)
	cost = length(find(node.con~=dis));
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
