% Task B
% methodology 2

clc;clear;
close all;
eeglab;

%% mode selection
classification_type='LDA'; % select LDA or SVM
num_repetition=15;         % number of repetitions per character: 1,...,15

%% initialization
addpath(strcat(pwd,'\function'));
addpath(strcat(pwd,'\raw runs'));
addpath(strcat(pwd,'\mydata\improve_5'));

channel_location=pop_loadset('s10r01.set').chanlocs;

frequency_resolution_length=240; % parameter to tune the frequency resolution
num_samples_intensification=360;
stimulus_code_matrix=[ 'A','B','C','D','E','F';
    'G','H','I','J','K','L';
    'M','N','O','P','Q','R';
    'S','T','U','V','W','X';
    'Y','Z','1','2','3','4';
    '5','6','7','8','9','_'];
%% load all training data
runs_group=cell(1,11);
count=1;
for i=10:11
    if i==10
        num_file=5;
    else
        num_file=6;
    end
    for j=1:num_file
        clean_data_file=['s',num2str(i),'r0',num2str(j),'.set'];
        eeg=pop_loadset(clean_data_file);
        clean_signal=eeg.data;
        raw_run_file=['AAS0',num2str(i),'R0',num2str(j),'.mat'];
        run=load(raw_run_file);
        run.signal=clean_signal';
        runs_group{count}=run; % save all processed data in a cell
        count=count+1;
    end
end

%% average temproal analysis across all runs
sum_nonStimulus=zeros(64,num_samples_intensification);  % channels*360
sum_stimulus=zeros(64,num_samples_intensification);
total_num_nonStimulus=0;
total_num_stimulus=0;


for i=1:11
    run=runs_group{i};
    [time_course_stimulus_allChannel, time_course_nonStimulus_allChannel,num_nonStimulus,num_stimulus]= intensificationExtraction(run,num_samples_intensification);
    sum_nonStimulus=sum_nonStimulus+time_course_nonStimulus_allChannel*num_nonStimulus;
    sum_stimulus=sum_stimulus+time_course_stimulus_allChannel*num_stimulus;
    total_num_nonStimulus=total_num_nonStimulus+num_nonStimulus;
    total_num_stimulus=total_num_stimulus+num_stimulus;
end

average_nonStimulus=sum_nonStimulus/total_num_nonStimulus;
average_stimulus=sum_stimulus/total_num_stimulus; % channels*samples

%% visulization
% plot time-course
% Since the response to the stimulus overlaps with subsequent trials, the
% time-course has a small peak about every 175 ms. But the peak around
% 300ms (P3) remains to be significant when stimulus appears.

Fs=240;
time_vec=(-0.5:1/Fs:1-1/Fs)*1000; % time vector
figure;
plot(time_vec,average_stimulus(11,:),'b'); hold on;
plot(time_vec,average_nonStimulus(11,:),'r'); hold on;
title('time course at channel Cz');
xlabel('time-course[ms]');
ylabel('signal amplitude');
axis([-500 1000 -300 300]);
grid on;
legend('Stimulus','nonStimulus');

% topographic visulization around 201st and 146th sample
figure;
subplot(2,2,1);topoplot(average_stimulus(:,201),channel_location,'maplimits',[-200 200]);title('stimulus P3');
subplot(2,2,2);topoplot(average_nonStimulus(:,201),channel_location,'maplimits',[-200 200]);title('nonStimulus P3');
subplot(2,2,3);topoplot(average_stimulus(:,146),channel_location,'maplimits',[-80 80]);title('stimulus N1');
subplot(2,2,4);topoplot(average_nonStimulus(:,146),channel_location,'maplimits',[-80 80]);title('nonStimulus N1');
%% time feature extraction
%%%%%%%%%%%%%%% time features around 333.3 ms (201th sample) for P3 %%%%%%%%%%%%%%%%%%%
averaged_peak_sample_P3=201;
feature_mat_nonStimulus_temporal_P3=[];
feature_mat_stimulus_temporal_P3=[];
for i=1:11
    run=runs_group{i};
    [feature_unitmat_nonStimulus_central_P3,feature_unitmat_stimulus_central_P3]=TimeFeatureExtraction(run,num_samples_intensification,num_repetition,averaged_peak_sample_P3);
    
    
    feature_mat_nonStimulus_temporal_P3=[feature_mat_nonStimulus_temporal_P3;feature_unitmat_nonStimulus_central_P3];
    feature_mat_stimulus_temporal_P3=[feature_mat_stimulus_temporal_P3;feature_unitmat_stimulus_central_P3];
