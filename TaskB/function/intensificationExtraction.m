function [time_course_stimulus_allChannel, time_course_nonStimulus_allChannel,num_nonStimulus,num_stimulus]= intensificationExtraction(run_data,num_samples_trial)
% Input-     run_data:              clean eeg, *.set file
%            num_samples_trial:     extracted samples per intensification
%
% Output-    time_course_stimulus_allChannel: averaged time-course of all stimulus, channels*360
%            time_course_stimulus_allChannel: averaged time-course of all non-stimulus, channels*360
%            num_nonStimulus:  number of all non-stimulus intensifications in this run 
%            num_stimulus: number of all stimulus intensifications in this run 

% to be improved!! take number of repetitions into account!!

sample_index1=find(run_data.StimulusType==1);  % find the samples corresponding to the stimulus
sample_index2=find(run_data.Flashing==1);
sample_index3 = setdiff(sample_index2,sample_index1);   % find the samples corresponding to the non-stimulus
first_sample_index_stimulus=sample_index1(1:24:end);  % find the first samples corresponding to the stimulus
first_sample_index_nonStimulus=sample_index3(1:24:end);  % find the first samples corresponding to the non-stimulus
num_stimulus=run_data.trialnr(end)/6;  % number of stimulus intensifications
num_nonStimulus=run_data.trialnr(end)-num_stimulus;  % number of non-stimulus intensifications

time_course_stimulus_allChannel=zeros(64,num_samples_trial);
time_course_nonStimulus_allChannel=zeros(64,num_samples_trial);
% stimulus_slot=0;
% nonStimulus_slot=0;
for i=1:num_nonStimulus
    index=first_sample_index_nonStimulus(i);
    time_course_nonStimulus_allChannel=time_course_nonStimulus_allChannel+(run_data.signal(index-num_samples_trial/3:index+num_samples_trial/3*2-1,:))';
%     for j=1:64
%     time_course_nonStimulus_allChannel(j,:)=time_course_nonStimulus_allChannel(j,:)+(run_data.signal(index-num_samples_trial/3:index+num_samples_trial/3*2-1,j))';
%     end
end

for i=1:num_stimulus
    index=first_sample_index_stimulus(i);
    time_course_stimulus_allChannel=time_course_stimulus_allChannel+(run_data.signal(index-num_samples_trial/3:index+num_samples_trial/3*2-1,:))';
%     for j=1:64
%         time_course_stimulus_allChannel(j,:)=time_course_stimulus_allChannel(j,:)+(run_data.signal(index-num_samples_trial/3:index+num_samples_trial/3*2-1,j))';
%     end
end

time_course_nonStimulus_allChannel=time_course_nonStimulus_allChannel/num_nonStimulus;
time_course_stimulus_allChannel=time_course_stimulus_allChannel/num_stimulus;

end