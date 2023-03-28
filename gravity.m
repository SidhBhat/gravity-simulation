#clear memory
clear all;
pause on;

##----------Start Configuration----------##
### Define environment ###
# The gravitaional constant
global G = 0.4;

# define the initial parameters of the bodies
# here you can define as many bodies as you like in similar fasion
global bodies;              # don't touch this line

bodies(1).m = 1;       # mass
bodies(1).x = [0.746156, 0];  # position
bodies(1).v = [0, 0.324677];  # velocity

bodies(2).m = 1;       # mass
bodies(2).x = [-0.373078, 0.238313];  # position
bodies(2).v = [0.764226, -0.162399];  # velocity

bodies(3).m = 1;       # mass
bodies(3).x = [-0.373078, -0.238313];  # position
bodies(3).v = [-0.764226, -0.162399];  # velocity

### Simulation Parameters
# value of delta t
global delta_t = 0.00001;
# simulation time
T              = 2
;

### plot parameters
# axis limits
global lim         = 1;
# normal markersize (size of least massive body)
global marker_size = 15
#trace marker size  (size of the path trace)
global trace_size  = 3;
# frames per unit time
fp_unit            = 10;

##----------End Configuration----------##

#### ----- Start Script ------#####
#dont work for single body systems
if(!isvector(bodies))
		return;
endif

#the number of bodies
global n = size(bodies)(2);
# Set initial acceleration zero
for k = 1:size(bodies)(2);
	bodies(k).a = [0,0];
endfor

# the least mass among all bodies
global least_mass = bodies(1).m;
# Compute least mass
for k = 1:size(bodies)(2);
   if(least_mass > bodies(k).m)
       least_mass = bodies(k).m;
   endif
endfor
# compute relative radius
for k = 1:size(bodies)(2);
   bodies(k).r_r = (bodies(k).m / least_mass)^(1/3);
endfor

#Compute the acceleration on each body
function get_acc()
	global bodies;
	global delta_t;
	global n;
	global G;

	for k1 = 1:n;
		bodies(k1).a = [0, 0];
		for k2 = 1:n;
			if (k2 != k1)
				a = G * bodies(k2).m / norm(bodies(k2).x - bodies(k1).x)^3;
				bodies(k1).a += a * (bodies(k2).x - bodies(k1).x);
			endif
		endfor
	endfor

endfunction

#calculate the next position of the body in a small delta time
function update_bodies()
	global bodies;
	global delta_t;
	global n;

	for k = 1:n;
		bodies(k).x += bodies(k).v * delta_t + bodies(k).a * delta_t^2 / 2;
		bodies(k).v += bodies(k).a * delta_t;
	endfor
endfunction

## function to plot the bodies
# plot_v1 clears the previous plot
function plot_bodies_v1()
	global bodies;
	global delta_t;
	global least_mass;
	global n;
	global marker_size;
	global lim;

	n = size(bodies)(2);

	cla;
	hold "on";
	for k = 1:n;
		plot(bodies(k).x(1), bodies(k).x(2), ".k", "markersize", bodies(k).r_r * marker_size);
	endfor
	axis([-lim, lim, -lim, lim], "equal");
	grid("on");
endfunction
# external variables for plot_v2
global trace_cnt = 0;       # counter
global trace_lim = 10000;   # max number of points to plot before reset
# plot_v2 keeps the previous plot
function plot_bodies_v2()
	global bodies;
	global delta_t;
	global n;
	global trace_size;
	global lim;

	global trace_cnt;
	global trace_lim;

	hold "on";
	trace_cnt++;
	if(trace_cnt >= trace_lim)
		trace_cnt = 0;
		hold "off";
	endif

	for k = 1:n;
		plot(bodies(k).x(1), bodies(k).x(2), "*k", "markersize", trace_size);
	endfor
	axis([-lim, lim, -lim, lim], "equal");
	grid("on");
endfunction


# Initial and final values of t
t1     = 0.0;
t2     = T;
# number of delta t between frames
tp = 1 / fp_unit / delta_t;
# counter
cnt = 0;

## Set up plot
clf;
subplot(1,2,1);
cla;
subplot(1,2,2);
cla;
###--- Start simulation --- ###

tstart2 = clock();
tstart  = clock();
for t = t1:delta_t:t2;
	if(!mod(cnt,tp))
		subplot(1,2,1);
		plot_bodies_v1();
		title(sprintf("t = %0.2f",t));
     	subplot(1,2,2);
		plot_bodies_v2();
		title(sprintf("t = %0.2f",t));

		exe_time = etime(clock(), tstart);
		#printf("t = %f\n",exe_time);
		pause(delta_t * tp - exe_time);
		tstart = clock();
	endif
	cnt++;

	get_acc();
	update_bodies();
endfor
exe_time = etime(clock(), tstart2);
printf("t = %f\n",exe_time);
