A=imread('moon.JPG');
imshow(A);
hold on;

Threshold = 1;
UniBack=[0
    0
   255];

% choose background object, and B results into the Foreground Object and the
% Boundary Region
% choose the outer line of the boundary region. Single left click the mouse to specify vertice.Double left click or single right click to finish;
OuterBW = roipoly(A);
B(:,:,1) = immultiply(A(:,:,1),OuterBW);
B(:,:,2) = immultiply(A(:,:,2),OuterBW);
B(:,:,3) = immultiply(A(:,:,3),OuterBW);
Back(:,:,1) = immultiply(A(:,:,1),~OuterBW);
Back(:,:,2) = immultiply(A(:,:,2),~OuterBW);
Back(:,:,3) = immultiply(A(:,:,3),~OuterBW);
imshow(B);

% choose foreground object, and C results into a Circle of Interest
% choose the inner line of the boundary region. Single left click the mouse to specify vertice.Double left click or single right click to finish;
InnerBW = roipoly(B);
C(:,:,1) = immultiply(B(:,:,1),~InnerBW);
C(:,:,2) = immultiply(B(:,:,2),~InnerBW);
C(:,:,3) = immultiply(B(:,:,3),~InnerBW);
Fore(:,:,1) = immultiply(A(:,:,1),InnerBW);
Fore(:,:,2) = immultiply(A(:,:,2),InnerBW);
Fore(:,:,3) = immultiply(A(:,:,3),InnerBW);
imshow(C);

hold off;
RawAlpha = (double(OuterBW)+double(InnerBW))/2;

I = double(A);

% Method of "averaging" to get raw fore and background colors
for i = 1:size(RawAlpha,1)
     for j = 1:size(RawAlpha,2)
         RawFore(i,j,1)=0;                     
         RawFore(i,j,2)=0;
         RawFore(i,j,3)=0;
         RawBack(i,j,1)=0;                     
         RawBack(i,j,2)=0;
         RawBack(i,j,3)=0;
         if RawAlpha(i,j) == 1
             RawFore(i,j,:)=Fore(i,j,:);
         end;
         if RawAlpha(i,j) == 0
             RawBack(i,j,:)=Back(i,j,:);
         end;
         if RawAlpha(i,j) == 0.5
             r=1;
             while 1
                 TestFore = InnerBW(max(i-r,1):min(i+r,size(A,1)),max(j-r,1):min(j+r,size(A,2)));
                 if size(find(TestFore),1)  
                     [i1, j1] = find(TestFore);
                     i2 = i1 + max(i-r,1) -1;
                     j2 = j1 + max(j-r,1) -1;
                     Rs = double(Fore(i2,j2,:));
                     Ds(:,1)=diag(Rs(:,:,1));
                     Ds(:,2)=diag(Rs(:,:,2));
                     Ds(:,3)=diag(Rs(:,:,3));                 
                     if size(Ds,1) == 1
                         RawFore(i,j,:) =Ds;
                     else
                         RawFore(i,j,:) = sum(Ds) / size(Ds,1);
                     end;
                     clear Ds;
                     break;
                 else
                     r=r+1;
                 end;
             end;
             r=1;
             while 1
                 TestBack = ~OuterBW(max(i-r,1):min(i+r,size(A,1)),max(j-r,1):min(j+r,size(A,2)));
                 if size(find(TestBack),1)
                     [i1, j1] = find(TestBack);
                     i2 = i1 + max(i-r,1) -1;
                     j2 = j1 + max(j-r,1) -1;
                     Rs = double(Back(i2,j2,:));
                     Ds(:,1)=diag(Rs(:,:,1));
                     Ds(:,2)=diag(Rs(:,:,2));
                     Ds(:,3)=diag(Rs(:,:,3));                 
                     if size(Ds,1) == 1
                         RawBack(i,j,:) =Ds;
                     else
                         RawBack(i,j,:) = sum(Ds) / size(Ds,1);
                     end;
                     clear Ds;
                     break;
                 else
                     r=r+1;
                 end;
             end;
         end;
     end;
 end;

%此处没有用高斯滤波
Denorm = RawFore - RawBack;
%red channel
I1 = I(:,:,1);
Denorm1 = Denorm(:,:,1);

for i=1:size(Denorm1,1)
    for j= 1: size(Denorm1,2)
        if Denorm1(i,j)==0
            Denorm1(i,j)=1;
        end;
    end;
end;

OldAlpha = RawAlpha;
NewAlpha = RawAlpha;
h1=0;
while 1
    for i=1:size(OldAlpha,1)
        for j=1:size(OldAlpha,2)
            NewAlpha(i,j) = OldAlpha(i,j);
            if RawAlpha(i,j) == 0.5
                Roui = ((I1(i+1,j) + I1(i-1,j) - 2 * I1(i,j)) * Denorm1(i,j) - (I1(i+1,j) - I1(i,j)) * (Denorm1(i+1,j) - Denorm1(i,j)))/(Denorm1(i,j) * Denorm1(i,j));
                Rouj = ((I1(i,j+1) + I1(i,j-1) - 2 * I1(i,j)) * Denorm1(i,j) - (I1(i,j+1) - I1(i,j)) * (Denorm1(i,j+1) - Denorm1(i,j)))/(Denorm1(i,j) * Denorm1(i,j));
                Rou = Roui + Rouj;
                NewAlpha(i,j) = (OldAlpha(i+1,j) + NewAlpha(i-1,j) + OldAlpha(i,j+1) + NewAlpha(i,j-1) - Rou) / 4;
                if NewAlpha(i,j)<0
                    NewAlpha(i,j)=0;
                end;
                if NewAlpha(i,j)>1
                    NewAlpha(i,j)=1;
                end;
            end;
        end;
    end;
   % imshow(uint8(NewAlpha*255));
    DifferenceAlpha = abs(NewAlpha - OldAlpha);
    OldAlpha = NewAlpha;
    if sum(sum(DifferenceAlpha)) < Threshold
        break;
    end; 
    h1=h1+1;
end;
for i=1:size(A,1)
    for j=1:size(A,2)
        if OldAlpha(i,j)==0
            NewImage(i,j,:)=UniBack';
        else
            NewImage(i,j,1)=UniBack(1)*(1-OldAlpha(i,j))+RawFore(i,j,1)*OldAlpha(i,j);
            NewImage(i,j,2)=UniBack(2)*(1-OldAlpha(i,j))+RawFore(i,j,2)*OldAlpha(i,j);
            NewImage(i,j,3)=UniBack(3)*(1-OldAlpha(i,j))+RawFore(i,j,3)*OldAlpha(i,j);
        end;
    end;
end;
figure,imshow(NewAlpha);
figure,imshow(uint8(NewImage));
figure,imshow(uint8(RawFore));
figure,imshow(uint8(RawBack));