function drawVideoFrame_(pltHandle, imageFrame, frameBorder)
    axes(pltHandle);
    imshow(uint8(imageFrame));

    pltHandle.Visible = 'on';
    pltHandle.XTick = [];
    pltHandle.YTick = [];
    pltHandle.LineWidth = 5;
    pltHandle.XColor = frameBorder;
    pltHandle.YColor = frameBorder;
end