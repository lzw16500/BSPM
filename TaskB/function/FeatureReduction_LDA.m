function [ egnValSort,egnVecSort,newX ] = FeatureReduction_LDA( Xdata,Xlabel,egnValSort,egnVecSort,ReductionMode,State )
% Xdata => Nch * Nt
% mode : LDA - PCA - Correlation - ANN
Xdata=Xdata';   % [Nt Nch]
switch ReductionMode
    case 'LDA'
        switch State
            case 'train'
                SW=0;
                SB=0;
                labs =unique(Xlabel);   %if Xlabel=[5 5 5 3 3  1 1 1 2 2 2 2]' =>  labs=[1 2 3 5]'
                mu = mean(Xdata); %X is matrix Nt * Nch
                for i=1:length( labs )
                    labITrn = Xdata( ismember(Xlabel , labs(i) ) ,:);   %All data are belong to label i are in labITrn in each iteration
                    %SW or Scatter Within_class is Nch * Nch//cov(x):For matrices,
                    %where each row is an observation, and each column is a variable//( size(labITrn,1) - 1 ):probability
                    SW = SW + (size(labITrn,1)/size(Xdata,1))*cov( labITrn );   
                    %SB or Scatter between_class W is Nch * Nch//
                    %SB=Sigma(Pi*(Mi-M0)'*(Mi-M0))//Mi:mean in each class//M0:mean whole data
                    SB = SB + (size(labITrn,1)/size(Xdata,1))*( mean( labITrn,1 ) - mu )'*( mean( labITrn,1 ) - mu );   
                end
                s=0.0001;
                [ egnVec , egnVal ] = eig( (inv(SW+s+eye(size(SW,1))))*(SB+eps) );
                [ egnValSort , IX ] = sort( diag( egnVal ) , 'descend' );
                egnVecSort = egnVec( : , IX);
                g = ( imag(egnValSort)==0 ) & ( real( egnValSort )>0.0001 );
                egnValSort = egnValSort( g );
                egnVecSort = egnVecSort( :, g );
                %egnVecSort = normc( egnVecSort );
                newX=egnVecSort'*Xdata';%[g Nt]=[g Nch] [Nch Nt]
            case 'test'
                newX=egnVecSort'*Xdata'; %[g Nt]=[g Nch] [Nch Nt]
        end
    case 'PCA'
        switch State
            case 'train'
                C = cov(Xdata);
                [EigVec EV]=eig(C); 
                [EigVal order] = sort(diag(EV), 'descend');  
                egnVecSort =EigVec(:,order);
                SumEigVal=sum(EigVal);
                for i=1:length(EigVal)
                    SumEDX=sum(EigVal(1:i));
                    if SumEDX/SumEigVal > 0.95
                        break;
                    end
                end
                egnValSort=EigVal(1:i);
                egnVecSort=egnVecSort(:,1:i); 
                newX=egnVecSort'*Xdata';%[g Nt]=[g Nch] [Nch Nt]
            case 'test'
                newX=egnVecSort'*Xdata'; %[g Nt]=[g Nch] [Nch Nt]
        end
    case 'Correlation'
        switch State
            case 'train'
                RHO = abs(corr(Xdata));
                Q=1;
                Thr=0;
                egnValSort=[];
                for i=1:10
                    Thr=Thr+0.1;
                    c=1;
                    j=1;
                    while (c)
                        if j==(size(Xdata,2)+1)
                            c=0;
                        else
                            if isempty(find(Q==j, 1))
                                P=RHO(Q,j);
                                if P<=Thr
                                    Q=cat(2,Q,j);
                                end
                            end
                        end
                        j=j+1;
                    end
                    egnValSort=cat(2,egnValSort,length(Q));
                end
                egnVecSort=Q;
                newX=(Xdata(:,egnVecSort))';
            case 'test'
                newX=(Xdata(:,egnVecSort))';
        end
    case 'ANN'
         switch State
            case 'train'
                error=[];
                for i=1:floor(2*size(Xdata,2)/3)
                    net=newff(Xdata',Xdata',i,{'purelin'},'trainlm');
                    net.trainParam.show = 50; % The result is shown at every 50th iteration (epoch)
                    net.trainParam.lr = 0.05; % Learning rate used in some gradient schemes
                    net.trainParam.epochs =10; % Max number of iterations
                    net.trainParam.goal = 1e-2; % Error tolerance; stopping criterion
                    net.trainParam.max_fail=8;
                    net1 = train(net, Xdata', Xdata'); % Iterates gradient type of loop
                    Test= sim(net1,Xdata')';
                    e=sqrt(sum(sum((Xdata-Test).^2))/(size(Xdata,1)*size(Xdata,2)));
                    error=cat(2,error,e);
                end
                plot(1:floor(2*size(Xdata,2)/3),error)
                [error order] = sort(error, 'ascend'); 
                net=newff(Xdata',Xdata',order(1),{'purelin'},'trainlm');
                net.trainParam.show = 50; % The result is shown at every 50th iteration (epoch)
                net.trainParam.lr = 0.05; % Learning rate used in some gradient schemes
                net.trainParam.epochs =10; % Max number of iterations
             	net.trainParam.goal = 1e-2; % Error tolerance; stopping criterion
            	net.trainParam.max_fail=8;
              	net1 = train(net, Xdata', Xdata'); % Iterates gradient type of loop
                egnVecSort=net1.IW{1}; %[i Nch]
                egnValSort=net1.b{1}; %[i 1]
                newX=egnVecSort*Xdata'+repmat(egnValSort,1,size(Xdata,1));
             case 'test'
                newX=egnVecSort*Xdata'+repmat(egnValSort,1,size(Xdata,1));
         end
end
end

