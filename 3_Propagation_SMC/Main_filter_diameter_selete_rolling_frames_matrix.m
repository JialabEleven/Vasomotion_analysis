clear all;
clc;
cur_p1 = mfilename('fullpath');%获得现在所打开的文件的路径
i=strfind(cur_p1,'\');%匹配 \
cur_p=cur_p1(1:i(end-1));   
buildingDir = fullfile([cur_p '3_Propagation_SMC\diameter.xlsx']);
savepath = fullfile([cur_p '3_Propagation_SMC\Results of rolling_data_matrix\']);
a=xlsread(buildingDir);
m=1;
cycle=25;%循环的个数，单数

%%原数据的窗口滑动评判
for k=1:(size(a,2)-cycle+1)
    t=(cycle+1)/2;
    ordinate=k+t-1;%循环的中心位置
    b=a(:,ordinate);
    rolling_window=(cycle-1)/2;
    for kk=1:rolling_window
        bb(:,kk)=a(:,ordinate-kk);
        cc(:,kk)=a(:,ordinate+kk);
    end
    bb_revise=fliplr(bb);
    rolling_matrix=[bb_revise b cc];
    for i=1:size(rolling_matrix,2)
        for j=1:size(rolling_matrix,2)
            m=rolling_matrix(:,i);
            n=rolling_matrix(:,j);
            correl_raw(i,j)=corr(m,n);
        end
    end
    output_data(:,:,k)=correl_raw;
end 

output_total=zeros(25);
for ii=1:size(output_data,3)
    output_divide(:,:)=output_data(:,:,ii);
    output_total=output_total+output_divide;
end
output_average=output_total/(size(output_data,3));

for jj=1:size(output_data,3)
    %A = [{'D','D0','deltaF/F0','peak_position','delta_radius_value','peak_deltaD/D0'}; num2cell(output)];
    xlswrite([savepath,'single_data'],output_data(:,:,jj),['cell_',num2str(jj),'']);
end

  xlswrite([savepath,'R_value_rolling'],output_average);

colorbar;
XVarNames = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'};
matrixplot(output_average,'XVarNames',XVarNames,'YVarNames',XVarNames,'TextColor',[0.3,0.3,0.3],'ColorBar','on');
set(gca,'CLim',[0,1]);%固定colorbar以用于比较
hold off
saveas(gca,[savepath,'model_matrix.tif']);

