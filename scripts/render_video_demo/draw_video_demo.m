close all
fig = figure(2); clf;
fig.Color = 'k'

windowSize = [1,1,1920*(2/3),1080*(2/3)] 
fig.Position = windowSize;

[plotHandleVideo pHPos1] = tight_subplot(1,2,[.025 .05], [.525 .05], [.0635 .0635])
set(plotHandleVideo,'XTick',[],'YTick',[])
set(plotHandleVideo,'box', 'on')
set(plotHandleVideo,'Units','pixels');
set(plotHandleVideo,'LineWidth',20);
set(plotHandleVideo,'XColor', [1 1 1],'YColor',[1 1 1])
resizePosVideo = get(plotHandleVideo,'Position');
axesSizeVideo = resizePosVideo{1};

[plotHandleSRC pHPos2] = tight_subplot(1,2,[.025 .22], [.265 .5005], [.0635 .0635])
[plotHandleCumSRC pHPos3] = tight_subplot(1,2,[.025 .035], [.265 .5005], [.4 .4])

[plotHandleBottomLeft pHPos4] = tight_subplot(1,2,[.025 .035], [.05 .8], [.1 .65])
[plotHandleBottomRight pHPos4] = tight_subplot(1,2,[.025 .035], [.05 .8], [.65 .1])
[plotHandleCumAlpha pHPos3] = tight_subplot(1,2,[.025 .035], [.05 .775], [.4 .4])

% delete(plotHandleTopoLeft)
cumSrcBci = 0; cumSrcWatch = 0;
nFrames = length(videoBci);

normFeatIntensity = double(videoMean2(stimBci));
normFeatIntensity = myRescale(normFeatIntensity,1,256);
normFeatIntensity = uint8(normFeatIntensity);
colorMapIntensity = flipud(hot(255));

% plot(normFeatIntensity)
startIndex = 150;
bciStartIndex = 6;
raceStartIndex = videoEpochIndexBci(1) - startIndex - bciStartIndex+1;
% videoBci = videoBci((startIndex+bciStartIndex):end,:,:,:);
% videoWatch = videoWatch(startIndex:end,:,:,:);
% subplot(2,1,1)
% imshow(squeeze(videoBci(raceStartIndex,:,:,:)));
% subplot(2,1,2)
% imshow(squeeze(videoWatch(raceStartIndex,:,:,:)));
% 
v = VideoWriter('./output/demo/ActivePassiveDemo.mp4');
set(v,'FrameRate',fs);
open(v);

displayWindowLength = 60;
ph1b = [];
ph2b = [];
iter = 1;

