/**
  h-AAS post processor configuration.

  $Revision: 00001 18ed74b0b685b0d3fd238e58719b897a383e6fa6$
  $Date: 2022-03-08 14:47:02 $
  

    Conturo Prototyping Version Info
    
    03/10/2022
    Billy @ CP
      -Changed the way HAAS HSM smoothing (G187) is calculated, was based off STL, now it's a combo of tolerance and smoothing. Search HSM to find it in the code.
      -removed duplicate minimum version, description, and long description
      -removed UMC1600 from the options
      -make chip transport on by default


*/

//local
// >>>>> INCLUDED FROM ../../../haas next generation.cps
////////////////////////////////////////////////////////////////////////////////////////////////
//                        MANUAL NC COMMANDS
//
// The following ACTION commands are supported by this post.
//
//     CYCLE_REVERSAL                - Reverses the spindle in a drilling cycle
//     USEPOLARMODE                  - Enables polar interpolation for the following operation.
//     VFD_HIGH                      - Uses high pressure flood coolant if machine has VFD
//     VFD_LOW                       - Uses low pressure flood coolant if machine has VFD
//     VFD_NORMAL                    - Uses normal pressure flood coolant if machine has VFD
//
////////////////////////////////////////////////////////////////////////////////////////////////



description = "HAAS - Mill - NGC";
vendor = "h-AAS Automation";
vendorUrl = "http://www.conturoprototyping.com";
legal = "Conturo Prototyping";
certificationLevel = 2;
minimumRevision = 00001;

//longDescription = "Generic post for the HAAS Next Generation control. The post includes support for multi-axis indexing and simultaneous machining. The post utilizes the dynamic work offset feature so you can place your work piece as desired without having to repost your NC programs." + EOL +
//"You can specify following pre-configured machines by using the property 'Machine model':" + EOL +
//"UMC-500" + EOL + "UMC-750" + EOL + "UMC-1000" + EOL + "UMC-1600-H";

extension = "nc";
programNameIsInteger = true;
setCodePage("ascii");
keywords = "MODEL_IMAGE PREVIEW_IMAGE";

capabilities = CAPABILITY_MILLING | CAPABILITY_MACHINE_SIMULATION;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.25, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(355);
allowHelicalMoves = true;
allowedCircularPlanes = undefined; // allow any circular motion
allowSpiralMoves = true;
highFeedrate = (unit == IN) ? 650 : 5000;

