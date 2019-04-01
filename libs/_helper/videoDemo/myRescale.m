function x = myRescale(x, a, b)
x = b + (b-a).*(x-max(max(x)))./(max(max(x))-min(min(x))) ;
