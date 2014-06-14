A = imread('moon.JPG');
[bw, xi, yi] = roipoly(A);
bw = uint8(bw);
Ir = bw .* A(:,:,1);
Ig = bw .* A(:,:,2);
Ib = bw .* A(:,:,3);

A(:,:,1)=Ir;
A(:,:,2)=Ig;
A(:,:,3)=Ib;
imshow(A);