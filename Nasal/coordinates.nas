

# coordinate transformation routines for the Space Shuttle
# Thorsten Renk 2015

var tracking_loop_flag = 0;

var trackingCoord = geo.Coord.new() ;


var timeObj = {
	new: func(day, hour, min, sec) {
	        var t = { parents: [timeObj] };
		t.day = day;
		t.hour = hour;
		t.min = min;
		t.sec = sec;
	        return t;
	},
	#subtract: func(t2) {
	#	var t.sec = t.sec - t2.sec;
	#	if (t.sec < 0) {t.sec = 60 - t.sec; t.min = t.min -1;}	
	#},
};


var update_LVLH_to_ECI = func {

var shuttleWCoord = geo.aircraft_position() ;
var shuttleCoord = geo.Coord.new() ;

var x = getprop("/fdm/jsbsim/position/eci-x-ft") * 0.3048;
var y = getprop("/fdm/jsbsim/position/eci-y-ft") * 0.3048;
var z = getprop("/fdm/jsbsim/position/eci-z-ft") * 0.3048;

shuttleCoord.set_xyz(x,y,z);

var D_lon = shuttleWCoord.lon() - shuttleCoord.lon();

#print("D_lon: ", D_lon);
setprop("/fdm/jsbsim/systems/pointing/inertial/delta-lon-rad", -D_lon * math.pi/180.0);

}



var get_pitch_yaw = func (vec) {

var norm = math.sqrt(vec[0] * vec[0] + vec[1] * vec[1] + vec[2]* vec[2]);

vec[0] = vec[0]/norm;
vec[1] = vec[1]/norm;
vec[2] = vec[2]/norm;

var pitch = math.asin(vec[2]);

var norm2 = math.sqrt(vec[0] * vec[0] + vec[1] * vec[1]);
var yaw_pos = math.acos(vec[0]/norm2);

var yaw = yaw_pos;

if (vec[1] < 0.0) {yaw = math.pi - yaw_pos;}

print("p: ", pitch * 180/math.pi, "y: ", yaw * 180/math.pi);

return [pitch, yaw];

}

var create_mnvr_vector = func {


var pitch = getprop("/fdm/jsbsim/systems/ap/ops201/mnvr-pitch");
var yaw = getprop("/fdm/jsbsim/systems/ap/ops201/mnvr-yaw");
var roll = getprop("/fdm/jsbsim/systems/ap/ops201/mnvr-roll");

var vec = [1.0, 0.0, 0.0];
var inertial_vec = SpaceShuttle.orientTaitBryan (vec, yaw, pitch, roll);

setprop("/fdm/jsbsim/systems/ap/track/target-vector[0]", inertial_vec[0]);
setprop("/fdm/jsbsim/systems/ap/track/target-vector[1]", inertial_vec[1]);
setprop("/fdm/jsbsim/systems/ap/track/target-vector[2]", inertial_vec[2]);

vec = [0.0, 0.0, 1.0];
inertial_vec = SpaceShuttle.orientTaitBryan (vec, yaw, pitch, roll);

setprop("/fdm/jsbsim/systems/ap/track/target-sec[0]", inertial_vec[0]);
setprop("/fdm/jsbsim/systems/ap/track/target-sec[1]", inertial_vec[1]);
setprop("/fdm/jsbsim/systems/ap/track/target-sec[2]", inertial_vec[2]);
}


var create_trk_vector = func {

var lat = getprop("/fdm/jsbsim/systems/ap/ops201/trk-lat");
var lon = getprop("/fdm/jsbsim/systems/ap/ops201/trk-lon");
var alt = getprop("/fdm/jsbsim/systems/ap/ops201/trk-alt");

var target_id = getprop("/fdm/jsbsim/systems/ap/ops201/tgt-id");

if (target_id == 2) # we track the center of Earth, omicron zero point is celestial north pole
	{
	
	settimer(func {tracking_loop_flag = 1; tracking_loop_earth();}, 0.2);

	setprop("/fdm/jsbsim/systems/ap/track/target-sec[0]", 0);
	setprop("/fdm/jsbsim/systems/ap/track/target-sec[1]", 0);
	setprop("/fdm/jsbsim/systems/ap/track/target-sec[2]", 1);
	}
if (target_id == 3) # we track an earth-relative target specified by items 11 to 13
	{
	var lat =  getprop("/fdm/jsbsim/systems/ap/ops201/trk-lat");
 	var lon =  getprop("/fdm/jsbsim/systems/ap/ops201/trk-lon");
	var alt =  getprop("/fdm/jsbsim/systems/ap/ops201/trk-alt");

	trackingCoord.set_latlon(lat, lon, alt * 0.3048);
	
	settimer(func {tracking_loop_flag = 1; tracking_loop_earth_tgt();}, 0.2);

	setprop("/fdm/jsbsim/systems/ap/track/target-sec[0]", 0);
	setprop("/fdm/jsbsim/systems/ap/track/target-sec[1]", 0);
	setprop("/fdm/jsbsim/systems/ap/track/target-sec[2]", 1);
	}
if (target_id == 4) # we track the Sun, omicron zero point is the celestial north pole
	{
	settimer(func {tracking_loop_flag = 1; tracking_loop_sun();}, 0.2);

	setprop("/fdm/jsbsim/systems/ap/track/target-sec[0]", 0);
	setprop("/fdm/jsbsim/systems/ap/track/target-sec[1]", 0);
	setprop("/fdm/jsbsim/systems/ap/track/target-sec[2]", 1);

	}

}


