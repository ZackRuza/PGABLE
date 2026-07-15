function k = bezierCurvature(cp,t)
%BEZIERCURVATURE--compute the signed curvature of a Bezier curve
[row,col]=size(cp);
sgn=1;
if t>0.5
  cp = flip(cp);
  t = 1-t;
  sgn=-1
end
for i=1:col-1
  for j=1:col-i
      cp(j)=(1-t)*cp(j) + t*cp(j+1);
  end
end
fd = hdual((col-1)*(cp(2)-cp(1)));
sd = hdual((col-1)*(col-2)*((cp(3)-cp(2))-(cp(2)-cp(1))));
if t>=0.5
  fd = -fd;
  sd = -sd;
end
if norm(fd)<1e-6
	k=inf;
else
	k = sgn*abs(double(GAZ(fd^sd*I3/norm(fd)^3).*e3));
	if double((fd^sd).*e12) > 0
		k = -1*k;
	end
end
