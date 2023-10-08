clear all;
clc;
cur_p1 = mfilename('fullpath');%获得现在所打开的文件的路径
i=strfind(cur_p1,'\');%匹配 \
cur_p=cur_p1(1:i(end-1));   
buildingDir = fullfile([cur_p '1_Diameter_radius_detection\test_figure.bmp']);
imgData1 = imread(buildingDir);
%a=im2gray(imgData1);

a=imgData1(:,:,1);%MCAO48minR2
%a=imgData1(:,25:195);%MCAO56minR3 %select part of picture for test show the bright value
 figure(), imshow(a);
% hold on 
% line([size(a,2)/2,size(a,2)/2],[1,size(a,1)],'LineWidth',2);



%axis off;
[rows,columns]=size(a)
k=0
p=0;
kk=0;
pp=0;
number_positive=0;
number_negative=0;

for i=1:rows
b=a(i,:);
     %figure(),plot(b);
c=smoothdata(b,'gaussian',3); %smooth data
      %figure(),plot(c);
%        figure,plot(c); 
%       figure()
%       plot(c,'r','Linewidth',1);%select part of picture for test show the bright value
%       xlabel('horizonal pixel');
%       ylabel('bright value');



d=double(c);
[e,f]=findpeaks(d);
n = find(e>80);  %select the peak value of left and right


for t=1:length(n)%
    g(t)=e(n(t));
    h(t)=f(n(t));
end
left=min(h);
right=max(h);


if right<0.6*columns%
    dg1=floor(0.6*columns);
    ff1=find(d(dg1:columns)==max(d(dg1:columns)));
    right=max(ff1)+(dg1-1);
    e=max(d(dg1:columns));
end

if left>0.4*columns%
    dg2=floor(0.4*columns);
    ff2=find(d(1:dg2)==max(d(1:dg2)));
    left=min(ff2);
    e=max(d(1:dg2));
end


if length(n)<2
    %if isempty(e)==1 | e<30 %judge whether e is empty
      ff3=find(d==max(d));
      left=min(ff3);
      right=max(ff3);
      e=max(d);
end
for m=1:columns
    boundary1(i,m)=c(m+right);
    if boundary1(i,m)==c(right)
        k=k+1;
    end
    if m>1
        if boundary1(i,m)==boundary1(i,m-1) 
            boundary1(i,m)=boundary1(i,m-1)-1;
            d(right+m)=boundary1(i,m);
            p=p+1;
        end
    end
    if m>2  
        if boundary1(i,m)>boundary1(i,m-1)
            boundary1(i,m)=boundary1(i,m-1)-1;
            d(right+m)=boundary1(i,m);
            p=p+1;
        end
    end
    if boundary1(i,m)<20 %base line of right
        markright=m+right;
        break;
    end
end

for q=1:columns
    boundary2(i,q)=c(left-q);
    if boundary2(i,q)==c(left)
        left=left-1; 
        kk=kk+1;
    end
    if q>1
        if boundary2(i,q)==boundary2(i,q-1) 
            boundary2(i,q)=boundary2(i,q-1)-1;
            d(left-q)=boundary2(i,q);
            pp=pp+1;
        end
    end
    if q>2 
        if boundary2(i,q)>boundary2(i,q-1)
            boundary2(i,q)=boundary2(i,q-1)-1;
            d(left-q)=boundary2(i,q);
            pp=pp+1;
        end
    end
    if boundary2(i,q)<20 %base line of left
        markleft=left-q;
        break;
    end
end

x=d((right+k):markright);
y=((right+k):markright);
y1(i)=interp1(x,y,(d(right)+d(markright))/2,'pchip');
y2(i)=interp1(x,y,(d(right)+d(markright))/2,'spline');


xx=d((markleft-kk):left);
yy=((markleft-kk):left);
y3(i)=interp1(xx,yy,(d(left)+d(markleft))/2,'pchip');
y4(i)=interp1(xx,yy,(d(left)+d(markleft))/2,'spline');

diameter_cubic(i)=0.994*((y1(i))-y3(i));%select pixel per mm
%tt=0;
%mm=0;
if i>=2
    if diameter_cubic(i)> (1+0.1)*diameter_cubic(i-1)
        diameter_cubic(i)=(1+0.01)*diameter_cubic(i-1);
        number_positive=number_positive+1;
    else
        if diameter_cubic(i)<(1-0.1)*diameter_cubic(i-1)
            diameter_cubic(i)=(1-0.01)*diameter_cubic(i-1);
            number_negative=number_negative+1;
        end
    end
end



%diameter_spline(i)=0.509117*((y2(i))-y4(i)); %select pixel per mm
h(:)=[];
g(:)=[];
k=0;
end


aa=ones(1,size(a,1))*(size(a,2)/2);
core=(y1+y3)/2;
average_core=mean(core);
core_x=1:1:size(a,1);
bb=polyfit(core_x,core,1);
core_y=bb(1)*core_x+bb(2);
average_core_revise=ones(1,size(a,1))*average_core;

figure(),imshow(a)
hold on 
plot(core,1:size(a,1),'LineWidth',1,'Color',[0 1 1]);
% hold on
% plot(aa,1:size(a,1),'LineWidth',1);
% hold on 
% plot(average_core_revise,1:size(a,1),'LineWidth',1,'Color',[0 0 1]);
hold on 
plot(core_y,1:size(a,1),'LineWidth',1,'Color',[1 1 0]);%fitting的线是红色
%saveas(gca,[savepath,'model_line.tif']);

% jj=-size(a,1):-1;
% jj=-jj;
% figure(),
% % plot(core,jj,'LineWidth',2,"Color",[0 1 1]);
% % hold on
% % plot(aa,jj,'LineWidth',1);
% % hold on 
% % plot(average_core_revise,jj,'LineWidth',1);
% % hold on 
% plot(core_y,jj,'LineWidth',2,'color',[1 1 0]);
% xlim([0,size(a,2)]);
%  axis off

j=length(diameter_cubic);
figure(), plot(1:j,diameter_cubic(1,:));title('Diameter');

left_radius_test_line=(core_y-y3)*0.994;
right_radius_test_line=(y1-core_y)*0.994;
number_positive_left_line=0;
number_negative_left_line=0;
number_positive_right_line=0;
number_negative_right_line=0;

for iii=1:rows
if iii>=2
    if left_radius_test_line(iii)> (1+0.2)*left_radius_test_line(iii-1)
        left_radius_test_line(iii)=(1+0.02)*left_radius_test_line(iii-1);
        number_positive_left_line=number_positive_left_line+1;
    else
        if left_radius_test_line(iii)<(1-0.2)*left_radius_test_line(iii-1)
            left_radius_test_line(iii)=(1-0.02)*left_radius_test_line(iii-1);
            number_negative_left_line=number_negative_left_line+1;
        end
    end
end
end

for jjj=1:rows
if jjj>=2
    if right_radius_test_line(jjj)> (1+0.24)*right_radius_test_line(jjj-1)
        right_radius_test_line(jjj)=(1+0.024)*right_radius_test_line(jjj-1);
        number_positive_right_line=number_positive_right_line+1;
    else
        if right_radius_test_line(jjj)<(1-0.24)*right_radius_test_line(jjj-1)
            right_radius_test_line(jjj)=(1-0.024)*right_radius_test_line(jjj-1);
            number_negative_right_line=number_negative_right_line+1;
        end
    end
end
end



figure(),plot(1:j,left_radius_test_line); title('Side1 radius');
figure(),plot(1:j,right_radius_test_line);title('Side2 radius');


[d_pks1,d_locs1]=findpeaks(diameter_cubic);
% figure(), plot(diameter_cubic);   
% hold on
% plot(d_locs1,d_pks1,'.','color','R');                %绘制最大值点
diameter=diameter_cubic';

diameter_radius_merge=[diameter left_radius_test_line' right_radius_test_line']
B = [{'diameter','side1_radius_fitting','side2_radius_fitting'}; num2cell(diameter_radius_merge)];
buildingDir1 = fullfile([cur_p '1_Diameter_radius_detection\']);
xlswrite([buildingDir1,'diameter_radius_merge'],B);
% for ii=1:size(d_locs1,2)
%     d_time(ii)=1.08*d_locs1(ii);
%     text(d_locs1(ii),d_pks1(ii),['',num2str(ii),''],'FontSize',10,'Color','r'); 
% end


