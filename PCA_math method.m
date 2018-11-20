load DataPSTH.mat
% X is a 469*12*7501 variable in the loaded data
% 3d = [neurons, conditions, time points]
% “conditions" = 6 freq * 2 class (f1>f2/f2>f1)


%% stats
% reshape three-dim array into matrix: (#neurons) x (#data points)

dm = size(DataPCA);
X_2d = reshape(DataPCA, dm(1), dm(2)*dm(3));


% center the data

X_2d_center = X_2d - mean(X_2d')';

% compute covariance matrix

X_cov = cov(X_2d_center');


% compute eigenvalues and eigenvectors

[V,D] = eig(X_cov);


%% PCA 

% extract first 20 components
TotalComponents = 20;
EigenValues = D(:,end-(TotalComponents-1):end);
X_PCA = V(:,end-(TotalComponents-1):end)'*X_2d_center;
% reshape back into 3d array: (# pcs) x (# conditions) x (# time points)
X_PCA_3d = reshape(X_PCA, TotalComponents, dm(2), dm(3));

%% choose k

EigVsum=0.0;
for i = 1:TotalComponents
    EigVsum = EigVsum+EigenValues(dm(1)+1-i,TotalComponents+1-i); 
end

percentage = zeros(1,TotalComponents);
CulPer = zeros(1,TotalComponents);

for i = 1:TotalComponents
    percentage(1,i) = EigenValues(dm(1)+1-i,TotalComponents+1-i)/EigVsum;
    CulPer(i)=sum(percentage(1,1:i));
end
figure(1);clf;
plot(1:TotalComponents, CulPer(1,:));

disp(CulPer);



%% plot
% create color map for plotting

cm = colormap;
cm = cm(round(linspace(1,64,6)),:);



% plot first 5 PC
k = 8; %number of components to plot
n = length(FreqsFin);



for i=1:k
    figure(i+1); clf;
    hold on;
    for j=1:n                
        plot( Time, squeeze(X_PCA_3d((TotalComponents+1)-i,j,:)), 'Color', cm(j,:) );
        plot( Time, squeeze(X_PCA_3d((TotalComponents+1)-i,n+j,:)), '--', 'Color', cm(j,:) );
    end
    axis([ 0 3000 -100 200] );
    legend('10 C1','10 C2','14 C1','14 C2','18 C1','18 C2','24 C1','24 C2','30 C1','30 C2','34 C1','34 C2','Location','northeastoutside');
    title(['Component ', num2str(i), ':  ',num2str(round(CulPer(i)*100)),'%']);
    xlabel('time(s)');
    ylabel('relative rate (Hz)');
    set(gca,'XTick', [0 3000] );
    set(gca,'XTickLabel', {'0', '3'} );
end


