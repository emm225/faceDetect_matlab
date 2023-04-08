function varargout = face(varargin)
% FACE MATLAB code for face.fig
%      FACE, by itself, creates a new FACE or raises the existing
%      singleton*.
%
%      H = FACE returns the handle to a new FACE or the handle to
%      the existing singleton*.
%
%      FACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACE.M with the given input arguments.
%
%      FACE('Property','Value',...) creates a new FACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before face_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to face_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help face

% Last Modified by GUIDE v2.5 18-Dec-2014 12:02:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @face_OpeningFcn, ...
                   'gui_OutputFcn',  @face_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
%     try
%         gui_mainfcn(gui_State, varargin{:});
%     catch
%         fprintf("未获取人脸数据，请进行正确操作\n");
%     end
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before face is made visible.
function face_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to face (see VARARGIN)

% Choose default command line output for face
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes face wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = face_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% read image to be recognize
global im;                      %存储选择的图像
global pending;                 %待处理
[filename, pathname] = uigetfile({'*.bmp'},'choose photo');
str = [pathname, filename];     %将文件名和目录名组合成一个完整的路径
im = imread(str);               %读入图像
pending = str;                  %暂存待处理图片地址
axes( handles.axes1);           %定义图形区域axes1
imshow(im);                     %显示图像
%在GUI的某个特定区域显示图像时，需要使用axes函数定义这个区域，并将其与imshow函数一起使用来显示图像
%如果不使用axes函数，imshow函数会默认在最后一个被激活的图形窗口中显示图像
%使用axes函数定义图形区域后，可以使用imshow函数将图像显示在指定的区域内




% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global im                       %存储选择的图像
global reference                %训练样本在新座标基下的表达矩阵
global W                        %新向量在新的坐标系的投影，每一列代表一张特征脸
global imgmean                  %均值列向量
global col_of_data              %训练样本总数
global pathname
global img_path_list
global pending;                 %待处理

% 预处理新数据
im = double(im(:));             %（：）将矩阵转换为行向量或列向量，这里转换为列向量
objectone = W'*(im - imgmean);  %得到图片在新坐标系的坐标
distance = 100000000;

% 最小距离法，寻找和待识别图片最为接近的训练图片
for k = 1:col_of_data
    temp = norm(objectone - reference(:,k));    %计算欧式距离
    if(distance>temp)
        aimone = k;             %取出距离最小的训练图片
        distance = temp;
        aimpath = strcat(pathname, '/', img_path_list(aimone).name); %给出[pathname,filename]
        axes( handles.axes2 )
        imshow(aimpath)
    end
end
if(distance>5e+07)
    flag = 1;
    fprintf("超出所设距离阈值，识别失败！\n");
else
    flag =0;
    fprintf("识别成功！\n");
end

%更新训练库
if(flag == 1)
    image_resized(pending);
end

% 显示测试结果
% aimpath = strcat(pathname, '/', img_path_list(aimone).name);
% axes( handles.axes2 )
% imshow(aimpath)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global reference        %训练样本在新座标基下的表达矩阵
global W                %新向量在新的坐标系的投影，每一列代表一张特征脸
global imgmean          %均值列向量
global col_of_data      %训练样本总数
global pathname
global img_path_list

% 批量读取指定文件夹下的图片128*128
pathname = uigetdir;
img_path_list = dir(strcat(pathname,'\*.bmp'));
img_num = length(img_path_list);
imagedata = [];
if img_num >0
    for j = 1:img_num
        img_name = img_path_list(j).name;
        temp = imread(strcat(pathname, '/', img_name));
        temp = double(temp(:));         %将单精度(float)的temp转换为双精度(double)的列向量
        imagedata = [imagedata, temp];  %将temp数据加入进imagedata
    end
end
col_of_data = size(imagedata,2);        %1表示获取imagedata行数，2表示获取imagedata列数  imagedata的列数（等于训练的样本数）

% 中心化 & 计算协方差矩阵
imgmean = mean(imagedata,2);            %返回值为每一行均值的列向量
for i = 1:col_of_data
    imagedata(:,i) = imagedata(:,i) - imgmean;
end
covMat = imagedata'*imagedata;          % 求协方差矩阵
[COEFF, latent, explained] = pcacov(covMat);    %COEFF为特征向量矩阵 latent为特征值向量 explained为每个特征值的贡献度,返回的explained从大到小排列

%explained是一个向量，其和表示总贡献度，即100%

% 选择构成95%能量的特征值
i = 1;
proportion = 0;
while(proportion < 95)
    proportion = proportion + explained(i);
    i = i+1;
end
p = i - 1;              %W的列数等于p

% 特征脸
W = imagedata*COEFF;    % N*M阶 imagedata向新坐标映射
W = W(:,1:p);           % N*p阶 取前p列

% 训练样本在新座标基下的表达矩阵 p*M
reference = W'*imagedata;


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 选择测试集

global W                   %新向量在新的坐标系的投影，每一列代表一张特征脸
global reference           %训练样本在新座标基下的表达矩阵
% col_of_data = 60;
global col_of_data;        %训练样本总数

pathname = uigetdir;
img_path_list = dir(strcat(pathname,'\*.bmp'));
img_num = length(img_path_list);
testdata = [];
if img_num >0
    for j = 1:img_num
        img_name = img_path_list(j).name;
        temp = imread(strcat(pathname, '/', img_name));
        temp = double(temp(:));
        testdata = [testdata, temp];
    end
end

meandata = mean(testdata,2);
col_of_test = size(testdata,2);
for i = 1:col_of_test
    testdata(:,i) = testdata(:,i) - meandata;
end
%testdata = center( testdata );

object = W'* testdata;

% 最小距离法，寻找和待识别图片最为接近的训练图片
% 计算分类器准确率
num = 0;
for j = 1:col_of_test;
    distance = 1000000000000;
    for k = 1:col_of_data;
        temp = norm(object(:,j) - reference(:,k));
        if(distance>temp)
            aimone = k;
            distance = temp;
        end
    end
    if ceil(j/3)==ceil(aimone/4)        %进行分类
       num = num + 1;
    end
end
accuracy = num/col_of_test;
msgbox(['分类器准确率:                   ',num2str(accuracy)],'accuracy')
