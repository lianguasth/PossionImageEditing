function varargout = GUI(varargin)
% GUI M-file for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 14-Jun-2014 22:16:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonLoadImage.
function buttonLoadImage_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoadImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname,filterindex]=uigetfile({'*.jpg';'*.bmp';'*.gif'},'选择图片');
%合成路径+文件名
str=[pathname filename];
if filterindex
    str = [pathname filename];
    c = imread(str);
    image(c,'Parent',handles.axes1);
    axis off;
    pic = getimage;
    handles.srcName = str;
    handles.srcImg = c;
    guidata(hObject,handles);
end


% --- Executes on button press in selZone.
function selZone_Callback(hObject, eventdata, handles)
% hObject    handle to selZone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hf = figure(1);
A = imread(handles.srcName);
%A = rgb2gray(A);
imshow(A);
rect = getrect(hf);
w = round(rect(3));
h = round(rect(4));
if w > 1 && h >1
    r = [rect(1), rect(1)+w, rect(1)+w, rect(1); rect(2), rect(2), rect(2)+h, rect(2)+h];
    rectangle('Position',[rect(1), rect(2), w, h], 'edgecolor', 'red');
    figure(2);
    bw = roipoly(A, r(1,:), r(2,:));
    AA = reshape(A, [(size(A,1)*size(A,2)),size(A,3)]);
    BB = AA(bw, :);
    B = reshape(BB,[h, w, size(A, 3)]);
    imshow(B);
    handles.imgWidth = w;
    handles.imgHeight = h;
    handles.imgSrcX = round(rect(1));
    handles.imgSrcY = round(rect(2));
    guidata(hObject,handles);
end


% --- Executes on button press in loadTargetImage.
function loadTargetImage_Callback(hObject, eventdata, handles)
% hObject    handle to loadTargetImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname,filterindex]=uigetfile({'*.jpg';'*.bmp';'*.gif'},'选择图片');
%合成路径+文件名
str=[pathname filename];
if filterindex
    str = [pathname filename];
    c = imread(str);
    image(c,'Parent',handles.axes2);
    axis off;
    pic = getimage;
    handles.targetName = str;
    handles.targetImg = c;
    guidata(hObject,handles);
end


% --- Executes on button press in selTargetPoint.
function selTargetPoint_Callback(hObject, eventdata, handles)
% hObject    handle to selTargetPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hf = figure(1);
A = imread(handles.targetName);
imshow(A);
[x,y]=ginput(1);
handles.targetX = round(x);
handles.targetY = round(y);
handles.targetY
guidata(hObject,handles);


% --- Executes on button press in solve.
function solve_Callback(hObject, eventdata, handles)
% hObject    handle to solve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
img_width = handles.imgWidth;
img_height = handles.imgHeight;

src_st_x = handles.imgSrcX;
src_st_y = handles.imgSrcY;
dst_st_x = handles.targetX;
dst_st_y = handles.targetY;


src_img = handles.srcImg;
dst_img = handles.targetImg;

extracted_src_img = src_img(src_st_y:src_st_y+img_height,src_st_x:src_st_x+img_width,:);
extracted_dst_img = dst_img(dst_st_y:dst_st_y+img_height,dst_st_x:dst_st_x+img_width,:);

[rws,cls] = size(extracted_src_img(:,:,1));

dst_img_temp = dst_img;
dst_img_temp(dst_st_y:dst_st_y+img_height,dst_st_x:dst_st_x+img_width,:) = extracted_src_img;
figure(3); imshow(uint8(dst_img_temp));
% imwrite(uint8(dst_img_temp),'C:\simple_cut_and_paste_result.bmp');

padding_factor = 3;
padded_src_img = pad_image(extracted_src_img,padding_factor);
padded_dst_img = pad_image(extracted_dst_img,padding_factor);

figure(4); imshow(uint8(padded_dst_img));
figure(5); imshow(uint8(padded_src_img));

temp_result = zeros(rws,cls,3);
temp_result(:,:,1) = find_result_channel(padded_src_img(:,:,1),padded_dst_img(:,:,1),padding_factor);
temp_result(:,:,2) = find_result_channel(padded_src_img(:,:,2),padded_dst_img(:,:,2),padding_factor);
temp_result(:,:,3) = find_result_channel(padded_src_img(:,:,3),padded_dst_img(:,:,3),padding_factor);
figure(6); imshow(uint8(temp_result));

dst_img(dst_st_y:dst_st_y+img_height,dst_st_x:dst_st_x+img_width,:) = temp_result;
figure(7); imshow(uint8(dst_img));


% --- Executes on button press in Mask.
function Mask_Callback(hObject, eventdata, handles)
% hObject    handle to Mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname,filterindex]=uigetfile({'*.jpg';'*.bmp';'*.gif'},'选择图片');
%合成路径+文件名
str=[pathname filename];
if filterindex
    str = [pathname filename];
    c = imread(str);
    srcImg = handles.srcImg;
%    c = repmat(c,[1,1,3]);
    c = logical(c);
    srcImg(~c) = 0;
    figure(1);
    imshow(srcImg);
end
