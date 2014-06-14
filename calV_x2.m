function [ src ] = calV_x2( src, n , padding_factor)
%CALV_X2 Summary of this function goes here
%   Detailed explanation goes here
a = src(:,padding_factor+1)-src(:,2+padding_factor);
b = src(:,n-1-padding_factor)-src(:,n-padding_factor);
src(:,padding_factor+2:n-1-padding_factor) = 0;
size(a)
size(src(:,1))
src(:,padding_factor+1) = a;
src(:,n-padding_factor) = b;
end

