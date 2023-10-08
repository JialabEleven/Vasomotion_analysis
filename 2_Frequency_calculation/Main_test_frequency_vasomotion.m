clear all;
clc;
cur_p1 = mfilename('fullpath');%获得现在所打开的文件的路径
i=strfind(cur_p1,'\');%匹配 \
cur_p=cur_p1(1:i(end-1));   
buildingDir = fullfile([cur_p '2_Frequency_calculation\Test_vasomotion_data.xlsx']);
savepath = fullfile([cur_p '2_Frequency_calculation\data_frequency_vasomotion\']);

data=xlsread(buildingDir);

time=1.08:1.08:216; %因为我们之前是输入了一个25000*2的矩阵，但为了方便，我们可以按批次上传，先上传time的，再上传amplitude的。原理一样，在workspace分别得到两个文件，每个都是25000*1的数字矩阵。

for i=1:size(data,2)
    amplitude=data(:,i);%同上
    figure(),plot(time,amplitude);

response=amplitude;%我们让amplitude等于response代表输出值

response=response-mean(response);

y=fft(response);%我们直接用fft函数对其转换。


sampleNumber=length(response);%样本数量等于response的长度也就是25000

sampleFrequency=1/1.08;%样本频率指的是400个频率点


ytemp1=abs(y/sampleNumber);

ytemp2=ytemp1(1:sampleNumber/2+1);


delta_f = 1*sampleFrequency/sampleNumber;

X = fftshift(abs(fft(response)))/sampleNumber;
X_angle = fftshift(angle(fft(response)));
f = (-sampleNumber/2:sampleNumber/2-1)*delta_f;
t = (0:sampleNumber-1)*(1/sampleFrequency);

raw_data1=X(101:101);
raw_data2=2*X(102:200);
raw_data=[raw_data1;raw_data2];
raw_data_merge(:,i)=raw_data;
f_frequency=f(101:200);
output_frequency=[f_frequency' raw_data_merge];




%设计一个巴特沃夫低通滤波器,要求把50Hz的频率分量保留,其他分量滤掉
wp = 0.18/(sampleFrequency/2);  %通带截止频率,取50~100中间的值,并对其归一化
ws = 0.3/(sampleFrequency/2);  %阻带截止频率,取50~100中间的值,并对其归一化
alpha_p = 3; %通带允许最大衰减为  db
alpha_s = 20;%阻带允许最小衰减为  db
%获取阶数和截止频率
[ N1 wc1 ] = buttord( wp , ws , alpha_p , alpha_s);
%获得转移函数系数
[ b a ] = butter(N1,wc1,'low');
%滤波
filter_lp_s = filter(b,a,response);
X_lp_s = fftshift(abs(fft(filter_lp_s)))/sampleNumber;
X_lp_s_angle = fftshift(angle(fft(filter_lp_s)));
filter_data1=X_lp_s(101:101);
filter_data2=2*X_lp_s(102:200);
filter_data=[filter_data1;filter_data2];
% figure();
% freqz(b,a); %滤波器频谱特性
% figure();
% subplot(2,1,1);
% plot(t,filter_lp_s);
% grid on;
% title('低通滤波后时域图形');
% subplot(2,1,2);
% plot(f(101:200),filter_data);
% title('低通滤波后频域幅度特性');
% saveas(gca,[savepath,'frequency_domain',num2str(i),'.tif']);
% subplot(3,1,3);
% plot(f,X_lp_s_angle);
% title('低通滤波后频域相位特性');
filter_data_merge(:,i)=filter_data;
output_frequency_filter=[f_frequency' filter_data_merge];
merge_frequency=output_frequency_filter(:,2:end);
end



for j=1:size(merge_frequency,1)
        before_average_frequency(j)=mean(merge_frequency(j,1:(size(data,2)-1)));
end
        before_average_frequency_filter=smooth(before_average_frequency,3);
        before_average_frequency_filter=smooth(before_average_frequency_filter,2);

%         figure
%         plot(f_frequency,before_average_frequency)
%         grid on
%         xlabel('Frequency(Hz)','Fontsize',12)
%         ylabel('Frequency-domain','Fontsize',12)
%         legend('Before','RP22h')
%         saveas(gca,[savepath,'compare_frequency_domain.tif']);

        figure
        plot(f_frequency,before_average_frequency_filter)
        grid on
        xlabel('Frequency(Hz)','Fontsize',12)
        ylabel('Frequency-domain','Fontsize',12)
        legend('Before','RP22h','RP14day')
        saveas(gca,[savepath,'compare_frequency_domain.tif']);
        k=1;
for j=1:(size(merge_frequency,2))
    compare_pair1=merge_frequency(:,j);
    compare_pair2=smooth(compare_pair1,3);
    compare_pair2=smooth(compare_pair2,2);


    before_output_filter(:,k)=compare_pair2;%%%%%
    k=k+1;%%%%%



%     figure
%     plot(f_frequency,compare_pair1)
%     grid on
%     xlabel('Frequency(Hz)','Fontsize',12)
%     ylabel('Frequency-domain','Fontsize',12)
%     legend('Before')
%     saveas(gca,[savepath,'compare_pair',num2str(j),'.tif']);

    figure
    plot(f_frequency,compare_pair2)
    grid on
    xlabel('Frequency(Hz)','Fontsize',12)
    ylabel('Frequency-domain','Fontsize',12)
    legend('Before')
    saveas(gca,[savepath,'compare_pair_',num2str(j),'.tif']);


end


merge_frequency_filter=[before_output_filter];%%%%%%



% output_frequency_revise=[f_frequency' merge_frequency];
% xlswrite([savepath,'Total_data'],output_frequency_revise);

output_frequency_filter_revise_smooth=[f_frequency' merge_frequency_filter];%%%%
xlswrite([savepath,'Total_data'],output_frequency_filter_revise_smooth);%%%%