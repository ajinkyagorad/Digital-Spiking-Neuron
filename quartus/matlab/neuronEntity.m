%% Simulate Neuron entity with fixed point

%%
clear all;
for iter = 0:10
V = [0];
Vth =1;
b1 = 0.03;
b2 = 0.1;
Isyn = 0;
K = 1000;
rng(0);
Iapp = 1+randn(1,K);
spike = ([0]);
alpha =(1-1/50);
FP =sign(iter);
fp_int = 2;
fp_frac = 10+(iter-1);
word_len = fp_int+fp_frac+1;
fprintf('FP:%i fp_int:%i fp_frac:%i\r\n',FP,fp_int,fp_frac);
if(FP)

s = whos;
for i = 1:length(s)
    if( strcmp(s(i).class,'double') && ~sum(strcmp(s(i).name,{'fp_int','fp_frac','K','iter'})))
        name = s(i).name;
        assignin('base',name,sfi(evalin('base',name),word_len,fp_frac));
    end

end
end
tic
for k = 1:K % time evolution (each clock edge)
	V(k+1) = alpha*V(k)+b1*Iapp(k)+b2*Isyn;
    spike(k+1)=V(k+1)>Vth;
    if(spike(k+1)) V(k+1)=0; end
end
toc
%%

hold on;
subplot(311); plot(Iapp);hold on;
subplot(312); plot(V); hold on;
subplot(313); plot((1:K+1),spike+iter); hold on;
end


