% Visualize the state of a sample HDGM learner (4 replicas) trained with generative replay
% 
% hdgm_visualize(replica) shows the state of a given replica (1..4).
%
% The code extends the visualization of experiment 1 (Fig 1A,F and Fig 2A) from
% Stoianov, I., Maisto, D., & Pezzulo, G. (2020) BioRxiv. doi:10.1101/2020.01.16.908889
% "The hippocampal formation as a hierarchical generative model supporting generative replay and continual learning." 
%
% hdgm_visualize(replica,trial_selector) show all or just selected navigation trials of the selected learner
%     trial_selector=0 shows all trials (SLOW demo)
%     trial_selector=1 (default) shows the first and last two trials of each block (each in different maze)
%                      the 1st trial of each block is interesting because it shows the transition in belief 
%                      from the previous maze to the new maze
%     trial_selector=2 shows the the first two and last two trials of the last block only (QUICK demo).
%
% Note that the visualization shows only the last state of the maps
%
% 

function hdgm_visualize(replica,trial_selector)
if nargin<1, replica=1; end
if nargin<2, trial_selector=1; end
fnm='HDGM_generative_replay_5replica.mat';
load(fnm);
condition=1;                % The datafile contains the state of 5 replicas trained in a single condition (gener replay) 
M=MM.M{replica,condition};  % M is a structure containing the learner state
fgn=1; h_fg=figure(fgn); clf reset;
set(h_fg,'Position',[1500,1000,1000,1000],'Renderer','zbuffer','Color',[1 1 1],'PaperPositionMode', 'auto');
M.plot_selector=1;          % 1:trace, 2replay
for i=1:M.tS
  iepoch=M.S(i,1); ipath=M.S(i,2); 
  if trial_selector>=2 && (iepoch<M.nepisodes), continue; end % Show just the last block
  if trial_selector>=1 && (ipath>2 && ipath<(M.npaths-1)), continue; end % Show the first 2 and last 2 trials of each block
  plot_genmodel(h_fg,M,i);
end

end

%M.S(M.tS,:)=[single([iepoch ipath istep X.x X.k X.m X.map X.xpr]) X.pk X.zk];
%if M.storex, M.z(M.tS,:)=X.Z'; M.y(M.tS,:)=X.Y'; M.xpr(M.tS,:)=X.Xpr;

%  M.SS(M.tSS,:)=[single([M.iepoch iswr istep X.x X.k X.m X.map isgoal]) X.pk X.zk X.pxpr]; 
%                 %  [epoch iswr istep pos cluster preferred-map 0 isgoal log-p(y|mapk) p_z p(next-x)]       
%  M.zS(M.tSS,:)=X.Z'; M.yS(M.tSS,:)=X.Y'; M.xprS(M.tSS,:)=X.Xpr;

function plot_genmodel(h_fg,M,i)
clf;        % clear figure;
x=0.28;     % center
msz=0.15;   % map size
dy=msz;     % relative step
iepoch=M.S(i,1); ipath=M.S(i,2); maze=M.S(i,7); istr=sprintf('Block %d  Maze %d Trace %d',iepoch,maze,ipath);

y=0.152*dy;   annotation(h_fg,'textbox',[x 1-y 0.45 0.02],'String','Hierarchical Dynamic Generative Model','FontSize',16,'LineStyle','none');
y=y+0.2*dy; annotation(h_fg,'textbox',[x+.1 1-y 0.45 0.02],'String',istr,'FontSize',14,'LineStyle','none');

