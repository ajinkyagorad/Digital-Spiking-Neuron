%% Write vhdl script given the network
% Author : Ajinkya Gorad
% Define Network properties
X = [ 1 1 1 2 2 2 3 3 3]; % all are row vectors 1xNsyn matrices
Xn = [2 3 4 1 3 4 1 2 4];
Tau = [1 2 3 4 5 6 7 8 9];
W = ([0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9]);

inputNeurons = [1 2 3]; % add extra synapse to these neurons
inputWeights = [1 1 1]; % and respective input weights for input
inputDelays = [ 1 1 1]; % and respective delays for input
outputNeurons = [4];
%N=4;
N = max([X Xn]); % total number of neurons in network
Nsyn = length(X);
Ninput = length(inputNeurons);
Noutput = length(outputNeurons);
Ntotal = N+Ninput;
% Modify X,Xn and add dummy neurons for representing the input synapses
% extra neurons are added as N+1 to N+Ninput, Ninput is the number of input
% Neurons.
if(Ninput>0)
X = [X N+1:N+Ninput];
Xn = [Xn inputNeurons];
W = [W inputWeights];
Tau = [Tau inputDelays];
end
% Neuron properties  in network
alpha_w  = 1.0;
beta_w   = 0.1;
alpha_v1 = 0.98;
alpha_v2 = 0.9333;
alpha_V  = 0.98;
alpha_A  = 0.98;
beta_1   = 0.286;
beta_2   = 1.0;
beta_A   = 0.1;
V_th     = 1.0;
%% Define Vhdl properties
entityName = 'Network';
fID = fopen('script.vhd','w');
%% Write comment Header at start (information)
%% Write header at start
header = {'library IEEE;'
    'use IEEE.STD_LOGIC_1164.ALL;'
    'use ieee.numeric_std.all;'
    ''
    'library ieee_proposed;'
    'use ieee_proposed.fixed_pkg.all;'
    'use ieee_proposed.math_utility_pkg.all;'
    ''
    'library work;'
    'use work.myTypes.all;'
    'use work.all;'
    };
for i =1:length(header)
    fprintf(fID,'%s\r\n',header{i});
end
%%
fprintf(fID,'\r\n\r\n');
%% Write entity information
entity = {'entity <entityName> is'
    'port (clk,globalRst : in std_logic;'
    '        spikeIn: in std_logic_vector(<inputNeurons> downto 1);'
    '        spikeOut: out std_logic_vector(<outputNeurons> downto 1));'
    'end entity;'};
entity = strrep(entity,'<entityName>',entityName);
entity = strrep(entity,'<outputNeurons>',num2str(length(outputNeurons)));
entity = strrep(entity,'<inputNeurons>',num2str(length(inputNeurons)));

for i =1:length(entity)
    fprintf(fID,'%s\r\n',entity{i});
end
%% Write architecture information
% architecture  information is broken in segments
architecture1 = {'architecture arch of <entityName> is'
    ''
    % component defination (depends on the model) do not change
    'component neuron is'
    '        -- neuron parameters'
    '        generic( Nsyn : natural :=3;'
    '        D : integerArray:=(2,3,4);'
    '        W : realArray:=(0.5, 0.2, 0.3);'
    '        alpha_w : real :=1.0;'
    '        beta_w : real :=0.1;'
    '        alpha_v1 :real :=0.98;'
    '        alpha_v2:real :=0.9333;'
    '        alpha_V :real :=0.98;'
    '        alpha_A:real :=0.98;'
    '        beta_1 :real :=0.286;'
    '        beta_2 :real :=1.0;'
    '        beta_A :real :=-0.1;'
    '        V_th :real :=1.0);'
    '        '
    '        port ( inputSpikes : in std_logic_vector(Nsyn downto 1):=(others=>''0'');'
    '                 outputSpike : out std_logic:=''0'';'
    '                 globalRst,clk : in std_logic:=''0'';'
    '                 Iapp : in fp:=to_sfixed(0,fp_int,fp_frac));'
    'end component;'
    };
architecture1 = strrep(architecture1,'<entityName>',entityName);

