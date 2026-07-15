classdef (Abstract) GA
    %GA - An abstract class that encompasses all geometric algebra objects.
    %   Specific models of geometric algebra are child classes of this abstract class,
    %   namely OGA, CGA and PGA. To see more specific information on elements and methods
    %   of those particular models, run "help OGA", "help CGA", or "help PGA".
    %   To learn how the drawing routines work, run "help GAScene".
    %   
    %   Settings common to all GA models are stored by static variables in this class.
    %   To see which settings are available, run "GA.settings".
    %   To see how to use GA.settings, run "help GA.settings".
    %
    %   See also PGA, CGA, OGA.

    % PGABLE, Copyright (c) 2024, University of Waterloo
    % Copying, use and development for non-commercial purposes permitted.
    %          All rights for commercial use reserved; for more information
    %          contact Stephen Mann (smann@uwaterloo.ca)
    %
    %          This software is unsupported.

    % ******************** Public Static Methods ********************

    methods (Static = true)

        %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%
        %           Settings           %
        %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%

        function settings()
            %SETTINGS - Displays the current configuration settings for PGABLE.
            %   To retrieve a particular setting, run "GA.[setting]".
            %   For example, to retrieve the value of autoscalar, run "GA.autoscalar".
            %   To change the value of a particular setting, run "GA.[setting]([value])".
            %   For example, to set the value of autoscalar to false, run
            %   "GA.autoscalar(false)".
            %   For more information on a particular setting, run help "GA.[setting]".
            %   To surpress the console output of changing a settings, set the second
            %   parameter to true, for example "GA.epsilon_tolerance(1E-13, true)" will set
            %   the epsilon tolerance to 1E-13 without printing the change to the console.

            disp("   ~~~~~~~~~~ Settings ~~~~~~~~~~")
            disp("   autoscalar:           " + GA.autoscalar())
            disp("   compact_notation:     " + GA.compact_notation())
            disp("   compact_pseudoscalar: " + GA.compact_pseudoscalar())
            disp("   epsilon_tolerance:    " + GA.epsilon_tolerance())
            disp("   indicate_model:       " + GA.indicate_model())
            disp("   model:                " + GA.model())
            
        end

        % TODO: Mention in documentation that this function will now no longer convert GA elements to scalars, only scalars to GA elements
        function val = autoscalar(newval, surpress_output)
            %AUTOSCALAR - Set/retreive the AUTOSCALAR setting.
            %   The AUTOSCALAR setting is either true or false.
            %   When set to true, doubles in equations will automatically be converted to GA
            %   scalar elements.
            %   When set to false, doubles in equations will return an error.
            %   If no argument is provided, AUTOSCALAR returns the current value of the
            %   AUTOSCALAR setting.
            
            arguments
                newval = [];
                surpress_output = false;
            end

            persistent currentval;
            
            % By default the autoscalar setting is set to true
            if isempty(currentval)
                currentval = true;
            end

            if isempty(newval)
                % User is trying to retrieve the current value
                val = currentval;
            else
                % User is trying to set the value
                if islogical(newval)
                    currentval = newval;
                    if ~surpress_output
                        disp("   autoscalar set to " + currentval)
                    end
                else
                    error('autoscalar must have value true or false.')
                end
            end 
        end

        function val = model(newval, surpress_output)
            %MODEL - Set/retreive the MODEL setting.
            %   The MODEL setting is an element indicating the current model.
            %   To retrieve the name of the current model in use, run GA.model().
            %   To retrieve the zero element of the current model in use, run GA.model(true).
            %   To set the current model, input an element of the desired model.
            %   Thus, for example, GA.model(PGA) and GA.model(e1(PGA) + e2(PGA)) will set the
            %   current model to PGA.
            %
            %   The value of MODEL indicates which model of geometric algebra is in use.
            %   This determines, for example:
            %      - What model to construct elements such as e1
            %      - How drawing an element such as e12 should be interpreted
            %      - Whether the element e0 is a valid element or not
            %   
            %   To construct an element outside of the current model, a model can be indicated
            %   as an argument. For example, e1(PGA) will always construct e1 as a PGA
            %   element, regardless of the current selected model.
            %
            %   See also e1, origin, point.

            arguments
                newval = [];
                surpress_output = false;
            end

            persistent currentval;
            
            % By default the model is OGA
            if isempty(currentval)
                currentval = OGA();
            end

            if isempty(newval)
                % User is trying to retrieve the name of the current value
                val = currentval.modelname();
            else

                if islogical(newval) && newval
                    % User is trying to retrieve the zero element
                    val = currentval;
                else
                    % User is trying to set the value

                    if ~isa(newval, 'GA')
                        error("Model must be a child of class GA.")
                    end

                    currentval = newval.getzero();

                    if ~surpress_output
                        disp("   model set to " + currentval.modelname())
                    end
                end
                
            end 
        end

        function val = indicate_model(newval, surpress_output)
            %INDICATE_MODEL - Set/retreive the INDICATE_MODEL setting.
            %   The INDICATE_MODEL setting is either true or false.
            %   When set to true, the current model will be displayed with the value of each
            %   GA element.
            %   When set to false, the current model will be hidden when the value of a GA
            %   element is displayed.

            arguments
                newval = [];
                surpress_output = false;
            end

            persistent currentval;
            
            % By default the indicate_model setting is set to false
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
                        disp("   indicate_model set to " + currentval)
                    end
                else
                    error('indicate_model must have value true or false.')
                end
            end 
        end

        function val = epsilon_tolerance(newval, surpress_output)
            %EPSILON_TOLERANCE - Set/retreive the tolerance for epsilon.
            %   The EPSILON_TOLERANCE is a non-negative real number which indicates the value
            %   for which all values whose magnitude is smaller than it will be considered
            %   epsilon. Thus, for any value x, x will be considered an epsilon if
            %                           abs(x) < GA.epsilon_tolerance.
            %   These values will be displayed as ε or -ε.
            %   By default, the value of epsilon_tolerance is 1e-15.

            arguments
                newval = [];
                surpress_output = false;
            end

            persistent currentval;
            
            % By default the indicate_model setting is set to false
            if isempty(currentval)
                currentval = 1e-15;
            end

            if isempty(newval)
                % User is trying to retrieve the current value
                val = currentval;
            else
                % User is trying to set the value
                if isnumeric(newval)
                    if newval >= 0
                        currentval = newval;
                        if ~surpress_output
                            disp("   epsilon_tolerance set to " + currentval)
                        end
                    else
                        error('epsilon_tolerance must be a non-negative number.')
                    end
                else
                    error('epsilon_tolerance must be a number.')
                end
            end 
        end

        function val = compact_notation(newval, surpress_output)
            %COMPACT_NOTATION - Set/retrieve the COMPACT_NOTATION setting.
            %   The COMPACT_NOTATION setting is either true or false.
            %   When set to true, GA elements will be displayed in compact notation.
            %   For example, the element e1^e2^e3 will be written as e123.
            %   When set to false, GA elements will be written in the full outer product form.
            %   If no argument is provided, COMPACT_NOTATION returns the current value of the
            %   COMPACT_NOTATION setting.
            %
            %   See also COMPACT_PSEUDOSCALAR.

            arguments
                newval = [];
                surpress_output = false;
            end

            persistent currentval;
            
            % By default the compact_notation setting is set to false
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
                        disp("   compact_notation set to " + currentval)
                    end
                else
                    error('compact_notation must have value true or false.')
                end
            end
        end

        function val = compact_pseudoscalar(newval, surpress_output)
            %COMPACT_PSEUDOSCALAR - Set/retrieve the COMPACT_PSEUDOSCALAR setting.
            %   The COMPACT_PSEUDOSCALAR setting is either true or false.
            %   When set to true, The pseudoscalar of the GA model will be represented via I[dim]
            %   where [dim] is the dimensionality of the space. Thus the following notation is used:
            %      OGA: I3 := e1^e2^e3
            %      PGA: I4 := e0^e1^e2^e3
            %      CGA: I5 := no^e1^e2^e3^ni
	    %   although in some models, you can select the pseudoscalar
            %   When set to false, this notation is not used.
            %   If no argument is provided, COMPACT_PSEUDOSCALAR returns the current value of the COMPACT_PSEUDOSCLAR setting.
            %
            %   See also COMPACT_NOTATION.

            arguments
                newval = [];
                surpress_output = false;
            end

            persistent currentval;
            
            % By default the compact_pseudoscalar setting is set to false
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
                        disp("   compact_pseudoscalar set to " + currentval)
                    end
                else
                    error('compact_pseudoscalar must have value true or false.')
                end
            end
        end
    end


    % ******************** Protected Static Methods ********************

    methods (Access = protected, Static)
        function [s_new, pl_new] = charifyval_(val, str, s, pl)
            s_new = s;
            pl_new = pl;
            
            if val ~= 0
                if val == 1
                    s_new = [s pl str];
                elseif val == -1
                    s_new = [s pl '-' str];
                elseif abs(val) < GA.epsilon_tolerance
                    if val < 0
                        s_new = [s pl '-ε*' str];
                    else
                        s_new = [s pl 'ε*' str];
                    end
                else
                    number_string = num2str(val);
                    % This converts scientific notation to use capital E to avoid confusion
                    number_string = regexprep(number_string, 'e\+?(-?\d+)', 'E$1');
                    s_new = [s pl number_string '*' str];
                end
                pl_new = ' + ';
            end
        end

        function C = getdominating_(A, B)
            if nargin == 2
                if isa(A, 'GA')
                    C = A;
                elseif isa(B, 'GA')
                    C = B;
                else
                    C = GA.model(true);
                end
            else
                if isa(A, 'GA')
                    C = A;
                else 
                    C = GA.model(true);
                end
            end
        end
    end

    % ******************** Public Static Abstract Methods ********************
    methods (Access = public, Static, Abstract)
        %ELEMENTS - Returns the elements of the model as an array.
        elements();

        %MODELNAME - Returns the name of the model of the element.
        modelname();

        %CAST - Converts the input into an element of the model if an implicit conversion
        %   is possible.
        cast(A);

        %GETZERO - Returns the zero (additive identity) of the model.
        getzero();
    end

    % ******************** Public Methods ********************
    methods (Access = public)

        %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%
        %         Public Tools         %
        %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%

        function s = char(p, indicate_model)
            %CHAR - Returns the string representation of a GA element.
            %   The (optional) second argument, indicate_model, determines if the model is
            %   included in the string representation of the element.
            %   The default value of indicate_model is false.
            
            arguments
                p;
                indicate_model = false;
            end
            
            if size(p, 2) > 1
                % TODO: The following below is a demo of an idea. Essentially, we could allow the user
                %       to work with matrices of GA objects rather than one at a time.
                s = [];
                for p_element = p
                    s = [s char(9) char_(p_element)];
                end
            else 
                s = char_(p);
            end

            if GA.indicate_model() || indicate_model
                s = ['(' convertStringsToChars(p.modelname()) ') ' s];
            end
        end

        function display(p)
            %DISPLAY - Displays the element in the console.
            disp(' ');
            disp([inputname(1),' = '])
            disp(' ');
            disp(['     ' char(p)])
            disp(' ');
        end

        %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%
        %           Wrappers           %
        %%%%%%%%%%~%%%%%%%%%%~%%%%%%%%%%

        % Addition, subtraction, negation
        
        function R = plus(A, B)
            %PLUS - Computes the addition of GA multivectors.

            C = GA.getdominating_(A, B);
            R = plus_(C.cast(A), C.cast(B));
        end

        function R = uplus(A)
            %UPLUS - Handles +A notation for multivector A.

            R = A;
        end

        function R = minus(A, B)
            %MINUS - Computes the subtraction of GA multivectors.

            C = GA.getdominating_(A, B);
            R = minus_(C.cast(A), C.cast(B));
        end

        function R = uminus(A)
            %UMINUS - Handles -A notation for multivector A.

            R = uminus_(A);
        end

        % Outer product

        function R = outer(A, B)
             %OUTER - Computes the outer product of GA multivectors.

            C = GA.getdominating_(A, B);
            R = outer_(C.cast(A), C.cast(B));
        end

        function R = mpower(A, B)
            %MPOWER - Handles A^B notation of GA multivectors and computes the outer product
            %   between the multivectors.

            C = GA.getdominating_(A, B);
            R = outer_(C.cast(A), C.cast(B));
        end

        % Inner product

        function R = cdot(A, B)
            %CDOT - Computes the Hestenes inner product of multivectors.

            C = GA.getdominating_(A, B);
            R = cdot_(C.cast(A), C.cast(B));
        end

        function R = inner(A, B)
            %INNER - Computes the inner product of multivectors.

            C = GA.getdominating_(A, B);
            R = inner_(C.cast(A), C.cast(B));
        end

        function R = times(A, B)
            %TIMES - Handles A.*B notation of GA multivectors and computes the inner product
            %   between the multivectors.

            C = GA.getdominating_(A, B);
            R = inner_(C.cast(A), C.cast(B));
        end

        % Contractions

        function R = leftcontraction(A, B)
            %LEFTCONTRACTION - Computes the left contraction of A onto B.
            %
            %   See also lcont.

            C = GA.getdominating_(A, B);
            R = leftcontraction_(C.cast(A), C.cast(B));
        end

        function R = lcont(A, B)
            %LCONT - Shorthand for leftcontraction.
            %
            %   See also leftcontraction.

            C = GA.getdominating_(A, B);
            R = leftcontraction_(C.cast(A), C.cast(B));
        end

        function R = rightcontraction(A, B)
            %RIGHTCONTRACTION - Computes the right contraction of A contracted by B.
            %
            %   See also rcont.

            C = GA.getdominating_(A, B);
            R = rightcontraction_(C.cast(A), C.cast(B));
        end

        function R = rcont(A, B)
            %RCONT - Shorthand for rightcontraction.
            %
            %   See also rightcontraction.

            C = GA.getdominating_(A, B);
            R = rightcontraction_(C.cast(A), C.cast(B));
        end

        % Equalities and inequalities

        function b = eq(A, B)
            %EQ - Tests equality between GA mutlivectors (within a tolerance of epsilon).
            %
            %   See also ne, eeq.

            C = GA.getdominating_(A, B);
            b = eq_(C.cast(A), C.cast(B));
        end

        function b = eeq(A, B)
            %EEQ - Tests equality between GA mutlivectors (exact equality of all coefficients).
            %
            %   See also eq, ne.

            C = GA.getdominating_(A, B);
            b = eeq_(C.cast(A), C.cast(B));
        end

        function b = ne(A, B)
            %NE - Tests inequality between GA multivectors (within a tolerance of epsilon).
            %
            %   See also eq, eeq.
            C = GA.getdominating_(A, B);
            b = ne_(C.cast(A), C.cast(B));
        end

        % Geometric product

        function R = product(A, B)
            %PRODUCT - Computes the geometric product between multivectors.
            %
            %   See also prod, mtimes.
            C = GA.getdominating_(A, B);
            R = product_(C.cast(A), C.cast(B));
        end

        function R = prod(A, B)
            %PROD - Shorthand for product.
            %
            %   See also product, mtimes.
            C = GA.getdominating_(A, B);
            R = product_(C.cast(A), C.cast(B));
        end

        function R = mtimes(A, B)
            %MTIMES - Handles A*B notation of GA multivectors and computes the geometric
            %   product between the multivectors.
            %
            %   See also product, prod.

            C = GA.getdominating_(A, B);
            R = product_(C.cast(A), C.cast(B));
        end

        % Inverse

        function R = inverse(A)
            %INVERSE - Computes the inverse of a GA multivector.

            R = inverse_(A);
        end

        % Divide

        function R = divide(A, B)
            %DIVIDE - Computes the division of A over B.
            %
            %   See also mrdivide.

            C = GA.getdominating_(A, B);
            R = divide_(C.cast(A), C.cast(B));
        end

        function R = mrdivide(A, B)
            %MTIMES - Handles A/B notation of GA multivectors and computes the division
            %    of multivector A over multivector B.
            %
            %   See also divide.

            C = GA.getdominating_(A, B);
            R = divide_(C.cast(A), C.cast(B));
        end

        % Logs, exponentials, roots

        function R = wexp(A)
            %WEXP - Computes the exponential of the outer product.

            R = wexp_(A);
        end

        function R = gexp(A)
            %GEXP - Computes the geometric exponential of a multivector.

            R = gexp_(A);
        end

        function R = glog(A)
            %GLOG - Computes the geometric logarithm of a multivector.

            R = glog_(A);
        end

        function R = sqrt(A)
            %SQRT - Computes the square root of a multivector (such that the geometric product
            %   of the resulting element with itself results in the input).

            R = sqrt_(A);
        end

        % Norms and normalization

        function r = norm(A)
            %NORM - Computes the norm of the multivector.

            r = norm_(A);
        end

        function r = vnorm(A)
            %VNORM - Computes the vanishing norm of the multivector.
            
            r = vnorm_(A);
        end

        function R = normalize(A)
            %NORMALIZE - Computes the normalized multivector.

            R = normalize_(A);
        end

        % Dual

        function R = dual(A)
            %DUAL - Computes the dual.
            %
            %   See also d.

            R = dual_(A);
        end

        function R = d(A)
            %D - Shorthand for dual.
            %
            %   See also dual.

            R = dual_(A);
        end

        % Inverse dual

        function R = inversedual(A)
            %INVERSEDUAL - Computes the inverse dual.
            %
            %   See also invdual, id.
            R = inversedual_(A);
        end

        function R = invdual(A)
            %INVDUAL - Shorthand for inversedual.
            %
            %   See also inversedual, id.

            R = inversedual_(A);
        end

        function R = id(A)
            %ID - Shorthand for inversedual.
            %
            %   See also inversedual, id.

            R = inversedual_(A);
        end

        % Hodge dual

        function R = hodgedual(A)
            %HODGEDUAL - Computes the hodge dual.
            %
            %   See also hdual, hd.
            R = hodgedual_(A);
        end

        function R = hdual(A)
            %HDUAL - Shorthand for hodgedual.
            %
            %   See also hodgedual, hd.
            R = hodgedual_(A);
        end

        function R = hd(A)
            %HD - Shorthand for hodgedual.
            %
            %   See also hodgedual, hdual.
            R = hodgedual_(A);
        end

        % Inverse Hodge dual

        function R = inversehodgedual(A)
            %INVERSEHODGEDUAL - Computes the inverse hodge dual.
            %
            %   See also invhodgedual, invhdual, ihd.

            R = inversehodgedual_(A);
        end

        function R = invhodgedual(A)
            %INVHODGEDUAL - Shorthand for inversehodgedual.
            %
            %   See also inversehodgedual, invhdual, ihd.

            R = inversehodgedual_(A);
        end

        function R = invhdual(A)
            %INVHDUAL - Shorthand for inversehodgedual.
            %
            %   See also inversehodgedual, invhodgedual, ihd.
            R = inversehodgedual_(A);
        end

        function R = ihd(A)
            %IHD - Shorthand for inversehodgedual.
            %
            %   See also inversehodgedual, invhodgedual, invhdual.
            R = inversehodgedual_(A);
        end

        % JMap

        function R = jmap(A)
            %JMAP - Computes the jmap, also called the poincare dual.
            %
            %   See also poincaredual, pdual, pd.

            R = jmap_(A);
        end

        function R = poincaredual(A)
            %POINCAREDUAL - Computes the poincare dual, also called the jmap.
            %
            %   See also jmap, pdual, pd.

            R = jmap_(A);
        end

        function R = pdual(A)
            %PDUAL - Shorthand for poincaredual.
            %
            %   See also jmap, poincaredual, pd

            R = jmap_(A);
        end

        function R = pd(A)
            %PD - Shorthand for poincaredual.
            %
            %   See also jmap, poincaredual, pdual.
            R = jmap_(A);
        end

        % Reverse

        function R = reverse(A)
            %REVERSE - Computes the reverse.
            %
            %   See also rev.

            R = reverse_(A);
        end

        function R = rev(A)
            %REV - Shorthand for reverse.
            %
            %   See also reverse.

            R = reverse_(A);
        end

        % Meet and join

        function R = meet(A, B)
            %MEET - Computes the meet of two multivectors.

            C = GA.getdominating_(A, B);
            R = meet_(C.cast(A), C.cast(B));
        end

        function R = join(A, B)
            %JOIN - Computes the join of two multivectors.

            C = GA.getdominating_(A, B);
            R = join_(C.cast(A), C.cast(B));
        end

        % Conjugate and involution

        function R = conjugate(A)
            %CONJUGATE - Computes the conjugate.
            %
            %   See also conj.

            R = conjugate_(A);
        end

        function R = conj(A)
            %CONJ - Shorthand for conjugate.
            %
            %   See also conjugate.

            R = conjugate_(A);
        end

        function R = gradeinvolution(A)
            %GRADEINVOLUTION - Computing the grade involution.
            %
            %   See also gi.

            R = gradeinvolution_(A);
        end

        function R = gi(A)
            %GI - Shorthand for gradeinvolution.
            %
            %   See also gradeinvolution.

            R = gradeinvolution_(A);
        end

        % Grades

        function R = grade(A, n)
            %GRADE - If only a multivector is provided, returns the a non-negative integer
            %   representing the grade of the element (or -1 if the element contains
            %   multiple grades).
            %   If a multivector and an integer n is provided, returns the grade n component
            %   of the multivector.

            arguments
                A GA;
                n (1, 1) int32 = -1;
            end

            R = grade_(A, n);
        end

        function b = isgrade(A, g)
            %ISGRADE - Returns true if the multivector A is a blade of grade g, and false otherwise.
            %
            %   See also GAisa, PGA.GAisa, CGA.GAisa, OGA.GAisa.

            arguments
                A GA;
                g (1, 1) uint32;
            end
            b = isgrade_(A, g);
        end

        function R = hsmap(A, n)
            %HMAP - The Hitzer-Sanwine map.  Return A with its grade 'n' elements
	    %   negated.

            arguments
                A GA;
                n (:, 1) int32 = -1;
            end

            R = hsmap_(A, n);
        end


        % Coordinates

        function r = getx(A)
            %GETX - Computes the x coordinate of an element.
            %   The enterpretation of this computation (and which elements are valid input)
            %   highly depends on the model. Thus, for more help, run "help [model].getx_".

            r = getx_(A);
        end

        function r = gety(A)
            %GETY - Computes the y coordinate of an element.
            %   The enterpretation of this computation (and which elements are valid input)
            %   highly depends on the model. Thus, for more help, run "help [model].gety".

            r = gety_(A);
        end

        function r = getz(A)
            %GETZ - Computes the z coordinate of an element.
            %   The enterpretation of this computation (and which elements are valid input)
            %   highly depends on the model. Thus, for more help, run "help [model].getz".

            r = getz_(A);
        end

        % Cleaning

        function R = zeroepsilons(A)
            %ZEROEPSILONS - Sets any epsilons to zero.
            %   I.e. it takes any basis blade within the multivector with coefficient size
            %   less than GA.epsilon_tolerance and sets it to zero.
            %
            %   See also GAZ, GA.epsilon_tolerance.

            R = zeroepsilons_(A);
        end

        function R = GAZ(A)
            %GAZ - Shorthand for zeroepsilons.
            %
            %   See also zeroepsilons.

            R = zeroepsilons_(A);
        end

        % Conversion

        function r = double(A)
            %DOUBLE - Converts a scalar GA element into a double.
            %   Returns an error if the GA element is not a scalar.

            r = double_(A);
        end

        % Versor batch

        function rg = versorbatch(V, multivectors)
            arguments
                V GA;
                multivectors;
            end

            invV = inverse(V);
            rg = cell(size(multivectors, 1), size(multivectors, 2));

            for i = 1:size(multivectors, 1)
                for j = 1:size(multivectors, 2)
                    rg{i, j} = V*multivectors{i, j}*invV;
                end
            end
        end

        % TODO: proper arguments block, rename 2nd parameter, cleanup

        function rg = versorbatchiterate(V, multivector_list, iterations, include_zero)
            arguments
                V GA;
                multivector_list;
                iterations uint32 = 1;
                include_zero = false;
            end

            invV = inverse(V);
            mln = size(multivector_list, 2);

            if include_zero
                rg = cell(iterations + 1, mln);

                for mli = 1:mln
                    rg{1, mli} = multivector_list{mli};
                    for iter = 2:(iterations+1)
                        rg{iter, mli} = V * rg{iter-1, mli} * invV;
                    end
                end
            else
                rg = cell(iterations, mln);

                for mli = 1:mln
                    rg{1, mli} = V * multivector_list{mli} * invV;
                    for iter = 2:iterations
                        rg{iter, mli} = V * rg{iter-1, mli} * invV;
                    end
                end
            end
        end

    end

    % ******************** Abstract Public Methods ********************
    
    methods (Abstract, Access = public)
        %MATRIX - Returns the internal matrix representation of a multivector.
        %   This is for debugging purposes.
        matrix(A);

        %GAISA - Takes a multivector and a string representing a type of a multivector
        %   as input and returns true if the multivector is of that type.
        %   Which types are valid depends on the GA model. Thus, to see which types are
        %   permissable, run help [model].GAisa to see the list of options.
        %   For example, to see the options for PGA, run "help PGA.GAisa".
        %
        %   See also PGA.GAisa, OGA.GAisa.
        GAisa(A, t);

        %PGACAST - Casts a GA element directly into PGA without geometric considerations.
        %   It converts elements directly, removing any incompatible elements.
        %   For example, PGAcast(e1(OGA) + e2(OGA)) will result in the PGA element e1+e2.
        %   (despite the fact that e1+e2 is a vector in OGA but a plane in PGA).
        PGAcast(A);

        %OGACAST - Casts a GA element directly into OGA without geometric considerations.
        %    It converts elements directly, removing any incompatible elements.
        %    For example, OGAcast(e0(PGA)+e1(PGA)) will result in the OGA element e1.
        %    (since the element e0 does not exist in OGA).
        OGAcast(A);

        %DRAW - Draws the GA element to the GA Scene figure.
        %   Note that the geometric interpretation of elements depends on the model.
        %   Thus, draw(e1(OGA)) may draw something different than draw(e1(PGA)).
        %   Not all elements can be drawn. You will receive an error if it cannot be drawn.
        draw(A, varargin);
    end

    % ******************** Abstract Protected Methods ********************

    methods (Abstract, Access = protected)
        char_(A);
        conjugate_(A);
        divide_(A, B);
        double_(A);
        dual_(A);
        eeq_(A, B);
        eq_(A, B);
        getx_(A);
        gety_(A);
        getz_(A);
        gexp_(A);
        glog_(A);
        grade_(A, n);
        gradeinvolution_(A);
        hsmap_(A, n);
        hodgedual_(A);
        inner_(A, B);
        cdot_(A, B);
        inverse_(A);
        inversedual_(A);
        inversehodgedual_(A);
        isgrade_(A, g);
        jmap_(A);
        join_(A, B);
        leftcontraction_(A, B);
        meet_(A, B);
        minus_(A, B);
        ne_(A, B);
        norm_(A);
        normalize_(A);
        outer_(A, B);
        plus_(A, B);
        product_(A, B);
        reverse_(A);
        rightcontraction_(A, B);
        sqrt_(A);
        uminus_(A);
        vnorm_(A);
        zeroepsilons_(A);
        
        % TODO: Perhaps implement the methods below
        % wexp_(A);
    end

end

