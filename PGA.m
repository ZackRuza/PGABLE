classdef PGA < GA
    %PGA - A child class of GA for elements of Projective/Plane-based Geometric Algebra.
    %   Elements
    %      Basic elements include 1, e0, e1, e2, e3, e01, e02, e03, e12, e31, e23, e021,
    %      e013, e032, e123, e0123.
    %      Additionally, we have e13 = -e31, e012 = -e021, e023 = -e032.
    %      We also have method for creating PGA points,gapoint(x, y, z), which creates a
    %      PGA point with coordinates (x, y, z). We also have origin() = gapoint(0, 0, 0).
    %
    %   Operations
    %      You can use these special characters for these basic operations:
    %         • +  for addition               also: plus(A, B)
    %         • -  for subtraction            also: minus(A, B)
    %         • *  for the geometric product  also: product(A, B)
    %         • /  for division               also: divide(A, B)
    %         • ^  for the outer product      also: outer(A, B)
    %         • .* for the inner product      also: inner(A, B)
    %         • == for equality               also: eq(A, B)
    %         • ~= for inequality             also: neq(A, B)
    %      Additonally, there are basic operations:
    %         • meet(A, B)                    compute the meet of two multivectors
    %         • join(A, B)                    compute the join of two multivectors
    %         • inverse(A)                    compute the inverse
    %           (Note: the inverse may not always exist in PGA)
    %         • gradeinvolution(A)            compute the grade involution
    %         • conjugate(A)                  compute the conjugate
    %         • reverse(A)                    compute the reverse
    %         • norm(A)                       compute the norm
    %         • vnorm(A)                      compute the vanishing norm
    %         • normalize(A)                  normalize the multivector
    %         • poincaredual(A)               compute the poincare dual
    %         • hodgedual(A)                  compute the hodge dual
    %         • inversehodgedual(A)           compute the inverse hodge dual
    %         • getx(A)                       get the x coordinate of a PGA point
    %         • gety(A)                       get the y coordinate of a PGA point
    %         • getz(A)                       get the z coordinate of a PGA point
    %         • zeroepsilons(A)               zero-out epsilons (small errors)
    %         • draw(A)                       draw the multivector
    %         (See also GAScene for more information on draw calls)
    %         • pclf                          clear all objects including vanishing objects
    %         • grade(A, g)                   select the grade-g component of a multivector
    %         • isgrade(A, g)                 determine if a multivector is of grade g
    %         • hsmap(A, g)                   negate the grade-g's components of a multivector
    %      There are functions for constructing some objects directly:
    %         •gapoint(x,y,z)                 construct a PGA point
    %         •galine(l,p)                    construct a line with direction
    %         •galine(l1,l2,l3, p1,p2,p3)     with direction l through point p
    %      There are also more advanced operations:
    %         • sqrt(A)                       compute the square root
    %         • glog(A)                       compute the geometric log
    %         • gexp(A)                       compute the geometric exponential
    %
    %   See also GA, OGA, GAScene.

    % PGABLE, Copyright (c) 2024, University of Waterloo
    % Copying, use and development for non-commercial purposes permitted.
    %          All rights for commercial use reserved; for more information
    %          contact Stephen Mann (smann@uwaterloo.ca)
    %
    %          This software is unsupported.
    
    properties (Access = private)
        % A 1x16 matrix of real numbers corresponding to the coefficients of entries 1, e0, e1, ..., e01, ..., e0123. 
        m
    end

    %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%
    %           Settings           %
    %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%

    methods (Static = true)

        function settings()
            %SETTINGS - Displays the current configuration settings for PGA in PGABLE.
            %   To retrieve a particular setting, run PGA.[setting].
            %   For example, to retrieve the value of increasing_order, run
            %   PGA.increasing_order.
            %   To change the value of a particular setting, run PGA.[setting]([value]).
            %   For example, to set the value of increasing_order to true, run
            %   PGA.increasing_order(true).
            %   For more information on a particular setting, run help PGA.[setting].
            %
            %   See also GA.settings.

            [S0, S1, S2, S3] = PGA.signature();

            disp("   ~~~~~~~~~~ PGA Settings ~~~~~~~~~~")
            disp("   signature:        e0*e0 = " + S0 + ", e1*e1 = " + S1 + ", e2*e2 = " + S2 + ", e3*e3 = " + S3)
            disp("   increasing_order: " + PGA.increasing_order())
            disp("   ~~~~~~~~~~ PGA Point Settings ~~~~~~~~~~")
            disp("   pointsize:        " + PGA.pointsize())
        end
        
        function [S0, S1, S2, S3] = signature(sign0, sign1, sign2, sign3)
            %SIGNATURE - Set/retrieve the current signature of the model.
            %   This setting is NOT recommended for beginners.
            %   If no arguments are provided, the signatures for e0, e1, e2, e3 are returned
            %   as a vector [S0, S1, S2, S3].
            %   If 4 arguments are provided, the inputs sign0, sign1, sign2, sign3 correspond
            %   to the signatures of e0, e1, e2, e3 respectively.

            persistent signature0;
            persistent signature1;
            persistent signature2;
            persistent signature3;

            if isempty(signature0)
                signature0 = 0;
                signature1 = 1;
                signature2 = 1;
                signature3 = 1;
            end

            if nargin == 4
               signature0 = sign0;
               signature1 = sign1;
               signature2 = sign2;
               signature3 = sign3;
            end

            S0 = signature0;
            S1 = signature1;
            S2 = signature2;
            S3 = signature3;
        end

        function val = pointsize(newval, surpress_output)
            %POINTSIZE - Set/retreive the POINTSIZE setting.
            %   The POINTSIZE setting is a double indicated the radius of the octahedron
            %   representing a point.
            %   If no argument is provided, POINTSIZE returns the current value of the
            %   POINTSIZE setting.
            
            arguments
                newval = [];
                surpress_output = false;
            end

            persistent currentval;
            
            if isempty(currentval)
                currentval = 0.1;
            end

            if isempty(newval)
                % User is trying to retrieve the current value
                val = currentval;
            else
                % User is trying to set the value
                if isnumeric(newval)
                    currentval = newval;
                    if ~surpress_output
                        disp("   pointsize set to " + currentval)
                    end
                else
                    error('pointsize must have a numeric value.')
                end
            end 
        end

        function val = increasing_order(newval, surpress_output)
            %INCREASING_ORDER - Set/retrieve the INCREASING_ORDER setting.
            %   The INCREASING setting is either true or false.
            %   When set to true, PGA elements are represented by the basis:
            %   1, e0, e1, e2, e3, e01, e02, e03, e12, e13, e23, e012, e013, e023, e123, e0123
            %   When set to false, PGA elements are represented by the basis:
            %   1, e0, e1, e2, e3, e01, e02, e03, e23, e31, e12, e032, e013, e021, e123, e0123
            %   If no argument is provided, INCREASING_ORDER returns the current value of the
            %   INCREASING_ORDER setting.

            arguments
                newval = [];
                surpress_output = false;
            end

            persistent currentval;
            
            % By default the increasing_order setting is set to false
            if isempty(currentval)
                currentval = false;
            end

            if isempty(newval)
                % User is trying to retrieve the current value
                val = currentval;
            else
                % User is trying to set the value
                if islogical(newval)
                    currentval = newval;
                    if ~surpress_output
                        disp("   increasing_order set to " + currentval)
                    end
                else
                    error('increasing_order must have value true or false.')
                end
            end
        end

        %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%
        %  Dynamic Drawing Functions   %
        %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%

        function h = drawvanishingpoint(vp, varargin)
            hold on


            vpx = vp.getx();
            vpy = vp.gety();
            vpz = vp.getz();
            
            ax = gca;

            xrange = ax.XLim;
            yrange = ax.YLim;
            zrange = ax.ZLim;

            xwidth = xrange(2) - xrange(1);
            ywidth = yrange(2) - yrange(1);
            zwidth = zrange(2) - zrange(1);

            propx = abs(vpx/xwidth);
            propy = abs(vpy/ywidth);
            propz = abs(vpz/zwidth);

            xaverage = (xrange(1) + xrange(2))/2;
            yaverage = (yrange(1) + yrange(2))/2;
            zaverage = (zrange(1) + zrange(2))/2;

            center = gapoint(xaverage, yaverage, zaverage, PGA);

            
            [~, argmax] = max([propx, propy, propz]);

            switch argmax
                case 1
                    if vp.getx() > 0
                        plane = -xrange(2)*e0(PGA) + e1(PGA);
                    else
                        plane = -xrange(1)*e0(PGA) + e1(PGA);
                    end
                case 2
                    if vp.gety() > 0
                        plane = -yrange(2)*e0(PGA) + e2(PGA);
                    else
                        plane = -yrange(1)*e0(PGA) + e2(PGA);
                    end
                case 3
                    if vp.getz() > 0
                        plane = -zrange(2)*e0(PGA) + e3(PGA);
                    else
                        plane = -zrange(1)*e0(PGA) + e3(PGA);
                    end
            end

            line = join(vp, center);
            line = normalize(line);
            p = line^plane;

            % Phi is percent away the arrows are from the edge of the bounding box
            phi = 0.3;
            aphi = 1 - phi;
            h = plot3([p.getx(), aphi*p.getx() + phi*xaverage], ...
                      [p.gety(), aphi*p.gety() + phi*yaverage], ...
                      [p.getz(), aphi*p.getz() + phi*zaverage], 'k');


            h = [h, PGABLEDraw.drawstaronplane(vp, 1, varargin{:})];
            h = [h, PGABLEDraw.drawstaronplane(vp, 2, varargin{:})];
            h = [h, PGABLEDraw.drawstaronplane(vp, 3, varargin{:})];
        end

        function h = drawvanishingline(vl, varargin)
            %DRAWVANISHINGLINE - Draws a single instance of a vanishing line.
            %   This function is NOT intended for a user to draw a vanishing line to the
            %   scene. To draw a vanishing line, run "draw(vanishing_line)".

            h = [];

            ax = gca;

            xrange = ax.XLim;
            yrange = ax.YLim;
            zrange = ax.ZLim;

            xaverage = (xrange(1) + xrange(2))/2;
            yaverage = (yrange(1) + yrange(2))/2;
            zaverage = (zrange(1) + zrange(2))/2;
            
            % TODO: move this somewhere else
            hold on
            
            % TODO: get x, y, z of line's normal.
            vlplane = normalize(hd(vl)/I3(PGA));

            n = normalize(hd(vl)/I3(PGA));
            
            p0 = xaverage*e1(PGA) + yaverage*e2(PGA) + zaverage*e3(PGA);

            vlplane = n - (n.*p0)*e0;
            


            % The 6 planes of the bounding box
            xp = -xrange(2)*e0(PGA) + e1(PGA);
            xn = -xrange(1)*e0(PGA) + e1(PGA);
            yp = -yrange(2)*e0(PGA) + e2(PGA);
            yn = -yrange(1)*e0(PGA) + e2(PGA);
            zp = -zrange(2)*e0(PGA) + e3(PGA);
            zn = -zrange(1)*e0(PGA) + e3(PGA);
            

            points = [];

            isin = @(p)PGABLEDraw.isinboundingbox(xrange, yrange, zrange, p);

            if isin(xp^yp^vlplane)
                % We are in the scenario where we know the line goes through:
                %   - The x planes and the y planes
                % However, it may still go through the z planes.
                % If it does, it must hit the following point:

                if isin(yp^zp^vlplane)
                    % Now we know we go through all six faces in this particular order.
                    points = {xp^yp^vlplane, yp^zp^vlplane, zp^xn^vlplane, xn^yn^vlplane, yn^zn^vlplane, zn^xp^vlplane, xp^yp^vlplane};
                elseif isin(yp^zn^vlplane)
                    points = {xp^yp^vlplane, yp^zn^vlplane, zn^xn^vlplane, xn^yn^vlplane, yn^zp^vlplane, zp^xp^vlplane, xp^yp^vlplane};
                else
                    % It doesn't go through all 6 faces. So we get this
                    points = {xp^yp^vlplane, yp^xn^vlplane, xn^yn^vlplane, yn^xp^vlplane, xp^yp^vlplane};
                end
            elseif isin(xp^zp^vlplane)
                if isin(xp^yn^vlplane)
                    points = {zp^xp^vlplane, xp^yn^vlplane, yn^zn^vlplane, zn^xn^vlplane, xn^yp^vlplane, yp^zp^vlplane, zp^xp^vlplane};
                else
                    points = {xp^zp^vlplane, zp^xn^vlplane, xn^zn^vlplane, zn^xp^vlplane, xp^zp^vlplane};
                end
            else
                if isin(xp^zn^vlplane)
                    points = {zn^xp^vlplane, xp^yn^vlplane, yn^zp^vlplane, zp^xn^vlplane, xn^yp^vlplane, yp^zn^vlplane, zn^xp^vlplane};
                else
                    points = {yp^zp^vlplane, zp^yn^vlplane, yn^zn^vlplane, zn^yp^vlplane, yp^zp^vlplane};
                end
            end

            points = arrayfun(@(p)PGABLEDraw.boundingboxclip(xrange, yrange, zrange, p), points);

            h = PGABLEDraw.plotline(points, varargin{:});

            
            for i=1:(length(points)-1)
                point_1 = points{i};
                point_2 = points{i+1};
                % TODO: This is very bad. Very bad. Getting imaginary parts. Draws the points correctly though.
                ap_move = gexp(glog(point_1/point_2)*0.5);
                ap = sqrt(ap_move)*point_2/sqrt(ap_move);
                % Now we want to draw the line from AP to AP moved in the direction where things will go
                % Then, we point with an arrow type thing.
                ap_short_move = gexp(glog(point_1/point_2)*0.45);
                ap_long_move = gexp(glog(point_1/point_2)*0.55);
                ap_short = sqrt(ap_short_move)*point_2/sqrt(ap_short_move);
                ap_long = sqrt(ap_long_move)*point_2/sqrt(ap_long_move);

                R = gexp(-0.05*vl/2);
                ap_tip = R*ap/R;

                arrow_points = {ap_short, ap_tip, ap_long};
                arrow_points = arrayfun(@(p)PGABLEDraw.boundingboxclip(xrange, yrange, zrange, p), arrow_points);
                
                c = PGABLEDraw.extractcolor(varargin{:});
                h = [h PGABLEDraw.patch(arrow_points, 'EdgeColor', c, 'FaceColor', c)];
            end
            
        end
    end

    %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%
    %      Protected methods       %
    %         (non-static)         %
    %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%
    
    methods (Access = protected)

        function [scalar_nz, vector_nz, bivector_nz, trivector_nz, fourvector_nz] = gradestatus_(A)
            nzm = A.m ~= 0;
            % The following variables hold true if there exists a non-zero entry
            % in that category
            scalar_nz = nzm(1) ~= 0;
            vector_nz = sum(nzm(2:5)) ~= 0;
            bivector_nz = sum(nzm(6:11)) ~= 0;
            trivector_nz = sum(nzm(12:15) ~= 0);
            fourvector_nz = nzm(16) ~= 0;
        end

        function b = GAisa_(A, t)
            [scalar_nz, vector_nz, bivector_nz, trivector_nz, fourvector_nz] = gradestatus_(A);

            if strcmp(t, 'double') || strcmp(t, 'scalar') 
                b = ~(             vector_nz || bivector_nz || trivector_nz || fourvector_nz);
            elseif strcmp(t,'vector') || strcmp(t,'plane')
                b = ~(scalar_nz ||              bivector_nz || trivector_nz || fourvector_nz);
            elseif strcmp(t,'bivector') || strcmp(t,'line')
                b = ~(scalar_nz || vector_nz ||                trivector_nz || fourvector_nz);
            elseif strcmp(t,'trivector') || strcmp(t,'point')
                b = ~(scalar_nz || vector_nz || bivector_nz ||                 fourvector_nz);
            elseif strcmp(t,'4vector') || strcmp(t,'fourvector') || strcmp(t,'quadvector') || strcmp(t,'pseudoscalar')
                b = ~(scalar_nz || vector_nz || bivector_nz || trivector_nz                 );
            elseif strcmp(t,'multivector')
                b = sum([scalar_nz vector_nz bivector_nz trivector_nz fourvector_nz]) > 1;
            else
                b = false;
            end 
        end

        function r = double_(A)
            if GAisa_(A, 'scalar')
                r = A.m(1);
            else
                error('Can only convert a scalar PGA object to a double. Object is %s.', char(A));
            end
        end

        % ***** Functions for adding and subtracting PGA objects *****

        function R = plus_(A, B)
            R = PGA(A.m + B.m);
        end

        function R = minus_(A, B)
            R = PGA(A.m - B.m);
        end

        function R = uminus_(A)
            R = PGA(-A.m);
        end


        % ***** Geometric Product Stuff *****

        function R = productleftexpand_(A)
            [scal, E0, E1, E2, E3, E01, E02, E03, E12, E13, E23, E012, E013, E023, E123, E0123] = decompose_(A);

            [S0, S1, S2, S3] = PGA.signature();
            S01 = S0*S1;
            S02 = S0*S2;
            S03 = S0*S3;
            S12 = S1*S2;
            S13 = S1*S3;
            S23 = S2*S3;
            S012 = S01*S2;
            S013 = S01*S3;
            S023 = S02*S3;
            S123 = S12*S3;
            S0123 = S012*S3; 

            R = [scal       S0*E0      S1*E1      S2*E2      S3*E3     -S01*E01   -S02*E02   -S03*E03   -S12*E12   -S13*E13   -S23*E23   -S012*E012 -S013*E013 -S023*E023 -S123*E123  S0123*E0123 ;
                 E0         scal       S1*E01     S2*E02     S3*E03    -S1*E1     -S2*E2     -S3*E3     -S12*E012  -S13*E013  -S23*E023  -S12*E12   -S13*E13   -S23*E23   -S123*E0123  S123*E123 ;
                 E1        -S0*E01     scal       S2*E12     S3*E13     S0*E0      S02*E012   S03*E013  -S2*E2     -S3*E3     -S23*E123   S02*E02    S03*E03    S023*E0123 -S23*E23   -S023*E023 ;
                 E2        -S0*E02    -S1*E12     scal       S3*E23    -S01*E012   S0*E0      S03*E023   S1*E1      S13*E123  -S3*E3     -S01*E01   -S013*E0123  S03*E03    S13*E13    S013*E013 ;
                 E3        -S0*E03    -S1*E13    -S2*E23     scal      -S01*E013  -S02*E023   S0*E0     -S12*E123   S1*E1      S2*E2      S012*E0123 -S01*E01   -S02*E02   -S12*E12   -S012*E012 ;
                 E01       -E1         E0         S2*E012    S3*E013    scal       S2*E12     S3*E13    -S2*E02    -S3*E03    -S23*E0123  S2*E2      S3*E3      S23*E123  -S23*E023  -S23*E23   ;
                 E02       -E2        -S1*E012    E0         S3*E023   -S1*E12     scal       S3*E23     S1*E01     S13*E0123 -S3*E03    -S1*E1     -S13*E123   S3*E3      S13*E013   S13*E13   ;
                 E03       -E3        -S1*E013   -S2*E023    E0        -S1*E13    -S2*E23     scal      -S12*E0123  S1*E01     S2*E02     S12*E123  -S1*E1     -S2*E2     -S12*E012  -S12*E12   ;
                 E12        S0*E012   -E2         E1         S3*E123    S0*E02    -S0*E01    -S03*E0123  scal       S3*E23    -S3*E13     S0*E0      S03*E023  -S03*E013   S3*E3     -S03*E03   ;
                 E13        S0*E013   -E3        -S2*E123    E1         S0*E03     S02*E0123 -S0*E01    -S2*E23     scal       S2*E12    -S02*E023   S0*E0      S02*E012  -S2*E2      S02*E02   ;
                 E23        S0*E023    S1*E123   -E3         E2        -S01*E0123  S0*E03    -S0*E02     S1*E13    -S1*E12     scal       S01*E013  -S01*E012   S0*E0      S1*E1     -S01*E01   ;
                 E012       E12       -E02        E01        S3*E0123   E2        -E1        -S3*E123    E0         S3*E023   -S3*E013    scal       S3*E23    -S3*E13     S3*E03    -S3*E3     ;
                 E013       E13       -E03       -S2*E0123   E01        E3         S2*E123   -E1        -S2*E023    E0         S2*E012   -S2*E23     scal       S2*E12    -S2*E02     S2*E2     ;
                 E023       E23        S1*E0123  -E03        E02       -S1*E123    E3        -E2         S1*E013   -S1*E012    E0         S1*E13    -S1*E12     scal       S1*E01    -S1*E1     ;
                 E123      -S0*E0123   E23       -E13        E12        S0*E023   -S0*E013    S0*E012    E3        -E2         E1        -S0*E03     S0*E02    -S0*E01     scal       S0*E0     ;
                 E0123     -E123       E023      -E013       E012       E23       -E13        E12        E03       -E02        E01       -E3         E2        -E1         E0         scal      ];
        
        end

        function R = product_(A, B)
            R = PGA(productleftexpand_(A)*B.m);
        end

        function [scal, E0, E1, E2, E3, E01, E02, E03, E12, E13, E23, E012, E013, E023, E123, E0123] = decompose_(A)
            scal = A.m(1);
            E0 = A.m(2);
            E1 = A.m(3);
            E2 = A.m(4);
            E3 = A.m(5);
            E01 = A.m(6);
            E02 = A.m(7);
            E03 = A.m(8);
            E12 = A.m(9);
            E13 = A.m(10);
            E23 = A.m(11);
            E012 = A.m(12);
            E013 = A.m(13);
            E023 = A.m(14);
            E123 = A.m(15);
            E0123 = A.m(16);
        end

        % ***** The Outer Product *****

        
        function rm = outerleftexpand_(A)

            % TODO: Verify this is correct. Perhaps depricate this function and place in outer_.
            [scal, E0, E1, E2, E3, E01, E02, E03, E12, E13, E23, E012, E013, E023, E123, E0123] = decompose_(A);

                rm = [scal       0       0       0       0       0       0       0      0      0      0        0      0      0      0      0;

                     E0        scal     0       0       0       0       0       0      0      0      0        0      0      0      0      0;
                     E1         0      scal     0       0       0       0       0      0      0      0        0      0      0      0      0;
                     E2         0       0      scal     0       0       0       0      0      0      0        0      0      0      0      0;
                     E3         0       0       0      scal     0       0       0      0      0      0        0      0      0      0      0;

                     E01       -E1      E0      0       0      scal     0       0      0      0      0        0      0      0      0      0;
                     E02       -E2      0       E0      0       0      scal     0      0      0      0        0      0      0      0      0;
                     E03       -E3      0       0       E0      0       0      scal    0      0      0        0      0      0      0      0;
                     E12        0      -E2      E1      0       0       0       0     scal    0      0        0      0      0      0      0;
                     E13        0      -E3      0       E1      0       0       0      0     scal    0        0      0      0      0      0;
                     E23        0       0      -E3      E2      0       0       0      0      0     scal      0      0      0      0      0;

                     E012      E12    -E02     E01      0       E2     -E1      0     E0      0      0       scal    0      0      0      0;
                     E013      E13    -E03      0      E01      E3      0      -E1     0      E0     0        0     scal    0      0      0;
                     E023      E23      0      -E03    E02      0       E3     -E2     0      0      E0       0      0     scal    0      0;
                     E123       0      E23     -E13    E12      0       0       0      E3    -E2     E1       0      0      0     scal    0;

                     E0123   -E123    E023    -E013    E012    E23    -E13     E12    E03   -E02    E01      -E3     E2    -E1     E0    scal];
        end

        function R = outer_(A, B)
                rm = outerleftexpand_(A);
                R = PGA(rm*B.m);
        end

        function R = divide_(A, B)
            R = A * inverse_(B);
        end

        function R = leftcontraction_(A, B)
            [S0, S1, S2, S3] = PGA.signature();
            S01 = S0*S1;
            S02 = S0*S2;
            S03 = S0*S3;
            S12 = S1*S2;
            S13 = S1*S3;
            S23 = S2*S3;
            S012 = S01*S2;
            S013 = S01*S3;
            S023 = S02*S3;
            S123 = S12*S3;
            S0123 = S012 * S3; 

            [scal, E0, E1, E2, E3, E01, E02, E03, E12, E13, E23, E012, E013, E023, E123, E0123] = decompose_(A);
            
            C0 = S0*E0;
            C1 = S1*E1;
            C2 = S2*E2;
            C3 = S3*E3;
            C01 = S01*E01;
            C02 = S02*E02;
            C03 = S03*E03;
            C12 = S12*E12;
            C13 = S13*E13;
            C23 = S23*E23;
            C012 = S012*E012;
            C013 = S013*E013;
            C023 = S023*E023;
            C123 = S123*E123;
            C0123 = S0123*E0123;

            M = [scal   C0    C1    C2    C3  -C01  -C02  -C03  -C12  -C13  -C23  -C012 -C013 -C023 -C123  C0123;

                  0    scal   0     0     0    -C1   -C2   -C3    0     0     0    C12   C13   C23    0    C123;
                  0     0    scal   0     0     C0    0     0    -C2   -C3    0    C02   C03    0   -C23  -C023;
                  0     0     0    scal   0     0     C0    0     C1    0    -C3  -C01    0    C03   C13   C013;
                  0     0     0     0    scal   0     0     C0    0     C1    C2    0   -C01  -C02  -C12  -C012;

                  0     0     0     0     0    scal   0     0     0     0     0     C2    C3    0     0    -C23;
                  0     0     0     0     0     0    scal   0     0     0     0    -C1    0     C3    0    -C13;
                  0     0     0     0     0     0     0    scal   0     0     0     0    -C1   -C2    0    -C12;
                  0     0     0     0     0     0     0     0    scal   0     0     C0    0     0     C3   -C03;
                  0     0     0     0     0     0     0     0     0    scal   0     0     C0    0    -C2    C02;
                  0     0     0     0     0     0     0     0     0     0    scal   0     0     C0    C1   -C01;

                  0     0     0     0     0     0     0     0     0     0     0    scal   0     0     0    -C3;
                  0     0     0     0     0     0     0     0     0     0     0     0    scal   0     0     C2;
                  0     0     0     0     0     0     0     0     0     0     0     0     0    scal   0    -C1;
                  0     0     0     0     0     0     0     0     0     0     0     0     0     0    scal   C0;

                  0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    scal];
            R = PGA(M*B.m);
        end

        function R = rightcontraction_(A, B)

            % TODO: implement right contraction.
            error('Right contraction is not currently implemented.')
        end

        function R = inner_(A, B)
            [S0, S1, S2, S3] = PGA.signature();
            S01 = S0*S1;
            S02 = S0*S2;
            S03 = S0*S3;
            S12 = S1*S2;
            S13 = S1*S3;
            S23 = S2*S3;
            S012 = S01*S2;
            S013 = S01*S3;
            S023 = S02*S3;
            S123 = S12*S3;
            S0123 = S012 * S3; 

            [scal, E0, E1, E2, E3, E01, E02, E03, E12, E13, E23, E012, E013, E023, E123, E0123] = decompose_(A);

            C0 = S0*E0;
            C1 = S1*E1;
            C2 = S2*E2;
            C3 = S3*E3;
            C01 = S01*E01;
            C02 = S02*E02;
            C03 = S03*E03;
            C12 = S12*E12;
            C13 = S13*E13;
            C23 = S23*E23;
            C012 = S012*E012;
            C013 = S013*E013;
            C023 = S023*E023;
            C123 = S123*E123;
            C0123 = S0123*E0123;

            M = [scal   C0    C1    C2    C3  -C01  -C02  -C03  -C12  -C13  -C23  -C012 -C013 -C023 -C123  C0123;

                E0    scal  E01   E02   E03   -C1   -C2   -C3  -E012  -E013 -E023  -E12  -E13  -E23  -E0123  C123;
                E1   -C01   scal  C12   C13    C0    0     0    -C2   -C3  -C123  C02   C03    0   -C23  -C023;
                E2   -C02  -C12   scal  C23    0     C0    0     C1   C123  -C3  -C01    0    C03   C13   C013
                E3   -C03  -C13  -C23   scal   0     0     C0  -C123   C1    C2    0   -C01  -C02  -C12  -C012;

                E01    0     0    E012  E013  scal   0     0     0     0  -E0123   C2    C3    0     0    -C23;
                E02    0   -E012   0    E023   0    scal   0     0    E0123  0    -C1    0     C3    0     C13;
                E03    0   -E013 -E023   0     0     0    scal -E0123  0     0     0    -C1   -C2    0    -C12;
                E12   C012   0     0    C123   0     0  -C0123  scal   0     0     C0    0     0     C3   -C03;
                E13   C013   0   -C123   0     0   C0123   0     0    scal   0     0     C0    0    -C2    C02;
                E23   C023  C123   0     0  -C0123   0     0     0     0    scal   0     0     C0    C1   -C01;

                E012   0     0     0   E0123   0     0     0     0     0     0    scal   0     0     0    -C3;
                E013   0     0  -E0123   0     0     0     0     0     0     0     0    scal   0     0     C2;
                E023   0   E0123   0     0     0     0     0     0     0     0     0     0    scal   0    -C1;
                E123 -C0123  0     0     0     0     0     0     0     0     0     0     0     0    scal   C0;

               E0123   0     0     0     0     0     0     0     0     0     0     0     0     0     0   scal];
               
            R = PGA(M*B.m);
        end

	% Temporary
        function R = cdot_(A, B)
		R = inner_(A,B)
	end

        function R = inverse_(A)
	if 0
            M = productleftexpand_(A);
            if rcond(M) <= eps
                error('Inverse of %s does not exist.', char(A))
            end

           R = PGA(M\PGA(1).m);
	else
	    % This version of the inverse is from a Hitzer-Sangwine paper,
	    % although see Dimiter Prodanov, Computation of Minimal 
	    % Polynomials and Multivector Inverses in Non-Degenerate Clifford 
	    % Algebras, Mathematics 2025, 13, 110, 
	    % https://doi.org/10.3390/math13071106
	    % for a bit more direct formula (22)
	    numer = conjugate(A)*hsmap(A*conjugate(A),[3,4]);
	    denom = (A*conjugate(A))*hsmap(A*conjugate(A),[3,4]);
	    % Shouldn't need to do the grade test, but just in case
            %if grade(zeroepsilons(denom))~=0 || norm(denom) <= eps
            if  norm(denom) <= eps
		    denom
                error('Inverse of %s does not exist.', char(A))
            end
	    R = numer*(1/denom.m(1));
	end
        end

        % ***** Norms *****

        function r = norm_(A)
            B = double_(grade_(A.product_(reverse_(A)), 0));
            if B > 0
                r = sqrt(B);
            else
                r = sqrt(-B);
            end
        end

        function r = vnorm_(A)
            r = norm_(hodgedual_(A));
        end

        function R = normalize_(A)
            if norm_(A) < GA.epsilon_tolerance()
                error("The norm of the element is 0. Cannot normalize.")
            end
            R = A / norm_(A);
        end

        % ***** Equality and Inequality *****

        function b = eq_(A, B)
            b = norm_(A - B) + vnorm_(A - B) < GA.epsilon_tolerance;
            % TODO: Double check that confirming the norm and vnorm are close to 0
            %       is actually sufficient for determining equality.
        end

        function b = eeq_(A, B)
            b = all(A.m == B.m);
        end

        function b = ne_(A, B)
            b = ~eq_(A, B);
        end
        
        % ***** Dual and Reverse*****

        function R = dual_(A)
            error('Dual cannot be performed on PGA elements.');
        end

        function R = inversedual_(A)
            error('Inverse dual cannot be performed on PGA elements.');
        end

        function R = hodgedual_(A)
            [scal, E0, E1, E2, E3, E01, E02, E03, E12, E13, E23, E012, E013, E023, E123, E0123] = decompose_(A);

            R = PGA(  E0123, ...
                      [ -E123; E023; -E013; E012], ...
                      [ E23; -E13; E12; E03; -E02; E01], ...
                      [ -E3; E2; -E1; E0], ...
                      scal);
        end

        function R = inversehodgedual_(A)
            R = hodgedual_(gradeinvolution_(A));
        end

        function R = jmap_(A)
            [scal, E0, E1, E2, E3, E01, E02, E03, E12, E13, E23, E012, E013, E023, E123, E0123] = decompose_(A);

            R = PGA(  E0123, ...
                      [ E123; -E023; E013; -E012], ...
                      [ E23; -E13; E12; E03; -E02; E01], ...
                      [ -E3; E2; -E1; E0], ...
                      scal);
        end

        function R = reverse_(A)
            R = PGA(  A.m(1), ...
                      [A.m(2); A.m(3); A.m(4); A.m(5)], ...
                    - [A.m(6); A.m(7); A.m(8); A.m(9); A.m(10); A.m(11)], ...
                    - [A.m(12); A.m(13); A.m(14); A.m(15)], ...
                      A.m(16));
        end

        function R = zeroepsilons_(A)
            R = A;
            for i=1:16
                if abs(R.m(i)) < GA.epsilon_tolerance
                    R.m(i) = 0;
                end
            end
        end

        function R = join_(A, B)
            R = inversehodgedual_((hodgedual_(A).outer_(hodgedual_(B))));
        end

        function R = meet_(A, B)
            R = A.outer_(B);
        end

        function R = conjugate_(A)
            R = PGA(   A.m(1), ... 
                    - [A.m(2); A.m(3); A.m(4); A.m(5)], ...
                    - [A.m(6); A.m(7); A.m(8); A.m(9); A.m(10); A.m(11)], ...
                      [A.m(12); A.m(13); A.m(14); A.m(15)], ...
                       A.m(16));
        end

        function R = gradeinvolution_(A)
            R = PGA(   A.m(1), ... 
                    - [A.m(2); A.m(3); A.m(4); A.m(5)], ...
                      [A.m(6); A.m(7); A.m(8); A.m(9); A.m(10); A.m(11)], ...
                    - [A.m(12); A.m(13); A.m(14); A.m(15)], ...
                       A.m(16));
        end

        function [scalar_nz, vector_nz, bivector_nz, trivector_nz, fourvector_nz] = grade_status_(A)
            scalar_nz = (A.m(1) ~= 0);
            vector_nz = (A.m(2) ~= 0 || A.m(3) ~= 0 || A.m(4) ~= 0 || A.m(5) ~= 0);
            bivector_nz = (A.m(6) ~= 0 || A.m(7) ~= 0 || A.m(8) ~= 0 || A.m(9) ~= 0 || A.m(10) ~= 0 || A.m(11) ~= 0);
            trivector_nz = (A.m(12) ~= 0 || A.m(13) ~= 0 || A.m(14) ~= 0 || A.m(15) ~= 0);
            fourvector_nz = (A.m(16) ~= 0);
        end

        function R = grade_(A, n)
            if nargin == 1 || n == -1
                [scalar_nz, vector_nz, bivector_nz, trivector_nz, fourvector_nz] = grade_status_(A);
                if sum([scalar_nz vector_nz bivector_nz trivector_nz fourvector_nz]) ~= 1
                    R = -1;
                else
                    R = 1*vector_nz + 2*bivector_nz + 3*trivector_nz + 4*fourvector_nz; 
                end
            else
                if n == 0
                    R = PGA(A.m(1));
                elseif n == 1
                    R = PGA(0, [A.m(2); A.m(3); A.m(4); A.m(5)], 0, 0, 0);
                elseif n == 2
                    R = PGA(0, 0, [A.m(6); A.m(7); A.m(8); A.m(9); A.m(10); A.m(11)], 0, 0);
                elseif n == 3
                    R = PGA(0, 0, 0, [A.m(12); A.m(13); A.m(14); A.m(15)], 0);
                elseif n == 4
                    R = PGA(0, 0, 0, 0, A.m(16));
                else
                    R = PGA(0);
                end
            end
        end

	function R = hsmap_(A, n)
            R=A;
            if sum(n == 0)>0
                R.m(1) = -A.m(1);
            end
            if sum(n == 1)>0
                R.m(2) = -A.m(2);
                R.m(3) = -A.m(3);
                R.m(4) = -A.m(4);
                R.m(5) = -A.m(5);
            end
            if sum(n == 2)>0
                R.m(6) = -A.m(6);
                R.m(7) = -A.m(7);
                R.m(8) = -A.m(8);
                R.m(9) = -A.m(9);
                R.m(10) = -A.m(10);
                R.m(11) = -A.m(11);
            end
            if sum(n == 3)>0
                R.m(12) = -A.m(12);
                R.m(13) = -A.m(13);
                R.m(14) = -A.m(14);
                R.m(15) = -A.m(15);
            end
            if sum(n == 4)>0
                R.m(16) = -A.m(16);
            end
        end


        function b = isgrade_(A, g)
            if g == 0
                b = GAisa_(A, "scalar");
            elseif g == 1
                b = GAisa_(A, "vector");
            elseif g == 2
                b = GAisa_(A, "bivector");
            elseif g == 3
                b = GAisa_(A, "trivector");
            elseif g == 4
                b = GAisa_(A, "fourvector");
            elseif g==-1
                b = GAisa_(A, "multivector");
            else
                error('isgrade: invalid grade.');
            end
        end
            
        % TODO: Needs to be upgraded to PGA
        % TODO: make private and wrap for public
        % function r = blade(A)
        %     % blade(A) : return a blade made from the largest portion of a multivector.
        %     A = PGA(A);

        %     s(1) = abs(A.m(1));
        %     s(2) = sqrt(sum(abs(A.m(2:4))));
        %     s(3) = sqrt(sum(abs(A.m(5:7))));
        %     s(4) = abs(A.m(8));
        %     if s(1)>s(2) && s(1)>s(3) && s(1)>s(4)
        %       r = PGA.returnGA_(A.m(1));
        %     elseif s(2)>s(3) && s(2)>s(4)
        %       r = PGA.returnGA_([0; A.m(2); A.m(3); A.m(4); 0; 0; 0; 0]);
        %     elseif s(3)>s(4)
        %       r = PGA.returnGA_([0; 0; 0; 0; A.m(5); A.m(6); A.m(7); 0]);
        %     else
        %       r = PGA.returnGA_([0; 0; 0; 0; 0; 0; 0; A.m(8)]);
        %     end
        % end

        function R = gexp_(A)
            rm = productleftexpand_(A);
            E = expm(rm);
            R = PGA(E(1:16,1));
        end

        function R = glog_(A)
            rm = productleftexpand_(A);
            L = logm(rm);
            R = PGA(L(1:16, 1));
        end

        function R = sqrt_(A)
            rm = productleftexpand_(A);
            S = sqrtm(rm);
            R = PGA(S(1:16, 1));

            % TODO: This is an implementation of equation (90) in PGA4CS.
            %       However, it doesn't resolve the issue with sqrt(PGA(-1)) since we get
            %       0 in the denominator.
            %denom = double_(2*(1 + grade_(A, 0)));
            %R = ((1+A)/sqrt(denom))*(1 - grade_(A, 4)/denom);
        end

        % TODO: Decide behaviour for non-points for get functions.

        function r = getx_(A)
            %GETX_ - A private function for computing the x coordinate of a PGA element.
            %   Returns the x coordinate of a point. Non-points return an error.

            r = -A.m(14)/A.m(15);
            % 14 is the position of e023
            % 15 is the position of e123
        end
        
        function r = gety_(A)
            %GETY_ - A private function for computing the y coordinate of a PGA element.
            %   Returns the y coordinate of a point. Non-points return an error.

            r = A.m(13)/A.m(15);
            % 13 is the position of e013
            % 15 is the position of e123
        end
        
        function r = getz_(A)
            %GETZ_ - A private function for computing the z coordinate of a PGA element.
            %   Returns the z coordinate of a point. Non-points return an error.

            r = -A.m(12)/A.m(15);
            % 12 is the position of e012
            % 15 is the position of e123
        end
  
        function s = char_(p)
            if ~any(p.m(:))
                s = '0';
                return;
            end

            pl = '';
            s = '';
            
            if p.m(1) ~= 0
                s = [s pl num2str(p.m(1))];
                pl = ' + ';
            end

            [s, pl] = GA.charifyval_(p.m(2), 'e0', s, pl);
            [s, pl] = GA.charifyval_(p.m(3), 'e1', s, pl);
            [s, pl] = GA.charifyval_(p.m(4), 'e2', s, pl);
            [s, pl] = GA.charifyval_(p.m(5), 'e3', s, pl);

            if GA.compact_notation()
                [s, pl] = GA.charifyval_(p.m(6), 'e01', s, pl);
                [s, pl] = GA.charifyval_(p.m(7), 'e02', s, pl);
                [s, pl] = GA.charifyval_(p.m(8), 'e03', s, pl);

                if ~PGA.increasing_order()
                    [s, pl] = GA.charifyval_(p.m(11), 'e23', s, pl);
                    [s, pl] = GA.charifyval_(-p.m(10), 'e31', s, pl);
                    [s, pl] = GA.charifyval_(p.m(9), 'e12', s, pl);

                    [s, pl] = GA.charifyval_(-p.m(14), 'e032', s, pl);
                    [s, pl] = GA.charifyval_(p.m(13), 'e013', s, pl);
                    [s, pl] = GA.charifyval_(-p.m(12), 'e021', s, pl);
                    [s, pl] = GA.charifyval_(p.m(15), 'e123', s, pl);
                else 
                    [s, pl] = GA.charifyval_(p.m(9), 'e12', s, pl);
                    [s, pl] = GA.charifyval_(p.m(10), 'e13', s, pl);
                    [s, pl] = GA.charifyval_(p.m(11), 'e23', s, pl);

                    [s, pl] = GA.charifyval_(p.m(12), 'e012', s, pl);
                    [s, pl] = GA.charifyval_(p.m(13), 'e013', s, pl);
                    [s, pl] = GA.charifyval_(p.m(14), 'e023', s, pl);
                    [s, pl] = GA.charifyval_(p.m(15), 'e123', s, pl);
                end

                if GA.compact_pseudoscalar()
                    [s, pl] = GA.charifyval_(p.m(16), 'I4', s, pl);
                else
                    [s, pl] = GA.charifyval_(p.m(16), 'e0123', s, pl);
                end
            else
                [s, pl] = GA.charifyval_(p.m(6), 'e0^e1', s, pl);
                [s, pl] = GA.charifyval_(p.m(7), 'e0^e2', s, pl);
                [s, pl] = GA.charifyval_(p.m(8), 'e0^e3', s, pl);

                if ~PGA.increasing_order()
                    [s, pl] = GA.charifyval_(p.m(11), 'e2^e3', s, pl);
                    [s, pl] = GA.charifyval_(-p.m(10), 'e3^e1', s, pl);
                    [s, pl] = GA.charifyval_(p.m(9), 'e1^e2', s, pl);

                    [s, pl] = GA.charifyval_(-p.m(14), 'e0^e3^e2', s, pl);
                    [s, pl] = GA.charifyval_(p.m(13), 'e0^e1^e3', s, pl);
                    [s, pl] = GA.charifyval_(-p.m(12), 'e0^e2^e1', s, pl);
                    [s, pl] = GA.charifyval_(p.m(15), 'e1^e2^e3', s, pl);
                else
                    [s, pl] = GA.charifyval_(p.m(9), 'e1^e2', s, pl);
                    [s, pl] = GA.charifyval_(p.m(10), 'e1^e3', s, pl);
                    [s, pl] = GA.charifyval_(p.m(11), 'e2^e3', s, pl);

                    [s, pl] = GA.charifyval_(p.m(12), 'e0^e1^e2', s, pl);
                    [s, pl] = GA.charifyval_(p.m(13), 'e0^e1^e3', s, pl);
                    [s, pl] = GA.charifyval_(p.m(14), 'e0^e2^e3', s, pl);
                    [s, pl] = GA.charifyval_(p.m(15), 'e1^e2^e3', s, pl);
                end

                if GA.compact_pseudoscalar()
                    [s, pl] = GA.charifyval_(p.m(16), 'I4', s, pl);
                else
                    [s, pl] = GA.charifyval_(p.m(16), 'e0^e1^e2^e3', s, pl);
                end
            end
            
            if strcmp(pl, ' ')
                s = '     0';
            end
        end
    end

    % ******************** Public Static Methods ********************
    methods (Access = public, Static)
        function e = elements()
            if PGA.increasing_order()
                e = [PGA(1), e0(PGA), e1(PGA), e2(PGA), e3(PGA), e01(PGA), e02(PGA), e03(PGA),...
                     e12(PGA), e13(PGA), e23(PGA), e012(PGA), e013(PGA), e023(PGA), e123(PGA), e0123(PGA)];
            else 
                e = [PGA(1), e0(PGA), e1(PGA), e2(PGA), e3(PGA), e01(PGA), e02(PGA), e03(PGA),...
                     e23(PGA), e31(PGA), e12(PGA), e032(PGA), e013(PGA), e021(PGA), e123(PGA), e0123(PGA)];
            end
        end

        function s = modelname()
            s = "PGA";
        end

        function R = cast(A)
            if isa(A, 'PGA')
                R = A;
            elseif isa(A, 'double')
                if GA.autoscalar
                    R = PGA(A);
                else 
                    error('Implicit conversion between a double and PGA is disabled. Run "help GA.autoscalar" for more information.')
                end
            else
                error(['Cannot implictly convert from ' class(A) ' to PGA'])
            end
        end

        function r = getzero()
            r = PGA(0);
        end
    end


    % ******************** Public Methods ********************

    methods (Access = public)
        function obj = PGA(m0, m1, m2, m3, m4)
            %PGA - The constructor for PGA elements.
            %   If no arugment is provided, the 0 element in PGA is returned.
            %   If 1 arugment is provided and it is a PGA element, the element itself will
            %   be returned. If the argument is a double, a PGA element of that scalar will
            %   be returned.
            %   If 5 arguments are provided, it is assumed they have the following format:
            %   The first argument is a double for the scalar portion of the multivector
            %   The second argument is [c0, c1, c2, c3], where ci is a double corresponding
            %   to the coefficient for ei.
            %   The third argument is [c01, c02, c03, c12, c13, c23], where cij is a double
            %   corresponding to the coefficient for eij.
            %   The fourth argument is [c012, c013, c023, c123], where cijk is a double
            %   corresponding to the coefficient for eijk.
            %   The fifth argument is a double corresponding to the coefficient for e0123.
            %   For any of the arguments, one can optionally simply put 0 to have zero
            %   for all the corresponding coefficients. 
            %
            %   It is not generally recommended to construct PGA elements this way.
            %   Instead, consider writing equations of the form
            %                              e1 + e2^e3
            %   while in the PGA model (see help GA.settings and help GA.model)
            %   or while not in the PGA model as
            %                              e1(PGA) + e2(PGA)^e3(PGA)
        
            if nargin == 0
                obj = PGA(0);
            elseif nargin == 5
                if m1 == 0
                    m1 = zeros(4, 1);
                end
                if m2 == 0
                    m2 = zeros(6, 1);
                end
                if m3 == 0
                    m3 = zeros(4, 1);
                end
                obj.m = [m0; 
                         m1(1); m1(2); m1(3); m1(4); 
                         m2(1); m2(2); m2(3); m2(4); m2(5); m2(6); 
                         m3(1); m3(2); m3(3); m3(4);
                         m4];
            elseif nargin == 1
                if isa(m0, 'PGA')
                    obj = m0;
                elseif isa(m0, 'double')
                    if size(m0, 1) == 1 & size(m0, 2) == 1
                        % User has provided a scalar
                        obj.m = [m0; 
                                    0; 0; 0; 0; 
                                    0; 0; 0; 0; 0; 0; 
                                    0; 0; 0; 0;
                                    0];
                    elseif size(m0, 1) == 1 & size(m0, 2) == 16
                        % User has provided a column vector
                        obj.m = m0';
                    elseif size(m0, 1) == 16 & size(m0, 2) == 1
                        % User has prodived a row vector
                        obj.m = m0;
                    else
                        error('Bad PGA argument: Unexpected array size.\nExpected size is either 1x1, 16x1 or 1x16.\nCurrent size is: %dx%d', size(m0, 1), size(m0, 2))
                    end
                else
                    error('Bad PGA argument: Invalid input type. Class is currently: %s.', class(m0))
                end
            else 
                error('Bad PGA argument: Invalid number of arguments.')
            end
        end

        function rm = matrix(A)
            rm = A.m;
        end

        function b = GAisa(A, t)
            %GAISA - Determines in a multivector and a string representing a type of multivector
            %   and returns true if the multivector is of that type.
            %   In PGA, valid types are:
            %   scalar, vector, plane, bivector, line, trivector, point, quadvector,
            %   pseudoscalar, multivector

            arguments
                A PGA;
                t (1, 1) string;
            end
            
            b = GAisa_(A, t);
        end

        function R = PGAcast(A)
            R = A;
        end

        function R = OGAcast(A)
            [scal, E0, E1, E2, E3, E01, E02, E03, E12, E13, E23, E012, E013, E023, E123, E0123] = decompose_(A);
            R = OGA(scal, [E1, E2, E3], [E12, E13, E23], E123);
        end

        function drawTP(A, center, c)
            arguments
                A PGA;
		center PGA;
                c = [];
            end
            if GAisa(A, 'plane')
                if isempty(c)
                    % TODO: make default colour of plane changable.
                    c = 'g';
                end

		dist = double(outer(A,center).noneuclidean.*I3);
		% Check if center on plane A; if not, then project onto A
		if abs(dist) > eps
		   nrm = norm(A.euclidean)
		   t = A.euclidean*dist/(nrm*nrm);
		   trans = 1-e0*(t)/2;
		   transi = 1+e0*(t)/2;
		   center = trans*center*transi;
		end
            h = PGABLEDraw.pointingplaneC(A, center, c);
            GAScene.addstillitem(GASceneStillItem(A, h));
        else
            error('Error is not a point, line, or plane. PGA cannot draw it.');
        end
	end

        function draw(A, varargin)
            arguments
                A PGA;
            end
            arguments (Repeating)
                varargin
            end
            GAScene.usefigure();

            

            A = zeroepsilons_(A);
            
            if GAisa(A, 'point')


                % Custom input handling
                argsize = size(varargin, 2);
                if argsize == 1
                    if isa(varargin{1}, "char")
                        varargin = ['FaceColor', varargin];
                    end
                end

                updated_varargin = PGABLEDraw.defaultvarargin('FaceColor', 'y', varargin{:});
                if euclidean(A) == 0
                    % TODO perhaps make drawing as part of the constructor of the dynamic item
                    h = PGA.drawvanishingpoint(A, updated_varargin{:});
                    GAScene.adddynamicitem(GASceneDynamicItem(A, h, @()PGA.drawvanishingpoint(A, updated_varargin{:})));
                else
                    h = PGABLEDraw.octahedron(A, PGA.pointsize(), updated_varargin{:});
                    GAScene.addstillitem(GASceneStillItem(A, h));
                end
                
            elseif GAisa(A, 'line')

                offset = [];
                % Custom input handling
                argsize = size(varargin, 2);
                if argsize == 1
                    if isa(varargin{1}, "char")
                        varargin = ['Color', varargin];
                    elseif isa(varargin{1}, "GA")
                        offset = varargin{1};
                        varargin = {};
                    end
                elseif argsize == 2
                    if isa(varargin{1}, "GA") && isa(varargin{2}, "char")
                        offset = varargin{1};
                        varargin{1} = 'Color';
                    elseif isa(varargin{1}, "char") && isa(varargin{2}, "GA")
                        error("Arguments are in an incorrect order. It should be draw(ELEMENT, OFFSET, COLOR).")
                    end
                end


                updated_varargin = PGABLEDraw.defaultvarargin('Color', 'b', varargin{:});
                updated_varargin = PGABLEDraw.defaultvarargin('LineWidth', 1.5, updated_varargin{:});
                if euclidean(A) == 0
                    if ~isempty(offset)
                        error("Cannot offset lines at infinity. Do not provide an offset argument.")
                    end
                    % TODO perhaps make drawing as part of the constructor of the dynamic item
                    %TODO: make dashedness work
                    updated_varargin = [{'--'}, updated_varargin];
                    h = PGA.drawvanishingline(A, updated_varargin{:});
                    GAScene.adddynamicitem(GASceneDynamicItem(A, h, @()PGA.drawvanishingline(A, updated_varargin{:})));
                else
                    if isempty(offset)
                        h = PGABLEDraw.hairyline(A, updated_varargin{:});
                    else 
                        h = PGABLEDraw.hairylineC(A, offset, updated_varargin{:});
                    end
                    
                    GAScene.addstillitem(GASceneStillItem(A, h));
                end

            elseif GAisa(A, 'plane')

                % Calculating center
                plane = normalize(A);
                if euclidean(plane) == 0
                    error("This is a plane at infinity. Cannot currently display this object.");
                end
                delta = -e0coeff(plane);
                support_vec = euclidean(plane); 
                center = ihd(delta*support_vec + e0(PGA));

                % Setting the default offset to be the desired center
                offset = center;

                % Custom input handling
                argsize = size(varargin, 2);
                if argsize == 1
                    if isa(varargin{1}, "char")
                        varargin = ['FaceColor', varargin];
                    elseif isa(varargin{1}, "GA")
                        offset = varargin{1};
                        varargin = {};
                    end
                elseif argsize == 2
                    if isa(varargin{1}, "GA") && isa(varargin{2}, "char")
                        offset = varargin{1};
                        varargin{1} = 'FaceColor';
                    elseif isa(varargin{1}, "char") && isa(varargin{2}, "GA")
                        error("Arguments are in an incorrect order. It should be draw(ELEMENT, OFFSET, COLOR).")
                    end
                end


                updated_varargin = PGABLEDraw.defaultvarargin('FaceColor', 'g', varargin{:});
                updated_varargin = PGABLEDraw.defaultvarargin('FaceAlpha', 0.5, updated_varargin{:});
                h = PGABLEDraw.pointingplaneC(A, offset, updated_varargin{:});
                GAScene.addstillitem(GASceneStillItem(A, h));
            else
                error('Error is not a point, line, or plane. PGA cannot draw it.');
            end
        end

	function R = lcomp(A)
	%LCOMP-the left complement of Lengyel
	  R = hodgedual_(A);
	end

	function R = rcomp(A)
	%RCOMP-the right complement of Lengyel
	  R = inversehodgedual_(A);
	end

        function R = euclidean(A)
            %EUCLIDEAN - Returns the euclidean portion of the multivector.

            [scal, E0, E1, E2, E3, E01, E02, E03, E12, E13, E23, E012, E013, E023, E123, E0123] = decompose_(A);
            R = PGA(scal, [0, E1, E2, E3], [0, 0, 0, E12, E13, E23], [0, 0, 0, E123], 0);
        end

        function R = noneuclidean(A)
            %NONEUCLIDEAN - Returns the non-euclidean portion of the multivector.

            [scal, E0, E1, E2, E3, E01, E02, E03, E12, E13, E23, E012, E013, E023, E123, E0123] = decompose_(A);
            R = PGA(E0, [0, E01, E02, E03], [0, 0, 0, E012, E013, E023], [0, 0, 0, E0123], 0);
        end

        function r = e0coeff(A)
            %E0COEFF - Returns the coefficient of e0.

            M = matrix(A);
            r = M(2);
        end

        function r = e1coeff(A)
            %E1COEFF - Returns the coefficient of e1.

            M = matrix(A);
            r = M(3);
        end

        function r = e2coeff(A)
            %E2COEFF - Returns the coefficient of e2.

            M = matrix(A);
            r = M(4);
        end

        function r = e3coeff(A)
            %E3COEFF - Returns the coefficient of e3.

            M = matrix(A);
            r = M(5);
        end

        function r = e01coeff(A)
            %E01COEFF - Returns the coefficient of e01.

            M = matrix(A);
            r = M(6);
        end

        function r = e02coeff(A)
            %E02COEFF - Returns the coefficient of e02.

            M = matrix(A);
            r = M(7);
        end

        function r = e03coeff(A)
            %E03COEFF - Returns the coefficient of e03.

            M = matrix(A);
            r = M(8);
        end

        function r = e12coeff(A)
            %E12COEFF - Returns the coefficient of e12.

            M = matrix(A);
            r = M(9);
        end

        function r = e13coeff(A)
            %E13COEFF - Returns the coefficient of e13.

            M = matrix(A);
            r = M(10);
        end

        function r = e23coeff(A)
            %E23COEFF - Returns the coefficient of e23.

            M = matrix(A);
            r = M(11);
        end

        function r = e012coeff(A)
            %E012COEFF - Returns the coefficient of e012.

            M = matrix(A);
            r = M(12);
        end

        function r = e013coeff(A)
            %E013COEFF - Returns the coefficient of e013.

            M = matrix(A);
            r = M(13);
        end

        function r = e023coeff(A)
            %E023COEFF - Returns the coefficient of e023.

            M = matrix(A);
            r = M(14);
        end

        function r = e123coeff(A)
            %E123COEFF - Returns the coefficient of e123.

            M = matrix(A);
            r = M(15);
        end

        function r = e0123coeff(A)
            %E0123COEFF - Returns the coefficient of e0123.

            M = matrix(A);
            r = M(16);
        end
    end
end
