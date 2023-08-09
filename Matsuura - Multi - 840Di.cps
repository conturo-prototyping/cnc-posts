/**

  Matsuura Siemens SINUMERIK 840Di post processor configuration.

  $Revision: 37 $
  $Date: 2023-08-09 $

  Conturo Prototyping Version Info

  1 - 02/08/2022
    -initial setup and testing

  2 - 12/09/2022
    -setup coolant codes based on M code list
    -setup table clamp codes based on M code list (using M131 and M132)
  
  3 - 4/14/2023 - Billy
    - added M110 at the end of every tool call
    - disabled workpiece because the machine didn't like the format
    - teporarily disabled the output for Cycle800 because the machine didn't like the format
  4
    - teporarily remove "D" section of tool call
  5
    - forced decemal on all feeds
  6
    - force G17-19 on all circular movements --- irrelevent since using CIP now
  7
    - bring fanuc basic linear and circular section into this
    - remove all modal commands between lines
  8
    - fuck 2d arcs, just moving to 3d arcs using CIP  (didn't work either)
  9
    - moved the coolant command to right after the spindle starts because it's taking a lot of time for coolant to come on (band-aid fix for now, system has leaks)
    - removed tool lenght offset warning
  10
    - max spindle speed set to 16500rpm
    - added spindle speed ramp-up while getting into postion M203/M204
  
  11 - 4/17/2023 - Billy
     - added variable to useradius and useCIP to try to figure that out
     - rarange circular argument orders to match 840Di documentation
  12
     - implemented spindle precall and tool change precall
     - reference pallet at end of program to prep for pallet change "G91 G30 X0 Y0 P2'
     - added CIP and radius options to post menu
     - added expert options to post menu
     - commented out fast spindle ramp up M203 and M204 (control didn't like it)
     - added fast tool change M229
  13
     - commented out fast tool change M229 (control didn't like it)
  14
     - minimum circular radius set for .01 mm to .02 because we keep running into issues with this
  15
     - minimum circular radius set back to .01 mm
     - added CIP switch for all Z axis arcs under 100 inches, variable added to adjust this
  16
     - started adding Gxx drilling cycles from Siemens Yaskawa manual and made it an option  
     - linearized all z axis arcs
  17
     - continued drill developement
  18
     - and more drilling stuff
  19
     - siemens mode added to modal group
     - switch between siemens and ISO implemented into all MCALL drill cycles
  20
     - rotary axis brakes added to modal group to reduce lock and unlock amounts
  21 - 4/18/2023
     - cleanup circular section and commented properties to control this
  22
     - remove D0 and axis clamp stuff for now
  23
     - back to axis clamp stuff
  24
     - converted to siemens IS post from Fusion Library 44060
     - copied most things from last version but circular stuff. Gonna start fresh on that
  25
     - added options for arc type IJK, CT, and RAD
  26
    - removed tool offset call D1

  27 - 5/1/2023 Billy 
    - removed AC prefix/suffix from CIP arcs
    - moved plane call into IJK line instead of all arcs
    - revised arc logit to avoid reseting plane mid program
    - changed pallet program logic and call to M98 Pxxx (dropdown added to properties and check box removed)

  28
    - arc-turn set to false

  29
    - added x y z resets to all CIPs

  30
    - removed extended tapping arguments - - not compatable with 840Di
    - force decimal on all xyz outputs
    - added preprocessing buffer control with FIFO

  31
    -extended offset changed to correct format for 840Di (G54Pxx)
  32
    -add tool H calls after indexing
    -moved to xyz safe zone before indexing (hardcoded for now)
    -enabled TRAORI but doesn't seem to work yet
    -M0s before all full 5 axis operations
    -updated smoothing settings >see google drive doc "Matsuura 840Di HON parameters"
  
  33
    -revised pallet swaping setting logic
  
  34
    -Added TSC plus flood logic
    -TSC position modifications (can't start or stop TSC after the spindle in rotating)
    -XY prepositioning at beginning of program removed
    -Added dwells for TSC ramp up/down (would like to make a little more efficiant using machine counters but going to have to experement more with this in person, aka be able to move to position while the dwell is happening)
  
  35
    -Spindle stop at end of every tool path with a change in the next

  36
    -added all the spindle and coolant shutoffs to last section
    -commented out all TSC dwells because Justin didn't think it was necessary
  
  37 - Billy
    -changed pallet logic to output a master program and rename this as a subprogram
    -elevated to non-test version for justin even though there are some things to workout still
    -cleaned up unused post parameters
    


  



*/

description = "CP - Matsuura - Multi - Siemens 840D";
vendor = "Matsuura";
vendorUrl = "https://www.matsuura.co.jp/english/";
legal = "Conturo Prototyping";
certificationLevel = 2;
minimumRevision = 45821;

longDescription = "Matsuura 840Di post built from generic 840D IS post by Conturo Prototyping. Note that the post will use D1 always for the tool length compensation as this is how most users work.";


setCodePage("ascii");

capabilities = CAPABILITY_MILLING | CAPABILITY_MACHINE_SIMULATION;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.25, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
var useArcTurn = false;
maximumCircularSweep = toRad(useArcTurn ? (999 * 360) : 90); // max revolutions
allowHelicalMoves = true;
allowedCircularPlanes = undefined; // undefined = allow any circular motion, 0 = don't allow any circular motion

var tv = false; //test version
var notes = "-- TRAORI isn't working yet. See Google drive doc for smoothing settings"; //test version notes

