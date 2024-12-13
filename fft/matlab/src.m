clc;clear
N=256;
n=1:N;
 
f0=50;
 
f1=200;
 
fs=2e3;
 
y=sin(2*pi*f0.*n/fs)+2*sin(2*pi*f1.*n/fs);
 
figure;
 
plot(y);
 
Y=fft(y);
 
figure;
 
plot(abs(Y));
 
y1=y';
q=quantizer([17 8]);
y2=num2bin(q,y1);
fid1=fopen('src.txt','wt');
for i=1:N
    fwrite(fid1,y2(i,:));
    fprintf(fid1,'\n');
end
fclose(fid1);
Y = fft(y);
Y = abs(Y) / (N / 2); % 归一化
frequencies = (0:N-1) * fs / N; % 频率轴
plot(frequencies(1:N/2), Y(1:N/2)); % 只绘制正频部分
