%%%------PSTH plots for all neurons and all electrodes
% Time
TotalTime = 15000;
deltat    = 2;
Time      = (0:deltat:TotalTime)-5000;
NumTime   = length(Time);

% Gaussian kernel for smoothing
NumKer = round(500/deltat);
GaussK = exp( - ( 1.6*(-NumKer:2:NumKer)/NumKer ).^2 );
GaussK = GaussK / sum(GaussK);

% All data files

Path  = 'data/rr014/prefront/';
Names = dir(Path);
IndAll = 1;
IndPCA = 1;
%traking1 = zeros(462,1);
for FileName=3:length(Names) % loop for files

    data = load( [Path, Names(FileName).name] ); % load one file
    Ntrials = size(data.result,1)-1; % number of trials for this file
    
    for NElec=1:7 % loop for electrodes

        f1 = zeros(Ntrials,1); %search for freqs in this file
        for k=1:Ntrials
            f1(k) = data.result{k+1,4};
        end
        Allfreqs = unique(f1); %freqs for this file
        Numf1    = length(Allfreqs); %number of freqs for this file
        DataAv   = zeros(Numf1*2,NumTime); %data array for this file
        
        for j = 1:Numf1 % j indicates values of f1
            F2f1    = zeros(Ntrials,NumTime); % For groups1 f1<f2
            F1f2    = zeros(Ntrials,NumTime); % For groups2 f1>f2
            TotalG1 = 1;
            TotalG2 = 1;

            for k = -1:2:1 %-1 for group 1 and +1 for group 2
                for i = 2:Ntrials+1 %i moves trough the number of trials
                    belief = sign(data.result{i,4}-data.result{i,5})*(2*data.result{i,3}-1); %-1 for group 1 and +1 for group 2
                    if Allfreqs(j) == data.result{i,4} && belief == k %compares with f1 and group
                        TSpikes = 5000 + data.result{i,6}{NElec} - data.result{i,9}; %time of all spikes
                        if k == -1
                            F2f1(TotalG1,round(TSpikes/deltat)) = 1;
                            TotalG1 = TotalG1 + 1;
                        elseif k == 1
                            F1f2(TotalG2,round(TSpikes/deltat)) = 1;
                            TotalG2 = TotalG2 + 1;
                        end
                    end
                end
            end
            F2f1 = F2f1(1:TotalG1,:); %Remove usless rows
            F1f2 = F1f2(1:TotalG2,:); 
            MeanG1 = mean( F2f1, 1 ); %Average over trials per group per freq
            MeanG2 = mean( F1f2, 1 ); 
            DataAv(j,:)   = conv( MeanG1, GaussK, 'same' ); %Convolution with gaussian kernel
            DataAv(Numf1+j,:) = conv( MeanG2, GaussK, 'same' ); 
        end
        DataAv = DataAv * 1000; %In Hertz ???

        % store all data
        AllDataAv{IndAll} = DataAv; %visible spikes
        Allf1{IndAll} = Allfreqs; %freqs
        %ready for PCA
        IndAll = IndAll+1;
        
        FreqsFin = [10;14;18;24;30;34];
        NumTotFF = size(FreqsFin,1);
        if size(Allfreqs,1) == NumTotFF
            if sum(Allfreqs == FreqsFin)== NumTotFF
                DataRow = reshape(DataAv,1,2*NumTotFF,NumTime);
                DataPCA(IndPCA,:,:) = DataRow;
                %traking1(IndPCA) = IndAll-1;
                IndPCA = IndPCA+1;
            end
        end
    end
end

   