for i= 1:nFrames
    
    iFrame = i;
    
    imgFrame1 = double(squeeze(videoBci(iFrame,:,:,:)));
    frameBorder1 = [1 1 1];
    
    imgFrame2 = double(squeeze(videoWatch(iFrame,:,:,:)));
    frameBorder2 = [1 1 1];
    isDrawn1 = false;
    if iFrame == 1
        isDrawn1 = false;
        eegWatchMean = mean(eegWatch,3);
        eegBciMean = mean(eegBci,3);
        
        eegBciPowerMean = mean(eegBciPower,3);
        eegWatchPowerMean = mean(eegWatchPower,3);

        %% intialize the plot for time resolved correlation
        
        valIter = 1;
        fsCorr = 5;
        displayWindowLength = fsCorr*6 ;
        rhoTimeResolved1 = sum(rhoThimeResolvedSRCMeanBci,2);
        rhoTimeResolved2 = sum(rhoThimeResolvedSRCMeanWatch,2);
        time1 = 1:length(rhoTimeResolved1);
        time2 = 1:length(rhoTimeResolved2);


        yTick = [-0.25:.25:0.5];
        for ii = 1:length(yTick)
            yTickLabel{ii} = ['\color{white} ' num2str(yTick(ii))];
        end
        yLim = [-.15 yTick(end)]
        
        axes(plotHandleSRC(1)); hold on
        hp1a = plot(time1,rhoTimeResolved1,'color','b','LineWidth',1);
        
        hp1c = plot(time1,rhoThimeResolvedSRCMeanBci); colormap jet;
        for i = 1:11
            hp1c(i).Color(4) = 0.5;
        end
        
        xTick1 = 1:fsCorr:time1(end);
        tEnd1 = time1(end)/5;        
        xTickLabel = (0:1:tEnd1-1);
        for ii = 1:length(xTickLabel)
            xTickLabel1{ii} = ['\color{white} ' num2str(xTickLabel(ii))];
        end
        set(plotHandleSRC(1),'xtick',xTick1,'xTickLabel',xTickLabel1, 'xcolor','k')
        xlim([time1(1) - displayWindowLength/2 time1(1)+ displayWindowLength])
        xlabel('time (s)', 'FontSize',12,'color','w')
        set(plotHandleSRC(1),'ytick',yTick ,'yticklabel',yTickLabel, 'ycolor','k')

        ylim(yLim)
        ylabel('Stimulus-Response Correlation','FontSize',14,'color','w')
         grid on

        axes(plotHandleSRC(2)); hold on
        hp2a = plot(time2,rhoTimeResolved2,'color','b','LineWidth',1);
        hp2c = plot(time2,rhoThimeResolvedSRCMeanWatch); colormap jet;
        
        for i = 1:11
            hp2c(i).Color(4) = 0.5;
        end
        
         xTick2 = 1:fsCorr:time2(end);
        tEnd2 = time2(end)/5;
        xTickLabel = (0:1:tEnd2-1);
        for ii = 1:length(xTickLabel)
            xTickLabel2{ii} = ['\color{white} ' num2str(xTickLabel(ii))];
        end
        set(plotHandleSRC(2),'xtick',xTick2,'xTickLabel',xTickLabel2, 'xcolor','k')
        xlabel('time (s)', 'FontSize',12,'color','w')
 
        yyaxis left
        set(plotHandleSRC(2),'ytick',yTick,'yticklabel',[], 'ycolor','k')
        ylim(yLim)

        yyaxis right
        set(plotHandleSRC(2),'ytick',yTick ,'yticklabel',yTickLabel, 'ycolor','k')
        ylim(yLim)
        xlim([time2(1) - displayWindowLength/2 time2(1)+ displayWindowLength])
        grid on

        %% initialize plot for cumulative src
        cumRho1 = 0;
        cumRho2 = 0;
        axes(plotHandleCumSRC(1));
        set(plotHandleCumSRC(1),'xtick',0,'xtick',[],'ytick',[0 150],'yticklabel',{'0', 'max'});
        xlim([-1 1]);
        ylim([0 155]); 
        
        axes(plotHandleCumSRC(2));
       
        ylabel('cumulative src');
        set(plotHandleCumSRC(2),'xtick',0,'xtick',[],'ytick',[0 150],'yticklabel',{'0', 'max'});
        yl = ylabel('Cumulative SRC','FontSize',14,'color','w') ;
