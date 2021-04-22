function features = morph_features(roi)

rp = regionprops(roi, 'Area', 'Centroid', 'ConvexArea', 'ConvexHull', 'MajorAxisLength', 'MinorAxisLength', 'Perimeter');
[~, idx]=sort([rp.Area], 'descend' ); % extract the largest region
rp = rp(idx);
rp = rp(1); 

nrv = (rp.ConvexArea - rp.Area) / rp.Perimeter; % NORMALIZED RESIDUAL VALUE
rs = rp.Area / rp.ConvexArea; % AREA RATIO
convexity = rp.Area / rp.ConvexArea; % CONVEXITY

% % % % % % % %

bound = bwboundaries(roi);

s = []; 

for i=1:length(bound)
    
    temp = bound{i};
    s(i) = size(temp, 1); 

end

[~, n] = max(s); 

z = bound{n}(:, 1);
y = bound{n}(:, 2);

dwr = (max(z) - min(z)) / (max(y) - min(y)); % DWR
circularity = pi*4*rp.Area / (rp.Perimeter^2); % CIRCULARITY
roundness = 4*rp.Area / (pi*rp.MajorAxisLength^2); % ROUNDNESS

% % % % % % % %

elli = fit_ellipse(z, y);
perim_elli = pi * (1.5 * (elli.a + elli.b) - sqrt(elli.a*elli.b) ); 

t = bwmorph(roi, 'skel', Inf);
elli_skel = sum(t(roi==1)) / perim_elli; % ELLIPTIC NORMALIZED SKELETON

long_short = elli.b/elli.a; % LONG SHORT RATIO

elli_circumference = rp.Perimeter / perim_elli; % ELLIPTIC CIRCUMFERENCE

% % % % % % % %

if elli.phi<=pi/2 % ORIENTATION -->
    orient = elli.phi;
end

if (elli.phi>pi/2)&&(elli.phi<=pi)
    orient = pi - elli.phi;
end

if (elli.phi>pi)&&(elli.phi<=1.5*pi)
    orient = elli.phi - pi;
end

if (elli.phi>1.5*pi)
    orient = 2*pi - elli.phi;
end

% % % % % % % %	
	
cent = rp.Centroid;

z = z - cent(1);
y = y - cent(2);

nrl = sqrt(z.^2 + y.^2);
nrl = nrl / max(nrl);

n = length(nrl);

nrl_mean = mean(nrl); % MEAN NRL
nrl_std = std(nrl); % STD NRL

nrl_ra = sum(nrl(nrl>nrl_mean)-nrl_mean) / (nrl_mean*n); % NRL AREA RATIO
nrl_rough = mean(diff(nrl)); % NRL CONTOUR ROUGHNESS

area = sum(roi(:)==1);

features = [area, nrv, rs, convexity, dwr, circularity, roundness, elli_skel, long_short, elli_circumference, orient, nrl_mean, nrl_std, nrl_ra, nrl_rough]; 
