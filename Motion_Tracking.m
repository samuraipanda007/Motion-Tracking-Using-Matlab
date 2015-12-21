%% Opening
close all
clear
clc

%% Input video and Output video names
myvid = VideoReader('Input_Video.mp4');%Input video
nFrames = myvid.NumberOfFrames; %Reading the framse in the video
writerObj = VideoWriter('Output_Video.avi'); % Name it.
writerObj.FrameRate = 30; % How many frames per second.
open(writerObj);

%% Making the frames of the output video
for frames = 1:nFrames-3
%% Reading the frames of the video
currentrgb = im2double(read(myvid,(frames+1))); %Get a collored image for the video

reference = im2double(rgb2gray(read(myvid,frames))); 
current = im2double(rgb2gray(read(myvid,frames+1))); %Takes the 3 frames from the video to process
after = im2double(rgb2gray(read(myvid,frames+2)));   %This 3 frames will then be use to generate the vektor fields an frame

%The size of the frames
[m,n,o] = size (reference);
[M,N,O] = size (currentrgb);

%% Dividing the frames into blocks of 5x5 pixel size
divider1 = 72; %Divides the image into 72 block in the y direction
divider2 = 128;%Divides the image into 128 block in the x direction

%Dividing the frames
referenceV2 = mat2cell(reference,diff(round(linspace(0,m,divider1+1))), diff(round(linspace(0,n,divider2+1))));
currentV2 = mat2cell(current,diff(round(linspace(0,m,divider1+1))), diff(round(linspace(0,n,divider2+1))));
afterV2     = mat2cell(after,diff(round(linspace(0,m,divider1+1))), diff(round(linspace(0,n,divider2+1))));

%The size of the blokoed images
[mV2,nV2,oV2] = size (referenceV2);
[MV2,NV2,OV2] = size (currentV2);
[d,f,e] = size (cell2mat(referenceV2(1,1)));

dummy=zeros(m,n);%Making dummys for generating blobed image
dummy2=zeros(m,n);

%% SAD to make blobed images
for i=1:mV2;
    for j=1:nV2;
        difference2 (i,j) = sum(abs(sum(sum(cell2mat(currentV2(i,j)) - cell2mat(referenceV2(i,j)))))); %SAD of the current and refrence frames
        difference3 (i,j) = sum(abs(sum(sum(cell2mat(afterV2(i,j)) - cell2mat(currentV2(i,j))))));     %SAD of the after and current frames
            
        %Threshold
        difference2 (difference2<1) = 0;
        difference3 (difference3<1) = 0;
            
        %Locating blocks 
        if difference2(i,j)>0.26;%locating the block that has a diffrence  an then marking the
            hasil_x2=j;          %location of the block by making the dummy white thus making a
            hasil_y2=i;          %blobed image
            x= (d*(hasil_x2-1));
            x22=x+d;
            y= (f*(hasil_y2-1));
            y22=y+f;

            for g2=x+1:x22;
                for h2=y+1:y22;
                    dummy(h2,g2)=1;
                end    
            end
        end
            
        if difference3(i,j)>0.26;
            hasil_x3=j;
            hasil_y3=i;
            x3= (d*(hasil_x3-1));
            x32=x3+d;
            y3= (f*(hasil_y3-1));
            y32=y3+f;
            for g3=x3+1:x32;
                for h3=y3+1:y32;
                    dummy2(h3,g3)=1;
                end    
            end
        end
    end
end
%% Getting the data of locations, velocities and directions
%Listing the location of pixels that are white (pixels that have moved)
l1 = regionprops(dummy,'PixelList');
l1 = cell2mat(struct2cell(l1));
[z,q]=size(l1);

%Getiing the size of the blobed region (height and width)
w = cell2mat(struct2cell(regionprops(dummy,'MajorAxisLength')));
h = cell2mat(struct2cell(regionprops(dummy,'MinorAxisLength')));
    
%Getiing the center location of the blobed image
s1 = regionprops(dummy, 'Centroid');
s1 = int16(cell2mat(struct2cell(s1)));
s2 = regionprops(dummy2, 'Centroid');
s2 = int16(cell2mat(struct2cell(s2)));

%Getiing the speed and direction for vecktors
u=(s2(1,1)-s1(1,1));%by getiing the difrences of centroid location 
v=(s2(1,2)-s1(1,2));%in the two blobed images we can that calculate 
U=zeros(n,m);       %the speed and the direction the object is moving
V=zeros(n,m);

%Making a box to point out the region thats moving with the height of h and width of w
currentrgb=insertShape(reference,'Rectangle',[ (s2(1,1)-w/2+u) (s2(1,2)-h/2-10+v) w+10 h+10], 'LineWidth', 5);

%% Generating a quiver plot of the velocities and overlaying it on top of the image
for i=1:z;  
    if mod(i,50) == 0
        X=l1(i,1);
        Y=l1(i,2);% this is to space the vector arrows apart by 50 pixels so its easier to see 
        U(X,Y)=u;
        V(X,Y)=v;
    end
end

[a,b] = meshgrid(0:1:m-1,0:1:n-1);
imshow(currentrgb); hold on;                %this is to generate the quiver plot
vektor=quiver(b,a,U,V,'AutoScaleFactor',8); %i enlarged the vectors by 8x so we can see it better

%% You can chose the output to be video or just the frames just uncomment it (running both would be slow)
%Saving the image into a frame for the output video (if you want to comment this make sure you comment the top part also)
frame = getframe(gcf); % 'gcf' can handle if you zoom in to take a movie.
writeVideo(writerObj, frame) 
hold off;
frames

%Saving the image individualy for viewing purposes 
% s=int2str(frames);
% s=['ImageFrame_' s '.jpg'];
% saveas(vektor,s);
end
close(writerObj); % Saves the movie.