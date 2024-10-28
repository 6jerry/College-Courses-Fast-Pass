function varargout = LeafDiseaseGradingSystemGUI(varargin)
% LeafDiseaseGradingSystemGUI MATLAB code for LeafDiseaseGradingSystemGUI.fig
%      LeafDiseaseGradingSystemGUI, by itself, creates a new LeafDiseaseGradingSystemGUI or raises the existing
%      singleton*.
%
%      H = LeafDiseaseGradingSystemGUI returns the handle to a new LeafDiseaseGradingSystemGUI or the handle to
%      the existing singleton*.
%
%      LeafDiseaseGradingSystemGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LeafDiseaseGradingSystemGUI.M with the given input arguments.
%
%      LeafDiseaseGradingSystemGUI('Property','Value',...) creates a new LeafDiseaseGradingSystemGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the LeafDiseaseGradingSystemGUI before LeafDiseaseGradingSystemGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LeafDiseaseGradingSystemGUI_OpeningFcn via varargin.
%
%      *See LeafDiseaseGradingSystemGUI Options on GUIDE's Tools menu.  Choose "LeafDiseaseGradingSystemGUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LeafDiseaseGradingSystemGUI

% Last Modified by GUIDE v2.5 20-Jan-2015 14:49:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LeafDiseaseGradingSystemGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @LeafDiseaseGradingSystemGUI_OutputFcn, ...
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


% --- Executes just before LeafDiseaseGradingSystemGUI is made visible.
function LeafDiseaseGradingSystemGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LeafDiseaseGradingSystemGUI (see VARARGIN)
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

Disease_Grading = readfis('Disease_Grading.fis');

handles.Disease_Grading = Disease_Grading;
guidata(hObject,handles);

% Choose default command line output for LeafDiseaseGradingSystemGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LeafDiseaseGradingSystemGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LeafDiseaseGradingSystemGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in select_image.
function select_image_Callback(hObject, eventdata, handles)
% hObject    handle to select_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

       [File_Name, Path_Name] = uigetfile('PATHNAME');
       I = imread([Path_Name,File_Name]);
       imshow([Path_Name,File_Name], 'Parent', handles.axes1); title('Original Leaf Image', 'Parent', handles.axes1);
       
       %# store queryname, version 1
       handles.I = I;
       guidata(hObject,handles);
       



% --- Executes on button press in segmentation.
function segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to segmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

I = handles.I;

% Creating color transformation from sRGB to L*a*b % 
cform = makecform('srgb2lab'); 

lab_I = applycform(I,cform);

ab = double(lab_I(:,:,2:3));

nrows = size(ab,1); 
ncols = size(ab,2);

ab = reshape(ab,nrows*ncols,2); 
% No of clusters to be created with five iterations % 
nColors =5; 
[cluster_idx cluster_center] = kmeans(ab,nColors,'EmptyAction','singleton','distance','sqEuclidean','start',[128,128;128,128;128,128;128,128;128,128]); 

pixel_labels = reshape(cluster_idx,nrows,ncols); 

segmented_images = cell(5);

rgb_label = repmat(pixel_labels,[1 1 3]);

for k = 1:nColors 
color = I; 
color(rgb_label ~= k) = 0; 
segmented_images{k} = color; 
end

% displaying different show_clusters objects %

I_cluster_1 = segmented_images{1};

I_cluster_2 = segmented_images{2};

I_cluster_3 = segmented_images{3};

I_cluster_4 = segmented_images{4};

I_cluster_5 = segmented_images{5};

imshow(I_cluster_1,'Parent', handles.axes2); title('Cluster 1');

 handles.I_cluster_1 = I_cluster_1;
 handles.I_cluster_2 = I_cluster_2;
 handles.I_cluster_3 = I_cluster_3;
 handles.I_cluster_4 = I_cluster_4;
 handles.I_cluster_5 = I_cluster_5;

 guidata(hObject,handles);


