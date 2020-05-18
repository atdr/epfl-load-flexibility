classdef EpsilonSkewNormalDistribution < prob.ToolboxFittableParametricDistribution
    %    An object of the EpsilonSkewNormalDistribution class represents an
    %    epsilon-skew-normal probability distribution with specific location
    %    parameter THETA, scale parameter SIGMA, and skewness parameter EPSILON.
    %    This distribution object can be created directly using the MAKEDIST
    %    function or fit to data using the FITDIST function.
    %
    %    EpsilonSkewNormalDistribution methods:
    %       cdf                   - Cumulative distribution function
    %       fit                   - Fit distribution to data
    %       icdf                  - Inverse cumulative distribution function
    %       iqr                   - Interquartile range
    %       mean                  - Mean
    %       median                - Median
    %       paramci               - Confidence intervals for parameters
    %       pdf                   - Probability density function
    %       proflik               - Profile likelihood function
    %       random                - Random number generation
    %       std                   - Standard deviation
    %       truncate              - Truncation distribution to an interval
    %       var                   - Variance
    %
    %    EpsilonSkewNormalDistribution properties:
    %       DistributionName      - Name of the distribution
    %       Theta                 - Value of the theta parameter (location)
    %       Sigma                 - Value of the sigma parameter (scale)
    %       Epsilon               - Value of the epsilon parameter (skewness)
    %       NumParameters         - Number of parameters
    %       ParameterNames        - Names of parameters
    %       ParameterDescription  - Descriptions of parameters
    %       ParameterValues       - Vector of values of parameters
    %       Truncation            - Two-element vector indicating truncation limits
    %       IsTruncated           - Boolean flag indicating if distribution is truncated
    %       ParameterCovariance   - Covariance matrix of estimated parameters
    %       ParameterIsFixed      - Two-element boolean vector indicating fixed parameters
    %       InputData             - Structure containing data used to fit the distribution    
    %
    %    See also fitdist, makedist.
    
    properties (Constant)
        % Name of the distribution.
        DistributionName = 'EpsilonSkewNormal';
        % Number of distribution parameters.
        NumParameters = 3;
        % Distribution parameter names.
        ParameterNames = {'theta', 'sigma', 'epsilon'};
        % Distribution parameter descriptions.
        ParameterDescription = {'location', 'scale', 'skewness'};
    end % properties (Constant)
    
    properties (Dependent)
        % Theta is the location parameter for this distribution, and can
        % take any real value (-Inf < Theta < Inf).
        Theta
        % Sigma is the scale parameter for this distribution, and can take
        % any positive real value (0 < Sigma < Inf).
        Sigma
        % Epsilon is the skewness parameter for this distribution, and has
        % a value between -1 and 1 (-1 < Epsilon < 1).
        Epsilon
    end % properties (Dependent)
    
    properties (SetAccess = protected)
        % Three-element vector containing the distribution parameters in
        % the order Theta, Sigma, Epsilon.
        ParameterValues
    end % properties (SetAccess = protected)
    
    methods
        
        function obj = EpsilonSkewNormalDistribution(theta, sigma, epsilon)
            % Constructor method. This can accept zero input arguments, in
            % which case a default distribution is created, or three input
            % arguments, which are checked and then stored in the object.
            % If an object is created using the constructor, then the
            % parameters are fixed and the covariance matrix is zero.
            
            switch nargin
                case 0
                    theta = 0;
                    sigma = 1;
                    epsilon = 0;
                otherwise
                    narginchk(3, 3)
            end % switch/case
            
            % Check and store the parameter values.
            checkparams(theta, sigma, epsilon);
            obj.ParameterValues = [theta, sigma, epsilon];
            % Indicate that the parameters are fixed with zero
            % covariance.
            n = obj.NumParameters;
            obj.ParameterIsFixed = true(1, n);
            obj.ParameterCovariance = zeros(n);
            
        end % constructor
        
        function m = mean(obj)
            % Mean of the distribution.
            m = obj.Theta - 4 * obj.Sigma * obj.Epsilon / sqrt(2*pi);
        end % mean
        
        function s = std(obj)
            % Standard deviation of the distribution.
            s = sqrt(var(obj));
        end
        
        function v = var(obj)
            % Variance of the distribution.
            v = (obj.Sigma^2 / pi) * ( (3*pi - 8) * obj.Epsilon^2 + pi );
        end
        
        % Get/set methods.
        % Distribution parameter set methods should mark the distribution
        % as no longer fitted, because any old results such as the
        % covariance matrix are not valid when the parameters are changed
        % from their estimated values.
        
        function obj = set.Theta(obj, theta)
            checkparams(theta, obj.Sigma, obj.Epsilon);
            obj.ParameterValues(1) = theta;
            obj = invalidateFit(obj);
        end % set.Theta
        
        function obj = set.Sigma(obj, sigma)
            checkparams(obj.Theta, sigma, obj.Epsilon);
            obj.ParameterValues(2) = sigma;
            obj = invalidateFit(obj);
        end % set.Sigma
        
        function obj = set.Epsilon(obj, epsilon)
            checkparams(obj.Theta, obj.Sigma, epsilon);
            obj.ParameterValues(3) = epsilon;
            obj = invalidateFit(obj);
        end % set.Epsilon
        
        function theta = get.Theta(obj)
            theta = obj.ParameterValues(1);
        end % get.Theta
        
        function sigma = get.Sigma(obj)
            sigma = obj.ParameterValues(2);
        end % get.Sigma
        
        function epsilon = get.Epsilon(obj)
            epsilon = obj.ParameterValues(3);
        end % get.Epsilon
        
    end % methods
    
    methods (Static)
        % All FittableDistribution classes must implement a fit method to
        % fit the distribution from data. This method is called by the
        % FITDIST function, and is not intended to be called directly.
        function obj = fit(x, varargin)
            %FIT Fit from data
            %   P = prob.EpsilonSkewNormalDistribution.fit(x)
            %   P = prob.EpsilonSkewNormalDistribution.fit(x, NAME1, VAL1, NAME2, VAL2, ...)
            %   with the following optional parameter name-value pairs:
            %
            %          'censoring'    Boolean vector indicating censored x values
            %          'frequency'    Vector indicating frequencies of corresponding
            %                         x values
            %          'options'      Options structure for fitting, as created by
            %                         the STATSET function
            
            % Get the optional arguments.
            [x, cens, freq] = prob.ToolboxFittableParametricDistribution.processFitArgs(x, varargin{:});
            
            % This distribution was not written to support censoring. The
            % following utility expands x by the frequency vector, and
            % displays an error message if there is censoring.
            distName = prob.EpsilonSkewNormalDistribution.DistributionName;
            x = prob.ToolboxFittableParametricDistribution.removeCensoring(x, cens, freq, distName);
            freq = ones(size(x));
            
            % Estimate the parameters from the data. 
            
            % Sample skewness.
            s = skewness(x);
            % Approximation formula for the epsilon parameter.
            epsilon = -0.5835 * s - 0.5861 * s^3 + 1.0763 * s^5 - 0.9226 * s^7;
            % Ensure that epsilon lies within its bounds.
            if epsilon < -1
                epsilon = -1 + eps;
            elseif epsilon > 1
                epsilon = 1 - eps;
            end
            % Approximate the sigma parameter.
            v = var(x);
            sigma = sqrt( pi * v / ( (3 * pi - 8) * epsilon^2 + pi ) );
            % Approximate the theta parameter.
            m = mean(x);
            theta = m + 4 * epsilon * sigma / sqrt( 2 * pi );
            % Initial parameter values for the estimation process.
            param0 = [theta; sigma; epsilon];
            % Perform the MLE to estimate the distribution parameters.
            f = @(data, theta, sigma, epsilon) ...
                prob.EpsilonSkewNormalDistribution.logpdffunc(...
                data, theta, sigma, epsilon);
            lb = [-Inf; 0; -1];
            ub = [Inf; Inf; 1];
            params = mle(x, 'logpdf', f, ...
                'start', param0, ...
                'LowerBound', lb, ...
                'UpperBound', ub);
            % Separate the individual parameters.
            theta = params(1);
            sigma = params(2);
            epsilon = params(3);
            
            % Create the distribution by calling the constructor.
            obj = prob.EpsilonSkewNormalDistribution(theta, sigma, epsilon);
            
            % Fill in the remaining properties as required for the
            % FittableDistribution class.
            
            % The parameters are no longer fixed, but rather estimated from
            % the data.
            obj.ParameterIsFixed = false(1, obj.NumParameters);
            % Record the negative loglikelihood value and the parameter
            % variance/covariance matrix estimate.
            [obj.NegativeLogLikelihood, ...
                obj.ParameterCovariance] = ...
                prob.EpsilonSkewNormalDistribution.likefunc(params, x);
            % Form the InputData property. This is a structure containing
            % the data used for fitting ('data'), the censoring
            % information ('cens'), and the observed frequencies ('freq').
            obj.InputData = struct('data', x, 'cens', [], 'freq', freq);
            
        end % fit
        
        % The following static methods are required for the
        % ToolboxParametricDistribution class and are used by various
        % Statistics and Machine Learning Toolbox functions. These
        % functions operate on parameter values supplied as input
        % arguments, not on the parameter values stored in an
        % EpsilonSkewNormalDistribution object. For example, the cdf method
        % implemented in a parent class invokes the cdffunc static method
        % and provides it with the parameter values.
        function [nll, acov] = likefunc(params, x)
            
            % Number of data points.
            nDataPoints = numel(x);
            
            % Distribution parameters.
            theta = params(1);
            sigma = params(2);
            epsilon = params(3);
            
            % Negative loglikelihood value.
            nll = -sum(prob.EpsilonSkewNormalDistribution.logpdffunc(x, theta, sigma, epsilon));
            
            % Asymptotic parameter variance-covariance matrix, either a
            % closed-form expression or, if a closed-form expression is
            % unknown, a call to MLECOV.
            s = (1 - epsilon^2) / (3 * pi - 8);
            acov = [3 * pi * s * sigma^2, 0, 2 * sqrt( 2 * pi ) * s * sigma
                0, 2 * sigma^4, 0
                2 * sqrt( 2 * pi ) * s * sigma, 0, pi * s] / nDataPoints;
            
        end % Likelihood function
        
        function y = cdffunc(x, theta, sigma, epsilon)
            
            y = (x - theta) / sigma;
            y = F0( y, epsilon );
            y(isnan(x)) = NaN;
            
            % Canonical CDF (ESN(0, 1, epsilon)).
            function y = F0( u, epsilon )
                negIdx = u < 0;
                y(negIdx) = (1 + epsilon) * normcdf( u(negIdx) / (1 + epsilon) );
                nonNegIdx = u >= 0;
                y(nonNegIdx) = epsilon + (1 - epsilon) * ...
                    normcdf( u(nonNegIdx) / (1 - epsilon) );
                y = reshape(y, size(u));
            end % F0
            
        end % Cumulative distribution function
        
        function y = pdffunc(x, theta, sigma, epsilon)
           
            y = exp(prob.EpsilonSkewNormalDistribution.logpdffunc(x, theta, sigma, epsilon));
            
        end % Probability density function 
        
        function y = logpdffunc(x, theta, sigma, epsilon)
            
            y = f0( (x - theta)/sigma, epsilon ) / sigma;
            y(isnan(x)) = NaN;
            y = log(y);
            
            % Canonical PDF (ESN(0, 1, epsilon)).
            function y = f0( u, epsilon )
                negIdx = u < 0;
                y(negIdx) = (1 / sqrt( 2 * pi )) * exp( - u(negIdx).^2 / (2 * (1 + epsilon)^2) );
                nonNegIdx = u >= 0;
                y(nonNegIdx) = (1 / sqrt( 2 * pi )) * exp( - u(nonNegIdx).^2 / (2 * (1 - epsilon)^2) );
                y = reshape(y, size(u));
            end % f0
            
        end % Log probability density function
        
        function y = invfunc(p, theta, sigma, epsilon)
            
            switch nargin
                case 1
                    theta = 0;
                    sigma = 1;
                    epsilon = 0;
                otherwise
                    narginchk(4, 4)
            end % switch/case
            
            y = theta + sigma * Q0( p, epsilon );
            y(p < 0 | 1 < p) = NaN;
            
            % Canonical ICDF (ESN(0, 1, epsilon)).
            function y = Q0( p, epsilon )
                L = p > 0 & p < (1 + epsilon)/2;
                y(L) = (1 + epsilon) * norminv( p(L) / (1 + epsilon) );
                L = p >= (1 + epsilon)/2 & p < 1;
                y(L) = (1 - epsilon) * norminv( (p(L) - epsilon) / (1 - epsilon) );
                y = reshape(y, size(p));
            end % Q0
            
        end % Inverse cumulative distribution function
        
        function y = randfunc(theta, sigma, epsilon, varargin)
            y = prob.EpsilonSkewNormalDistribution.invfunc(rand(varargin{:}), theta, sigma, epsilon);
        end % Random number generator
        
    end % methods (Static)
    
    methods (Static, Hidden)
        
        % All ToolboxDistributions must implement a getInfo Static method
        % so that Statistics and Machine Learning Toolbox functions can get
        % information about the distribution.
        
        function info = getInfo()
            
            % First get the default info from the parent class.
            info = getInfo@prob.ToolboxFittableParametricDistribution('prob.EpsilonSkewNormalDistribution');
            
            % Then, overwrite fields as necessary.
            info.name = prob.EpsilonSkewNormalDistribution.DistributionName;
            info.code = info.name;
            
        end % getInfo
        
    end % methods (Hidden, Static)
    
end % classdef

function checkparams(theta, sigma, epsilon)
% CHECKPARAMS Utility function for validating correct distribution parameter
% values.

validateattributes(theta, {'double'}, {'scalar', 'real', 'finite'}, ...
    'EpsilonSkewNormalDistribution/set.Theta', 'theta')
validateattributes(sigma, {'double'}, ...
    {'scalar', 'real', 'finite', 'positive'}, ...
    'EpsilonSkewNormalDistribution/set.Sigma', 'sigma')
validateattributes(epsilon, {'double'}, ...
    {'scalar', 'real', 'finite', '>', -1, '<', 1}, ...
    'EpsilonSkewNormalDistribution/set.Epsilon', 'epsilon')

end % checkparams