// user-defined properties
properties = {
  machineModel: {
    title      : "Machine model",
    description: "Specifies the pre-configured machine model.",
    type       : "enum",
    group      : 0,
    values     : [
      {title:"None", id:"none"},
      {title:"UMC-500", id:"umc-500"},
      {title:"UMC-750", id:"umc-750"},
      {title:"UMC-1000", id:"umc-1000"},
      //{title:"UMC-1600-H", id:"umc-1600"}
    ],
    value: "none",
    scope: "post"
  },
  hasAAxis: {
    title      : "Has A-axis rotary",
    description: "Enable if the machine has an A-axis table/trunnion. Check the table direction on the machine and use the (Reversed) selection if the table is moving in the opposite direction.",
    type       : "enum",
    group      : 1,
    values     : [
      {title:"No", id:"false"},
      {title:"Yes", id:"true"},
      {title:"Reversed", id:"reversed"}
    ],
    value: "false",
    scope: "post"
  },
  hasBAxis: {
    title      : "Has B-axis rotary",
    description: "Enable if the machine has a B-axis table/trunnion. Check the table direction on the machine and use the (Reversed) selection if the table is moving in the opposite direction.",
    type       : "enum",
    group      : 1,
    values     : [
      {title:"No", id:"false"},
      {title:"Yes", id:"true"},
      {title:"Reversed", id:"reversed"}
    ],
    value: "false",
    scope: "post"
  },
  hasCAxis: {
    title      : "Has C-axis rotary",
    description: "Enable if the machine has a C-axis table. Specifies a trunnion setup if an A-axis or B-axis is defined. Check the table direction on the machine and use the (Reversed) selection if the table is moving in the opposite direction.",
    type       : "enum",
    group      : 1,
    values     : [
      {title:"No", id:"false"},
      {title:"Yes", id:"true"},
      {title:"Reversed", id:"reversed"}
    ],
    value: "false",
    scope: "post"
  },
  useDPMFeeds: {
    title      : "Rotary moves use DPM feeds",
    description: "Enable to output DPM feeds, disable for Inverse Time feeds with rotary axes moves.",
    group      : 1,
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  useTCP: {
    title      : "Use TCPC programming",
    description: "The control supports Tool Center Point Control programming.",
    group      : 1,
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  useMultiAxisFeatures: {
    title      : "Use DWO",
    description: "Specifies that the Dynamic Work Offset feature (G254/G255) should be used.",
    group      : 1,
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  preloadTool: {
    title      : "Preload tool",
    description: "Preloads the next tool at a tool change (if any).",
    group      : 2,
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  chipTransport: {
    title      : "Use chip transport",
    description: "Enable to turn on chip transport at start of program.",
    group      : 2,
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  optionalStop: {
    title      : "Optional stop",
    description: "Specifies that optional stops M1 should be output at tool changes.",
    group      : 2,
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  separateWordsWithSpace: {
    title      : "Separate words with space",
    description: "Adds spaces between words if 'yes' is selected.",
    group      : 2,
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  useRadius: {
    title      : "Radius arcs",
    description: "If yes is selected, arcs are output using radius values rather than IJK.",
    group      : 2,
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  useParametricFeed: {
    title      : "Parametric feed",
    description: "Parametric feed values based on movement type are output.",
    group      : 2,
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  useG0: {
    title      : "Use G0",
    description: "Specifies that G0s should be used for rapid moves when moving along a single axis.",
    group      : 2,
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  safePositionMethod: {
    title      : "Safe Retracts",
    description: "Select your desired retract option. 'Clearance Height' retracts to the operation clearance height.",
    type       : "enum",
    values     : [
      {title:"G28", id:"G28"},
      {title:"G53", id:"G53"},
      {title:"Clearance Height", id:"clearanceHeight"}
    ],
    value: "G53",
    scope: "post"
  },
  // smoothing option commented out by Billy 3-10-2022, we don't need this to be an option
  //useSmoothing: {
    //title      : "Use G187",
    //description: "G187 smoothing mode.",
    //type       : "enum",
    //group      : 1,
    //values     : [
      //{title:"Off", id:"-1"},
      //{title:"Automatic", id:"9999"},
      //{title:"Rough", id:"1"},
      //{title:"Medium", id:"2"},
      //{title:"Finish", id:"3"}
    //],
    //value: "-1",
    //scope: "post"
  //},
  homePositionCenter: {
    title      : "Home position center",
    description: "Enable to center the part along X at the end of program for easy access. Requires a CNC with a moving table.",
    group      : 2,
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  optionallyCycleToolsAtStart: {
    title      : "Optionally cycle tools at start",
    description: "Cycle through each tool used at the beginning of the program when block delete is turned off.",
    group      : 2,
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  optionallyMeasureToolsAtStart: {
    title      : "Optionally measure tools at start",
    description: "Measure each tool used at the beginning of the program when block delete is turned off.",
    group      : 2,
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  forceHomeOnIndexing: {
    title      : "Force XY home position on indexing",
    description: "Move XY to their home positions on multi-axis indexing.",
    group      : 2,
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  toolBreakageTolerance: {
    title      : "Tool breakage tolerance",
    description: "Specifies the tolerance for which tool break detection will raise an alarm.",
    group      : 2,
    type       : "spatial",
    value      : 0.1,
    scope      : "post"
  },
  toolArmDrive: {
    title      : "Machine has a tool setting probe arm",
    description: "Outputs M104/M105 to extend/retract the tool setting probe arm",
    group      : 2,
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  useSSV: {
    title      : "Use SSV",
    description: "Outputs M138/M139 to enable Spindle Speed Variation (SSV).",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  safeStartAllOperations: {
    title      : "Safe start all operations",
    description: "Write optional blocks at the beginning of all operations that include all commands to start program.",
    group      : 2,
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  fastToolChange: {
    title      : "Fast tool change",
    description: "Skip spindle off, coolant off, and Z retract to make tool change quicker.",
    group      : 2,
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  useG95forTapping: {
    title      : "Use G95 for tapping",
    description: "use IPR/MPR instead of IPM/MPM for tapping",
    group      : 2,
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  safeRetractDistance: {
    title      : "Safe retract distance",
    description: "Specifies the distance to add to retract distance when rewinding rotary axes.",
    group      : 2,
    type       : "spatial",
    value      : 0,
    scope      : "post"
  },
  useSubroutines: {
    title      : "Use subroutines",
    description: "Select your desired subroutine option. 'All Operations' creates subroutines per each operation, 'Cycles' creates subroutines for cycle operations on same holes, and 'Patterns' creates subroutines for patterned operations.",
    type       : "enum",
    values     : [
      {title:"No", id:"none"},
      {title:"All Operations", id:"allOperations"},
      {title:"Cycles", id:"cycles"},
      {title:"Patterns", id:"patterns"}
    ],
    group: 3,
    value: "none",
    scope: "post"
  },
  writeMachine: {
    title      : "Write machine",
    description: "Output the machine settings in the header of the code.",
    group      : 4,
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  writeTools: {
    title      : "Write tool list",
    description: "Output a tool list in the header of the code.",
    group      : 4,
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  writeVersion: {
    title      : "Write version",
    description: "Write the version number in the header of the code.",
    group      : 4,
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  showSequenceNumbers: {
    title      : "Use sequence numbers",
    description: "Use sequence numbers for each block of outputted code.",
    group      : 4,
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  sequenceNumberStart: {
    title      : "Start sequence number",
    description: "The number at which to start the sequence numbers.",
    group      : 4,
    type       : "integer",
    value      : 10,
    scope      : "post"
  },
  sequenceNumberIncrement: {
    title      : "Sequence number increment",
    description: "The amount by which the sequence number is incremented by in each block.",
    group      : 4,
    type       : "integer",
    value      : 5,
    scope      : "post"
  },
  sequenceNumberOnlyOnToolChange: {
    title      : "Block number only on tool change",
    description: "Specifies that block numbers should only be output at tool changes.",
    group      : 4,
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  showNotes: {
    title      : "Show notes",
    description: "Enable to output notes for operations.",
    group      : 4,
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  useM130PartImages: {
    title      : "Include M130 part images",
    description: "Enable to include M130 part images with the NC file.",
    group      : 4,
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  useM130ToolImages: {
    title      : "Include M130 tool images",
    description: "Enable to include M130 tool images with the NC file.",
    group      : 4,
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  coolantPressure: {
    title      : "Coolant pressure",
    description: "Select the coolant pressure if equipped with a Variable Frequency Drive.  Select 'Default' if this option is not installed.",
    type       : "enum",
    group      : 2,
    values     : [
      {title:"Default", id:""},
      {title:"Low", id:"P0"},
      {title:"Normal", id:"P1"},
      {title:"High", id:"P2"}
    ],
    value: "",
    scope: "post"
  },
  singleResultsFile: {
    title      : "Create single results file",
    description: "Set to false if you want to store the measurement results for each probe / inspection toolpath in a separate file",
    group      : 0,
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  useClampCodes: {
    title      : "Use clamp codes",
    description: "Specifies whether clamp codes for rotary axes should be output. For simultaneous toolpaths rotary axes will always get unclamped.",
    type       : "boolean",
    value      : true,
    scope      : "post"
  }
};

// wcs definiton
wcsDefinitions = {
  useZeroOffset: false,
  wcs          : [
    {name:"Standard", format:"G", range:[54, 59]},
    {name:"Extended", format:"G154 P", range:[1, 99]}
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
  {id:COOLANT_THROUGH_TOOL, on:88, off:89},
  {id:COOLANT_AIR, on:83, off:84},
  {id:COOLANT_AIR_THROUGH_TOOL, on:73, off:74},
  {id:COOLANT_SUCTION},
  {id:COOLANT_FLOOD_MIST},
  {id:COOLANT_FLOOD_THROUGH_TOOL, on:[88, 8], off:[89, 9]},
  {id:COOLANT_OFF, off:9}
];

// old machines only support 4 digits
var oFormat = createFormat({width:5, zeropad:true, decimals:0});
var nFormat = createFormat({decimals:0});

var gFormat = createFormat({prefix:"G", decimals:0});
var mFormat = createFormat({prefix:"M", decimals:0});
var hFormat = createFormat({prefix:"H", decimals:0});
var dFormat = createFormat({prefix:"D", decimals:0});
var probeWCSFormat = createFormat({prefix:"S", decimals:0, forceDecimal:true});
var probeExtWCSFormat = createFormat({prefix:"S154.", width:2, zeropad:true, decimals:0});

var xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var rFormat = xyzFormat; // radius
var abcFormat = createFormat({decimals:3, forceDecimal:true, scale:DEG});
var feedFormat = createFormat({decimals:(unit == MM ? 2 : 3), forceDecimal:true});
var inverseTimeFormat = createFormat({decimals:3, forceDecimal:true});
var pitchFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var toolFormat = createFormat({decimals:0});
var rpmFormat = createFormat({decimals:0});
var secFormat = createFormat({decimals:3, forceDecimal:true}); // seconds - range 0.001-1000
var milliFormat = createFormat({decimals:0}); // milliseconds // range 1-9999
var taperFormat = createFormat({decimals:1, scale:DEG});

var xOutput = createVariable({prefix:"X"}, xyzFormat);
var yOutput = createVariable({prefix:"Y"}, xyzFormat);
var zOutput = createVariable({onchange:function() {retracted = false;}, prefix:"Z"}, xyzFormat);
var aOutput = createVariable({prefix:"A"}, abcFormat);
var bOutput = createVariable({prefix:"B"}, abcFormat);
var cOutput = createVariable({prefix:"C"}, abcFormat);
var feedOutput = createVariable({prefix:"F"}, feedFormat);
var inverseTimeOutput = createVariable({prefix:"F", force:true}, inverseTimeFormat);
var pitchOutput = createVariable({prefix:"F", force:true}, pitchFormat);
var sOutput = createVariable({prefix:"S", force:true}, rpmFormat);
var dOutput = createVariable({}, dFormat);

// circular output
var iOutput = createReferenceVariable({prefix:"I", force:true}, xyzFormat);
var jOutput = createReferenceVariable({prefix:"J", force:true}, xyzFormat);
var kOutput = createReferenceVariable({prefix:"K", force:true}, xyzFormat);

var gMotionModal = createModal({}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal({onchange:function () {gMotionModal.reset();}}, gFormat); // modal group 2 // G17-19
var gAbsIncModal = createModal({}, gFormat); // modal group 3 // G90-91
var gFeedModeModal = createModal({}, gFormat); // modal group 5 // G93-94
var gUnitModal = createModal({}, gFormat); // modal group 6 // G20-21
var gCycleModal = createModal({}, gFormat); // modal group 9 // G81, ...
var gRetractModal = createModal({force:true}, gFormat); // modal group 10 // G98-99
var gRotationModal = createModal({
  onchange: function () {
    if (probeVariables.probeAngleMethod == "G68") {
      probeVariables.outputRotationCodes = true;
    }
  }
}, gFormat); // modal group 16 // G68-G69
var ssvModal = createModal({}, mFormat); // M138, M139
var mClampModal = createModalGroup(
  {strict:false},
  [
    [10, 11], // 4th axis clamp / unclamp
    [12, 13] // 5th axis clamp / unclamp
  ],
  mFormat
);
var mProbeArmModal = createModal({}, mFormat); // M104, M105 extend / retract the tool setting probe arm

// fixed settings
var firstFeedParameter = 100; // the first variable to use with parametric feed
var forceResetWorkPlane = false; // enable to force reset of machine ABC on new orientation
var minimumCyclePoints = 5; // minimum number of points in cycle operation to consider for subprogram
var useDwoForPositioning = true; // specifies to use the DWO feature for XY positioning for multi-axis operations

var WARNING_WORK_OFFSET = 0;

var allowIndexingWCSProbing = false; // specifies that probe WCS with tool orientation is supported
var probeVariables = {
  outputRotationCodes: false, // defines if it is required to output rotation codes
  probeAngleMethod   : "OFF", // OFF, AXIS_ROT, G68, G54.4
  compensationXY     : undefined,
  rotationalAxis     : -1
};

var SUB_UNKNOWN = 0;
var SUB_PATTERN = 1;
var SUB_CYCLE = 2;

// collected state
var sequenceNumber;
var currentWorkOffset;
var coolantPressure;
var optionalSection = false;
var forceSpindleSpeed = false;
var forceCoolant = false;
var activeMovements; // do not use by default
var currentFeedId;
var maximumCircularRadiiDifference = toPreciseUnit(0.005, MM);
var maximumLineLength = 80; // the maximum number of charaters allowed in a line
var subprograms = [];
var currentPattern = -1;
var firstPattern = false;
var currentSubprogram;
var lastSubprogram;
var initialSubprogramNumber = 90000;
var definedPatterns = new Array();
var incrementalMode = false;
var saveShowSequenceNumbers;
var cycleSubprogramIsActive = false;
var patternIsActive = false;
var lastOperationComment = "";
var incrementalSubprogram;
var retracted = false; // specifies that the tool has been retracted to the safe plane
var hasA = false;
var hasB = false;
var hasC = false;
var measureTool = false;
var cycleReverse = false;
probeMultipleFeatures = true;
var maximumSpindleRPM = 15000;
var homePositionCenter = false;

// used to convert blocks to optional for safeStartAllOperations, might get used outside of onSection
var operationNeedsSafeStart = false;

/**
  Writes the specified block.
*/
var skipBlock = false;
function writeBlock() {
  var text = formatWords(arguments);
  if (!text) {
    return;
  }
  var maximumSequenceNumber = ((getProperty("useSubroutines") == "allOperations") || (getProperty("useSubroutines") == "patterns") ||
    (getProperty("useSubroutines") == "cycles")) ? initialSubprogramNumber : 99999;
  if (getProperty("showSequenceNumbers")) {
    if (sequenceNumber >= maximumSequenceNumber) {
      sequenceNumber = getProperty("sequenceNumberStart");
    }
    if (optionalSection || skipBlock) {
      if (text) {
        writeWords("/", "N" + sequenceNumber, text);
      }
    } else {
      writeWords2("N" + sequenceNumber, arguments);
    }
    sequenceNumber += getProperty("sequenceNumberIncrement");
  } else {
    if (optionalSection || skipBlock) {
      writeWords2("/", arguments);
    } else {
      writeWords(arguments);
    }
  }
  skipBlock = false;
}

/**
  Writes the specified block - used for tool changes only.
*/
function writeToolBlock() {
  var show = getProperty("showSequenceNumbers");
  setProperty("showSequenceNumbers", show || getProperty("sequenceNumberOnlyOnToolChange"));
  writeBlock(arguments);
  setProperty("showSequenceNumbers", show);
}

/**
  Writes the specified optional block.
*/
function writeOptionalBlock() {
  skipBlock = true;
  writeBlock(arguments);
}

function formatComment(text) {
  return "(" + String(text).replace(/[()]/g, "") + ")";
}

/**
  Output a comment.
*/
function writeComment(text) {
  writeln(formatComment(text.substr(0, maximumLineLength - 2)));
}

/**
  Returns the matching HAAS tool type for the tool.
*/
function getHaasToolType(toolType) {
  switch (toolType) {
  case TOOL_DRILL:
  case TOOL_REAMER:
    return 1; // drill
  case TOOL_TAP_RIGHT_HAND:
  case TOOL_TAP_LEFT_HAND:
    return 2; // tap
  case TOOL_MILLING_FACE:
  case TOOL_MILLING_SLOT:
  case TOOL_BORING_BAR:
    return 3; // shell mill
  case TOOL_MILLING_END_FLAT:
  case TOOL_MILLING_END_BULLNOSE:
  case TOOL_MILLING_TAPERED:
  case TOOL_MILLING_DOVETAIL:
    return 4; // end mill
  case TOOL_DRILL_SPOT:
  case TOOL_MILLING_CHAMFER:
  case TOOL_DRILL_CENTER:
  case TOOL_COUNTER_SINK:
  case TOOL_COUNTER_BORE:
  case TOOL_MILLING_THREAD:
  case TOOL_MILLING_FORM:
    return 5; // center drill
  case TOOL_MILLING_END_BALL:
  case TOOL_MILLING_LOLLIPOP:
    return 6; // ball nose
  case TOOL_PROBE:
    return 7; // probe
  default:
    error(localize("Invalid HAAS tool type."));
    return -1;
  }
}

function getHaasProbingType(toolType, use9023) {
  switch (getHaasToolType(toolType)) {
  case 3:
  case 4:
    return (use9023 ? 23 : 1); // rotate
  case 1:
  case 2:
  case 5:
  case 6:
  case 7:
    return (use9023 ? 12 : 2); // non rotate
  case 0:
    return (use9023 ? 13 : 3); // rotate length and dia
  default:
    error(localize("Invalid HAAS tool type."));
    return -1;
  }
}

function writeToolCycleBlock(tool) {
  writeBlock("T" + toolFormat.format(tool.number), mFormat.format(6)); // get tool
  writeBlock(mFormat.format(0)); // wait for operator
}

function prepareForToolCheck() {
  onCommand(COMMAND_STOP_SPINDLE);
  onCommand(COMMAND_COOLANT_OFF);

  // cancel TCP so that tool doesn't follow tables
  if (currentSection.isMultiAxis() && operationSupportsTCP) {
    disableLengthCompensation(false, "TCPC OFF");
  }
  if ((currentSection.isMultiAxis() && getCurrentDirection().length != 0) ||
    (currentMachineABC != undefined && currentMachineABC.length != 0)) {
    setWorkPlane(new Vector(0, 0, 0));
    forceWorkPlane();
  }
  if (getProperty("toolArmDrive")) {
    writeBlock(mProbeArmModal.format(104), formatComment("Extend tool setting probe arm"));
  }
}

function writeToolMeasureBlock(tool, preMeasure) {
  var comment = measureTool ? formatComment("MEASURE TOOL") : "";
  if (!preMeasure) {
    prepareForToolCheck();
  }
  if (true) { // use Macro P9023 to measure tools
    var probingType = getHaasProbingType(tool.type, true);
    writeBlock(
      gFormat.format(65),
      "P9023",
      "A" + probingType + ".",
      "T" + toolFormat.format(tool.number),
      conditional((probingType != 12), "H" + xyzFormat.format(getBodyLength(tool))),
      conditional((probingType != 12), "D" + xyzFormat.format(tool.diameter)),
      comment
    );
  } else { // use Macro P9995 to measure tools
    writeBlock("T" + toolFormat.format(tool.number), mFormat.format(6)); // get tool
    writeBlock(
      gFormat.format(65),
      "P9995",
      "A0.",
      "B" + getHaasToolType(tool.type) + ".",
      "C" + getHaasProbingType(tool.type, false) + ".",
      "T" + toolFormat.format(tool.number),
      "E" + xyzFormat.format(getBodyLength(tool)),
      "D" + xyzFormat.format(tool.diameter),
      "K" + xyzFormat.format(0.1),
      "I0.",
      comment
    ); // probe tool
  }
  if (getProperty("toolArmDrive") && !preMeasure) {
    writeBlock(mProbeArmModal.format(105), formatComment("Retract tool setting probe arm"));
  }
  measureTool = false;
}

function defineMachineModel() {
  var useTCP = getProperty("useTCP");
  switch (getProperty("machineModel")) {
  case "umc-500":
    var axis1 = createAxis({coordinate:1, table:true, axis:[0, 1, 0], range:[-35, 120], preference:1, tcp:useTCP});
    var axis2 = createAxis({coordinate:2, table:true, axis:[0, 0, 1], cyclic:true, preference:0, reset:1, tcp:useTCP});
    machineConfiguration = new MachineConfiguration(axis1, axis2);
    machineConfiguration.setHomePositionX(toPreciseUnit(-23.96, IN));
    machineConfiguration.setHomePositionY(toPreciseUnit(-3.37, IN));
    machineConfiguration.setRetractPlane(toPreciseUnit(0, IN));
    maximumSpindleRPM = 8100;
    break;
  case "umc-750":
    var axis1 = createAxis({coordinate:1, table:true, axis:[0, 1, 0], range:[-35, 120], preference:1, tcp:useTCP});
    var axis2 = createAxis({coordinate:2, table:true, axis:[0, 0, 1], cyclic:true, preference:0, reset:1, tcp:useTCP});
    machineConfiguration = new MachineConfiguration(axis1, axis2);
    machineConfiguration.setHomePositionX(toPreciseUnit(-29.0, IN));
    machineConfiguration.setHomePositionY(toPreciseUnit(-8, IN));
    machineConfiguration.setRetractPlane(toPreciseUnit(2.5, IN));
    maximumSpindleRPM = 8100;
    break;
  case "umc-1000":
    var axis1 = createAxis({coordinate:1, table:true, axis:[0, 1, 0], range:[-35, 120], preference:1, tcp:useTCP});
    var axis2 = createAxis({coordinate:2, table:true, axis:[0, 0, 1], cyclic:true, preference:0, reset:1, tcp:useTCP});
    machineConfiguration = new MachineConfiguration(axis1, axis2);
    machineConfiguration.setHomePositionX(toPreciseUnit(-40.07, IN));
    machineConfiguration.setHomePositionY(toPreciseUnit(-10.76, IN));
    machineConfiguration.setRetractPlane(toPreciseUnit(0, IN));
    maximumSpindleRPM = 8100;
    break;
  case "umc-1600":
    var axis1 = createAxis({coordinate:1, table:true, axis:[0, 1, 0], range:[-120, 120], preference:1, tcp:useTCP});
    var axis2 = createAxis({coordinate:2, table:true, axis:[0, 0, 1], cyclic:true, preference:0, reset:1, tcp:useTCP});
    machineConfiguration = new MachineConfiguration(axis1, axis2);
    machineConfiguration.setHomePositionX(toPreciseUnit(0, IN));
    machineConfiguration.setHomePositionY(toPreciseUnit(0, IN));
    machineConfiguration.setRetractPlane(toPreciseUnit(0, IN));
    maximumSpindleRPM = 7500;
    break;
  }
  machineConfiguration.setModel(getProperty("machineModel").toUpperCase());
  machineConfiguration.setVendor("Haas Automation");

  setMachineConfiguration(machineConfiguration);
  if (receivedMachineConfiguration) {
    warning(localize("The provided CAM machine configuration is overwritten by the postprocessor."));
    receivedMachineConfiguration = false; // CAM provided machine configuration is overwritten
  }
}

// Start of machine configuration logic
var compensateToolLength = false; // add the tool length to the pivot distance for nonTCP rotary heads
var virtualTooltip = false; // translate the pivot point to the virtual tool tip for nonTCP rotary heads
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

  // don't need to modify any settings if 3-axis machine
  if (!machineConfiguration.isMultiAxisConfiguration()) {
    return;
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

  // setup for head configurations
  if (machineConfiguration.isHeadConfiguration()) {
    compensateToolLength = typeof compensateToolLength == "undefined" ? false : compensateToolLength;
  }

  // calculate the ABC angles and adjust the points for multi-axis operations
  // rotary heads may require the tool length be added to the pivot length
  // so we need to optimize each section individually
  if (machineConfiguration.isHeadConfiguration() && compensateToolLength) {
    for (var i = 0; i < getNumberOfSections(); ++i) {
      var section = getSection(i);
      if (section.isMultiAxis()) {
        machineConfiguration.setToolLength(getBodyLength(section.getTool())); // define the tool length for head adjustments
        section.optimizeMachineAnglesByMachine(machineConfiguration, OPTIMIZE_AXIS);
      }
    }
  } else { // tables and rotary heads with TCP support can be optimized with a single call
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
  hasA = getProperty("hasAAxis") != "false";
  hasB = getProperty("hasBAxis") != "false";
  hasC = getProperty("hasCAxis") != "false";

  var useTCP = getProperty("useTCP");
  if (hasA && hasB && hasC) {
    error(localize("Only two rotary axes can be active at the same time."));
    return;
  } else if ((hasA || hasB || hasC) && getProperty("machineModel") != "none") {
    error(localize("You can only select either a machine model or use the ABC axis properties."));
    return;
  } else if (((hasA || hasB || hasC) || getProperty("machineModel") != "none") && (receivedMachineConfiguration && machineConfiguration.isMultiAxisConfiguration())) {
    error(localize("You can only select either a machine in the CAM setup or use the properties to define your kinematics."));
    return;
  }
  if (getProperty("machineModel") == "none") {
    if (hasA || hasB || hasC) { // configure machine
      var aAxis;
      var bAxis;
      var cAxis;
      if (hasA) { // A Axis - For horizontal machines and trunnions
        var dir = getProperty("hasAAxis") == "reversed" ? -1 : 1;
        if (hasC || hasB) {
          var aMin = (dir == 1) ? -120 - 0.0001 : -30 - 0.0001;
          var aMax = (dir == 1) ? 30 + 0.0001 : 120 + 0.0001;
          aAxis = createAxis({coordinate:0, table:true, axis:[dir, 0, 0], range:[aMin, aMax], preference:dir, reset:(hasB ? 0 : 1), tcp:useTCP});
        } else {
          aAxis = createAxis({coordinate:0, table:true, axis:[dir, 0, 0], cyclic:true, tcp:useTCP});
        }
      }

      if (hasB) { // B Axis - For horizontal machines and trunnions
        var dir = getProperty("hasBAxis") == "reversed" ? -1 : 1;
        if (hasC) {
          var bMin = (dir == 1) ? -120 - 0.0001 : -30 - 0.0001;
          var bMax = (dir == 1) ? 30 + 0.0001 : 120 + 0.0001;
          bAxis = createAxis({coordinate:1, table:true, axis:[0, dir, 0], range:[bMin, bMax], preference:-dir, reset:1, tcp:useTCP});
        } else if (hasA) {
          bAxis = createAxis({coordinate:1, table:true, axis:[0, 0, dir], cyclic:true, tcp:useTCP});
        } else {
          bAxis = createAxis({coordinate:1, table:true, axis:[0, dir, 0], cyclic:true, tcp:useTCP});
        }
      }

      if (hasC) { // C Axis - For trunnions only
        var dir = getProperty("hasCAxis") == "reversed" ? -1 : 1;
        cAxis = createAxis({coordinate:2, table:true, axis:[0, 0, dir], cyclic:true, reset:1, tcp:useTCP});
      }

      if (hasA && hasC) { // AC trunnion
        machineConfiguration = new MachineConfiguration(aAxis, cAxis);
      } else if (hasB && hasC) { // BC trunnion
        machineConfiguration = new MachineConfiguration(bAxis, cAxis);
      } else if (hasA && hasB) { // AB trunnion
        machineConfiguration = new MachineConfiguration(aAxis, bAxis);
      } else if (hasA) { // A rotary
        machineConfiguration = new MachineConfiguration(aAxis);
      } else if (hasB) { // B rotary - horizontal machine only
        machineConfiguration = new MachineConfiguration(bAxis);
      } else if (hasC) { // C rotary
        machineConfiguration = new MachineConfiguration(cAxis);
      }
      setMachineConfiguration(machineConfiguration);
      if (receivedMachineConfiguration) {
        warning(localize("The provided CAM machine configuration is overwritten by the postprocessor."));
        receivedMachineConfiguration = false; // CAM provided machine configuration is overwritten
      }
    }
  } else {
    defineMachineModel();
  }

  if (!receivedMachineConfiguration) {
    // retract / reconfigure
    var performRewinds = false; // set to true to enable the rewind/reconfigure logic
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
  receivedMachineConfiguration = machineConfiguration.isReceived();
  if (typeof defineMachine == "function") {
    defineMachine(); // hardcoded machine configuration
  }
  activateMachine(); // enable the machine optimizations and settings

  if (getProperty("useDPMFeeds")) {
    gFeedModeModal.format(94);
  }
  if (getProperty("useRadius")) {
    maximumCircularSweep = toRad(90); // avoid potential center calculation errors for CNC
  }
  if (getProperty("sequenceNumberOnlyOnToolChange")) {
    setProperty("showSequenceNumbers", false);
  }
  if (!getProperty("useMultiAxisFeatures")) {
    useDwoForPositioning = false;
  }
  if (getProperty("useLiveConnection")) {
    if (getProperty("showSequenceNumbers")) {
      warning(localize("'Use sequence numbers' is switched off due to live connection."));
    }
    setProperty("showSequenceNumbers", false);
  }

  gRotationModal.format(69); // Default to G69 Rotation Off
  ssvModal.format(139); // Default to M139 SSV turned off
  mClampModal.format(10); // Default 4th axis modal code to be clamped
  mClampModal.format(12); // Default 5th axis modal code to be clamped
  mProbeArmModal.format(105); // Default to M105 retract the tool setting probe arm

  if (highFeedrate <= 0) {
    error(localize("You must set 'highFeedrate' because axes are not synchronized for rapid traversal."));
    return;
  }

  if (!getProperty("separateWordsWithSpace")) {
    setWordSeparator("");
  }
  saveShowSequenceNumbers = getProperty("showSequenceNumbers");
  sequenceNumber = getProperty("sequenceNumberStart");
  writeln("%");

  if (programName) {
    var programId;
    try {
      programId = getAsInt(programName);
    } catch (e) {
      error(localize("Program name must be a number."));
      return;
    }
    if (!((programId >= 1) && (programId <= 99999))) {
      error(localize("Program number is out of range."));
      return;
    }
    writeln(
      "O" + oFormat.format(programId) +
      conditional(programComment, " " + formatComment(programComment.substr(0, maximumLineLength - 2 - ("O" + oFormat.format(programId)).length - 1)))
    );
    lastSubprogram = (initialSubprogramNumber - 1);
  } else {
    error(localize("Program name has not been specified."));
    return;
  }

  if (getProperty("useG0")) {
    writeComment(localize("Using G0 which travels along dogleg path."));
  } else {
    writeComment(subst(localize("Using high feed G1 F%1 instead of G0."), feedFormat.format(highFeedrate)));
  }

  if (getProperty("writeVersion")) {
    if ((typeof getHeaderVersion == "function") && getHeaderVersion()) {
      writeComment(localize("post version") + ": " + getHeaderVersion());
    }
    if ((typeof getHeaderDate == "function") && getHeaderDate()) {
      writeComment(localize("post modified") + ": " + getHeaderDate());
    }
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
        var comment = "T" + toolFormat.format(tool.number) + " " +
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

        if (getProperty("useM130ToolImages")) {
          var toolRenderer = createToolRenderer();
          if (toolRenderer) {
            toolRenderer.setBackgroundColor(new Color(1, 1, 1));
            toolRenderer.setFluteColor(new Color(40.0 / 255, 40.0 / 255, 40.0 / 255));
            toolRenderer.setShoulderColor(new Color(80.0 / 255, 80.0 / 255, 80.0 / 255));
            toolRenderer.setShaftColor(new Color(80.0 / 255, 80.0 / 255, 80.0 / 255));
            toolRenderer.setHolderColor(new Color(40.0 / 255, 40.0 / 255, 40.0 / 255));
            if (i % 2 == 0) {
              toolRenderer.setBackgroundColor(new Color(1, 1, 1));
            } else {
              toolRenderer.setBackgroundColor(new Color(240 / 255.0, 240 / 255.0, 240 / 255.0));
            }
            var path = "tool" + tool.number + ".png";
            var width = 400;
            var height = 532;
            toolRenderer.exportAs(path, "image/png", tool, width, height);
          }
        }
      }
    }
  }

  // optionally cycle through all tools
  if (getProperty("optionallyCycleToolsAtStart") || getProperty("optionallyMeasureToolsAtStart")) {
    var tools = getToolTable();
    optionalSection = true;
    if (tools.getNumberOfTools() > 0) {
      writeln("");

      writeBlock(mFormat.format(0), formatComment(localize("Read note"))); // wait for operator
      writeComment(localize("With BLOCK DELETE turned off each tool will cycle through"));
      writeComment(localize("the spindle to verify that the correct tool is in the tool magazine"));
      if (getProperty("optionallyMeasureToolsAtStart")) {
        writeComment(localize("and to automatically measure it"));
      }
      writeComment(localize("Once the tools are verified turn BLOCK DELETE on to skip verification"));
      if (getProperty("toolArmDrive") && getProperty("optionallyMeasureToolsAtStart")) {
        writeBlock(mProbeArmModal.format(104), formatComment("Extend tool setting probe arm"));
      }
      for (var i = 0; i < tools.getNumberOfTools(); ++i) {
        var tool = tools.getTool(i);
        if (getProperty("optionallyMeasureToolsAtStart") && (tool.type == TOOL_PROBE)) {
          continue;
        }
        var comment = "T" + toolFormat.format(tool.number) + " " +
          "D=" + xyzFormat.format(tool.diameter) + " " +
          localize("CR") + "=" + xyzFormat.format(tool.cornerRadius);
        if ((tool.taperAngle > 0) && (tool.taperAngle < Math.PI)) {
          comment += " " + localize("TAPER") + "=" + taperFormat.format(tool.taperAngle) + localize("deg");
        }
        comment += " - " + getToolTypeName(tool.type);
        writeComment(comment);
        if (getProperty("optionallyMeasureToolsAtStart")) {
          writeToolMeasureBlock(tool, true);
        } else {
          writeToolCycleBlock(tool);
        }
      }
    }
    if (getProperty("toolArmDrive") && getProperty("optionallyMeasureToolsAtStart")) {
      writeBlock(mProbeArmModal.format(105), formatComment("Retract tool setting probe arm"));
    }
    optionalSection = false;
    writeln("");
  }

  if (false /*getProperty("useMultiAxisFeatures")*/) {
    var failed = false;
    var dynamicWCSs = {};
    for (var i = 0; i < getNumberOfSections(); ++i) {
      var section = getSection(i);
      var description = section.hasParameter("operation-comment") ? section.getParameter("operation-comment") : ("#" + (i + 1));
      if (!section.hasDynamicWorkOffset()) {
        error(subst(localize("Dynamic work offset has not been set for operation '%1'."), description));
        failed = true;
      }

      var o = section.getDynamicWCSOrigin();
      var p = section.getDynamicWCSPlane();
      if (dynamicWCSs[section.getDynamicWorkOffset()]) {
        if ((Vector.diff(o, dynamicWCSs[section.getDynamicWorkOffset()].origin).length > 1e-9) ||
            (Matrix.diff(p, dynamicWCSs[section.getDynamicWorkOffset()].plane).n1 > 1e-9)) {
          error(subst(localize("Dynamic WCS mismatch for operation '%1'."), description));
          failed = true;
        }
      } else {
        dynamicWCSs[section.getDynamicWorkOffset()] = {origin:o, plane:p};
      }
    }
    if (failed) {
      return;
    }
  }

  if (false) {
    // check for duplicate tool number
    for (var i = 0; i < getNumberOfSections(); ++i) {
      var sectioni = getSection(i);
      var tooli = sectioni.getTool();
      for (var j = i + 1; j < getNumberOfSections(); ++j) {
        var sectionj = getSection(j);
        var toolj = sectionj.getTool();
        if (tooli.number == toolj.number) {
          if (xyzFormat.areDifferent(tooli.diameter, toolj.diameter) ||
              xyzFormat.areDifferent(tooli.cornerRadius, toolj.cornerRadius) ||
              abcFormat.areDifferent(tooli.taperAngle, toolj.taperAngle) ||
              (tooli.numberOfFlutes != toolj.numberOfFlutes)) {
            error(
              subst(
                localize("Using the same tool number for different cutter geometry for operation '%1' and '%2'."),
                sectioni.hasParameter("operation-comment") ? sectioni.getParameter("operation-comment") : ("#" + (i + 1)),
                sectionj.hasParameter("operation-comment") ? sectionj.getParameter("operation-comment") : ("#" + (j + 1))
              )
            );
            return;
          }
        }
      }
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
  writeBlock(gAbsIncModal.format(90), gFeedModeModal.format(94), gPlaneModal.format(17));

  switch (unit) {
  case IN:
    writeBlock(gUnitModal.format(20));
    break;
  case MM:
    writeBlock(gUnitModal.format(21));
    break;
  }

  coolantPressure = getProperty("coolantPressure");

  if (getProperty("chipTransport")) {
    onCommand(COMMAND_START_CHIP_TRANSPORT);
  }
  // Probing Surface Inspection
  if (typeof inspectionWriteVariables == "function") {
    inspectionWriteVariables();
  }
  if (getProperty("useLiveConnection") && (typeof liveConnectionHeader == "function")) {
    liveConnectionHeader();
  }
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

var lengthCompensationActive = false;
/** Disables length compensation if currently active or if forced. */
function disableLengthCompensation(force, message) {
  if (lengthCompensationActive || force) {
    writeBlock(gFormat.format(49), conditional(message, formatComment(message)));
    lengthCompensationActive = false;
  }
}

//Haas HSM control options
//P - Controls the smoothness level, P1(rough), P2(medium), or P3(finish). Temporarily overrides Setting 191. This will round corners in an effort keep the speed from decreasing.
//E - Sets the max corner rounding value.Temporarily overrides Setting 85.
//Setting 191 sets the default smoothness to the user specified ROUGH, MEDIUM, or FINISH when G187 is not active.The Medium setting is the factory default setting.

if (hasParameter("operation:strategy") && ((getParameter("operation:strategy")) !== ("drill"))) {
  var smoothingmultiplyer;
  var accelunit;
  var smoothingfilter;
  if (hasParameter("operation:smoothingFilterTolerance")) {
    smoothingfilter = getParameter("operation:smoothingFilterTolerance")
            //writeComment("smoohtingfilter: " + (smoothingfilter)); //write smoothing filter

    if (smoothingfilter < .0015) {
       smoothingmultiplyer = 1.5;
       accelunit = 1;
       //writeComment("smoothingmultiplyer: " + (smoothingmultiplyer)); //write smoothing multiplyer
       }
    if ((smoothingfilter >= .0015) && (smoothingfilter < .0025)) {
       smoothingmultiplyer = (smoothingfilter * 1600);
       accelunit = 1;
       //writeComment("smoothingmultiplyer: " + (smoothingmultiplyer)); //write smoothing multiplyer
        }
    if (smoothingfilter >= .0025) {
       smoothingmultiplyer = 4;
       accelunit = 0;
       //writeComment("smoothingmultiplyer: " + (smoothingmultiplyer)); //write smoothing multiplyer
       }
  }
    else {
       smoothingmultiplyer = 1; //set smoothing multipyer to 1 if no smoothing filter parameter exists
       accelunit = 1; //set accel "P" value adjuster to 1 if no smoothing filter parameter exists
  }


  if (hasParameter("operation:tolerance")) {
     var tolerance = (getParameter("operation:tolerance"));
     if (tolerance <= .00125) {
        writeBlock(gFormat.format(187) + " P" + (2 + accelunit) + " E" + (xyzFormat.format(smoothingmultiplyer) * .02));//" (<= .002 hsm tol)"
        }
        else {
        if ((tolerance > .00125) && (tolerance < .003125)) {
           writeBlock(gFormat.format(187) + " P" + (1 + accelunit) + " E" + (xyzFormat.format((smoothingmultiplyer) * ((tolerance) * 16))));//" (> .002 hsm tol)"
           }
           else {
           if ((tolerance >= .00316) || ((smoothingfilter + tolerance) >= .0045)) {
              writeBlock(gFormat.format(187) + " P1" + " E" + (0.200));//"(> .00316 or .0045 combined)"
           }
        }
     }

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
        return "F#" + (firstFeedParameter + feedContext.id);
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
    if ((movements & (1 << MOVEMENT_HIGH_FEED)) || (highFeedMapping != HIGH_FEED_NO_MAPPING)) {
      var feed;
      if (hasParameter("operation:highFeedrateMode") && getParameter("operation:highFeedrateMode") != "disabled") {
        feed = getParameter("operation:highFeedrate");
      } else {
        feed = this.highFeedrate;
      }
      var feedContext = new FeedContext(id, localize("High Feed"), feed);
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_HIGH_FEED] = feedContext;
      activeMovements[MOVEMENT_RAPID] = feedContext;
    }
    ++id;
  }

  for (var i = 0; i < activeFeeds.length; ++i) {
    var feedContext = activeFeeds[i];
    writeBlock("#" + (firstFeedParameter + feedContext.id) + "=" + feedFormat.format(feedContext.feed), formatComment(feedContext.description));
  }
}

var currentWorkPlaneABC = undefined;
var activeG254 = false;

function forceWorkPlane() {
  currentWorkPlaneABC = undefined;
}

function defineWorkPlane(_section, _setWorkPlane) {
  var abc = new Vector(0, 0, 0);
  if (machineConfiguration.isMultiAxisConfiguration()) { // use 5-axis indexing for multi-axis mode
    if (isPolarModeActive()) {
      abc = getCurrentDirection();
    } else {
      abc = _section.isMultiAxis() ? _section.getInitialToolAxisABC() : getWorkPlaneMachineABC(_section.workPlane, _setWorkPlane);
    }
    if (_section.isMultiAxis() || isPolarModeActive()) {
      cancelTransformation();
      if (_setWorkPlane) {
        if (activeG254) {
          writeBlock(gFormat.format(255)); // cancel DWO
          activeG254 = false;
        }
        forceWorkPlane();
        positionABC(abc, true);
      }
    } else {
      if (_setWorkPlane) {
        setWorkPlane(abc);
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

function setWorkPlane(abc) {
  if (!machineConfiguration.isMultiAxisConfiguration()) {
    return; // ignore
  }

  var _skipBlock = false;
  if (!((currentWorkPlaneABC == undefined) ||
        abcFormat.areDifferent(abc.x, currentWorkPlaneABC.x) ||
        abcFormat.areDifferent(abc.y, currentWorkPlaneABC.y) ||
        abcFormat.areDifferent(abc.z, currentWorkPlaneABC.z))) {
    if (operationNeedsSafeStart) {
      _skipBlock = true;
    } else {
      return; // no change
    }
  }
  skipBlock = _skipBlock;
  onCommand(COMMAND_UNLOCK_MULTI_AXIS);

  if (!retracted) {
    skipBlock = _skipBlock;
    moveToSafeRetractPosition(false);
  }

  if (activeG254) {
    skipBlock = _skipBlock;
    activeG254 = false;
    writeBlock(gFormat.format(255)); // cancel DWO
  }

  skipBlock = _skipBlock;
  positionABC(abc, true);

  skipBlock = _skipBlock;
  if (!currentSection.isMultiAxis() && !isPolarModeActive()) {
    onCommand(COMMAND_LOCK_MULTI_AXIS);
  }

  if (getProperty("useMultiAxisFeatures") &&
      (abcFormat.isSignificant(abc.x % (Math.PI * 2)) || abcFormat.isSignificant(abc.y % (Math.PI * 2)) || abcFormat.isSignificant(abc.z % (Math.PI * 2)))) {
    skipBlock = _skipBlock;
    activeG254 = true;
    writeBlock(gFormat.format(254)); // enable DWO
  }
  currentWorkPlaneABC = abc;
}

function positionABC(abc, force) {
  if (typeof unwindABC == "function") {
    unwindABC(abc, false);
  }
  if (force) {
    forceABC();
  }
  var a = aOutput.format(abc.x);
  var b = bOutput.format(abc.y);
  var c = cOutput.format(abc.z);
  if (a || b || c) {
    if (!retracted) {
      if (typeof moveToSafeRetractPosition == "function") {
        moveToSafeRetractPosition();
      } else {
        writeRetract(Z);
      }
    }
    onCommand(COMMAND_UNLOCK_MULTI_AXIS);
    gMotionModal.reset();
    writeBlock(gMotionModal.format(0), a, b, c);
    currentMachineABC = new Vector(abc);
    if (getCurrentSectionId() != -1) {
      setCurrentABC(abc); // required for machine simulation
    }
  }
}

var closestABC = true; // choose closest machine angles
var currentMachineABC = new Vector(0, 0, 0);

// resets the rotary axes to 0 if reset is specified when creating the axis
function resetABC(previousABC) {
  var axis = new Array(machineConfiguration.getAxisU(), machineConfiguration.getAxisV(), machineConfiguration.getAxisW());
  var abc = new Vector(previousABC);
  for (var i in axis) {
    if (axis[i].isEnabled() && (axis[i].getReset() & 1)) {
      var coordinate = axis[i].getCoordinate();
      if (abcFormat.getResultingValue(Math.abs(abc.getCoordinate(coordinate))) > 360) {
        abc.setCoordinate(coordinate, 0);
      }
    }
  }
  return abc;
}

function getPreferenceWeight(_abc) {
  var axis = new Array(machineConfiguration.getAxisU(), machineConfiguration.getAxisV(), machineConfiguration.getAxisW());
  var abc = new Array(_abc.x, _abc.y, _abc.z);
  var preference = 0;
  for (var i = 0; i < 3; ++i) {
    if (axis[i].isEnabled()) {
      preference += ((abcFormat.getResultingValue(abc[axis[i].getCoordinate()]) * axis[i].getPreference()) < 0) ? -1 : 1;
    }
  }
  return preference;
}

function remapToABC(currentABC, previousABC, useReset) {
  if (useReset) {
    previousABC = resetABC(previousABC); // support 'reset' flag in axes definitions
  }
  var both = machineConfiguration.getABCByDirectionBoth(machineConfiguration.getDirection(currentABC));
  var abc1 = machineConfiguration.remapToABC(both[0], previousABC);
  abc1 = machineConfiguration.remapABC(abc1);
  var abc2 = machineConfiguration.remapToABC(both[1], previousABC);
  abc2 = machineConfiguration.remapABC(abc2);

  // choose angles based on preference
  var preference1 = getPreferenceWeight(abc1);
  var preference2 = getPreferenceWeight(abc2);
  if (preference1 > preference2) {
    return abc1;
  } else if (preference2 > preference1) {
    return abc2;
  }

  // choose angles based on closest solution
  if (Vector.diff(abc1, previousABC).length < Vector.diff(abc2, previousABC).length) {
    return abc1;
  } else {
    return abc2;
  }
}

function getWorkPlaneMachineABC(workPlane, _setWorkPlane) {
  var W = workPlane; // map to global frame

  var abc = machineConfiguration.getABC(W);
  if (closestABC) {
    if (currentMachineABC) {
      abc = remapToABC(abc, currentMachineABC, true);
    } else {
      abc = machineConfiguration.getPreferredABC(abc);
    }
  } else {
    abc = machineConfiguration.getPreferredABC(abc);
  }

  try {
    abc = machineConfiguration.remapABC(abc);
  } catch (e) {
    error(
      localize("Machine angles not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
    );
  }

  var direction = machineConfiguration.getDirection(abc);
  if (!isSameDirection(direction, W.forward)) {
    error(localize("Orientation not supported."));
  }

  if (!machineConfiguration.isABCSupported(abc)) {
    error(
      localize("Work plane is not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
    );
  }

  var tcp = false;
  if (tcp) {
    setRotation(W); // TCP mode
  } else {
    var O = machineConfiguration.getOrientation(abc);
    var R = machineConfiguration.getRemainingOrientation(abc, W);
    setRotation(R);
  }

  return abc;
}

function unwindABC(abc, force) {
  var method = "G28"; // supported methods are "G28" and "G92"
  if (method != "G92" && method != "G28") {
    error(localize("Unsupported unwindABC method."));
    return;
  }
  var axes = new Array(machineConfiguration.getAxisU(), machineConfiguration.getAxisV(), machineConfiguration.getAxisW());
  for (var i in axes) {
    if (axes[i].isEnabled()) {
      if (axes[i].getReset() > 0 || force) {
        var j = axes[i].getCoordinate();
        var nearestABC = remapToABC(currentMachineABC, abc, false);
        var distanceABC = abcFormat.getResultingValue(Math.abs(Vector.diff(currentMachineABC, abc).getCoordinate(j)));
        var distanceOrigin = 0;
        if (method == "G92") {
          distanceOrigin = abcFormat.getResultingValue(Math.abs(Vector.diff(nearestABC, abc).getCoordinate(j)));
        } else { // G28
          distanceOrigin = abcFormat.getResultingValue(Math.abs(currentMachineABC.getCoordinate(j))) % 360; // calculate distance for unwinding axis
          distanceOrigin = (distanceOrigin > 180) ? 360 - distanceOrigin : distanceOrigin; // take shortest route to 0
          distanceOrigin += abcFormat.getResultingValue(Math.abs(abc.getCoordinate(j))); // add distance from 0 to new position
        }
        var revolutions = distanceABC / 360;
        if (distanceABC > distanceOrigin && (revolutions > 1)) {
          var angle = method == "G92" ? nearestABC.getCoordinate(j) : 0;
          var words = method == "G92" ? [gFormat.format(92)] : [gFormat.format(28), gAbsIncModal.format(91)];
          var outputs = [aOutput, bOutput, cOutput];
          outputs[j].reset();
          words.push(outputs[j].format(angle));
          if (!retracted) {
            if (typeof moveToSafeRetractPosition == "function") {
              moveToSafeRetractPosition();
            } else {
              writeRetract(Z);
            }
          }
          onCommand(COMMAND_UNLOCK_MULTI_AXIS);
          writeBlock(words);
          writeBlock((gAbsIncModal.getCurrent() == 91) ? gAbsIncModal.format(90) : "");
          currentMachineABC.setCoordinate(j, angle);
        }
      }
    }
  }
}

function printProbeResults() {
  return currentSection.getParameter("printResults", 0) == 1;
}

var probeOutputWorkOffset = 1;

function onPassThrough(text) {
  var commands = String(text).split(",");
  for (text in commands) {
    writeBlock(commands[text]);
  }
}

function onManualNC(command, value) {
  switch (command) {
  case COMMAND_ACTION:
    if (String(value).toUpperCase() == "CYCLE_REVERSAL") {
      cycleReverse = true;
    } else if (String(value).toUpperCase() == "VFD_LOW") {
      coolantPressure = "P0";
    } else if (String(value).toUpperCase() == "VFD_NORMAL") {
      coolantPressure = "P1";
    } else if (String(value).toUpperCase() == "VFD_HIGH") {
      coolantPressure = "P2";
    } else if (String(value).toUpperCase() == "USEPOLARMODE") {
      usePolarMode = true;
    }
    break;
  default:
    expandManualNC(command, value);
  }
}

function onParameter(name, value) {
  if (name == "probe-output-work-offset") {
    probeOutputWorkOffset = (value > 0) ? value : 1;
  }
}

var seenPatternIds = {};

function previewImage() {
  var permittedExtensions = ["JPG", "MP4", "MOV", "PNG", "JPEG"];
  var patternId = currentSection.getPatternId();
  var show = false;
  if (!seenPatternIds[patternId]) {
    show = true;
    seenPatternIds[patternId] = true;
  }
  var images = [];
  if (show) {
    if (FileSystem.isFile(FileSystem.getCombinedPath(FileSystem.getFolderPath(getOutputPath()), modelImagePath))) {
      images.push(modelImagePath);
    }
    if (hasParameter("autodeskcam:preview-name") && FileSystem.isFile(FileSystem.getCombinedPath(FileSystem.getFolderPath(getOutputPath()), getParameter("autodeskcam:preview-name")))) {
      images.push(getParameter("autodeskcam:preview-name"));
    }

    for (var i = 0; i < images.length; ++i) {
      var fileExtension = images[i].slice(images[i].lastIndexOf(".") + 1, images[i].length).toUpperCase();
      var permittedExtension = false;
      for (var j = 0; j < permittedExtensions.length; ++j) {
        if (fileExtension == permittedExtensions[j]) {
          permittedExtension = true;
          break; // found
        }
      }
      if (!permittedExtension) {
        warning(localize("The image file format " + "\"" + fileExtension + "\"" + " is not supported on HAAS controls."));
      }

      if (!getProperty("useM130PartImages") || !permittedExtension) {
        FileSystem.remove(FileSystem.getCombinedPath(FileSystem.getFolderPath(getOutputPath()), images[i])); // remove
        images.splice([i], 1); // remove from array
      }
    }
    if (images.length > 0) {
      writeBlock(mFormat.format(130), "(" + images[images.length - 1] + ")");
    }
  }
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
      writeBlock(mFormat.format(97), "P" + nFormat.format(currentSubprogram));
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
    writeBlock(mFormat.format(97), "P" + nFormat.format(currentSubprogram));
    firstPattern = true;
    subprogramStart(_initialPosition, _abc, false);
  }
}

function subprogramStart(_initialPosition, _abc, _incremental) {
  redirectToBuffer();
  var comment = "";
  if (hasParameter("operation-comment")) {
    comment = getParameter("operation-comment");
  }
  writeln(
    "N" + nFormat.format(currentSubprogram) +
    conditional(comment, formatComment(comment.substr(0, maximumLineLength - 2 - 6 - 1)))
  );
  setProperty("showSequenceNumbers", false);
  if (_incremental) {
    setIncrementalMode(_initialPosition, _abc);
  }
  gPlaneModal.reset();
  gMotionModal.reset();
}

function subprogramEnd() {
  if (firstPattern) {
    writeBlock(mFormat.format(99));
    writeln("");
    subprograms += getRedirectionBuffer();
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
  var forceToolAndRetract = optionalSection && !currentSection.isOptional();
  optionalSection = currentSection.isOptional();

  var insertToolCall = forceToolAndRetract || isFirstSection() ||
    currentSection.getForceToolChange && currentSection.getForceToolChange() ||
    (tool.number != getPreviousSection().getTool().number);

  retracted = false;

  var zIsOutput = false; // true if the Z-position has been output, used for patterns
  var newWorkOffset = isFirstSection() ||
    (getPreviousSection().workOffset != currentSection.workOffset); // work offset changes
  var newWorkPlane = isFirstSection() ||
    !isSameDirection(getPreviousSection().getGlobalFinalToolAxis(), currentSection.getGlobalInitialToolAxis()) ||
    (currentSection.isOptimizedForMachine() && getPreviousSection().isOptimizedForMachine() &&
      Vector.diff(getPreviousSection().getFinalToolAxisABC(), currentSection.getInitialToolAxisABC()).length > 1e-4) ||
    (!machineConfiguration.isMultiAxisConfiguration() && currentSection.isMultiAxis()) ||
    (!getPreviousSection().isMultiAxis() && currentSection.isMultiAxis() ||
      getPreviousSection().isMultiAxis() && !currentSection.isMultiAxis()); // force newWorkPlane between indexing and simultaneous operations

  operationNeedsSafeStart = getProperty("safeStartAllOperations") && !isFirstSection();

  if (insertToolCall || operationNeedsSafeStart) {
    if (getProperty("fastToolChange") && !isProbeOperation()) {
      currentCoolantMode = COOLANT_OFF;
    } else if (insertToolCall) { // no coolant off command if safe start operation
      onCommand(COMMAND_COOLANT_OFF);
    }
  }

  // toolpath starting information for live connection
  if (getProperty("useLiveConnection") && (typeof liveConnectionWriteData == "function")) {
    liveConnectionWriteData("toolpathStart");
  }
  // define smoothing mode
  initializeSmoothing();

  if ((insertToolCall && !getProperty("fastToolChange")) || newWorkOffset || newWorkPlane || toolChecked) {

    // stop spindle before retract during tool change
    if (insertToolCall && !isFirstSection() && !toolChecked && !getProperty("fastToolChange")) {
      onCommand(COMMAND_STOP_SPINDLE);
    }

    // retract to safe plane
    writeRetract(Z);

    if (forceResetWorkPlane && newWorkPlane) {
      forceWorkPlane();
      setWorkPlane(new Vector(0, 0, 0)); // reset working plane
    }
  }

  if (hasParameter("operation-comment")) {
    var comment = getParameter("operation-comment");
    if (comment && ((comment !== lastOperationComment) || !patternIsActive || insertToolCall)) {
      writeln("");
      writeComment(comment);
      lastOperationComment = comment;
    } else if (!patternIsActive || insertToolCall) {
      writeln("");
    }
  } else {
    writeln("");
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

  // enable polar interpolation
  if (usePolarMode && (tool.type != TOOL_PROBE)) {
    if (polarDirection == undefined) {
      error(localize("Polar direction property must be a vector - x,y,z."));
      return;
    }
    setPolarMode(currentSection, true);
  }

  defineWorkPlane(currentSection, false);
  var initialPosition = isPolarModeActive() ? getCurrentPosition() : getFramePosition(currentSection.getInitialPosition());
  forceAny();

  if (operationNeedsSafeStart) {
    if (!retracted) {
      skipBlock = true;
      writeRetract(Z);
    }
  }

  if (insertToolCall || operationNeedsSafeStart) {

    if (getProperty("useM130ToolImages")) {
      writeBlock(mFormat.format(130), "(tool" + tool.number + ".png)");
    }

    if (!isFirstSection() && getProperty("optionalStop") && insertToolCall) {
      onCommand(COMMAND_OPTIONAL_STOP);
    }

    if ((tool.number > 200 && tool.number < 1000) || tool.number > 9999) {
      warning(localize("Tool number out of range."));
    }

    skipBlock = !insertToolCall;
    writeToolBlock(
      "T" + toolFormat.format(tool.number),
      mFormat.format(6)
    );
    if (tool.comment) {
      writeComment(tool.comment);
    }
    if (measureTool) {
      writeToolMeasureBlock(tool, false);
    }
    if (insertToolCall) {
      forceWorkPlane();
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
        writeComment(localize("ZMIN") + "=" + xyzFormat.format(zRange.getMinimum()));
      }
    }
  }

  // activate those two coolant modes before the spindle is turned on
  if ((tool.coolant == COOLANT_THROUGH_TOOL) || (tool.coolant == COOLANT_AIR_THROUGH_TOOL) || (tool.coolant == COOLANT_FLOOD_THROUGH_TOOL)) {
    if (!isFirstSection() && !insertToolCall && (currentCoolantMode != tool.coolant)) {
      onCommand(COMMAND_STOP_SPINDLE);
      forceSpindleSpeed = true;
    }
    setCoolant(tool.coolant);
  } else if ((currentCoolantMode == COOLANT_THROUGH_TOOL) || (currentCoolantMode == COOLANT_AIR_THROUGH_TOOL) || (currentCoolantMode == COOLANT_FLOOD_THROUGH_TOOL)) {
    onCommand(COMMAND_STOP_SPINDLE);
    setCoolant(COOLANT_OFF);
    forceSpindleSpeed = true;
  }

  if (toolChecked) {
    forceSpindleSpeed = true; // spindle must be restarted if tool is checked without a tool change
    toolChecked = false; // state of tool is not known at the beginning of a section since it could be broken for the previous section
  }
  var spindleChanged = tool.type != TOOL_PROBE &&
    (insertToolCall || forceSpindleSpeed || isFirstSection() ||
    (rpmFormat.areDifferent(spindleSpeed, sOutput.getCurrent())) ||
    (tool.clockwise != getPreviousSection().getTool().clockwise));
  if (spindleChanged || (operationNeedsSafeStart && tool.type != TOOL_PROBE)) {
    forceSpindleSpeed = false;

    if (spindleSpeed < 1) {
      error(localize("Spindle speed out of range."));
      return;
    }
    maximumSpindleRPM = machineConfiguration.getMaximumSpindleSpeed() > 0 ? machineConfiguration.getMaximumSpindleSpeed() : maximumSpindleRPM;
    if (spindleSpeed > maximumSpindleRPM) {
      warning(subst(localize("Spindle speed '" + spindleSpeed + " RPM' exceeds maximum value of '%1 RPM."), maximumSpindleRPM));
    }
    skipBlock = !spindleChanged;
    writeBlock(
      sOutput.format(spindleSpeed), mFormat.format(tool.clockwise ? 3 : 4)
    );
  }

  previewImage();

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

  // wcs
  if (insertToolCall || operationNeedsSafeStart) { // force work offset when changing tool
    currentWorkOffset = undefined;
    skipBlock = operationNeedsSafeStart && !newWorkOffset && !insertToolCall;
  }
  if (currentSection.workOffset != currentWorkOffset) {
    if (!skipBlock) {
      forceWorkPlane();
    }
    writeBlock(currentSection.wcs);
    currentWorkOffset = currentSection.workOffset;
  }

  if (newWorkPlane || (insertToolCall && !retracted)) { // go to home position for safety
    if (!retracted) {
      writeRetract(Z);
    }
    if (getProperty("forceHomeOnIndexing") && machineConfiguration.isMultiAxisConfiguration()) {
      writeRetract(X, Y);
    }
  }

  if (newWorkOffset) {
    forceWorkPlane();
  }

  var abc = defineWorkPlane(currentSection, true);

  setProbeAngle(); // output probe angle rotations if required

  // set coolant after we have positioned at Z
  setCoolant(tool.coolant);

  gMotionModal.reset();

  if (getProperty("useSSV")) {
    if (!(currentSection.getTool().type == TOOL_PROBE || currentSection.checkGroup(STRATEGY_DRILLING))) {
      writeBlock(ssvModal.format(138));
    } else {
      writeBlock(ssvModal.format(139));
    }
  }

  smoothing.force = operationNeedsSafeStart && (getProperty("useSmoothing") != "-1");
  setSmoothing(smoothing.isAllowed);

  var G = ((highFeedMapping != HIGH_FEED_NO_MAPPING) || !getProperty("useG0")) ? 1 : 0;
  var F = ((highFeedMapping != HIGH_FEED_NO_MAPPING) || !getProperty("useG0")) ? getFeed(highFeedrate) : "";
  if (insertToolCall || retracted || operationNeedsSafeStart || !lengthCompensationActive ||
      (!isFirstSection() && (currentSection.isMultiAxis() != getPreviousSection().isMultiAxis()))) {
    var _skipBlock = !(insertToolCall || retracted ||
      (!isFirstSection() && (currentSection.isMultiAxis() != getPreviousSection().isMultiAxis())));
    var lengthOffset = tool.lengthOffset;
    if ((lengthOffset > 200 && lengthOffset < 1000) || lengthOffset > 9999) {
      error(localize("Length offset out of range."));
      return;
    }

    gMotionModal.reset();
    writeBlock(gPlaneModal.format(17));

    if (!machineConfiguration.isHeadConfiguration()) {
      if (operationSupportsTCP && useDwoForPositioning && currentSection.isMultiAxis()) {
        prepositionDWO(initialPosition, abc, skipBlock);
      } else {
        skipBlock = _skipBlock;
        writeBlock(gAbsIncModal.format(90), gMotionModal.format(G), xOutput.format(initialPosition.x), yOutput.format(initialPosition.y), F);
        skipBlock = _skipBlock;
        writeBlock(
          gMotionModal.format(0),
          conditional(!currentSection.isMultiAxis() || !operationSupportsTCP, gFormat.format(43)),
          conditional(currentSection.isMultiAxis() && operationSupportsTCP, gFormat.format(234)),
          zOutput.format(initialPosition.z),
          hFormat.format(lengthOffset)
        );
      }
    } else {
      skipBlock = _skipBlock;
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(currentSection.isMultiAxis() && operationSupportsTCP ? 0 : G),
        conditional(!currentSection.isMultiAxis() || !operationSupportsTCP, gFormat.format(43)),
        conditional(currentSection.isMultiAxis() && operationSupportsTCP, gFormat.format(234)),
        xOutput.format(initialPosition.x),
        yOutput.format(initialPosition.y),
        zOutput.format(initialPosition.z),
        F,
        hFormat.format(lengthOffset)
      );
    }
    zIsOutput = true;
    lengthCompensationActive = true;
    if (_skipBlock) {
      forceXYZ();
      var x = xOutput.format(initialPosition.x);
      var y = yOutput.format(initialPosition.y);
      if (x && y) {
        // axes are not synchronized
        writeBlock(gAbsIncModal.format(90), gMotionModal.format(G), x, y, F);
      } else {
        writeBlock(gAbsIncModal.format(90), gMotionModal.format(0), x, y);
      }
    }
  } else {
    validate(lengthCompensationActive, "Length compensation is not active.");
    if (getCurrentPosition().z < initialPosition.z) {
      writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
      zIsOutput = true;
    }
    var x = xOutput.format(initialPosition.x);
    var y = yOutput.format(initialPosition.y);
    if (x && y) {
      // axes are not synchronized
      writeBlock(gAbsIncModal.format(90), gMotionModal.format(G), x, y, F);
    } else {
      writeBlock(gAbsIncModal.format(90), gMotionModal.format(0), x, y);
    }
  }
  if (gMotionModal.getCurrent() == 0) {
    forceFeed();
  }
  gMotionModal.reset();
  validate(lengthCompensationActive, "Length compensation is not active.");

  if (insertToolCall || operationNeedsSafeStart) {
    if (getProperty("preloadTool")) {
      var nextTool = getNextTool(tool.number);
      if (nextTool) {
        skipBlock = !insertToolCall;
        writeBlock("T" + toolFormat.format(nextTool.number));
      } else {
        // preload first tool
        var section = getSection(0);
        var firstToolNumber = section.getTool().number;
        if (tool.number != firstToolNumber) {
          skipBlock = !insertToolCall;
          writeBlock("T" + toolFormat.format(firstToolNumber));
        }
      }
    }
  }

  if (isProbeOperation()) {
    validate(probeVariables.probeAngleMethod != "G68", "You cannot probe while G68 Rotation is in effect.");
    validate(probeVariables.probeAngleMethod != "G54.4", "You cannot probe while workpiece setting error compensation G54.4 is enabled.");
    writeBlock(gFormat.format(65), "P" + 9832); // spin the probe on
    inspectionCreateResultsFileHeader();
  } else {
    // surface Inspection
    if (isInspectionOperation() && (typeof inspectionProcessSectionStart == "function")) {
      inspectionProcessSectionStart();
    }
  }
  // define subprogram
  subprogramDefine(initialPosition, abc, retracted, zIsOutput);
}

function prepositionDWO(position, abc, _skipBlock) {
  forceFeed();
  var G = ((highFeedMapping != HIGH_FEED_NO_MAPPING) || !getProperty("useG0")) ? 1 : 0;
  var F = ((highFeedMapping != HIGH_FEED_NO_MAPPING) || !getProperty("useG0")) ? getFeed(highFeedrate) : "";
  var O = machineConfiguration.getOrientation(abc);
  var initialPositionDWO = O.getTransposed().multiply(getGlobalPosition(currentSection.getInitialPosition()));

  skipBlock = _skipBlock;
  writeBlock(gFormat.format(254));
  skipBlock = _skipBlock;
  writeBlock(gAbsIncModal.format(90), gMotionModal.format(G), xOutput.format(initialPositionDWO.x), yOutput.format(initialPositionDWO.y), F);
  skipBlock = _skipBlock;
  writeBlock(gFormat.format(255));
  skipBlock = _skipBlock;
  writeBlock(
    gMotionModal.format(0), // G0 motion mode is required for the G234 command
    gFormat.format(234),
    xOutput.format(position.x), yOutput.format(position.y), zOutput.format(position.z),
    hFormat.format(tool.lengthOffset)
  );
  lengthCompensationActive = true;
}

function onDwell(seconds) {
  if (seconds > 99999.999) {
    warning(localize("Dwelling time is out of range."));
  }
  seconds = clamp(0.001, seconds, 99999.999);
  writeBlock(gFeedModeModal.format(94), gFormat.format(4), "P" + milliFormat.format(seconds * 1000));
}

function onSpindleSpeed(spindleSpeed) {
  writeBlock(sOutput.format(spindleSpeed));
}

function onCycle() {
  writeBlock(gPlaneModal.format(17));
}

function getCommonCycle(x, y, z, r, c) {
  forceXYZ();
  if (isPolarModeActive()) {
    var polarPosition = getPolarPosition(x, y, z);
    return [xOutput.format(polarPosition.first.x), yOutput.format(polarPosition.first.y),
      zOutput.format(polarPosition.first.z),
      aOutput.format(polarPosition.second.x),
      bOutput.format(polarPosition.second.y),
      cOutput.format(polarPosition.second.z),
      "R" + xyzFormat.format(r)];
  } else {
    if (incrementalMode) {
      zOutput.format(c);
      return [xOutput.format(x), yOutput.format(y),
        "Z" + xyzFormat.format(z - r),
        "R" + xyzFormat.format(r - c)];
    } else {
      return [xOutput.format(x), yOutput.format(y),
        zOutput.format(z),
        "R" + xyzFormat.format(r)];
    }
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

/** Convert approach to sign. */
function approach(value) {
  validate((value == "positive") || (value == "negative"), "Invalid approach.");
  return (value == "positive") ? 1 : -1;
}

function setProbeAngleMethod() {
  probeVariables.probeAngleMethod = (machineConfiguration.getNumberOfAxes() < 5 || is3D()) ? (getProperty("useG54x4") ? "G54.4" : "G68") : "UNSUPPORTED";
  var axes = [machineConfiguration.getAxisU(), machineConfiguration.getAxisV(), machineConfiguration.getAxisW()];
  for (var i = 0; i < axes.length; ++i) {
    if (axes[i].isEnabled() && isSameDirection((axes[i].getAxis()).getAbsolute(), new Vector(0, 0, 1)) && axes[i].isTable()) {
      probeVariables.probeAngleMethod = "AXIS_ROT";
      probeVariables.rotationalAxis = axes[i].getCoordinate();
      break;
    }
  }
  probeVariables.outputRotationCodes = true;
}

/** Output rotation offset based on angular probing cycle. */
function setProbeAngle() {
  if (probeVariables.outputRotationCodes) {
    validate(probeOutputWorkOffset <= 6, "Angular Probing only supports work offsets 1-6.");
    if (probeVariables.probeAngleMethod == "G68" && (Vector.diff(currentSection.getGlobalInitialToolAxis(), new Vector(0, 0, 1)).length > 1e-4)) {
      error(localize("You cannot use multi axis toolpaths while G68 Rotation is in effect."));
    }
    var validateWorkOffset = false;
    switch (probeVariables.probeAngleMethod) {
    case "G54.4":
      var param = 26000 + (probeOutputWorkOffset * 10);
      writeBlock("#" + param + "=#135");
      writeBlock("#" + (param + 1) + "=#136");
      writeBlock("#" + (param + 5) + "=#144");
      writeBlock(gFormat.format(54.4), "P" + probeOutputWorkOffset);
      break;
    case "G68":
      gRotationModal.reset();
      gAbsIncModal.reset();
      writeBlock(gRotationModal.format(68), gAbsIncModal.format(90), probeVariables.compensationXY, "R[#194]");
      validateWorkOffset = true;
      break;
    case "AXIS_ROT":
      var param = 5200 + probeOutputWorkOffset * 20 + probeVariables.rotationalAxis + 4;
      writeBlock("#" + param + " = " + "[#" + param + " + #194]");
      forceWorkPlane(); // force workplane to rotate ABC in order to apply rotation offsets
      currentWorkOffset = undefined; // force WCS output to make use of updated parameters
      validateWorkOffset = true;
      break;
    default:
      error(localize("Angular Probing is not supported for this machine configuration."));
      return;
    }
    if (validateWorkOffset) {
      for (var i = currentSection.getId(); i < getNumberOfSections(); ++i) {
        if (getSection(i).workOffset != currentSection.workOffset) {
          error(localize("WCS offset cannot change while using angle rotation compensation."));
          return;
        }
      }
    }
    probeVariables.outputRotationCodes = false;
  }
}

function protectedProbeMove(_cycle, x, y, z) {
  var _x = xOutput.format(x);
  var _y = yOutput.format(y);
  var _z = zOutput.format(z);
  if (_z && z >= getCurrentPosition().z) {
    writeBlock(gFormat.format(65), "P" + 9810, _z, getFeed(cycle.feedrate)); // protected positioning move
  }
  if (_x || _y) {
    writeBlock(gFormat.format(65), "P" + 9810, _x, _y, getFeed(highFeedrate)); // protected positioning move
  }
  if (_z && z < getCurrentPosition().z) {
    writeBlock(gFormat.format(65), "P" + 9810, _z, getFeed(cycle.feedrate)); // protected positioning move
  }
}

function cancelG68Rotation(force) {
  if (force) {
    gRotationModal.reset();
  }
  writeBlock(gRotationModal.format(69));
}

function onCyclePoint(x, y, z) {
  if (isInspectionOperation() && (typeof inspectionCycleInspect == "function")) {
    inspectionCycleInspect(cycle, x, y, z);
    return;
  }
  if (!isSameDirection(getRotation().forward, new Vector(0, 0, 1))) {
    expandCyclePoint(x, y, z);
    return;
  }
  if (isProbeOperation()) {
    if (!isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1))) {
      if (!allowIndexingWCSProbing && currentSection.strategy == "probe") {
        error(localize("Updating WCS / work offset using probing is only supported by the CNC in the WCS frame."));
        return;
      } else if (getProperty("useMultiAxisFeatures")) {
        error(localize("Your machine does not support the selected probing operation with DWO enabled."));
        return;
      }
    }
    if (printProbeResults()) {
      writeProbingToolpathInformation(z - cycle.depth + tool.diameter / 2);
      inspectionWriteCADTransform();
      inspectionWriteWorkplaneTransform();
      if (typeof inspectionWriteVariables == "function") {
        inspectionVariables.pointNumber += 1;
      }
    }
    protectedProbeMove(cycle, x, y, z);
  }

  var forceCycle = false;
  switch (cycleType) {
  case "tapping-with-chip-breaking":
  case "left-tapping-with-chip-breaking":
  case "right-tapping-with-chip-breaking":
    forceCycle = true;
    if (!isFirstCyclePoint()) {
      writeBlock(gCycleModal.format(80));
      gMotionModal.reset();
    }
  }
  if (forceCycle || isFirstCyclePoint() || isProbeOperation()) {
    if (!isProbeOperation()) {
      // return to initial Z which is clearance plane and set absolute mode
      repositionToCycleClearance(cycle, x, y, z);
    }

    var F = cycle.feedrate;
    var P = !cycle.dwell ? 0 : clamp(1, cycle.dwell * 1000, 99999999); // in milliseconds

    switch (cycleType) {
    case "drilling":
      writeBlock(
        gRetractModal.format(98), gCycleModal.format(81),
        getCommonCycle(x, y, z, cycle.retract, cycle.clearance),
        conditional(cycleReverse, "E2000"), feedOutput.format(F)
      );
      break;
    case "counter-boring":
      if (P > 0) {
        writeBlock(
          gRetractModal.format(98), gCycleModal.format(82),
          getCommonCycle(x, y, z, cycle.retract, cycle.clearance),
          "P" + milliFormat.format(P), // not optional
          conditional(cycleReverse, "E2000"), feedOutput.format(F)
        );
      } else {
        writeBlock(
          gRetractModal.format(98), gCycleModal.format(81),
          getCommonCycle(x, y, z, cycle.retract, cycle.clearance),
          conditional(cycleReverse, "E2000"), feedOutput.format(F)
        );
      }
      break;
    case "chip-breaking":
      if ((cycle.accumulatedDepth < cycle.depth) && (cycle.incrementalDepthReduction > 0)) {
        expandCyclePoint(x, y, z);
      } else if (cycle.accumulatedDepth < cycle.depth) {
        writeBlock(
          gRetractModal.format(98), gCycleModal.format(73),
          getCommonCycle(x, y, z, cycle.retract, cycle.clearance),
          ("Q" + xyzFormat.format(cycle.incrementalDepth)),
          ("K" + xyzFormat.format(cycle.accumulatedDepth)),
          conditional(P > 0, "P" + milliFormat.format(P)), // optional
          conditional(cycleReverse, "E2000"), feedOutput.format(F)
        );
      } else {
        writeBlock(
          gRetractModal.format(98), gCycleModal.format(73),
          getCommonCycle(x, y, z, cycle.retract, cycle.clearance),
          (((cycle.incrementalDepthReduction > 0) ? "I" : "Q") + xyzFormat.format(cycle.incrementalDepth)),
          conditional(cycle.incrementalDepthReduction > 0, "J" + xyzFormat.format(cycle.incrementalDepthReduction)),
          conditional(cycle.incrementalDepthReduction > 0, "K" + xyzFormat.format(cycle.minimumIncrementalDepth)),
          conditional(P > 0, "P" + milliFormat.format(P)), // optional
          conditional(cycleReverse, "E2000"), feedOutput.format(F)
        );
      }
      break;
    case "deep-drilling":
      writeBlock(
        gRetractModal.format(98), gCycleModal.format(83),
        getCommonCycle(x, y, z, cycle.retract, cycle.clearance),
        (((cycle.incrementalDepthReduction > 0) ? "I" : "Q") + xyzFormat.format(cycle.incrementalDepth)),
        conditional(cycle.incrementalDepthReduction > 0, "J" + xyzFormat.format(cycle.incrementalDepthReduction)),
        conditional(cycle.incrementalDepthReduction > 0, "K" + xyzFormat.format(cycle.minimumIncrementalDepth)),
        conditional(P > 0, "P" + milliFormat.format(P)), // optional
        conditional(cycleReverse, "E2000"), feedOutput.format(F)
      );
      break;
    case "tapping":
      var tappingFPM = tool.getThreadPitch() * rpmFormat.getResultingValue(spindleSpeed);
      F = (getProperty("useG95forTapping") ? tool.getThreadPitch() : tappingFPM);
      if (getProperty("useG95forTapping")) {
        writeBlock(gFeedModeModal.format(95));
      }
      writeBlock(
        gRetractModal.format(98), gCycleModal.format((tool.type == TOOL_TAP_LEFT_HAND) ? 74 : 84),
        getCommonCycle(x, y, z, cycle.retract, cycle.clearance),
        conditional(cycleReverse, "E2000"), pitchOutput.format(F)
      );
      forceFeed();
      break;
    case "left-tapping":
      var tappingFPM = tool.getThreadPitch() * rpmFormat.getResultingValue(spindleSpeed);
      F = (getProperty("useG95forTapping") ? tool.getThreadPitch() : tappingFPM);
      if (getProperty("useG95forTapping")) {
        writeBlock(gFeedModeModal.format(95));
      }
      writeBlock(
        gRetractModal.format(98), gCycleModal.format(74),
        getCommonCycle(x, y, z, cycle.retract, cycle.clearance),
        conditional(cycleReverse, "E2000"), pitchOutput.format(F)
      );
      forceFeed();
      break;
    case "right-tapping":
      var tappingFPM = tool.getThreadPitch() * rpmFormat.getResultingValue(spindleSpeed);
      F = (getProperty("useG95forTapping") ? tool.getThreadPitch() : tappingFPM);
      if (getProperty("useG95forTapping")) {
        writeBlock(gFeedModeModal.format(95));
      }
      writeBlock(
        gRetractModal.format(98), gCycleModal.format(84),
        getCommonCycle(x, y, z, cycle.retract, cycle.clearance),
        conditional(cycleReverse, "E2000"), pitchOutput.format(F)
      );
      forceFeed();
      break;
    case "tapping-with-chip-breaking":
    case "left-tapping-with-chip-breaking":
    case "right-tapping-with-chip-breaking":
      var tappingFPM = tool.getThreadPitch() * rpmFormat.getResultingValue(spindleSpeed);
      F = (getProperty("useG95forTapping") ? tool.getThreadPitch() : tappingFPM);
      if (getProperty("useG95forTapping")) {
        writeBlock(gFeedModeModal.format(95));
      }
      // Parameter 57 bit 6, REPT RIG TAP, is set to 1 (On)
      // On Mill software versions12.09 and above, REPT RIG TAP has been moved from the Parameters to Setting 133
      var u = cycle.stock;
      var step = cycle.incrementalDepth;
      var first = true;
      while (u > cycle.bottom) {
        if (step < cycle.minimumIncrementalDepth) {
          step = cycle.minimumIncrementalDepth;
        }

        u -= step;
        step -= cycle.incrementalDepthReduction;
        gCycleModal.reset(); // required
        if ((u - 0.001) <= cycle.bottom) {
          u = cycle.bottom;
        }
        if (first) {
          first = false;
          writeBlock(
            gRetractModal.format(99), gCycleModal.format((tool.type == TOOL_TAP_LEFT_HAND ? 74 : 84)),
            getCommonCycle((gPlaneModal.getCurrent() == 19) ? u : x, (gPlaneModal.getCurrent() == 18) ? u : y, (gPlaneModal.getCurrent() == 17) ? u : z, cycle.retract, cycle.clearance),
            conditional(cycleReverse, "E2000"), pitchOutput.format(F)
          );
        } else {
          var position;
          var depth;
          switch (gPlaneModal.getCurrent()) {
          case 17:
            xOutput.reset();
            position = xOutput.format(x);
            depth = zOutput.format(u);
            break;
          case 18:
            zOutput.reset();
            position = zOutput.format(z);
            depth = yOutput.format(u);
            break;
          case 19:
            yOutput.reset();
            position = yOutput.format(y);
            depth = xOutput.format(u);
            break;
          }
          writeBlock(conditional(u <= cycle.bottom, gRetractModal.format(98)), position, depth);
        }
        if (incrementalMode) {
          setCyclePosition(cycle.retract);
        }
      }
      forceFeed();
      break;
    case "fine-boring":
      writeBlock(
        gRetractModal.format(98), gCycleModal.format(76),
        getCommonCycle(x, y, z, cycle.retract, cycle.clearance),
        "P" + milliFormat.format(P), // not optional
        "Q" + xyzFormat.format(cycle.shift),
        conditional(cycleReverse, "E2000"), feedOutput.format(F)
      );
      forceSpindleSpeed = true;
      break;
    case "back-boring":
      if (P > 0) {
        expandCyclePoint(x, y, z);
      } else {
        var dx = (gPlaneModal.getCurrent() == 19) ? cycle.backBoreDistance : 0;
        var dy = (gPlaneModal.getCurrent() == 18) ? cycle.backBoreDistance : 0;
        var dz = (gPlaneModal.getCurrent() == 17) ? cycle.backBoreDistance : 0;
        writeBlock(
          gRetractModal.format(98), gCycleModal.format(77),
          getCommonCycle(x - dx, y - dy, z - dz, cycle.bottom, cycle.clearance),
          "Q" + xyzFormat.format(cycle.shift),
          conditional(cycleReverse, "E2000"), feedOutput.format(F)
        );
        forceSpindleSpeed = true;
      }
      break;
    case "reaming":
      writeBlock(
        gRetractModal.format(98), gCycleModal.format(85),
        getCommonCycle(x, y, z, cycle.retract, cycle.clearance),
        conditional(cycleReverse, "E2000"), feedOutput.format(F)
      );
      break;
    case "stop-boring":
      if (P > 0) {
        expandCyclePoint(x, y, z);
      } else {
        writeBlock(
          gRetractModal.format(98), gCycleModal.format(86),
          getCommonCycle(x, y, z, cycle.retract, cycle.clearance),
          conditional(cycleReverse, "E2000"), feedOutput.format(F)
        );
        forceSpindleSpeed = true;
      }
      break;
    case "manual-boring":
      writeBlock(
        gRetractModal.format(98), gCycleModal.format(88),
        getCommonCycle(x, y, z, cycle.retract, cycle.clearance),
        "P" + milliFormat.format(P), // not optional
        conditional(cycleReverse, "E2000"), feedOutput.format(F)
      );
      break;
    case "boring":
      writeBlock(
        gRetractModal.format(98), gCycleModal.format(89),
        getCommonCycle(x, y, z, cycle.retract, cycle.clearance),
        "P" + milliFormat.format(P), // not optional
        conditional(cycleReverse, "E2000"), feedOutput.format(F)
      );
      break;

    case "probing-x":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9811,
        "X" + xyzFormat.format(x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-y":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9811,
        "Y" + xyzFormat.format(y + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-z":
      protectedProbeMove(cycle, x, y, Math.min(z - cycle.depth + cycle.probeClearance, cycle.retract));
      writeBlock(
        gFormat.format(65), "P" + 9811,
        "Z" + xyzFormat.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-x-wall":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "X" + xyzFormat.format(cycle.width1),
        zOutput.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(cycle.probeClearance),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-y-wall":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Y" + xyzFormat.format(cycle.width1),
        zOutput.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(cycle.probeClearance),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-x-channel":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "X" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        // not required "R" + xyzFormat.format(cycle.probeClearance),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-x-channel-with-island":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "X" + xyzFormat.format(cycle.width1),
        zOutput.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(-cycle.probeClearance),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-y-channel":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Y" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        // not required "R" + xyzFormat.format(cycle.probeClearance),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-y-channel-with-island":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Y" + xyzFormat.format(cycle.width1),
        zOutput.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(-cycle.probeClearance),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-xy-circular-boss":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9814,
        "D" + xyzFormat.format(cycle.width1),
        "Z" + xyzFormat.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(cycle.probeClearance),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-xy-circular-partial-boss":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9823,
        "A" + xyzFormat.format(cycle.partialCircleAngleA),
        "B" + xyzFormat.format(cycle.partialCircleAngleB),
        "C" + xyzFormat.format(cycle.partialCircleAngleC),
        "D" + xyzFormat.format(cycle.width1),
        "Z" + xyzFormat.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(cycle.probeClearance),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-xy-circular-hole":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9814,
        "D" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        // not required "R" + xyzFormat.format(cycle.probeClearance),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-xy-circular-partial-hole":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9823,
        "A" + xyzFormat.format(cycle.partialCircleAngleA),
        "B" + xyzFormat.format(cycle.partialCircleAngleB),
        "C" + xyzFormat.format(cycle.partialCircleAngleC),
        "D" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-xy-circular-hole-with-island":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9814,
        "Z" + xyzFormat.format(z - cycle.depth),
        "D" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(-cycle.probeClearance),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-xy-circular-partial-hole-with-island":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9823,
        "Z" + xyzFormat.format(z - cycle.depth),
        "A" + xyzFormat.format(cycle.partialCircleAngleA),
        "B" + xyzFormat.format(cycle.partialCircleAngleB),
        "C" + xyzFormat.format(cycle.partialCircleAngleC),
        "D" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(-cycle.probeClearance),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-xy-rectangular-hole":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "X" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        // not required "R" + xyzFormat.format(-cycle.probeClearance),
        getProbingArguments(cycle, true)
      );
      if (getProperty("useLiveConnection") && (typeof liveConnectionStoreResults == "function")) {
        liveConnectionStoreResults();
      }
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Y" + xyzFormat.format(cycle.width2),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        // not required "R" + xyzFormat.format(-cycle.probeClearance),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-xy-rectangular-boss":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Z" + xyzFormat.format(z - cycle.depth),
        "X" + xyzFormat.format(cycle.width1),
        "R" + xyzFormat.format(cycle.probeClearance),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, true)
      );
      if (getProperty("useLiveConnection") && (typeof liveConnectionStoreResults == "function")) {
        liveConnectionStoreResults();
      }
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Z" + xyzFormat.format(z - cycle.depth),
        "Y" + xyzFormat.format(cycle.width2),
        "R" + xyzFormat.format(cycle.probeClearance),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-xy-rectangular-hole-with-island":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Z" + xyzFormat.format(z - cycle.depth),
        "X" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(-cycle.probeClearance),
        getProbingArguments(cycle, true)
      );
      if (getProperty("useLiveConnection") && (typeof liveConnectionStoreResults == "function")) {
        liveConnectionStoreResults();
      }
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Z" + xyzFormat.format(z - cycle.depth),
        "Y" + xyzFormat.format(cycle.width2),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(-cycle.probeClearance),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-xy-inner-corner":
      var cornerX = x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2);
      var cornerY = y + approach(cycle.approach2) * (cycle.probeClearance + tool.diameter / 2);
      var cornerI = 0;
      var cornerJ = 0;
      if (cycle.probeSpacing !== undefined) {
        cornerI = cycle.probeSpacing;
        cornerJ = cycle.probeSpacing;
      }
      if ((cornerI != 0) && (cornerJ != 0)) {
        if (currentSection.strategy == "probe") {
          setProbeAngleMethod();
          probeVariables.compensationXY = "X[#185] Y[#186]";
        }
      }
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9815, xOutput.format(cornerX), yOutput.format(cornerY),
        conditional(cornerI != 0, "I" + xyzFormat.format(cornerI)),
        conditional(cornerJ != 0, "J" + xyzFormat.format(cornerJ)),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-xy-outer-corner":
      var cornerX = x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2);
      var cornerY = y + approach(cycle.approach2) * (cycle.probeClearance + tool.diameter / 2);
      var cornerI = 0;
      var cornerJ = 0;
      if (cycle.probeSpacing !== undefined) {
        cornerI = cycle.probeSpacing;
        cornerJ = cycle.probeSpacing;
      }
      if ((cornerI != 0) && (cornerJ != 0)) {
        if (currentSection.strategy == "probe") {
          setProbeAngleMethod();
          probeVariables.compensationXY = "X[#185] Y[#186]";
        }
      }
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9816, xOutput.format(cornerX), yOutput.format(cornerY),
        conditional(cornerI != 0, "I" + xyzFormat.format(cornerI)),
        conditional(cornerJ != 0, "J" + xyzFormat.format(cornerJ)),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-x-plane-angle":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9843,
        "X" + xyzFormat.format(x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
        "D" + xyzFormat.format(cycle.probeSpacing),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "A" + xyzFormat.format(cycle.nominalAngle != undefined ? cycle.nominalAngle : 90),
        getProbingArguments(cycle, false)
      );
      if (currentSection.strategy == "probe") {
        setProbeAngleMethod();
        probeVariables.compensationXY = "X" + xyzFormat.format(0) + " Y" + xyzFormat.format(0);
      }
      break;
    case "probing-y-plane-angle":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9843,
        "Y" + xyzFormat.format(y + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
        "D" + xyzFormat.format(cycle.probeSpacing),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "A" + xyzFormat.format(cycle.nominalAngle != undefined ? cycle.nominalAngle : 0),
        getProbingArguments(cycle, false)
      );
      if (currentSection.strategy == "probe") {
        setProbeAngleMethod();
        probeVariables.compensationXY = "X" + xyzFormat.format(0) + " Y" + xyzFormat.format(0);
      }
      break;
    case "probing-xy-pcd-hole":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9819,
        "A" + xyzFormat.format(cycle.pcdStartingAngle),
        "B" + xyzFormat.format(cycle.numberOfSubfeatures),
        "C" + xyzFormat.format(cycle.widthPCD),
        "D" + xyzFormat.format(cycle.widthFeature),
        "K" + xyzFormat.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, false)
      );
      if (cycle.updateToolWear) {
        error(localize("Action -Update Tool Wear- is not supported with this cycle"));
        return;
      }
      break;
    case "probing-xy-pcd-boss":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9819,
        "A" + xyzFormat.format(cycle.pcdStartingAngle),
        "B" + xyzFormat.format(cycle.numberOfSubfeatures),
        "C" + xyzFormat.format(cycle.widthPCD),
        "D" + xyzFormat.format(cycle.widthFeature),
        "Z" + xyzFormat.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(cycle.probeClearance),
        getProbingArguments(cycle, false)
      );
      if (cycle.updateToolWear) {
        error(localize("Action -Update Tool Wear- is not supported with this cycle"));
        return;
      }
      break;
    default:
      expandCyclePoint(x, y, z);
    }

    // place cycle operation in subprogram
    if (cycleSubprogramIsActive) {
      if (forceCycle || cycleExpanded || isProbeOperation()) {
        cycleSubprogramIsActive = false;
      } else {
        // call subprogram
        writeBlock(mFormat.format(97), "P" + nFormat.format(currentSubprogram));
        subprogramStart(new Vector(x, y, z), new Vector(0, 0, 0), false);
      }
    }
    if (incrementalMode) { // set current position to clearance height
      setCyclePosition(cycle.clearance);
    }

  // 2nd through nth cycle point
  } else {
    if (cycleExpanded) {
      expandCyclePoint(x, y, z);
    } else {
      if (isPolarModeActive()) {
        var polarPosition = getPolarPosition(x, y, z);
        writeBlock(xOutput.format(polarPosition.first.x), yOutput.format(polarPosition.first.y), zOutput.format(polarPosition.first.z),
          aOutput.format(polarPosition.second.x), bOutput.format(polarPosition.second.y), cOutput.format(polarPosition.second.z));
        return;
      }
      var _x;
      var _y;
      var _z;
      if (!xyzFormat.areDifferent(x, xOutput.getCurrent()) &&
          !xyzFormat.areDifferent(y, yOutput.getCurrent()) &&
          !xyzFormat.areDifferent(z, zOutput.getCurrent())) {
        switch (gPlaneModal.getCurrent()) {
        case 17: // XY
          xOutput.reset(); // at least one axis is required
          break;
        case 18: // ZX
          zOutput.reset(); // at least one axis is required
          break;
        case 19: // YZ
          yOutput.reset(); // at least one axis is required
          break;
        }
      }
      if (incrementalMode) { // set current position to retract height
        setCyclePosition(cycle.retract);
      }
      writeBlock(xOutput.format(x), yOutput.format(y), zOutput.format(z));
      if (incrementalMode) { // set current position to clearance height
        setCyclePosition(cycle.clearance);
      }
    }
  }
}

function getProbingArguments(cycle, updateWCS) {
  var outputWCSCode = updateWCS && currentSection.strategy == "probe";
  if (outputWCSCode) {
    validate(
      probeOutputWorkOffset > 0 && (probeOutputWorkOffset > 6 ? probeOutputWorkOffset - 6 : probeOutputWorkOffset) <= 99,
      "Work offset is out of range."
    );
    var nextWorkOffset = hasNextSection() ? getNextSection().workOffset == 0 ? 1 : getNextSection().workOffset : -1;
    if (probeOutputWorkOffset == nextWorkOffset) {
      currentWorkOffset = undefined;
    }
  }
  return [
    (cycle.angleAskewAction == "stop-message" ? "B" + xyzFormat.format(cycle.toleranceAngle ? cycle.toleranceAngle : 0) : undefined),
    ((cycle.updateToolWear && cycle.toolWearErrorCorrection < 100) ? "F" + xyzFormat.format(cycle.toolWearErrorCorrection ? cycle.toolWearErrorCorrection / 100 : 100) : undefined),
    (cycle.wrongSizeAction == "stop-message" ? "H" + xyzFormat.format(cycle.toleranceSize ? cycle.toleranceSize : 0) : undefined),
    (cycle.outOfPositionAction == "stop-message" ? "M" + xyzFormat.format(cycle.tolerancePosition ? cycle.tolerancePosition : 0) : undefined),
    ((cycle.updateToolWear && cycleType == "probing-z") ? "T" + xyzFormat.format(cycle.toolLengthOffset) : undefined),
    ((cycle.updateToolWear && cycleType !== "probing-z") ? "T" + xyzFormat.format(cycle.toolDiameterOffset) : undefined),
    (cycle.updateToolWear ? "V" + xyzFormat.format(cycle.toolWearUpdateThreshold ? cycle.toolWearUpdateThreshold : 0) : undefined),
    (cycle.printResults ? "W" + xyzFormat.format(1 + cycle.incrementComponent) : undefined), // 1 for advance feature, 2 for reset feature count and advance component number. first reported result in a program should use W2.
    conditional(outputWCSCode, (probeOutputWorkOffset > 6 ? probeExtWCSFormat.format((probeOutputWorkOffset - 6)) : probeWCSFormat.format(probeOutputWorkOffset)))
  ];
}

function onCycleEnd() {
  if (isProbeOperation()) {
    zOutput.reset();
    gMotionModal.reset();
    writeBlock(gFormat.format(65), "P" + 9810, zOutput.format(cycle.retract)); // protected retract move
  } else {
    if (cycleSubprogramIsActive) {
      subprogramEnd();
      cycleSubprogramIsActive = false;
    }
    if (!cycleExpanded) {
      writeBlock(gCycleModal.format(80), conditional(getProperty("useG95forTapping"), gFeedModeModal.format(94)));
      gMotionModal.reset();
    }
  }
  if (getProperty("useLiveConnection") && isProbeOperation() && typeof liveConnectionWriteData == "function") {
    liveConnectionWriteData("macroEnd");
  }
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
    if (!getProperty("useG0") && (((x ? 1 : 0) + (y ? 1 : 0) + (z ? 1 : 0)) > 1)) {
      // axes are not synchronized
      writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), x, y, z, getFeed(highFeedrate));
    } else {
      writeBlock(gMotionModal.format(0), x, y, z);
      forceFeed();
    }
  }
}

function onLinear(_x, _y, _z, feed) {
  if (pendingRadiusCompensation >= 0) {
    // ensure that we end at desired position when compensation is turned off
    xOutput.reset();
    yOutput.reset();
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var f = getFeed(feed);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      pendingRadiusCompensation = -1;
      var d = tool.diameterOffset;
      if ((d > 200 && d < 1000) || d > 9999) {
        warning(localize("Diameter offset out of range."));
      }
      writeBlock(gPlaneModal.format(17), gFeedModeModal.format(94));
      switch (radiusCompensation) {
      case RADIUS_COMPENSATION_LEFT:
        dOutput.reset();
        writeBlock(gMotionModal.format(1), gFormat.format(41), x, y, z, dOutput.format(d), f);
        break;
      case RADIUS_COMPENSATION_RIGHT:
        dOutput.reset();
        writeBlock(gMotionModal.format(1), gFormat.format(42), x, y, z, dOutput.format(d), f);
        break;
      default:
        writeBlock(gMotionModal.format(1), gFormat.format(40), x, y, z, f);
      }
    } else {
      writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), x, y, z, f);
    }
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      forceFeed(); // force feed on next line
    } else {
      writeBlock(gMotionModal.format(1), f);
    }
  }
}

var forceG0 = false;
function onRapid5D(_x, _y, _z, _a, _b, _c) {
  if (!currentSection.isOptimizedForMachine()) {
    error(localize("This post configuration has not been customized for 5-axis simultaneous toolpath."));
    return;
  }
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation mode cannot be changed at rapid traversal."));
    return;
  }

  var num =
    (xyzFormat.areDifferent(_x, xOutput.getCurrent()) ? 1 : 0) +
    (xyzFormat.areDifferent(_y, yOutput.getCurrent()) ? 1 : 0) +
    (xyzFormat.areDifferent(_z, zOutput.getCurrent()) ? 1 : 0) +
    ((aOutput.isEnabled() && abcFormat.areDifferent(_a, aOutput.getCurrent())) ? 1 : 0) +
    ((bOutput.isEnabled() && abcFormat.areDifferent(_b, bOutput.getCurrent())) ? 1 : 0) +
    ((cOutput.isEnabled() && abcFormat.areDifferent(_c, cOutput.getCurrent())) ? 1 : 0);
  /*
  if (!getProperty("useG0") && !forceG0 && (operationSupportsTCP || (num > 1))) {
    invokeOnLinear5D(_x, _y, _z, _a, _b, _c, highFeedrate); // onLinear5D handles inverse time feedrates
    forceG0 = false;
    return;
  }
  */
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = aOutput.format(_a);
  var b = bOutput.format(_b);
  var c = cOutput.format(_c);

  if (x || y || z || a || b || c) {
    if (!getProperty("useG0") && (operationSupportsTCP || (num > 1))) {
      // axes are not synchronized
      writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), x, y, z, a, b, c, getFeed(highFeedrate));
    } else {
      writeBlock(gMotionModal.format(0), x, y, z, a, b, c);
      forceFeed();
    }
  }
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed, feedMode) {
  if (!currentSection.isOptimizedForMachine()) {
    error(localize("This post configuration has not been customized for 5-axis simultaneous toolpath."));
    return;
  }
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for 5-axis move."));
    return;
  }

  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = aOutput.format(_a);
  var b = bOutput.format(_b);
  var c = cOutput.format(_c);

  if (feedMode == FEED_INVERSE_TIME) {
    forceFeed();
  }
  var f = feedMode == FEED_INVERSE_TIME ? inverseTimeOutput.format(feed) : getFeed(feed);
  var fMode = (feedMode == FEED_INVERSE_TIME) ? 93 : 94;

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

function moveToSafeRetractPosition(isRetracted) {
  var _skipBlock = skipBlock;
  if (!isRetracted) {
    writeRetract(Z);
  }
  if (getProperty("forceHomeOnIndexing")) {
    skipBlock = _skipBlock;
    writeRetract(X, Y);
  }
}

// Start of onRewindMachine logic
/** Allow user to override the onRewind logic. */
function onRewindMachineEntry(_a, _b, _c) {
  return false;
}

/** Retract to safe position before indexing rotaries. */
function onMoveToSafeRetractPosition() {
  // cancel TCP so that tool doesn't follow rotaries
  if (currentSection.isMultiAxis() && operationSupportsTCP) {
    disableLengthCompensation(false, "TCPC OFF");
  }
  moveToSafeRetractPosition(false);
}

/** Rotate axes to new position above reentry position */
function onRotateAxes(_x, _y, _z, _a, _b, _c) {
  // position rotary axes
  xOutput.disable();
  yOutput.disable();
  zOutput.disable();
  forceG0 = true;
  unwindABC(new Vector(_a, _b, _c), false);
  invokeOnRapid5D(_x, _y, _z, _a, _b, _c);
  setCurrentABC(new Vector(_a, _b, _c));
  xOutput.enable();
  yOutput.enable();
  zOutput.enable();
}

/** Return from safe position after indexing rotaries. */
function onReturnFromSafeRetractPosition(_x, _y, _z) {
  // reinstate TCP
  if (operationSupportsTCP) {
    if (useDwoForPositioning) {
      prepositionDWO(new Vector(_x, _y, _z), getCurrentDirection(), false);
    } else {
      writeBlock(gMotionModal.format(0), gFormat.format(234), hFormat.format(tool.lengthOffset), formatComment("TCPC ON"));
      forceFeed();
      lengthCompensationActive = true;
    }
  } else {
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
}
// End of onRewindMachine logic

// Start of polar interpolation
var usePolarMode = false; // controlled by manual NC operation, enables polar interpolation for a single operation
var polarDirection = new Vector(1, 0, 0); // vector to maintain tool at while in polar interpolation
function setPolarMode(section, mode) {
  if (!mode) { // turn off polar mode if required
    if (isPolarModeActive()) {
      currentMachineABC = getCurrentDirection();
      deactivatePolarMode();
      setPolarFeedMode(false);
      usePolarMode = false;
    }
    return;
  }

  var direction = polarDirection;

  // determine the rotary axis to use for polar interpolation
  var axis = undefined;
  if (machineConfiguration.getAxisV().isEnabled()) {
    if (Vector.dot(machineConfiguration.getAxisV().getAxis(), section.workPlane.getForward()) != 0) {
      axis = machineConfiguration.getAxisV();
    }
  }
  if (axis == undefined && machineConfiguration.getAxisU().isEnabled()) {
    if (Vector.dot(machineConfiguration.getAxisU().getAxis(), section.workPlane.getForward()) != 0) {
      axis = machineConfiguration.getAxisU();
    }
  }
  if (axis == undefined) {
    error(localize("Polar interpolation requires an active rotary axis be defined in direction of workplane normal."));
  }

  // calculate directional vector from initial position
  if (direction == undefined) {
    error(localize("Polar interpolation initiated without a directional vector."));
    return;
  } else if (direction.isZero()) {
    var initialPosition = getFramePosition(section.getInitialPosition());
    direction = Vector.diff(initialPosition, axis.getOffset()).getNormalized();
  }

  // put vector in plane of rotary axis
  var temp = Vector.cross(direction, axis.getAxis()).getNormalized();
  direction = Vector.cross(axis.getAxis(), temp).getNormalized();

  // activate polar interpolation
  setPolarFeedMode(true); // enable multi-axis feeds for polar mode
  activatePolarMode(tolerance / 2, 0, direction);
  var polarPosition = getPolarPosition(section.getInitialPosition().x, section.getInitialPosition().y, section.getInitialPosition().z);
  setCurrentPositionAndDirection(polarPosition);
  forceWorkPlane();
}

function setPolarFeedMode(mode) {
  if (machineConfiguration.isMultiAxisConfiguration()) {
    machineConfiguration.setMultiAxisFeedrate(
      !mode ? multiAxisFeedrate.mode : getProperty("useDPMFeeds") ? FEED_DPM : FEED_INVERSE_TIME,
      multiAxisFeedrate.maximum,
      !mode ? multiAxisFeedrate.type : getProperty("useDPMFeeds") ? DPM_COMBINATION : INVERSE_MINUTES,
      multiAxisFeedrate.tolerance,
      multiAxisFeedrate.bpwRatio
    );
    if (!receivedMachineConfiguration) {
      setMachineConfiguration(machineConfiguration);
    }
  }
}
// End of polar interpolation

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  if (isSpiral()) {
    var startRadius = getCircularStartRadius();
    var endRadius = getCircularRadius();
    var dr = Math.abs(endRadius - startRadius);
    if (dr > maximumCircularRadiiDifference) { // maximum limit
      linearize(tolerance); // or alternatively use other G-codes for spiral motion
      return;
    }
  }

  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for a circular move."));
    return;
  }

  var start = getCurrentPosition();

  if (isFullCircle()) {
    if (getProperty("useRadius") || isHelical()) { // radius mode does not support full arcs
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed));
      break;
    case PLANE_ZX:
      writeBlock(gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    case PLANE_YZ:
      writeBlock(gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else if (!getProperty("useRadius")) {
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed));
      break;
    case PLANE_ZX:
      writeBlock(gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    case PLANE_YZ:
      writeBlock(gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else { // use radius mode
    var r = getCircularRadius();
    if (toDeg(getCircularSweep()) > (180 + 1e-9)) {
      r = -r; // allow up to <360 deg arcs
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    case PLANE_ZX:
      writeBlock(gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    case PLANE_YZ:
      writeBlock(gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  }
}

var currentCoolantMode = COOLANT_OFF;
var coolantOff = undefined;
var isOptionalCoolant = false;

function setCoolant(coolant) {
  var coolantCodes = getCoolantCodes(coolant);
  forceSingleLine = false;
  if ((coolantCodes != undefined) && (coolant == COOLANT_FLOOD)) {
    if (coolantPressure != "") {
      forceSingleLine = true;
      coolantCodes.push(coolantPressure);
    }
  }
  if (Array.isArray(coolantCodes)) {
    if (singleLineCoolant || forceSingleLine) {
      skipBlock = isOptionalCoolant;
      writeBlock(coolantCodes.join(getWordSeparator()));
    } else {
      for (var c in coolantCodes) {
        skipBlock = isOptionalCoolant;
        writeBlock(coolantCodes[c]);
      }
    }
    return undefined;
  }
  return coolantCodes;
}

var isSpecialCoolantActive = false;

function getCoolantCodes(coolant) {
  isOptionalCoolant = false;
  var multipleCoolantBlocks = new Array(); // create a formatted array to be passed into the outputted line
  if (!coolants) {
    error(localize("Coolants have not been defined."));
  }
  if (tool.type == TOOL_PROBE) { // avoid coolant output for probing
    coolant = COOLANT_OFF;
  }
  if (coolant == currentCoolantMode) {
    if (operationNeedsSafeStart && coolant != COOLANT_OFF && !isSpecialCoolantActive) {
      isOptionalCoolant = true;
    } else if (!forceCoolant || coolant == COOLANT_OFF) {
      return undefined; // coolant is already active
    }
  }
  if ((coolant != COOLANT_OFF) && (currentCoolantMode != COOLANT_OFF) && (coolantOff != undefined) && !isOptionalCoolant && !forceCoolant) {
    if (Array.isArray(coolantOff)) {
      for (var i in coolantOff) {
        multipleCoolantBlocks.push(coolantOff[i]);
      }
    } else {
      multipleCoolantBlocks.push(coolantOff);
    }
  }
  forceCoolant = false;

  if (isSpecialCoolantActive) {
    forceSpindleSpeed = true;
  }
  var m;
  var coolantCodes = {};
  for (var c in coolants) { // find required coolant codes into the coolants array
    if (coolants[c].id == coolant) {
      isSpecialCoolantActive = (coolants[c].id == COOLANT_THROUGH_TOOL) || (coolants[c].id == COOLANT_FLOOD_THROUGH_TOOL) || (coolants[c].id == COOLANT_AIR_THROUGH_TOOL);
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
  COMMAND_END                     : 2,
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
  case COMMAND_COOLANT_ON:
    setCoolant(COOLANT_FLOOD);
    return;
  case COMMAND_COOLANT_OFF:
    setCoolant(COOLANT_OFF);
    return;
  case COMMAND_START_SPINDLE:
    onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
    return;
  case COMMAND_LOCK_MULTI_AXIS:
    if (machineConfiguration.isMultiAxisConfiguration() && (machineConfiguration.getNumberOfAxes() >= 4)) {
      var _skipBlock = skipBlock;
      writeBlock(mClampModal.format(10)); // lock 4th-axis motion
      if (machineConfiguration.getNumberOfAxes() == 5) {
        skipBlock = _skipBlock;
        writeBlock(mClampModal.format(12)); // lock 5th-axis motion
      }
    }
    return;
  case COMMAND_UNLOCK_MULTI_AXIS:
    var outputClampCodes = getProperty("useClampCodes") || currentSection.isMultiAxis() || isPolarModeActive();
    if (outputClampCodes && machineConfiguration.isMultiAxisConfiguration() && (machineConfiguration.getNumberOfAxes() >= 4)) {
      var _skipBlock = skipBlock;
      writeBlock(mClampModal.format(11)); // unlock 4th-axis motion
      if (machineConfiguration.getNumberOfAxes() == 5) {
        skipBlock = _skipBlock;
        writeBlock(mClampModal.format(13)); // unlock 5th-axis motion
      }
    }
    return;
  case COMMAND_BREAK_CONTROL:
    if (!toolChecked) { // avoid duplicate COMMAND_BREAK_CONTROL
      prepareForToolCheck();
      writeBlock(
        gFormat.format(65),
        "P" + 9853,
        "T" + toolFormat.format(tool.number),
        "B" + xyzFormat.format(0),
        "H" + xyzFormat.format(getProperty("toolBreakageTolerance"))
      );
      if (getProperty("toolArmDrive")) {
        writeBlock(mProbeArmModal.format(105), formatComment("Retract tool setting probe arm"));
      }
      toolChecked = true;
      lengthCompensationActive = false; // macro 9853 cancels tool length compensation
    }
    return;
  case COMMAND_TOOL_MEASURE:
    measureTool = true;
    return;
  case COMMAND_START_CHIP_TRANSPORT:
    writeBlock(mFormat.format(31));
    return;
  case COMMAND_STOP_CHIP_TRANSPORT:
    writeBlock(mFormat.format(33));
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

var toolChecked = false; // specifies that the tool has been checked with the probe

function onSectionEnd() {
  if (isInspectionOperation() && !isLastSection()) {
    writeBlock(gFormat.format(103), "P0", formatComment("LOOKAHEAD ON"));
  }
  if (!isLastSection() && (getNextSection().getTool().coolant != tool.coolant)) {
    setCoolant(COOLANT_OFF);
  }
  if ((((getCurrentSectionId() + 1) >= getNumberOfSections()) ||
      (tool.number != getNextSection().getTool().number)) &&
      tool.breakControl) {
    onCommand(COMMAND_BREAK_CONTROL);
  } else {
    toolChecked = false;
  }

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

  if (currentSection.isMultiAxis() || isPolarModeActive()) {
    writeBlock(gFeedModeModal.format(94)); // inverse time feed off
    if (currentSection.isOptimizedForMachine()) {
      // the code below gets the machine angles from previous operation.  closestABC must also be set to true
      currentMachineABC = currentSection.getFinalToolAxisABC();
    }
    if (operationSupportsTCP) {
      disableLengthCompensation(false, "TCPC OFF");
    }
  }

  if (isProbeOperation()) {
    writeBlock(gFormat.format(65), "P" + 9833); // spin the probe off
    if (probeVariables.probeAngleMethod != "G68") {
      setProbeAngle(); // output probe angle rotations if required
    }
  }

  if (getProperty("useLiveConnection") && (typeof liveConnectionWriteData == "function")) {
    if (isInspectionOperation()) {
      liveConnectionWriteData("inspectSurfaceAlarm");
    }
    liveConnectionWriteData("toolpathEnd");
  }

  // reset for next section
  operationNeedsSafeStart = false;
  coolantPressure = getProperty("coolantPressure");
  cycleReverse = false;

  setPolarMode(currentSection, false);
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
  if ((retractAxes[0] || retractAxes[1]) && !retracted && !skipBlock) { // retract Z first before moving to X/Y home
    error(localize("Retracting in X/Y is not possible without being retracted in Z."));
    return;
  }
  // special conditions
  if (retractAxes[0] || retractAxes[1]) {
    method = "G53";
  }
  cancelG68Rotation(); // G68 has to be canceled for retracts

  // define home positions
  var _xHome;
  var _yHome;
  var _zHome;
  if (method == "G28") {
    _xHome = toPreciseUnit(0, MM);
    _yHome = toPreciseUnit(0, MM);
    _zHome = toPreciseUnit(0, MM);
  } else {
    if (homePositionCenter &&
      hasParameter("part-upper-x") && hasParameter("part-lower-x")) {
      _xHome = (getParameter("part-upper-x") + getParameter("part-lower-x")) / 2;
    } else {
      _xHome = machineConfiguration.hasHomePositionX() ? machineConfiguration.getHomePositionX() : toPreciseUnit(0, MM);
    }
    _yHome = machineConfiguration.hasHomePositionY() ? machineConfiguration.getHomePositionY() : toPreciseUnit(0, MM);
    _zHome = machineConfiguration.getRetractPlane() != 0 ? machineConfiguration.getRetractPlane() : toPreciseUnit(0, MM);
  }
  for (var i = 0; i < arguments.length; ++i) {
    switch (arguments[i]) {
    case X:
      // special conditions
      if (homePositionCenter) { // output X in standard block by itself if centering
        writeBlock(gMotionModal.format(0), "X" + xyzFormat.format(_xHome));
        xOutput.reset();
        break;
      }
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
      retracted = !skipBlock;
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
      writeBlock(gAbsIncModal.format(90), gFormat.format(53), gMotionModal.format(0), words);
      break;
    default:
      error(localize("Unsupported safe position method."));
      return;
    }
  }
}

var isDPRNTopen = false;
function inspectionCreateResultsFileHeader() {
  if (getProperty("useLiveConnection") && controlType != "NGC") {
    return; // do not DPRNT if Live connection is active on a classic control
  }
  if (isDPRNTopen) {
    if (!getProperty("singleResultsFile")) {
      writeln("DPRNT[END]");
      writeBlock("PCLOS");
      isDPRNTopen = false;
    }
  }

  if (isProbeOperation() && !printProbeResults()) {
    return; // if print results is not desired by probe/probeWCS
  }

  if (!isDPRNTopen) {
    writeBlock("PCLOS");
    writeBlock("POPEN");
    // check for existence of none alphanumeric characters but not spaces
    var resFile;
    if (getProperty("singleResultsFile")) {
      resFile = getParameter("job-description") + "-RESULTS";
    } else {
      resFile = getParameter("operation-comment") + "-RESULTS";
    }
    resFile = resFile.replace(/:/g, "-");
    resFile = resFile.replace(/[^a-zA-Z0-9 -]/g, "");
    resFile = resFile.replace(/\s/g, "-");
    writeln("DPRNT[START]");
    writeln("DPRNT[RESULTSFILE*" + resFile + "]");
    if (hasGlobalParameter("document-id")) {
      writeln("DPRNT[DOCUMENTID*" + getGlobalParameter("document-id") + "]");
    }
    if (hasGlobalParameter("model-version")) {
      writeln("DPRNT[MODELVERSION*" + getGlobalParameter("model-version") + "]");
    }
  }
  if (isProbeOperation() && printProbeResults()) {
    isDPRNTopen = true;
  }
}

function getPointNumber() {
  if (typeof inspectionWriteVariables == "function") {
    return (inspectionVariables.pointNumber);
  } else {
    return ("#172[60]");
  }
}

function inspectionWriteCADTransform() {
  if (getProperty("useLiveConnection") && controlType != "NGC") {
    return; // do not DPRNT if Live connection is active on a classic control
  }
  var cadOrigin = currentSection.getModelOrigin();
  var cadWorkPlane = currentSection.getModelPlane().getTransposed();
  var cadEuler = cadWorkPlane.getEuler2(EULER_XYZ_S);
  writeln(
    "DPRNT[G331" +
    "*N" + getPointNumber() +
    "*A" + abcFormat.format(cadEuler.x) +
    "*B" + abcFormat.format(cadEuler.y) +
    "*C" + abcFormat.format(cadEuler.z) +
    "*X" + xyzFormat.format(-cadOrigin.x) +
    "*Y" + xyzFormat.format(-cadOrigin.y) +
    "*Z" + xyzFormat.format(-cadOrigin.z) +
    "]"
  );
}

function inspectionWriteWorkplaneTransform() {
  var orientation = (machineConfiguration.isMultiAxisConfiguration() && currentMachineABC != undefined) ? machineConfiguration.getOrientation(currentMachineABC) : currentSection.workPlane;
  var abc = orientation.getEuler2(EULER_XYZ_S);
  if ((getProperty("useLiveConnection"))) {
    liveConnectorInterface("WORKPLANE");
    writeBlock(inspectionVariables.liveConnectionWPA + " = " + abcFormat.format(abc.x));
    writeBlock(inspectionVariables.liveConnectionWPB + " = " + abcFormat.format(abc.y));
    writeBlock(inspectionVariables.liveConnectionWPC + " = " + abcFormat.format(abc.z));
    writeBlock("IF [" + inspectionVariables.workplaneStartAddress, "EQ -1] THEN",
      inspectionVariables.workplaneStartAddress, "=", currentSection.getParameter("autodeskcam:operation-id")
    );
  }
  if (getProperty("useLiveConnection") && controlType != "NGC") {
    return; // do not DPRNT if Live connection is active on a classic control
  }
  writeln("DPRNT[G330" +
    "*N" + getPointNumber() +
    "*A" + abcFormat.format(abc.x) +
    "*B" + abcFormat.format(abc.y) +
    "*C" + abcFormat.format(abc.z) +
    "*X0*Y0*Z0*I0*R0]"
  );
}

function writeProbingToolpathInformation(cycleDepth) {
  if (getProperty("useLiveConnection") && controlType != "NGC") {
    return; // do not DPRNT if Live connection is active on a classic control
  }
  writeln("DPRNT[TOOLPATHID*" + getParameter("autodeskcam:operation-id") + "]");
  if (isInspectionOperation()) {
    writeln("DPRNT[TOOLPATH*" + getParameter("operation-comment") + "]");
  } else {
    writeln("DPRNT[CYCLEDEPTH*" + xyzFormat.format(cycleDepth) + "]");
  }
}

function onClose() {
  if (!(getProperty("useLiveConnection") && controlType != "NGC")) {
    if (isDPRNTopen) {
      writeln("DPRNT[END]");
      writeBlock("PCLOS");
      isDPRNTopen = false;
    }
  }
  if (!getProperty("useLiveConnection") && typeof inspectionProcessSectionEnd == "function") {
    inspectionProcessSectionEnd();
  }

  cancelG68Rotation();
  writeln("");

  optionalSection = false;
  if (getProperty("useSSV")) {
    writeBlock(ssvModal.format(139));
  }
  onCommand(COMMAND_STOP_SPINDLE);
  onCommand(COMMAND_COOLANT_OFF);

  // retract
  writeRetract(Z);
  if (!getProperty("homePositionCenter") || currentMachineABC.length != 0) {
    writeRetract(X, Y);
  }

  if (activeG254) {
    writeBlock(gFormat.format(255)); // cancel DWO
    activeG254 = false;
  }
  // Unwind Rotary table at end
  if (machineConfiguration.isMultiAxisConfiguration()) {
    unwindABC(new Vector(0, 0, 0), true); // force unwind at the end of the program
    positionABC(new Vector(0, 0, 0), true);
  }
  if (getProperty("homePositionCenter")) {
    homePositionCenter = getProperty("homePositionCenter");
    if (getProperty("safePositionMethod") == "clearanceHeight") {
      retracted = true;
      setProperty("safePositionMethod", "G53");
      writeRetract(X);
    } else {
      writeRetract(X, Y);
    }
  }

  if (getProperty("useLiveConnection")) {
    writeComment("Live Connection Footer"); // Live connection write footer
    writeBlock(inspectionVariables.liveConnectionStatus, "= 2"); // If using live connection set results active to a 2 to signify program end
  }

  onImpliedCommand(COMMAND_END);
  onImpliedCommand(COMMAND_STOP_SPINDLE);

  if (getProperty("useM130PartImages") || getProperty("useM130ToolImages")) {
    writeBlock(mFormat.format(131));
  }
  writeBlock(mFormat.format(30)); // stop program, spindle stop, coolant off
  if (subprograms.length > 0) {
    writeln("");
    write(subprograms);
  }
  writeln("");
  writeln("%");
}

/*
keywords += (keywords ? " MODEL_IMAGE" : "MODEL_IMAGE");

function onTerminate() {
  var outputPath = getOutputPath();
  var programFilename = FileSystem.getFilename(outputPath);
  var programSize = FileSystem.getFileSize(outputPath);
  var postPath = findFile("setup-sheet-excel-2007.cps");
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
  a += " --noeditor --log temp.log \"" + postPath + "\" \"" + intermediatePath + "\" \"" + FileSystem.replaceExtension(outputPath, "xlsx") + "\"";
  execute(getPostProcessorPath(), a, false, "");
  executeNoWait("excel", "\"" + FileSystem.replaceExtension(outputPath, "xlsx") + "\"", false, "");
}
*/

function setProperty(property, value) {
  properties[property].current = value;
}
// <<<<< INCLUDED FROM ../../../haas next generation.cps

capabilities |= CAPABILITY_INSPECTION;
description = "HAAS - Next Generation Control Inspect Surface";
longDescription = "Generic post modified by Conturo Prototyping for the HAAS NGC with inspect surface & live connection capabilities.";

var controlType = "NGC"; // Specifies the control model "NGC" or "Classic"
// >>>>> INCLUDED FROM ../common/haas base inspection.cps
properties.toolOffsetType = {
  title      : "Tool offset type",
  description: "Select the which offsets are available on the tool offset page.",
  group      : "probing",
  type       : "enum",
  values     : [
    {id:"geomWear", title:"Geometry & Wear"},
    {id:"geomOnly", title:"Geometry only"}
  ],
  value: "geomWear",
  scope: "post"
};
properties.commissioningMode = {
  title      : "Inspection Commissioning Mode",
  description: "Enables commissioning mode where M0 and messages are output at key points in the program.",
  group      : "probing",
  type       : "boolean",
  value      : true,
  scope      : "post"
};
properties.probeOnCommand = {
  title      : "Probe On Command",
  description: "The command used to turn the probe on, this can be a M code or sub program call.",
  group      : "probing",
  type       : "string",
  value      : "G65 P9832",
  scope      : "post"
};
properties.probeOffCommand = {
  title      : "Probe Off Command",
  description: "The command used to turn the probe off, this can be a M code or sub program call.",
  group      : "probing",
  type       : "string",
  value      : "G65 P9833",
  scope      : "post"
};
properties.probeResultsBuffer = {
  title      : "Measurement results store start",
  description: "Specify the starting value of macro # variables where measurement results are stored.",
  group      : "probing",
  type       : "integer",
  value      : (controlType == "NGC" ? 10100 : 150),
  scope      : "post"
};
properties.probeCalibratedRadius = {
  title      : "Calibrated Radius",
  description: "Macro Variable used for storing probe calibrated radi.",
  group      : "probing",
  type       : "integer",
  value      : (controlType == "NGC" ? 10556 : 556),
  scope      : "post"
};
properties.probeEccentricityX = {
  title      : "Eccentricity X",
  description: "Macro Variable used for storing the X eccentricity.",
  group      : "probing",
  type       : "integer",
  value      : (controlType == "NGC" ? 10558 : 558),
  scope      : "post"
};
properties.probeEccentricityY = {
  title      : "Eccentricity Y",
  description: "Macro Variable used for storing the Y eccentricity.",
  group      : "probing",
  type       : "integer",
  value      : (controlType == "NGC" ? 10559 : 559),
  scope      : "post"
};
properties.probeCalibrationMethod = {
  title      : "Probe calibration Method",
  description: "Select the probe calibration method.",
  group      : "probing",
  type       : "enum",
  values     : [
    {id:"Renishaw", title:"Renishaw"},
    {id:"Autodesk", title:"Autodesk"},
    {id:"Other", title:"Other"}
  ],
  value: "Renishaw",
  scope: "post"
};
properties.useLiveConnection = {
  title      : "Live device connection",
  description: "Creates a live connection between the controller and Fusion 360, used for live importing of measurement results and toolpath tracking",
  group      : "probing",
  type       : "boolean",
  value      : false,
  scope      : "post"
};
properties.probeNumberofPoints = {
  title      : "Measurement number of points to store",
  description: "This is the maximum number of measurement results that can be stored in the buffer.",
  group      : "probing",
  type       : "integer",
  value      : 4,
  scope      : "post"
};
properties.controlConnectorVersion = {
  title      : "Results connector version",
  description: "Interface version for direct connection to read inspection results.",
  group      : "probing",
  type       : "integer",
  value      : 1,
  scope      : "post"
};

var ijkFormat = createFormat({decimals:5, forceDecimal:true});
// inspection variables
var inspectionVariables = {
  localVariablePrefix            : "#",
  probeRadius                    : 0,
  systemVariableMeasuredX        : 5061,
  systemVariableMeasuredY        : 5062,
  systemVariableMeasuredZ        : 5063,
  pointNumber                    : 1,
  probeResultsBufferFull         : false,
  probeResultsBufferIndex        : 1,
  hasInspectionSections          : false,
  inspectionSectionCount         : 0,
  systemVariableOffsetLengthTable: 2000,
  systemVariableOffsetWearTable  : 2200,
  workpieceOffset                : "",
  systemVariablePreviousX        : 5001,
  systemVariablePreviousY        : 5002,
  systemVariablePreviousZ        : 5003,
  systemVariableMachineCoordX    : 5021,
  systemVariableMachineCoordY    : 5022,
  systemVariableMachineCoordZ    : 5023,
  systemVariableWCSOffset        : 5200,
  systemVariableWCSOffsetExt     : 14000,
};

var macroFormat = createFormat({prefix:inspectionVariables.localVariablePrefix, decimals:0});
var LINEAR_MOVE = 1;
var SAFE_MOVE = 2;
var SAFE_MOVE_DWO = 3;
var MEASURE_MOVE = 4;
var ALARM_IF_DEFLECTED = "M78";
var ALARM_IF_NOT_DEFLECTED = "M79";
var NO_DEFLECTION_CHECK = "";

function inspectionWriteVariables() {
  var count = 1;
  var prefix = inspectionVariables.localVariablePrefix;
  inspectionVariables.probeRadius = prefix + count; // #1
  inspectionVariables.xTarget = prefix + ++count;
  inspectionVariables.yTarget = prefix + ++count;
  inspectionVariables.zTarget = prefix + ++count;
  inspectionVariables.xMeasured = prefix + ++count;
  inspectionVariables.yMeasured = prefix + ++count;
  inspectionVariables.zMeasured = prefix + ++count;
  inspectionVariables.activeToolLength = prefix + ++count;
  inspectionVariables.macroVariable1 = prefix + ++count;
  inspectionVariables.macroVariable2 = prefix + ++count;
  inspectionVariables.macroVariable3 = prefix + ++count;
  inspectionVariables.macroVariable4 = prefix + ++count;
  inspectionVariables.macroVariable5 = prefix + ++count;
  inspectionVariables.macroVariable6 = prefix + ++count;
  inspectionVariables.macroVariable7 = prefix + ++count;
  inspectionVariables.wcsVectorX = prefix + ++count;
  inspectionVariables.wcsVectorY = prefix + ++count;
  inspectionVariables.wcsVectorZ = prefix + ++count;
  inspectionVariables.previousWCSX = prefix + ++count;
  inspectionVariables.previousWCSY = prefix + ++count;
  inspectionVariables.previousWCSZ = prefix + ++count; // #21
  // set Buffer Variable
  if (getProperty("useLiveConnection")) {
    var bufferCount = getProperty("probeResultsBuffer");
    inspectionVariables.liveConnectionVersion = prefix + bufferCount; // #10100
    inspectionVariables.liveConnectionCapacity = prefix + ++bufferCount;
    inspectionVariables.liveConnectionReadPointer = prefix + ++bufferCount;
    inspectionVariables.liveConnectionWritePointer = prefix + ++bufferCount;
    inspectionVariables.liveConnectionStatus = prefix + ++bufferCount;
    inspectionVariables.workplaneStartAddress = prefix + ++bufferCount;
    inspectionVariables.liveConnectionWPA = prefix + ++bufferCount;
    inspectionVariables.liveConnectionWPB = prefix + ++bufferCount;
    inspectionVariables.liveConnectionWPC = prefix + ++bufferCount;
    inspectionVariables.probeRadius = prefix + ++bufferCount; // override
    inspectionVariables.commandID = prefix + ++bufferCount; // #10110
    inspectionVariables.commandArg1 = prefix + ++bufferCount;
    inspectionVariables.commandArg2 = prefix + ++bufferCount;
    inspectionVariables.commandArg3 = prefix + ++bufferCount;
    inspectionVariables.commandArg4 = prefix + ++bufferCount;
    inspectionVariables.commandArg5 = prefix + ++bufferCount;
    inspectionVariables.commandArg6 = prefix + ++bufferCount;
    inspectionVariables.commandArg7 = prefix + ++bufferCount;
    inspectionVariables.commandArg8 = prefix + ++bufferCount;
    inspectionVariables.commandArg9 = prefix + ++bufferCount;
    inspectionVariables.probeResultsStartAddress = ++bufferCount; // #10120
    if (getProperty("probeResultsBuffer") <= 0) {
      error("Probe Results Buffer start address cannot be less than or equal to zero when using a direct connection.");
      return;
    }
    if (getProperty("probeResultsBuffer") <= count) {
      error("Macro variables (" +
        prefix + 1 + "-" + prefix + count +
        ") and live probe results storage area (" +
        prefix + getProperty("probeResultsBuffer") + "-" + prefix + (bufferCount) +
        ") overlap." + EOL +
        "The minimal allowed value for property '" + properties.probeResultsBuffer.title + "' is " + (count + 1) + "."
      );
      return;
    }
  }
  // loop through all NC stream sections to check for surface inspection
  for (var i = 0; i < getNumberOfSections(); ++i) {
    var section = getSection(i);
    if (section.strategy == "inspectSurface") {
      inspectionVariables.workpieceOffset = section.workOffset;
      inspectionVariables.hasInspectionSections = true;
      inspectionValidateInspectionSettings();
      if (getProperty("commissioningMode")) {
        writeBlock("#3006=1" + formatComment("Inspection commissioning mode is active, when the machine is measuring correctly please disable this in the post properties"));
      }
      break;
    }
  }
}

function onProbe(status) {
  if (status) { // probe ON
    writeBlock(mFormat.format(19));
    writeBlock(getProperty("probeOnCommand")); // Command for switching the probe on
    onDwell(2);
    if (getProperty("commissioningMode")) {
      writeBlock("#3006=1" + formatComment("Ensure Probe Is Active"));
    }
  } else { // probe OFF
    writeBlock(getProperty("probeOffCommand")); // Command for switching the probe off
    onDwell(2);
    if (getProperty("commissioningMode")) {
      writeBlock("#3006=1" + formatComment("Ensure Probe Has Deactivated"));
    }
  }
}

function inspectionCycleInspect(cycle, x, y, z) {
  if (getNumberOfCyclePoints() != 3) {
    error(localize("Missing Endpoint in Inspection Cycle, check Approach and Retract heights"));
  }
  forceFeed(); // ensure feed is always output - just incase.
  if (isFirstCyclePoint()) {
    writeComment("Approach Move");
    // safe move to approach point start
    if (activeG254) {
      // Apply Eccentricity
      gMotionModal.reset();
      writeBlock(gFormat.format(61)); // exact stop mode on
      writeBlock(gAbsIncModal.format(91), gFormat.format(1),
        "X-" + macroFormat.format(getProperty("probeEccentricityX")),
        "Y-" + macroFormat.format(getProperty("probeEccentricityY")),
        feedOutput.format(cycle.safeFeed)
      );
      writeBlock(gFormat.format(103), "P1", formatComment("LOOKAHEAD OFF"));
      inspectionGetCoordinates(true);
      inspectionCalculateTargetEndpoint(x, y, z, SAFE_MOVE_DWO);
      // move alond probing vector with DWO off
      inspectionWriteCycleMove(gAbsIncModal.format(91), cycle.safeFeed, SAFE_MOVE_DWO, ALARM_IF_DEFLECTED);
      // Apply radius delta correction
      writeBlock(gAbsIncModal.format(91), gFormat.format(1),
        "Z+[" + xyzFormat.format(tool.diameter / 2) + "-" + inspectionVariables.probeRadius + "]",
        feedOutput.format(cycle.safeFeed)
      );
      writeBlock(gFormat.format(103), "P1", formatComment("LOOKAHEAD OFF"));
      inspectionGetCoordinates(false);
    } else {
      // only do trigger check when DWO is not active
      inspectionCalculateTargetEndpoint(x, y, z, SAFE_MOVE);
      inspectionWriteCycleMove(gAbsIncModal.format(90), cycle.safeFeed, SAFE_MOVE, ALARM_IF_DEFLECTED);
    }
    return;
  }
  if (isLastCyclePoint()) {
    // retract move
    writeComment("Retract Move");
    inspectionCalculateTargetEndpoint(x, y, z, LINEAR_MOVE);
    inspectionWriteCycleMove(gAbsIncModal.format(90), cycle.linkFeed, LINEAR_MOVE, NO_DEFLECTION_CHECK);
    forceXYZ();
    writeBlock(gFormat.format(64)); // exact stop mode on
    return;
  }
  // measure move
  if (getProperty("commissioningMode") && (inspectionVariables.pointNumber == 1)) {
    writeBlock("#3006=1" + formatComment("Probe is about to contact part. Axes should stop on contact"));
  }
  inspectionWriteNominalData(cycle);
  inspectionCalculateTargetEndpoint(x, y, z, MEASURE_MOVE);
  var f = cycle.measureFeed;
  if (activeG254) {
    inspectionWriteCycleMove(gAbsIncModal.format(91), f, MEASURE_MOVE, ALARM_IF_NOT_DEFLECTED);
    writeBlock(inspectionVariables.xTarget + "=" + macroFormat.format(inspectionVariables.systemVariableMeasuredX));
    writeBlock(inspectionVariables.yTarget + "=" + macroFormat.format(inspectionVariables.systemVariableMeasuredY));
    writeBlock(inspectionVariables.zTarget + "=" + macroFormat.format(inspectionVariables.systemVariableMeasuredZ) + " - " + inspectionVariables.activeToolLength);
    inspectionWriteCycleMove(gAbsIncModal.format(90), f, LINEAR_MOVE, NO_DEFLECTION_CHECK);
    inspectionReconfirmPositionDWO(f);
  } else {
    inspectionWriteCycleMove(gAbsIncModal.format(90), f, MEASURE_MOVE, ALARM_IF_NOT_DEFLECTED);
  }
  inspectionCorrectProbeMeasurement();
  inspectionWriteMeasuredData();
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
  if (getProperty("useLiveConnection") && controlType != "NGC") {
    return;
  }
  writeln("DPRNT[G800" +
    "*N" + inspectionVariables.pointNumber +
    "*X" + xyzFormat.format(cycle.nominalX) +
    "*Y" + xyzFormat.format(cycle.nominalY) +
    "*Z" + xyzFormat.format(cycle.nominalZ) +
    "*I" + ijkFormat.format(cycle.nominalI) +
    "*J" + ijkFormat.format(cycle.nominalJ) +
    "*K" + ijkFormat.format(cycle.nominalK) +
    "*O" + xyzFormat.format(getParameter("operation:inspectSurfaceOffset")) +
    "*U" + xyzFormat.format(getParameter("operation:inspectUpperTolerance")) +
    "*L" + xyzFormat.format(getParameter("operation:inspectLowerTolerance")) +
    "]"
  );
}

function inspectionCalculateTargetEndpoint(x, y, z, moveType) {
  writeComment("CALCULATE TARGET ENDPOINT");
  if (activeG254 && (moveType == MEASURE_MOVE || moveType == SAFE_MOVE_DWO)) {
    // get measure move vector with TWP active
    var searchIJK = new Vector(0, 0, 0);
    var searchDistance;
    var moveDistance;

    switch (moveType) {
    case MEASURE_MOVE:
      // writeComment("CTE - MEASURE_MOVE");
      searchDistance = getParameter("probeClearance") + getParameter("probeOvertravel");
      moveDistance = searchDistance * 0.1;
      searchDistance -= moveDistance;
      searchIJK.i = cycle.nominalI * -1 * moveDistance;
      searchIJK.j = cycle.nominalJ * -1 * moveDistance;
      searchIJK.k = cycle.nominalK * -1 * moveDistance;
      break;
    case SAFE_MOVE_DWO:
      // get safe move unit vector with DWO active
      // writeComment("CTE - SAFE_MOVE_DWO");
      var xyz = new Vector(0, 0, 0);
      xyz = getCurrentPosition();
      var vectorI = x - xyz.x;
      var vectorJ = y - xyz.y;
      var vectorK = z - xyz.z;
      var magnitude = Math.sqrt((vectorI * vectorI) + (vectorJ * vectorJ) + (vectorK * vectorK));
      moveDistance = magnitude * 0.1;
      searchIJK.i = (vectorI / magnitude) * moveDistance;
      searchIJK.j = (vectorJ / magnitude) * moveDistance;
      searchIJK.k = (vectorK / magnitude) * moveDistance;
      searchDistance = magnitude - moveDistance;
      break;
    default:
      // writeComment("CTE - DEFAULT");
    }
    // xyzTarget is previous move endpoint - with eccentricity correction
    writeBlock(inspectionVariables.xTarget + " =" + xyzFormat.format(searchIJK.i));
    writeBlock(inspectionVariables.yTarget + " =" + xyzFormat.format(searchIJK.j));
    writeBlock(inspectionVariables.zTarget + " =" + xyzFormat.format(searchIJK.k));
    inspectionWriteCycleMove(gAbsIncModal.format(91), moveType == MEASURE_MOVE ? cycle.measureFeed : cycle.safeFeed, LINEAR_MOVE, NO_DEFLECTION_CHECK);
    writeBlock(gFormat.format(255));
    writeComment("Calculate vector in WPCS");
    writeBlock(inspectionVariables.wcsVectorX + " =" + macroFormat.format(inspectionVariables.systemVariableMachineCoordX) + "-" + inspectionVariables.previousWCSX);
    writeBlock(inspectionVariables.wcsVectorY + " =" + macroFormat.format(inspectionVariables.systemVariableMachineCoordY) + "-" + inspectionVariables.previousWCSY);
    writeBlock(inspectionVariables.wcsVectorZ + " =[" + macroFormat.format(inspectionVariables.systemVariableMachineCoordZ) + "-" + inspectionVariables.activeToolLength + "]-" + inspectionVariables.previousWCSZ);
    writeBlock(inspectionVariables.macroVariable4 + " =SQRT[" +
      "[" + inspectionVariables.wcsVectorX + "*" + inspectionVariables.wcsVectorX + "]" + "+" +
      "[" + inspectionVariables.wcsVectorY + "*" + inspectionVariables.wcsVectorY + "]" + "+" +
      "[" + inspectionVariables.wcsVectorZ + "*" + inspectionVariables.wcsVectorZ + "]]"
    );
    writeComment("Convert to unit vector");
    // safe or measure move endpointwith DWO active
    writeBlock(inspectionVariables.xTarget + " =[" + xyzFormat.format(searchDistance) + " * [" + inspectionVariables.wcsVectorX + "/" + inspectionVariables.macroVariable4 + "]]");
    writeBlock(inspectionVariables.yTarget + " =[" + xyzFormat.format(searchDistance) + " * [" + inspectionVariables.wcsVectorY + "/" + inspectionVariables.macroVariable4 + "]]");
    writeBlock(inspectionVariables.zTarget + " =[" + xyzFormat.format(searchDistance) + " * [" + inspectionVariables.wcsVectorZ + "/" + inspectionVariables.macroVariable4 + "]]");
  } else {
    writeBlock(inspectionVariables.xTarget + " =" + xyzFormat.format(x) + "-" + macroFormat.format(getProperty("probeEccentricityX")));
    writeBlock(inspectionVariables.yTarget + " =" + xyzFormat.format(y) + "-" + macroFormat.format(getProperty("probeEccentricityY")));
    writeBlock(inspectionVariables.zTarget + " =" + xyzFormat.format(z) + "+[" + xyzFormat.format(tool.diameter / 2) + "-" + inspectionVariables.probeRadius + "]");
  }
}

function inspectionWriteCycleMove(absInc, _feed, moveType, triggerCheck) {
  // writeComment("moveType = " + moveType, triggerCheck);
  var motionCommand = moveType == LINEAR_MOVE ? 1 : 31;
  gMotionModal.reset();
  writeBlock(absInc,
    gFormat.format(motionCommand),
    "X" + inspectionVariables.xTarget,
    "Y" + inspectionVariables.yTarget,
    "Z" + inspectionVariables.zTarget,
    feedOutput.format(_feed),
    triggerCheck
  );
  writeBlock(gFormat.format(103), "P1", formatComment("LOOKAHEAD OFF"));
}

function inspectionProbeTriggerCheck(triggered) {
  var condition = triggered ? " GT " : " LT ";
  var message = triggered ? "NO POINT TAKEN" : "PATH OBSTRUCTED";
  var inPositionTolerance = (unit == MM) ? 0.01 : 0.0004;
  writeBlock(inspectionVariables.macroVariable1 + " =" + inspectionVariables.xTarget + "-" + macroFormat.format(inspectionVariables.systemVariableMeasuredX));
  writeBlock(inspectionVariables.macroVariable2 + " =" + inspectionVariables.yTarget + "-" + macroFormat.format(inspectionVariables.systemVariableMeasuredY));
  writeBlock(inspectionVariables.macroVariable3 + " =" + inspectionVariables.zTarget + "-" + macroFormat.format(inspectionVariables.systemVariableMeasuredZ) + "+" + inspectionVariables.activeToolLength);
  writeBlock(inspectionVariables.macroVariable4 + " =" +
    "[" + inspectionVariables.macroVariable1 + "*" + inspectionVariables.macroVariable1 + "]" + "+" +
    "[" + inspectionVariables.macroVariable2 + "*" + inspectionVariables.macroVariable2 + "]" + "+" +
    "[" + inspectionVariables.macroVariable3 + "*" + inspectionVariables.macroVariable3 + "]"
  );
  forceSequenceNumbers(true);
  writeBlock("IF [" + inspectionVariables.macroVariable4 + condition + inPositionTolerance + "] GOTO" + skipNLines(2));
  writeBlock("#3000 = 1 " + formatComment(message));
  writeBlock(" ");
  forceSequenceNumbers(false);
}

function inspectionCorrectProbeMeasurement() {
  writeComment("Correct Measurements");
  var adjustX = macroFormat.format(activeG254 ? inspectionVariables.systemVariablePreviousX : inspectionVariables.systemVariableMeasuredX);
  var adjustY = macroFormat.format(activeG254 ? inspectionVariables.systemVariablePreviousY : inspectionVariables.systemVariableMeasuredY);
  var adjustZ = macroFormat.format(activeG254 ? inspectionVariables.systemVariablePreviousZ : inspectionVariables.systemVariableMeasuredZ);

  writeBlock(inspectionVariables.xMeasured + " =" + adjustX + "+" + macroFormat.format(getProperty("probeEccentricityX")));
  writeBlock(inspectionVariables.yMeasured + " =" + adjustY + "+" + macroFormat.format(getProperty("probeEccentricityY")));
  // need to consider probe centre tool output point in future too
  var correctToolLength = activeG254 ? "" : ("-" + inspectionVariables.activeToolLength);
  writeBlock(inspectionVariables.zMeasured + " =" + adjustZ + "+" + inspectionVariables.probeRadius + correctToolLength);
}

function inspectionCalculateDeviation() {
  var outputFormat = (unit == MM) ? "[53]" : "[44]";
  // calculate the deviation and produce a warning if out of tolerance.
  // (Measured + ((vector *(-1))*calibrated radi))

  writeComment("calculate deviation");
  // compensate for tip rad in X
  writeBlock(
    inspectionVariables.macroVariable1 + "=[" +
    inspectionVariables.xMeasured + "+[[" +
    ijkFormat.format(cycle.nominalI) + "*[-1]]*" +
    inspectionVariables.probeRadius + "]]"
  );
  // compensate for tip rad in Y
  writeBlock(
    inspectionVariables.macroVariable2 + "=[" +
    inspectionVariables.yMeasured + "+[[" +
    ijkFormat.format(cycle.nominalJ) + "*[-1]]*" +
    inspectionVariables.probeRadius + "]]"
  );
  // compensate for tip rad in Z
  writeBlock(
    inspectionVariables.macroVariable3 + "=[" +
    inspectionVariables.zMeasured + "+[[" +
    ijkFormat.format(cycle.nominalK) + "*[-1]]*" +
    inspectionVariables.probeRadius + "]]"
  );
  // calculate deviation vector (Measured x - nominal x)
  writeBlock(
    inspectionVariables.macroVariable4 + "=" +
    inspectionVariables.macroVariable1 + "-" +
    xyzFormat.format(cycle.nominalX)
  );
  // calculate deviation vector (Measured y - nominal y)
  writeBlock(
    inspectionVariables.macroVariable5 + "=" +
    inspectionVariables.macroVariable2 + "-" +
    xyzFormat.format(cycle.nominalY)
  );
  // calculate deviation vector (Measured Z - nominal Z)
  writeBlock(
    inspectionVariables.macroVariable6 + "=[" +
    inspectionVariables.macroVariable3 + "-[" +
    xyzFormat.format(cycle.nominalZ) + "]]"
  );
  // sqrt xyz.xyz this is the value of the deviation
  writeBlock(
    inspectionVariables.macroVariable7 + "=SQRT[[" +
    inspectionVariables.macroVariable4 + "*" +
    inspectionVariables.macroVariable4 + "]+[" +
    inspectionVariables.macroVariable5 + "*" +
    inspectionVariables.macroVariable5 + "]+[" +
    inspectionVariables.macroVariable6 + "*" +
    inspectionVariables.macroVariable6 + "]]"
  );
  // sign of the vector
  writeBlock(
    inspectionVariables.macroVariable1 + "=[[" +
    ijkFormat.format(cycle.nominalI) + "*" +
    inspectionVariables.macroVariable4 + "]+[" +
    ijkFormat.format(cycle.nominalJ) + "*" +
    inspectionVariables.macroVariable5 + "]+[" +
    ijkFormat.format(cycle.nominalK) + "*" +
    inspectionVariables.macroVariable6 + "]]"
  );
  // print out deviation value
  forceSequenceNumbers(true);
  writeBlock(
    "IF [" + inspectionVariables.macroVariable1 + "GE0] GOTO" + skipNLines(3)
  );
  writeBlock(
    inspectionVariables.macroVariable4 + "=" +
    inspectionVariables.macroVariable7
  );
  writeBlock("GOTO" + skipNLines(2));
  writeBlock(
    inspectionVariables.macroVariable4 + "=[" +
    inspectionVariables.macroVariable7 + "*[-1]]"
  );
  writeBlock(" ");

  if (!getProperty("useLiveConnection") || controlType == "NGC") {
    writeln(
      "DPRNT[G802" + "*N" + inspectionVariables.pointNumber +
      "*DEVIATION*" + inspectionVariables.macroVariable4 + outputFormat + "]"
    );
  }
  // tolerance check
  writeBlock(
    "IF [" + inspectionVariables.macroVariable4 +
    "LT" + (xyzFormat.format(getParameter("operation:inspectUpperTolerance"))) +
    "] GOTO" + skipNLines(3)
  );
  writeBlock(
    "#3006 = 1" + formatComment("Inspection point over tolerance")
  );
  writeBlock("GOTO" + skipNLines(3));
  writeBlock(
    "IF [" + inspectionVariables.macroVariable4 +
    "GT" + (xyzFormat.format(getParameter("operation:inspectLowerTolerance"))) +
    "] GOTO" + skipNLines(2)
  );
  writeBlock(
    "#3006 = 1" + formatComment("Inspection point under tolerance")
  );
  writeBlock(" ");
  forceSequenceNumbers(false);
}

function inspectionWriteMeasuredData() {
  var outputFormat = (unit == MM) ? "[53]" : "[44]";
  if (!getProperty("useLiveConnection") || controlType == "NGC") {
    writeln("DPRNT[G801" +
      "*N" + inspectionVariables.pointNumber +
      "*X" + inspectionVariables.xMeasured + outputFormat +
      "*Y" + inspectionVariables.yMeasured + outputFormat +
      "*Z" + inspectionVariables.zMeasured + outputFormat +
      "*R" + inspectionVariables.probeRadius + outputFormat +
      "]"
    );
  } else {
    writeComment("Live connection");
  }
  if (cycle.outOfPositionAction == "stop-message" && !getProperty("liveConnection")) {
    inspectionCalculateDeviation();
  }
  if (getProperty("useLiveConnection")) {
    liveConnectionWriteData("inspectSurfacePoint");
  }
  inspectionVariables.pointNumber += 1;
}

function forceSequenceNumbers(force) {
  if (force) {
    setProperty("showSequenceNumbers", true);
  } else {
    setProperty("showSequenceNumbers", saveShowSequenceNumbers);
  }
}

function skipNLines(n) {
  return (n * getProperty("sequenceNumberIncrement") + sequenceNumber);
}

function inspectionProcessSectionStart() {
  writeBlock(gFormat.format(103), "P1", formatComment("LOOKAHEAD OFF"));
  // only write header once if user selects a single results file
  if (!isDPRNTopen || !getProperty("singleResultsFile") || (currentSection.workOffset != inspectionVariables.workpieceOffset)) {
    inspectionCreateResultsFileHeader();
    inspectionVariables.workpieceOffset = currentSection.workOffset;
  }
  // write the toolpath name as a comment
  if (!getProperty("useLiveConnection") || controlType == "NGC") {
    writeProbingToolpathInformation();
  }
  inspectionWriteCADTransform();
  inspectionWriteWorkplaneTransform();
  inspectionVariables.inspectionSectionCount += 1;
  if (getProperty("toolOffsetType") == "geomOnly") {
    writeComment("Geometry Only");
    writeBlock(
      inspectionVariables.activeToolLength + "=" +
      inspectionVariables.localVariablePrefix + "[" +
      inspectionVariables.systemVariableOffsetLengthTable + " + " +
      macroFormat.format(4111) +
      "]"
    );
  } else {
    writeComment("Geometry and Wear");
    writeBlock(
      inspectionVariables.activeToolLength + "=" +
      inspectionVariables.localVariablePrefix + "[" +
      inspectionVariables.systemVariableOffsetLengthTable + " + " +
      macroFormat.format(4111) +
      "] + " +
      inspectionVariables.localVariablePrefix + "[" +
      inspectionVariables.systemVariableOffsetWearTable + " + " +
      macroFormat.format(4111) +
      "]"
    );
  }
  if (getProperty("probeCalibrationMethod") == "Renishaw") {
    writeBlock(inspectionVariables.probeRadius + "=[[" +
      macroFormat.format(getProperty("probeCalibratedRadius")) + " + " +
      macroFormat.format(getProperty("probeCalibratedRadius") + 1) + "]" + "/2]"
    );
  } else {
    writeBlock(inspectionVariables.probeRadius + "=" + macroFormat.format(getProperty("probeCalibratedRadius")));
  }
  if (getProperty("commissioningMode") && !isDPRNTopen) {
    var outputFormat = (unit == MM) ? "[53]" : "[44]";
    if (!getProperty("useLiveConnection") || controlType == "NGC") {
      writeln("DPRNT[CALIBRATED*RADIUS*" + inspectionVariables.probeRadius + outputFormat + "]");
      writeln("DPRNT[ECCENTRICITY*X****" + macroFormat.format(getProperty("probeEccentricityX")) + outputFormat + "]");
      writeln("DPRNT[ECCENTRICITY*Y****" + macroFormat.format(getProperty("probeEccentricityY")) + outputFormat + "]");
    }
    forceSequenceNumbers(true);
    writeBlock("IF [" + inspectionVariables.probeRadius + " NE #0] GOTO" + skipNLines(2));
    writeBlock("#3000 = 1" + formatComment("PROBE NOT CALIBRATED OR PROPERTY CALIBRATED RADIUS INCORRECT"));
    writeBlock("IF [" + inspectionVariables.probeRadius + " NE 0] GOTO" + skipNLines(2));
    writeBlock("#3000 = 1" + formatComment("PROBE NOT CALIBRATED OR PROPERTY CALIBRATED RADIUS INCORRECT"));
    writeBlock("IF [" + inspectionVariables.probeRadius + " LT " + xyzFormat.format(tool.diameter / 2) + "] GOTO" + skipNLines(2));
    writeBlock("#3000 = 1" + formatComment("PROBE NOT CALIBRATED OR PROPERTY CALIBRATED RADIUS INCORRECT"));
    var maxEccentricity = (unit == MM) ? 0.2 : 0.0079;
    writeBlock("IF [ABS[" + macroFormat.format(getProperty("probeEccentricityX")) + "] LT " + maxEccentricity + "] GOTO" + skipNLines(2));
    writeBlock("#3000 = 1" + formatComment("PROBE NOT CALIBRATED OR PROPERTY ECCENTRICITY X INCORRECT"));
    writeBlock("IF [ABS[" + macroFormat.format(getProperty("probeEccentricityY")) + "] LT " + maxEccentricity + "] GOTO" + skipNLines(2));
    writeBlock("#3000 = 1" + formatComment("PROBE NOT CALIBRATED OR PROPERTY ECCENTRICITY Y INCORRECT"));
    writeBlock("IF [" + macroFormat.format(getProperty("probeEccentricityX")) + " NE #0] GOTO" + skipNLines(2));
    writeBlock("#3000 = 1" + formatComment("PROBE NOT CALIBRATED OR PROPERTY ECCENTRICITY X INCORRECT"));
    writeBlock("IF [" + macroFormat.format(getProperty("probeEccentricityY")) + " NE #0] GOTO" + skipNLines(2));
    writeBlock("#3000 = 1" + formatComment("PROBE NOT CALIBRATED OR PROPERTY ECCENTRICITY Y INCORRECT"));
    writeBlock(" ");
    forceSequenceNumbers(false);
  }
  isDPRNTopen = true;
}

function inspectionProcessSectionEnd() {
  // close inspection results file if the NC has inspection toolpaths
  if (inspectionVariables.hasInspectionSections) {
    if (getProperty("commissioningMode")) {
      if (controlType == "NGC") {
        forceSequenceNumbers(true);
        writeBlock(inspectionVariables.macroVariable1 + " = [#20261 * " + 4 * getProperty("sequenceNumberIncrement") + " + " + skipNLines(2) + "]");
        writeBlock("GOTO " + inspectionVariables.macroVariable1);
        writeBlock(" ");
        writeBlock("#3006=1" + formatComment("DPRNT LOCATION NOT SET"));
        onCommand(COMMAND_STOP);
        writeBlock("GOTO " + skipNLines(8));
        writeBlock(" ");
        writeBlock("#3006=1" + formatComment("CHECK SETTING 262 FOR RESULTS FILE LOCATION"));
        onCommand(COMMAND_STOP);
        writeBlock("GOTO " + skipNLines(4));
        writeBlock(" ");
        writeBlock("#3006=1" + formatComment("RESULTS FILE WRITTEN TO TCP PORT"));
        onCommand(COMMAND_STOP);
        writeBlock(" ");
        forceSequenceNumbers(false);
      } else {
        writeBlock("#3006=1" + formatComment("RESULTS FILE WRITTEN TO SERIAL PORT"));
      }
    }
    writeBlock(gFormat.format(103), "P0", formatComment("LOOKAHEAD ON"));
  }
}

function inspectionGetCoordinates(isApproachMove) {
  if (isApproachMove) {
    writeComment("Get Current Point DWO ON");
    writeBlock(inspectionVariables.xTarget + " =" + macroFormat.format(inspectionVariables.systemVariablePreviousX));
    writeBlock(inspectionVariables.yTarget + " =" + macroFormat.format(inspectionVariables.systemVariablePreviousY));
    writeBlock(inspectionVariables.zTarget + " =" + macroFormat.format(inspectionVariables.systemVariablePreviousZ));
  }
  writeComment("Current Point in WCS");
  writeBlock(gFormat.format(255));
  writeBlock(inspectionVariables.previousWCSX + " =" + macroFormat.format(inspectionVariables.systemVariableMachineCoordX));
  writeBlock(inspectionVariables.previousWCSY + " =" + macroFormat.format(inspectionVariables.systemVariableMachineCoordY));
  writeBlock(inspectionVariables.previousWCSZ + " =" + macroFormat.format(inspectionVariables.systemVariableMachineCoordZ) + "-" + inspectionVariables.activeToolLength);
  inspectionReconfirmPositionDWO(cycle.safeFeed);
}

function inspectionReconfirmPositionDWO(f) {
  // zero length move to re-confirm current position
  writeComment("Re-confirm position DWO Active");
  writeBlock(gFormat.format(254));
  writeBlock(gAbsIncModal.format(91), gMotionModal.format(1), "X0.0 Y0.0", feedOutput.format(f));
  writeBlock("Z0.0");
  writeBlock(gFormat.format(103), "P1", formatComment("LOOKAHEAD OFF"));
}

function liveConnectionHeader() {
  writeComment("Live Connection Header");
  writeBlock(gFormat.format(103), "P1", formatComment("LOOKAHEAD OFF"));
  writeBlock((inspectionVariables.liveConnectionVersion) + " = " + getProperty("controlConnectorVersion"));
  writeBlock((inspectionVariables.liveConnectionCapacity) + " = " + getProperty("probeNumberofPoints"));
  writeBlock(inspectionVariables.liveConnectionReadPointer + " = 0");
  writeBlock(inspectionVariables.liveConnectionWritePointer + " = 1");
  writeBlock("IF [" + inspectionVariables.liveConnectionStatus, "NE -1] THEN", inspectionVariables.liveConnectionStatus + " = 1");
  writeBlock("IF [" + inspectionVariables.liveConnectionStatus, "EQ -1] THEN", inspectionVariables.liveConnectionStatus + " = 3");
  writeBlock(inspectionVariables.workplaneStartAddress + " = 0");
  writeBlock(inspectionVariables.liveConnectionWPA + " = 0");
  writeBlock(inspectionVariables.liveConnectionWPB + " = 0");
  writeBlock(inspectionVariables.liveConnectionWPC + " = 0");
  if (getProperty("probeCalibrationMethod") == "Renishaw") {
    writeBlock(inspectionVariables.probeRadius + "=[[" +
      macroFormat.format(getProperty("probeCalibratedRadius")) + " + " +
      macroFormat.format(getProperty("probeCalibratedRadius") + 1) + "]" + "/2]"
    );
  } else {
    writeBlock(inspectionVariables.probeRadius + "=" + macroFormat.format(getProperty("probeCalibratedRadius")));
  }

  writeBlock(inspectionVariables.commandID + " = 0");
  for (var i = 1; i <= 9; i++) {
    writeBlock(inspectionVariables["commandArg" + i] + " = 0");
  }

  if (getProperty("probeResultsBuffer") == 0) {
    error("Probe Results Buffer start address cannot be zero when using a live connection.");
    return;
  }
  writeBlock("WHILE [" + inspectionVariables.liveConnectionStatus + " NE -1] DO1");
  writeComment("WAITING FOR FUSION CONNECTION");
  writeBlock(gFormat.format(53));
  writeBlock("END1");

  // LOOP THOUGH ALL THE TOOLPATHS TO GIVE THE DATA TO LIVE CONNECTION.
  writeComment("loop though all toolpaths for live connection");
  for (var i = 0; i < getNumberOfSections(); ++i) {
    var value = inspectionVariables.probeResultsStartAddress + 6 * inspectionVariables.probeResultsBufferIndex;
    var pathTypeID = macroFormat.format(value);
    var toolpathID = macroFormat.format(value + 1);
    var toolpathInfo1 = macroFormat.format(value + 2);
    var toolpathInfo2 = macroFormat.format(value + 3);
    var toolpathInfo3 = macroFormat.format(value + 4);
    var toolpathInfo4 = macroFormat.format(value + 5);

    var section = getSection(i);
    if (section.hasParameter("autodeskcam:operation-id")) {
      writeln("");
      writeBlock("WHILE [[" + inspectionVariables.liveConnectionStatus + " EQ -1" +
        "] AND [" + inspectionVariables.liveConnectionReadPointer + " EQ " + inspectionVariables.liveConnectionWritePointer + "]] DO1"
      );
      writeComment("WAITING FOR FUSION CONNECTION-OVERWRITE PROTECTION");
      writeBlock(gFormat.format(53));
      writeBlock("END1");
      writeBlock(pathTypeID + " = 0"); // Path type set to 0 as this is an Information data block
      writeBlock(toolpathID + " = " + section.getParameter("autodeskcam:operation-id"));
      writeBlock(toolpathInfo1 + " = 0"); // notice type record
      writeBlock(toolpathInfo2 + " = 0", formatComment("tool length")); // length
      writeBlock(toolpathInfo3 + " = 0", formatComment("tool radius")); // radius
      writeBlock(toolpathInfo4 + " = 0");
      inspectionVariables.probeResultsBufferIndex += 1;

      if (inspectionVariables.probeResultsBufferIndex > getProperty("probeNumberofPoints")) {
        inspectionVariables.probeResultsBufferIndex = 0;
      }
      writeBlock(inspectionVariables.liveConnectionWritePointer + " = " + inspectionVariables.probeResultsBufferIndex);
    }
  }
  writeBlock(gFormat.format(103), "P0", formatComment("LOOKAHEAD ON"));
}

// Store X value for size and position
function liveConnectionStoreResults() {
  writeBlock(gFormat.format(103), "P1", formatComment("LOOKAHEAD OFF"));
  writeBlock(inspectionVariables.commandArg8, "=", macroFormat.format(135)); // Store X position
  writeBlock(inspectionVariables.commandArg9, "=", macroFormat.format(138)); // Store X size
  writeBlock(gFormat.format(103), "P0", formatComment("LOOKAHEAD ON"));
}

function liveConnectionWriteData(type) {
  var pathTypeValue; // path types 0=Information / 1=inspect surface / 2=macro inspection / 3=milling / 4=additive
  if (isInspectionOperation()) {
    pathTypeValue = 1;
  } else if (isProbeOperation()) {
    pathTypeValue = 2;
  } else {
    pathTypeValue = 3; // if its anything else than inspection, path type=3 i.e milling
  }
  var value = inspectionVariables.probeResultsStartAddress + 6 * inspectionVariables.probeResultsBufferIndex;
  var pathTypeID = macroFormat.format(value);
  var toolpathID = macroFormat.format(value + 1);
  var toolpathInfo1 = macroFormat.format(value + 2);
  var toolpathInfo2 = macroFormat.format(value + 3);
  var toolpathInfo3 = macroFormat.format(value + 4);
  var toolpathInfo4 = macroFormat.format(value + 5);

  writeln("");
  liveConnectorInterface("overwriteProtection");
  writeBlock(gFormat.format(103), "P1", formatComment("LOOKAHEAD OFF"));
  switch (type) {
  case "toolpathStart":
    writeComment("Toolpath Start Live Import");
    writeBlock(pathTypeID + " = 0"); // record type
    writeBlock(toolpathID + " = " + getParameter("autodeskcam:operation-id"));
    writeBlock(toolpathInfo1 + " =  1"); // information type, 1 = "start" record, 2 = end record, 3 = part alignment
    writeBlock(toolpathInfo2 + " = #3012"); // HH-MM-SS 235,959 (max value)
    writeBlock(toolpathInfo3 + " = 0");
    writeBlock(toolpathInfo4 + " = 0");
    inspectionVariables.probeResultsBufferIndex += 1;
    break;
  case "toolpathEnd":
    writeComment("Toolpath End Live Import");
    writeBlock(pathTypeID + " = 0");
    writeBlock(toolpathID + " = " + getParameter("autodeskcam:operation-id"));
    writeBlock(inspectionVariables.commandArg1 + " = " + getParameter("autodeskcam:operation-id")); // store toolpath ID in cmd arg 1 for part alignment
    writeBlock(toolpathInfo1 + " = 2");
    writeBlock(toolpathInfo2 + " = #3012");
    writeBlock(toolpathInfo3 + " = 0");
    writeBlock(toolpathInfo4 + " = 0");
    inspectionVariables.probeResultsBufferIndex += 1;
    break;
  case "toolpathAlignment":
    writeComment("Toolpath Alignment Live Import");
    writeBlock(pathTypeID + " = 0");
    writeBlock(toolpathID + " = " + inspectionVariables.commandArg1);
    writeBlock(toolpathInfo1 + " =  3");
    writeBlock(toolpathInfo2 + " = 0");
    writeBlock(toolpathInfo3 + " = 0");
    writeBlock(toolpathInfo4 + " = 0");
    inspectionVariables.probeResultsBufferIndex += 1;
    break;
  case "milling":
    writeComment("Milling Toolpath Live Import");
    writeBlock(pathTypeID + " = " + pathTypeValue);
    writeBlock(toolpathID + " = " + getParameter("autodeskcam:operation-id"));
    writeBlock(toolpathInfo1 + " = 0");
    writeBlock(toolpathInfo2 + " = 0");
    writeBlock(toolpathInfo3 + " = 0");
    writeBlock(toolpathInfo4 + " = 0");
    inspectionVariables.probeResultsBufferIndex += 1;
    break;
  case "inspectSurfacePoint":
    writeComment("Inspect Surface Point Live Import");
    writeBlock(pathTypeID + " = " + pathTypeValue);
    writeBlock(toolpathID + " = " + getParameter("autodeskcam:operation-id"));
    writeBlock(toolpathInfo1 + " = " + cycle.pointID);
    writeBlock(toolpathInfo2 + " = " + inspectionVariables.xMeasured);
    writeBlock(toolpathInfo3 + " = " + inspectionVariables.yMeasured);
    writeBlock(toolpathInfo4 + " = " + inspectionVariables.zMeasured);
    inspectionVariables.probeResultsBufferIndex += 1;
    break;
  case "inspectSurfaceAlarm":
    writeBlock("IF [" + inspectionVariables.commandID + " EQ 2] THEN " + inspectionVariables.commandID + "= -2");
    writeBlock("IF [[" + inspectionVariables.commandID + " EQ -2] AND [" + inspectionVariables.commandArg1 + " EQ 1]] THEN #3006 = 1 (OUT_OF_TOLERANCE)");
    writeBlock("IF [[" + inspectionVariables.commandID + " EQ -2] AND [" + inspectionVariables.commandArg1 + " EQ 2]] THEN #3006 = 1 (-OUT_OF_TOLERANCE-)"); // Point unprojected alarm
    writeBlock("IF [[" + inspectionVariables.commandID + " EQ -2] AND [" + inspectionVariables.commandArg1 + " EQ 3]] THEN #3006 = 1 (PART_ALIGNMENT_ALARM)");
    writeBlock("IF [[" + inspectionVariables.commandID + " EQ -2] AND [" + inspectionVariables.commandArg1 + " EQ 4]] THEN #3006 = 1 (UNSPECIFIED)");
    writeBlock("IF [" + inspectionVariables.commandID + " EQ -2] THEN " + inspectionVariables.commandID + " = 0");
    break;
  case "macroEnd":
    var macroType = 0.009;
    var data1 = 0;
    var data2 = 0;
    var data3 = 0;
    var data4 = 0;
    switch (cycleType) {
    case "probing-x":
      macroType = 0.001;
      data1 = (macroFormat.format(188));
      data2 = (macroFormat.format(185));
      break;
    case "probing-y":
      macroType = 0.002;
      data1 = (macroFormat.format(188));
      data3 = (macroFormat.format(186));
      break;
    case "probing-z":
      macroType = 0.003;
      data1 = (macroFormat.format(188));
      data4 = (macroFormat.format(187));
      break;
    case "probing-xy-circular-boss":
    case "probing-xy-circular-hole":
    case "probing-xy-circular-partial-boss":
    case "probing-xy-circular-partial-hole":
    case "probing-xy-circular-hole-with-island":
    case "probing-xy-circular-partial-hole-with-island":
      macroType = 0.004;
      data1 = (macroFormat.format(188)); // Diameter
      data2 = (macroFormat.format(185)); // X position
      data3 = (macroFormat.format(186)); // Y Position
      break;
    case "probing-xy-rectangular-boss":
    case "probing-xy-rectangular-hole":
    case "probing-xy-rectangular-hole-with-island":
      macroType = 0.005;
      data1 = (inspectionVariables.commandArg9); // X size
      data2 = (inspectionVariables.commandArg8); // X position
      data3 = (macroFormat.format(186)); // Y position
      data4 = (macroFormat.format(188)); // Y size
      break;
    case "probing-x-wall":
    case "probing-x-channel":
    case "probing-x-channel-with-island":
      macroType = 0.006;
      data1 = (macroFormat.format(185)); // X size
      data2 = (macroFormat.format(188)); // X position
      break;
    case "probing-y-wall":
    case "probing-y-channel":
    case "probing-y-channel-with-island":
      macroType = 0.007;
      data3 = (macroFormat.format(186)); // Y position
      data4 = (macroFormat.format(188)); // Y size
      break;
    default:
      warning("This probing macro is not yet operated by Live connection");
      return;
    }
    writeComment("Macro Inspection Live Import");
    writeBlock(pathTypeID + " =" + (pathTypeValue + macroType + 0.00001));
    writeBlock(toolpathID + " = " + getParameter("autodeskcam:operation-id"));
    writeBlock(toolpathInfo1 + " = " + data1);
    writeBlock(toolpathInfo2 + " = " + data2);
    writeBlock(toolpathInfo3 + " = " + data3);
    writeBlock(toolpathInfo4 + " = " + data4);
    inspectionVariables.probeResultsBufferIndex += 1;
    break;
  }

  if (inspectionVariables.probeResultsBufferIndex > getProperty("probeNumberofPoints")) {
    inspectionVariables.probeResultsBufferIndex = 0;
  }
  writeBlock(inspectionVariables.liveConnectionWritePointer + " = " + inspectionVariables.probeResultsBufferIndex);
  writeBlock(gFormat.format(103), "P0", formatComment("LOOKAHEAD ON"));
}

function liveConnectorInterface(type) {
  switch (type) {
  case "overwriteProtection":
    writeBlock(
      "WHILE [[" + inspectionVariables.liveConnectionStatus + " EQ -1" +
      "] AND [" + inspectionVariables.liveConnectionReadPointer + " EQ " + inspectionVariables.liveConnectionWritePointer + "]] DO1"
    );
    writeComment("WAITING FOR FUSION CONNECTION");
    writeBlock(gFormat.format(53));
    writeBlock("END1");
    break;
  case "WORKPLANE":
    var orientation = (machineConfiguration.isMultiAxisConfiguration() && currentMachineABC != undefined) ? machineConfiguration.getOrientation(currentMachineABC) : currentSection.workPlane;
    var abc = orientation.getEuler2(EULER_XYZ_S);
    writeBlock(
      "WHILE [[" + inspectionVariables.workplaneStartAddress + " NE 0] AND [[" +
      inspectionVariables.liveConnectionWPA, "NE", abcFormat.format(abc.x) + "] OR [" +
      inspectionVariables.liveConnectionWPB, "NE", abcFormat.format(abc.y) + "] OR [" +
      inspectionVariables.liveConnectionWPC, "NE", abcFormat.format(abc.z) + "]]] DO1"
    );
    writeComment("WAITING FOR FUSION CONNECTION WORKPLANE READ");
    writeBlock(gFormat.format(53));
    writeBlock("END1");
    writeBlock(
      "IF [[" +
      inspectionVariables.liveConnectionWPA, "NE", abcFormat.format(abc.x) + "] OR [" +
      inspectionVariables.liveConnectionWPB, "NE", abcFormat.format(abc.y) + "] OR [" +
      inspectionVariables.liveConnectionWPC, "NE", abcFormat.format(abc.z) + "]] THEN " +
      inspectionVariables.workplaneStartAddress, "= -1"
    );
    break;
  }
}

function onLiveAlignment() {
  var workOffset = (currentWorkOffset == 0 ? 1 : currentWorkOffset);
  var nextWorkOffset = hasNextSection() ? getNextSection().workOffset == 0 ? 1 : getNextSection().workOffset : -1;
  if (workOffset == nextWorkOffset) {
    currentWorkOffset = undefined;
  }
  var standardRange = 6;
  var systemWCS = (workOffset > standardRange ? inspectionVariables.systemVariableWCSOffsetExt : inspectionVariables.systemVariableWCSOffset);
  systemWCS += (workOffset > standardRange ? (workOffset - (standardRange + 1)) : workOffset) * 20;

  var liveAlignmentOffset = {
    x: macroFormat.format(systemWCS + 1),
    y: macroFormat.format(systemWCS + 2),
    z: macroFormat.format(systemWCS + 3),
    a: macroFormat.format(systemWCS + 4),
    b: macroFormat.format(systemWCS + 5),
    c: macroFormat.format(systemWCS + 6),
  };

  writeln("");
  writeBlock(gFormat.format(103), "P1", formatComment("LOOKAHEAD OFF"));
  liveConnectionWriteData("toolpathAlignment");

  writeBlock("WHILE [" + inspectionVariables.commandID + " NE 3] DO1");
  writeComment("WAITING FOR WCS UPDATE");
  writeBlock(gFormat.format(53));
  writeBlock("IF [" + inspectionVariables.commandID + " EQ 2] THEN " + inspectionVariables.commandID + "= -2");
  writeBlock("IF [[" + inspectionVariables.commandID + " EQ -2] AND [" + inspectionVariables.commandArg1 + " EQ 3]] THEN #3006 = 1 (PART_ALIGNMENT_ALARM)");
  writeBlock("IF [[" + inspectionVariables.commandID + " EQ -2] AND [" + inspectionVariables.commandArg1 + " EQ 3]] THEN " + inspectionVariables.liveConnectionStatus, "= 2"); //If using live connection set Results active to a 2 to signify program end
  writeBlock("IF [" + inspectionVariables.commandID + " EQ -2] THEN " + inspectionVariables.commandID + " = 0"); // Clear Alarm
  writeBlock("IF [[" + inspectionVariables.liveConnectionStatus + " EQ 2] AND [" + inspectionVariables.commandArg1 + " EQ 3]] THEN M30");
  writeBlock("END1");

  writeBlock(liveAlignmentOffset.x + " = " + liveAlignmentOffset.x + "-" + inspectionVariables.commandArg1);
  writeBlock(liveAlignmentOffset.y + " = " + liveAlignmentOffset.y + "-" + inspectionVariables.commandArg2);
  writeBlock(liveAlignmentOffset.z + " = " + liveAlignmentOffset.z + "-" + inspectionVariables.commandArg3);
  writeBlock(liveAlignmentOffset.a + " = " + liveAlignmentOffset.a + "-" + inspectionVariables.commandArg4);
  writeBlock(liveAlignmentOffset.b + " = " + liveAlignmentOffset.b + "-" + inspectionVariables.commandArg5);
  writeBlock(liveAlignmentOffset.c + " = " + liveAlignmentOffset.c + "-" + inspectionVariables.commandArg6);
  writeBlock("IF [" + inspectionVariables.commandID + " EQ 3] THEN " + inspectionVariables.commandID + " = 0");
  writeBlock(gFormat.format(103), "P0", formatComment("LOOKAHEAD ON"));
}
// <<<<< INCLUDED FROM ../common/haas base inspection.cps

function inspectionValidateInspectionSettings() {
  var errorText = "";
  if (getProperty("probeOnCommand") == "") {
    errorText += "\n-Probe On Command-";
  }
  if (getProperty("probeOffCommand") == "") {
    errorText += "\n-Probe Off Command-";
  }
  if (getProperty("probeCalibratedRadius") == 0) {
    errorText += "\n-Calibrated Radius-";
  }
  if (getProperty("probeEccentricityX") == 0) {
    errorText += "\n-Eccentricity X-";
  }
  if (getProperty("probeEccentricityY") == 0) {
    errorText += "\n-Eccentricity Y-";
  }
  if (errorText != "") {
    error(localize("The following properties need to be configured:" + errorText + "\n-Please consult the guide PDF found at https://cam.autodesk.com/hsmposts?p=haas_next_generation_inspect_surface for more information-"));
  }
}