end
feature_mat_P3=[feature_mat_nonStimulus_temporal_P3;feature_mat_stimulus_temporal_P3];

%%%%%%%%%%%%%%% time features around 95.8 ms (146th sample) for N1 %%%%%%%%%%%%%%%%%%%
averaged_peak_sample_N1=146;
feature_mat_nonStimulus_temporal_N1=[];
feature_mat_stimulus_temporal_N1=[];
for i=1:11
    run=runs_group{i};
    [feature_unitmat_nonStimulus_central_N1,feature_unitmat_stimulus_central_N1]=TimeFeatureExtraction_N1(run,num_samples_intensification,num_repetition,averaged_peak_sample_N1);
    
    
    feature_mat_nonStimulus_temporal_N1=[feature_mat_nonStimulus_temporal_N1;feature_unitmat_nonStimulus_central_N1];
    feature_mat_stimulus_temporal_N1=[feature_mat_stimulus_temporal_N1;feature_unitmat_stimulus_central_N1];
end
feature_mat_N1=[feature_mat_nonStimulus_temporal_N1;feature_mat_stimulus_temporal_N1];


%% time feature evaluation
%%%%%%%%%%%%%%%%%% P3 %%%%%%%%%%%%%%%%%%%%%%%%
feat_mat_P3=feature_mat_P3(:,1:end-1);
labels=feature_mat_P3(:,end);
[fisher_criterion_P3,rank_P3]=fisherrank(feat_mat_P3,labels);  % feature evaluation based on Fisher criterion
figure;
subplot(1,2,1);plot(sort(fisher_criterion_P3,'descend'));
title('temporal analysis for all channels P3');
xlabel('ranked features');
ylabel('fisher score');
axis([0 65 0 18]);
grid on;

% scatter plot for 2 best features
best_feature_1_index_P3=rank_P3(1);
best_feature_2_index_P3=rank_P3(2);
best_feature_3_index_P3=36;
best_feature_4_index_P3=51;
% selected_channel=[best_feature_1_index_P3,best_feature_2_index_P3,best_feature_3_index_P3];

subplot(1,2,2);
plot(feature_mat_nonStimulus_temporal_P3(:,best_feature_1_index_P3),feature_mat_nonStimulus_temporal_P3(:,best_feature_2_index_P3),'r*');hold on;
plot(feature_mat_stimulus_temporal_P3(:,best_feature_1_index_P3),feature_mat_stimulus_temporal_P3(:,best_feature_2_index_P3),'g*');hold on;
xlabel('1.best time feature');
ylabel('2.best time feature');
grid on;
legend('nonStimulus: -1','Stimulus: 1');

%%%%%%%%%%%%%%%%%% N1 %%%%%%%%%%%%%%%%%%%%%%%%
feat_mat_N1=feature_mat_N1(:,1:end-1);
labels=feature_mat_N1(:,end);
[fisher_criterion_N1,rank_N1]=fisherrank(feat_mat_N1,labels);  % feature evaluation based on Fisher criterion
figure;
subplot(1,2,1);plot(sort(fisher_criterion_N1,'descend'));
title('temporal analysis for all channels N1');
xlabel('ranked features');
ylabel('fisher score');
axis([0 65 0 18]);
grid on;

% scatter plot for 2 best features
best_feature_1_index_N2=rank_N1(1);
best_feature_2_index_N2=rank_N1(2);

subplot(1,2,2);
plot(feature_mat_nonStimulus_temporal_N1(:,best_feature_1_index_N2),feature_mat_nonStimulus_temporal_N1(:,best_feature_4_index_P3),'r*');hold on;
plot(feature_mat_stimulus_temporal_N1(:,best_feature_1_index_N2),feature_mat_stimulus_temporal_N1(:,best_feature_4_index_P3),'g*');hold on;
xlabel('1.best time feature');
ylabel('2.best time feature');
grid on;
legend('nonStimulus: -1','Stimulus: 1');
%% frequency analysis
frequenct_unit = Fs*(0:(frequency_resolution_length/2))/frequency_resolution_length;
frequency_resolution=frequenct_unit(2)-frequenct_unit(1);

