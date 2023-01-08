function[frequency_mat_nonStimulus,frequency_mat_Stimulus]=FrequencyFeatureExtraction_improve_2_v2(run_data,num_samples_trial,num_repetition,signal_length,candidate_channel)
%%
sample_index1=find(run_data.StimulusType==1);  % find the samples corresponding to the stimulus
sample_index2=find(run_data.Flashing==1);
sample_index3 = setdiff(sample_index2,sample_index1);
first_sample_index_stimulus=sample_index1(1:24:end);  % find the first samples corresponding to the stimulus
first_sample_index_nonStimulus=sample_index3(1:24:end);  % find the first samples corresponding to the non-stimulus
num_stimulus=run_data.trialnr(end)/6;  % number of stimulus intensifications
num_nonStimulus=run_data.trialnr(end)-num_stimulus;  % number of non-stimulus intensifications


%%
frequency_mat_Stimulus=[];
frequency_mat_nonStimulus=[];

% Fs=240;
N1=signal_length; % a parameter to be tuned, to tune the frequency resolution
% window=201-N1/2:201+N1/2; % samples around 333 ms
P3_signal_extraction=201-38:201+38;
% normalization_signal_extraction=1:77;

% figure;
%% stimulus
for i=1:30:num_stimulus
    time_course=zeros(num_samples_trial,64);
    for j=0:num_repetition*2-1
        time_course_unit= run_data.signal(first_sample_index_stimulus(i+j)-num_samples_trial/3:first_sample_index_stimulus(i+j)+num_samples_trial/3*2-1,:);
        time_course=time_course+time_course_unit;
    end
    %         baseline=mean(time_course(1:num_samples_trial/3,:)/(num_repetition*2),1);  % baseline correction
    %         time_course=time_course/(num_repetition*2)-baseline;
    time_course=time_course/(num_repetition*2);  % averaged
    %%%%%%%%%%%%%%%% plot test %%%%%%%%%%%%%%%%%%%%%%%%%
%     Fs=240;
%     time_vec=(-0.5:1/Fs:1-1/Fs)*1000;
%     plot(time_vec,time_course(:,12)');
%     axis([-500 1000 -400 400]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     time_course=time_course-mean(time_course,1);
    P_Stimulus_P3=[];
    for k=candidate_channel
        signal_extracted_P3=time_course(P3_signal_extraction,k)';
        signal_P3=signal_extracted_P3-mean(signal_extracted_P3);
        signal_P3_mirror_extend=[signal_P3,fliplr(signal_P3(1:end-1))];
        for count=1:2
            signal_P3_mirror_extend=[signal_P3_mirror_extend,fliplr(signal_P3_mirror_extend(1:end-1))];
        end
        signal_P3_mirror_extend=signal_P3_mirror_extend(1:N1);
        signal_P3_mirror_extend=signal_P3_mirror_extend-mean(signal_P3_mirror_extend);

        
        % P3 fft
        Y1_P3=fft(signal_P3_mirror_extend);
        P1_P3 = abs(Y1_P3/N1);
        P_P3 = P1_P3(1:N1/2+1);
        P_P3(2:end-1) = 2*P_P3(2:end-1);
        
        % normalization fft
%         Y1_norm=fft(signal_norm,N1);
%         P1_norm = abs(Y1_norm/N1);
%         P_norm = P1_norm(1:N1/2+1);
%         P_norm(2:end-1) = 2*P_norm(2:end-1);
        
        % normalization
%         Ps=[P_P3(1),P_P3(2:end)-log(P_P3(2:end)./P_norm(2:end))];
        
        P_Stimulus_P3=[P_Stimulus_P3,P_P3];
    end
    frequency_mat_Stimulus=[frequency_mat_Stimulus;[P_Stimulus_P3,1]];  % stimulus with label 1
end

%% non-stimulus
for i=1:150:num_nonStimulus
    time_course=zeros(num_samples_trial,64);
    for j=0:num_repetition*10-1
        time_course_unit= run_data.signal(first_sample_index_nonStimulus(i+j)-num_samples_trial/3:first_sample_index_nonStimulus(i+j)+num_samples_trial/3*2-1,:);
        time_course=time_course+time_course_unit;
    end
    %         baseline=mean(time_course(1:num_samples_trial/3,:)/(num_repetition*2),1);  % baseline correction
    %         time_course=time_course/(num_repetition*2)-baseline;
    time_course=time_course/(num_repetition*10);
    %%%%%%%%%%%%%%%% plot test %%%%%%%%%%%%%%%%%%%%%%%%%
%     Fs=240;
%     time_vec=(-0.5:1/Fs:1-1/Fs)*1000;
%     plot(time_vec,time_course(:,12)');
%     axis([-500 1000 -400 400]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     time_course=time_course-mean(time_course,1);
    P_nonStimulus_P3=[];
    for k=candidate_channel
        signal_extracted_P3=time_course(P3_signal_extraction,k)';
        signal_P3=signal_extracted_P3-mean(signal_extracted_P3);
%         signal_norm=time_course(normalization_signal_extraction,k)';
%         signal_norm=signal_norm-mean(signal_norm);
        signal_P3_mirror_extend=[signal_P3,fliplr(signal_P3(1:end-1))];
        for count=1:2
            signal_P3_mirror_extend=[signal_P3_mirror_extend,fliplr(signal_P3_mirror_extend(1:end-1))];
        end
        signal_P3_mirror_extend=signal_P3_mirror_extend(1:N1);
        signal_P3_mirror_extend=signal_P3_mirror_extend-mean(signal_P3_mirror_extend);


        
        % P3 fft
        Y1_P3=fft(signal_P3_mirror_extend);
        P1_P3 = abs(Y1_P3/N1);
        P_P3 = P1_P3(1:N1/2+1);
        P_P3(2:end-1) = 2*P_P3(2:end-1);
        
        % normalization fft
%         Y1_norm=fft(signal_norm,N1);
%         P1_norm = abs(Y1_norm/N1);
%         P_norm = P1_norm(1:N1/2+1);
%         P_norm(2:end-1) = 2*P_norm(2:end-1);
        
        % normalization
%         Ps=[P_P3(1),P_P3(2:end)-log(P_P3(2:end)./P_norm(2:end))];
            
        P_nonStimulus_P3=[P_nonStimulus_P3,P_P3];
        
    end
    frequency_mat_nonStimulus=[frequency_mat_nonStimulus;[P_nonStimulus_P3,-1]];
    
end
end