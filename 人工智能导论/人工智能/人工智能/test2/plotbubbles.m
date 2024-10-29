function []=plotbubbles(matr)
	
	
	[m,k]=size(matr);
	if m~=k,disp('input matrix should be of size nxn. ERROR.'); return ; end
	n = k+1;
	
	% ----------------------------
	% ---- 创建各个顶点的坐标-----
	posVex(1:2,1)=0;
	for i=1:(n)^2
		if i==1, posVex(1:2,i)=[0,n-1];
		else
			if mod(i-1,n)~=0
				posVex(1,i)=posVex(1,i-1)+1;
				posVex(2,i)=posVex(2,i-1);
			else
				posVex(1,i)=posVex(1,i-n);
				posVex(2,i)=posVex(2,i-n)-1;
			end
		end    
	end
	% 以下初始化各个顶点的关系矩阵A
	A=zeros(n^2);
	for i=1:n^2
		if i+1<=n^2 && mod(i,n)~=0
			A(i,i+1)=1;
		end
		if i+n<=n^2
			A(i,i+n)=1;
		end
		
	end	
	A=A+A';
	
	% ----------------------------
	% ---- 根据坐标，plot各个顶点-----
    plot([0,0],'b');
    hold on
	for i=1:n^2
		for j=i:n^2				
			if A(i,j)==1, 
				plot([posVex(1,i),posVex(1,j)],[posVex(2,i),posVex(2,j)],'b');
			end
		end
	end
	hold off
	
	
	% ----------------------------
	% ---- 根据matr，填充各个数字-----
    hold on
	for i=1:k
		for j=1:k
			num = (i-1)*n+j;
			x = posVex(1,num)+0.5;
			y = posVex(2,num)-0.5;
            if (matr(i,j)==0)
                text(x,y,num2str(matr(i,j)),'FontSize',24,'Color','red','FontWeight','Bold');
            else
                text(x,y,num2str(matr(i,j)),'FontSize',18);
            end
		end
	end
	hold off
end