%%%%%%%%%%%%%%%% central channels %%%%%%%%%%%%%%%%%%%%%%
fre_feature_mat_nonStimulus_central=[];
fre_feature_mat_stimulus_central=[];
frequency_candidate_channel_Central=[3 4 5 10 11 12 17 18 19];
for i=1:11
    run=runs_group{i};
    [feature_unitmat_nonStimulus_central_P3,feature_unitmat_stimulus_central_P3]=FrequencyFeatureExtraction_improve_2_v2(run,num_samples_intensification,num_repetition,frequency_resolution_length,frequency_candidate_channel_Central);
    fre_feature_mat_nonStimulus_central=[fre_feature_mat_nonStimulus_central;feature_unitmat_nonStimulus_central_P3];
    fre_feature_mat_stimulus_central=[fre_feature_mat_stimulus_central;feature_unitmat_stimulus_central_P3];
end
fre_feature_mat_central=[fre_feature_mat_nonStimulus_central;fre_feature_mat_stimulus_central];

%%%%%%%%%%%%%%%% frontal and posterior channels (FaP) %%%%%%%%%%%%%%%%%%%%
fre_feature_mat_nonStimulus_FaP=[];
fre_feature_mat_stimulus_FaP=[];
frequency_candidate_channel_FaP=[33 34 35 50 51 52];
for i=1:11
    run=runs_group{i};
    [feature_unitmat_nonStimulus_FaP,feature_unitmat_stimulus_FaP]=FrequencyFeatureExtraction_improve_2_v2(run,num_samples_intensification,num_repetition,frequency_resolution_length,frequency_candidate_channel_FaP);
    fre_feature_mat_nonStimulus_FaP=[fre_feature_mat_nonStimulus_FaP;feature_unitmat_nonStimulus_FaP];
    fre_feature_mat_stimulus_FaP=[fre_feature_mat_stimulus_FaP;feature_unitmat_stimulus_FaP];
end
fre_feature_mat_FaP=[fre_feature_mat_nonStimulus_FaP;fre_feature_mat_stimulus_FaP];

%% frequency feature evaluation
%%%%%%%%%%%%%%% central channels %%%%%%%%%%%%%%%%%%%%%%
fre_feat_mat_central=fre_feature_mat_central(:,1:end-1);
labels=fre_feature_mat_central(:,end);
[fre_fisher_criterion_central,fre_rank_central]=fisherrank(fre_feat_mat_central,labels);  % feature evaluation based on Fisher criterion
figure;
subplot(1,2,1);plot(sort(fre_fisher_criterion_central,'descend'));
title('frequency analysis for central channels');
xlabel('ranked features');
ylabel('fisher score');
axis([0 100 0 10]);
grid on;

% scatter plot for 2 best features
fre_best_feature_1_index_central=fre_rank_central(1);
fre_best_feature_2_index_central=fre_rank_central(2);
subplot(1,2,2);
plot(fre_feature_mat_nonStimulus_central(:,fre_best_feature_1_index_central),fre_feature_mat_nonStimulus_central(:,fre_best_feature_2_index_central),'r*');hold on;
plot(fre_feature_mat_stimulus_central(:,fre_best_feature_1_index_central),fre_feature_mat_stimulus_central(:,fre_best_feature_2_index_central),'g*');hold on;
xlabel('1.best fre feature');
ylabel('2.best fre feature');
grid on;
legend('nonStimulus: -1','Stimulus: 1');

% frequency feature 
best_frequency_channel_central=frequency_candidate_channel_Central(ceil(fre_best_feature_1_index_central/length(frequenct_unit)));
best_frequency_central=frequenct_unit(mod(fre_best_feature_1_index_central,length(frequenct_unit)));
% best_frequency_index=mod(fre_best_feature_1_index,numel(frequenct_unit));
% best_frequency_band_index=[best_frequency_index-1,best_frequency_index,best_frequency_index+1];

%%%%%%%%%%%%%%%% frontal and posterior channels (FaP) %%%%%%%%%%%%%%%%%%%%
% force channel 34
fre_feat_mat_FaP=fre_feature_mat_FaP(:,1:end-1);
labels=fre_feature_mat_FaP(:,end);
[fre_fisher_criterion_FaP,fre_rank_FaP]=fisherrank(fre_feat_mat_FaP,labels);  % feature evaluation based on Fisher criterion
figure;
subplot(1,2,1);plot(sort(fre_fisher_criterion_FaP,'descend'));
title('frequency analysis for FaP channels');
xlabel('ranked features');
ylabel('fisher score');
axis([0 100 0 10]);
grid on;