var create_oms_burn_vector = func {

var dvx = getprop("/fdm/jsbsim/systems/ap/oms-plan/dvx");
var dvy = getprop("/fdm/jsbsim/systems/ap/oms-plan/dvy");
var dvz = getprop("/fdm/jsbsim/systems/ap/oms-plan/dvz");



var dvtot = math.sqrt(dvx*dvx + dvy*dvy + dvz * dvz);

var tx = dvx/dvtot;
var ty = dvy/dvtot;
var tz = dvz/dvtot;

var prograde = [getprop("/fdm/jsbsim/systems/pointing/inertial/prograde[0]"),getprop("/fdm/jsbsim/systems/pointing/inertial/prograde[1]"), getprop("/fdm/jsbsim/systems/pointing/inertial/prograde[2]")];

var radial = [getprop("/fdm/jsbsim/systems/pointing/inertial/radial[0]"),getprop("/fdm/jsbsim/systems/pointing/inertial/radial[1]"), getprop("/fdm/jsbsim/systems/pointing/inertial/radial[2]")];

var normal = [getprop("/fdm/jsbsim/systems/pointing/inertial/normal[0]"),getprop("/fdm/jsbsim/systems/pointing/inertial/prograde[1]"), getprop("/fdm/jsbsim/systems/pointing/inertial/normal[2]")];

var tgt0 = tx * prograde[0] + ty * normal[0] + tz * radial[0];
var tgt1 = tx * prograde[1] + ty * normal[1] + tz * radial[1];
var tgt2 = tx * prograde[2] + ty * normal[2] + tz * radial[2];

setprop("/fdm/jsbsim/systems/ap/track/target-vector[0]", tgt0);
setprop("/fdm/jsbsim/systems/ap/track/target-vector[1]", tgt1);
setprop("/fdm/jsbsim/systems/ap/track/target-vector[2]", tgt2);

var orientation = get_pitch_yaw([tgt0, tgt1, tgt2]);

var sec = SpaceShuttle.orientTaitBryan(radial, orientation[1], orientation[0], 180.0);

setprop("/fdm/jsbsim/systems/ap/track/target-sec[0]", sec[0]);
setprop("/fdm/jsbsim/systems/ap/track/target-sec[1]", sec[1]);
setprop("/fdm/jsbsim/systems/ap/track/target-sec[2]", sec[2]);
}


var tracking_loop_earth = func {

if (tracking_loop_flag == 0) {return;}

print("Tracking..");

setprop("/fdm/jsbsim/systems/ap/track/target-vector[0]", -getprop("/fdm/jsbsim/systems/pointing/inertial/radial[0]"));
setprop("/fdm/jsbsim/systems/ap/track/target-vector[1]", -getprop("/fdm/jsbsim/systems/pointing/inertial/radial[1]"));
setprop("/fdm/jsbsim/systems/ap/track/target-vector[2]", -getprop("/fdm/jsbsim/systems/pointing/inertial/radial[2]"));


settimer(tracking_loop_earth, 0.0);
}


var tracking_loop_earth_tgt = func {

if (tracking_loop_flag == 0) {return;}

print("Tracking..");

# move the tracking coords to the inertial system

var shuttleWCoord = geo.aircraft_position() ;
var shuttleCoord = geo.Coord.new() ;

var x = getprop("/fdm/jsbsim/position/eci-x-ft") * 0.3048;
var y = getprop("/fdm/jsbsim/position/eci-y-ft") * 0.3048;
var z = getprop("/fdm/jsbsim/position/eci-z-ft") * 0.3048;

shuttleCoord.set_xyz(x,y,z);

var D_lon = shuttleWCoord.lon() - shuttleCoord.lon();

var trackCoord_tmp = geo.Coord.new();
trackCoord_tmp.set_xyz(trackingCoord.x(), trackingCoord.y(), trackingCoord.z());

trackCoord_tmp.set_lon(trackCoord_tmp.lon() + D_lon);

# the tracking vector is now a normalized coordinate difference

var track_x = trackCoord_tmp.x();
var track_y = trackCoord_tmp.y();
var track_z = trackCoord_tmp.z();

var track_vector = [track_x - x, track_y - y, track_z - z ];

track_norm = math.sqrt(track_vector[0] * track_vector[0] + track_vector[1] * track_vector[1] + track_vector[2] * track_vector[2]);

setprop("/fdm/jsbsim/systems/ap/track/target-vector[0]", track_vector[0]/track_norm);
setprop("/fdm/jsbsim/systems/ap/track/target-vector[1]", track_vector[1]/track_norm );
setprop("/fdm/jsbsim/systems/ap/track/target-vector[2]", track_vector[2]/track_norm );

settimer(tracking_loop_earth_tgt, 0.0);
}


var tracking_loop_sun = func {

if (tracking_loop_flag == 0) {return;}

print("Tracking..");

setprop("/fdm/jsbsim/systems/ap/track/target-vector[0]", getprop("/fdm/jsbsim/systems/pointing/inertial/sun[0]"));
setprop("/fdm/jsbsim/systems/ap/track/target-vector[1]", getprop("/fdm/jsbsim/systems/pointing/inertial/sun[1]"));
setprop("/fdm/jsbsim/systems/ap/track/target-vector[2]", getprop("/fdm/jsbsim/systems/pointing/inertial/sun[2]"));


settimer(tracking_loop_sun, 0.0);
}