// user-defined properties
properties = {
  writeMachine: {
    title      : "Write machine",
    description: "Output the machine settings in the header of the code.",
    group      : "formats",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  writeTools: {
    title      : "Write tool list",
    description: "Output a tool list in the header of the code.",
    group      : "formats",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  preloadTool: {
    title      : "Preload tool",
    description: "Preloads the next tool at a tool change (if any).",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  showSequenceNumbers: {
    title      : "Use sequence numbers",
    description: "'Yes' outputs sequence numbers on each block, 'Only on tool change' outputs sequence numbers on tool change blocks only, and 'No' disables the output of sequence numbers.",
    group      : "formats",
    type       : "enum",
    values     : [
      {title:"Yes", id:"true"},
      {title:"No", id:"false"},
      {title:"Only on tool change", id:"toolChange"}
    ],
    value: "true",
    scope: "post"
  },
  sequenceNumberStart: {
    title      : "Start sequence number",
    description: "The number at which to start the sequence numbers.",
    group      : "formats",
    type       : "integer",
    value      : 10,
    scope      : "post"
  },
  sequenceNumberIncrement: {
    title      : "Sequence number increment",
    description: "The amount by which the sequence number is incremented by in each block.",
    group      : "formats",
    type       : "integer",
    value      : 1,
    scope      : "post"
  },
  optionalStop: {
    title      : "Optional stop",
    description: "Outputs optional stop code during when necessary in the code.",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  useShortestDirection: {
    title      : "Use shortest direction",
    description: "Specifies that the shortest angular direction should be used.",
    group      : "multiAxis",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  useParametricFeed: {
    title      : "Parametric feed",
    description: "Specifies the feed value that should be output using a Q value.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  showNotes: {
    title      : "Show notes",
    description: "Writes operation notes as comments in the outputted code.",
    group      : "formats",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  useSmoothing: {
    title      : "Use NC Smoothing", //smoothing setup to use matsuura HONR
    description: "Enable to use IPC smoothing.",
    group      : "preferences",
    type       : "enum",
    values     : [
      {title:"Off", id:"-1"},
      {title:"Automatic", id:"9999"}//,
      //{title:"Level 1", id:"1"},
      //{title:"Level 2", id:"2"},
      //{title:"Level 3", id:"3"}
    ],
    value: "9999",
    scope: "post"
  },
  toolAsName: {
    title      : "Tool as name",
    description: "If enabled, the tool will be called with the tool description rather than the tool number.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  useSubroutines: {
    title      : "Use subroutines",
    description: "Select your desired subroutine option. 'All Operations' creates subroutines per each operation, 'Cycles' creates subroutines for cycle operations on same holes, and 'Patterns' creates subroutines for patterned operations.",
    group      : "preferences",
    type       : "enum",
    values     : [
      {title:"No", id:"none"},
      {title:"All Operations", id:"allOperations"},
      {title:"Cycles", id:"cycles"},
      {title:"Patterns", id:"patterns"}
    ],
    value: "none",
    scope: "post"
  },
  useFilesForSubprograms: {
    title      : "Use files for subroutines",
    description: "If enabled, subroutines will be saved as individual files.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  cycle800Mode: {
    title      : "CYCLE800 mode",
    description: "Specifies the mode to use for CYCLE800.",
    group      : "multiAxis",
    type       : "enum",
    values     : [
      {id:"0", title:"0 (OFF)"},
      {id:"39", title:"39 (CAB)"},
      {id:"27", title:"27 (CBA)"},
      {id:"57", title:"57 (ABC)"},
      {id:"45", title:"45 (ACB)"},
      {id:"30", title:"30 (BCA)"},
      {id:"54", title:"54 (BAC)"},
      {id:"192", title:"192 (Rotary angles)"}
    ],
    value: "57",
    scope: "post"
  },
  //cycle800SwivelDataRecord: {
  //  title      : "CYCLE800 Swivel Data Record",
  //  description: "Specifies the label to use for the Swivel Data Record for CYCLE800.",
  //  group      : "multiAxis",
  //  type       : "string",
  //  value      : "K01",
  //  scope      : "post"
  //},
  useExtendedCycles: {
    title      : "Extended cycles",
    description: "Specifies whether the extended cycles should be used. 2008 840Di should set this to false.", //will hardcode eventually
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  singleLineProbing: {
    title      : "Single line probing",
    description: "If enabled, probing will be output in a single cycle call line.",
    group      : "probing",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  safePositionMethod: {
    title      : "Safe Retracts",
    description: "Select your desired retract option. 'Clearance Height' retracts to the operation clearance height.",
    group      : "homePositions",
    type       : "enum",
    values     : [
      // {title: "G28", id: "G28"},
      {title:"G53", id:"G53"},
      {title:"Clearance Height", id:"clearanceHeight"},
      {title:"SUPA", id:"SUPA"}
    ],
    value: "SUPA",
    scope: "post"
  },
  useParkPosition: {
    title      : "Ready pallet at end",
    description: "Specifies that the machine moves the pallet to the waiting position at the end of the program.",
    group      : "homePositions",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  isPalletProgram: {
    title      : "Automatic pallet changing",
    description: "Set program for automatic pallet changing from a master program.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  }
};

// wcs definiton
wcsDefinitions = {
  useZeroOffset: false,
  wcs          : [
    {name:"Standard", format:"G", range:[54, 59]},
    {name:"Extended", format:"G54P", range:[1, 93]}
  ]
};

var singleLineCoolant = false; // specifies to output multiple coolant codes in one line rather than in separate lines
// samples:
// {id: COOLANT_THROUGH_TOOL, on: 88, off: 89}
// {id: COOLANT_THROUGH_TOOL, on: [8, 88], off: [9, 89]}
// {id: COOLANT_THROUGH_TOOL, on: "M88 P3 (myComment)", off: "M89"}
var coolants = [
  {id:COOLANT_FLOOD, on:8},
  {id:COOLANT_MIST},
  {id:COOLANT_THROUGH_TOOL, on:50}, //oil hole coolant start/TSC start/ HPC start (option)
  {id:COOLANT_AIR, on:25, off:27}, //chip air blow per manual
  {id:COOLANT_AIR_THROUGH_TOOL, on:52, off:53}, //spindle air blow per manual
  {id:COOLANT_SUCTION},
  {id:COOLANT_FLOOD_MIST},
  {id:COOLANT_FLOOD_THROUGH_TOOL, on:[8, 50]},
  {id:COOLANT_OFF, off:9}
];

extension = "mpf";

var chipTransport = "auto" // auto - pass - on //options: auto=automatic(default)  pass=off but passthrough accepted  on=runs through the entire program

var gFormat = createFormat({prefix:"G", decimals:0});
var mFormat = createFormat({prefix:"M", decimals:0});
var hFormat = createFormat({prefix:"H", decimals:0});
var dFormat = createFormat({prefix:"D", decimals:0});
var nFormat = createFormat({prefix:"N", decimals:0});

var xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var abcFormat = createFormat({decimals:3, scale:DEG});
var abcDirectFormat = createFormat({decimals:3, scale:DEG, prefix:"=DC(", suffix:")"});
var abc3Format = createFormat({decimals:6});
var feedFormat = createFormat({decimals:(unit == MM ? 1 : 2), forceDecimal:true});
var inverseTimeFormat = createFormat({decimals:3, forceDecimal:true});
var toolFormat = createFormat({decimals:0});
var toolProbeFormat = createFormat({decimals:0, zeropad:true, width:3});
var rpmFormat = createFormat({decimals:0});
var secFormat = createFormat({decimals:3});
var taperFormat = createFormat({decimals:1, scale:DEG});
var arFormat = createFormat({decimals:3, scale:DEG});
var integerFormat = createFormat({decimals:0});
var rFormat = xyzFormat; // radius
var cipFormat = createFormat({decimals:(unit == MM ? 3 : 4)}); // CIP , suffix:")"

var xOutput = createVariable({prefix:"X"}, xyzFormat);
var yOutput = createVariable({prefix:"Y"}, xyzFormat);
var zOutput = createVariable({onchange:function () {retracted = false;}, prefix:"Z"}, xyzFormat);
var a3Output = createVariable({prefix:"A3=", force:true}, abc3Format);
var b3Output = createVariable({prefix:"B3=", force:true}, abc3Format);
var c3Output = createVariable({prefix:"C3=", force:true}, abc3Format);
var aOutput = createVariable({prefix:"A"}, abcFormat);
var bOutput = createVariable({prefix:"B"}, abcFormat);
var cOutput = createVariable({prefix:"C"}, abcFormat);
var feedOutput = createVariable({prefix:"F"}, feedFormat);
var inverseTimeOutput = createVariable({prefix:"F", force:true}, inverseTimeFormat);
var sOutput = createVariable({prefix:"S", force:true}, rpmFormat);
var dOutput = createVariable({}, dFormat);
var cipiOutput = createVariable({prefix:"I1=", force:true}, cipFormat); //CIPs AC(
var cipjOutput = createVariable({prefix:"J1=", force:true}, cipFormat);  //AC(
var cipkOutput = createVariable({prefix:"K1=", force:true}, cipFormat); //AC(

// circular output
var iOutput = createReferenceVariable({prefix:"I", force:true}, xyzFormat);
var jOutput = createReferenceVariable({prefix:"J", force:true}, xyzFormat);
var kOutput = createReferenceVariable({prefix:"K", force:true}, xyzFormat);

var gMotionModal = createModal({force:false}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal({onchange:function () {gMotionModal.reset();}}, gFormat); // modal group 2 // G17-19
var gAbsIncModal = createModal({}, gFormat); // modal group 3 // G90-91
var gFeedModeModal = createModal({}, gFormat); // modal group 5 // G94-95
var gUnitModal = createModal({}, gFormat); // modal group 6 // G70-71
var gCycleModal = createModal({}, gFormat); // modal group 9 // G81, ...
var gRetractModal = createModal({}, gFormat);// modal group 10 // G98-99
var gModeModal = createModal({}, gFormat); //siemens mode or ISO mode
var cAxisClampModal = createModal({}, mFormat);
var aAxisClampModal = createModal({}, mFormat);
var rotAxisClampModal = createModal({}, mFormat);

/* used for cycle832 smoothing
var settings = {
  smoothing: {
    roughing              : 3, // roughing level for smoothing in automatic mode
    semi                  : 2, // semi-roughing level for smoothing in automatic mode
    semifinishing         : 2, // semi-finishing level for smoothing in automatic mode
    finishing             : 1, // finishing level for smoothing in automatic mode
    thresholdRoughing     : toPreciseUnit(0.2, MM), // operations with stock/tolerance above that threshold will use roughing level in automatic mode
    thresholdFinishing    : toPreciseUnit(0.05, MM), // operations with stock/tolerance below that threshold will use finishing level in automatic mode
    thresholdSemiFinishing: toPreciseUnit(0.1, MM), // operations with stock/tolerance above finishing and below threshold roughing that threshold will use semi finishing level in automatic mode

    differenceCriteria: "both", // options: "level", "tolerance", "both". Specifies criteria when output smoothing codes
    autoLevelCriteria : "stock", // use "stock" or "tolerance" to determine levels in automatic mode
    cancelCompensation: false // tool length compensation must be canceled prior to changing the smoothing level
  }
};
*/



// fixed settings
var firstFeedParameter = 1;
var useMultiAxisFeatures = true;
var useABCPrepositioning = false; // position ABC axes prior to CYCLE800 block, machine configuration required
var maximumLineLength = 80; // the maximum number of charaters allowed in a line
var minimumCyclePoints = 5; // minimum number of points in cycle operation to consider for subprogram
var allowIndexingWCSProbing = false; // specifies that probe WCS with tool orientation is supported

var WARNING_LENGTH_OFFSET = 1;
var WARNING_DIAMETER_OFFSET = 2;
var SUB_UNKNOWN = 0;
var SUB_PATTERN = 1;
var SUB_CYCLE = 2;

// collected state
var sequenceNumber;
var currentWorkOffset;
var forceSpindleSpeed = false;
var activeMovements; // do not use by default
var currentFeedId;
var retracted = false; // specifies that the tool has been retracted to the safe plane
var subprograms = [];
var currentPattern = -1;
var firstPattern = false;
var currentSubprogram = 0;
var lastSubprogram = 0;
var definedPatterns = new Array();
var incrementalMode = false;
var saveShowSequenceNumbers;
var cycleSubprogramIsActive = false;
var patternIsActive = false;
var lastOperationComment = "";
var incrementalSubprogram;
var subprogramExtension = "spf";
var cycleSeparator = ", ";
var lengthOffset = 0; //wasn't in old version -Billy
probeMultipleFeatures = true;

/**
  Writes the specified block.
*/
function writeBlock() {
  if (getProperty("showSequenceNumbers") == "true") {
    writeWords2("N" + sequenceNumber, arguments);
    sequenceNumber += getProperty("sequenceNumberIncrement");
  } else {
    writeWords(arguments);
  }
}

function formatComment(text) {
  return "; " + String(text);
}

/**
  Writes the specified block - used for tool changes only.
*/
function writeToolBlock() {
  var show = getProperty("showSequenceNumbers");
  setProperty("showSequenceNumbers", (show == "true" || show == "toolChange") ? "true" : "false");
  writeBlock(arguments);
  setProperty("showSequenceNumbers", show);
}

/**
  Output a comment.
*/
function writeComment(text) {
  if (getProperty("showSequenceNumbers") == "true") {
    writeWords2("N" + sequenceNumber, formatComment(text));
    sequenceNumber += getProperty("sequenceNumberIncrement");
  } else {
    writeWords(formatComment(text));
  }
}

/** Returns the CYCLE800 configuration to use for the selected mode. */
function getCycle800Config(abc) {
  var options = [];
  switch (getProperty("cycle800Mode")) {
  case "39":
    options.push(39, abc, EULER_ZXY_R);
    break;
  case "27":
    options.push(27, abc, EULER_ZYX_R);
    break;
  case "57":
    options.push(57, abc, EULER_XYZ_R);
    break;
  case "45":
    options.push(45, abc, EULER_XZY_R);
    break;
  case "30":
    options.push(30, abc, EULER_YZX_R);
    break;
  case "54":
    options.push(54, abc, EULER_YXZ_R);
    break;
  case "192":
  case "0": //to turn off cycle800
    if (!machineConfiguration.isMultiAxisConfiguration()) {
      error(localize("CYCL800 Mode 192 cannot be used without a multi-axis machine configuration."));
      return options;
    }
    var abcDirect = new Vector(0, 0, 0);
    var axes = new Array(machineConfiguration.getAxisU(), machineConfiguration.getAxisV(), machineConfiguration.getAxisW());
    for (var i = 0; i < machineConfiguration.getNumberOfAxes() - 3; ++i) {
      if (axes[i].isEnabled()) {
        abcDirect.setCoordinate(i, abc.getCoordinate(axes[i].getCoordinate()));
      }
    }
    options.push(192, abcDirect);
    break;
  default:
    error(localize("Unknown CYCLE800 mode selected."));
    return undefined;
  }
  return options;
}

// Start of machine configuration logic
var compensateToolLength = false; // add the tool length to the pivot distance for nonTCP rotary heads

// internal variables, do not change
var receivedMachineConfiguration;
var operationSupportsTCP;
var multiAxisFeedrate;

function activateMachine() {
  // disable unsupported rotary axes output
  if (!machineConfiguration.isMachineCoordinate(0) && (typeof aOutput != "undefined")) {
    aOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(1) && (typeof bOutput != "undefined")) {
    bOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(2) && (typeof cOutput != "undefined")) {
    cOutput.disable();
  }

  // setup usage of multiAxisFeatures
  useMultiAxisFeatures = getProperty("useMultiAxisFeatures") != undefined ? getProperty("useMultiAxisFeatures") :
    (typeof useMultiAxisFeatures != "undefined" ? useMultiAxisFeatures : false);
  useABCPrepositioning = getProperty("useABCPrepositioning") != undefined ? getProperty("useABCPrepositioning") :
    (typeof useABCPrepositioning != "undefined" ? useABCPrepositioning : false);

  if (!machineConfiguration.isMultiAxisConfiguration()) {
    return; // don't need to modify any settings for 3-axis machines
  }

  // save multi-axis feedrate settings from machine configuration
  var mode = machineConfiguration.getMultiAxisFeedrateMode();
  var type = mode == FEED_INVERSE_TIME ? machineConfiguration.getMultiAxisFeedrateInverseTimeUnits() :
    (mode == FEED_DPM ? machineConfiguration.getMultiAxisFeedrateDPMType() : DPM_STANDARD);
  multiAxisFeedrate = {
    mode     : mode,
    maximum  : machineConfiguration.getMultiAxisFeedrateMaximum(),
    type     : type,
    tolerance: mode == FEED_DPM ? machineConfiguration.getMultiAxisFeedrateOutputTolerance() : 0,
    bpwRatio : mode == FEED_DPM ? machineConfiguration.getMultiAxisFeedrateBpwRatio() : 1
  };

  // setup of retract/reconfigure  TAG: Only needed until post kernel supports these machine config settings
  if (receivedMachineConfiguration && machineConfiguration.performRewinds()) {
    safeRetractDistance = machineConfiguration.getSafeRetractDistance();
    safePlungeFeed = machineConfiguration.getSafePlungeFeedrate();
    safeRetractFeed = machineConfiguration.getSafeRetractFeedrate();
  }
  if (typeof safeRetractDistance == "number" && getProperty("safeRetractDistance") != undefined && getProperty("safeRetractDistance") != 0) {
    safeRetractDistance = getProperty("safeRetractDistance");
  }

  if (machineConfiguration.isHeadConfiguration()) {
    compensateToolLength = typeof compensateToolLength == "undefined" ? false : compensateToolLength;
  }

  if (machineConfiguration.isHeadConfiguration() && compensateToolLength) {
    for (var i = 0; i < getNumberOfSections(); ++i) {
      var section = getSection(i);
      if (section.isMultiAxis()) {
        machineConfiguration.setToolLength(getBodyLength(section.getTool())); // define the tool length for head adjustments
        section.optimizeMachineAnglesByMachine(machineConfiguration, OPTIMIZE_AXIS);
      }
    }
  } else {
    optimizeMachineAngles2(OPTIMIZE_AXIS);
  }
}

function getBodyLength(tool) {
  for (var i = 0; i < getNumberOfSections(); ++i) {
    var section = getSection(i);
    if (tool.number == section.getTool().number) {
      return section.getParameter("operation:tool_overallLength", tool.bodyLength + tool.holderLength);
    }
  }
  return tool.bodyLength + tool.holderLength;
}

function defineMachine() {
  var useTCP = true;
  if (true) { // note: setup your machine here
    var aAxis = createAxis({coordinate:0, table:true, axis:[1, 0, 0], range:[-112, 12], preference:1, tcp:useTCP}); //Matsuura specs -110 to 10
    var cAxis = createAxis({coordinate:2, table:true, axis:[0, 0, 1], range:[-360, 0], preference:0, tcp:useTCP}); //full 360 movements
    machineConfiguration = new MachineConfiguration(aAxis, cAxis);

    setMachineConfiguration(machineConfiguration);
    if (receivedMachineConfiguration) {
      warning(localize("The provided CAM machine configuration is overwritten by the postprocessor."));
      receivedMachineConfiguration = false; // CAM provided machine configuration is overwritten
    }
  }

  if (!receivedMachineConfiguration) {
    // multiaxis settings
    if (machineConfiguration.isHeadConfiguration()) {
      machineConfiguration.setVirtualTooltip(false); // translate the pivot point to the virtual tool tip for nonTCP rotary heads
    }

    // retract / reconfigure
    var performRewinds = true; // set to true to enable the rewind/reconfigure logic - default was off -Billy
    if (performRewinds) {
      machineConfiguration.enableMachineRewinds(); // enables the retract/reconfigure logic
      safeRetractDistance = (unit == IN) ? 1 : 25; // additional distance to retract out of stock, can be overridden with a property
      safeRetractFeed = (unit == IN) ? 20 : 500; // retract feed rate
      safePlungeFeed = (unit == IN) ? 10 : 250; // plunge feed rate
      machineConfiguration.setSafeRetractDistance(safeRetractDistance);
      machineConfiguration.setSafeRetractFeedrate(safeRetractFeed);
      machineConfiguration.setSafePlungeFeedrate(safePlungeFeed);
      var stockExpansion = new Vector(toPreciseUnit(0.1, IN), toPreciseUnit(0.1, IN), toPreciseUnit(0.1, IN)); // expand stock XYZ values
      machineConfiguration.setRewindStockExpansion(stockExpansion);
    }

    // multi-axis feedrates
    if (machineConfiguration.isMultiAxisConfiguration()) {
      machineConfiguration.setMultiAxisFeedrate(
        useTCP ? FEED_FPM : getProperty("useDPMFeeds") ? FEED_DPM : FEED_INVERSE_TIME,
        9999.99, // maximum output value for inverse time feed rates
        getProperty("useDPMFeeds") ? DPM_COMBINATION : INVERSE_MINUTES, // INVERSE_MINUTES/INVERSE_SECONDS or DPM_COMBINATION/DPM_STANDARD
        0.5, // tolerance to determine when the DPM feed has changed
        1.0 // ratio of rotary accuracy to linear accuracy for DPM calculations
      );
      setMachineConfiguration(machineConfiguration);
    }
    /* home positions */
    // machineConfiguration.setHomePositionX(toPreciseUnit(0, IN));
    // machineConfiguration.setHomePositionY(toPreciseUnit(0, IN));
    // machineConfiguration.setRetractPlane(toPreciseUnit(0, IN));
  }
}
// End of machine configuration logic

function onOpen() {
  // define and enable machine configuration
  receivedMachineConfiguration = machineConfiguration.isReceived();

  if (typeof defineMachine == "function") {
    defineMachine(); // hardcoded machine configuration
  }
  activateMachine(); // enable the machine optimizations and settings

  // Probing Surface Inspection
  if (typeof inspectionWriteVariables == "function") {
    inspectionWriteVariables();
  }

  if (getProperty("useShortestDirection")) {
    // abcFormat and abcDirectFormat must be compatible except for =DC()
    if (machineConfiguration.isMachineCoordinate(0)) {
      if (machineConfiguration.getAxisByCoordinate(0).isCyclic() || isSameDirection(machineConfiguration.getAxisByCoordinate(0).getAxis(), machineConfiguration.getSpindleAxis())) {
        aOutput = createVariable({prefix:"A"}, abcDirectFormat);
      }
    }
    if (machineConfiguration.isMachineCoordinate(1)) {
      if (machineConfiguration.getAxisByCoordinate(1).isCyclic() || isSameDirection(machineConfiguration.getAxisByCoordinate(1).getAxis(), machineConfiguration.getSpindleAxis())) {
        bOutput = createVariable({prefix:"B"}, abcDirectFormat);
      }
    }
    if (machineConfiguration.isMachineCoordinate(2)) {
      if (machineConfiguration.getAxisByCoordinate(2).isCyclic() || isSameDirection(machineConfiguration.getAxisByCoordinate(2).getAxis(), machineConfiguration.getSpindleAxis())) {
        cOutput = createVariable({prefix:"C"}, abcDirectFormat);
      }
    }
  }

  sequenceNumber = getProperty("sequenceNumberStart");
  // if (!((programName.length >= 2) && (isAlpha(programName[0]) || (programName[0] == "_")) && isAlpha(programName[1]))) {
  //   error(localize("Program name must begin with 2 letters."));
  // }
  writeln("; %_N_" + translateText(String(programName).toUpperCase(), " ", "_") + "_MPF");

  //program header
  var jobdescription = (getGlobalParameter("job-description"))
  if (jobdescription) {
    writeComment(jobdescription);
  }

  // write test version
  if (tv){ //true for writing test version, false for don't write test version
    if ((typeof getHeaderVersion == "function") && getHeaderVersion()) { 
      writeln("");
      writeComment(("TESTING POST PROCESSOR V") + getHeaderVersion() + " " + notes);
      writeComment("PROCEED WITH CAUTION !!!");
      writeBlock(mFormat.format(0));
    }
  }


  // write user name	
  if (hasGlobalParameter("username")) {
    var usernameprint = getGlobalParameter("username");
		  writeln("");
		  writeComment("Username: " + usernameprint);
		  }
		  
  // write date
  var d = new Date();
	if (hasGlobalParameter("generated-at")) {
    var datetime = getGlobalParameter("generated-at");
		  writeComment("Program Posted: " + d.toLocaleDateString() + " " + (d.toLocaleTimeString()));
  }

  // dump post properties  
  if ((typeof getHeaderVersion == "function") && getHeaderVersion()) { 
    writeComment(("Matsuura Siemen Factory 840D Post V") + getHeaderVersion()); 
  }
  writeln("")
  writeComment("Chip management=" + chipTransport)
  if(getProperty("isPalletProgram")){
    writeComment("Auto pallet changing enabled")
  }

  // dump machine configuration
  var vendor = machineConfiguration.getVendor();
  var model = machineConfiguration.getModel();
  var description = machineConfiguration.getDescription();

  if (getProperty("writeMachine") && (vendor || model || description)) {
    writeComment(localize("Machine"));
    if (vendor) {
      writeComment("  " + localize("vendor") + ": " + vendor);
    }
    if (model) {
      writeComment("  " + localize("model") + ": " + model);
    }
    if (description) {
      writeComment("  " + localize("description") + ": "  + description);
    }
  }

  // dump tool information
  writeln("")
  if (getProperty("writeTools")) {
    var zRanges = {};
    if (is3D()) {
      var numberOfSections = getNumberOfSections();
      for (var i = 0; i < numberOfSections; ++i) {
        var section = getSection(i);
        var zRange = section.getGlobalZRange();
        var tool = section.getTool();
        if (zRanges[tool.number]) {
          zRanges[tool.number].expandToRange(zRange);
        } else {
          zRanges[tool.number] = zRange;
        }
      }
    }

    var tools = getToolTable();
    if (tools.getNumberOfTools() > 0) {
      for (var i = 0; i < tools.getNumberOfTools(); ++i) {
        var tool = tools.getTool(i);
        var comment = "T" + (getProperty("toolAsName") ? "="  + "\"" + (tool.description.toUpperCase()) + "\"" : toolFormat.format(tool.number)) + " " +
          "D=" + xyzFormat.format(tool.diameter) + " " +
          localize("CR") + "=" + xyzFormat.format(tool.cornerRadius);
        if ((tool.taperAngle > 0) && (tool.taperAngle < Math.PI)) {
          comment += " " + localize("TAPER") + "=" + taperFormat.format(tool.taperAngle) + localize("deg");
        }
        if (zRanges[tool.number]) {
          comment += " - " + localize("ZMIN") + "=" + xyzFormat.format(zRanges[tool.number].getMinimum());
        }
        comment += " - " + getToolTypeName(tool.type);
        writeComment(comment);
      }
    }
  }

  if (false) { // stock - workpiece - disabled because cublex didn't like "workpiece" command
    var workpiece = getWorkpiece();
    var delta = Vector.diff(workpiece.upper, workpiece.lower);
    if (delta.isNonZero()) {
      writeBlock(
        "WORKPIECE" + "(" + ",,," + "\"" + "BOX" + "\""  + "," + "112" + "," + xyzFormat.format(workpiece.upper.z) + "," + xyzFormat.format(workpiece.lower.z) + "," + "80" +
        "," + xyzFormat.format(workpiece.upper.x) + "," + xyzFormat.format(workpiece.upper.y) + "," + xyzFormat.format(workpiece.lower.x) + "," + xyzFormat.format(workpiece.lower.y) + ")"
      );
    }
  }

  if ((getNumberOfSections() > 0) && (getSection(0).workOffset == 0)) {
    for (var i = 0; i < getNumberOfSections(); ++i) {
      if (getSection(i).workOffset > 0) {
        error(localize("Using multiple work offsets is not possible if the initial work offset is 0."));
        return;
      }
    }
  }

  // absolute coordinates and feed per min
  writeBlock(gAbsIncModal.format(90), gFeedModeModal.format(94));

  switch (unit) {
  case IN:
    writeBlock(gUnitModal.format(70)); // lengths
    //writeBlock(gFormat.format(700)); // feeds
    break;
  case MM:
    writeBlock(gUnitModal.format(71)); // lengths
    //writeBlock(gFormat.format(710)); // feeds
    break;
  }

  writeBlock(gFormat.format(64)); // continuous-path mode
  writeBlock(gPlaneModal.format(17));
  writeBlock(gModeModal.format(291)); //ISO mode
}

function onComment(message) {
  writeComment(message);
}

/** Force output of X, Y, and Z. */
function forceXYZ() {
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
}

/** Force output of A, B, and C. */
function forceABC() {
  aOutput.reset();
  bOutput.reset();
  cOutput.reset();
}

function forceFeed() {
  currentFeedId = undefined;
  feedOutput.reset();
}

/** Force output of X, Y, Z, A, B, C, and F on next output. */
function forceAny() {
  forceXYZ();
  forceABC();
  forceFeed();
}

function setWCS() {
  if (currentSection.workOffset != currentWorkOffset) {
    writeBlock(currentSection.wcs);
    currentWorkOffset = currentSection.workOffset;
  }
}

function isProbeOperation() {
  return hasParameter("operation-strategy") && ((getParameter("operation-strategy") == "probe" || getParameter("operation-strategy") == "probe_geometry"));
}

function isInspectionOperation(section) {
  return section.hasParameter("operation-strategy") && (section.getParameter("operation-strategy") == "inspectSurface");
}

var probeOutputWorkOffset = 0;

function onParameter(name, value) {
  if (name == "probe-output-work-offset") {
    probeOutputWorkOffset = (value > 0) ? value : 9999;
  }
}

function FeedContext(id, description, feed) {
  this.id = id;
  this.description = description;
  this.feed = feed;
}

function getFeed(f) {
  if (activeMovements) {
    var feedContext = activeMovements[movement];
    if (feedContext != undefined) {
      if (!feedFormat.areDifferent(feedContext.feed, f)) {
        if (feedContext.id == currentFeedId) {
          return ""; // nothing has changed
        }
        forceFeed();
        currentFeedId = feedContext.id;
        return "F=R" + (firstFeedParameter + feedContext.id);
      }
    }
    currentFeedId = undefined; // force Q feed next time
  }
  return feedOutput.format(f); // use feed value
}

function initializeActiveFeeds() {
  activeMovements = new Array();
  var movements = currentSection.getMovements();

  var id = 0;
  var activeFeeds = new Array();
  if (hasParameter("operation:tool_feedCutting")) {
    if (movements & ((1 << MOVEMENT_CUTTING) | (1 << MOVEMENT_LINK_TRANSITION) | (1 << MOVEMENT_EXTENDED))) {
      var feedContext = new FeedContext(id, localize("Cutting"), getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_CUTTING] = feedContext;
      activeMovements[MOVEMENT_LINK_TRANSITION] = feedContext;
      activeMovements[MOVEMENT_EXTENDED] = feedContext;
    }
    ++id;
    if (movements & (1 << MOVEMENT_PREDRILL)) {
      feedContext = new FeedContext(id, localize("Predrilling"), getParameter("operation:tool_feedCutting"));
      activeMovements[MOVEMENT_PREDRILL] = feedContext;
      activeFeeds.push(feedContext);
    }
    ++id;
  }

  if (hasParameter("operation:finishFeedrate")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), getParameter("operation:finishFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedEntry")) {
    if (movements & (1 << MOVEMENT_LEAD_IN)) {
      var feedContext = new FeedContext(id, localize("Entry"), getParameter("operation:tool_feedEntry"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_IN] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LEAD_OUT)) {
      var feedContext = new FeedContext(id, localize("Exit"), getParameter("operation:tool_feedExit"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_OUT] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:noEngagementFeedrate")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), getParameter("operation:noEngagementFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting") &&
             hasParameter("operation:tool_feedEntry") &&
             hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), Math.max(getParameter("operation:tool_feedCutting"), getParameter("operation:tool_feedEntry"), getParameter("operation:tool_feedExit")));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:reducedFeedrate")) {
    if (movements & (1 << MOVEMENT_REDUCED)) {
      var feedContext = new FeedContext(id, localize("Reduced"), getParameter("operation:reducedFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_REDUCED] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedRamp")) {
    if (movements & ((1 << MOVEMENT_RAMP) | (1 << MOVEMENT_RAMP_HELIX) | (1 << MOVEMENT_RAMP_PROFILE) | (1 << MOVEMENT_RAMP_ZIG_ZAG))) {
      var feedContext = new FeedContext(id, localize("Ramping"), getParameter("operation:tool_feedRamp"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_RAMP] = feedContext;
      activeMovements[MOVEMENT_RAMP_HELIX] = feedContext;
      activeMovements[MOVEMENT_RAMP_PROFILE] = feedContext;
      activeMovements[MOVEMENT_RAMP_ZIG_ZAG] = feedContext;
    }
    ++id;
  }
  if (hasParameter("operation:tool_feedPlunge")) {
    if (movements & (1 << MOVEMENT_PLUNGE)) {
      var feedContext = new FeedContext(id, localize("Plunge"), getParameter("operation:tool_feedPlunge"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_PLUNGE] = feedContext;
    }
    ++id;
  }
  if (true) { // high feed
    if (movements & (1 << MOVEMENT_HIGH_FEED)) {
      var feedContext = new FeedContext(id, localize("High Feed"), this.highFeedrate);
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_HIGH_FEED] = feedContext;
    }
    ++id;
  }

  for (var i = 0; i < activeFeeds.length; ++i) {
    var feedContext = activeFeeds[i];
    writeBlock("R" + (firstFeedParameter + feedContext.id) + "=" + feedFormat.format(feedContext.feed), formatComment(feedContext.description));
  }
}

var currentWorkPlaneABC = undefined;
var currentWorkPlaneABCTurned = false;

function forceWorkPlane() {
  currentWorkPlaneABC = undefined;
}

function defineWorkPlane(_section, _setWorkPlane) {
  var abc = new Vector(0, 0, 0);
  cancelTransformation();
  if (!is3D() || machineConfiguration.isMultiAxisConfiguration()) { // use 5-axis indexing for multi-axis mode
    // set working plane after datum shift

    if (_section.isMultiAxis()) {
      forceWorkPlane();
      setWorkPlane(new Vector(0, 0, 0), false); // reset working plane
    } else {
      if (useMultiAxisFeatures) {
        var cycle800Config = getCycle800Config(abc); // get the Euler method to use for cycle800
        if (cycle800Config[0] != 192) {
          abc = _section.workPlane.getEuler2(cycle800Config[2]);
        } else {
          abc = getWorkPlaneMachineABC(_section.workPlane, _setWorkPlane, true);
        }

      } else {
        abc = getWorkPlaneMachineABC(_section.workPlane, _setWorkPlane, true);
      }
      if (_setWorkPlane) {
        setWorkPlane(abc, true); // turn
      }
    }
  } else { // pure 3D
    var remaining = _section.workPlane;
    if (!isSameDirection(remaining.forward, new Vector(0, 0, 1))) {
      error(localize("Tool orientation is not supported."));
      return abc;
    }
    setRotation(remaining);
  }
  if (currentSection && (currentSection.getId() == _section.getId())) {
    operationSupportsTCP = (_section.isMultiAxis() || !useMultiAxisFeatures) && _section.getOptimizedTCPMode() == OPTIMIZE_NONE;
  }
  return abc;
}

function setWorkPlane(abc, turn) {
  if (is3D() && !machineConfiguration.isMultiAxisConfiguration()) {
    return; // ignore
  }

  if (!((currentWorkPlaneABC == undefined) ||
        abcFormat.areDifferent(abc.x, currentWorkPlaneABC.x) ||
        abcFormat.areDifferent(abc.y, currentWorkPlaneABC.y) ||
        abcFormat.areDifferent(abc.z, currentWorkPlaneABC.z) ||
        (!currentWorkPlaneABCTurned && turn))) {
    return; // no change
  }
  currentWorkPlaneABC = abc;
  currentWorkPlaneABCTurned = turn;

  if (!retracted) {
    writeRetract(Z);
  }

  if (turn) {
    onCommand(COMMAND_UNLOCK_MULTI_AXIS);
  }

  if (useMultiAxisFeatures) {
    var cycle800Config = getCycle800Config(abc);
    var DIR = integerFormat.format(turn ? -1 : 0); // direction
    if (machineConfiguration.isMultiAxisConfiguration()) {
      var machineABC = abc.isNonZero() ? (currentSection.isMultiAxis() ? getCurrentDirection() : getWorkPlaneMachineABC(currentSection.workPlane, false, false)) : abc;
      DIR = integerFormat.format(turn ? (abcFormat.getResultingValue(machineABC.getCoordinate(machineConfiguration.getAxisU().getCoordinate())) >= 0 ? 1 : -1) : 0);
      if (useABCPrepositioning) {
        writeBlock(
          gMotionModal.format(0),
          aOutput.format(machineABC.x),
          bOutput.format(machineABC.y),
          cOutput.format(machineABC.z)
        );
      }
      setCurrentABC(machineABC); // required for machine simulation
    }
    if(getProperty("cycle800Mode") != 0){
    if (cycle800Config[1].isZero() && !turn) {
      //writeBlock("CYCLE800()");
    } else {
      var FR = integerFormat.format(1); // 0 = without moving to safety plane, 1 = move to safety plane only in Z, 2 = move to safety plane Z,X,Y
      var TC = "\"" + "K01" + "\"";
      var ST = integerFormat.format(0);
      var MODE = cycle800Config[0];
      var X0 = integerFormat.format(0);
      var Y0 = integerFormat.format(0);
      var Z0 = integerFormat.format(0);
      var A = abcFormat.format(cycle800Config[1].x);
      var B = abcFormat.format(cycle800Config[1].y);
      var C = abcFormat.format(cycle800Config[1].z);
      var X1 = integerFormat.format(0);
      var Y1 = integerFormat.format(0);
      var Z1 = integerFormat.format(0);
      var FR_I = "";
      var DMODE = integerFormat.format(0); // keep the previous plane active
      writeBlock(
        "CYCLE800(" + [FR, TC, ST, MODE, X0, Y0, Z0, A, B, C, X1, Y1, Z1, DIR +
          (getProperty("useExtendedCycles") ? ("," + [FR_I, DMODE].join(",")) : "")].join(",") + ")"
      );
    };
  };
  } else {
    gMotionModal.reset();
    writeBlock(
      gMotionModal.format(0),
      conditional(machineConfiguration.isMachineCoordinate(0), "A" + abcFormat.format(abc.x)),
      conditional(machineConfiguration.isMachineCoordinate(1), "B" + abcFormat.format(abc.y)),
      conditional(machineConfiguration.isMachineCoordinate(2), "C" + abcFormat.format(abc.z))
    );
    setCurrentABC(abc); // required for machine simulation
  }

  forceABC();
  forceXYZ();

  if (turn) {
    //if (!currentSection.isMultiAxis()) {
    //onCommand(COMMAND_LOCK_MULTI_AXIS);
    //}
  }
}

function getWorkPlaneMachineABC(workPlane, _setWorkPlane, rotate) {
  var W = workPlane; // map to global frame

  var currentABC = isFirstSection() ? new Vector(0, 0, 0) : getCurrentDirection();
  var abc = machineConfiguration.getABCByPreference(W, currentABC, ABC, PREFER_PREFERENCE, ENABLE_ALL);

  var direction = machineConfiguration.getDirection(abc);
  if (!isSameDirection(direction, W.forward)) {
    error(localize("Orientation not supported."));
  }

  if (rotate) {
    var tcp = false;
    if (tcp) {
      setRotation(W); // TCP mode
    } else {
      var O = machineConfiguration.getOrientation(abc);
      var R = machineConfiguration.getRemainingOrientation(abc, W);
      setRotation(R);
    }
  }
  return abc;
}

/** Returns true if the spatial vectors are significantly different. */
function areSpatialVectorsDifferent(_vector1, _vector2) {
  return (xyzFormat.getResultingValue(_vector1.x) != xyzFormat.getResultingValue(_vector2.x)) ||
    (xyzFormat.getResultingValue(_vector1.y) != xyzFormat.getResultingValue(_vector2.y)) ||
    (xyzFormat.getResultingValue(_vector1.z) != xyzFormat.getResultingValue(_vector2.z));
}

/** Returns true if the spatial boxes are a pure translation. */
function areSpatialBoxesTranslated(_box1, _box2) {
  return !areSpatialVectorsDifferent(Vector.diff(_box1[1], _box1[0]), Vector.diff(_box2[1], _box2[0])) &&
    !areSpatialVectorsDifferent(Vector.diff(_box2[0], _box1[0]), Vector.diff(_box2[1], _box1[1]));
}

/** Returns true if the spatial boxes are same. */
function areSpatialBoxesSame(_box1, _box2) {
  return !areSpatialVectorsDifferent(_box1[0], _box2[0]) && !areSpatialVectorsDifferent(_box1[1], _box2[1]);
}

function subprogramDefine(_initialPosition, _abc, _retracted, _zIsOutput) {
  // convert patterns into subprograms
  var usePattern = false;
  patternIsActive = false;
  if (currentSection.isPatterned && currentSection.isPatterned() && (getProperty("useSubroutines") == "patterns")) {
    currentPattern = currentSection.getPatternId();
    firstPattern = true;
    for (var i = 0; i < definedPatterns.length; ++i) {
      if ((definedPatterns[i].patternType == SUB_PATTERN) && (currentPattern == definedPatterns[i].patternId)) {
        currentSubprogram = definedPatterns[i].subProgram;
        usePattern = definedPatterns[i].validPattern;
        firstPattern = false;
        break;
      }
    }

    if (firstPattern) {
      // determine if this is a valid pattern for creating a subprogram
      usePattern = subprogramIsValid(currentSection, currentPattern, SUB_PATTERN);
      if (usePattern) {
        currentSubprogram = ++lastSubprogram;
      }
      definedPatterns.push({
        patternType    : SUB_PATTERN,
        patternId      : currentPattern,
        subProgram     : currentSubprogram,
        validPattern   : usePattern,
        initialPosition: _initialPosition,
        finalPosition  : _initialPosition
      });
    }

    if (usePattern) {
      // make sure Z-position is output prior to subprogram call
      if (!_retracted && !_zIsOutput) {
        writeBlock(gMotionModal.format(0), zOutput.format(_initialPosition.z));
      }

      // call subprogram
      subprogramCall();
      patternIsActive = true;

      if (firstPattern) {
        subprogramStart(_initialPosition, _abc, incrementalSubprogram);
      } else {
        skipRemainingSection();
        setCurrentPosition(getFramePosition(currentSection.getFinalPosition()));
      }
    }
  }

  // Output cycle operation as subprogram
  if (!usePattern && (getProperty("useSubroutines") == "cycles") && currentSection.doesStrictCycle &&
    (currentSection.getNumberOfCycles() == 1) && currentSection.getNumberOfCyclePoints() >= minimumCyclePoints) {
    var finalPosition = getFramePosition(currentSection.getFinalPosition());
    currentPattern = currentSection.getNumberOfCyclePoints();
    firstPattern = true;
    for (var i = 0; i < definedPatterns.length; ++i) {
      if ((definedPatterns[i].patternType == SUB_CYCLE) && (currentPattern == definedPatterns[i].patternId) &&
        !areSpatialVectorsDifferent(_initialPosition, definedPatterns[i].initialPosition) &&
        !areSpatialVectorsDifferent(finalPosition, definedPatterns[i].finalPosition)) {
        currentSubprogram = definedPatterns[i].subProgram;
        usePattern = definedPatterns[i].validPattern;
        firstPattern = false;
        break;
      }
    }

    if (firstPattern) {
      // determine if this is a valid pattern for creating a subprogram
      usePattern = subprogramIsValid(currentSection, currentPattern, SUB_CYCLE);
      if (usePattern) {
        currentSubprogram = ++lastSubprogram;
      }
      definedPatterns.push({
        patternType    : SUB_CYCLE,
        patternId      : currentPattern,
        subProgram     : currentSubprogram,
        validPattern   : usePattern,
        initialPosition: _initialPosition,
        finalPosition  : finalPosition
      });
    }
    cycleSubprogramIsActive = usePattern;
  }

  // Output each operation as a subprogram
  if (!usePattern && (getProperty("useSubroutines") == "allOperations")) {
    currentSubprogram = ++lastSubprogram;
    // writeBlock("REPEAT LABEL" + currentSubprogram + " LABEL0");
    subprogramCall();
    firstPattern = true;
    subprogramStart(_initialPosition, _abc, false);
  }
}

function subprogramStart(_initialPosition, _abc, _incremental) {
  var comment = "";
  if (hasParameter("operation-comment")) {
    comment = getParameter("operation-comment");
  }

  if (getProperty("useFilesForSubprograms")) {
    // used if external files are used for subprograms
    var subprogram = "sub" + String(programName).substr(0, Math.min(programName.length, 20)) + currentSubprogram; // set the subprogram name
    var path = FileSystem.getCombinedPath(FileSystem.getFolderPath(getOutputPath()), subprogram + "." + subprogramExtension); // set the output path for the subprogram(s)
    redirectToFile(path); // redirect output to the new file (defined above)
    writeln("; %_N_" + translateText(String(subprogram).toUpperCase(), " ", "_") + "_SPF"); // add the program name to the first line of the newly created file
  } else {
    // used if subroutines are contained within the same file
    redirectToBuffer();
    writeln(
      "LABEL" + currentSubprogram + ":" +
      conditional(comment, formatComment(comment.substr(0, maximumLineLength - 2 - 6 - 1)))
    ); // output the subroutine name as the first line of the new file
  }

  saveShowSequenceNumbers = getProperty("showSequenceNumbers");
  setProperty("showSequenceNumbers", "false"); // disable sequence numbers for subprograms
  if (_incremental) {
    setIncrementalMode(_initialPosition, _abc);
  }
  gPlaneModal.reset();
  gMotionModal.reset();
}

function subprogramCall() {
  if (getProperty("useFilesForSubprograms")) {
    var subprogram = "sub" + String(programName).substr(0, Math.min(programName.length, 20)) + currentSubprogram; // set the subprogram name
    var callType = "SPF CALL";
    writeBlock(subprogram + " ;", callType); // call subprogram
  } else {
    writeBlock("CALL BLOCK LABEL" + currentSubprogram + " TO LABEL0");
  }
}

function subprogramEnd() {
  if (firstPattern) {
    if (!getProperty("useFilesForSubprograms")) {
      writeBlock("LABEL0:"); // sets the end block of the subroutine
      writeln("");
      subprograms += getRedirectionBuffer();
    } else {
      writeBlock(mFormat.format(17)); // close the external subprogram with M17
    }
  }
  forceAny();
  firstPattern = false;
  setProperty("showSequenceNumbers", saveShowSequenceNumbers);
  closeRedirection();
}

function subprogramIsValid(_section, _patternId, _patternType) {
  var sectionId = _section.getId();
  var numberOfSections = getNumberOfSections();
  var validSubprogram = _patternType != SUB_CYCLE;

  var masterPosition = new Array();
  masterPosition[0] = getFramePosition(_section.getInitialPosition());
  masterPosition[1] = getFramePosition(_section.getFinalPosition());
  var tempBox = _section.getBoundingBox();
  var masterBox = new Array();
  masterBox[0] = getFramePosition(tempBox[0]);
  masterBox[1] = getFramePosition(tempBox[1]);

  var rotation = getRotation();
  var translation = getTranslation();
  incrementalSubprogram = undefined;

  for (var i = 0; i < numberOfSections; ++i) {
    var section = getSection(i);
    if (section.getId() != sectionId) {
      defineWorkPlane(section, false);
      // check for valid pattern
      if (_patternType == SUB_PATTERN) {
        if (section.getPatternId() == _patternId) {
          var patternPosition = new Array();
          patternPosition[0] = getFramePosition(section.getInitialPosition());
          patternPosition[1] = getFramePosition(section.getFinalPosition());
          tempBox = section.getBoundingBox();
          var patternBox = new Array();
          patternBox[0] = getFramePosition(tempBox[0]);
          patternBox[1] = getFramePosition(tempBox[1]);

          if (areSpatialBoxesSame(masterPosition, patternPosition) && areSpatialBoxesSame(masterBox, patternBox) && !section.isMultiAxis()) {
            incrementalSubprogram = incrementalSubprogram ? incrementalSubprogram : false;
          } else if (!areSpatialBoxesTranslated(masterPosition, patternPosition) || !areSpatialBoxesTranslated(masterBox, patternBox)) {
            validSubprogram = false;
            break;
          } else {
            incrementalSubprogram = true;
          }
        }

      // check for valid cycle operation
      } else if (_patternType == SUB_CYCLE) {
        if ((section.getNumberOfCyclePoints() == _patternId) && (section.getNumberOfCycles() == 1)) {
          var patternInitial = getFramePosition(section.getInitialPosition());
          var patternFinal = getFramePosition(section.getFinalPosition());
          if (!areSpatialVectorsDifferent(patternInitial, masterPosition[0]) && !areSpatialVectorsDifferent(patternFinal, masterPosition[1])) {
            validSubprogram = true;
            break;
          }
        }
      }
    }
  }
  setRotation(rotation);
  setTranslation(translation);
  return (validSubprogram);
}

function setAxisMode(_format, _output, _prefix, _value, _incr) {
  var i = _output.isEnabled();
  if (_output == zOutput) {
    _output = _incr ? createIncrementalVariable({onchange:function() {retracted = false;}, prefix:_prefix}, _format) : createVariable({onchange:function() {retracted = false;}, prefix:_prefix}, _format);
  } else {
    _output = _incr ? createIncrementalVariable({prefix:_prefix}, _format) : createVariable({prefix:_prefix}, _format);
  }
  _output.format(_value);
  _output.format(_value);
  i = i ? _output.enable() : _output.disable();
  return _output;
}

function setIncrementalMode(xyz, abc) {
  xOutput = setAxisMode(xyzFormat, xOutput, "X", xyz.x, true);
  yOutput = setAxisMode(xyzFormat, yOutput, "Y", xyz.y, true);
  zOutput = setAxisMode(xyzFormat, zOutput, "Z", xyz.z, true);
  aOutput = setAxisMode(abcFormat, aOutput, "A", abc.x, true);
  bOutput = setAxisMode(abcFormat, bOutput, "B", abc.y, true);
  cOutput = setAxisMode(abcFormat, cOutput, "C", abc.z, true);
  gAbsIncModal.reset();
  writeBlock(gAbsIncModal.format(91));
  incrementalMode = true;
}

function setAbsoluteMode(xyz, abc) {
  if (incrementalMode) {
    xOutput = setAxisMode(xyzFormat, xOutput, "X", xyz.x, false);
    yOutput = setAxisMode(xyzFormat, yOutput, "Y", xyz.y, false);
    zOutput = setAxisMode(xyzFormat, zOutput, "Z", xyz.z, false);
    aOutput = setAxisMode(abcFormat, aOutput, "A", abc.x, false);
    bOutput = setAxisMode(abcFormat, bOutput, "B", abc.y, false);
    cOutput = setAxisMode(abcFormat, cOutput, "C", abc.z, false);
    gAbsIncModal.reset();
    writeBlock(gAbsIncModal.format(90));
    incrementalMode = false;
  }
}

function onSection() {
  if (getProperty("toolAsName") && !tool.description) {
    if (hasParameter("operation-comment")) {
      error(subst(localize("Tool description is empty in operation \"%1\"."), getParameter("operation-comment").toUpperCase()));
    } else {
      error(localize("Tool description is empty."));
    }
    return;
  }
  var insertToolCall = isFirstSection() ||
    currentSection.getForceToolChange && currentSection.getForceToolChange() ||
    (tool.number != getPreviousSection().getTool().number) ||
    conditional(getProperty("toolAsName"), tool.description != getPreviousSection().getTool().description);

  retracted = false; // specifies that the tool has been retracted to the safe plane
  var zIsOutput = false; // true if the Z-position has been output, used for patterns

  var newWorkOffset = isFirstSection() ||
    (getPreviousSection().workOffset != currentSection.workOffset); // work offset changes
  var newWorkPlane = isFirstSection() ||
    !isSameDirection(getPreviousSection().getGlobalFinalToolAxis(), currentSection.getGlobalInitialToolAxis()) ||
    (currentSection.isOptimizedForMachine() && getPreviousSection().isOptimizedForMachine() &&
    Vector.diff(getPreviousSection().getFinalToolAxisABC(), currentSection.getInitialToolAxisABC()).length > 1e-4) ||
    (!machineConfiguration.isMultiAxisConfiguration() && currentSection.isMultiAxis()) ||
    (getPreviousSection().isMultiAxis() != currentSection.isMultiAxis()); // force newWorkPlane between indexing and simultaneous operations

  initializeSmoothing(); // initialize smoothing mode

  if (insertToolCall || newWorkOffset || newWorkPlane) {

    // retract to safe plane
    writeRetract(Z);
    if(!isFirstSection()){
      writeRetract(X,Y);
    };
    writeBlock("CYCLE800()"); //cancel cycle800

    if (newWorkPlane && useMultiAxisFeatures) {
      setWorkPlane(new Vector(0, 0, 0), false); // reset working plane
    }
  }

  if (hasParameter("operation-comment")) {
    var comment = getParameter("operation-comment");
    if (comment && ((comment !== lastOperationComment) || !patternIsActive || insertToolCall)) {
      writeln("");
      writeComment(comment + " " + xyzFormat.format(tool.diameter) + " Dia");
      lastOperationComment = comment;
    } else if (!patternIsActive || insertToolCall) {
      writeln("");
    }
  }

  if (getProperty("showNotes") && hasParameter("notes")) {
    var notes = getParameter("notes");
    if (notes) {
      var lines = String(notes).split("\n");
      var r1 = new RegExp("^[\\s]+", "g");
      var r2 = new RegExp("[\\s]+$", "g");
      for (line in lines) {
        var comment = lines[line].replace(r1, "").replace(r2, "");
        if (comment) {
          writeComment(comment);
        }
      }
    }
  }

    //optional stop at the beginning of every tool path -- on Matsuura-Fanuc this requires spindle and coolant to be turned back on in the program
    if (!isFirstSection() && getProperty("optionalStop")) {  
      onCommand(COMMAND_OPTIONAL_STOP);
    }
    
  if (insertToolCall) {
    forceWorkPlane();

    setCoolant(COOLANT_OFF);


    if (!isFirstSection() && !getProperty("optionalStop") && insertToolCall) {
      onCommand(COMMAND_OPTIONAL_STOP);
    }


    if (tool.number > 99999999) {
      warning(localize("Tool number exceeds maximum value."));
    }

    lengthOffset = 1; // optional, use tool.lengthOffset instead
    if (lengthOffset > 99) {
      error(localize("Length offset out of range."));
      return;
    }
    
    writeToolBlock("T" + (getProperty("toolAsName") ? "="  + "\"" + (tool.description.toUpperCase()) + "\"" : toolFormat.format(tool.number)));//, dFormat.format(lengthOffset)); //commented d value because the control didn't like it on CUBLEX in ISO mode -Billy
    writeBlock(mFormat.format(6));
    if (tool.comment) {
      writeComment(tool.comment);
    }
    var showToolZMin = false;
    if (showToolZMin) {
      if (is3D()) {
        var numberOfSections = getNumberOfSections();
        var zRange = currentSection.getGlobalZRange();
        var number = tool.number;
        for (var i = currentSection.getId() + 1; i < numberOfSections; ++i) {
          var section = getSection(i);
          if (section.getTool().number != number) {
            break;
          }
          zRange.expandToRange(section.getGlobalZRange());
        }
        writeComment(localize("ZMIN") + "=" + zRange.getMinimum());
      }
    }
    writeBlock(mFormat.format(110)); //close tool door (not sure why this isn't happening automatically)

    if (getProperty("preloadTool")) {
      var nextTool = (getProperty("toolAsName") ? getNextToolDescription(tool.description) : getNextTool(tool.number));
      if (nextTool) {
        writeBlock("T" + (getProperty("toolAsName") ? "="  + "\"" + (nextTool.description.toUpperCase()) + "\"" : toolFormat.format(nextTool.number)));
      } else {
        // preload first tool
        var section = getSection(0);
        var firstToolNumber = section.getTool().number;
        var firstToolDescription = section.getTool().description;
        if (getProperty("toolAsName")) {
          if (tool.description != firstToolDescription) {
            writeBlock("T=" + "\"" + (firstToolDescription.toUpperCase()) + "\"");
          }
        } else {
          if (tool.number != firstToolNumber) {
            writeBlock("T" + toolFormat.format(firstToolNumber));
          }
        }
      }
    }
  }

  
  if((tool.coolant) == "3" || (tool.coolant) == "8"){
    setCoolant(tool.coolant);
    //writeBlock(gFormat.format(4), "P5000")
    //writeComment("dwell 5 seconds for TSC to ramp up"); //debug coolant
  }; //dwell for through tool coolant to ramp up



  if ((insertToolCall ||
       forceSpindleSpeed ||
       isFirstSection() ||
       (rpmFormat.areDifferent(spindleSpeed, sOutput.getCurrent())) ||
       (tool.clockwise != getPreviousSection().getTool().clockwise) || 
       getProperty("optionalStop"))) {
    forceSpindleSpeed = false;

    if (tool.type == TOOL_PROBE) {
      if (insertToolCall) {
        writeBlock("SPOS=0");
      }
    } else {
      if (spindleSpeed < 1) {
        error(localize("Spindle speed can't be less than 1rpm."));
        return;
      }
      if (spindleSpeed > 16500) {
        warning(localize("Spindle speed exceeds maximum value of 16500rpm"));
        return;
      }
      writeBlock(
        sOutput.format(spindleSpeed), mFormat.format(tool.clockwise ? 3 : 4)  //according to matsuura docs, could use M203 or M204 here and call the M3 or M4 later -Billy
      );

    }
  }

  // set coolant after spindle starts - - should be after z is positioned but something must be wrong with machine and it's taking a lot of time to come on -Billy
  if (insertToolCall) {
    // currentCoolantMode = undefined;
  }
  
  if((tool.coolant) != "3" && (tool.coolant) != "8"){
    setCoolant(tool.coolant);
  }; //all coolants other than TSC start after spindle

  // wcs
  if (insertToolCall) { // force work offset when changing tool
    currentWorkOffset = undefined;
  }
  setWCS();

  forceXYZ();

  var abc = defineWorkPlane(currentSection, true);
  forceAny();

  if (!currentSection.isMultiAxis()) {
    onCommand(COMMAND_LOCK_MULTI_AXIS);
  }

   if (retracted && !insertToolCall) { //removed from new fusion post version -Billy
    var lengthOffset = 1; // optional, use tool.lengthOffset instead
    if (lengthOffset > 99) {
      error(localize("Length offset out of range."));
      return;
    }
    //writeBlock(dFormat.format(lengthOffset)); Siemens mode lenght offset
    writeBlock(gFormat.format(getOffsetCode()), "H" + toolFormat.format(tool.number)); //ISO mode length offset

  }

  if (currentSection.isMultiAxis()) {
    forceWorkPlane();
    cancelTransformation();

    // turn machine
    if (currentSection.isOptimizedForMachine()) {
      if (!retracted) {
        writeRetract(Z);
      }
      var abc = currentSection.getInitialToolAxisABC();
      writeBlock(gAbsIncModal.format(90), gMotionModal.format(0), aOutput.format(abc.x), bOutput.format(abc.y), cOutput.format(abc.z));
      setCurrentDirection(abc); //added to new fusion post version -Billy
    }
    if (operationSupportsTCP || !machineConfiguration.isMultiAxisConfiguration()) {
      onCommand(COMMAND_OPTIONAL_STOP); //M0 before full 5 axis to check
      writeBlock("TRAORI");
    }
    var initialPosition = getFramePosition(currentSection.getInitialPosition());

    if (currentSection.isOptimizedForMachine()) {
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(0),
        xOutput.format(initialPosition.x),
        yOutput.format(initialPosition.y),
        zOutput.format(initialPosition.z)
      );
    } else {
      var d = currentSection.getGlobalInitialToolAxis();
      writeBlock(
        gMotionModal.format(0),
        //gFormat.format(getOffsetCode()),
        zOutput.format(initialPosition.z)//,
        //"H" + toolFormat.format(tool.number)
      );
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(0),
        xOutput.format(initialPosition.x),
        yOutput.format(initialPosition.y),
        zOutput.format(initialPosition.z),
        a3Output.format(d.x),
        b3Output.format(d.y),
        c3Output.format(d.z)
      );
    }
  } else {

    var initialPosition = getFramePosition(currentSection.getInitialPosition());
    if (!retracted && !insertToolCall) {
      if (getCurrentPosition().z < initialPosition.z) {
        writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
        zIsOutput = true;
      }
    }

    if (insertToolCall) {
      /*
      if (tool.lengthOffset != 0) {
        warningOnce(localize("Length offset is not supported."), WARNING_LENGTH_OFFSET);
      }
      */

      if (!machineConfiguration.isHeadConfiguration()) {
        writeBlock(
          gAbsIncModal.format(90),
          gMotionModal.format(0), xOutput.format(initialPosition.x), yOutput.format(initialPosition.y)
        );
        var z = zOutput.format(initialPosition.z);
        if (z) {
          writeBlock(gMotionModal.format(0), z);
        }
      } else {
        writeBlock(
          gAbsIncModal.format(90),
          gMotionModal.format(0),
          xOutput.format(initialPosition.x),
          yOutput.format(initialPosition.y)
        );
        writeBlock(
          gMotionModal.format(0),
          //gFormat.format(getOffsetCode()),
          zOutput.format(initialPosition.z)//,
          //"H" + toolFormat.format(tool.number)
        );
      }
    } else {
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(0),
        xOutput.format(initialPosition.x),
        yOutput.format(initialPosition.y)
      );  
      writeBlock(
        //gFormat.format(getOffsetCode()),
        zOutput.format(initialPosition.z)//,
        //"H" + toolFormat.format(tool.number)
      );
    }
  }

  // set coolant after we have positioned at Z

  /*default behavior desabled by JF request because it's not coming on fast enough -Billy

  if (insertToolCall) {
    // currentCoolantMode = undefined;
  }

  */


  setCoolant(tool.coolant);



  if (tool.type != TOOL_PROBE) {
    if(chipTransport == "auto"){      
      if(tool.diameter >= .34){
        onCommand(COMMAND_START_CHIP_TRANSPORT) //chip management commands flush and conveyor start
      }
    }
  }

    /*//Matsuura spindle rampup function spindle check
  if ((insertToolCall ||
    forceSpindleSpeed ||
    isFirstSection() ||
    (rpmFormat.areDifferent(spindleSpeed, sOutput.getCurrent())) ||
    (tool.clockwise != getPreviousSection().getTool().clockwise) || 
    getProperty("optionalStop"))) {
        forceSpindleSpeed = false;

        if (tool.type != TOOL_PROBE) {
            writeBlock(mFormat.format(tool.clockwise ? 3 : 4))
            ;
        }
    }
  
    
  */

    smoothing.force = insertToolCall && (getProperty("useSmoothing") != "-1");
    setSmoothing(smoothing.isAllowed); // writes the required smoothing codes

  if (getProperty("useParametricFeed") &&
      hasParameter("operation-strategy") &&
      (getParameter("operation-strategy") != "drill") && // legacy
      !(currentSection.hasAnyCycle && currentSection.hasAnyCycle())) {
    if (!insertToolCall &&
        activeMovements &&
        (getCurrentSectionId() > 0) &&
        ((getPreviousSection().getPatternId() == currentSection.getPatternId()) && (currentSection.getPatternId() != 0))) {
      // use the current feeds
    } else {
      initializeActiveFeeds();
    }
  } else {
    activeMovements = undefined;
  }

  if (insertToolCall) {
    gPlaneModal.reset();
  }
  retracted = false;
  // surface Inspection
  if (isInspectionOperation(currentSection) && (typeof inspectionProcessSectionStart == "function")) {
    inspectionProcessSectionStart();
  }
  // define subprogram
  subprogramDefine(initialPosition, abc, retracted, zIsOutput);
}

function setSmoothing(mode) {
  /*if (mode == smoothing.isActive && (!mode || !smoothing.isDifferent) && !smoothing.force) {
    return; // return if smoothing is already active or is not different
  }
  if (typeof lengthCompensationActive != "undefined" && smoothingSettings.cancelCompensation) {
    validate(!lengthCompensationActive, "Length compensation is active while trying to update smoothing.");
  }
  */

  if (mode) { // enable smoothing
    if (hasParameter("operation:smoothingFilterTolerance") && (smoothing.filter > 0)) {
      writeComment("Smoothing: " + ijkFormat.format(getParameter("operation:smoothingFilterTolerance", 0))) //write smoothing filter
    };
    if (hasParameter("operation:tolerance")) {
      writeComment("Tolerance: "+ (getParameter("operation:tolerance", 0))) //write tolerance
    };
    writeBlock(smoothing.prefix + smoothing.level);
    writeBlock("STOPFIFO")
  } else { // disable smoothing
    writeBlock("HOF");
    
  }
  smoothing.isActive = mode;
  smoothing.force = false;
  smoothing.isDifferent = false;
}
// End of smoothing logic

function getNextToolDescription(description) {
  var currentSectionId = getCurrentSectionId();
  if (currentSectionId < 0) {
    return null;
  }
  for (var i = currentSectionId + 1; i < getNumberOfSections(); ++i) {
    var section = getSection(i);
    var sectionTool = section.getTool();
    if (description != sectionTool.description) {
      return sectionTool; // found next tool
    }
  }
  return null; // not found
}

function onDwell(seconds) {
  if (seconds > 0) {
    writeBlock(gFormat.format(4), "F" + secFormat.format(seconds));
  }
}

function onSpindleSpeed(spindleSpeed) {
  writeBlock(sOutput.format(spindleSpeed));
}

var expandCurrentCycle = false;

function onCycle() {
  if (!isSameDirection(getRotation().forward, new Vector(0, 0, 1))) {
    expandCurrentCycle = true;
    return;
  }

  writeBlock(gPlaneModal.format(17));


  expandCurrentCycle = false;

  if ((cycleType != "tapping") &&
      (cycleType != "right-tapping") &&
      (cycleType != "left-tapping") &&
      (cycleType != "tapping-with-chip-breaking") &&
      (cycleType != "inspect") &&
      !isProbeOperation()) {
    writeBlock(feedOutput.format(cycle.feedrate));
  }

  var RTP;//define variables
  var RFP;
  var SDIS;
  var DP;
  var DPR;
  var DTB;
  var SDIR;
  if (tool.type != TOOL_PROBE) {//set varibales
    RTP = xyzFormat.format(cycle.clearance); // return plane (absolute)
    RFP = xyzFormat.format(cycle.stock); // reference plane (absolute)
    SDIS = xyzFormat.format(cycle.retract - cycle.stock); // safety distance
    DP = xyzFormat.format(cycle.bottom); // depth (absolute)
    DPR = ""; // depth (relative to reference plane)
    DTB = secFormat.format(cycle.dwell);
    SDIR = integerFormat.format(tool.clockwise ? 3 : 4); // direction of rotation: M3:3 and M4:4
  }

  switch (cycleType) {
  case "drilling":
    if (cycle.clearance > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    var _GMODE = integerFormat.format(0);
    var _DMODE = integerFormat.format(0); // keep the programmed plane active
    var _AMODE = integerFormat.format(10); // dwell is programmed in seconds and depth is taken from DP DPR settings
    writeBlock(gModeModal.format(290));
    writeBlock(
      "MCALL CYCLE81(" + [RTP, RFP, SDIS, DP, DPR +
        (getProperty("useExtendedCycles") ? (cycleSeparator + [_GMODE, _DMODE, _AMODE].join(cycleSeparator)) : "")].join(cycleSeparator) + ")"
    );
    break;
  case "counter-boring":
    if (cycle.clearance > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    var _GMODE = integerFormat.format(0);
    var _DMODE = integerFormat.format(0); // keep the programmed plane active
    var _AMODE = integerFormat.format(10); // dwell is programmed in seconds and depth is taken from DP DPR settings
    writeBlock(gModeModal.format(290));
    writeBlock(
      "MCALL CYCLE82(" + [RTP, RFP, SDIS, DP, DPR, DTB +
        (getProperty("useExtendedCycles") ? (cycleSeparator + [_GMODE, _DMODE, _AMODE].join(", ")) : "")].join(cycleSeparator) + ")"
    );
    break;
  case "chip-breaking":
    if (cycle.accumulatedDepth < cycle.depth) {
      expandCurrentCycle = true;
    } else {
      if (cycle.clearance > getCurrentPosition().z) {
        writeBlock(gMotionModal.format(0), zOutput.format(RTP));
      }
      // add support for accumulated depth
      var FDEP = xyzFormat.format(cycle.stock - cycle.incrementalDepth);
      var FDPR = ""; // relative to reference plane (unsigned)
      var _DAM = xyzFormat.format(cycle.incrementalDepthReduction); // degression (unsigned)
      DTB = "";
      var DTS = secFormat.format(0); // dwell time at start
      var FRF = xyzFormat.format(1); // feedrate factor (unsigned)
      var VARI = integerFormat.format(0); // chip breaking
      var _AXN = ""; // tool axis
      var _MDEP = xyzFormat.format((cycle.incrementalDepthReduction > 0) ? cycle.minimumIncrementalDepth : cycle.incrementalDepth); // minimum drilling depth
      var _VRT = xyzFormat.format(cycle.chipBreakDistance); // retraction distance
      var _DTD = secFormat.format((cycle.dwell != undefined) ? cycle.dwell : 0);
      var _DIS1 = integerFormat.format(0); // limit distance
      var _GMODE = integerFormat.format(0); // drilling with respect to the tip
      var _DMODE = integerFormat.format(0); // keep the programmed plane active
      var _AMODE = integerFormat.format(1001110);
      writeBlock(gModeModal.format(290));
      writeBlock(
        "MCALL CYCLE83(" + [RTP, RFP, SDIS, DP, DPR, FDEP, FDPR, _DAM, DTB, DTS, FRF, VARI, _AXN, _MDEP, _VRT, _DTD, _DIS1 +
          (getProperty("useExtendedCycles") ? (cycleSeparator + [_GMODE, _DMODE, _AMODE].join(cycleSeparator)) : "")].join(cycleSeparator) + ")"
      );
    }
    break;
  case "deep-drilling":
    if (cycle.clearance > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    var FDEP = xyzFormat.format(cycle.stock - cycle.incrementalDepth);
    var FDPR = ""; // relative to reference plane (unsigned)
    var _DAM = xyzFormat.format(cycle.incrementalDepthReduction); // degression (unsigned)
    var DTS = secFormat.format(0); // dwell time at start
    var FRF = xyzFormat.format(1); // feedrate factor (unsigned)
    var VARI = integerFormat.format(1); // full retract
    var _AXN = ""; // tool axis
    var _MDEP = xyzFormat.format((cycle.incrementalDepthReduction > 0) ? cycle.minimumIncrementalDepth : cycle.incrementalDepth); // minimum drilling depth
    var _VRT = xyzFormat.format(cycle.chipBreakDistance ? cycle.chipBreakDistance : 0); // retraction distance
    var _DTD = secFormat.format((cycle.dwell != undefined) ? cycle.dwell : 0);
    var _DIS1 = integerFormat.format(0); // limit distance
    var _GMODE = integerFormat.format(0); // drilling with respect to the tip
    var _DMODE = integerFormat.format(0); // keep the programmed plane active
    var _AMODE = integerFormat.format(1001110);
    writeBlock(gModeModal.format(290));
    writeBlock(
      "MCALL CYCLE83(" + [RTP, RFP, SDIS, DP, DPR, FDEP, FDPR, _DAM, DTB, DTS, FRF, VARI, _AXN,  _MDEP, _VRT, _DTD, _DIS1 +
        (getProperty("useExtendedCycles") ? (cycleSeparator + [_GMODE, _DMODE, _AMODE].join(cycleSeparator)) : "")].join(cycleSeparator) + ")"
    );

    break;
  case "tapping":
  case "left-tapping":
  case "right-tapping":
    if (cycle.clearance > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    var SDAC = SDIR; // direction of rotation after end of cycle
    var MPIT = ""; // thread pitch as thread size
    var PIT = xyzFormat.format(tool.threadPitch); // thread pitch
    var POSS = xyzFormat.format(0); // spindle position for oriented spindle stop in cycle (in degrees)
    var SST = rpmFormat.format(spindleSpeed); // speed for tapping
    var SST1 = rpmFormat.format(spindleSpeed); // speed for return
    var _AXN = integerFormat.format(0); // tool axis - - all "_" removed for CUBLEX 840Di -Billy
    var _PITA = integerFormat.format((unit == MM) ? 1 : 3);
    var _TECHNO = ""; // technology settings
    var _VARI = integerFormat.format(0); // machining type: 0 = tapping full depth, 1 = tapping partial retract, 2 = tapping full retract
    var _DAM = ""; // incremental depth
    var _VRT = ""; // retract distance for chip breaking
    var _PITM = ""; // string for pitch input (not used)
    var _PTAB = ""; // string for thread table (not used)
    var _PTABA = ""; // string for selection from thread table (not used)
    var _GMODE = integerFormat.format(0); // reserved (geometrical mode)
    var _DMODE = integerFormat.format(0); // units and active spindle (0 for tool spindle, 100 for turning spindle)
    var _AMODE = integerFormat.format((tool.type == TOOL_TAP_LEFT_HAND) ? 1002002 : 1001002); // alternate mode
    writeBlock(gModeModal.format(290));
    writeBlock(
      "MCALL CYCLE84(" + [RTP, 
        RFP, 
        SDIS, 
        DP, 
        DPR, 
        DTB, 
        SDAC, 
        MPIT, 
        PIT, 
        POSS, 
        SST, 
        SST1].join(cycleSeparator) + ")" 
        /*_AXN, 
        //_PITA, 
        _TECHNO, 
        _VARI, 
        _DAM, 
        _VRT, 
        _PITM, 
        _PTAB, 
        _PTABA +
          (getProperty("useExtendedCycles") ? (cycleSeparator + [_GMODE, _DMODE, _AMODE].join(cycleSeparator)) : "")].join(cycleSeparator) + ")"
    */
    );
    break;
  case "tapping-with-chip-breaking":
    if (cycle.accumulatedDepth < cycle.depth) {
      error(localize("Accumulated pecking depth is not supported for canned tapping cycles with chip breaking."));
      return;
    }
    if (cycle.clearance > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    var SDAC = SDIR; // direction of rotation after end of cycle
    var MPIT = ""; // thread pitch as thread size
    var PIT = xyzFormat.format(tool.threadPitch); // thread pitch
    var POSS = xyzFormat.format(0); // spindle position for oriented spindle stop in cycle (in degrees)
    var SST = rpmFormat.format(spindleSpeed); // speed for tapping
    var SST1 = rpmFormat.format(spindleSpeed); // speed for return
    var _AXN = integerFormat.format(0); // tool axis  - - all "_" removed for CUBLEX 840Di -Billy
    var _PITA = integerFormat.format((unit == MM) ? 1 : 3);
    var _TECHNO = ""; // technology settings
    var _VARI = integerFormat.format(1); // machining type: 0 = tapping full depth, 1 = tapping partial retract, 2 = tapping full retract
    var _DAM = xyzFormat.format(cycle.incrementalDepth); // incremental depth
    var _VRT = xyzFormat.format(cycle.chipBreakDistance); // retract distance for chip breaking
    var _PITM = ""; // string for pitch input (not used)
    var _PTAB = ""; // string for thread table (not used)
    var _PTABA = ""; // string for selection from thread table (not used)
    var _GMODE = integerFormat.format(0); // reserved (geometrical mode)
    var _DMODE = integerFormat.format(0); // units and active spindle (0 for tool spindle, 100 for turning spindle)
    var _AMODE = integerFormat.format((tool.type == TOOL_TAP_LEFT_HAND) ? 1002002 : 1001002); // alternate mode

    writeBlock(gModeModal.format(290));
    writeBlock(
      "MCALL CYCLE84(" + [RTP,
        RFP,
        SDIS,
        DP, 
        DPR, 
        DTB, 
        SDAC, 
        MPIT, 
        PIT, 
        POSS, 
        SST, 
        SST1].join(cycleSeparator) + ")"//,
        /* 
        _AXN, 
        _PITA, 
        _TECHNO, 
        _VARI, 
        _DAM, 
        _VRT, 
        _PITM, 
        _PTAB, 
        _PTABA +
          (getProperty("useExtendedCycles") ? (cycleSeparator + [_GMODE, _DMODE, _AMODE].join(cycleSeparator)) : "")].join(cycleSeparator) + ")"
        */
          );
    break;
  case "reaming":
    if (cycle.clearance > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    var FFR = xyzFormat.format(cycle.feedrate);
    var RFF = xyzFormat.format(cycle.retractFeedrate);
    var _GMODE = integerFormat.format(0); // reserved
    var _DMODE = integerFormat.format(0); // keep current plane active
    var _AMODE = integerFormat.format(0); // compatibility from DP and DT programming
    writeBlock(gModeModal.format(290));
    writeBlock(
      "MCALL CYCLE85(" + [RTP, RFP, SDIS, DP, DPR, DTB, FFR, RFF +
          (getProperty("useExtendedCycles") ? (cycleSeparator + [_GMODE, _DMODE, _AMODE].join(cycleSeparator)) : "")].join(cycleSeparator) + ")"
    );
    break;
  case "stop-boring":
    if (cycle.clearance > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    if (cycle.dwell > 0) {
      writeBlock(gModeModal.format(290));
      writeBlock(
        "MCALL CYCLE88(" + [RTP, RFP, SDIS, DP, DPR, DTB, SDIR].join(cycleSeparator) + ")"
      );
    } else {
      writeBlock(gModeModal.format(290));
      writeBlock(
        "MCALL CYCLE87(" + [RTP, RFP, SDIS, DP, DPR, SDIR].join(cycleSeparator) + ")"
      );
    }
    break;
  case "fine-boring":
    if (cycle.clearance > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    var RPA = xyzFormat.format(-Math.cos(cycle.shiftOrientation) * cycle.shift); // return path in abscissa of the active plane (enter incrementally with)
    var RPO = xyzFormat.format(-Math.sin(cycle.shiftOrientation) * cycle.shift); // return path in the ordinate of the active plane (enter incrementally sign)
    var RPAP = xyzFormat.format(0); // return plane in the applicate (enter incrementally with sign)
    var POSS = xyzFormat.format(toDeg(cycle.shiftOrientation)); // spindle position for oriented spindle stop in cycle (in degrees)
    var _GMODE = integerFormat.format(0); // lift off
    var _DMODE = integerFormat.format(0); // keep current plane active
    var _AMODE = integerFormat.format(10); // dwell in seconds and keep units abs/inc setting from DP/DPR
    writeBlock(gModeModal.format(290));
    writeBlock(
      "MCALL CYCLE86(" + [RTP, RFP, SDIS, DP, DPR, DTB, SDIR, RPA, RPO, RPAP, POSS +
        (getProperty("useExtendedCycles") ? (cycleSeparator + [_GMODE, _DMODE, _AMODE].join(cycleSeparator)) : "")].join(cycleSeparator) + ")"
    );
    break;
  case "back-boring":
    expandCurrentCycle = true;
    break;
  case "boring":
    if (cycle.clearance > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    // retract feed is ignored
    writeBlock(gModeModal.format(290));
    writeBlock(
      "MCALL CYCLE89(" + [RTP, RFP, SDIS, DP, DPR, DTB].join(cycleSeparator) + ")"
    );
    break;

  default:
    expandCurrentCycle = true;
  }

  if (!expandCurrentCycle) {
    // place cycle operation in subprogram
    if (cycleSubprogramIsActive) {
      if (cycleExpanded || isProbeOperation()) {
        cycleSubprogramIsActive = false;
      } else {
        subprogramCall();
        if (firstPattern) {
          subprogramStart(new Vector(0, 0, 0), new Vector(0, 0, 0), false);
        } else {
          // skipRemainingSection();
          // setCurrentPosition(getFramePosition(currentSection.getFinalPosition()));
        }
      }
    }
    xOutput.reset();
    yOutput.reset();
  } else {
    cycleSubprogramIsActive = false;
  }
}

function setCyclePosition(_position) {
  switch (gPlaneModal.getCurrent()) {
  case 17: // XY
    zOutput.format(_position);
    break;
  case 18: // ZX
    yOutput.format(_position);
    break;
  case 19: // YZ
    xOutput.format(_position);
    break;
  }
}

function approach(value) {
  validate((value == "positive") || (value == "negative"), "Invalid approach.");
  return (value == "positive") ? 1 : -1;
}

function getProbingArguments(cycle, singleLine) {
  var probeWCS = hasParameter("operation-strategy") && (getParameter("operation-strategy") == "probe");
  var isAngleProbing = cycleType.indexOf("angle") != -1;

  return {
    probeWCS             : probeWCS,
    isAngleProbing       : isAngleProbing,
    isRectangularFeature : cycleType.indexOf("rectangular") != -1,
    isIncrementalDepth   : cycleType.indexOf("island") != -1 || cycleType.indexOf("wall") != -1 || cycleType.indexOf("boss") != -1,
    isAngleAskewAction   : (cycle.angleAskewAction == "stop-message"),
    isWrongSizeAction    : (cycle.wrongSizeAction == "stop-message"),
    isOutOfPositionAction: (cycle.outOfPositionAction == "stop-message"),
    _TUL                 : !isAngleProbing ? (cycle.tolerancePosition ? ((!singleLine ? "_TUL=" : "") + xyzFormat.format(cycle.tolerancePosition)) : undefined) : undefined,
    _TLL                 : !isAngleProbing ? (cycle.tolerancePosition ? ((!singleLine ? "_TLL=" : "") + xyzFormat.format(cycle.tolerancePosition * -1)) : undefined) : undefined,
    _TNUM                : (!isAngleProbing && cycle.updateToolWear) ? (!singleLine ? (getProperty("toolAsName") ? "_TNAME=" : "_TNUM=") : "") + (getProperty("toolAsName") ? "\"" + (cycle.toolDescription.toUpperCase()) + "\"" : toolFormat.format(cycle.toolWearNumber)) : undefined,
    _TDIF                : (!isAngleProbing && cycle.updateToolWear) ? (!singleLine ? "_TDIF=" : "") + xyzFormat.format(cycle.toolWearUpdateThreshold) : undefined,
    _TMV                 : cycle.hasSizeTolerance ? ((!isAngleProbing && cycle.updateToolWear) ? (!singleLine ? "_TMV=" : "") + xyzFormat.format(cycle.toleranceSize) : undefined) : undefined,
    _KNUM                : (!isAngleProbing && cycle.updateToolWear) ? (!singleLine ? "_KNUM=" : "") + xyzFormat.format(cycleType == "probing-z" ? (1000 + (cycle.toolLengthOffset)) : (2000 + (cycle.toolDiameterOffset))) : (isAngleProbing && !probeWCS) ? (!singleLine ? "_KNUM=" : "") + 0 : undefined // 2001 for D1
  };
}

function onCyclePoint(x, y, z) {
  if (cycleType == "inspect") {
    if (typeof inspectionCycleInspect == "function") {
      inspectionCycleInspect(cycle, x, y, z);
      return;
    } else {
      cycleNotSupported();
    }
  }
  if (cycleSubprogramIsActive && !firstPattern) {
    return;
  }
  if (isProbeOperation()) {
    var _x = xOutput.format(x);
    var _y = yOutput.format(y);
    var _z = zOutput.format(z);
    if (!useMultiAxisFeatures && !isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1))) {
      if (!allowIndexingWCSProbing && currentSection.strategy == "probe") {
        error(localize("Updating WCS / work offset using probing is only supported by the CNC in the WCS frame."));
        return;
      }
    }

    if (_z && (z >= getCurrentPosition().z)) {
      writeBlock(gMotionModal.format(1), _z, feedOutput.format(cycle.feedrate));
    }
    if (_x || _y) {
      writeBlock(gMotionModal.format(1), _x, _y, feedOutput.format(cycle.feedrate));
    }
    if (_z && (z < getCurrentPosition().z)) {
      writeBlock(gMotionModal.format(1), _z, feedOutput.format(cycle.feedrate));
    }

    currentWorkOffset = undefined;

    var singleLine = getProperty("singleLineProbing");
    var probingArguments = getProbingArguments(cycle, singleLine);

    var _PRNUM = (!singleLine ? "_PRNUM=" : "") + toolProbeFormat.format(1); // Probingtyp, Probingnumber. 3 digits. 1st = (0=Multiprobe, 1=Monoprobe), 2nd/3rd = 2digit Probing-Tool-Number
    var _VMS = (!singleLine ? "_VMS=" : "") + xyzFormat.format(0); // Feed of probing. 0=150mm/min, >1=300m/min
    var _TSA = (!singleLine ? "_TSA=" : "") + (cycleType.indexOf("angle") != -1 ? xyzFormat.format(0.1) : xyzFormat.format(1)); // tolerance (trust area) //angle tolerance (in the simulation he move to the second point with this angle)
    var _NMSP = (!singleLine ? "_NMSP=" : "") + xyzFormat.format(1); // number of measurements at same spot
    var _ID = probingArguments.isIncrementalDepth ? (!singleLine ? "_ID=" : "") + xyzFormat.format(cycle.depth * -1) : undefined; // incremental depth infeed in Z, direction over sign (only by circular boss, wall resp. rectangle and by hole/channel/circular boss/wall with guard zone)
    var _SETVAL = (!probingArguments.isRectangularFeature ? (!singleLine ? "_SETVAL=" : "") : undefined);
    _SETVAL = (cycle.width1 && !probingArguments.isRectangularFeature ? _SETVAL + xyzFormat.format(cycle.width1) : _SETVAL);
    var _SETV0 = (probingArguments.isRectangularFeature ? (!singleLine ? "_SETV[0]=" : "") + (cycle.width1 ? xyzFormat.format(cycle.width1) : (singleLine ? xyzFormat.format(0) : "")) : undefined); // nominal value in X
    var _SETV1 = (probingArguments.isRectangularFeature ? (!singleLine ? "_SETV[1]=" : "") + (cycle.width2 ? xyzFormat.format(cycle.width2) : "") : undefined); // nominal value in Y
    var _DMODE = 0;
    var _FA = (!singleLine ? "_FA=" : "") + // measuring range (distance to surface), total measuring range=2*_FA in mm
      xyzFormat.format(cycle.probeClearance ? cycle.probeClearance : cycle.probeOvertravel);
    var _RA = (probingArguments.isAngleProbing ? (!singleLine ? "_RA=" : "") + xyzFormat.format(0) : undefined); // correction of angle, 0 dont rotate the table;
    var _STA1 = (probingArguments.isAngleProbing ? (!singleLine ? "_STA1=" : "") + xyzFormat.format(0) : undefined); // angle of the plane
    var _TDIF = probingArguments._TDIF;
    var _TNUM = probingArguments._TNUM;
    var _TMV = probingArguments._TMV;
    var _TUL = probingArguments._TUL;
    var _TLL = probingArguments._TLL;
    var _K = (!singleLine ? "_K=" : "");
    var _KNUM = probingArguments._KNUM;
    if (_KNUM == undefined) {
      _KNUM = (!singleLine ? "_KNUM=" + xyzFormat.format(probeOutputWorkOffset) : xyzFormat.format(10000 + probeOutputWorkOffset)); // automatically input in active workOffset. e.g. _KNUM=1 (G54)
    }

    if (!getProperty("toolAsName") && tool.number >= 100) {
      error(localize("Tool number is out of range for probing. Tool number must be below 100."));
      return;
    }

    if (cycle.updateToolWear) {
      if (getProperty("toolAsName") && !cycle.toolDescription) {
        if (hasParameter("operation-comment")) {
          error(subst(localize("Tool description is empty in operation \"%1\"."), getParameter("operation-comment").toUpperCase()));
        } else {
          error(localize("Tool description is empty."));
        }
        return;
      }
      if (!probingArguments.isAngleProbing) {
        var array = [100, 51, 34, 26, 21, 17, 15, 13, 12, 9, 0];
        var factor = cycle.toolWearErrorCorrection;

        for (var i = 1; i < array.length; ++i) {
          var range = new Range(array[i - 1], array[i]);
          if (range.isWithin(factor)) {
            _K += (factor <= range.getMaximum()) ? i : i + 1;
            break;
          }
        }
      } else {
        _K = undefined;
      }
    } else {
      _K = undefined;
    }

    writeBlock(
      conditional(probingArguments.isWrongSizeAction, "_CBIT[2]=1 "),
      conditional(cycle.updateToolWear, "_CHBIT[3]=1 "), //0 tool data are written in geometry, wear is deleted; 1 difference is written in tool wear data geometry remain unchanged
      conditional(cycle.printResults, "_CHBIT[10]=1 _CHBIT[11]=1")
    );

    var cycleParameters;

    switch (cycleType) {
    case "probing-x":
    case "probing-y":
      cycleParameters = {cycleNumber:978, _MA:cycleType == "probing-x" ? 1 : 2, _MVAR:0};
      _SETVAL += xyzFormat.format((cycleType == "probing-x" ? x : y) + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2));
      writeBlock(gMotionModal.format(1), zOutput.format(z - cycle.depth), feedOutput.format(cycle.feedrate));
      break;
    case "probing-z":
      cycleParameters = {cycleNumber:978, _MA:3, _MVAR:0};
      _SETVAL += xyzFormat.format(z - cycle.depth);
      writeBlock(gMotionModal.format(1), zOutput.format(z - cycle.depth + cycle.probeClearance));
      break;
    case "probing-x-channel":
      cycleParameters = {cycleNumber:977, _MA:1, _MVAR:3};
      writeBlock(gMotionModal.format(1) + " " + zOutput.format(z - cycle.depth));
      break;
    case "probing-x-channel-with-island":
      cycleParameters = {cycleNumber:977, _MA:1, _MVAR:3};
      break;
    case "probing-y-channel":
      cycleParameters = {cycleNumber:977, _MA:2, _MVAR:3};
      writeBlock(gMotionModal.format(1) + " " + zOutput.format(z - cycle.depth));
      break;
    case "probing-y-channel-with-island":
      cycleParameters = {cycleNumber:977, _MA:2, _MVAR:3};
      break;
      /* not supported currently, need min. 3 points to call this cycle (same as heindenhain)
    case "probing-xy-inner-corner":
      cycleParameters = {cycleNumber: 961, _MVAR: 105};
      break;
    case "probing-xy-outer-corner":
      cycleParameters = {cycleNumber: 961, _MVAR: 106};
      _ID = (!singleLine ? "_ID=" : "") + xyzFormat.format(0);
      break;
      */
    case "probing-x-wall":
    case "probing-y-wall":
      cycleParameters = {cycleNumber:977, _MA:cycleType == "probing-x-wall" ? 1 : 2, _MVAR:4};
      break;
    case "probing-xy-circular-hole":
      cycleParameters = {cycleNumber:977, _MVAR:1};
      writeBlock(gMotionModal.format(1) + " " + zOutput.format(cycle.bottom));
      break;
    case "probing-xy-circular-hole-with-island":
      cycleParameters = {cycleNumber:977, _MVAR:1};
      // writeBlock(conditional(cycleType == "probing-xy-circular-hole", gMotionModal.format(1) + " " + zOutput.format(z - cycle.depth)));
      break;
    case "probing-xy-circular-boss":
      cycleParameters = {cycleNumber:977, _MVAR:2};
      break;
    case "probing-xy-rectangular-hole":
      cycleParameters = {cycleNumber:977, _MVAR:5};
      writeBlock(gMotionModal.format(1) + " " + zOutput.format(z - cycle.depth));
      break;
    case "probing-xy-rectangular-boss":
      cycleParameters = {cycleNumber:977, _MVAR:6};
      break;
    case "probing-xy-rectangular-hole-with-island":
      cycleParameters = {cycleNumber:977, _MVAR:5};
      break;
    case "probing-x-plane-angle":
    case "probing-y-plane-angle":
      cycleParameters = {cycleNumber:998, _MA:cycleType == "probing-x-plane-angle" ? 201 : 102, _MVAR:5};
      _ID = (!singleLine ? "_ID=" : "") + xyzFormat.format(cycle.probeSpacing); // distance between points
      _SETVAL += xyzFormat.format((cycleType == "probing-x-plane-angle" ? x : y) + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2));
      writeBlock(gMotionModal.format(1), zOutput.format(z - cycle.depth));
      writeBlock(gMotionModal.format(1), cycleType == "probing-x-plane-angle" ? yOutput.format(y - cycle.probeSpacing / 2) : xOutput.format(x - cycle.probeSpacing / 2));
      break;
    default:
      cycleNotSupported();
    }

    var multiplier = (probingArguments.probeWCS || probingArguments.isAngleProbing) ? 100 : 0; // 1xx for datum shift correction
    multiplier = (cycleType.indexOf("island") != -1) ? 1000 + multiplier : multiplier; // 1xxx for guardian zone
    var _MVAR = cycleParameters._MVAR != undefined ? (!singleLine ? "_MVAR=" : "") + xyzFormat.format(multiplier + cycleParameters._MVAR) : undefined; // CYCLE TYPE
    var _MA = cycleParameters._MA != undefined ? (!singleLine ? "_MA=" : "") + xyzFormat.format(cycleParameters._MA) : undefined;

    var procParam = [];
    if (!singleLine) {
      writeBlock(_TSA, _PRNUM, _VMS, _NMSP, _FA, _TDIF, _TUL, _TLL, _K, _TMV);
      writeBlock(_MVAR, _SETV0, _SETV1, _SETVAL, _MA, _ID, _RA, _STA1, _TNUM, _KNUM);
      writeBlock("CYCLE" + xyzFormat.format(cycleParameters.cycleNumber));
    } else {
      switch (cycleParameters.cycleNumber) {
      case 977:
        procParam = [_MVAR, _KNUM, "", _PRNUM, _SETVAL, _SETV0, _SETV1,
          _FA, _TSA, _STA1, _ID, "", "", _MA, _NMSP, _TNUM,
          "", "", _TDIF, _TUL, _TLL, _TMV, _K, "", "", _DMODE].join(cycleSeparator);
        break;
      case 998:
        procParam = [_MVAR, _KNUM, _RA, _PRNUM, _SETVAL, _STA1,
          "", _FA, _TSA, _MA, "", _ID, _SETV0, _SETV1,
          "", "", _NMSP, "", _DMODE].join(cycleSeparator);
        break;
      case 978:
        procParam = [_MVAR, _KNUM, "", _PRNUM, _SETVAL,
          _FA, _TSA, _MA, "", _NMSP, _TNUM, "", "", _TDIF,
          _TUL, _TLL, _TMV, _K, "", "", _DMODE].join(cycleSeparator);
        break;
      default:
        cycleNotSupported();
      }
      writeBlock(
        ("CYCLE" + xyzFormat.format(cycleParameters.cycleNumber)) + "(" + (procParam) + cycleSeparator + ")"
      );
    }

    if (probingArguments.isOutOfPositionAction)  {
      if (cycleParameters.cycleNumber != 977) {
        writeComment("Out of position action is only supported with CYCLE977.");
      } else {
        var positionUpperTolerance = xyzFormat.format(cycle.tolerancePosition);
        var positionLowerTolerance = xyzFormat.format(cycle.tolerancePosition * -1);
        writeBlock(
          "IF((_OVR[5]>" + positionUpperTolerance + ")" +
          " OR (_OVR[6]>" + positionUpperTolerance + ")" +
          " OR (_OVR[5]<" + positionLowerTolerance + ")" +
          " OR (_OVR[6]<" + positionLowerTolerance + ")" +
          ")"
        );
        writeBlock("SETAL(62990,\"OUT OF POSITION TOLERANCE\")");
        onCommand(COMMAND_STOP);
        writeBlock("ENDIF");
      }
    }

    if (probingArguments.isAngleAskewAction) {
      var angleUpperTolerance = xyzFormat.format(cycle.toleranceAngle);
      var angleLowerTolerance = xyzFormat.format(cycle.toleranceAngle * -1);
      writeBlock(
        "IF((_OVR[16]>" + angleUpperTolerance + ")" +
        " OR (_OVR[16]<" + angleLowerTolerance + ")" +
        ")"
      );
      writeBlock("SETAL(62991,\"OUT OF ANGLE TOLERANCE\")");
      onCommand(COMMAND_STOP);
      writeBlock("ENDIF");
    }
    return;
  }

  if (!expandCurrentCycle) {
    if (incrementalMode) { // set current position to retract height
      setCyclePosition(cycle.retract);
    }
    var _x = xOutput.format(x);
    var _y = yOutput.format(y);
    /*zOutput.format(z)*/
    if (_x || _y) {
      writeBlock(_x, _y);
    }
    if (incrementalMode) { // set current position to clearance height
      setCyclePosition(cycle.clearance);
    }
  } else {
    cycleSubprogramIsActive = false;
    expandCyclePoint(x, y, z);
  }
}

function onCycleEnd() {
  if (isProbeOperation()) {
    zOutput.reset();
    gMotionModal.reset();
    writeBlock(gMotionModal.format(1), zOutput.format(cycle.retract), feedOutput.format(cycle.feedrate));
  } else {
    if (cycleSubprogramIsActive) {
      if (firstPattern) { // bob
        subprogramEnd();
      }
      cycleSubprogramIsActive = false;
    }
    if (!expandCurrentCycle) {
      writeBlock("MCALL"); // end modal cycle
      writeBlock(gModeModal.format(291)) //switch to iso mode
      zOutput.reset();
    }
  }
  setWCS();

  zOutput.reset();
}

var pendingRadiusCompensation = -1;

function onRadiusCompensation() {
  pendingRadiusCompensation = radiusCompensation;
}

function onRapid(_x, _y, _z) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      error(localize("Radius compensation mode cannot be changed at rapid traversal."));
      return;
    }
    writeBlock(gMotionModal.format(0), x, y, z);
    forceFeed();
  }
}

function onLinear(_x, _y, _z, feed) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var f = getFeed(feed);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      pendingRadiusCompensation = -1;

      if (tool.diameterOffset != 0) {
        warningOnce(localize("Diameter offset is not supported."), WARNING_DIAMETER_OFFSET);
      }

      writeBlock(gPlaneModal.format(17));
      switch (radiusCompensation) {
      case RADIUS_COMPENSATION_LEFT:
        writeBlock(gMotionModal.format(1), gFormat.format(41), x, y, z, f);
        break;
      case RADIUS_COMPENSATION_RIGHT:
        writeBlock(gMotionModal.format(1), gFormat.format(42), x, y, z, f);
        break;
      default:
        writeBlock(gMotionModal.format(1), gFormat.format(40), x, y, z, f);
      }
    } else {
      writeBlock(gMotionModal.format(1), x, y, z, f);
    }
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      forceFeed(); // force feed on next line
    } else {
      writeBlock(gMotionModal.format(1), f);
    }
  }
}

function onRapid5D(_x, _y, _z, _a, _b, _c) {
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation mode cannot be changed at rapid traversal."));
    return;
  }
  if (!currentSection.isOptimizedForMachine()) {
    forceXYZ(); // required
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = currentSection.isOptimizedForMachine() ? aOutput.format(_a) : a3Output.format(_a);
  var b = currentSection.isOptimizedForMachine() ? bOutput.format(_b) : b3Output.format(_b);
  var c = currentSection.isOptimizedForMachine() ? cOutput.format(_c) : c3Output.format(_c);
  if (x || y || z || a || b || c) {
    writeBlock(gMotionModal.format(0), x, y, z, a, b, c);
  }
  forceFeed();
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed, feedMode) {
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for 5-axis move."));
    return;
  }

  if (!currentSection.isOptimizedForMachine()) {
    forceXYZ(); // required
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = currentSection.isOptimizedForMachine() ? aOutput.format(_a) : a3Output.format(_a);
  var b = currentSection.isOptimizedForMachine() ? bOutput.format(_b) : b3Output.format(_b);
  var c = currentSection.isOptimizedForMachine() ? cOutput.format(_c) : c3Output.format(_c);
  if (feedMode == FEED_INVERSE_TIME) {
    forceFeed();
  }
  var f = feedMode == FEED_INVERSE_TIME ? inverseTimeOutput.format(feed) : getFeed(feed);
  var fMode = feedMode == FEED_INVERSE_TIME ? 93 : 94;

  if (x || y || z || a || b || c) {
    writeBlock(gFeedModeModal.format(fMode), gMotionModal.format(1), x, y, z, a, b, c, f);
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      forceFeed(); // force feed on next line
    } else {
      writeBlock(gFeedModeModal.format(fMode), gMotionModal.format(1), f);
    }
  }
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {

  var start = getCurrentPosition();
  var revolutions = Math.abs(getCircularSweep()) / (2 * Math.PI);
  var turns = useArcTurn ? (revolutions % 1) == 0 ? revolutions - 1 : Math.floor(revolutions) : 0; // full turns
  var useradius = false; //getProperty("useRadius")
  var arcMode = "IJK" //getProperty("arcModeSet"); //CT, IJK, RAD
  var useIJK = true
  var useCT = true;
  var useCIP = true; //getProperty("useCIP")
  var linZ = true; //linearize all Z related planes - - CUBLEX 840Di doesn't seem to like any arcs in Z planes
  var minR = 100; //radius INCH to switch from CIP to IJK arcs in Z planes - - set to 100 to always do CIP for now but ignored all together if linearized

  if (isFullCircle()) { //full circle
    writeComment("untested !!! full circle")
    if (isHelical()) {
      linearize(tolerance);
      return;
    }
    if (turns > 1) {
      error(localize("Multiple turns are not supported."));
      return;
    }
    // G90/G91 are dont care when we do not used XYZ  <-- wtf is this sentence fusion team? -Billy
    switch (getCircularPlane()) {  //siemens technically doesn't like calling G17-19 during the middle of running the program so that has been ommitted here
    case PLANE_XY:
      if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
        if ((gPlaneModal.getCurrent() !== null) && (gPlaneModal.getCurrent() != 17)) {
          error(localize("Plane cannot be changed when radius compensation is active."));
          return;
        }
      }
      writeBlock(gMotionModal.format(clockwise ? 2 : 3), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed));
      break;
    case PLANE_ZX:
      if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
        if ((gPlaneModal.getCurrent() !== null) && (gPlaneModal.getCurrent() != 18)) {
          error(localize("Plane cannot be changed when radius compensation is active."));
          return;
        }
      }
      writeBlock(gMotionModal.format(clockwise ? 2 : 3), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));//prolly wont work
      break;
    case PLANE_YZ:
      if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
        if ((gPlaneModal.getCurrent() !== null) && (gPlaneModal.getCurrent() != 19)) {
          error(localize("Plane cannot be changed when radius compensation is active."));
          return;
        }
      }
      writeBlock(gMotionModal.format(clockwise ? 2 : 3), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));//prolly wont work
      break;
    default:
      writeComment("linearized full circle arc")
      linearize(tolerance);
    }
  } else if (arcMode == "IJK") { // Custom IJK for non full circles
    
    switch (getCircularPlane()) {
    case PLANE_XY:
      if (isHelical()) {
        xOutput.reset();
        yOutput.reset();
      }
      if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
        if ((gPlaneModal.getCurrent() !== null) && (gPlaneModal.getCurrent() != 17)) {
          error(localize("Plane cannot be changed when radius compensation is active."));
          return;
        }
      }
      // arFormat.format(Math.abs(getCircularSweep()));
      if (turns > 0) {
        writeComment("untested !!!! arc turn > 0")
        writeBlock(gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), zOutput.format(z), getFeed(feed), "TURN=" + turns);
      } else {
        writeBlock(gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), zOutput.format(z), getFeed(feed));
      }
      break;
    case PLANE_ZX:
      if (isHelical()) {
        xOutput.reset();
        zOutput.reset();
      }
      if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
        if ((gPlaneModal.getCurrent() !== null) && (gPlaneModal.getCurrent() != 18)) {
          error(localize("Plane cannot be changed when radius compensation is active."));
          return;
        }
      }
      if (turns > 0) {
          writeComment("arc turn mode")
          linearize(tolerance);
      } else {
          if (useCIP) { // allow CIP
              var ip = getPositionU(0.5);
              writeBlock(getFeed(feed));
              writeBlock(
                "CIP ",
                xOutput.format(x),
                yOutput.format(y),
                zOutput.format(z),
                cipiOutput.format(ip.x),
                cipjOutput.format(ip.y),
                cipkOutput.format(ip.z));
              //gMotionModal.reset();
              //gPlaneModal.reset();
            } else {
              writeComment("linearized ijk zx arc")
              linearize(tolerance);
            }
      }
      break;
    case PLANE_YZ:
      if (isHelical()) {
        yOutput.reset();
        zOutput.reset();
      }
      if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
        if ((gPlaneModal.getCurrent() !== null) && (gPlaneModal.getCurrent() != 19)) {
          error(localize("Plane cannot be changed when radius compensation is active."));
          return;
        }
      }
      if (turns > 0) {
          writeComment("arc turn mode")
          writeComment("linearized arc")
          linearize(tolerance);
      } else {
          if (useCIP) { // allow CIP
              var ip = getPositionU(0.5);
              writeBlock(getFeed(feed));
              writeBlock(
                "CIP ",
                xOutput.format(x),
                yOutput.format(y),
                zOutput.format(z),
                cipiOutput.format(ip.x),
                cipjOutput.format(ip.y),
                cipkOutput.format(ip.z));
              //gMotionModal.reset();
              //gPlaneModal.reset();
            } else {
              writeComment("linearized ijk yz arc")
              linearize(tolerance);
            }
      }
      break;
    default:
      if (turns > 1) {
        error(localize("Multiple turns are not supported."));
        return;
      }
      if (useCIP) { // allow CIP
        var ip = getPositionU(0.5);
        writeBlock(getFeed(feed));
        writeBlock(
          "CIP ",
          xOutput.format(x),
          yOutput.format(y),
          zOutput.format(z),
          cipiOutput.format(ip.x),
          cipjOutput.format(ip.y),
          cipkOutput.format(ip.z)
        );
        //gMotionModal.reset();
        //gPlaneModal.reset();
      } else {
        writeComment("linearized ijk arc")
        linearize(tolerance);
      }
    }

  } else if (arcMode == "CT") { // CT mode
    switch (getCircularPlane()) {
    case PLANE_XY:
      if (isHelical()) {
        xOutput.reset();
        yOutput.reset();
      }
      if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
        if ((gPlaneModal.getCurrent() !== null) && (gPlaneModal.getCurrent() != 17)) {
          error(localize("Plane cannot be changed when radius compensation is active."));
          return;
        }
      }
      // arFormat.format(Math.abs(getCircularSweep()));
      if (turns > 0) {
        writeComment("untested !!!! arc turn > 0")
        writeBlock(gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), zOutput.format(z), getFeed(feed), "TURN=" + turns);
      } else {
        writeBlock(getFeed(feed));
        writeBlock("CT", xOutput.format(x), yOutput.format(y), zOutput.format(z), getFeed(feed));
      }
      break;
    case PLANE_ZX:
      if (isHelical()) {
        xOutput.reset();
        zOutput.reset();
      }
      if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
        if ((gPlaneModal.getCurrent() !== null) && (gPlaneModal.getCurrent() != 18)) {
          error(localize("Plane cannot be changed when radius compensation is active."));
          return;
        }
      }
      if (turns > 0) {
          writeComment("linearized ct zx arc")
          linearize(tolerance);
      } else {
        writeBlock(getFeed(feed));
        writeBlock("CT", xOutput.format(x), yOutput.format(y), zOutput.format(z), getFeed(feed));
      }
      break;
    case PLANE_YZ:
      if (isHelical()) {
        yOutput.reset();
        zOutput.reset();
      }
      if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
        if ((gPlaneModal.getCurrent() !== null) && (gPlaneModal.getCurrent() != 19)) {
          error(localize("Plane cannot be changed when radius compensation is active."));
          return;
        }
      }
      if (turns > 0) {
          writeComment("linearized ct zx arc")
          linearize(tolerance);
      } else {
        writeBlock(getFeed(feed));
        writeBlock("CT", xOutput.format(x), yOutput.format(y), zOutput.format(z), getFeed(feed));
      }
      break;
    default:
      if (turns > 1) {
        error(localize("Multiple turns are not supported."));
        return;
      }
      writeBlock(getFeed(feed));
      writeBlock("CT", xOutput.format(x), yOutput.format(y), zOutput.format(z), getFeed(feed));
    }



  } else { //rad mode
    if (isHelical()) {
      writeComment("linearized h r arc")
      linearize(tolerance);
      return;
    }
    var r = getCircularRadius();
    if (toDeg(getCircularSweep()) > (180 + 1e-9)) {
      r = -r; // allow up to <360 deg arcs
    }
    forceXYZ();

    // radius mode is only supported on PLANE_XY
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), "CR=" + xyzFormat.format(r), getFeed(feed));
      break;
    case PLANE_ZX:
      //writeBlock(gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed)); //doesn't work
      writeComment("linearized r arc")
      linearize(tolerance);
      break;
    case PLANE_YZ:
      //writeBlock(gMotionModal.format(clockwise ? 2 : 3), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed)); //doesn't work
      writeComment("linearized r arc")
      linearize(tolerance);
      break;
    default:
      writeComment("linearized r arc")
      linearize(tolerance);
    }
  }
}