% scatter plot for 2 best features
fre_best_feature_1_index_FaP=fre_rank_FaP(1);
fre_best_feature_2_index_FaP=fre_rank_FaP(2);
subplot(1,2,2);
plot(fre_feature_mat_nonStimulus_FaP(:,fre_best_feature_1_index_FaP),fre_feature_mat_nonStimulus_FaP(:,fre_best_feature_2_index_FaP),'r*');hold on;
plot(fre_feature_mat_stimulus_FaP(:,fre_best_feature_1_index_FaP),fre_feature_mat_stimulus_FaP(:,fre_best_feature_2_index_FaP),'g*');hold on;
xlabel('1.best fre feature');
ylabel('2.best fre feature');
grid on;
legend('nonStimulus: -1','Stimulus: 1');

% %%%%%%%%%%%%%% comparision between stimulus and non-stimulus %%%%%%%%%%%%%
figure;
num_bins=0.5*frequency_resolution_length+1;
fre_band_Stimulus_p3=mean(fre_feature_mat_stimulus_central(:,4*num_bins+1:5*num_bins),1);
fre_band_nonStimulus_p3=mean(fre_feature_mat_nonStimulus_central(:,4*num_bins+1:5*num_bins),1);
plot(frequenct_unit,fre_band_Stimulus_p3,'g'); hold on;
plot(frequenct_unit,fre_band_nonStimulus_p3,'r'); hold on;
title('frequency comaprision around P3 in Cz');
legend('Stimulus','nonStimulus');
% 
% % frequency feature 
% best_frequency_channel_FaP=frequency_candidate_channel_FaP(ceil(fre_best_feature_1_index_FaP/length(frequenct_unit)));
% best_frequency_FaP=frequenct_unit(mod(fre_best_feature_2_index_FaP,length(frequenct_unit)));
% 
% %%%%%%%%%%%%%%%%%%%%%%%%% combine frequency features %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % selected_channel_frequency=[best_frequency_channel_central,best_frequency_central;
% %                              best_frequency_channel_FaP,best_frequency_FaP];
% selected_channel_frequency=[best_frequency_channel_central,best_frequency_central]; % only central channels are chosen for frequency feature
% % selected_channel_frequency=[];
%% extract 3Hz and 4Hz in all channels
fre_feature_mat_nonStimulus=[];
fre_feature_mat_stimulus=[];
frequency_candidate_channel=1:64;
for i=1:11
    run=runs_group{i};
    [feature_unitmat_nonStimulus_P3,feature_unitmat_stimulus_P3]=FrequencyFeatureExtraction_fre(run,num_samples_intensification,num_repetition,frequency_resolution_length,frequency_candidate_channel,3);
    fre_feature_mat_nonStimulus=[fre_feature_mat_nonStimulus;feature_unitmat_nonStimulus_P3];
    fre_feature_mat_stimulus=[fre_feature_mat_stimulus;feature_unitmat_stimulus_P3];
end
fre_feature_mat_all_channel=[fre_feature_mat_nonStimulus;fre_feature_mat_stimulus];
fre_feature_mat_all_channel=fre_feature_mat_all_channel(:,1:end-1);
%% set up classification model and normaliztion
% temporal
normalization_parameter_mean_time=[];
normalization_parameter_std_time=[];
feat_mat_normalized_time=[];
for i=1:size(feat_mat_P3,2)
    normalization_parameter_mean_time=[normalization_parameter_mean_time;mean(feat_mat_P3(:,i))];
    normalization_parameter_std_time=[normalization_parameter_std_time;std(feat_mat_P3(:,i),0,'all')];
    feat_normalized=(feat_mat_P3(:,i)-mean(feat_mat_P3(:,i)))/std(feat_mat_P3(:,i),0,'all');
    feat_mat_normalized_time=[feat_mat_normalized_time feat_normalized];
end

% spectural
normalization_parameter_mean_fre=[];
normalization_parameter_std_fre=[];
feat_mat_normalized_fre=[];
for i=1:size(fre_feature_mat_all_channel,2)
    normalization_parameter_mean_fre=[normalization_parameter_mean_fre;mean(fre_feature_mat_all_channel(:,i))];
    normalization_parameter_std_fre=[normalization_parameter_std_fre;std(fre_feature_mat_all_channel(:,i),0,'all')];
    feat_normalized=(fre_feature_mat_all_channel(:,i)-mean(fre_feature_mat_all_channel(:,i)))/std(fre_feature_mat_all_channel(:,i),0,'all');
    feat_mat_normalized_fre=[feat_mat_normalized_fre feat_normalized];
end
normalization_parameter=[normalization_parameter_mean_time,normalization_parameter_std_time,normalization_parameter_mean_fre,normalization_parameter_std_fre];

