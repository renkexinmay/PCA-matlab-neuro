%% pca
load DataPSTH.mat
dm = size(DataPCA);
X1 = reshape(DataPCA, dm(1), dm(2)*dm(3));
X1 = X1';
[coeff,score,latent] = pca(X1);
percent_explained = 100*latent/sum(latent);

%% plot

TotalComponents=20;
CulPer_pca = zeros(1,TotalComponents);
for i = 1:TotalComponents
    CulPer_pca(i)=sum(percent_explained(1:i,1));
end
figure(7); clf;
plot(1:TotalComponents, CulPer_pca);

display( CulPer_pca);


%% plot

cm = colormap;
cm = cm(round(linspace(1,64,6)),:);
k = 7; %number of components to plot
n = length(FreqsFin);

dm_sc = size(score);
pca_3d = score';
pca_3d = reshape(pca_3d, dm_sc(2), 12,dm_sc(1)/12);
for i=1:k
    figure(i+7); clf;
    hold on;
    for j=1:n                
        plot( Time, squeeze(pca_3d(i,j,:)), 'Color', cm(j,:) );
        plot( Time, squeeze(pca_3d(i,n+j,:)), '--', 'Color', cm(j,:) );
    end
    axis([ 0 3000 -100 200]);
    legend('10 C1','10 C2','14 C1','14 C2','18 C1','18 C2','24 C1','24 C2','30 C1','30 C2','34 C1','34 C2','Location','northeastoutside');
    title(['Component ', num2str(i), ':  ',num2str(round(CulPer_pca(i))),'%']);
    xlabel('time(s)');
    ylabel('relative rate (Hz)');
    set(gca,'XTick', [0 3000] );
    set(gca,'XTickLabel', {'0', '3'} );
end
%modify axi number 