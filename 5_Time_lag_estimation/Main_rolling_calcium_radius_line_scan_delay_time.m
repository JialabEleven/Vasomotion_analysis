clear all;
clc;
cur_p1 = mfilename('fullpath');%获得现在所打开的文件的路径
i=strfind(cur_p1,'\');%匹配 \
cur_p=cur_p1(1:i(end-1));   
filename = fullfile([cur_p '5_Time_lag_estimation\calcium_radius.xlsx']);
savepath = fullfile([cur_p '5_Time_lag_estimation\Time_lag_data\']);
a=xlsread(filename);
m=1;

radius=a(281:380,2); %301-2000frames采用221-320的帧数
aa=size(radius,1);
base_number=size(radius,1);
calcium=a(1:400,1);
bb=size(calcium,1);
cc=bb-aa;
%cc=(bb-aa+1)/2;
%%原数据的窗口滑动评判
for i=1:(size(calcium,1)-aa+1)
    calcium_select=calcium(i:i+aa-1,1);
    correl_raw(i)=corr(calcium_select,radius);
end

correl_raw_test=-correl_raw; %为了找寻极小值，但是由于使用findpeak函数，需要把整个函数翻过来以找到极小值点
correl_raw_test1=-correl_raw;
j=length(correl_raw_test);
% figure(), plot(1:j,correl_raw_test(1,:));

[d_pks1,d_locs1]=findpeaks(correl_raw_test);
%  [d_pks2,d_locs2]=findpeaks(correl_raw_test1);
%  figure(),plot(d_locs2,-d_pks2)
%   [d_pks3,d_locs3]=findpeaks(d_pks2);
%    figure(),plot(d_locs2(d_locs3),-d_pks3);
% figure(), plot(correl_raw_test);   
% hold on
% plot(d_locs1,d_pks1,'.','color','R');                %绘制极大值点
a=max(d_pks1);
k=find(d_pks1==max(d_pks1));
x=d_locs1(k);
y=-a; %找到极小值中的最小值点


% d_pks1(k)=-1;
% a1=max(d_pks1);
% k1=find(d_pks1==max(d_pks1));
% x1=d_locs1(k1);
% y1=-a1; %找到极小值中的第二最小值点
% 
% d_pks1(k1)=-1;
% a2=max(d_pks1);
% k2=find(d_pks1==max(d_pks1));
% x2=d_locs1(k2);
% y2=-a2; %找到极小值中的第三最小值点

frame_total=[x];
time=17.251/2000;%时间

b=[-cc*time:time:0];
%data_time_delay=-(b(x)+b(x1)+b(x2))/3;
x_total=[b(x)];
y_total=[y];
figure(), plot(b,correl_raw)
hold on
plot(x_total,y_total,'.','color','R')
for ii=1:size(x_total,2)
     text(x_total(ii),y_total(ii),['',num2str(ii),''],'FontSize',10,'Color','r'); 
 end
title('R_value_rolling')
xlabel('Time/s');
ylabel('R_value')
hold off
saveas(gca,[savepath,'radius_calcium.tif']);
time1=b';
data_correl=correl_raw';
data_R_value_total=[frame_total' x_total' y_total'];

output_data=[y_total(1),x_total(1)];
B = [{'CC','Time_lag'}; num2cell(output_data)];
xlswrite([savepath,'output_CC_timelag'],B);
