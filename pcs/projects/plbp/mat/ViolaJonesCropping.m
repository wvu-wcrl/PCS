
function [J]= ViolaJonesCropping(img)

[T1,T2,T3]=size(img);

try
    %img=imread('01-3m.jpg');
    faceDetector = vision.CascadeObjectDetector();
    
    % Run the detector.
    videoFrame      = img;
    bbox            = step(faceDetector, videoFrame);
    
    if T1== 576 && T2== 720
        
        %Let's bypass the img if it comes from the database
        J=img;
        
        %     % enlarge a bit the window
        %     bbox(2)= bbox(2)*0.4;
        %     bbox(4)= bbox(4)*1.9;
        %     bbox(1)= bbox(1);
        %     bbox(3)= bbox(3)*1.05;
        %
        %     % get only the face and show it
        %     Icrop = imcrop(img,bbox);
        %
        %     img1=imread('BackPlane.ppm');
        %
        %     img1 = imresize(img1, [576,720]);
        %
        %     [L1,L2,L3]=size(Icrop);
        %     [S1,S2,S3]=size(img1);
        %
        %     start1=(S1-L1);
        %     start2=(S2-L2)/2;
        %
        %     img1(start1:(start1+L1-1),start2:(start2+L2-1),:)=Icrop;
        %
        %     J = img1;
        
    else
        
        % enlarge a bit the window
        bbox(2)= bbox(2)*0.3;
        bbox(4)= bbox(4)*1.8;
        bbox(1)= bbox(1)*0.98;
        bbox(3)= bbox(3)*1.12;
        
        % get only the face and show it
        Icrop = imcrop(img,bbox);
        
        [N1,N2,N3]=size(Icrop)
        img1=imread('BackPlane.ppm');
        
        img1 = imresize(img1, [T1,T2]);
        
        [L1,L2,L3]=size(Icrop);
        [S1,S2,S3]=size(img1);
        
        start1=(S1-L1);
        start2=(S2-L2)/2;
        
        img1(start1:(start1+L1-1),start2:(start2+L2-1),:)=Icrop;
        
        J = imresize(img1, [576,720]);
        
    end
catch exception   
    J=img;   
end

end
