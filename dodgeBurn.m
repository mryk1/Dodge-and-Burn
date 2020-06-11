
clc
close all
I = getpfmraw('AtriumNight.pfm'); %image 1
dandb(I, 'AtriumNight');
I = getpfmraw('rosette.pfm'); %image 2
dandb(I, 'rosette');
I = getpfmraw('doll_doll.pfm'); %image 3
dandb(I,'doll_doll');
I = getpfmraw('lips.pfm'); % image 4
dandb(I,'lips');
I = getpfmraw('church.pfm'); %image 5
dandb(I,'church');

function dandb( I , name)
image = I;
worldLum = 0.2125 * image(:,:,1) + 0.7154 * image(:,:,2) + 0.0721 * image(:,:,3);
m = size(worldLum,1);
n = size(worldLum,2);
vi = zeros( m, n, 8);
centSurrRatio = 1.6 ;
alpha = 1 / (2*sqrt(2)); % ~ 0.35
for scale = 1 : 9 
    s = centSurrRatio ^ (scale - 1);
    sigma = alpha * s;
    radius =  round( sigma ) ;
    filtSize = (2 * radius) + 1;
    R = fspecial('gaussian', [filtSize filtSize], sigma); %equation 5
    vi(:,:,scale) = conv2(worldLum, R, 'same'); % equation 6
end
a = 0.18; % key value
phi = 0.8 ; % sharpening param
v = zeros( m, n, 8);
k = ( 2 ^ phi)* a / (s ^ 2) ;
for i = 1 : 8
    v1 = vi(:,:,i);
    v2 = vi(:,:,i+1);
    v(:,:,i) = abs( v1 - v2) ./ ( k + v1 ); % equation 7
end

% equation 8
sz1 = size(v,1);
sz2 = size(v,2);
sz3 = size(v,3);
sm = zeros( sz1 , sz2 );
epss = 0.05 ;
for i = 1 : sz1
    for j = 1 : sz2
        for sc = 1 : sz3
            if v(i,j,sc) > epss
                if (sc == 1) 
                    sm(i,j) = 1;
                end
                if (sc > 1) 
                    sm(i,j) = sc - 1;
                end
                break;
            end
        end
    end
end

ind = find(sm == 0);
sm( ind ) = 8;
v1_fin = zeros(size(v,1), size(v,2));
% calculating final v1
for i = 1 : size(vi,1)
    for j = 1 : size(vi,2)
        v1_fin( i , j ) = vi( i , j , sm(i,j) );
    end
end

luminanceCompressed = worldLum ./ (1 + v1_fin); % equation 9
output = zeros(size(image));
saturation = 0.6;
for i = 1 : 3
    output(:,:,i) = ((image(:,:,i) ./ worldLum) .^ saturation) .* luminanceCompressed;
end
indices = find(output > 1);
output(indices) = 1;
figure; imshow(I); title('original image');
figure; imshow(output); title('dodge & burn image');
imwrite( output,[name, '_local_.bmp']);

end