var currentCoolantMode = COOLANT_OFF;
var coolantOff = undefined;
var forceCoolant = false;

function setCoolant(coolant) {
  var coolantCodes = getCoolantCodes(coolant);
  if (Array.isArray(coolantCodes)) {
    if (singleLineCoolant) {
      writeBlock(coolantCodes.join(getWordSeparator()));
    } else {
      for (var c in coolantCodes) {
        writeBlock(coolantCodes[c]);
      }
    }
    return undefined;
  }
  return coolantCodes;
}

function getCoolantCodes(coolant) {
  var multipleCoolantBlocks = new Array(); // create a formatted array to be passed into the outputted line
  if (!coolants) {
    error(localize("Coolants have not been defined."));
  }
  if (tool.type == TOOL_PROBE) { // avoid coolant output for probing
    coolant = COOLANT_OFF;
  }
  if (coolant == currentCoolantMode && (!forceCoolant || coolant == COOLANT_OFF))  {
    return undefined; // coolant is already active
  }
  if ((coolant != COOLANT_OFF) && (currentCoolantMode != COOLANT_OFF) && (coolantOff != undefined) && !forceCoolant) {
    if (Array.isArray(coolantOff)) {
      for (var i in coolantOff) {
        multipleCoolantBlocks.push(coolantOff[i]);
      }
    } else {
      multipleCoolantBlocks.push(coolantOff);
    }
  }
  forceCoolant = false;

  var m;
  var coolantCodes = {};
  for (var c in coolants) { // find required coolant codes into the coolants array
    if (coolants[c].id == coolant) {
      coolantCodes.on = coolants[c].on;
      if (coolants[c].off != undefined) {
        coolantCodes.off = coolants[c].off;
        break;
      } else {
        for (var i in coolants) {
          if (coolants[i].id == COOLANT_OFF) {
            coolantCodes.off = coolants[i].off;
            break;
          }
        }
      }
    }
  }
  if (coolant == COOLANT_OFF) {
    m = !coolantOff ? coolantCodes.off : coolantOff; // use the default coolant off command when an 'off' value is not specified
  } else {
    coolantOff = coolantCodes.off;
    m = coolantCodes.on;
  }

  if (!m) {
    onUnsupportedCoolant(coolant);
    m = 9;
  } else {
    if (Array.isArray(m)) {
      for (var i in m) {
        multipleCoolantBlocks.push(m[i]);
      }
    } else {
      multipleCoolantBlocks.push(m);
    }
    currentCoolantMode = coolant;
    for (var i in multipleCoolantBlocks) {
      if (typeof multipleCoolantBlocks[i] == "number") {
        multipleCoolantBlocks[i] = mFormat.format(multipleCoolantBlocks[i]);
      }
    }
    return multipleCoolantBlocks; // return the single formatted coolant value
  }
  return undefined;
}

