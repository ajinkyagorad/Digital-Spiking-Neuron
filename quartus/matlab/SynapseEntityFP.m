%% Simulate Synapse Entity with FP


%%
clear all;
for iter = 0:10


alpha1 = (1-1/50);
alpha2 = (1-1/10);
Isyn = 0;
K = 1000;
dt = 1E-3;
rng(0);
spikeIn = rand(K,1)<0.01;
v1=([0]);
v2=([0]);
FP =sign(iter);
fp_int = 2;
fp_frac = 10+(iter-1);
word_len = fp_int+fp_frac+1;
fprintf('FP:%i fp_int:%i fp_frac:%i\r\n',FP,fp_int,fp_frac);
if(FP)

s = whos;
for i = 1:length(s)
    if( strcmp(s(i).class,'double') && ~sum(strcmp(s(i).name,{'fp_int','fp_frac','K','iter','dt'})))
        name = s(i).name;
        assignin('base',name,sfi(evalin('base',name),word_len,fp_frac));
    end

end
end
tic
for k = 1:K % time evolution (each clock edge)
	v1(k+1) = alpha1*v1(k)+spikeIn(k);
    v2(k+1) = alpha2*v2(k)+spikeIn(k);
end
    v = v1-v2; % post synaptic potential
toc
%%

hold on;
subplot(211); plot(v); xlim([0 1000]);hold on; title('Post synaptic Potential');xlabel('time(samples)');
subplot(212); plot((1:K),spikeIn+iter);xlim([0 1000]); hold on;title('Input Spikes');
end
set(gcf,'Color','w');


