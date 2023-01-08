function[predicted_word]=WordPrediction_improve_5(run_data,num_samples_trial,num_repetition,class_model,stimulus_code_matrix,selected_channel_time,fre_length_resolution,norm_parameter,eigenvec,class_type)
% Input-      run_data:eeg data, *.set file
%             num_samples_trial : number of extracted samples per intensifications
%             num_repetition: number of repetitions per character
%             class_model: classification model
%             stimulus_code_matrix: character matrix
%             selected_channel_time: channels
%             selected_channel_fre: channels and frequency
%             fre_length_resolution: parameter to tune the frequency resolution
%             norm_parameter: normalization parameter

% Output-    predicted_word: predicted word of the run


sample_index=find(run_data.Flashing==1);
first_sample_index=sample_index(1:24:end);  % find the first samples of each intensification
num_stimulus=run_data.trialnr(end)/6;  % number of stimulus intensifications
num_nonStimulus=run_data.trialnr(end)-num_stimulus;  % number of non-stimulus intensifications
num_character=num_stimulus/30;  % number of characters of the predicted word

% temporal initialization
peak_sample=201;
find_peak_window_length=12;
average_window_length=10;

% frequency initialization
Fs=240;
N1=fre_length_resolution; % a parameter to be tuned, to tune the frequency resolution
% window=201-N1/2:201+N1/2; % samples around 333 ms
P3_signal_extraction_fre=201-38:201+38;
% normalization_signal_extraction=1:77;
frequenct_unit = Fs*(0:(fre_length_resolution/2))/fre_length_resolution;
fre_index=4;

% num_features=numel(selected_channel_time)+size(selected_channel_fre,1); % number of features
num_features=64*2;

predicted_word=[];


%% averaging across all columns and rows related to one assumed character
% figure;
for character_count=1:num_character  % loop for the whole word
    max_distance=-100;
    character_no=[1,7];
    intensification_no=12*15*(character_count-1)+1:12*15*character_count;
    index=first_sample_index(intensification_no);  % index of intensifications belonging to this character
    index_intensification=zeros(1,30);
    for i=1:6  % loops for all possible characters
        for j=7:12
            index_intensification_columns=index(find(run_data.StimulusCode(index)==i));
            index_intensification_rows=index(find(run_data.StimulusCode(index)==j));
            temp1=1:2:30;
            temp2=2:2:30;
            index_intensification(temp1)=index_intensification_columns;
            index_intensification(temp2)=index_intensification_rows;
            index_intensification=index_intensification(1:2*num_repetition);  % consider the number of repetitions
            time_course=zeros(num_samples_trial,64);
            for p=1:length(index_intensification)
                time_course_unit= run_data.signal(index_intensification(p)-num_samples_trial/3:index_intensification(p)+num_samples_trial/3*2-1,:);
                time_course=time_course+time_course_unit;
            end
            %             baseline=mean(time_course(1:num_samples_trial/3,:)/length(index_intensification));  % baseline correction
            %             time_course=time_course/length(index_intensification)-baseline;
            time_course=time_course/length(index_intensification);  % final averaged time-course for the assumed character
            
            %%%%%%%%%%%%%%%% plot test %%%%%%%%%%%%%%%%%%%%%%%%%
%                         Fs=240;
%                         time_vec=(-0.5:1/Fs:1-1/Fs)*1000;
%                         plot(time_vec,time_course(:,12)');
%                         axis([-500 1000 -400 400]);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %% time feature: averaged peak value
            window1=time_course(peak_sample-find_peak_window_length*0.5:peak_sample+find_peak_window_length*0.5,:);
            [peak_position,~]=find(window1==max(window1));
            peak_position=peak_position+peak_sample-find_peak_window_length*0.5-1;

            peak_slot_mean=[];
            for k=selected_channel_time
                %         baseline=mean(time_course(1:120,j));
                average_window=peak_position(k)-average_window_length*0.5:peak_position(k)+average_window_length*0.5;
                peak_slot_mean=[peak_slot_mean,mean(time_course(average_window,k))];
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %% frequency feature
            P_unknown_Stimulus_P3=[];
            for k=1:64
                signal_extracted_P3=time_course(P3_signal_extraction_fre,k)';
                signal_P3=signal_extracted_P3-mean(signal_extracted_P3);
                %                 signal_norm=time_course(normalization_signal_extraction,k)';
                %                 signal_norm=signal_norm-mean(signal_norm);
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
%                 Y1_norm=fft(signal_norm,N1);
%                 P1_norm = abs(Y1_norm/N1);
%                 P_norm = P1_norm(1:N1/2+1);
%                 P_norm(2:end-1) = 2*P_norm(2:end-1);
                
%                 Ps=[P_P3(1),P_P3(2:end)-log(P_P3(2:end)./P_norm(2:end))];
                
%                 fre_index=find(frequenct_unit==selected_channel_fre(k,2));
                frequency_selected=(P_P3(fre_index)+P_P3(fre_index+1))/2;
%                 frequency_selected=P_P3(fre_index);
                P_unknown_Stimulus_P3=[P_unknown_Stimulus_P3,frequency_selected];
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %% normalization and classification
            
            feat_vec=[peak_slot_mean,P_unknown_Stimulus_P3];
            for k=1:num_features/2
                feat_vec(k)=(feat_vec(k)-norm_parameter(k,1))/norm_parameter(k,2);
            end % the final feature vector before classification
            for k=num_features/2+1:num_features
                feat_vec(k)=(feat_vec(k)-norm_parameter(k-64,3))/norm_parameter(k-64,4);
            end % the final feature vector before classification
            [~,~,feat_vec_new]=FeatureReduction_LDA( feat_vec',0,[],eigenvec,'LDA','test' );
            if strcmp(class_type,'LDA')
                distance=Distance_ShrinkLDA(class_model,feat_vec_new);  % classification: measure the distance to hyperplane, LDA
            elseif strcmp(class_type,'SVM')
                distance = class_model.Beta' * feat_vec_new'+ class_model.Bias; % SVM distance measure
            end
            if distance>max_distance
                max_distance=distance;
                character_no=[i,j];
            end
        end
    end
    predicted_character=stimulus_code_matrix(character_no(2)-6,character_no(1));
    predicted_word=[predicted_word,predicted_character];
end


end