% Mixture probabilities (p(z) and parameters
y=y+0.4*dy; annotation(h_fg,'textbox',[x-msz*.25, 1-y 0.5 0.02],'String','Mixture','FontSize',14,'LineStyle','none');
y=y-0.1*dy; annotation(h_fg,'rectangle',[x-0.17, 1-y-2.7*msz 0.33 0.38],'LineStyle',':','LineWidth',2,'Color',[0.7 0.7 0.7]);
y=y+0.35*dy; annotation(h_fg,'textbox',[x-msz*.5, 1-y 0.5 0.02],'String','Cluster probability','FontSize',12,'LineStyle','none');
y=y+0.6*dy; plot_z(M,i  ,x    ,y,msz);     % Plot z(t)

y=y+0.5*dy; annotation(h_fg,'textbox',[x-msz*.75, 1-y 0.5 0.02],'String','Cluster parameters (maps)','FontSize',12,'LineStyle','none');
y=y+0.6*dy; plot_maps(M,i,x,y,msz*.8);




% TRACE
y=y+0.8*dy; l=0.02; ddy=[-.5 .5]*l;  annotation(h_fg,'arrow',[x x],1-y-ddy,'HeadLength',6,'HeadWidth',6,'LineWidth',3,'Color','b');
y=y+0.3*dy; annotation(h_fg,'textbox',[x-msz*.6, 1-y 0.2 0.02],'String','Sequence code','FontSize',14,'LineStyle','none');
y=y+0.6*dy; plot_y(M,i-0  ,x    ,y,msz);

% Theta
y=y+0.7*dy; l=0.02; ddy=[-.5 .5]*l;  annotation(h_fg,'arrow',[x x],1-y-ddy,'HeadLength',6,'HeadWidth',6,'LineWidth',3,'Color','b');
y=y+0.3*dy; annotation(h_fg,'textbox',[x-msz*.6, 1-y 0.2 0.02],'String','Item code','FontSize',14,'LineStyle','none');
y=y+0.6*dy; plot_prx(M,i,x,y,msz);   % plot xpr

% z-trend within the current trial
x=0.7; y=0.7*dy;
annotation(h_fg,'textbox',[x-msz*.6, 1-y 0.5 0.02],'String','Mixture dynamics','FontSize',14,'LineStyle','none');
y=y+0.8*dy; plot_ztrend(M,i,x,y,msz)

y=y+0.6*dy; annotation(h_fg,'textbox',[x-msz*.5, 1-y 0.2 0.02],'String','Cluster selection','FontSize',14,'LineStyle','none');
y=y+1.6*dy;   plot_clusters(M,i,x,y,msz*1.5);

colormap pink;drawnow;
end

function plot_ztrend(M,i,x,y,sz)
 Leg={};for k=1:numel(M.LM.k), Leg{k}=sprintf('cluster %d',k); end
 axes('Position',[x-sz*.7,1-y,sz*1.2,sz*.7]); hold on;
 iepoch=M.S(i,1); 

 switch M.plot_selector,
  case 1, 
    ipath=M.S(i,2); istep=M.S(i,3);   % current trace and step
    I=find(M.S(:,1)==iepoch & M.S(:,2)==ipath & M.S(:,3)<=istep);  
    zz=M.z( I,M.LM.k);    % Probability of each cluster (reordered) (1) navigation
  case 2, 
    iswr=M.SS(i,2);    
    I=find(M.SS(:,1)==iepoch & M.SS(:,2)==iswr);  
    zz=M.zS(I,M.LM.k);    % (2) replay
 end
 plot(zz,'LineWidth',1);
 xlim([0.5 size(zz,1)+.5]); ylim([0 1]); xlabel('trial step'); ylabel('p(c)'); 
 legend(Leg,'Position',[x+sz 1-y+sz*0.2 sz*0.2 sz*0.2],'LineWidth',1);
end

function plot_clusters(M,i,x,y,sz)
 xsz=1.3*sz;
 axes('Position',[x-xsz/2,1-y,xsz,sz]); hold on;
 hold on; set(gca,'LineWidth',2); 
 c_sty='*osv^dp.+x'; c_col='rmgbkcygbk'; 
 LEG={}; iLEG=0;
 IP=1:i;
 epis=M.S(IP,1); cl=M.S(IP,5); map=M.S(IP,7); 
 clm=M.LM.k_map(cl); % reorder as in the left display

 for m=1:M.nmaps,
   I=find(map==m);
   if ~isempty(I), 
     plot(I,(clm(I)),[c_col(m) c_sty(m)]); 
     iLEG=iLEG+1; LEG{iLEG}=sprintf('maze %d',m);
   end
 end
  
 % Block
 depis=diff(single([0;epis;M.nepisodes+1]));
 Ichange=find(depis); 
 for bl=1:numel(Ichange)-1
   text(50+Ichange(bl),0.5,sprintf('bl.%d',bl),'Color',c_col(map(Ichange(bl))),'FontSize',10);  
 end
 xlim([0.5 numel(map)+.5]); ylim([0 M.nmaps+.5]);
 xlabel('Time step and block'); ylabel('Selected Cluster');
 legend(LEG,'Position',[x+0.7*xsz 1-y+sz*0.5 sz*0.2 sz*0.2],'LineWidth',1);
end

function plot_z(M,i,x,y,sz)
 axes('Position',[x-sz/2,1-y,sz,sz/2]); hold on;
 switch M.plot_selector,
   case 1, bar(M.z(i,M.LM.k), 'LineWidth',2); 
   case 2, bar(M.zS(i,M.LM.k),'LineWidth',2); 
 end
 axis tight; ylim([0 1]); xlabel('cluster'); ylabel('p(c)'); 
end

function plot_maps(M,i,x0,y0,sz)
 n=M.LM.n;
 dx=0.25*sz;                        % x-step
 dy=0.08*sz;                        % y-step
 xsz=sz+(n-1)*dx;                   % total group x-size
 ysz=sz+(n-1)*dy;                   % total group x-size 
 switch M.plot_selector,
   case 1, Z=M.z(i,M.LM.k);         % Probability of each cluster ordered by map (1) navigation
   case 2, Z=M.zS(i,M.LM.k);        % (2) replay
 end       
 Z=Z/max(Z);                        % Cluster probability
 for k=1:n                          % Each cluster
   axes('Position',[x0-xsz/2+(k-1)*dx,1-y0-ysz/2+(k-1)*dy,sz,sz]); hold on;
   imagesc(reshape(M.mapp(:,M.LM.k(k)),M.size(2),M.size(1))); 
   axis image; axis xy; axis off;
   plot([0 M.size(1) M.size(1) 0 0]+.5,[0 0 M.size(1) M.size(1) 0]+.5,'Color',[1 1 1]*0.75,'LineWidth',2); % Contour
   alpha(double(Z(k)));             % Set transparency proportional to the probability of that cluste  
 end
end

function plot_y(M,i,x0,y0,sz)
 axes('Position',[x0-sz/2,1-y0-sz/2,sz,sz]); hold on;
 switch M.plot_selector,
   case 1, 
     imagesc(reshape(M.y(i,:),M.size(2),M.size(1)));
     xpr=single(M.S (i,4));     % predicted trajectory point
   case 2, 
     imagesc(reshape(M.yS(i,:),M.size(2),M.size(1)));
     xpr=single(M.SS(i,4));     % predicted replay point
 end
 xypr=i2xy(xpr,M.size(2));    % x-y coord of the predicted point
 plot(xypr(1),xypr(2),'o','MarkerSize',8,'MarkerEdgeColor',[1 0 0],'LineWidth',2);  % Predicted point 
 plot([0 M.size(1) M.size(1) 0 0]+.5,[0 0 M.size(1) M.size(1) 0]+.5,'Color',[1 1 1]*0.75,'LineWidth',3); % Contour 
 axis image; axis xy; axis off;
end

function plot_prx(M,i,x0,y0,sz)
 axes('Position',[x0-sz/2,1-y0-sz/2,sz,sz]); hold on;
 switch M.plot_selector,
   case 1,  
    imagesc(reshape(M.xpr(i,:),M.size(2),M.size(1))); 
    xpr=single(M.S(i,4));     % predicted point
   case 2,
    imagesc(reshape(M.xprS(i,:),M.size(2),M.size(1))); 
    xpr=single(M.SS(i,4));    % predicted point
 end
 xypr=i2xy(xpr,M.size(2));          % x-y coord of the predicted point
 plot(xypr(1),xypr(2),'o','MarkerSize',8,'MarkerEdgeColor',[1 0 0],'LineWidth',2);  % Predicted point    
 plot([0 M.size(1) M.size(1) 0 0]+.5,[0 0 M.size(1) M.size(1) 0]+.5,'Color',[1 1 1]*0.75,'LineWidth',3); % Contour
 axis image; axis xy; axis off;
end
