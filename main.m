clc;
clear;
close all;

file_name = 'test1.jpg';
img = imread(file_name);

%%
%��ȡ���ƿ��ܴ��ڵ�λ��
I=img;
I1=rgb2gray(I);
I2=edge(I1,'roberts',0.18,'both');
se=[1;1;1];
I3=imerode(I2,se);%��ʴ
se=strel('rectangle',[25,25]);
I4=imclose(I3,se);%ͼ����࣬���ͼ��
I5=bwareaopen(I4,2000);%ȥ�����ŻҶ�ֵС��2000�Ĳ���
[y,x]=size(I5);%���ظ�ά�ĳߴ磬�洢��x,y��
myI=double(I5);
if myI==0
    mydialog('error in get plate''s position');%��ȡλ��ʧ��
end
my_y=zeros(y,1);
for i=1:y
    for j=1:x
        if myI(i,j)==1
            my_y(i,1)=my_y(i,1)+1;
        end
    end
end
[~,max_y]=max(my_y);
y1=max_y;
%�Ҹ���Ȥ������
while my_y(max_y,1)>=5 && max_y>1
    max_y=max_y-1;
end
roi_top=max_y;
%�Ҹ���Ȥ��������
while my_y(y1,1)>=5 && max_y<y
    y1=y1+1;
end
roi_bottom=y1;
%Iy=I(roi_top:roi_bottom,:,:);
%imshow(Iy);
my_x=zeros(1,x);
for i=1:x
    for j=1:y
        if myI(j,i)==1
            my_x(1,i)=my_x(1,i)+1;
        end
    end
end
%��ȡ����Ȥ�����
roi_left=1;
while roi_left<x && my_x(1,roi_left)<3
    roi_left=roi_left+1;
end
%��ȡ����Ȥ���Ҳ�
roi_right=x;
while roi_right>roi_left && my_x(1,roi_right)<3
    roi_right=roi_right-1;
end
I_roi=I(roi_top:roi_bottom,roi_left:roi_right,:);%��ô��³���ͼ��
%imshow(I_roi);
%%
%��ֵ������ͼ��
gray=rgb2gray(I_roi);
th = imbinarize(gray);
[rows,cols]=size(th);
%%
%���ͻ�ʴ
se=eye(2);%��λ����
d=th;
[m,n]=size(d);%������Ϣ����
h=fspecial('average',3);
%����Ԥ������˲����ӣ�averageΪ��ֵ�˲���ģ��ߴ�Ϊ3*3
d=im2bw(round(filter2(h,d)));%ʹ��ָ�����˲���h��h����d����ֵ�˲�
if bwarea(d)/m/n>=0.365%�����ֵͼ���ж�������������������ı��Ƿ����0.365
    d=imerode(d,se);%�������0.365����и�ʴ
elseif bwarea(d)/m/n<=0.235%�����ֵͼ���ж�������������������ı�ֵ�Ƿ�С��0.235
    d=imdilate(d,se);%%���С����ʵ�����Ͳ���
end
th=d;
%%
%%ȥ����Χ�ĸ���
flag=0;
while flag==0
    %���
    i=1;
    while sum(th(:,i))==0 && i<cols-1
        i=i+1;
    end
    n_len=0;
    while sum(th(:,i))~=0 && i<cols-1
        n_len=n_len+1;
        i=i+1;
    end
    if n_len<cols/15
        left=i;
        th(:,1:left)=0;
    else
        left=1;
    end
    %�ұ�
    i=cols;
    while sum(th(:,i))==0 && i>1
        i=i-1;
    end
    n_len=0;
    while sum(th(:,i))~=0 && i>1
        n_len=n_len+1;
        i=i-1;
    end
    if n_len<cols/15
        right=i;
        th(:,right:cols)=0;
    else
        right=cols;
    end
    %�ϱ�
    i=1;
    while sum(th(i,:))==0 && i<rows-1
        i=i+1;
    end
    n_len=0;
    while sum(th(i,:))~=0 && i<rows-1
        i=i+1;
        n_len=n_len+1;
    end
    if n_len<rows/6
        top=i;
        th(1:top,:)=0;
    else
        top=1;
    end
    %�±�
    i=rows;
    while sum(th(i,:))==0 && i>1
        i=i-1;
    end
    n_len=0;
    while sum(th(i,:))~=0 && i>1
        i=i-1;
        n_len=n_len+1;
    end
    if n_len<rows/6
        bottom=i;
        th(bottom:rows,:)=0;
    else
        bottom=rows;
    end
    th=qiege(th);
    [rows,cols]=size(th);
    if left==1 && right==cols && top==1 && bottom==rows
        flag=1;
    end
end
%imshow(th);

[rows,cols]=size(th);

%%
%�ָ�ȡ��
k=1;
for col=1:cols
    count_col(col)=0;
    for row=1:rows
        if th(row,col)==1
            count_col(col)=count_col(col)+1;
        end
    end
end
for col=1:cols
    if col~=cols
         if (count_col(col)==0) && (count_col(col+1)~=0)
             x_lim(k)=col+1;
             k=k+1;
         end
         if (count_col(col)~=0) && (count_col(col+1)==0)
             x_lim(k)=col;
             k=k+1;
         end
    end
end

%�����ַ��ָ�浽plate_char��
[dim_x_lim,len]=size(x_lim);
plate_char{1}=th(:,1:x_lim(1));
plate_char{1}=imresize(plate_char{1},[40,20],'bicubic');
for i=1:(len-1)/2
    plate_char{i+1}=th(:,x_lim(2*i):x_lim(2*i+1));
    plate_char{i+1}=imresize(plate_char{i+1},[40,20],'bicubic');
end
plate_char{7}=th(:,x_lim(12):cols);
plate_char{7}=imresize(plate_char{7},[40,20],'bicubic');

temp={'��.jpg','��.jpg','��.jpg','��.jpg','ԥ.jpg','��.jpg','��.jpg','��.jpg','³.jpg'};
[nothing,max]=size(temp);
%��ʶ����
for i=1:max
    fn=temp{i};
    y=imread(fn);
    [~,~,dim]=size(y);
    if dim==3
        y=rgb2gray(y);
    end
    th = imbinarize(y);
    res{i}=plate_char{1}-th;
    res{i}=abs(res{i});
    value(i)=sum(sum(res{i},1),2);
end
hanzi=temp{find(value==min(value))}(1);
%ʶ���������ֺ���ĸ
for i=1:6
    my_char(i)=shibie(plate_char{i+1});
end
result=[hanzi,my_char(1),'��',my_char(2:6)];
mydialog(result);