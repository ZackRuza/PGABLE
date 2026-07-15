function PGADrawPolygon(PA,varargin)
[r,col] = size(PA);
for i=1:col
	pt = PA(i);
  cpx(i)=double(pt.getx());
  cpy(i)=double(pt.gety());
  cpz(i)=double(pt.getz());
end
patch(cpx,cpy,cpz,varargin{:})
