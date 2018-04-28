%% Simulate STDP Entity with FP

clear all;
%%
RESET_REG = 1; %1/0 To use Reset in register (register_fp_rst_1 entity) or leave as normal register
h = figure('name','Sim');
set(gcf,'Position',[100 100 1000 400]);
%h2 = figure('name','STDP');
for iter = 0:10

a1 =0.1; % a1, a2 need to be equal in magnitude for this simulation code
a2 =-0.1;
alpha3 = (1-1/50);
alpha4 = (1-1/50);
K = 1000;
dt = 1E-3;
rng(0);
spikeSynapse = rand(K,1)<0.05;
spikeNeuron = rand(K,1)<0.05;
w =([0]); % initial Wt
v3=([0]); % initial values
v4=([0]);
% simulation log parameters
tSinceSyn = 0;
tSinceNeu = 0;
spikeInterval = []; % tNeuron-tSynapse 
weightChange = [];

FP =sign(iter);
fp_int = 2;
fp_frac = 10+(iter-1);
word_len = fp_int+fp_frac+1;
fprintf('iter:%i FP:%i fp_int:%i fp_frac:%i\r\n',iter,FP,fp_int,fp_frac);
if(FP)

s = whos;
for i = 1:length(s)
    if( strcmp(s(i).class,'double') && ~sum(strcmp(s(i).name,{'fp_int','fp_frac','K','iter','dt','RESET_REG','tSinceSyn','tSinceNeu','spikeInterval','weightChange'})))
        name = s(i).name;
        assignin('base',name,sfi(evalin('base',name),word_len,fp_frac));
    end

end
end
tic

for k = 1:K % time evolution (each clock edge)
    
    if(RESET_REG)
    if(spikeSynapse(k))v3(k) =1;end
    if(spikeNeuron(k))v4(k) = 1;end
    v3(k+1) = alpha3*v3(k)+spikeSynapse(k);
    v4(k+1) = alpha4*v4(k)+spikeNeuron(k);
    else
	v3(k+1) = alpha3*v3(k)+spikeSynapse(k);
    v4(k+1) = alpha4*v4(k)+spikeNeuron(k);
    end
    % Update weights
    if(spikeNeuron(k)& ~spikeSynapse(k));    w(k+1) = w(k)+a1*v3(k); 
    elseif(spikeSynapse(k)& ~spikeNeuron(k));   w(k+1) = w(k)+a2*v4(k);
    else        w(k+1) = w(k);
    end
    % Log the time vs weight change
    
    if(spikeSynapse(k) & ~spikeNeuron(k))
        spikeInterval(end+1) = -tSinceNeu; tSinceSyn = 0;
        weightChange(end+1) = w(k+1)-w(k);
    end
    if(spikeNeuron(k) & ~spikeSynapse(k))
        spikeInterval(end+1) = tSinceSyn; tSinceNeu = 0;
        weightChange(end+1) = w(k+1)-w(k);
    end
    if(spikeNeuron(k) & spikeSynapse(k))
        spikeInterval(end+1) = 0;
        tSinceSyn=0; tSinceNeu = 0;
        weightChange(end+1) = w(k+1)-w(k);
    end
    tSinceSyn = tSinceSyn+1;
    tSinceNeu = tSinceNeu+1;
end
toc
if(FP)
s = whos;
for i = 1:length(s)
    if( strcmp(s(i).class,'embedded.fi') && ~sum(strcmp(s(i).name,{'fp_int','fp_frac','K','iter','dt','RESET_REG'})))
        name = s(i).name;
        assignin('base',name,double(evalin('base',name)));
    end

end
end
%%
figure(h); hold on;
subplot(221); plot(w); xlim([0 1000]);hold on; title('Weight'); xlabel('time(samples)');
subplot(223); plot(v3+iter); hold on; plot(v4+iter);xlim([0 1000]); title('Neuron/Synapse Spikes');
subplot(223); 
plot((1:K),spikeSynapse+iter,'b');xlim([0 1000]); hold on;
plot((1:K),spikeNeuron+iter,'r');xlim([0 1000]); hold on;
%figure(h2);
subplot(2,2,[2 4]);
plot(spikeInterval,weightChange,'.'); hold on; title('STDP'); xlabel('t_{post}-t_{pre} (samples)');ylabel('{\Delta}W');
drawnow;

end
set(gcf,'Color','w');