var mapCommand = {
  COMMAND_END                     : 30,
  COMMAND_SPINDLE_CLOCKWISE       : 3,
  COMMAND_SPINDLE_COUNTERCLOCKWISE: 4,
  COMMAND_STOP_SPINDLE            : 5,
  COMMAND_ORIENTATE_SPINDLE       : 19,
  COMMAND_LOAD_TOOL               : 6
};

function onCommand(command) {
  switch (command) {
  case COMMAND_STOP:
    writeBlock(mFormat.format(0));
    forceSpindleSpeed = true;
    forceCoolant = true;
    return;
  case COMMAND_OPTIONAL_STOP:
    writeBlock(mFormat.format(1));
    forceSpindleSpeed = true;
    forceCoolant = true;
    return;
  case COMMAND_START_SPINDLE:
    onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
    return;
  case COMMAND_LOCK_MULTI_AXIS:
    writeBlock(mFormat.format(131)); //lock 4th and 5th
    return;
  case COMMAND_UNLOCK_MULTI_AXIS:
    writeBlock(mFormat.format(132)); //unlock 4th and 5th
    return;
  case COMMAND_START_CHIP_TRANSPORT:
    writeBlock(mFormat.format(15)); //cublex42 flush coolant  option
    return;
  case COMMAND_STOP_CHIP_TRANSPORT:
    writeBlock(mFormat.format(16)); //cublex42 flush coolant option
    return;
  case COMMAND_BREAK_CONTROL:
    return;
  case COMMAND_TOOL_MEASURE:
    return;
  case COMMAND_PROBE_ON:
    return;
  case COMMAND_PROBE_OFF:
    return;
  }

  var stringId = getCommandStringId(command);
  var mcode = mapCommand[stringId];
  if (mcode != undefined) {
    writeBlock(mFormat.format(mcode));
  } else {
    onUnsupportedCommand(command);
  }
}

