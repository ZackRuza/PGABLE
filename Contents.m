%   PGABLE is a Matlab toolkit for geometric algebra.
%
%   Version V2.2.1
%
%   Most of the core code was written by Zachary Leger (zcjleger@uwaterloo.ca).
%   The tutorial was largely written by Stephen Mann (smann@uwaterloo.ca).
%
%   GA is a parent class of all geometric algebra models.
%   The models OGA, PGA, and CGA are currently implemented as child classes of GA.
%   Type help(OGA) and help(PGA) for information about each model.
%   To switch between OGA and PGA, run GA.model(OGA), GA.model(PGA), or
%   GA.model(CGA).
%   You may want to run GAdemo for a brief introduction to OGA, and
%   PGAdemo for a brief introduction to PGA.
%
%   There are general settings stored in GA which apply to all GA models, 
%   and there are settings stored for each model of GA.
%   To access each of these settings, run "GA.settings", "OGA.settings", or
%   "PGA.settings".
%
%   See https://cs.uwaterloo.ca/~smann/PGABLE/ for a tutorial on OGA and PGA.
