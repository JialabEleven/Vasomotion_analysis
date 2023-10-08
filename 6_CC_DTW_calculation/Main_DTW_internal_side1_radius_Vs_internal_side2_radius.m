clear all;
clc;
cur_p1 = mfilename('fullpath');%获得现在所打开的文件的路径
i=strfind(cur_p1,'\');%匹配 \
cur_p=cur_p1(1:i(end-1));   
buildingDir = fullfile([cur_p '6_CC_DTW_calculation\side1_radius_Vs_side2_radius\side1_radius_VS_side2_radius.xls']);
savepath = fullfile([cur_p '6_CC_DTW_calculation\side1_radius_Vs_side2_radius\']);

data=xlsread(buildingDir);
%a=(data(:,1));
%a=smoothdata(a,'gaussian',2);
peak_amount=ones(size(data,1),size(data,2))*nan;
peak_bright_value=ones(size(data,1),size(data,2))*nan;
peak_select_enddata=ones(size(data,1),size(data,2))*nan;
%savepath='G:\20230131_deal_pdgAi96_Awake_anes_20221115_awakemouse_LJZ\Figure\图5_Artery_Vein\vein_calcium\vein_diameter_calcium_vasomotion\';
%% 判断数据是否符合正态分布
for iii=1:size(data,2)
    a=data(:,iii);
    %a=smoothdata(a,'gaussian',3); %smooth data
    number=size(a,1);
    a_number_random=randperm(number,number);%随机选取数据进行抽样分析正态分布
 for rr=1:size(a,1)
     a_random=a(a_number_random);
 end
 h0(iii)=lillietest(a_random);    %判断是否正态。h=0
% %返回值h为假设,只有0和1两种情况，h=0假设符合正态分布，h=1假设不符合正态分布
% %返回值p为方差概率，也可以说事情的发生概率，p<0.05(显著性水平通常取0.05，还有0.025和0.01三种情况)为不可能事件，拒绝；p>0.05，接受
 h1(iii)=kstest(a_random);
 h2(iii)=jbtest(a_random);
 h3(iii)=chi2gof(a_random);

 aa=a_random(1:round(number*0.75));
 h00(iii)=lillietest(aa);    %判断是否正态。h=0为正态分布
 h11(iii)=kstest(aa);
 h22(iii)=jbtest(aa);
 h33(iii)=chi2gof(aa);

  aaa=a_random(1:round(number*0.5));
  h000(iii)=lillietest(aaa);    %判断是否正态。h=0为正态分布
  h111(iii)=kstest(aaa);
  h222(iii)=jbtest(aaa);
  h333(iii)=chi2gof(aaa);

  aaaa=a_random(1:round(number*0.25));
  h0000(iii)=lillietest(aaaa);    %判断是否正态。h=0为正态分布
  h1111(iii)=kstest(aaaa);
  h2222(iii)=jbtest(aaaa);
  h3333(iii)=chi2gof(aaaa);
    %a=smooth(a,3);
    cell_data = a';
    proc_data = rolling_percentile_filter(cell_data,40,20);
    

 pro_data=cell_data-proc_data;
 sig=std(proc_data); %算出a的标准偏差。到底哪个是标准差
%     pro_data(pro_data < 0) = 0;
    final_data=pro_data./(proc_data);
    [pks2,locs2]=findpeaks(pro_data);
%     [pks2,locs2]=findpeaks(final_data);
    [d_pks,d_locs]=findpeaks(final_data);
  u=1:1:length(pro_data);    
     for m=1:size(locs2,2)
         text(locs2(m),pks2(m),['',num2str(m),''],'FontSize',10,'Color','b'); 
     end
    %peak_ca=[locs2,pks2];
%     for jj=1:size(locs2,2)
%         part_cell_data(jj)=cell_data(locs2(jj));
%         part_proc_data(jj)=proc_data(locs2(jj));
%         part_time(jj)=locs2(jj)*tt;
%         part_final_data(jj)=final_data(locs2(jj));
%     end
% figure(),plot(final_data);
end_F(:,iii)=cell_data';
end_F0(:,iii)=proc_data';
end_data(:,iii)=final_data';




m=zeros(1,length(a));
num = [];%记录异常值
num1= [];
n = [];%构建一个新的矩阵用以储存新的数据集（异常值已经替换）
i=1;
q=1;
p=1;
e=1;
amount=[];
amount1=[];
select_enddata=[];
select_enddata1=[];
for t=1:length(d_locs)
    m(t)=cell_data(d_locs(t))-proc_data(d_locs(t));
	if m(t)>2*sig
  		%n(t)=aa;%这里把异常值替换成了均值，也可以直接替换成其他的值如0等，然后进行剔除
        %n(t)=0;%这里把异常值替换成了均值，也可以直接替换成其他的值如0等，然后进行剔除
  		bright_value1(p)=m(t);
        num1(i)=a(d_locs(t));%显示异常数据，如果没有异常数据的话将不会产生num变量
        amount1(q)=d_locs(t);
        select_enddata1(e)=final_data(d_locs(t));
  		i=i+1;
        q=q+1;
        p=p+1;
        e=e+1;
  	end
end


%找到final_data的deltaR/R0小于6%的位置
jj=1;
for tt=1:length(select_enddata1)
    if select_enddata1(tt)>0.008 %设置固定阈值去除一些被计入的小杂峰
        select_enddata(jj)=select_enddata1(tt);
        amount(jj)=amount1(tt);
        num(jj)=a(amount1(tt));
        bright_value(jj)=bright_value1(tt);
        jj=jj+1;
    end
end



%识别相邻事件，并将每一组相邻事件分成新的序列
nn=1;
amount_diff=diff(amount);
count=[];
for mm=1:length(amount_diff)
    if amount_diff(mm)<3  %将相邻<3pixel(<3.24s)的相邻峰值作为误差，挑选尾端两项较大的作为第一峰值，以便于后续生长
        count(nn)=mm;
        nn=nn+1;
    end
end

kkk=1;
aaa=1;
bbb=1;
count1=[count length(select_enddata)+1];
if length(count1)<=1
    delete_data_total=[];
else
    for mmm=1:(length(count1)-1)
    if count1(mmm+1)-count1(mmm)>1
%         count4(aaa)=count1(mmm);
%         aaa=aaa+1;
        if select_enddata(count1(mmm))<select_enddata(count1(mmm)+1)
            position(kkk)=count1(mmm);
            kkk=kkk+1;
        else if select_enddata(count1(mmm))>=select_enddata(count1(mmm)+1)
                position(kkk)=count1(mmm)+1;
                kkk=kkk+1;
        end
        end
    end
end
a1=diff(count1);
a2=find(a1==1);
delete_data1=[];
for uu=1:length(a2)
    delete_data1(uu)=count1(a2(uu));
end
delete_data2=position;
delete_data_total=[delete_data1 delete_data2];
delete_data_total=sort(delete_data_total);
end


%%未去除相邻数据前得到的图像
if isempty(select_enddata)
    bright_value=0;
end

b=1:1:length(cell_data);
% figure(), plot(b,cell_data);
% hold on
% plot(proc_data);
% hold on 
% plot(amount,num,'.','color','R');  
%  for j=1:size(num,2)
%      text(amount(j),num(j),['',num2str(j),''],'FontSize',10,'Color','b');
%  end
% title('Diameter events')
% xlabel('Frame');
% ylabel('Diameter')
% hold off
%saveas(gca,[savepath,'raw_data_line',num2str(iii),'.tif']);

% figure(), plot(b,final_data)
% hold on
% plot(amount,select_enddata,'.','color','R')
% for jj=1:size(num,2)
%      text(amount(jj),select_enddata(jj),['',num2str(jj),''],'FontSize',10,'Color','b');
%  end
% title('Diameter events')
% xlabel('Frame');
% ylabel('detaD/D0')
% hold off
% saveas(gca,[savepath,'deltaD_D0_line',num2str(iii),'.tif']);

%%选择性删除相邻数据后得到的图像
select_enddata_revise=select_enddata;
amount_revise=amount;
num_revise=num;
bright_value_revise=bright_value;
for z=1:length(delete_data_total)
    select_enddata_revise(delete_data_total(z))=0;
    amount_revise(delete_data_total(z))=0;
    num_revise(delete_data_total(z))=0;
    bright_value_revise(delete_data_total(z))=0;
end
select_enddata_revise(select_enddata_revise==0)=[];
amount_revise(amount_revise==0)=[];
num_revise(num_revise==0)=[];
bright_value_revise(bright_value_revise==0)=[];



% output=selete_single_peak(amount_revise,select_enddata_revise,b,final_data);
% figure(), plot(b,final_data)
% hold on
% plot(amount_revise,select_enddata_revise,'.','color','R')
% for jjj=1:size(select_enddata_revise,2)
%      text(amount_revise(jjj),select_enddata_revise(jjj),['',num2str(jjj),''],'FontSize',10,'Color','b');
%  end
% title('Diameter events delete')
% xlabel('Frame');
% ylabel('detaD/D0')
% hold off
% saveas(gca,[savepath,'deltaD_D0_line_select',num2str(iii),'.tif']);

peak_amount(1:length(amount_revise),iii)=amount_revise';
peak_bright_value(1:length(bright_value_revise),iii)=bright_value_revise';
peak_select_enddata(1:length(select_enddata_revise),iii)=select_enddata_revise';
%output=[end_F(:,iii),end_F0(:,iii),end_data(:,iii),peak_amount(1:length(amount),iii),peak_bright_value(1:length(bright_value),iii),peak_select_enddata(1:length(select_enddata),iii)];
output_raw_data=[end_F(:,iii),end_F0(:,iii),end_data(:,iii)];
output_peak=[peak_amount(1:length(amount_revise),iii),peak_bright_value(1:length(bright_value_revise),iii),peak_select_enddata(1:length(select_enddata_revise),iii)];
if isempty(output_peak)
    frequency(iii)=0;
    average_amplitude(iii)=0;
    output_peak=zeros(length(a),3);
else
frequency(iii)=size(output_peak,1)/(size(data,1)*1.08);%215.812;%320.962;%432.708;%320.962;%216.354 200帧所经历的时间
average_amplitude(iii)=mean(output_peak(:,3));
end
output_add=padarray(output_peak,length(a)-size(output_peak,1),'post');
output=[output_raw_data,output_add];
% if size(output_peak,1)==0|length(output_peak)==1
%     break;
% end
if size(output_peak,1)>=2
    if size(output_peak,1)==2
        interval=(output_peak(2,1)-output_peak(1,1))*1.08;%1.60481;%1.08
    else
        for kk=1:length(output_peak)-1
            interval(kk)=(output_peak(kk+1,1)-output_peak(kk,1))*1.08;%1.60481;%相邻两帧的时间间隔 1.08
        end
    end
end

if size(output_peak,1)==1
    interval=0;
end



interval_SD(iii)=std(interval);
interval_mean(iii)=mean(interval);
mean_diameter(iii)=mean(a);
mean_deltaD(iii)=mean(bright_value);%算出平均的deltaR值




A = [{'D','D0','deltaD/D0','peak_position','delta_diameter_value','peak_deltaD/D0'}; num2cell(output)];
% xlswrite([savepath,'single_data'],A,['cell_',num2str(iii),'']);


interval=[];
amount=[];
amount1=[];
amount_diff=[];
amount_revise=[];
bright_value_revise=[];
num1=[];
num_revise=[];
bright_value=[];
bright_value1=[];
select_enddata=[];
select_enddata1=[];
select_enddata_revise=[];
num=[];
single_position_data=[];
single_value_data=[];
single_average_data=[];
left=[];
right=[];
output_peak=[];
delete_data1=[];
delete_data2=[];
delete_data_total=[];
position=[];

end


total_data=[frequency' average_amplitude' interval_mean' interval_SD' mean_deltaD' mean_diameter'];
B = [{'Frequency(Hz)','Average_deltaD/D0','interval_mean(s)','interval_SD','mean_deltaD' 'mean_diameter'}; num2cell(total_data)];
%xlswrite([savepath,'Total_data'],B);

normal_data=[h0' h00' h000' h0000' h1' h11' h111' h1111' h2' h22' h222' h2222' h3' h33' h333' h3333'];
C = [{'lillietest_total','lillietest_3/4','lillietest1/2','lillietest1/4','kstest_total','kstest3/4','kstest1/2','kstest1/4'...
    'jbtest_total','jbtest3/4','jbtest1/2','jbtest1/4','chi2gof_total','chi2gof3/4','chi2gof1/2','chi2gof1/4'}; num2cell(normal_data)];
% xlswrite([savepath,'normal_distribution'],C);



%%计算deltaR/R0的左侧右侧的DTW参数

%  filename1='G:\20230131_deal_pdgAi96_Awake_anes_20221115_awakemouse_LJZ\Figure\图4_supplymentray\model_radius\radius_diameter_vasomotion_index\deltaR_R.xlsx'
%  end_data=xlsread(filename1);
%  data=end_data;
for k=1:size(data,2)/2
    time=[1.08:1.08:216]';
    diameter_green=end_data(:,2*k-1);
    diameter_red=end_data(:,2*k);
    diameter_green_raw=data(:,2*k-1);
    diameter_red_raw=data(:,2*k);
    [green_red_R(:,k),pval1(:,k)]=corr(diameter_green,diameter_red);
    [green_red_R_raw(:,k),pval2(:,k)]=corr(diameter_green_raw,diameter_red_raw);




    %average_deltaD/D0下的DTW距离
x_len2 = length(diameter_green);
y_len2 = length(diameter_red);
    figure(),
    plot(1.08:1.08:1.08*x_len2,diameter_green,'color','m','LineWidth',2);hold on
    plot(1.08:1.08:1.08*y_len2,diameter_red,'color',[1 0 0],'LineWidth',2);hold on
    %axis off;
    saveas(gca,[savepath,'green_red_',num2str(k),'.tif']);
    %计算两序列每个特征点的距离矩阵
    distance2 = zeros(x_len2,y_len2);
for ii2 = 1:x_len2
    for jj2=1:y_len2
        distance2(ii2,jj2) = (diameter_green(ii2)-diameter_red(jj2)).^2;
    end
end




%计算两个序列
DP2 = zeros(x_len2,y_len2);
DP2(1,1) = distance2(1,1);
for ii2=2:x_len2
    DP2(ii2,1) = distance2(ii2,1)+DP2(ii2-1,1);
end
for jj2=2:y_len2
    DP2(1,jj2) = distance2(1,jj2)+DP2(1,jj2-1);
end
for ii2=2:x_len2
    for jj2=2:y_len2
        DP2(ii2,jj2) = distance2(ii2,jj2) + GetMin(DP2(ii2-1,jj2),DP2(ii2,jj2-1),DP2(ii2-1,jj2-1));
    end
end

%回溯，找到各个特征点之间的匹配关系
ii2 = x_len2;
jj2 = y_len2;
while(~((ii2 == 1)&&(jj2==1)))
    plot([1.08*ii2,1.08*jj2],[diameter_green(ii2),diameter_red(jj2)],'b');hold on %画出匹配之后的特征点之间的匹配关系
    if(ii2==1)
        index_ii2 = 1;
        index_jj2 = jj2-1;
    elseif(jj2==1)
        index_ii2 = ii2-1;
        index_jj2 = 1;
    else
    [index_ii2,index_jj2] = GetMinIndex(DP2(ii2-1,jj2-1),DP2(ii2-1,jj2),DP2(ii2,jj2-1),ii2,jj2)
    end
    ii2 = index_ii2;
    jj2 = index_jj2;
    
end
 saveas(gca,[savepath,'green_red_line_',num2str(k),'.tif']);
 Total_distance(k)=DP2(end,end);




end

num=size(end_data,2)/2;
output_R_distance=[green_red_R;pval1;green_red_R_raw;pval2;Total_distance]';
% output_distance=[Total_distance_f;Total_distance_m];

C = [{'green_red_R','p_green_red','green_red_R_raw','p_green_red_raw','Total_DTW_distance'}; num2cell(output_R_distance)];
xlswrite([savepath,'R_distance_data'],C);

single_delta_D=[end_data];
% xlswrite([savepath,'single_delta_D'],single_delta_D);


