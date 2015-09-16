
# DPS keyboard command parser for the Space Shuttle
# Thorsten Renk 2015

var command_string = "";
var last_command = [];

var header = "";
var body = "";
var value = "";

# OPS key #########################################################

var key_ops = func {

var current_string = getprop("/fdm/jsbsim/systems/dps/command-string");

if (current_string == "")
	{header = "OPS";}
else {header = "FAIL";}

var element = "OPS ";
append(last_command, element);
current_string = current_string~element;

setprop("/fdm/jsbsim/systems/dps/command-string", current_string);
}

# ITEM key #########################################################

var key_item = func {

var current_string = getprop("/fdm/jsbsim/systems/dps/command-string");

if (current_string == "")
	{header = "ITEM";}
else {header = "FAIL";}

var element = "ITEM ";
append(last_command, element);
current_string = current_string~element;

setprop("/fdm/jsbsim/systems/dps/command-string", current_string);
}

# SPEC key #########################################################

var key_spec = func {

var current_string = getprop("/fdm/jsbsim/systems/dps/command-string");

if (current_string == "")
	{header = "SPEC";}
else {header = "FAIL";}

var element = "SPEC ";
append(last_command, element);
current_string = current_string~element;

setprop("/fdm/jsbsim/systems/dps/command-string", current_string);
}

# all symbol keys #########################################################

var key_symbol = func  (symbol) {

var current_string = getprop("/fdm/jsbsim/systems/dps/command-string");

append(last_command, symbol);
current_string = current_string~symbol;

if ((header == "OPS") or (header == "SPEC") or (header == "ITEM"))
	{
	body = body~symbol;
	}

setprop("/fdm/jsbsim/systems/dps/command-string", current_string);
}



# CLEAR key #######################################################

var key_clear = func {

var n = size(last_command);

if (n==0) {return;}

var current_string = "";

for (var i = 0; i < (n-1); i=i+1)
	{
	current_string = current_string~last_command[i];
	}
setsize(last_command,n-1);

setprop("/fdm/jsbsim/systems/dps/command-string", current_string);
}

# MSG RESET key #######################################################

var key_msg_reset = func {


setprop("/fdm/jsbsim/systems/dps/error-string", "");
}

# FAULT SUMM key #######################################################

var key_fault_summ = func {

SpaceShuttle.PFD.selectPage(p_dps_fault);

}

# PRO key #######################################################

var key_pro = func {

var current_string = getprop("/fdm/jsbsim/systems/dps/command-string");

var element = " PRO";
append(last_command, element);
current_string = current_string~element;

setprop("/fdm/jsbsim/systems/dps/command-string", current_string);


command_parse();
}

# EXEC key #######################################################

var key_exec = func {

var current_string = getprop("/fdm/jsbsim/systems/dps/command-string");

var element = " EXEC";
append(last_command, element);
current_string = current_string~element;

setprop("/fdm/jsbsim/systems/dps/command-string", current_string);


command_parse();
}


#####################################################################
# The command parser
#####################################################################

var command_parse = func {

var dps_display_flag = getprop("/fdm/jsbsim/systems/dps/dps-page-flag");

if (dps_display_flag == 0)
	{
	setprop("/fdm/jsbsim/systems/dps/command-string", "");
	return;
	}

var current_string = getprop("/fdm/jsbsim/systems/dps/command-string");

var valid_flag = 0;


if (header == "OPS")
	{
	var major_mode = int(body);
	print ("Switching to major_mode ", major_mode);
	var current_ops = getprop("/fdm/jsbsim/systems/dps/ops");

	if (major_mode == 101)
		{
		setprop("/fdm/jsbsim/systems/dps/ops", 1);
		setprop("/fdm/jsbsim/systems/dps/major-mode", 101);
		SpaceShuttle.PFD.selectPage(p_ascent);
		valid_flag = 1;
		}
	else if ((major_mode == 102) and (current_ops == 1))
		{
		setprop("/fdm/jsbsim/systems/dps/major-mode", 102);
		SpaceShuttle.PFD.selectPage(p_ascent);
		valid_flag = 1;
		}
	else if ((major_mode == 103) and (current_ops == 1))
		{
		setprop("/fdm/jsbsim/systems/dps/major-mode", 103);
		SpaceShuttle.PFD.selectPage(p_ascent);
		valid_flag = 1;
		}
	else if ((major_mode == 104) and (current_ops == 1))
		{
		setprop("/fdm/jsbsim/systems/dps/major-mode", 104);
		SpaceShuttle.PFD.selectPage(p_dps_mnvr);
		valid_flag = 1;
		}
	else if ((major_mode == 105) and (current_ops == 1))
		{
		setprop("/fdm/jsbsim/systems/dps/major-mode", 105);
		SpaceShuttle.PFD.selectPage(p_dps_mnvr);
		valid_flag = 1;
		}
	else if ((major_mode == 106) and (current_ops == 1))
		{
		setprop("/fdm/jsbsim/systems/dps/major-mode", 106);
		SpaceShuttle.PFD.selectPage(p_dps_mnvr);
		valid_flag = 1;
		}
	if (major_mode == 201)
		{
		setprop("/fdm/jsbsim/systems/dps/ops", 2);
		setprop("/fdm/jsbsim/systems/dps/major-mode", 201);
		SpaceShuttle.PFD.selectPage(p_dps_univ_ptg);
		valid_flag = 1;
		}
	else if ((major_mode == 202) and (current_ops == 2))
		{
		setprop("/fdm/jsbsim/systems/dps/major-mode", 202);
		SpaceShuttle.PFD.selectPage(p_dps_mnvr);
		valid_flag = 1;
		}
	}

if (header == "ITEM")
	{
	var major_mode = getprop("/fdm/jsbsim/systems/dps/major-mode");

	var item = int(body);
	var item_value = num(value);


	if (major_mode == 201)
		{
		if (item == 18)
			{setprop("/fdm/jsbsim/systems/ap/up-mnvr-flag", 1); valid_flag = 1;}
		else if (item == 19)
			{setprop("/fdm/jsbsim/systems/ap/up-mnvr-flag", 2); valid_flag = 1;}
		else if (item == 20)
			{setprop("/fdm/jsbsim/systems/ap/up-mnvr-flag", 3); valid_flag = 1;}
		else if (item == 21)
			{setprop("/fdm/jsbsim/systems/ap/up-mnvr-flag", 0); valid_flag = 1;}

		}
	
	}



if (current_string == "SPEC 99 PRO")
	{
	SpaceShuttle.PFD.selectPage(p_dps_fault);
	valid_flag = 1;
	}

if (valid_flag == 0)
	{
	setprop("/fdm/jsbsim/systems/dps/error-string", "ILLEGAL ENTRY");
	header = "";
	body = "";
	value = "";
	}
else 
	{
	setprop("/fdm/jsbsim/systems/dps/error-string", "");
	setprop("/fdm/jsbsim/systems/dps/command-string", "");
	header = "";
	body = "";
	value = "";
	}




}