function onSectionEnd() {
  if (typeof inspectionProcessSectionEnd == "function") {
    inspectionProcessSectionEnd();
  }

  if(smoothing.isAllowed){
    writeBlock("STARTFIFO")
    writeBlock("HOF"); //end FIFO buffer and smoothing
  };  

  if (currentSection.isMultiAxis()) {
    writeBlock("CYCLE800()");
    if (operationSupportsTCP || !machineConfiguration.isMultiAxisConfiguration()) {
      writeBlock("TRAFOOF");
      forceWorkPlane();
    }
    writeBlock(gFeedModeModal.format(94)); // inverse time feed off
  }


    //prepare for tool change if next tool is different
  
    //writeBlock(mFormat.format(229)); //begin tool change if next tool is different - - CUBLEX didn't like this M code even though it's in the manual -Billy

  if (isLastSection()) {    
    writeBlock(mFormat.format(5)); //spindle stop if last section
    setCoolant(COOLANT_OFF); //coolant off if last section
    if((tool.coolant) == "3" || (tool.coolant) == "8"){
      //writeBlock(gFormat.format(4), "P3000")
      writeComment("TSC shutoff sequence can be added here")
    };
  }else{
    if(getNextSection().getTool().number != tool.number){
        writeBlock(mFormat.format(5)); //spindle stop if next tool is different than current tool
        setCoolant(COOLANT_OFF); //coolant off if next tool is differnet than current tool (tool change coming up)
        if((tool.coolant) == "3" || (tool.coolant) == "8"){
          //writeBlock(gFormat.format(4), "P3000")
          writeComment("TSC shutoff sequence can be added here")
        }
    };
  }

  
  if (!isLastSection() && (getNextSection().getTool().coolant != tool.coolant)) {
    if (chipTransport == "auto" && ((getNextSection().getTool().diameter < .34) || (getNextSection().getTool().number != tool.number))){
      onCommand(COMMAND_STOP_CHIP_TRANSPORT); //chip management stop if next section doesn't have coolant and tool diamter or number is different
    }
  }




  writeBlock(gPlaneModal.format(17));
  


  if (true) {
    if (isRedirecting()) {
      if (firstPattern) {
        var finalPosition = getFramePosition(currentSection.getFinalPosition());
        var abc;
        if (currentSection.isMultiAxis() && machineConfiguration.isMultiAxisConfiguration()) {
          abc = currentSection.getFinalToolAxisABC();
        } else {
          abc = currentWorkPlaneABC;
        }
        if (abc == undefined) {
          abc = new Vector(0, 0, 0);
        }
        setAbsoluteMode(finalPosition, abc);
        subprogramEnd();
      }
    }
  }

  forceAny();
}