% feature reduction LDA
[egnValSort,egnVecSort,new_features ] = FeatureReduction_LDA( [feat_mat_normalized_time,feat_mat_normalized_fre]',labels,[],[],'LDA','train' );

% classification model
if strcmp(classification_type,'LDA')
    lambda=0.5;
    class_model=trainShrinkLDA(new_features',labels,lambda); % train LDA model
elseif strcmp(classification_type,'SVM')
    class_model=fitcsvm(new_features',labels);      % train SVM model
% elseif strcmp(classification_type,'KNN')
%     class_model=fitcknn(new_features',labels,'NumNeighbors',5);      % train knn model
end

    
%% cross-validation
% 10 runs as training data, 1 run as test data
% a standard process, doesn't require any change
cross_validation_result=cell(1,11);
num_character_per_word=[0;3;3;4;5;4;3;3;5;5;4;3;];
% normalization_parameter=[normalization_parameter_mean_time,normalization_parameter_std_time];
selected_channel=1:64;
feat_mat_val=[feat_mat_P3,fre_feature_mat_all_channel];
for i=1:11  % i-th run as test data
    feature_mat_nonStimulus_temporal_P3=[];  % rows: 2*number of characters, column:2+1
    feature_mat_stimulus_temporal_P3=[];
    feat_mat_normalized_val=[];
    test_run=runs_group{i};
    index_interval=sum(num_character_per_word(1:i))+1:sum(num_character_per_word(1:i+1));
    temp=[feat_mat_val,labels];
    temp1=[feat_mat_val(1:42,:),labels(1:42,:)];
    temp2=[feat_mat_val(43:end,:),labels(43:end,:)];
    mat_val_1=temp1(index_interval,:);
    mat_val_2=temp2(index_interval,:);
    [feature_mat_CrossValidation,~]=setdiff(temp,[mat_val_1;mat_val_2],'rows','stable'); % not robust enough
    for j=1:size(feature_mat_CrossValidation,2)-1
        feat_normalized_val=(feature_mat_CrossValidation(:,j)-mean(feature_mat_CrossValidation(:,j)))/std(feature_mat_CrossValidation(:,j),0,'all');
        feat_mat_normalized_val=[feat_mat_normalized_val feat_normalized_val];
    end
    [egnValSort_val,egnVecSort_val,new_features_val ] = FeatureReduction_LDA( feat_mat_normalized_val',feature_mat_CrossValidation(:,end),[],[],'LDA','train' );
    if strcmp(classification_type,'LDA')
        class_model_CrossValidation=trainShrinkLDA(new_features_val',feature_mat_CrossValidation(:,end),lambda); % train LDA model
    elseif strcmp(classification_type,'SVM')
        class_model_CrossValidation=fitcsvm(new_features_val',feature_mat_CrossValidation(:,end));      % train SVM model
%     elseif strcmp(classification_type,'KNN')
%         class_model_CrossValidation=fitcknn(new_features_val',feature_mat_CrossValidation(:,end),'NumNeighbors',5);      % train knn model
    end
    predicted_word=WordPrediction_improve_5(test_run,num_samples_intensification,num_repetition,class_model_CrossValidation,stimulus_code_matrix,selected_channel,frequency_resolution_length,normalization_parameter,egnVecSort_val,classification_type);
    cross_validation_result{1,i}=predicted_word;
end

%% noval session prediction
% load noval runs
runs_group_noval=cell(1,8);
count=1;
for i=1:8
    clean_data_file=['s12r0',num2str(i),'.set'];
    eeg=pop_loadset(clean_data_file);
    clean_signal=eeg.data;
    raw_run_file=['AAS012R0',num2str(i),'.mat'];
    run=load(raw_run_file);
    run.signal=clean_signal';
    runs_group_noval{count}=run; % save all processed data in a cell
    count=count+1;
end

% noval words prediction
selected_channel=1:64;
predicted_word_noval=cell(1,8);
for i=1:8
    predicted_word_noval{i}=WordPrediction_improve_5(runs_group_noval{i},num_samples_intensification,num_repetition,class_model,stimulus_code_matrix,selected_channel,frequency_resolution_length,normalization_parameter,egnVecSort,classification_type);
end

%% print results
fprintf('cross-validation results:\n');
for i=1:11
    fprintf('%s\n',cross_validation_result{i});
end

fprintf('session 12 prediction results:\n');
for i=1:8
    fprintf('%s\n',predicted_word_noval{i});
end