% --- Executes on button press in disease_grade.
function disease_grade_Callback(hObject, eventdata, handles)
% hObject    handle to disease_grade (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Disease_Grading = handles.Disease_Grading;

white_pixels_I = handles.white_pixels_I ;
 
white_pixels_I_selected = handles.white_pixels_I_selected ;
 
 percentage_infected = (white_pixels_I_selected/white_pixels_I)*100;
 
 grade = evalfis(percentage_infected,Disease_Grading);
 
 figure();
 
 plot(percentage_infected,grade,'g*');
 
 legend('Percent - Grade of Disease');

title('Disease Grade Classification Using Fuzzy Logic');
xlabel('Percentage');
ylabel('Disease Grade');

% --- Executes on button press in binary_original.
function binary_original_Callback(hObject, eventdata, handles)
% hObject    handle to binary_original (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

I = handles.I;

BW_I = im2bw(I,0.17);

white_pixels_I = sum(BW_I(:) == 1);

se = strel('disk',1);

closeBW = imclose(BW_I,se);

imshow(closeBW,'Parent', handles.axes2); title('Binary of Original Image');

handles.white_pixels_I = white_pixels_I;

guidata(hObject,handles);



% --- Executes on button press in binary_diseased.
function binary_diseased_Callback(hObject, eventdata, handles)
% hObject    handle to binary_diseased (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

I_selected = handles.I_slected ;

BW_I_selected = im2bw(I_selected,0.17);

white_pixels_I_selected = sum(BW_I_selected(:) == 1);

se = strel('disk',5);

closeBW = imclose(BW_I_selected,se);

imshow(closeBW,'Parent', handles.axes2); title('Binary of Clustered Image');

handles.white_pixels_I_selected = white_pixels_I_selected;

guidata(hObject,handles);


% --- Executes on selection change in show_clusters.
function show_clusters_Callback(hObject, eventdata, handles)
% hObject    handle to show_clusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns show_clusters contents as cell array
%        contents{get(hObject,'Value')} returns selected item from show_clusters
 I_cluster_1 = handles.I_cluster_1 ;
 I_cluster_2 = handles.I_cluster_2 ;
 I_cluster_3 = handles.I_cluster_3 ;
 I_cluster_4 = handles.I_cluster_4 ;
 I_cluster_5 = handles.I_cluster_5 ;
 
% Determine the selected data set.
str = get(hObject, 'String');
val = get(hObject,'Value');

% Set current data to the selected data set.
switch str{val};
case 'Cluster 1' % User selects peaks.   
    imshow(I_cluster_1,'Parent', handles.axes2); title('Cluster 1');
    I_selected = I_cluster_1;
case 'Cluster 2' % User selects membrane.
    imshow(I_cluster_2,'Parent', handles.axes2); title('Cluster 2');
    I_selected = I_cluster_2;
case 'Cluster 3' % User selects sinc.
    imshow(I_cluster_3,'Parent', handles.axes2); title('Cluster 3');
    I_selected = I_cluster_3;
case 'Cluster 4' % User selects sinc.
    imshow(I_cluster_4,'Parent', handles.axes2); title('Cluster 4');
    I_selected = I_cluster_4;
case 'Cluster 5' % User selects sinc.
    imshow(I_cluster_5,'Parent', handles.axes2); title('Cluster 5');
    I_selected = I_cluster_5;
end

% Save the handles structure.

handles.I_slected = I_selected;

guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function show_clusters_CreateFcn(hObject, eventdata, handles)
% hObject    handle to show_clusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%closing dilation


% --- Executes on button press in save_image.
function save_image_Callback(hObject, eventdata, handles)
% hObject    handle to save_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes2 = handles.axes2;

axes1 = handles.axes1;

h1=get(axes1,'Title');
h2=get(axes2,'Title');

figure();

subplot(1,2,1) ; imshow(getimage(axes1)); title(h1.String);
subplot(1,2,2) ; imshow(getimage(axes2)); title(h2.String);
