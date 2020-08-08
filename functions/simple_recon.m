function out = simple_recon(rf_data, db, siz)

x = rf_data / 62178.0;
x = abs(hilbert(x));
x = 20*log10(x);

x = imresize(x, siz);

x(x>0) = 0;

x(x>db) = db;

x = x / db;
x = x + 1;
x = x * 255.0;

out = imdiffusefilt(x/255.0, 'NumberOfIterations', 7);

