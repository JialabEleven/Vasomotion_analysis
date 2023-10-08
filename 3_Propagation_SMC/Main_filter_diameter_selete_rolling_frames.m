clear all;
clc;
cur_p1 = mfilename('fullpath');%获得现在所打开的文件的路径
i=strfind(cur_p1,'\');%匹配 \
cur_p=cur_p1(1:i(end-1));   
buildingDir = fullfile([cur_p '3_Propagation_SMC\diameter.xlsx']);
savepath = fullfile([cur_p '3_Propagation_SMC\Results of rolling_data\']);


a=xlsread(buildingDir);
m=1;
cycle=25;%循环的个数，单数

%%原数据的窗口滑动评判
for k=1:(size(a,2)-cycle+1)
    t=(cycle+1)/2;
    ordinate=k+t-1;%循环的中心位置
    b=a(:,ordinate);
    rolling_window=(cycle-1)/2;%滑动窗口的数量为6，往左六，往右六
    for kk=1:rolling_window
        bb(:,kk)=a(:,ordinate-kk);
        correl_raw_left(kk)=corr(b,bb(:,kk));
        cc(:,kk)=a(:,ordinate+kk);
        correl_raw_right(kk)=corr(b,cc(:,kk));
    end
    correl_raw_medium=corr(b,b);
    correl_raw_left_revise=fliplr(correl_raw_left);
    R_value_rolling(:,k)=[correl_raw_left_revise correl_raw_medium correl_raw_right];
    %需要把元素列到同一行输出
    figure(),plot(R_value_rolling(:,k));
    grid on

    xlabel('Distance(um)','Fontsize',12)

    ylabel('R_value','Fontsize',12)

    saveas(gca,[savepath,'Rolling_R_value',num2str(k),'.tif']);
end 
for q=1:(size(a,2)-cycle+1)
    p=(cycle+1)/2;
    ordinate1=q+p-1;%循环的中心位置
    b1=a(:,ordinate1);
    b1=smoothdata(b1,'gaussian',5);
    rolling_window=(cycle-1)/2;%滑动窗口的数量为6，往左六，往右六
    for qq=1:rolling_window
        bb1(:,qq)=a(:,ordinate1-qq);
        bb1(:,qq)=smoothdata(bb1(:,qq),'gaussian',5);
        correl_raw_left1(qq)=corr(b1,bb1(:,qq));
        cc1(:,qq)=a(:,ordinate1+qq);
        correl_raw_right1(qq)=corr(b1,cc1(:,qq));
    end
    correl_raw_medium1=corr(b1,b1);
    correl_raw_left_revise1=fliplr(correl_raw_left1);
    R_value_rolling1(:,q)=[correl_raw_left_revise1 correl_raw_medium1 correl_raw_right1];
end 


 output=[R_value_rolling];
 xlswrite([savepath,'information_R_value'],output);