%         set(yl, 'position', get(yl,'position')-[0.25,0,0])
        xlim([-1 1]) ;
        ylim([0 155]);
        
        %% initialize topmap of the eeg.
        ylabels = {'EEG Raw' 'EEG Alpha', ''}
        numPlots = 2;

        max1 = max(max(eegBciMean));
        max2 = max(max(eegWatchMean));

        min1 = min(min(eegBciMean));
        min2 = min(min(eegWatchMean));
        
        minVal = min(min1,min2);
        maxVal = max(max1,max2);

        cAxis = [minVal, mean([minVal maxVal]), maxVal];
        cAxisTickLabel = {['\color{white}' num2str(minVal, '%0.0f')] , ...
            '\color{white}\muV', ...
            ['\color{white}' num2str(maxVal, '%0.0f')]};
            
        plotHandle = plotHandleBottomLeft(1);
        topmap1(1) = setMap(Topomap('JBhead96_sym.loc'));
        topmap1(1).setPlotHandle(plotHandle);
        topmap1(1).drawMaskHeadRing(.5);
        topmap1(1).drawNoseAndEars(.5);
        topmap1(1).formatPlot(plotHandleBottomLeft(1),'w');
        topmap1(1).setColorAxis([minVal maxVal])
        topmap1(1).setColorBar(cAxis, cAxisTickLabel)
        xlabel(ylabels(1),'FontSize',12,'color','w')
        
        plotHandle = plotHandleBottomRight(1);
        topmap2(1) = setMap(Topomap('JBhead96_sym.loc'));
        topmap2(1).setPlotHandle(plotHandle);
        topmap2(1).drawMaskHeadRing(.5);
        topmap2(1).drawNoseAndEars(.5);
        topmap2(1).formatPlot(plotHandleBottomRight(1),'w');
        topmap2(1).setColorAxis([minVal maxVal])
        topmap2(1).setColorBar(cAxis, cAxisTickLabel)
        xlabel(ylabels(1),'FontSize',12,'color','w')
        
        max1 = max(max(eegWatchPowerMean));
        max2 = max(max(eegWatchPowerMean));

        min1 = min(min(eegBciPowerMean));
        min2 = min(min(eegBciPowerMean));
        
        minVal = min(min1,min2);
        maxVal = max(max1,max2);

        cAxis = [minVal, mean([minVal maxVal]), maxVal];
        cAxisTickLabel = {['\color{white}' num2str(minVal, '%0.0f')] , ...
            '\color{white}\muV^2', ...
            ['\color{white}' num2str(maxVal, '%0.0f')]};
        
        plotHandle = plotHandleBottomLeft(2);
        topmap1(2) = setMap(Topomap('JBhead96_sym.loc'));
        topmap1(2).setPlotHandle(plotHandle);
        topmap1(2).drawMaskHeadRing(.5);
        topmap1(2).drawNoseAndEars(.5);
        topmap1(2).formatPlot(plotHandleBottomLeft(2),'w');
        topmap1(2).setColorAxis([minVal maxVal])
        topmap1(2).setColorBar(cAxis, cAxisTickLabel)
        xlabel(ylabels(2),'FontSize',12,'color','w')
        
        plotHandle = plotHandleBottomRight(2);
        topmap2(2) = setMap(Topomap('JBhead96_sym.loc'));
        topmap2(2).setPlotHandle(plotHandle);
        topmap2(2).drawMaskHeadRing(.5);
        topmap2(2).drawNoseAndEars(.5);
        topmap2(2).formatPlot(plotHandleBottomRight(2),'w');
        topmap2(2).setColorAxis([minVal maxVal])
        topmap2(2).setColorBar(cAxis, cAxisTickLabel)
        xlabel(ylabels(2),'FontSize',12,'color','w')
        
        %% initialize plot for cumulative power
        cumPower1 = 0;
        cumPower2 = 0;
        axes(plotHandleCumAlpha(1));
      
        set(plotHandleCumAlpha(1),'xtick',0,'xtick',[],'ytick',[0 1000],'yticklabel',{'0', 'max'});
        xlim([-1 1]);
        ylim([0 1010]);
        
        axes(plotHandleCumAlpha(2));
%         xlabel('Cumulative Alpha');
        set(plotHandleCumAlpha(2),'xtick',0,'xtick',[],'ytick',[0 1000],'yticklabel',{'0', 'max'});
        yl = ylabel('Cumulative Alpha','FontSize',14,'color','w') ;