/** Output block to do safe retract and/or move to home position. */
function writeRetract() {
  var words = []; // store all retracted axes in an array
  var retractAxes = new Array(false, false, false);
  var method = getProperty("safePositionMethod");
  if (method == "clearanceHeight") {
    if (!is3D()) {
      error(localize("Safe retract option 'Clearance Height' is only supported when all operations are along the setup Z-axis."));
    }
    return;
  }
  validate(arguments.length != 0, "No axis specified for writeRetract().");

  for (i in arguments) {
    retractAxes[arguments[i]] = true;
  }
  if ((retractAxes[0] || retractAxes[1]) && !retracted) { // retract Z first before moving to X/Y home
    error(localize("Retracting in X/Y is not possible without being retracted in Z."));
    return;
  }
  // special conditions
  /*
  if (retractAxes[2]) { // Z doesn't use G53
    method = "G28";
  }
  */

  // define home positions
  var _xHome;
  var _yHome;
  var _zHome;
  if (method == "G28") {
    _xHome = toPreciseUnit(0, MM);
    _yHome = toPreciseUnit(0, MM);
    _zHome = toPreciseUnit(0, MM);
  } else {
    _xHome = machineConfiguration.hasHomePositionX() ? machineConfiguration.getHomePositionX() : toPreciseUnit(-17, IN);
    _yHome = machineConfiguration.hasHomePositionY() ? machineConfiguration.getHomePositionY() : toPreciseUnit(-8, IN);
    _zHome = machineConfiguration.getRetractPlane() != 0 ? machineConfiguration.getRetractPlane() : toPreciseUnit(0, IN);
  }
  for (var i = 0; i < arguments.length; ++i) {
    switch (arguments[i]) {
    case X:
      words.push("X" + xyzFormat.format(_xHome));
      xOutput.reset();
      break;
    case Y:
      words.push("Y" + xyzFormat.format(_yHome));
      yOutput.reset();
      break;
    case Z:
      words.push("Z" + xyzFormat.format(_zHome));
      zOutput.reset();
      retracted = true;
      break;
    default:
      error(localize("Unsupported axis specified for writeRetract()."));
      return;
    }
  }
  if (words.length > 0) {
    switch (method) {
    case "G28":
      gMotionModal.reset();
      gAbsIncModal.reset();
      writeBlock(gFormat.format(28), gAbsIncModal.format(91), words);
      writeBlock(gAbsIncModal.format(90));
      break;
    case "G53":
      gMotionModal.reset();
      writeBlock(gAbsIncModal.format(90), gFormat.format(53), words, dFormat.format(0)); // retract
      if (lengthOffset != 0) {
        writeBlock(dFormat.format(lengthOffset));
      }
      break;
    case "SUPA":
      gMotionModal.reset();
      writeBlock(gMotionModal.format(0), "SUPA", words, dFormat.format(0)); // retract

      //if (lengthOffset != 0) {  // for now taking out the tool offset call because I'm not sure it's necessary
      //  writeBlock(dFormat.format(lengthOffset));
      //}
      break;
    default:
      error(localize("Unsupported safe position method."));
      return;
    }
  }
}

// Start of onRewindMachine logic
/** Allow user to override the onRewind logic. */
function onRewindMachineEntry(_a, _b, _c) {
  return false;
}

/** Retract to safe position before indexing rotaries. */
function onMoveToSafeRetractPosition() {
  writeRetract(Z);
  writeRetract(X,Y);
  writeBlock("CYCLE800()"); //cancel cycle800 always
  
  // cancel TCP so that tool doesn't follow rotaries
  if (operationSupportsTCP || !machineConfiguration.isMultiAxisConfiguration()) {
    writeBlock("TRAFOOF");
  }
}

/** Rotate axes to new position above reentry position */
function onRotateAxes(_x, _y, _z, _a, _b, _c) {
  // position rotary axes
  xOutput.disable();
  yOutput.disable();
  zOutput.disable();
  invokeOnRapid5D(_x, _y, _z, _a, _b, _c);
  setCurrentABC(new Vector(_a, _b, _c));
  xOutput.enable();
  yOutput.enable();
  zOutput.enable();
}

/** Return from safe position after indexing rotaries. */
function onReturnFromSafeRetractPosition(_x, _y, _z) {
  // reinstate TCP / tool length compensation

  writeBlock(dFormat.format(lengthOffset));
  if (operationSupportsTCP || !machineConfiguration.isMultiAxisConfiguration()) {
    onCommand(COMMAND_STOP); //M0 before full 5 for double check
    writeBlock("TRAORI");
  }

  // position in XY
  forceXYZ();
  xOutput.reset();
  yOutput.reset();
  zOutput.disable();
  invokeOnRapid(_x, _y, _z);

  // position in Z
  zOutput.enable();
  invokeOnRapid(_x, _y, _z);
}
// End of onRewindMachine logic

function getOffsetCode() {
    // assumes a head configuration uses TCP on a Fanuc controller
    var offsetCode = 43;
    if (currentSection.isMultiAxis()) {
      if (machineConfiguration.isMultiAxisConfiguration()) {
        offsetCode = 43.4;
      } else if (!machineConfiguration.isMultiAxisConfiguration()) {
        offsetCode = 43.5;
      }
    }
    return offsetCode;
  }

function onClose() {
  writeln("");

  

  writeRetract(Z);
  writeRetract(X,Y);

  setWorkPlane(new Vector(0, 0, 0), true); // reset working plane
  forceWorkPlane(); // workplane needs forced
  setWorkPlane(new Vector(0, 0, 0), false); // reset working plane
  writeBlock("CYCLE800()");

  if (getProperty("useParkPosition")) {
    writeBlock(gFormat.format(91), gFormat.format(30), xOutput.format(0), yOutput.format(0), "P2", " ; PALLET READY TO CHANGE");
  }

  onCommand(COMMAND_STOP_CHIP_TRANSPORT); //always stop chip transport at end of program

  if(getProperty("isPalletProgram")){
    writeBlock(mFormat.format(1)); // optional stop
    writeComment("Return to main pallet program");
    writeBlock(mFormat.format(99)); // return to main program
    
    // redirect output to the new file (defined below)
    var jobdescription = (getGlobalParameter("job-description"))
    var startprogram = String(jobdescription).substr(0, Math.min(jobdescription.length, 20)); // set the subprogram name
    var path = FileSystem.getCombinedPath(FileSystem.getFolderPath(getOutputPath()), startprogram + "." + extension); // set the output path for the subprogram(s)
    var savedSequence = sequenceNumber

    redirectToFile(path);
    sequenceNumber = getProperty("sequenceNumberStart"); 
    //setProperty("showSequenceNumbers", "false") 
    //contents of redirected file
        
        //program header
        var jobdescription = (getGlobalParameter("job-description"))
        if (jobdescription) {
          writeComment(jobdescription);
        }
        writeln("")
        writeComment("Master program to call program from disk")  


      // write test version
      if (tv){ //true for writing test version, false for don't write test version
        if ((typeof getHeaderVersion == "function") && getHeaderVersion()) { 
      writeln("");
      writeComment(("TESTING POST PROCESSOR V") + getHeaderVersion() + " " + notes);
      writeComment("PROCEED WITH CAUTION !!!");
      writeBlock(mFormat.format(0));
        }
      }

      // write user name	
      if (hasGlobalParameter("username")) {
    var usernameprint = getGlobalParameter("username");
		  writeln("");
		  writeComment("Username: " + usernameprint);
		  }
		  
      // write date
      var d = new Date();
	    if (hasGlobalParameter("generated-at")) {
      var datetime = getGlobalParameter("generated-at");
		  writeComment("Program Posted: " + d.toLocaleDateString() + " " + (d.toLocaleTimeString()));
      }

      // dump post properties  
      if ((typeof getHeaderVersion == "function") && getHeaderVersion()) { 
      writeComment(("Matsuura Siemen Factory 840D Post V") + getHeaderVersion()); 
      }

      writeln("")
      writeComment("Chip management=" + chipTransport)

      writeln("")
      //Cancel any remaining calls
      // absolute coordinates and feed per min
      writeBlock(gFormat.format(90), gFormat.format(94));

      switch (unit) {
      case IN:
        writeBlock(gFormat.format(70)); // lengths
        //writeBlock(gFormat.format(700)); // feeds
      break;
      case MM:
        writeBlock(gFormat.format(71)); // lengths
        //writeBlock(gFormat.format(710)); // feeds
      break;
      }

      writeBlock(gFormat.format(64)); // continuous-path mode
      writeBlock(gFormat.format(17));
      writeBlock(gFormat.format(291)); //ISO mode
      writeRetract(Z);
      writeBlock("CYCLE800()")
      writeln("")

      //calling program notification
      writeComment("Calling Program " + programName);
      writeBlock('EXTCALL "'+ programName + "." + extension + '"')
      writeln("")


      writeBlock(gFormat.format(91), gFormat.format(30), "X0. Y0.", "P2", " ; PALLET READY TO CHANGE");
      writeBlock(mFormat.format(98), "P0001"); // call start program
      writeBlock(mFormat.format(30)); // stop program, spindle stop, coolant off
      writeln("")

      sequenceNumber = savedSequence


    
    
    closeRedirection(); 
    
  }
  
  onImpliedCommand(COMMAND_END);
  onImpliedCommand(COMMAND_STOP_SPINDLE);
  writeBlock(mFormat.format(30)); // stop program, spindle stop, coolant off
  if (subprograms.length > 0) {
    writeln("");
    write(subprograms);
  }
   
}