for i =1:length(architecture1)
    fprintf(fID,'%s\r\n',architecture1{i});
end
%% Introduce neuron dynamics parameters as constants
fprintf(fID,'\r\n\r\n   --Define common neuron parameters\r\n');% print comment
architecture1a = {
    '   constant alpha_w  :real :=<alpha_w>;'
    '   constant alpha_v1 :real :=<alpha_v1>;'
    '   constant alpha_v2 :real :=<alpha_v2>;'
    '   constant alpha_V  :real :=<alpha_V>;'
    '   constant alpha_A  :real :=<alpha_A>;'
    '   constant beta_1   :real :=<beta_1>;'
    '   constant beta_2   :real :=<beta_2>;'
    '   constant beta_A   :real :=<beta_A>;'
    '   constant beta_w   :real :=<beta_w>;'
    '   constant V_th     :real :=<V_th>;'
    };
architecture1a = strrep(architecture1a,'<alpha_w>',sprintf('%.5f',alpha_w));
architecture1a = strrep(architecture1a,'<alpha_v1>',sprintf('%.5f',alpha_v1));
architecture1a = strrep(architecture1a,'<alpha_v2>',sprintf('%.5f',alpha_v2));
architecture1a = strrep(architecture1a,'<alpha_V>',sprintf('%.5f',alpha_V));
architecture1a = strrep(architecture1a,'<alpha_A>',sprintf('%.5f',alpha_A));
architecture1a = strrep(architecture1a,'<beta_1>',sprintf('%.5f',beta_1));
architecture1a = strrep(architecture1a,'<beta_2>',sprintf('%.5f',beta_2));
architecture1a = strrep(architecture1a,'<beta_A>',sprintf('%.5f',beta_A));
architecture1a = strrep(architecture1a,'<beta_w>',sprintf('%.5f',beta_w));
architecture1a = strrep(architecture1a,'<V_th>',sprintf('%.5f',V_th));

for i =1:length(architecture1a)
    fprintf(fID,'%s\r\n',architecture1a{i});
end
%% start defining network parameters here
% input delay & weights for each synapse in neuron
% for eg : "constant D23 : integerArray:=(3,5,2,1);" for neuron 23
fprintf(fID,'\r\n\r\n   --Define interconnection delays for each neuron \r\n');% print comment
strD ={'   constant D<n> : integerArray := (<val>);' };
for n =1:N
    strDeval =strD;
    strDeval = strrep(strDeval,'<n>',num2str(n));
    s = sprintf('%.0f,' , Tau(Xn==n));
    strDeval = strrep(strDeval,'<val>',s(1:end-1));
    for i =1:length(strDeval)
        fprintf(fID,'%s\r\n',strDeval{i});
    end
end
% for eg : "constant W23 : realArray:=(3.0,5.0,2.0,1.0);" for neuron 23
% (note realArrays must have a decimal '.' in their string)
fprintf(fID,'\r\n\r\n   --Define initial Weights for each neuron\r\n');% print comment
strW ={'   constant W<n> : realArray := (<val>);' };
for n =1:N
    strWeval =strW;
    strWeval = strrep(strWeval,'<n>',num2str(n));
    s = sprintf('%.5f,' , W(Xn==n));
    strWeval = strrep(strWeval,'<val>',s(1:end-1));
    for i =1:length(strWeval)
        fprintf(fID,'%s\r\n',strWeval{i});
    end
end
%% for synapse spike signals (input to each neuron)
fprintf(fID,'\r\n\r\n   --Define interconnection signals\r\n');% print comment

strSynSpike = {'   signal synapseSpike<n>: std_logic_vector(<numSyn> downto 1):=(others=>''0'');'};
for n =1:Ntotal
    strSSeval =strSynSpike;
    strSSeval = strrep(strSSeval,'<n>',num2str(n));
    numSyn = sum(Xn==n);
    if(numSyn>0) % write only if there are input synapses
        strSSeval = strrep(strSSeval,'<numSyn>',num2str(numSyn));
        for i = 1:length(strSSeval)
            fprintf(fID,'%s\r\n',strSSeval{i});
        end
    end