%         set(yl, 'position', get(yl,'position')-[0.25,0,0])
        xlim([-1 1]) ;
        ylim([0 1010])       ;

        
       
    end
   
    
    if iFrame >= raceStartIndex
        
        %% overlay stimulus feature
        indHandle = 1;
        featureFrame1 = double(squeeze(stimBci(iter+1,:,:)));
        featIntensity1 = normFeatIntensity(iter);
        
        frameBorder1 = colorMapIntensity(featIntensity1,:);
        imgFrame1 = stimulusFeatureOverlay(imgFrame1, featureFrame1);
        
        featureFrame2 = double(squeeze(stimWatch(iter+1,:,:)));
        featIntensity2 = normFeatIntensity(iter);
        
        frameBorder2 = colorMapIntensity(featIntensity1,:);
        imgFrame2 = stimulusFeatureOverlay(imgFrame2, featureFrame2);
        
        %% draw src along time resolved axis
        isDrawn1 = false;
        if iter == 1 || mod(iter-1,6) == 0
            
            delete(topmap1(2).surfaceHandle)
            delete(topmap2(2).surfaceHandle)
                
            delete(ph1b)
            delete(ph2b)
            axes(plotHandleSRC(1)); hold on

            xlim([time1(valIter) - displayWindowLength/2 time1(valIter)+ displayWindowLength])
            ph1b = plot(time1(valIter),rhoTimeResolved1(valIter),'o','color','k','MarkerFaceColor','r','MarkerSize',10);

            axes(plotHandleSRC(2)); hold on
            ph2b = plot(time2(valIter),rhoTimeResolved2(valIter),'o','color','k','MarkerFaceColor','r','MarkerSize',10);

            xlim([time2(valIter) - displayWindowLength/2 time2(valIter)+ displayWindowLength])
            
            
            %% draw cumulative src to show difference between active and passive
            axes(plotHandleCumSRC(1)); hold on
            rho1 = rhoTimeResolved1(valIter);
            cumRho1 = cumRho1 + rho1;
            pb1 =bar(0,cumRho1,'BarWidth', 2,'FaceColor',[0 1 0],'EdgeColor',[150 150 150]/255);

            axes(plotHandleCumSRC(2)); hold on
            rho2 = rhoTimeResolved2(valIter);
            cumRho2 = cumRho2 + rho2;
            pb1 = bar(0,cumRho2,'BarWidth', 2,'FaceColor',[0 1 0],'EdgeColor',[150 150 150]/255);        
            
            %% draw alpha power
            eegPower1 = squeeze(eegBciPowerMean(valIter,:));
            topmap1(2).draw(eegPower1) 
        
            eegPower2 = squeeze(eegWatchPowerMean(valIter,:));
            topmap2(2).draw(eegPower2)
           
            %% draw cumulative alpha power to show difference between active and passive
            axes(plotHandleCumAlpha(1)); hold on
            power = mean(eegPower1);
            cumPower1 = cumPower1 + power;
            pb1 =bar(0,cumPower1,'BarWidth', 2,'FaceColor',[0 1 0],'EdgeColor',[150 150 150]/255);

            axes(plotHandleCumAlpha(2)); hold on
            power = mean(eegPower2);
            cumPower2 = cumPower2 + power;
            pb1 = bar(0,cumPower2,'BarWidth', 2,'FaceColor',[0 1 0],'EdgeColor',[150 150 150]/255);        
            
            valIter = valIter +1;
            isDrawn2 = true;
        end
        
        
        eeg1 = squeeze(eegBci(iter,:,11));
        topmap1(1).draw(eeg1) 
        
        eeg2 = squeeze(eegWatch(iter,:,10));
        topmap2(1).draw(eeg2)
                    
        isDrawn1 = true;          
        iter = iter+1;
    end
    
    
    drawVideoFrame_(plotHandleVideo(1), imgFrame1, frameBorder1)
    t1 = title('Sham Active','FontSize',16,'color','w');
    
    set(t1,'Position', t1.Position - [0,15,0]);

    drawVideoFrame_(plotHandleVideo(2), imgFrame2, frameBorder2)
    t2 = title('Passive','FontSize',16,'color','w');
    set(t2,'Position', t2.Position -  [0,15,0]);
    
    M=getframe(fig);
    writeVideo(v,M);

    cla(plotHandleVideo(1))
    cla(plotHandleVideo(2))
    
    
    if isDrawn1
        delete(topmap1(1).surfaceHandle)
        delete(topmap2(1).surfaceHandle)
    end
    

end

close(v);