/*
function onTerminate() {
  var outputPath = getOutputPath(); 
  var programFilename = FileSystem.getFilename(outputPath); 
  var programSize = FileSystem.getFileSize(outputPath); 
  var postPath = findFile("Matsuura - Start - 840Di.CPS"); 
  var intermediatePath = getIntermediatePath(); 
  var a = "--property unit " + ((unit == IN) ? "0" : "1"); // use 0 for inch and 1 for mm 
  
  
  if (programName) {
      a += " --property programName \"'" + programName + "'\"";
    } 
  if (programComment) {
      a += " --property programComment \"'" + programComment + "'\"";
    } 
  a += " --property programFilename \"'" + programFilename + "'\""; 
  a += " --property programSize \"" + programSize + "\""; 
  a += " --noeditor --log temp.log \"" + postPath + "\" \"" + intermediatePath + "\" \"" + FileSystem.replaceExtension(outputPath, "SPF") + "\""; 
  execute(getPostProcessorPath(), a, false, ""); 
  executeNoWait("excel", "\"" + FileSystem.replaceExtension(outputPath, "SPF") + "\"", false, "");
}

function setProperty(property, value) {
  properties[property].current = value;
}
*/


// Start of smoothing logic
var smoothingSettings = {
  roughing          : 1, // roughing level for smoothing in automatic mode
  semi              : 5, // semi-roughing level for smoothing in automatic mode
  finishing         : 8, // finishing level for smoothing in automatic mode
  thresholdRoughing : toPreciseUnit(0.01, IN), // operations with stock/tolerance above that threshold will use roughing level in automatic mode
  thresholdFinishing: toPreciseUnit(0.005, IN), // operations with stock/tolerance below that threshold will use finishing level in automatic mode
  differenceCriteria: "level", // options: "level", "tolerance", "both". Specifies criteria when output smoothing codes
  autoLevelCriteria : "tolerance", // use "stock" or "tolerance" to determine levels in automatic mode
  cancelCompensation: true, // tool length compensation must be canceled prior to changing the smoothing level
  r1                : 1,
  r2                : 2,
  r3                : 3,
  r4                : 4,
  r5                : 5,
  r6                : 6,
  r7                : 7,
  r8                : 8,
  r9                : 9,
  r10               : 10
};

// >>>>> moved from Matsuura 30i post
// collected state below, do not edit
var smoothing = {
  cancel     : false, // cancel tool length prior to update smoothing for this operation
  isActive   : false, // the current state of smoothing
  isAllowed  : false, // smoothing is allowed for this operation
  isDifferent: false, // tells if smoothing levels/tolerances/both are different between operations
  level      : -1, // the active level of smoothing
  tolerance  : -1, // the current operation tolerance --default tolerance
  force      : false, // smoothing needs to be forced out in this operation
  prefix     : "R", // smoothing parameter prefix - changed to R from M
  type       : "IPC", // Type of smoothing IPC or MIMS - see matsuura documents regarding this
  filter     : -1,
  correction : -1 //used to bump the smoothing up or down a level if fusion smoothing is used
};

function initializeSmoothing() {
  var previousLevel = smoothing.level;
  var previousTolerance = smoothing.tolerance;
  var previousPrefix = smoothing.prefix;
  //var smoothingfilter = smoothing.filter;
  //var smoothingmultiplyer = smoothing.multiplyer;
  //var accelunit = smoothing.correction;

  // determine new smoothing levels and tolerances
  smoothing.level = 9999; //parseInt(getProperty("useSmoothing"), 10);
  smoothing.level = isNaN(smoothing.level) ? -1 : smoothing.level;
  smoothing.tolerance = Math.max(getParameter("operation:tolerance", 0), 0);
  smoothing.type = "IPC"; //Matsuura smoothing type
  smoothing.filter = Math.max(getParameter("operation:smoothingFilterTolerance", 0), 0);
  smoothing.correction = 0

  // automatically determine smoothing level
  if (smoothing.level == 9999) {
    if (smoothingSettings.autoLevelCriteria == "stock") { // determine auto smoothing level based on stockToLeave
      var stockToLeave = xyzFormat.getResultingValue(getParameter("operation:stockToLeave", 0));
      var verticalStockToLeave = xyzFormat.getResultingValue(getParameter("operation:verticalStockToLeave", 0));
      if ((stockToLeave >= smoothingSettings.thresholdRoughing) && (verticalStockToLeave >= smoothingSettings.thresholdRoughing)) {
        smoothing.level = smoothingSettings.roughing; // set roughing level
      } else {
        if ((stockToLeave >= smoothingSettings.thresholdFinishing) && (verticalStockToLeave >= smoothingSettings.thresholdFinishing)) { //???
          smoothing.level = smoothingSettings.semi; // set semi level
        } else {
          smoothing.level = smoothingSettings.finishing; // set finishing level
        }
      }
    } else { // detemine auto smoothing level based on operation tolerance instead of stockToLeave
      //smoothing.level = smoothing.tolerance < smoothingSettings.thresholdRoughing ? smoothing.tolerance > smoothingSettings.thresholdFinishing ?
        //smoothingSettings.semi : smoothingSettings.finishing : smoothingSettings.roughing;

      const y = smoothing.filter 
      switch(true){
      case (y <= 0.0014):
        smoothing.correction = 0;
        break;
      case (y < 0.210):
        smoothing.correction = -1;
        break;
      default:
        error(localize("Smoothing tolerance out of range."));
        return;
      }  


      const x = smoothing.tolerance  
      switch(true){
      case (x < 0.0005):
        smoothing.level = smoothingSettings.r10 + smoothing.correction;
        break;
      case (x < 0.0008):
        smoothing.level = smoothingSettings.r9 + smoothing.correction;
        break;
      case (x < 0.0012):
        smoothing.level = smoothingSettings.r8 + smoothing.correction;
        break;
      case (x < 0.0030):
        smoothing.level = smoothingSettings.r7 + smoothing.correction;
        break;
      case (x < 0.0050):
        smoothing.level = smoothingSettings.r6 + smoothing.correction;
        break;
      case (x < 0.0090):
        smoothing.level = smoothingSettings.r5 + smoothing.correction;
        break;
      case (x < 0.0120):
        smoothing.level = smoothingSettings.r4 + smoothing.correction;
        break;
      case (x < 0.0500):
        smoothing.level = smoothingSettings.r3 + smoothing.correction;
        break;
      case (x < 0.0900):
        smoothing.level = smoothingSettings.r2 + smoothing.correction;
        break;
      case (x < 0.210):
        smoothing.level = smoothingSettings.r1;
        break;
      default:
        error(localize("Tolerance out of range."));
        return;
      }
    }
  }
  //smoothing prefix based on type
  if(smoothing.type == "MIMS"){
    if (currentSection.checkGroup(STRATEGY_MULTIAXIS)) {
    smoothing.prefix = "F";
    } else if (currentSection.checkGroup(STRATEGY_2D)) {
    smoothing.prefix = "P";
    } else {
    smoothing.prefix = "M";
    }
  }
  else{
    smoothing.prefix = "HONR"
  }

  if (smoothing.level == -1) { // useSmoothing is disabled
    smoothing.isAllowed = false;
  } else { // do not output smoothing for the following operations
    smoothing.isAllowed = !(currentSection.getTool().type == TOOL_PROBE || currentSection.checkGroup(STRATEGY_DRILLING));
  }
  if (!smoothing.isAllowed) {
    smoothing.level = -1;
    smoothing.tolerance = -1;
  }

  switch (smoothingSettings.differenceCriteria) {
  case "level":
    smoothing.isDifferent = smoothing.level != previousLevel || smoothing.prefix != previousPrefix;
    break;
  case "tolerance":
    smoothing.isDifferent = smoothing.tolerance != previousTolerance || smoothing.prefix != previousPrefix;
    break;
  case "both":
    smoothing.isDifferent = smoothing.level != previousLevel || smoothing.tolerance != previousTolerance || smoothing.prefix != previousPrefix;
    break;
  default:
    error(localize("Unsupported smoothing criteria."));
    return;
  }

  // tool length compensation needs to be canceled when smoothing state/level changes
  if (smoothingSettings.cancelCompensation) {
    smoothing.cancel = !isFirstSection() && smoothing.isDifferent;
  }
}
// <<<<< INCLUDED FROM include_files/smoothing.cpi
// <<<<< INCLUDED FROM generic_posts/siemens-840d.cps

capabilities |= CAPABILITY_INSPECTION;
description = "CP - Matsuura - Multi - Siemens 840D";
minimumRevision = 45702;
longDescription = "Generic post for Siemens 840D with inspection capabilities. Note that the post will use D1 always for the tool length compensation as this is how most users work.";

// code for inspection support

properties.probeLocalVar = {
  title      : "Local variable start",
  description: "Specify the starting value for R variables that are to be used for calculations during inspection paths",
  group      : "probing",
  type       : "integer",
  value      : 1,
  scope      : "post"
};
properties.singleResultsFile = {
  title      : "Create Single Results File",
  description: "Set to false if you want to store the measurement results for each inspection toolpath in a seperate file",
  group      : "probing",
  type       : "boolean",
  value      : true,
  scope      : "post"
};
properties.resultsFileLocation = {
  title      : "Results file location",
  description: "Specify the folder location where the results file should be written",
  group      : "probing",
  type       : "string",
  value      : "",
  scope      : "post"
};
properties.useDirectConnection = {
  title      : "Stream Measured Point Data",
  description: "Set to true to stream inspection results",
  group      : "probing",
  type       : "boolean",
  value      : false,
  scope      : "post"
};
properties.probeResultsBuffer = {
  title      : "Measurement results store start",
  description: "Specify the starting value of R variables where measurement results are stored",
  group      : "probing",
  type       : "integer",
  value      : 1400,
  scope      : "post"
};
properties.probeNumberofPoints = {
  title      : "Measurement number of points to store",
  description: "This is the maximum number of measurement results that can be stored in the buffer",
  group      : "probing",
  type       : "integer",
  value      : 4,
  scope      : "post"
};
properties.controlConnectorVersion = {
  title      : "Results connector version",
  description: "Interface version for direct connection to read inspection results",
  group      : "probing",
  type       : "integer",
  value      : 1,
  scope      : "post"
};
properties.probeOnCommand = {
  title      : "Probe On Command",
  description: "The command used to turn the probe on, this can be a M code or sub program call",
  group      : "probing",
  type       : "string",
  value      : "",
  scope      : "post"
};
properties.probeOffCommand = {
  title      : "Probe Off Command",
  description: "The command used to turn the probe off, this can be a M code or sub program call",
  group      : "probing",
  type       : "string",
  value      : "",
  scope      : "post"
};
properties.commissioningMode = {
  title      : "Commissioning Mode",
  description: "Enables commissioning mode where M0 and messages are output at key points in the program",
  group      : "probing",
  type       : "boolean",
  value      : true,
  scope      : "post"
};
properties.probeInput = {
  title      : "Probe input number",
  description: "The measuring probe can be connected to hardware input 1 or 2, contact the probe installer for this information",
  group      : "probing",
  type       : "integer",
  value      : 1,
  scope      : "post"
};
properties.probePolarityIsNegative = {
  title      : "Probe signal polarity negative",
  description: "The probe can be configured to trigger on a rising or falling edge, contact the probe installer for this information",
  group      : "probing",
  type       : "boolean",
  value      : false,
  scope      : "post"
};
properties.probeCalibrationMethod = {
  title      : "Probe calibration Method",
  description: "Select the probe calibration method",
  group      : "probing",
  type       : "enum",
  values     : [
    {id:"Siemens GUD6", title:"Siemens pre-SW Version 4.4"},
    {id:"Autodesk", title:"Autodesk"},
    {id:"Siemens SD", title:"Siemens SW Version 4.4+"}
  ],
  value: "Autodesk",
  scope: "post"
};
properties.calibrationNCOutput = {
  title      : "Calibration NC Output Type",
  description: "Choose none if the NC program created is to be used for calibrating the probe",
  group      : "probing",
  type       : "enum",
  values     : [
    {id:"none", title:"none"},
    {id:"Ring Gauge", title:"Ring Gauge"}
  ],
  value: "none",
  scope: "post"
};
properties.stopOnInspectionEnd = {
  title      : "Stop on Inspection End",
  description: "Set to ON to output M0 at the end of each inspection toolpath",
  group      : "probing",
  type       : "boolean",
  value      : true,
  scope      : "post"
};

var ijkFormat = createFormat({decimals:5, forceDecimal:true});

// inspection variables
var inspectionVariables = {
  localVariablePrefix    : "R",
  systemVariableMeasuredX: "$AA_MW[X]",
  systemVariableMeasuredY: "$AA_MW[Y]",
  systemVariableMeasuredZ: "$AA_MW[Z]",
  probeEccentricityX     : "$SNS_MEA_WP_POS_DEV_AX1[0]",
  probeEccentricityY     : "$SNS_MEA_WP_POS_DEV_AX2[0]",
  probeCalibratedDiam    : "$SNS_MEA_WP_BALL_DIAM[0]",
  pointNumber            : 1,
  inspectionResultsFile  : "RESULTS",
  probeResultsBufferFull : false,
  probeResultsBufferIndex: 1,
  inspectionSections     : 0,
  inspectionSectionCount : 0,
  probeCalibrationSiemens: true,
};

var macroFormat = createFormat({prefix:inspectionVariables.localVariablePrefix, decimals:0});

function inspectionWriteVariables() {
  // loop through all NC stream sections to check for surface inspection
  for (var i = 0; i < getNumberOfSections(); ++i) {
    var section = getSection(i);
    if (isInspectionOperation(section)) {
      if (inspectionVariables.inspectionSections == 0) {
        if (getProperty("commissioningMode")) {
          //sequence numbers cannot be active while commissioning mode is on
          setProperty("showSequenceNumbers", "false");
        }
        var count = 1;
        var localVar = getProperty("probeLocalVar");
        var prefix = inspectionVariables.localVariablePrefix;
        inspectionVariables.probeRadius = prefix + count;
        inspectionVariables.xTarget = prefix + ++count;
        inspectionVariables.yTarget = prefix + ++count;
        inspectionVariables.zTarget = prefix + ++count;
        inspectionVariables.xMeasured = prefix + ++count;
        inspectionVariables.yMeasured = prefix + ++count;
        inspectionVariables.zMeasured = prefix + ++count;
        inspectionVariables.radiusDelta = prefix + ++count;
        inspectionVariables.macroVariable1 = prefix + ++count;
        inspectionVariables.macroVariable2 = prefix + ++count;
        inspectionVariables.macroVariable3 = prefix + ++count;
        inspectionVariables.macroVariable4 = prefix + ++count;
        inspectionVariables.macroVariable5 = prefix + ++count;
        inspectionVariables.macroVariable6 = prefix + ++count;
        inspectionVariables.macroVariable7 = prefix + ++count;
        if (getProperty("calibrationNCOutput") == "Ring Gauge") {
          inspectionVariables.measuredXStartingAddress = localVar;
          inspectionVariables.measuredYStartingAddress = localVar + 10;
          inspectionVariables.measuredZStartingAddress = localVar + 20;
          inspectionVariables.measuredIStartingAddress = localVar + 30;
          inspectionVariables.measuredJStartingAddress = localVar + 40;
          inspectionVariables.measuredKStartingAddress = localVar + 50;
        }
        inspectionValidateInspectionSettings();
        inspectionVariables.probeResultsReadPointer = prefix + (getProperty("probeResultsBuffer") + 2);
        inspectionVariables.probeResultsWritePointer = prefix + (getProperty("probeResultsBuffer") + 3);
        inspectionVariables.probeResultsCollectionActive = prefix + (getProperty("probeResultsBuffer") + 4);
        inspectionVariables.probeResultsStartAddress = getProperty("probeResultsBuffer") + 5;

        switch (getProperty("probeCalibrationMethod")) {
        case "Siemens GUD6":
          inspectionVariables.probeCalibratedDiam = "_WP[0,0]";
          inspectionVariables.probeEccentricityX = "_WP[0,7]";
          inspectionVariables.probeEccentricityY = "_WP[0,8]";
          break;
        case "Autodesk":
          inspectionVariables.probeCalibratedDiam = "_WP[3,0]";
          inspectionVariables.probeEccentricityX = "_WP[3,7]";
          inspectionVariables.probeEccentricityY = "_WP[3,8]";
          inspectionVariables.probeCalibrationSiemens = false;
        }
        // Siemens header only
        writeln("DEF INT RETURNCODE");
        writeln("DEF STRING[128] RESULTSFILE");
        writeln("DEF STRING[128] OUTPUT");

        if (getProperty("useDirectConnection")) {
          // check to make sure local variables used in results buffer and inspection do not clash
          var localStart = getProperty("probeLocalVar");
          var localEnd = count;
          var BufferStart = getProperty("probeResultsBuffer");
          var bufferEnd = getProperty("probeResultsBuffer") + ((3 * getProperty("probeNumberofPoints")) + 8);
          if ((localStart >= BufferStart && localStart <= bufferEnd) ||
            (localEnd >= BufferStart && localEnd <= bufferEnd)) {
            error(localize("Local variables defined (" + prefix + localStart + "-" + prefix + localEnd +
              ") and live probe results storage area (" + prefix + BufferStart + "-" + prefix + bufferEnd + ") overlap."
            ));
          }
          writeBlock(macroFormat.format(getProperty("probeResultsBuffer")) + " = " + getProperty("controlConnectorVersion"));
          writeBlock(macroFormat.format(getProperty("probeResultsBuffer") + 1) + " = " + getProperty("probeNumberofPoints"));
          writeBlock(inspectionVariables.probeResultsReadPointer + " = 0");
          writeBlock(inspectionVariables.probeResultsWritePointer + " = 1");
          writeBlock(inspectionVariables.probeResultsCollectionActive + " = 0");
          if (getProperty("probeResultultsBuffer") == 0) {
            error(localize("Probe Results Buffer start address cannot be zero when using a direct connection."));
          }
          inspectionWriteFusionConnectorInterface("HEADER");
        }
      }
      inspectionVariables.inspectionSections += 1;
    }
  }
}

function inspectionValidateInspectionSettings() {
  var errorText = "The following properties need to be configured:";
  if (!getProperty("probeOnCommand") || !getProperty("probeOffCommand")) {
    if (!getProperty("probeOnCommand")) {
      errorText += "\n-Probe On Command-";
    }
    if (!getProperty("probeOffCommand")) {
      errorText += "\n-Probe Off Command-";
    }
    error(localize(errorText + "\n-Please consult the guide PDF found at https://cam.autodesk.com/hsmposts?p=siemens-840d_inspection for more information-"));
  }
}

function onProbe(status) {
  if (status) { // probe ON
    writeBlock(getProperty("probeOnCommand"));
    onDwell(2);
    if (getProperty("commissioningMode")) {
      writeBlock("MSG(" + "\"" + "Ensure Probe Has Enabled" + "\"" + ")");
      onCommand(COMMAND_STOP);
      writeBlock("MSG()");
    }
  } else { // probe OFF
    writeBlock(getProperty("probeOffCommand"));
    onDwell(2);
    if (getProperty("commissioningMode")) {
      writeBlock("MSG(" + "\"" + "Ensure Probe Has Disabled" + "\"" + ")");
      onCommand(COMMAND_STOP);
      writeBlock("MSG()");
    }
  }
}

