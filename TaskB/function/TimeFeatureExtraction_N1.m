function[feature_mat_nonStimulus,feature_mat_Stimulus]=TimeFeatureExtraction_N1(run_data,num_samples_trial,num_repetition,peak_sample)
% P3 or N2

sample_index1=find(run_data.StimulusType==1);  % find the samples corresponding to the stimulus
sample_index2=find(run_data.Flashing==1); % find the samples corresponding to each intensification
sample_index3 = setdiff(sample_index2,sample_index1);  % find the samples corresponding to non-stimulus
first_sample_index_stimulus=sample_index1(1:24:end);  % find the first samples corresponding to the stimulus
first_sample_index_nonStimulus=sample_index3(1:24:end);  % find the first samples corresponding to the non-stimulus
num_stimulus=run_data.trialnr(end)/6;  % number of stimulus intensifications
num_nonStimulus=run_data.trialnr(end)-num_stimulus;  % number of non-stimulus intensifications


%%%%%%%%%%%%%%%%%%%%% 2 windows with peak detecting %%%%%%%%%%%%%%%%%%%%%%%
feature_mat_nonStimulus=[];
feature_mat_Stimulus=[];
find_peak_window_length=12;
average_window_length=10;

% Fs=240;
% time_vec=(-0.5:1/Fs:1-1/Fs)*1000; % time vector

%% stimulus
% figure;
for i=1:30:num_stimulus
    time_course=zeros(num_samples_trial,64); % 360*64
%     feature_vector=zeros(1,64*2);
    for j=0:2*num_repetition-1
        time_course_unit= run_data.signal(first_sample_index_stimulus(i+j)-num_samples_trial/3:first_sample_index_stimulus(i+j)+num_samples_trial/3*2-1,:);
        time_course=time_course+time_course_unit;
    end
    time_course=time_course/(num_repetition*2);
    window1=time_course(peak_sample-find_peak_window_length*0.5:peak_sample+find_peak_window_length*0.5,:);
    [peak_position,~]=find(window1==min(window1));
    peak_position=peak_position+peak_sample-find_peak_window_length*0.5-1;
    peak_slot_mean=zeros(1,64);
    for k=1:64
%         baseline=mean(time_course(1:120,k));
        average_window=peak_position(k)-average_window_length*0.5:peak_position(k)+average_window_length*0.5;
        peak_slot_mean(k)=mean(time_course(average_window,k));
    end
    feature_mat_Stimulus=[feature_mat_Stimulus;[peak_slot_mean,1]];  % stimulus with label 1
    
    % plot
    %     temp=time_course';
    %     plot(time_vec,temp(11,:));
    %     axis([-500 1000 -1000 1000]);
end

%% non-stimulus
% figure;
for i=1:150:num_nonStimulus
    time_course=zeros(num_samples_trial,64);
    for j=0:10*num_repetition-1
        time_course_unit= run_data.signal(first_sample_index_nonStimulus(i+j)-num_samples_trial/3:first_sample_index_nonStimulus(i+j)+num_samples_trial/3*2-1,:);
        time_course=time_course+time_course_unit;
    end
    time_course=time_course/(num_repetition*10);
    window1=time_course(peak_sample-find_peak_window_length*0.5:peak_sample+find_peak_window_length*0.5,:);
    [peak_position,~]=find(window1==min(window1));
    peak_position=peak_position+peak_sample-find_peak_window_length*0.5-1;
    %     window2_startPos=peak_position'+peak_sample-window_length*0.5-1-window_length*0.5;
    %     window2_endPos=peak_position'+peak_sample-1;
    peak_slot_mean=zeros(1,64);
    for j=1:64
%         baseline=mean(time_course(1:120,j));
        average_window=peak_position(j)-average_window_length*0.5:peak_position(j)+average_window_length*0.5;
        peak_slot_mean(j)=mean(time_course(average_window,j));
    end
    feature_mat_nonStimulus=[feature_mat_nonStimulus;[peak_slot_mean,-1]];
    
    % plot
    %     temp=time_course';
    %     plot(time_vec,temp(11,:));
    %     axis([-500 1000 -2000 2000]);
end

%% fixed window
% feature_mat_nonStimulus=[];
% feature_mat_Stimulus=[];
% window=188:208;
%
% for i=1:num_stimulus
%     time_course= run_data.signal(first_sample_index_stimulus(i)-num_samples_trial/3:first_sample_index_stimulus(i)+num_samples_trial/3*2-1,:);
%     peak_mean=mean(time_course(window,:),1);
%     feature_mat_Stimulus=[feature_mat_Stimulus;[peak_mean,1]];  % stimulus with label 1
% end
%
% for i=1:num_nonStimulus
%     time_course= run_data.signal(first_sample_index_nonStimulus(i)-num_samples_trial/3:first_sample_index_nonStimulus(i)+num_samples_trial/3*2-1,:);
%     peak_mean=mean(time_course(window,:),1);
%     feature_mat_nonStimulus=[feature_mat_nonStimulus;[peak_mean,-1]];
% end

end