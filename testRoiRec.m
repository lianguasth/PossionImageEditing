hf = figure(1);
A = imread('moon.JPG');
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
end