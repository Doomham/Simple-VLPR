function [ out_char ] = shibie( img )
%%识别数字和字母
temp={'0.jpg','1.jpg','2.jpg','3.jpg','4.jpg','5.jpg','6.jpg','7.jpg','8.jpg','9.jpg',...
     'A.jpg','B.jpg','C.jpg','D.jpg','E.jpg','F.jpg','G.jpg', 'H.jpg','J.jpg',...
     'K.jpg','L.jpg','M.jpg','N.jpg','P.jpg', 'Q.jpg','R.jpg', 'S.jpg', 'T.jpg',...
     'U.jpg','V.jpg','W.jpg','X.jpg','Y.jpg','Z.jpg'};
[nothing,max]=size(temp);
for i=1:max
    fn=temp{i};
    y=imread(fn);
    [~,~,dim]=size(y);
    if dim==3
        y=rgb2gray(y);
    end
    th = imbinarize(y);
    res{i}=img-th;
    res{i}=abs(res{i});
    value(i)=sum(sum(res{i},1),2);
end
out_char=temp{find(value==min(value))}(1);
end

