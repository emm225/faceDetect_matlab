function findme()
% 创建GUI
Fig = figure('Position',[100,150,980,500]);

Pnl1 = uipanel(Fig,'Position',[0.05,0.17,0.9,0.8]);
Pnl2 = uipanel(Fig,'Position',[0.05,0.05,0.9,0.1]);

Axes1 = axes(Pnl1,'Position',[0,0,1/2,1]);
Axes2 = axes(Pnl1,'Position',[1/2,0,1/2,1]);

Bt = uicontrol(Pnl2,'style','togglebutton','String','人脸检测','Fontsize',16,...
    'Units','normalized','Position',[2/5,0,1/5,1],'Callback',@FaceDetection);
drawnow

% 开启摄像头
Hcamera = [];
Hobj = [];
if isempty(Hcamera)
    Hobj = videoinput('winvideo',1,'MJPG_640x480');
    Hcamera = preview(Hobj);
    frame = getsnapshot(Hobj);  % 获取帧
    [rows,cols,~] = size(frame);
end

% 人脸识别
flag = 0;
faceDetector = vision.CascadeObjectDetector();
gap = 2;

% 开始
while 1
    if ishandle(Hcamera)
        % 获取影像
        frame = getsnapshot(Hobj);  % 获取帧
        frame = im2double(frame);
        % 显示
        imshow(frame,'Parent',Axes1)
        % 检测
        if flag
            bboxx = face(frame);
            hold(Axes1,'on')
            for i = 1:size(bboxx,1)
                bbox = bboxx(i,:);
                rc = bbox+[-bbox(3)/4,-bbox(4)/4,bbox(3)/2,bbox(4)/2];
                rectangle('Position',rc,'Curvature',0,...
                    'LineWidth',2,'LineStyle','--',...
                    'EdgeColor','y','Parent',Axes1)
                % 检查 rc 是否在图像范围内
                rc(1) = max(1, rc(1));
                rc(2) = max(1, rc(2));
                rc(3) = min(cols-rc(1), rc(3));
                rc(4) = min(rows-rc(2), rc(4));
                
                % 实时获取方框内的视频流并输出到Axes2中
                subframe1 = frame(rc(2):rc(2)+rc(4),rc(1):rc(1)+rc(3),:);
                
                %subframe2 = grayscale(subframe1);
%                 % 灰度化
%                 grayframe = rgb2gray(subframe1);
                  subframe2 = rgb2gray(subframe1);
%                 % 锐化
%                 sharpcore = [-1,-1,-1;-1,9,-1;-1,-1,-1];
%                 sharpframe = imfilter(grayframe, sharpcore);
%                 % 对比度增强
%                 subframe2 = imadjust(sharpframe, [0.3 0.7], [0 1]);

                subframe = cat(2,subframe1,cat(3,subframe2,subframe2,subframe2));
                imshow(subframe,'Parent',Axes2)
            end
            hold(Axes1,'off')
        end
        drawnow
    else
        break
    end
end

    function FaceDetection(~,~)
        flag = get(Bt,'Value');
    end

    function bboxx = face(frame)
        frame = frame(1:gap:end,1:gap:end,:);
        bboxx = step(faceDetector, frame);
        bboxx = bboxx*gap;
    end
    function ed = grayscale(frame)
        % 灰度边缘
        core1 = [1,1,1;0,0,0;-1,-1,-1;];
        core2 = [1,1,0;1,0,-1;0,-1,-1;];
        frame = rgb2gray(frame);
        im1 = imfilter(frame,core1);
        im2 = imfilter(frame,core1');
        im3 = imfilter(frame,core2);
        im4 = imfilter(frame,core2');
        ed = max(abs(cat(3,im1,im2,im3,im4)),[],3);
    end
end
