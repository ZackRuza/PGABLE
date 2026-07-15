function drawspline(n,cp,kv,cpf,varargin)
% drawbspline(cp,cpf)--draw a degree n bspline curve with control points cp
%  and knot vector kv.
%  If cpf is 1, then draw the control points/polygon
% Example: cp = [gapoint(0,0,0), gapoint(1,0,0),gapoint(1,2,0),gapoint(1,2,1)]; drawbspline(2,cp,[0 0 0 0.5 1 1 1], 1)
% The curve is sampled over [kv(n+1),kv(end-n)) (ie, open on right)

[row,col]=size(cp);
if ~exist('cpf','var')
  cpf=0;
end
if cpf
  for i=1:col
    cpx(i)=double(cp(i).noneuclidean*I3.*e1);
    cpy(i)=double(cp(i).noneuclidean*I3.*e2);
    cpz(i)=double(cp(i).noneuclidean*I3.*e3);
    draw(cp(i));
  end
  plot3(cpx,cpy,cpz,'k-','LineWidth',1.5,'MarkerSize',4);
end
hold on
S = 200;
for i=0:S-1
  t=i/S;
  t = (1-t)*kv(n+1)+t*kv(end-n);
  pt = bspline(n,cp,kv,t);
  ptE = pt.noneuclidean*I3;
  x(i+1)=double(ptE.*e1);
  y(i+1)=double(ptE.*e2);
  z(i+1)=double(ptE.*e3);
end
axis equal
smpls = [x;y;z]'/7*1.2 - [0.6 0.6 0]
size(smpls)
max(smpls)
plot3(x,y,z,varargin{:});
