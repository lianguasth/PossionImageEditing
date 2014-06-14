function [ src ] = calV_y2( src, n , padding_factor)
%CALV_Y2 Summary of this function goes here
%   Detailed explanation goes here
a = src(1+padding_factor,:)-src(2+padding_factor,:);
b = src(n-1-padding_factor,:)-src(n-padding_factor,:);
src(2+padding_factor:n-1-padding_factor,:) = 0;
src(1+padding_factor,:) = a;
src(n-padding_factor,:) = b;
end

