classdef PGABLEDraw
    %PGABLEDRAW - A class with drawing routines used by PGABLE.
    %   The methods of this class is not recommended for beginners.
    %   If you wish to draw to a GAScene, it's best to call GAScene functions directly.

    methods (Access = public, Static)

        function h = arrow(p1, p2, varargin)
            %ARROW - Draws an arrow from one point to another.

            % Drawing an arrow from point p1 to point p2 in colour c
            arguments
                p1 PGA;
                p2 PGA;
            end
            arguments (Repeating)
                varargin
            end

            hold on

            p1x = p1.getx();
            p1y = p1.gety();
            p1z = p1.getz();

            p2x = p2.getx();
            p2y = p2.gety();
            p2z = p2.getz();
            
            p = (p2x - p1x)*e1(OGA) + (p2y - p1y)*e2(OGA) + (p2z - p1z)*e3(OGA);
            biv = e1(OGA)^p;
            if biv == 0
                dir1 = normalize(dual(e2(OGA)^p));
            else
                dir1 = normalize(dual(biv));
            end

            beta = 1/16;
            % Setting the size of dir1 to be proportional to p
            dir1 = beta*norm(p)*dir1;

            dir1x = dir1.getx();
            dir1y = dir1.gety();
            dir1z = dir1.getz();

            dir2 = normalize(dual(dir1^p));
            dir2 = beta*norm(p)*dir2;

            dir2x = dir2.getx();
            dir2y = dir2.gety();
            dir2z = dir2.getz();


            % DRAWING
            % First, plot line from point 1 to point 2
            h = PGABLEDraw.plotline({p1 p2}, varargin{:});

            % Then, for each angle, we want to rotate the point around dir1 and dir2
            phi = 0.75; % The base of the arrow head is 0.75 of the way
            abx = (1-phi) * p1x + phi * p2x;
            aby = (1-phi) * p1y + phi * p2y;
            abz = (1-phi) * p1z + phi * p2z;

            g = 8;
            theta = 2*pi/g;
            for i=1:g
                angle = theta*i;
                ht = plot3([p2x, abx + sin(angle)*dir1x + cos(angle)*dir2x], ...
                        [p2y, aby + sin(angle)*dir1y + cos(angle)*dir2y], ...
                        [p2z, abz + sin(angle)*dir1z + cos(angle)*dir2z], ...
                        varargin{:});
                h = [h ht];
            end

            for i=0:g
                angle1 = theta*i;
                angle2 = angle1+theta;
                ht = plot3([abx + sin(angle1)*dir1x + cos(angle1)*dir2x, abx + sin(angle2)*dir1x + cos(angle2)*dir2x], ...
                        [aby + sin(angle1)*dir1y + cos(angle1)*dir2y, aby + sin(angle2)*dir1y + cos(angle2)*dir2y], ...
                        [abz + sin(angle1)*dir1z + cos(angle1)*dir2z, abz + sin(angle2)*dir1z + cos(angle2)*dir2z], ...
                        varargin{:});
                h = [h ht];
            end
 
       end

        function polygon(Poly, BV, position, c)
            %POLYGON - Draws a polygon on a bivector with offset.
            % The polygon struct assumes the polygon is in the (x,y)-plane. 
            % Polygon is a struct containing the information of the polygon. It contains:
            %   - X, Y, Z vectors which are list of (x, y, z) coordinates for each point in the polygon
            %   - CX and CY, which is the (x, y) position of the center of the polygon

        
            translate = position/origin(PGA);

            rotate = e12(PGA) / BV;
            rotate = rotate/norm(rotate);
            rotate = PGA(sqrt(PGA(rotate)));
            
            for i=1:length(Poly.X)
                p = hodgedual(((Poly.X(i)-Poly.CX)*e1(PGA)*0.01 + (Poly.Y(i)-Poly.CY)*e2(PGA)*0.01) + e0(PGA));
                p = rotate * p * inverse(rotate);
                p = translate * p;
                
                pts{i} = p;
            end
            
            PGABLEDraw.patch(pts, c);
        end

        function handle = patch(pts, varargin)
            %PATCH - Draws a patch of a coloured polygon.

            arguments
                pts;
            end
            arguments (Repeating)
                varargin
            end

            for i = 1:length(pts)
                p = pts{i};
                % TODO: preallocate space of x, y, z for speed.
                x(i) = p.getx();
                y(i) = p.gety();
                z(i) = p.getz();
            end
            handle = patch('XData', x, 'YData', y, 'ZData', z, varargin{:});
        end

        function h = plotline(A, varargin)
            %PLOTLINE - Draws a line connecting the points of the first argument.

            arguments
                A;
            end
            arguments (Repeating)
                varargin
            end

            if length(A) == 0;
                h = [];
                return;
            end
            
            for i = 1:length(A)
                p = A{i};
                x(i) = p.getx();
                y(i) = p.gety();
                z(i) = p.getz();
            end

            h = plot3(x, y, z, varargin{:});

            % TODO: remove this commented out code
            % if isdashed
            %     if isthick
            %         h = plot3(x, y, z, '--', 'LineWidth', 1.5);
            %     else
            %         h = plot3(x, y, z, '--');
            %     end
            % else
            %     if isthick
            %         h = plot3(x, y, z, 'LineWidth', 1.5);
            %     else
            %         h = plot3(x, y, z);
            %     end
            % end
            % h.Color = c;
        end

	function h = wfsphere(center_point, radius, outn, varargin)
            %WFSPHERE - Draws a wire frame sphere

            arguments 
                center_point GA;
                radius double;
		outn double;
            end
            arguments (Repeating)
                varargin
            end

	    argsize = size(varargin, 2);
	    if argsize == 1
	       if isa(varargin{1}, "char")
	         varargin = ['Color', varargin];
	       end
	    end
	    updated_varargin = PGABLEDraw.defaultvarargin('Color', 'r', varargin{:});

            hold on
	    cx = center_point.getx();
	    cy = center_point.gety();
	    cz = center_point.getz();
	    [X,Y,Z]=sphere(6*3);
	    X = radius*X;
	    Y = radius*Y;
	    Z = radius*Z;
	    varargin{:}
	    h = plot3(X+cx,Y+cy,Z+cz,updated_varargin{:})';
	    for i=1:size(X,1)
	      for j=1:size(X,2)
	              x(j) = X(i,j);
		      y(j) = Y(i,j);
		      z(j) = Z(i,j);
	      end
	      %ht = plot3(x+cx,y+cy,z+cz,'r')';
	      ht = plot3(x+cx,y+cy,z+cz,updated_varargin{:})';
	      h = [h ht];
	     end
	     % Draw the hairs
	    [X,Y,Z]=sphere(6);
	    X = radius*X;
	    Y = radius*Y;
	    Z = radius*Z;
	     rs = 1;
	     if outn==1
	       d = 1.2;
	     else
	       d = 0.75;
             end
	     for i=1:size(X,1)
	         for j=mod(i,2)+1:2:size(X,2)
		   xh(1,j) = X(i,j);
		   xh(2,j) = d*X(i,j);
		   yh(1,j) = Y(i,j);
		   yh(2,j) = d*Y(i,j);
		   zh(1,j) = Z(i,j);
		   zh(2,j) = d*Z(i,j);
		  end
		  ht = plot3(xh+cx,yh+cy,zh+cz,'r','LineWidth',1.5)';
		  h = [h ht];
	     end
	end
	
        function h = octahedron(center_point, radius, varargin)
            %OCTAHEDRON - Draws an octahedron.

            arguments 
                center_point GA;
                radius double;
            end
            arguments (Repeating)
                varargin
            end

            hold on

	    if 0
            p_e1m = (gapoint(-radius, 0, 0, PGA)/origin(PGA))*center_point;
            p_e1p = (gapoint(radius, 0, 0, PGA)/origin(PGA))*center_point;
            p_e2m = (gapoint(0, -radius, 0, PGA)/origin(PGA))*center_point;
            p_e2p = (gapoint(0, radius, 0, PGA)/origin(PGA))*center_point;
            p_e3m = (gapoint(0, 0, -radius, PGA)/origin(PGA))*center_point;
            p_e3p = (gapoint(0, 0, radius, PGA)/origin(PGA))*center_point;
	    else
	    cx = center_point.getx();
	    cy = center_point.gety();
	    cz = center_point.getz();
            p_e1m = gapoint(cx-radius, cy, cz, PGA);
            p_e1p = gapoint(cx+radius, cy, cz, PGA);
            p_e2m = gapoint(cx, cy-radius, cz, PGA);
            p_e2p = gapoint(cx, cy+radius, cz, PGA);
            p_e3m = gapoint(cx, cy, cz-radius, PGA);
            p_e3p = gapoint(cx, cy, cz+radius, PGA);
	    end
            h = [PGABLEDraw.patch({p_e1m, p_e2m, p_e3m}, varargin{:}), ...
                 PGABLEDraw.patch({p_e1m, p_e2m, p_e3p}, varargin{:}), ...
                 PGABLEDraw.patch({p_e1m, p_e2p, p_e3m}, varargin{:}), ...
                 PGABLEDraw.patch({p_e1m, p_e2p, p_e3p}, varargin{:}), ...
                 PGABLEDraw.patch({p_e1p, p_e2m, p_e3m}, varargin{:}), ...
                 PGABLEDraw.patch({p_e1p, p_e2m, p_e3p}, varargin{:}), ...
                 PGABLEDraw.patch({p_e1p, p_e2p, p_e3m}, varargin{:}), ...
                 PGABLEDraw.patch({p_e1p, p_e2p, p_e3p}, varargin{:})];
        end

        function h = hairyline_by_coordinates(direction, center, varargin)
            arguments
                direction OGA;
                center OGA;
            end
            arguments (Repeating)
                varargin
            end

            hold on
            
            point_a = gapoint(center-direction, PGA);
            point_b = gapoint(center+direction, PGA);
            h = PGABLEDraw.plotline({
                point_a, point_b
            }, varargin{:});

            %%%%% DRAWING HAIRS %%%%% number of hairs
            num_hairs = 20;

            size = norm(direction);
            
            hair_mom = meet(dual(normalize(direction)), e1(OGA));
            if GAisa(hair_mom, 'scalar')
                hair_mom = meet(dual(normalize(direction)), e2(OGA));
                if GAisa(hair_mom, 'scalar')
                    hair_mom = meet(dual(normalize(direction)), e12(OGA));
                end
            end
            
            
            hair = size/num_hairs * normalize(hair_mom);
            
            rot = dual(normalize(direction));
            % Make the rotation 60 degrees rather than 90 degrees
            rot = 0.5 + 0.866*rot;

            for i = 1:num_hairs
                
                hair = rot*hair;
                hair = zeroepsilons(hair);

                d1 = center - direction + ((i*2)/num_hairs)*direction;
                d2 = center - direction + ((i*2-2)/num_hairs)*direction;

                h2 = PGABLEDraw.plotline({
                    gapoint(d1, PGA), gapoint(d2 + hair, PGA)
                }, varargin{:}); %TODO: for now just make it red

                h = [h h2];
            end


        end

        function h = hairylineC(line, center, varargin)
            arguments
                line PGA;
                center PGA;
            end
            arguments (Repeating)
                varargin
            end

            hold on

            llen = norm(line);
            line = line/llen;
            
            % These two things are equivalent
            dir = euclidean(line)/I3(PGA);
            % Calculating the moment
            p = pd(line*dir);
            mom = e1coeff(p)*e1(OGA) + e2coeff(p)*e2(OGA) + e3coeff(p)*e3(OGA);
            % Converting center to OGA
            % TODO: make a function for this
            center_OGA = center.getx()*e1(OGA) + center.gety()*e2(OGA) + center.getz()*e3(OGA);
            
            dir = OGAcast(dir);

            % Projected center
            new_center = mom + (inner(center_OGA - mom, dir)/inner(dir, dir))*dir;


            % Scale dir to be not normalized anymore
            dir = llen*dir;      

            h = PGABLEDraw.hairyline_by_coordinates(OGAcast(dir), OGAcast(new_center), varargin{:});
        end
        

        function h = hairyline(line, varargin)
            %HAIRYLINE - Draws a hairy line.

            hold on

            llen = norm(line);
            line = line/llen;
	        
            
            % These two things are equivalent
            dir = euclidean(line)/I3(PGA);
            %direction = [e1coeff(dir), e2coeff(dir), e3coeff(dir)]


            %TODO: determine why the line below isn't a valid way to extract the moment
            %moment = [e01coeff(line), e02coeff(line), e03coeff(line)]
            p = pd(line*dir);
            
            %moment = [e1coeff(p), e2coeff(p), e3coeff(p)]
             
            mom = e1coeff(p)*e1(OGA) + e2coeff(p)*e2(OGA) + e3coeff(p)*e3(OGA);
            

            % Scale dir to be not normalized anymore
            dir = llen*dir;

            h = PGABLEDraw.hairyline_by_coordinates(OGAcast(dir), OGAcast(mom), varargin{:});
        end

        function h = pointingplaneC(plane, center, varargin)
            %POINTINGPLANEC - Draws a plane with pointing arrows.

            % TODO: verify input is PGA vector
            arguments
                plane;
                center;
            end
            arguments (Repeating)
                varargin
            end

            hold on

            % TODO: Can currently only draw normalized planes. Perhaps should visualize non-unitness somehow.
            beta = sqrt(norm(plane));
            plane = normalize(plane);

            if euclidean(plane) == 0
                error("This is a plane at infinity. Cannot currently display this object.");
            end


            delta = -e0coeff(plane);
            support_vec = euclidean(plane);
            sv = OGAcast(support_vec);
            % pop = point on plane
            pop = sv*delta;
            
            biv = e1(OGA)^sv;
            if biv == 0
                dir1 = normalize(dual(e2(OGA)^sv));
            else
                dir1 = normalize(dual(biv));
            end

            dir2 = normalize(dual(dir1^sv));

            dir1 = beta*dir1;
            dir2 = beta*dir2;



            % Projecting the center onto the plane

            cx = center.getx();
            cy = center.gety();
            cz = center.getz();

            center_OGA = cx*e1(OGA) + cy*e2(OGA) + cz*e3(OGA);
            new_center = center_OGA - (inner(sv, center_OGA - pop)/inner(sv, sv))*sv;

            cx = new_center.getx();
            cy = new_center.gety();
            cz = new_center.getz();
            

            dir1x = dir1.getx();
            dir1y = dir1.gety();
            dir1z = dir1.getz();

            dir2x = dir2.getx();
            dir2y = dir2.gety();
            dir2z = dir2.getz();

            p1t = gapoint(cx + dir1x + dir2x, cy + dir1y + dir2y, cz + dir1z + dir2z, PGA);
            p2t = gapoint(cx - dir1x + dir2x, cy - dir1y + dir2y, cz - dir1z + dir2z, PGA);
            p3t = gapoint(cx - dir1x - dir2x, cy - dir1y - dir2y, cz - dir1z - dir2z, PGA);
            p4t = gapoint(cx + dir1x - dir2x, cy + dir1y - dir2y, cz + dir1z - dir2z, PGA);
            
            h = PGABLEDraw.patch({p1t, p2t, p3t, p4t}, varargin{:});

            
            

            % gs is the grid size. 1 -> one arrow on each corner
            %                      2 -> arrows in 3x3 grid
            %                      etc, etc. 
            gs = 2;

            k = 0.3; % length of arrows, as percentage of area of square
            nsv = beta*k*sv;

            l = 0.2;
            nad = l*k*dir2; % Note: dir2 is already scaled up by beta

            % Length of arrow head, as percentage of length of arrow staffs
            r = 0.2;

            for x = 0:gs
                for y  = 0:gs
                    xper = x/gs;
                    yper = y/gs;

                    % Arrow base
                    ab = (1-yper)*((1-xper)*p1t + xper*p2t) + yper*((1-xper)*p4t + xper*p3t);
                    % Arrow tip
                    at = gapoint(ab.getx() + nsv.getx(), ab.gety() + nsv.gety(), ab.getz() + nsv.getz(), PGA);
                    h = [h PGABLEDraw.plotline({ab, at}, 'Color', 'k')];
                    am = r*ab + (1-r)*at;
                    af1 = gapoint(am.getx() + nad.getx(), am.gety() + nad.gety(), am.getz() + nad.getz(), PGA);
                    af2 = gapoint(am.getx() - nad.getx(), am.gety() - nad.gety(), am.getz() - nad.getz(), PGA);
                    h = [h PGABLEDraw.plotline({af1, at, af2}, 'Color', 'k')];
                end
            end

        end

        function h = hairydisk(BV, offset, varargin)
            %HAIRYDISK - Draws a disk with hairs indicating spin.

            arguments
                BV PGA;
                offset PGA = origin(PGA);
            end
            arguments (Repeating)
                varargin
            end

            hold on

            % TODO: perhaps remove this error message
            if ~isgrade(BV, 2)
                error('Can only draw a disk for a bivector.');
            end

            total_transform = sqrt(e12(PGA)/BV);
            if GAisa(total_transform, 'scalar') && double(e12(PGA)/BV) < 0
                f = -1;
            else
                f = 1;
            end
            
            rad = sqrt(norm(BV))/pi;
            
            
            % Creating points in a circle
            t = (0:pi/12:2*pi);
            for i=1:length(t)
                pts{i} = gapoint(f*rad*sin(t(i)) + offset.getx(), ...
                                 rad*cos(t(i)) + offset.gety(), ...
                                 offset.getz(), ...
                                 PGA);
                pts{i} = inverse(total_transform) * pts{i} * total_transform;
            end
    
            h = PGABLEDraw.patch(pts, varargin{:});
            for i=2:4:length(t)-1
                 p{1} = pts{i};
                 p{2} = 2.5*(pts{i}-pts{i-1}) + pts{i-1};
                 h = [h PGABLEDraw.plotline({p{2},p{1}}, 'Color', 'k')];
            end
        end


        function h = hairyball(TV, offset, varargin)
            %HAIRYBALL - Draws a ball with hairs pointing inward or outward.

            hold on
            
            v = e123coeff(TV);
            r = (abs(v)*3/4/pi)^(1./3.);
        
            [X,Y,Z] = sphere(8);

            X = r*X;
            Y = r*Y;
            Z = r*Z;


            h = plot3(X + offset.getx(), Y + offset.gety(), Z + offset.getz(), varargin{:})';
            
            for i=1:size(X,1)
                for j=1:size(X,2)
                    x(j) = X(i,j);
                    y(j) = Y(i,j);
                    z(j) = Z(i,j);
                end
                h = [h plot3(x + offset.getx(), y + offset.gety(), z + offset.getz(), varargin{:})];
            end

            if v > 0
                d = 1.2;
            else
                d = .85;
            end

            for i=1:size(X,1)
                for j=mod(i,2)+1:2:size(X,2)
                    xh(1,j) = X(i,j);
                    xh(2,j) = d*X(i,j);
                    yh(1,j) = Y(i,j);
                    yh(2,j) = d*Y(i,j);
                    zh(1,j) = Z(i,j);
                    zh(2,j) = d*Z(i,j);
                end
                h = [h plot3(xh + offset.getx(), yh + offset.gety(), zh + offset.getz(), varargin{:})'];
            end
        end

        function h = drawstaronplane(vp, planearg, varargin)
            h = [];
            %planearg = 1 -> x axis
            %planearg = 2 -> y axis
            %planearg = 3 -> z axis

            ax = gca;

            xrange = ax.XLim;
            yrange = ax.YLim;
            zrange = ax.ZLim;

            xaverage = (xrange(1) + xrange(2))/2;
            yaverage = (yrange(1) + yrange(2))/2;
            zaverage = (zrange(1) + zrange(2))/2;
            center = gapoint(xaverage, yaverage, zaverage, PGA);
            
            % TODO: perhaps create plane and line creation functions
            plane = 0;
            switch planearg
                case 1
                    star_big_tip_trans = gapoint(0, 0.1, 0, PGA);
                    star_small_tip_trans = gapoint(0, 0.05, 0, PGA);
                    star_tip_rot_back = gapoint(0.1, 0, 0, PGA);

                    if vp.getx() > 0
                        plane = -xrange(2)*e0(PGA) + e1(PGA);
                    else
                        plane = -xrange(1)*e0(PGA) + e1(PGA);
                    end
                case 2
                    star_big_tip_trans = gapoint(0, 0, 0.1, PGA);
                    star_small_tip_trans = gapoint(0, 0, 0.05, PGA);
                    star_tip_rot_back = gapoint(0, 0.1, 0, PGA);
                    if vp.gety() > 0
                        plane = -yrange(2)*e0(PGA) + e2(PGA);
                    else
                        plane = -yrange(1)*e0(PGA) + e2(PGA);
                    end
                case 3
                    star_big_tip_trans = gapoint(0.1, 0, 0, PGA);
                    star_small_tip_trans = gapoint(0.05, 0, 0, PGA);
                    star_tip_rot_back = gapoint(0, 0, 0.1, PGA);
                    if vp.getz() > 0
                        plane = -zrange(2)*e0(PGA) + e3(PGA);
                    else
                        plane = -zrange(1)*e0(PGA) + e3(PGA);
                    end
            end

            line = join(vp, center);
            line = normalize(line);
            p = line^plane;
            
            if norm(p) ~= 0
                p = normalize(p);                
    
                rot_back = (star_tip_rot_back/origin(PGA))*p;
                l = join(rot_back, p);
                R = gexp((-2*pi/5)*normalize(l)/2);
                small_R = gexp((-1*pi/5)*normalize(l)/2);

                big_tip = (star_big_tip_trans/origin(PGA))*p;
                small_tip = small_R*(star_small_tip_trans/origin(PGA))*p*inverse(small_R);

                starpoints = versorbatchiterate(R, {big_tip, small_tip}, 4, true);

                starpoints = reshape(starpoints', [1, 10]);

                starpoints = arrayfun(@(p)PGABLEDraw.boundingboxclip(xrange, yrange, zrange, p), starpoints);
                h = [h PGABLEDraw.patch(starpoints, varargin{:})];
            end
        end


        %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%
        %         TODO Section         %
        %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%


        % TODO: Implement (convert p.m to appropriate values)
        % TODO: consider depricating(?)
        % function LineMesh(pts, c)
        %     if nargin == 1
        %         c = 'b';
        %     end
        %     M = size(pts, 1);
        %     N = size(pts, 2);
        %     for i=1:M
        %         for j=1:N
        %             p = pts{i,j};
        %             x(j) = p.m(2);
        %             y(j) = p.m(3);
        %             z(j) = p.m(4);
        %         end
        %         plot3(x,y,z,c);
        %     end
        %     for j=1:N
        %         for i=1:M
        %             p = pts{i,j};
        %             x(i) = p.m(2);
        %             y(i) = p.m(3);
        %             z(i) = p.m(4);
        %         end
        %         plot3(x,y,z,c);
        %     end
        % end

        %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%
        %        Generic Tooling       %
        %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%

        function R = boundingboxclip(xrange, yrange, zrange, p)
            %BOUNDINGBOXCLIP - Returns a point clipped in a bounding box.

            arguments
                xrange;
                yrange;
                zrange;
                p;
            end
            p = p{1};

            x = p.getx();
            y = p.gety();
            z = p.getz();
            R = {gapoint(clip(x, xrange(1), xrange(2)), clip(y, yrange(1), yrange(2)), clip(z, zrange(1), zrange(2)), PGA)};
        end

        function b = isinboundingbox(xrange, yrange, zrange, p)
            %ISINBOUNDINGBOX - Returns true if a point is in the bounding box.

            bx = xrange(1) <= p.getx() && p.getx() <= xrange(2);
            by = yrange(1) <= p.gety() && p.gety() <= yrange(2);
            bz = zrange(1) <= p.getz() && p.getz() <= zrange(2);

            b = bx && by && bz;
        end

        function v = defaultvarargin(key, val, varargin)
            for k = 1:length(varargin)
                arg = varargin{k};

                if isa(arg, "char") && strcmp(arg, key)
                    v = varargin;
                    return
                end
            end
            v = [varargin, {key}, {val}];
        end

        function c = extractcolor(varargin)
            for k = 1:length(varargin)
                arg = varargin{k};
                if strcmp(arg, 'Color')
                    c = varargin{k+1};
                    return
                end
            end
            % TODO: return error
        end

    end
end
