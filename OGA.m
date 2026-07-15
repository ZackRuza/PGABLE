classdef OGA < GA
    %OGA - A child class of GA for elements of Ordinary Geometric Algebra.
    %   Elements
    %      Basic elements include e1, e2, e3, e12, e31, e23, e123.
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
    %         • lcont(A, B)                   to compute the left contraction of two multivectors
    %         • rcont(A, B)                   to compute the right contraction of two multivectors
    %         • meet(A, B)                    to compute the meet of two multivectors
    %         • join(A, B)                    to compute the join of two multivectors
    %         • dual(A)                       to compute the dual
    %         • inverse(A)                    to compute the inverse
    %         • gradeinvolution(A)            to compute the grade involution
    %         • conjugate(A)                  to compute the conjugate
    %         • reverse(A)                    to compute the reverse
    %         • norm(A)                       to compute the norm
    %         • normalize(A)                  to normalize the multivector
    %         • getx(A)                       to get the x coordinate of an OGA point
    %         • gety(A)                       to get the y coordinate of an OGA point
    %         • getz(A)                       to get the z coordinate of an OGA point
    %         • zeroepsilons(A)               to zero-out epsilons (small errors)
    %         • draw(A, varargin)             to draw the multivector
    %         (See also GAScene for more information on draw calls)
    %         • grade(A, g)                   to select the grade-g component of a multivector
    %         • isgrade(A, g)                 to determine if a multivector is of grade g
    %         • hsmap(A, g)                   negate the grade-g's components of a multivector
    %      There are also more advanced operations:
    %         • sqrt(A)                       to compute the square root
    %         • glog(A)                       to compute the geometric log
    %         • gexp(A)                       to compute the geometric exponential
    %
    %   See also GA, OGA, GAScene.

    % PGABLE, Copyright (c) 2024, University of Waterloo
    % Copying, use and development for non-commercial purposes permitted.
    %          All rights for commercial use reserved; for more information
    %          contact Stephen Mann (smann@uwaterloo.ca)
    %
    %          This software is unsupported.
    
    properties (Access = private)
        % A 1x8 matrix of real numbers corresponding to the coefficients of entries 1, e1, e2, e3, e12, e13, e23, e123. 
        m
    end

    %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%
    %           Settings           %
    %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%

    methods (Static = true)
        function settings()
            %SETTINGS - Displays the current configuration settings for OGA in PGABLE.
            %   To retrieve a particular settings, run OGA.[setting].
            %   For example, to retrieve the value of increasing_order, run
            %   OGA.increasing_order.
            %   To change the value of a particular setting, run OGA.[setting]([value]).
            %   For example, to set the value of increasing_order to true, run
            %   OGA.increasing_order(true).
            %   For more information on a particular setting, run help OGA.[setting].
            %
            %   See also GA.settings.

            [S1, S2, S3] = OGA.signature();

            disp("   ~~~~~~~~~~ PGA Settings ~~~~~~~~~~")
            disp("   signature:        e1*e1 = " + S1 + ", e2*e2 = " + S2 + ", e3*e3 = " + S3)
            disp("   increasing_order: " + OGA.increasing_order())
        end

        function [S1, S2, S3] = signature(sign1, sign2, sign3)
            %SIGNATURE - Set/retrieve the current signature of the model.
            %   This setting is NOT recommended for beginners.
            %   If no arguments are provided, the signatures for e1, e2, e3 are returned
            %   as a vector [S1, S2, S3].
            %   If 3 arguments are provided, the inputs sign1, sign2, sign3 correspond to the
            %   signatures of e1, e2, e3 respectively.

            persistent signature1;
            persistent signature2;
            persistent signature3;

            if isempty(signature1)
                signature1 = 1;
                signature2 = 1;
                signature3 = 1;
            end

            if nargin == 3
               signature1 = sign1;
               signature2 = sign2;
               signature3 = sign3;
            end

            S1 = signature1;
            S2 = signature2;
            S3 = signature3;
        end

        function val = increasing_order(newval, surpress_output)
            %INCREASING_ORDER - Set/retrieve the INCREASING_ORDER setting.
            %   The INCREASING setting is either true or false.
            %   When set to true, OGA elements are represented by the basis:
            %   1, e1, e2, e3, e12, e13, e23, e123
            %   When set to false, PGA elements are represented by the basis:
            %   1, e1, e2, e3, e23, e31, e12, e123
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
    end

    %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%
    %      Protected methods       %
    %         (non-static)         %
    %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%

    methods (Access = protected)
        function b = GAisa_(A, t)
            nzm = A.m ~= 0;
            if strcmp(t, 'double') || strcmp(t, 'scalar') 
                b = sum(nzm(2:8)) == 0;
            elseif strcmp(t,'vector') 
                b = sum(nzm(5:8)) == 0 & nzm(1) == 0;
            elseif strcmp(t,'bivector') 
                b = sum(nzm(1:4)) == 0 & nzm(8) == 0;
            elseif strcmp(t,'trivector') || strcmp(t, 'pseudoscalar') 
                b = sum(nzm(1:7)) == 0;
            elseif strcmp(t,'multivector')
                b = sum( [sum(nzm(1)) sum(nzm(2:4)) sum(nzm(5:7)) nzm(8)] ~= 0) > 1;
            else
                b = false;
            end 
        end

        function r = double_(A)
            if GAisa_(A, 'scalar')
                r = A.m(1);
            else
                error('Can only convert a scalar OGA object to a double.');
            end
        end

        function R = plus_(A, B)
            R = OGA(A.m + B.m);
        end

        function R = minus_(A, B)
            R = OGA(A.m - B.m);
        end

        function R = uminus_(A)
            R = OGA(-A.m);
        end

        function mr = productleftexpand_(A)
            [S1, S2, S3] = OGA.signature();
            S12 = S1*S2;
            S13 = S1*S3;
            S23 = S2*S3;
            S123 = S12*S3;

            scal = A.m(1);
            E1 = A.m(2);
            E2 = A.m(3);
            E3 = A.m(4);
            E12 = A.m(5);
            E13 = A.m(6);
            E23 = A.m(7);
            E123 = A.m(8);

            mr = [scal     S1*E1      S2*E2      S3*E3     -S12*E12   -S13*E13   -S23*E23  -S123*E123 ;
                 E1       scal       S2*E12     S3*E13    -S2*E2     -S3*E3     -S23*E123  -S23*E23  ;
                 E2      -S1*E12     scal       S3*E23     S1*E1      S13*E123  -S3*E3      S13*E13  ;
                 E3      -S1*E13    -S2*E23     scal      -S12*E123   S1*E1      S2*E2     -S12*E12  ;
                 E12     -E2         E1         S3*E123    scal       S3*E23    -S3*E13    S3*E3     ;
                 E13     -E3        -S2*E123    E1        -S2*E23     scal       S2*E12   -S2*E2     ;
                 E23      S1*E123   -E3         E2         S1*E13    -S1*E12     scal      S1*E1     ;
                 E123     E23       -E13        E12        E3        -E2         E1        scal      ];
        end

        function R = product_(A, B)
            R = OGA(productleftexpand_(A)*B.m);
        end 

        function mr = outerleftexpand_(A)
            scal = A.m(1);
            E1 = A.m(2);
            E2 = A.m(3);
            E3 = A.m(4);
            E12 = A.m(5);
            E13 = A.m(6);
            E23 = A.m(7);
            E123 = A.m(8);

            mr = [scal     0       0       0       0      0       0       0   ;
                 E1      scal     0       0       0      0       0       0   ;
                 E2       0      scal     0       0      0       0       0   ;
                 E3       0       0      scal     0      0       0       0   ;
                 E12     -E2      E1      0      scal    0       0       0   ;
                 E13     -E3      0       E1      0     scal     0       0   ;
                 E23      0      -E3      E2      0      0      scal     0   ;
                 E123    E23     -E13    E12      E3    -E2      E1     scal];
        end

        function R = outer_(A, B)
            R = OGA(outerleftexpand_(A)*B.m);
        end

	% For now...
        function R = cdot_(A, B)
		R = inner_(A, B);
	end

        function R = inner_(A, B)
            [S1, S2, S3] = OGA.signature();
            S12 = S1*S2;
            S13 = S1*S3;
            S23 = S2*S3;
            S123 = S12*S3;

            [scal, E1, E2, E3, E12, E13, E23, E123] = decompose_(A);

            C1 = S1*E1;
            C2 = S2*E2;
            C3 = S3*E3;
            C12 = S12*E12;
            C13 = S13*E13;
            C23 = S23*E23;
            C123 = S123*E123;

            % TODO: write code to generate this matrix.
            M = [scal   C1    C2    C3  -C12  -C13  -C23  -C123 ;

                 C1    scal  C12   C13   -C2   -C3   -C123 -C23  ;
                 C2   -C12   scal  C23    C1  C123   -C3   C13  ;
                 C3   -C13  -C23   scal -C123  C1    C2  -C12  ;

                 C12    0     0    C123  scal   0     0     C3  ;
                 C13    0   -C123   0     0    scal   0    -C2  ;
                 C23   C123   0     0     0     0    scal   C1  ;

                 C123   0     0     0     0     0     0    scal ];

            R = OGA(M*B.m);
        end

        function [scal, E1, E2, E3, E12, E13, E23, E123] = decompose_(A)
            scal = A.m(1);
            E1 = A.m(2);
            E2 = A.m(3);
            E3 = A.m(4);
            E12 = A.m(5);
            E13 = A.m(6);
            E23 = A.m(7);
            E123 = A.m(8);
        end

        function R = leftcontraction_(A, B)
            [S1, S2, S3] = OGA.signature();
            S12 = S1*S2;
            S13 = S1*S3;
            S23 = S2*S3;
            S123 = S12*S3;

            [scal, E1, E2, E3, E12, E13, E23, E123] = decompose_(A);

            C1 = S1*E1;
            C2 = S2*E2;
            C3 = S3*E3;
            C12 = S12*E12;
            C13 = S13*E13;
            C23 = S23*E23;
            C123 = S123*E123;

            M = [scal   C1    C2    C3  -C12  -C13  -C23  -C123 ;

                  0    scal   0     0    -C2   -C3    0   -C23  ;
                  0     0   scal    0     C1    0    -C3   C13  ;
                  0     0     0    scal   0     C1    C2  -C12  ;

                  0     0     0     0    scal   0     0     C3  ;
                  0     0     0     0     0    scal   0    -C2  ;
                  0     0     0     0     0     0    scal   C1  ;

                  0     0     0     0     0     0     0    scal ];

            R = OGA(M*B.m);
        end

        function R = rightcontraction_(A, B)
           [S1, S2, S3] = OGA.signature();
            S12 = S1*S2;
            S13 = S1*S3;
            S23 = S2*S3;
            S123 = S12*S3;

            [scal, E1, E2, E3, E12, E13, E23, E123] = decompose_(A);

            C1 = S1*E1;
            C2 = S2*E2;
            C3 = S3*E3;
            C12 = S12*E12;
            C13 = S13*E13;
            C23 = S23*E23;
            C123 = S123*E123;

            % TODO: write code to generate this matrix.
            M = [scal   0     0     0     0     0     0     0 ;

                 C1    scal   0     0     0     0     0     0  ;
                 C2   -C12   scal   0     0     0     0     0  ;
                 C3   -C13  -C23   scal   0     0     0     0  ;

                 C12    0     0    C123  scal   0     0     0  ;
                 C13    0   -C123   0     0    scal   0     0  ;
                 C23   C123   0     0     0     0    scal   0  ;

                 C123   0     0     0     0     0     0    scal ];

            R = OGA(M*B.m);
        end

        function R = inverse_(A)
	  if 0
            rm = productleftexpand_(A);
            if rcond(rm) <= eps
                error('Inverse of %s does not exist.', char(A))
            end

            R = OGA(rm\OGA(1).m);
	  else
            % This version of the inverse is from a Hitzer-Sangwine paper,
            % although see Dimiter Prodanov, Computation of Minimal
            % Polynomials and Multivector Inverses in Non-Degenerate Clifford
            % Algebras, Mathematics 2025, 13, 110,
            % https://doi.org/10.3390/math13071106
            % for a bit more direct formula (21)
            numer = conjugate(A)*gradeinvolution(A)*reverse(A);
            denom = A*conjugate(A)*gradeinvolution(A)*reverse(A);
            % Shouldn't need to do the grade test, but just in case
            if grade(zeroepsilons(denom))~=0 || norm(denom) <= eps
                error('Inverse of %s does not exist.', char(A))
            end
            R = numer*(1/denom.m(1));
          end
        end

        function R = divide_(A, B)
            R = A * inverse_(B);
        end

        function r = norm_(A)
            B = double_(grade_(A.product_(reverse_(A)), 0));
            if B > 0
                r = sqrt(B);
            else
                r = sqrt(-B);
            end
        end

        function r = vnorm_(A)
            error('vnorm does not exist in OGA. Try norm.')
        end

        function R = normalize_(A)
            R = A / norm_(A);
        end

        function b = eq_(A, B)
            b = norm_(A - B) < GA.epsilon_tolerance;
        end

        function b = eeq_(A, B)
            b = all(A.m == B.m);
        end

        function b = ne_(A, B)
            b = ~eq_(A, B);
        end

        function R = dual_(A)
            R = A/I3(OGA);
        end

        function R = inversedual_(A)
            R = A*I3(OGA);
        end

        function R = hodgedual_(A)
            error('Hodge dual cannot be performed on OGA elements.');
        end

        function R = inversehodgedual_(A)
            error('Inverse Hodge dual cannot be performed on OGA elements.');
        end

        function R = jmap_(A)
            error('Poincare dual cannot be performed on OGA elements.');
        end

        function R = reverse_(A)
            R = OGA([A.m(1);A.m(2);A.m(3);A.m(4);-A.m(5);-A.m(6);-A.m(7);-A.m(8)]);
        end

        function R = zeroepsilons_(A)
            R = A;
            for i = 1:8
                if abs(R.m(i)) < GA.epsilon_tolerance
                    R.m(i) = 0;
                end
            end
        end

        function R = join_(A, B)
            a = zeroepsilons(A);
            b = zeroepsilons(B);
            
            if GAisa(a,'multivector') || GAisa(b,'multivector')
                error('The arguments of join must both be blades.');
            end

            p = zeroepsilons(a^b);
            
            if p ~= 0
                R = p;
            else
                m = zeroepsilons(leftcontraction(dual(b), a));
            
            
                if m ~= 0
                    R = norm(m)*(a/m)^b;
                else
                    if GAisa(a, 'bivector')
                        R = norm(b)*a;	
                    else
                        R = norm(a)*b;	
                    end
                end
            end
        end

        function R = meet_(A, B)
            a = zeroepsilons(A);
            b = zeroepsilons(B);
            
            if GAisa(a,'multivector') || GAisa(b,'multivector')
                error('The arguments of meet must both be blades.');
            end
            R = leftcontraction(b/join(a, b), a);
        end

        function R = conjugate_(A)
            R = OGA([A.m(1); -A.m(2); -A.m(3); -A.m(4); -A.m(5); -A.m(6);  -A.m(7);  A.m(8)]);
        end

        function R = gradeinvolution_(A)
            R = OGA([A.m(1); -A.m(2); -A.m(3); -A.m(4); A.m(5); A.m(6); A.m(7); -A.m(8)]);
        end

        function R = grade_(A, n)
            if nargin == 1 || n==-1
                if A.m(1) ~= 0
                    if sum(abs(A.m(2:8))) == 0
                        R = 0;
                    else
                        R = -1;
                    end
                elseif sum(abs(A.m(2:4))) ~= 0
                    if sum(abs(A.m(5:8))) == 0
                        R = 1;
                    else
                        R = -1;
                    end
                elseif sum(abs(A.m(5:7))) ~= 0
                   if A.m(8) == 0
                        R = 2;
                    else
                        R = -1;
                    end
                elseif A.m(8) ~= 0
                    R = 3;
                else
                    R = -1;
                end
            else
                if n == 0
                    R = OGA([A.m(1);0;0;0;0;0;0;0]);
                elseif n == 1
                    R = OGA([0;A.m(2);A.m(3);A.m(4);0;0;0;0]);
                elseif n == 2
                    R = OGA([0;0;0;0;A.m(5);A.m(6);A.m(7);0]);
                elseif n == 3
                    R = OGA([0;0;0;0;0;0;0;A.m(8)]);
                else
                    R = OGA(0);
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
	    end
	    if sum(n == 2)>0
		R.m(5) = -A.m(5);
		R.m(6) = -A.m(6);
		R.m(7) = -A.m(7);
	    end
	    if sum(n == 3)>0
		R.m(8) = -A.m(8); 
	    end
        end

        function b = isgrade_(A, g)
            b = false;

            if g == 0
                if sum(abs(A.m(2:8))) == 0
                    b = true;
                end
            elseif g == 1
                if sum(abs([A.m(1);A.m(5:8)])) == 0
                    b = true;
                end
            elseif g == 2
                if sum(abs([A.m(1:4);A.m(8)])) == 0
                    b = true;
                end
            elseif g == 3
                if sum(abs(A.m(1:7))) == 0
                    b = true;
                end
            elseif g == -1
                z = A.m == 0;
                z0 = z(1);
                z1 = sum(z(2:4)) ~= 0;
                z2 = sum(z(5:7)) ~= 0;
                z3 = z(8);
                % TODO: What does the comment below mean?
                % Note that the test treats 0 is a multivector!
                if z0 + z1 + z2 + z3 ~= 1
                    b = true;
                end
            else
                error('isgrade: invalid grade.');
            end
        end

        function R = gexp_(A)
            rm = productleftexpand_(A);
            E = expm(rm);
            R = OGA(E(1:8,1));
        end

        function R = glog_(A)
            rm = productleftexpand_(A);
            L = logm(rm);
            R = OGA(L(1:8, 1));
        end

        function R = sqrt_(A)
            rm = productleftexpand_(A);
            S = sqrtm(rm);
            R = PGA(S(1:8, 1));
            % TODO: fix this. Gets i on -1.
        end

        function r = getx_(A)
            %GETX_ - A private function for computing the x coordinate of an OGA element.
            %   Will return the e1 component of a vector. Non-vectors return an error.

            if GAisa_(A, "vector")
                r = A.m(2);
            else
                error("X coordinate of non-vectors is not defined for OGA.")
            end
        end
        
        function r = gety_(A)
            %GETY_ - A private function for computing the y coordinate of an OGA element.
            %   Will return the e2 component of a vector. Non-vectors return an error.
            
            if GAisa_(A, "vector")
                r = A.m(3);
            else
                error("Y coordinate of non-vectors is not defined for OGA.")
            end
        end
        
        function r = getz_(A)
            %GETZ_ - A private function for computing the z coordinate of an OGA element.
            %   Will return the e3 component of a vector. Non-vectors return an error.
            
            if GAisa_(A, "vector")
                r = A.m(4);
            else
                error("Z coordinate of non-vectors is not defined for OGA.")
            end
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

            [s, pl] = GA.charifyval_(p.m(2), 'e1', s, pl);
            [s, pl] = GA.charifyval_(p.m(3), 'e2', s, pl);
            [s, pl] = GA.charifyval_(p.m(4), 'e3', s, pl);
                        
            if GA.compact_notation()
                if OGA.increasing_order()
                    [s, pl] = GA.charifyval_(p.m(5), 'e12', s, pl);
                    [s, pl] = GA.charifyval_(p.m(6), 'e13', s, pl);
                    [s, pl] = GA.charifyval_(p.m(7), 'e23', s, pl);
                else
                    [s, pl] = GA.charifyval_(p.m(7), 'e23', s, pl);
                    [s, pl] = GA.charifyval_(-p.m(6), 'e31', s, pl);
                    [s, pl] = GA.charifyval_(p.m(5), 'e12', s, pl);
                end

                if GA.compact_pseudoscalar()
                    [s, pl] = GA.charifyval_(p.m(8), 'I3', s, pl);
                else
                    [s, pl] = GA.charifyval_(p.m(8), 'e123', s, pl);
                end
            else
                if OGA.increasing_order()
                    [s, pl] = GA.charifyval_(p.m(5), 'e1^e2', s, pl);
                    [s, pl] = GA.charifyval_(p.m(6), 'e1^e3', s, pl);
                    [s, pl] = GA.charifyval_(p.m(7), 'e2^e3', s, pl);
                else 
                    [s, pl] = GA.charifyval_(p.m(7), 'e2^e3', s, pl);
                    [s, pl] = GA.charifyval_(-p.m(6), 'e3^e1', s, pl);
                    [s, pl] = GA.charifyval_(p.m(5), 'e1^e2', s, pl);
                end

                if GA.compact_pseudoscalar()
                    [s, pl] = GA.charifyval_(p.m(8), 'I3', s, pl);
                else
                    [s, pl] = GA.charifyval_(p.m(8), 'e1^e2^e3', s, pl);
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
            if OGA.increasing_order()
                e = [OGA(1), e1(OGA), e2(OGA), e3(OGA), e12(OGA), e13(OGA), e23(OGA), e123(OGA)];
            else 
                e = [OGA(1), e1(OGA), e2(OGA), e3(OGA), e23(OGA), e31(OGA), e12(OGA), e123(OGA)];
            end
        end

        function s = modelname()
            s = "OGA";
        end

        function R = cast(A)
            if isa(A, 'OGA')
                R = A;
            elseif isa(A, 'double')
                if GA.autoscalar
                    R = OGA(A);
                else 
                    error('Implicit conversion between a double and OGA is disabled. Run "help GA.autoscalar" for more information.')
                end
            else
                error(['Cannot implictly convert from ' class(A) ' to OGA'])
            end
        end
        
        function r = getzero()
            r = OGA(0);
        end
    end


    % ******************** Public Methods ********************
    methods (Access = public)
        function obj = OGA(m0, m1, m2, m3)
            %OGA - The constructor for OGA elements.
            %   If no arugment is provided, the 0 element in OGA is returned.
            %   If 1 arugment is provided and it is a OGA element, the element itself will
            %   be returned. If the argument is a double, an OGA element of that scalar will
            %   be returned.
            %   If 4 arguments are provided, it is assumed they have the following format:
            %   The first argument is a double for the scalar portion of the multivector
            %   The second argument is [c1, c2, c3], where ci is a double corresponding
            %   to the coefficient for ei.
            %   The third argument is [c12, c13, c23], where cij is a double
            %   corresponding to the coefficient for eij.
            %   The fourth argument is a double corresponding to the coefficient for e123.
            %   For any of the arguments, one can optionally simply put 0 to have zero
            %   for all the corresponding coefficients.
            %
            %   It is not generally recommended to construct OGA elements this way.
            %   Instead, consider writing equations of the form
            %                              e1 + e2^e3
            %   while in the OGA model (see help GA.settings and help GA.model)
            %   or while not in the OGA model as
            %                              e1(OGA) + e2(OGA)^e3(OGA)

            if nargin == 0
                obj = OGA(0);
            elseif nargin == 4
                if m1 == 0
                    m1 = zeros(3, 1);
                end
                if m2 == 0
                    m2 = zeros(3, 1);
                end
                obj.m = [m0; 
                         m1(1); m1(2); m1(3)
                         m2(1); m2(2); m2(3);  
                         m3];
            elseif nargin == 1
                if isa(m0, 'OGA')
                    obj = m0;
                elseif isa(m0, 'double')
                    if size(m0, 1) == 1 & size(m0, 2) == 1
                        % User has provided a scalar
                        obj.m = [m0; 
                                 0; 0; 0; 
                                 0; 0; 0; 
                                 0];
                    elseif size(m0, 1) == 1 & size(m0, 2) == 8
                        % User has provided a column vector
                        obj.m = m0';
                    elseif size(m0, 1) == 8 & size(m0, 2) == 1
                        % User has prodived a row vector
                        obj.m = m0;
                    else
                        error('Bad OGA argument: Unexpected array size.\nExpected size is either 1x1, 8x1 or 1x8.\nCurrent size is: %dx%d', size(m0, 1), size(m0, 2))
                    end
                else
                    error('Bad OGA argument: Invalid input type. Class is currently: %s.', class(m0))
                end
            else 
                error('Bad OGA argument: Invalid number of arguments.')
            end
        end

        % Returns the matrix for the OGA object. For debugging purposes.
        % TODO: add to change notes: method m in GA is now called matrix in OGA.
        function rm = matrix(self)
            rm = self.m;
        end

        function b = GAisa(A, t)
            %GAISA - Determines in a multivector and a string representing a type of
            %   multivector and returns true if the multivector is of that type.
            %   In OGA, valid types are:
            %   scalar, vector, bivector, trivector, pseudoscalar, multivector

            arguments
                A OGA;
                t (1, 1) string;
            end
            
            b = GAisa_(A, t);
        end

        function R = OGAcast(A)
            R = A;
        end

        function R = PGAcast(A)
            scal = A.m(1);
            E1   = A.m(2);
            E2   = A.m(3);
            E3   = A.m(4);
            E12  = A.m(5);
            E13  = A.m(6);
            E23  = A.m(7);
            E123 = A.m(8);
            R = PGA(scal, [0, E1, E2, E3], [0, 0, 0, E12, E13, E23], [0, 0, 0, E123], 0);
        end

        function draw(A, varargin)
            arguments
                A OGA;
            end
            arguments (Repeating)
                varargin
            end

            % Default offset is the origin
            offset = origin(PGA);

            GAScene.usefigure();

            A = zeroepsilons_(A);
            
            if GAisa(A, 'scalar')
                % TODO: color for different color inputs
                title(double(A));
            
            elseif GAisa(A, 'vector')

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
                % TODO: make a proper way of converting a vector to a point
                h = PGABLEDraw.arrow(offset, ihd(PGAcast(A)) - offset, updated_varargin{:});
                GAScene.addstillitem(GASceneStillItem(A, h));
            elseif GAisa(A, 'bivector')

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
                h = PGABLEDraw.hairydisk(PGAcast(A), offset, updated_varargin{:});
                GAScene.addstillitem(GASceneStillItem(A, h));
            elseif GAisa(A, 'trivector')

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

                updated_varargin = PGABLEDraw.defaultvarargin('Color', 'r', varargin{:});
                h = PGABLEDraw.hairyball(A, offset, updated_varargin{:});
                GAScene.addstillitem(GASceneStillItem(A, h));
            else
                error('Error is not a vector, bivector or trivector. OGA cannot draw it.');
            end
        end

        function r = e1coeff(A)
            %E1COEFF - Returns the coefficient of e1.

            M = matrix(A);
            r = M(2);
        end

        function r = e2coeff(A)
            %E2COEFF - Returns the coefficient of e2.

            M = matrix(A);
            r = M(3);
        end

        function r = e3coeff(A)
            %E3COEFF - Returns the coefficient of e3.

            M = matrix(A);
            r = M(4);
        end

        function r = e12coeff(A)
            %E12COEFF - Returns the coefficient of e12.

            M = matrix(A);
            r = M(5);
        end

        function r = e13coeff(A)
            %E13COEFF - Returns the coefficient of e13.

            M = matrix(A);
            r = M(6);
        end

        function r = e23coeff(A)
            %E23COEFF - Returns the coefficient of e23.

            M = matrix(A);
            r = M(7);
        end

        function r = e123coeff(A)
            %E123COEFF - Returns the coefficient of e123.

            M = matrix(A);
            r = M(8);
        end

        function r = geoPGA(A)
            if GAisa(A, 'vector')
                l = dual(A);
                r = -PGAcast(l);
            elseif GAisa(A, 'bivector')
                normal = dual(A);
                r = PGAcast(normal);
            else
                error('Error is not a vector or a bivector. PGABLE cannot geometrically convert this element.');
            end
        end
    end

end