end
%% Write till begin of the architeture
architecture2={
    ''
    '   signal Iapp : fp_array(<numNeurons> downto 1):=(others=>to_sfixed(0.0,fp_int,fp_frac));'
    '   signal neuronSpike: std_logic_vector(<numNeuronsTotal> downto 1):=(others=>''0'');'
    % generate synapseSpike for each Neuron (lines = N)
    'begin'
    };
architecture2 = strrep(architecture2,'<numNeurons>',num2str(N));
architecture2 = strrep(architecture2,'<numNeuronsTotal>',num2str(Ntotal));


for i =1:length(architecture2)
    fprintf(fID,'%s\r\n',architecture2{i});
end
%% Generate Neurons Entities
% Create entities of neuron
fprintf(fID,'\r\n\r\n   --Generate Neurons\r\n');% print comment
strN = {'	N<n> :  neuron generic map(Nsyn=><Nsyn>,D=>D<n>,W=>W<n>,alpha_V=>alpha_V,alpha_v1=>alpha_v1,alpha_v2=>alpha_v2,alpha_A=>alpha_A,alpha_w=>alpha_w,beta_1=>beta_1,beta_2=>beta_2,beta_A=>beta_A,beta_w=>beta_w)' ...
        '           port map(Iapp=>Iapp(<n>),inputSpikes=>synapseSpike<n>,outputSpike=>neuronSpike(<n>),globalRst=>globalRst,clk=>clk);'};

for n =1:Ntotal
    strNeval =strN;
    numSyn = sum(Xn==n);
    if(numSyn>0)
        strNeval = strrep(strNeval,'<n>',num2str(n));
        strNeval = strrep(strNeval,'<Nsyn>',num2str(numSyn));
        
        for i =1:length(strNeval)
            fprintf(fID,'%s\r\n',strNeval{i});
        end
    end
end

%% Assign signal to Synapses of Neurons (connect network)
fprintf(fID,'\r\n\r\n   --Map Synapses\r\n');% print comment
strMakeConn = {'   synapseSpike<n>(<j>)<=neuronSpike(<m>);'};
for n = 1:N
    numSyn = sum(Xn==n);
    if(numSyn>0)
        inspikes = X(Xn==n);
        for j = 1:numSyn % start of  each line
            strMakeConneval = strMakeConn;
            strMakeConneval = strrep(strMakeConneval,'<n>',num2str(n));
            strMakeConneval = strrep(strMakeConneval,'<j>',num2str(j));
            strMakeConneval = strrep(strMakeConneval,'<m>',num2str(inspikes(j)));
            for i =1:length(strMakeConneval)
                fprintf(fID,'%s\r\n',strMakeConneval{i});
            end
        end
    end
end
%% Assign external world signals to input Neurons
fprintf(fID,'\r\n\r\n   --Map Inputs from external world \r\n');% print comment
strInputConn = {'   neuronSpike(<n>)<=spikeIn(<m>);'};
for n = 1:Ninput
    strInputConneval = strInputConn;
    strInputConneval = strrep(strInputConneval,'<n>',num2str(N+n));
    strInputConneval = strrep(strInputConneval,'<m>',num2str(n));
    for i =1:length(strInputConneval)
        fprintf(fID,'%s\r\n',strInputConneval{i});
    end
end
%% Assign output to external world

fprintf(fID,'\r\n\r\n   --Map Outputs to external world \r\n');% print comment
strOutputConn = {'   spikeOut(<n>)<=neuronSpike(<m>);'};
for n = 1:Noutput
    strOutputConneval = strOutputConn;
    strOutputConneval = strrep(strOutputConneval,'<n>',num2str(n));
    strOutputConneval = strrep(strOutputConneval,'<m>',num2str(outputNeurons(n)));
    for i =1:length(strOutputConneval)
        fprintf(fID,'%s\r\n',strOutputConneval{i});
    end
end
%%
architecture3={
    
'end arch;'
};
architecture3 = strrep(architecture3,'<entityName>',entityName);

for i =1:length(architecture3)
    fprintf(fID,'%s\r\n',architecture3{i});
end
