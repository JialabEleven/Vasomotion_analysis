clear all;
clc;
cur_p1 = mfilename('fullpath');%获得现在所打开的文件的路径
i=strfind(cur_p1,'\');%匹配 \
cur_p=cur_p1(1:i(end-1));   
filename = fullfile([cur_p '4_3Dmodel_Synchronization\diameter.xlsx']);
a=xlsread(filename);

z=a(1:100,1:25);
x=-30:2.5:30;
y=1:1.08:108;%统一时间
y1=1.08:1.08:108;
[xx,yy]=meshgrid(x,y);

for i=1:size(z,2)
    b=z(:,i);
    average(i)=mean(b);
    for ii=1:length(b)
        zz(ii,i)=(b(ii)-average(i))/average(i);
    end
end

% figure(),surf(xx,yy,zz);

windowSize = 12; 
c = (1/windowSize)*ones(1,windowSize);
d=1;
for j=1:size(zz,2)
    t(:,j)=filter(c,d,zz(:,j));
end


figure(),surf(xx,yy,t);