function inspectionCycleInspect(cycle, epx, epy, epz) {
  if (getNumberOfCyclePoints() != 3) {
    error(localize("Missing Endpoint in Inspection Cycle, check Approach and Retract heights"));
  }
  var x = xyzFormat.format(epx);
  var y = xyzFormat.format(epy);
  var z = xyzFormat.format(epz);
  var targetEndpoint = [inspectionVariables.xTarget, inspectionVariables.yTarget, inspectionVariables.zTarget];
  forceFeed(); // ensure feed is always output - just incase.
  var f;
  if (isFirstCyclePoint() || isLastCyclePoint()) {
    f = isFirstCyclePoint() ? cycle.safeFeed : cycle.linkFeed;
    inspectionCalculateTargetEndpoint(x, y, z);
    if (isFirstCyclePoint()) {
      writeComment("Approach Move");
      inspectionWriteMeasureMove(targetEndpoint, f);
      inspectionProbeTriggerCheck(false); // not triggered
    } else {
      writeComment("Retract Move");
      gMotionModal.reset();
      writeBlock(gMotionModal.format(1) + "X=" + targetEndpoint[0] + "Y=" + targetEndpoint[1] + "Z=" + targetEndpoint[2] + feedOutput.format(f));
      forceXYZ();
      if (cycle.outOfPositionAction == "stop-message" && !getProperty("liveConnection")) {
        inspectionOutOfPositionError();
      }
    }
  } else {
    writeComment("Measure Move");
    if (getProperty("commissioningMode") && (inspectionVariables.pointNumber == 1)) {
      writeBlock("MSG(" + "\"" + "Probe is about to contact part. Move should stop on contact" + "\"" + ")");
      onCommand(COMMAND_STOP);
      writeBlock("MSG()");
    }
    f = cycle.measureFeed;
    // var f = 300;
    inspectionWriteNominalData(cycle);
    if (getProperty("useDirectConnection")) {
      inspectionWriteFusionConnectorInterface("MEASURE");
    }
    inspectionCalculateTargetEndpoint(x, y, z);
    inspectionWriteMeasureMove(targetEndpoint, f);
    inspectionProbeTriggerCheck(true); // triggered
    // correct measured values for eccentricity.
    inspectionCorrectProbeMeasurement();
    inspectionWriteMeasuredData(cycle);
  }
}

function inspectionWriteNominalData(cycle) {
  var m = getRotation();
  var v = new Vector(cycle.nominalX, cycle.nominalY, cycle.nominalZ);
  var vt = m.multiply(v);
  var pathVector = new Vector(cycle.nominalI, cycle.nominalJ, cycle.nominalK);
  var nv = m.multiply(pathVector).normalized;
  cycle.nominalX = vt.x;
  cycle.nominalY = vt.y;
  cycle.nominalZ = vt.z;
  cycle.nominalI = nv.x;
  cycle.nominalJ = nv.y;
  cycle.nominalK = nv.z;
  writeBlock("OUTPUT = " + "\"" + "G800",
    "N" + inspectionVariables.pointNumber,
    "X" + xyzFormat.format(cycle.nominalX),
    "Y" + xyzFormat.format(cycle.nominalY),
    "Z" + xyzFormat.format(cycle.nominalZ),
    "I" + ijkFormat.format(cycle.nominalI),
    "J" + ijkFormat.format(cycle.nominalJ),
    "K" + ijkFormat.format(cycle.nominalK),
    "O" + xyzFormat.format(getParameter("operation:inspectSurfaceOffset")),
    "U" + xyzFormat.format(getParameter("operation:inspectUpperTolerance")),
    "L" + xyzFormat.format(getParameter("operation:inspectLowerTolerance")) +
    "\""
  );
  writeBlock("WRITE(RETURNCODE, RESULTSFILE, OUTPUT)");
  // later development check to ensure RETURNCODE is successful
}

function inspectionCalculateTargetEndpoint(x, y, z) {
  var correctionSign = inspectionVariables.probeCalibrationSiemens ? "+" : "-";
  writeBlock(inspectionVariables.xTarget + "=" + x + correctionSign + inspectionVariables.probeEccentricityX);
  writeBlock(inspectionVariables.yTarget + "=" + y + correctionSign + inspectionVariables.probeEccentricityY);
  writeBlock(inspectionVariables.zTarget + "=" + z + "+" + inspectionVariables.radiusDelta);
}

function inspectionWriteMeasureMove(xyzTarget, f) {
  writeBlock(
    "MEAS=" + (getProperty("probePolarityIsNegative") ? "-" : "") + getProperty("probeInput"),
    gMotionModal.format(1), "X=" + xyzTarget[0], "Y=" + xyzTarget[1], "Z=" + xyzTarget[2], feedOutput.format(f)
  );
  writeBlock("STOPRE");
}

function inspectionProbeTriggerCheck(triggered) {
  var probeTriggerState = getProperty("probePolarityIsNegative") ? 0 : 1;
  var condition = triggered ? "<>" : "==";
  var message = triggered ? "NO POINT TAKEN" : "PATH OBSTRUCTED";
  writeBlock("IF $A_PROBE[ABS(" + getProperty("probeInput") + ")] " + condition + probeTriggerState);
  writeBlock("MSG(" + "\"" + message + "\"" + ")");
  onCommand(COMMAND_STOP);
  writeBlock("MSG()");
  writeBlock("ENDIF");
}

function inspectionCorrectProbeMeasurement() {
  var correctionSign = inspectionVariables.probeCalibrationSiemens ? "-" : "+";
  writeBlock(
    inspectionVariables.xMeasured + "=" +
    inspectionVariables.systemVariableMeasuredX +
    correctionSign +
    inspectionVariables.probeEccentricityX
  );
  writeBlock(
    inspectionVariables.yMeasured + "=" +
    inspectionVariables.systemVariableMeasuredY +
    correctionSign +
    inspectionVariables.probeEccentricityY
  );
  // need to consider probe centre tool output point in future too
  writeBlock(inspectionVariables.zMeasured + "=" + inspectionVariables.systemVariableMeasuredZ + "+" + inspectionVariables.probeRadius);
}

function inspectionWriteFusionConnectorInterface(ncSection) {
  if (ncSection == "MEASURE") {
    writeBlock("IF " + inspectionVariables.probeResultsCollectionActive + " == 1");
    writeBlock("REPEAT");
    onDwell(0.5);
    writeComment("WAITING FOR FUSION CONNECTION");
    writeBlock("STOPRE");
    writeBlock(
      "UNTIL " + inspectionVariables.probeResultsReadPointer +
      " <> " + inspectionVariables.probeResultsWritePointer
    );
    writeBlock("ENDIF");
  } else {
    writeBlock("REPEAT");
    onDwell(0.5);
    writeComment("WAITING FOR FUSION CONNECTION");
    writeBlock("STOPRE");
    writeBlock("UNTIL " + inspectionVariables.probeResultsCollectionActive + " == 1");
  }
}

function inspectionCalculateDeviation(cycle) {
  var outputFormat = (unit == MM) ? "[53]" : "[44]";
  // calculate the deviation and produce a warning if out of tolerance.
  // (Measured + ((vector *(-1))*calibrated radi))

  writeComment("calculate deviation");
  // compensate for tip rad in X
  writeBlock(
    inspectionVariables.macroVariable1 + "=(" +
    inspectionVariables.xMeasured + "+((" +
    ijkFormat.format(cycle.nominalI) + "*(-1))*" +
    inspectionVariables.probeRadius + "))"
  );
  // compensate for tip rad in Y
  writeBlock(
    inspectionVariables.macroVariable2 + "=(" +
    inspectionVariables.yMeasured + "+((" +
    ijkFormat.format(cycle.nominalJ) + "*(-1))*" +
    inspectionVariables.probeRadius + "))"
  );
  // compensate for tip rad in Z
  writeBlock(
    inspectionVariables.macroVariable3 + "=(" +
    inspectionVariables.zMeasured + "+((" +
    ijkFormat.format(cycle.nominalK) + "*(-1))*" +
    inspectionVariables.probeRadius + "))"
  );
  // calculate deviation vector (Measured x - nominal x)
  writeBlock(
    inspectionVariables.macroVariable4 + "=" +
    inspectionVariables.macroVariable1 + "-" +
    "(" + xyzFormat.format(cycle.nominalX) + ")"
  );
  // calculate deviation vector (Measured y - nominal y)
  writeBlock(
    inspectionVariables.macroVariable5 + "=" +
    inspectionVariables.macroVariable2 + "-" +
    "(" + xyzFormat.format(cycle.nominalY) + ")"
  );
  // calculate deviation vector (Measured Z - nominal Z)
  writeBlock(
    inspectionVariables.macroVariable6 + "=(" +
    inspectionVariables.macroVariable3 + "-(" +
    xyzFormat.format(cycle.nominalZ) + "))"
  );
  // sqrt xyz.xyz this is the value of the deviation
  writeBlock(
    inspectionVariables.macroVariable7 + "=SQRT((" +
    inspectionVariables.macroVariable4 + "*" +
    inspectionVariables.macroVariable4 + ")+(" +
    inspectionVariables.macroVariable5 + "*" +
    inspectionVariables.macroVariable5 + ")+(" +
    inspectionVariables.macroVariable6 + "*" +
    inspectionVariables.macroVariable6 + "))"
  );
  // sign of the vector
  writeBlock(
    inspectionVariables.macroVariable1 + "=((" +
    ijkFormat.format(cycle.nominalI) + "*" +
    inspectionVariables.macroVariable4 + ")+(" +
    ijkFormat.format(cycle.nominalJ) + "*" +
    inspectionVariables.macroVariable5 + ")+(" +
    ijkFormat.format(cycle.nominalK) + "*" +
    inspectionVariables.macroVariable6 + "))"
  );
  // print out deviation value
  writeBlock(
    "IF (" + inspectionVariables.macroVariable1 + " <= 0)"
  );
  writeBlock(
    inspectionVariables.macroVariable4 + "=" +
    inspectionVariables.macroVariable7
  );
  writeBlock("ELSE");
  writeBlock(
    inspectionVariables.macroVariable4 + "=(" +
    inspectionVariables.macroVariable7 + "*(-1))"
  );
  writeBlock("ENDIF");

  if (!getProperty("useLiveConnection")) {
    writeBlock(
      "OUTPUT = " + "\"" + "G802 N" + inspectionVariables.pointNumber +
    " DEVIATION " + "\"" +
    "<<ROUND(" + inspectionVariables.macroVariable4 + "*10000)/10000"
    );
    writeBlock("WRITE(RETURNCODE, RESULTSFILE, OUTPUT)");
  }
}

function inspectionOutOfPositionError() {
  writeBlock(
    "IF (" + inspectionVariables.macroVariable4 +
    " > " + (xyzFormat.format(getParameter("operation:inspectUpperTolerance"))) +
    ")"
  );
  writeBlock("MSG(" + "\"" + "Inspection point over tolerance" + "\"" + ")");
  onCommand(COMMAND_STOP);
  writeBlock("MSG()");
  writeBlock("ENDIF");
  writeBlock(
    "IF (" + inspectionVariables.macroVariable4 +
    " < " + (xyzFormat.format(getParameter("operation:inspectLowerTolerance"))) +
    ")"
  );
  writeBlock("MSG(" + "\"" + "Inspection point under tolerance" + "\"" + ")");
  onCommand(COMMAND_STOP);
  writeBlock("MSG()");
  writeBlock("ENDIF");
}

function inspectionWriteMeasuredData(cycle) {
  writeBlock(
    "OUTPUT = " + "\"" + "G801 N" + inspectionVariables.pointNumber +
    " X " + "\"" +
    "<<ROUND(" + inspectionVariables.xMeasured + "*10000)/10000 <<" +
    "\"" + " Y" + "\"" +
    "<<ROUND(" + inspectionVariables.yMeasured + "*10000)/10000 <<" +
    "\"" + " Z" + "\"" +
    "<<ROUND(" + inspectionVariables.zMeasured + "*10000)/10000 <<" +
    "\"" + " R" + "\"" +
    "<<ROUND(" + inspectionVariables.probeRadius + "*10000)/10000"
  );
  writeBlock("WRITE(RETURNCODE, RESULTSFILE, OUTPUT)");
  // out of position action
  if (cycle.outOfPositionAction == "stop-message" && !getProperty("liveConnection")) {
    inspectionCalculateDeviation(cycle);
  }
  if (getProperty("useDirectConnection")) {
    var writeResultIndexX = inspectionVariables.probeResultsStartAddress + (3 * inspectionVariables.probeResultsBufferIndex);
    var writeResultIndexY = inspectionVariables.probeResultsStartAddress + (3 * inspectionVariables.probeResultsBufferIndex) + 1;
    var writeResultIndexZ = inspectionVariables.probeResultsStartAddress + (3 * inspectionVariables.probeResultsBufferIndex) + 2;

    writeBlock(macroFormat.format(writeResultIndexX) + " = " + inspectionVariables.xMeasured);
    writeBlock(macroFormat.format(writeResultIndexY) + " = " + inspectionVariables.yMeasured);
    writeBlock(macroFormat.format(writeResultIndexZ) + " = " + inspectionVariables.zMeasured);
    inspectionVariables.probeResultsBufferIndex += 1;
    if (inspectionVariables.probeResultsBufferIndex > getProperty("probeNumberofPoints")) {
      inspectionVariables.probeResultsBufferIndex = 0;
    }
    // writeBlock("R" + inspectionVariables.probeResultsCollectionActive + " = 2");
    writeBlock(inspectionVariables.probeResultsWritePointer + " = " + inspectionVariables.probeResultsBufferIndex);
  }
  if (getProperty("commissioningMode") && (getProperty("calibrationNCOutput") == "Ring Gauge")) {
    writeBlock(macroFormat.format(inspectionVariables.measuredXStartingAddress + inspectionVariables.pointNumber) +
    "=" + inspectionVariables.xMeasured);
    writeBlock(macroFormat.format(inspectionVariables.measuredYStartingAddress + inspectionVariables.pointNumber) +
    "=" + inspectionVariables.yMeasured);
    writeBlock(macroFormat.format(inspectionVariables.measuredZStartingAddress + inspectionVariables.pointNumber) +
    "=" + inspectionVariables.zMeasured);
    writeBlock(macroFormat.format(inspectionVariables.measuredIStartingAddress + inspectionVariables.pointNumber) +
    "=" + xyzFormat.format(cycle.nominalI));
    writeBlock(macroFormat.format(inspectionVariables.measuredJStartingAddress + inspectionVariables.pointNumber) +
    "=" + xyzFormat.format(cycle.nominalJ));
    writeBlock(macroFormat.format(inspectionVariables.measuredKStartingAddress + inspectionVariables.pointNumber) +
    "=" + xyzFormat.format(cycle.nominalK));
  }
  inspectionVariables.pointNumber += 1;
}

function inspectionProcessSectionStart() {
  writeBlock(inspectionVariables.probeRadius + "=" + inspectionVariables.probeCalibratedDiam + "/2");
  writeBlock(inspectionVariables.radiusDelta + "=" + xyzFormat.format(tool.diameter / 2) + "-" + inspectionVariables.probeRadius);
  // only write header once if user selects a single results file
  if (inspectionVariables.inspectionSectionCount == 0 || !getProperty("singleResultsFile") || (currentSection.workOffset != inspectionVariables.workpieceOffset)) {
    inspectionCreateResultsFileHeader();
  }
  inspectionVariables.inspectionSectionCount += 1;
  writeBlock("OUTPUT = " + "\"" + "TOOLPATHID " + getParameter("autodeskcam:operation-id") + "\"");
  writeBlock("WRITE(RETURNCODE, RESULTSFILE, OUTPUT)");
  inspectionWriteCADTransform();
  // write the toolpath name as a comment
  writeBlock("OUTPUT = " + "\"" + ";" + "TOOLPATH " + getParameter("operation-comment") + "\"");
  writeBlock("WRITE(RETURNCODE, RESULTSFILE, OUTPUT)");
  inspectionWriteWorkplaneTransform();
  if (getProperty("commissioningMode")) {
    writeBlock("OUTPUT = " + "\"" + "CALIBRATED RADIUS " + "\""  + "<<ROUND(" + inspectionVariables.probeRadius + "*10000)/10000");
    writeBlock("WRITE(RETURNCODE, RESULTSFILE, OUTPUT)");
    writeBlock("OUTPUT = " + "\"" + "ECCENTRICITY X " + "\"" + "<<ROUND(" + inspectionVariables.probeEccentricityX + "*10000)/10000");
    writeBlock("WRITE(RETURNCODE, RESULTSFILE, OUTPUT)");
    writeBlock("OUTPUT = " + "\"" + "ECCENTRICITY Y " + "\"" + "<<ROUND(" + inspectionVariables.probeEccentricityY + "*10000)/10000");
    writeBlock("WRITE(RETURNCODE, RESULTSFILE, OUTPUT)");

    writeBlock("IF " + inspectionVariables.probeRadius + " <= 0");
    writeBlock("MSG(" + "\"" + "PROBE NOT CALIBRATED OR PROPERTY CALIBRATED RADIUS INCORRECT" + "\"" + ")");
    onCommand(COMMAND_STOP);
    writeBlock("MSG()");
    writeBlock("ENDIF");
    writeBlock("IF " + inspectionVariables.probeRadius + " > " + xyzFormat.format(tool.diameter / 2));
    writeBlock("MSG(" + "\"" + "PROBE NOT CALIBRATED OR PROPERTY CALIBRATED RADIUS INCORRECT" + "\"" + ")");
    onCommand(COMMAND_STOP);
    writeBlock("MSG()");
    writeBlock("ENDIF");
    var maxEccentricity = (unit == MM) ? 0.2 : 0.0079;
    writeBlock("IF ABS(" + inspectionVariables.probeEccentricityX + ") > " + maxEccentricity);
    writeBlock("MSG(" + "\"" + "PROBE NOT CALIBRATED OR PROPERTY ECCENTRICITY X INCORRECT" + "\"" + ")");
    onCommand(COMMAND_STOP);
    writeBlock("MSG()");
    writeBlock("ENDIF");
    writeBlock("IF ABS(" + inspectionVariables.probeEccentricityY + ") > " + maxEccentricity);
    writeBlock("MSG(" + "\"" + "PROBE NOT CALIBRATED OR PROPERTY ECCENTRICITY Y INCORRECT" + "\"" + ")");
    onCommand(COMMAND_STOP);
    writeBlock("MSG()");
    writeBlock("ENDIF");
  }
}

function inspectionCreateResultsFileHeader() {
  // check for existence of none alphanumeric characters but not spaces
  var resFile;
  if (getProperty("singleResultsFile")) {
    resFile = getParameter("job-description") + "_RESULTS";
  } else {
    resFile = getParameter("operation-comment") + "_RESULTS";
  }
  // replace spaces with underscore as controllers don't like spaces in filenames
  resFile = resFile.replace(/\s/g, "_");
  resFile = resFile.replace(/[^a-zA-Z0-9_]/g, "");
  inspectionVariables.inspectionResultsFile = getProperty("resultsFileLocation") + resFile;
  if (inspectionVariables.inspectionSectionCount == 0 || !getProperty("singleResultsFile")) {
    writeBlock("RESULTSFILE = \"" + inspectionVariables.inspectionResultsFile + "\"");
    writeBlock("OUTPUT = " + "\"" + "START" + "\"");
    writeBlock("WRITE(RETURNCODE, RESULTSFILE, OUTPUT)");

    if (hasGlobalParameter("document-id")) {
      writeBlock("OUTPUT = " + "\"" + "DOCUMENTID " + getGlobalParameter("document-id") + "\"");
      writeBlock("WRITE(RETURNCODE, RESULTSFILE, OUTPUT)");
    }
    if (hasGlobalParameter("model-version")) {
      writeBlock("OUTPUT = " + "\"" + "MODELVERSION " + getGlobalParameter("model-version") + "\"");
      writeBlock("WRITE(RETURNCODE, RESULTSFILE, OUTPUT)");
    }
  }
}

function inspectionWriteCADTransform() {
  var cadOrigin = currentSection.getModelOrigin();
  var cadWorkPlane = currentSection.getModelPlane().getTransposed();
  var cadEuler = cadWorkPlane.getEuler2(EULER_XYZ_S);
  writeBlock(
    "OUTPUT = " + "\"" + "G331",
    "N" + inspectionVariables.pointNumber,
    "A" + abcFormat.format(cadEuler.x),
    "B" + abcFormat.format(cadEuler.y),
    "C" + abcFormat.format(cadEuler.z),
    "X" + xyzFormat.format(-cadOrigin.x),
    "Y" + xyzFormat.format(-cadOrigin.y),
    "Z" + xyzFormat.format(-cadOrigin.z) +
    "\""
  );
  writeBlock("WRITE(RETURNCODE, RESULTSFILE, OUTPUT)");
}

function inspectionWriteWorkplaneTransform() {
  var euler = currentSection.workPlane.getEuler2(EULER_XYZ_S);
  var abc = new Vector(euler.x, euler.y, euler.z);
  writeBlock("OUTPUT = " + "\"" + "G330",
    "N" + inspectionVariables.pointNumber,
    "A" + abcFormat.format(abc.x),
    "B" + abcFormat.format(abc.y),
    "C" + abcFormat.format(abc.z),
    "X0", "Y0", "Z0", "I0", "R0" + "\""
  );
  writeBlock("WRITE(RETURNCODE, RESULTSFILE, OUTPUT)");
}

function inspectionProcessSectionEnd() {
  if (isInspectionOperation(currentSection)) {
    // close inspection results file if the NC has inspection toolpaths
    if ((!getProperty("singleResultsFile")) || (inspectionVariables.inspectionSectionCount == inspectionVariables.inspectionSections)) {
      writeBlock("OUTPUT = " + "\"" + "END" + "\"");
      writeBlock("WRITE(RETURNCODE, RESULTSFILE, OUTPUT)");
    }
    if (getProperty("commissioningMode")) {
      var location = getProperty("resultsFileLocation") == "" ? "The nc program folder" : getProperty("resultsFileLocation");
      writeBlock("MSG(" + "\"" + "Results file should now be located in " + location + "\"" + ")");
      onCommand(COMMAND_STOP);
      writeBlock("MSG()");
    }
    writeBlock(getProperty("stopOnInspectionEnd") == true ? onCommand(COMMAND_STOP) : "");
  }
}
