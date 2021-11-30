/**
  Copyright (C) 2012-2020 by Autodesk, Inc.
  All rights reserved.

  HAAS post processor configuration.

    Origional Version Info
  $Revision: 42834 18ed74b0b685b0d3fd238e58719b897a383e6fa6 $
  $Date: 2020-06-24 06:42:41 $
  
    Conturo Prototyping Version Info
    
    V1.0 11/17/2021
    Devon @ DSI 
      -A axis angle range modification for posative and negative operation specificially to get the TR110 working in Daytona
    Billy @ CP
     -add date to program
     -add username to program

    V2.0 11/18/2021
    Billy @ CP
    Changed the way HSM (G187) is calculated, was based off STL, now it's a combo of tolerance and smoothing

*/

// >>>>> INCLUDED FROM ../../../haas next generation.cps
///////////////////////////////////////////////////////////////////////////////
//                        MANUAL NC COMMANDS
//
// The following ACTION commands are supported by this post.
//
//     cycleReverse                  - Reverses the spindle in a drilling cycle
//
///////////////////////////////////////////////////////////////////////////////

description = "HAAS - Next Generation Control";
vendor = "Haas Automation";
vendorUrl = "https://www.haascnc.com";
legal = "Copyright (C) 2012-2020 by Autodesk, Inc.";
certificationLevel = 2;
minimumRevision = 40783;

longDescription = "Generic post for the HAAS Next Generation control. The post includes support for multi-axis indexing and simultaneous machining. The post utilizes the dynamic work offset feature so you can place your work piece as desired without having to repost your NC programs." + EOL +
"You can specify following pre-configured machines by using the property 'Machine model':" + EOL +
"UMC-500" + EOL + "UMC-750" + EOL + "UMC-1000";

extension = "nc";
programNameIsInteger = true;
setCodePage("ascii");
keywords = "MODEL_IMAGE PREVIEW_IMAGE";

capabilities = CAPABILITY_MILLING;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.25, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(355);
allowHelicalMoves = true;
allowedCircularPlanes = undefined; // allow any circular motion
allowSpiralMoves = true;
highFeedrate = (unit == IN) ? 650 : 5000; // up to 650 should be supported

// user-defined properties
properties = {
  writeMachine: false, // write machine
  writeTools: true, // writes the tools
  writeVersion: false, // include version info
  preloadTool: true, // preloads next tool on tool change if any
  chipTransport: false, // turn on chip transport at start of program
  showSequenceNumbers: true, // show sequence numbers
  sequenceNumberStart: 1, // first sequence number
  sequenceNumberIncrement: 1, // increment for sequence numbers
  sequenceNumberOnlyOnToolChange: false, // only output sequence numbers on tool change
  optionalStop: true, // optional stop
  separateWordsWithSpace: true, // specifies that the words should be separated with a white space
  useRadius: false, // specifies that arcs should be output using the radius (R word) instead of the I, J, and K words.
  useParametricFeed: false, // specifies that feed should be output using Q values
  showNotes: false, // specifies that operation notes should be output
  useG0: false, // allow G0 when moving along more than one axis
  useG28: false, // specifies that G28 should be used instead of G53
  useSubroutines: false, // specifies that subroutines should be generated
  useSubroutinePatterns: false, // generates subroutines for patterned operation
  useSubroutineCycles: false, // generates subroutines for cycle operations on same holes
  useG187: false, // use G187 to set smoothing on the machine
  homePositionCenter: true, // moves the part in X in center of the door at end of program (ONLY WORKS IF THE TABLE IS MOVING)
  optionallyCycleToolsAtStart: false, // cycle through each tool used at the beginning of the program when block delete is turned off - this allows the operator to easily measure all tools before they are used for the first run of the program
  optionallyMeasureToolsAtStart: false, // measure each tool used at the beginning of the program when block delete is turned off - this allows the operator to easily measure all tools before they are used for the first run of the program
  hasAAxis: "false", // configures A axis
  hasBAxis: "false", // configures B axis
  hasCAxis: "false", // configures C axis
  machineModel: "none", // specifies the pre-configured machine model
  forceHomeOnIndexing: false, // force home position on indexing
  toolBreakageTolerance: 0.1, // value for which tool break detection will raise an alarm
  safeStartAllOperations: false, // write optional blocks at the beginning of all operations that include all commands to start program
  fastToolChange: false, // skip spindle off, coolant off, and Z retract to make tool change quicker
  useG95forTapping: false, // use IPR/MPR instead of IPM/MPM for tapping
  safeRetractDistance: 0.0, // distance to add to retract distance when rewinding rotary axes
  useDPMFeeds: false, // output DPM feeds instead of Inverse Time feeds
  useTCPC: true, // enable/disable TCPC option
  useDWO: true, // Dynamic Work Offset (DWO), like CYCL 19
  useM130PartImages: false, // enable to include M130 pictures
  useM130ToolImages: false // enable to include M130 pictures
};

propertyDefinitions = {
  machineModel: {
    title: "Machine model",
    description: "Specifies the pre-configured machine model.",
    type: "enum",
    group:0,
    values:[
      {title:"None", id:"none"},
      {title:"UMC-500", id:"umc-500"},
      {title:"UMC-750", id:"umc-750"},
      {title:"UMC-1000", id:"umc-1000"}
    ]
  },
  // group 1
  hasAAxis: {
    title: "Has A-axis rotary",
    description: "Enable if the machine has an A-axis table/trunnion. Check the table direction on the machine and use the (Reversed) selection if the table is moving in the opposite direction.",
    type: "enum",
    group:1,
    values:[
      {title:"No", id:"false"},
      {title:"Yes", id:"true"},
      {title:"Reversed", id:"reversed"}
    ]
  },
  hasBAxis: {
    title: "Has B-axis rotary",
    description: "Enable if the machine has a B-axis table/trunnion. Check the table direction on the machine and use the (Reversed) selection if the table is moving in the opposite direction.",
    type: "enum",
    group:1,
    values:[
      {title:"No", id:"false"},
      {title:"Yes", id:"true"},
      {title:"Reversed", id:"reversed"}
    ]
  },
  hasCAxis: {
    title: "Has C-axis rotary",
    description: "Enable if the machine has a C-axis table. Specifies a trunnion setup if an A-axis or B-axis is defined. Check the table direction on the machine and use the (Reversed) selection if the table is moving in the opposite direction.",
    type: "enum",
    group:1,
    values:[
      {title:"No", id:"false"},
      {title:"Yes", id:"true"},
      {title:"Reversed", id:"reversed"}
    ]
  },
  useDPMFeeds: {title:"Rotary moves use DPM feeds", description:"Enable to output DPM feeds, disable for Inverse Time feeds with rotary axes moves.", group:1, type:"boolean"},
  useTCPC: {title:"Use TCPC programming", description:"The control supports Tool Center Point Control programming.", group:1, type:"boolean"},
  useDWO: {title:"Use DWO", description:"Specifies that the Dynamic Work Offset feature (G254/G255) should be used.", group:1, type:"boolean"},
  // group 2
  preloadTool: {title:"Preload tool", description:"Preloads the next tool at a tool change (if any).", group:2, type:"boolean"},
  chipTransport: {title:"Use chip transport", description:"Enable to turn on chip transport at start of program.", group:2, type:"boolean"},
  optionalStop: {title:"Optional stop", description:"Specifies that optional stops M1 should be output at tool changes.", group:2, type:"boolean"},
  separateWordsWithSpace: {title:"Separate words with space", description:"Adds spaces between words if 'yes' is selected.", group:2, type:"boolean"},
  useRadius: {title:"Radius arcs", description:"If yes is selected, arcs are output using radius values rather than IJK.", group:2, type:"boolean"},
  useParametricFeed:  {title:"Parametric feed", description:"Parametric feed values based on movement type are output.", group:2, type:"boolean"},
  useG0: {title:"Use G0", description:"Specifies that G0s should be used for rapid moves when moving along a single axis.", group:2, type:"boolean"},
  useG28: {title:"Use G28 instead of G53", description:"Specifies that machine retracts should be done using G28 instead of G53.", group:2, type:"boolean"},
  useG187: {title:"Use G187", description:"Specifies that smoothing using G187 should be used.", group:2, type:"boolean"},
  homePositionCenter: {title:"Home position center", description:"Enable to center the part along X at the end of program for easy access. Requires a CNC with a moving table. This option has no effect on UMC machines.", group:2, type:"boolean"},
  optionallyCycleToolsAtStart: {title:"Optionally cycle tools at start", description:"Cycle through each tool used at the beginning of the program when block delete is turned off.", group:2, type:"boolean"},
  optionallyMeasureToolsAtStart: {title:"Optionally measure tools at start", description:"Measure each tool used at the beginning of the program when block delete is turned off.", group:2, type:"boolean"},
  forceHomeOnIndexing: {title:"Force home position on indexing", description:"Force home position on multi-axis indexing. This option is always active on UMC machines.", group:2, type:"boolean"},
  toolBreakageTolerance: {title:"Tool breakage tolerance", description:"Specifies the tolerance for which tool break detection will raise an alarm.", group:2, type:"spatial"},
  safeStartAllOperations: {title:"Safe start all operations", description:"Write optional blocks at the beginning of all operations that include all commands to start program.", group:2, type:"boolean"},
  fastToolChange: {title:"Fast tool change", description:"Skip spindle off, coolant off, and Z retract to make tool change quicker.", group:2, type:"boolean"},
  useG95forTapping: {title:"Use G95 for tapping", description:"use IPR/MPR instead of IPM/MPM for tapping", group:2, type:"boolean"},
  safeRetractDistance: {title:"Safe retract distance", description:"Specifies the distance to add to retract distance when rewinding rotary axes.", group:2, type:"spatial"},
  // group 3
  useSubroutines: {title:"Use subroutines", description:"Enables output of subroutines for each operation.", group:3, type:"boolean"},
  useSubroutinePatterns: {title:"Subroutines for patterns", description:"Enable output of subroutines for patterns.", group:3, type:"boolean"},
  useSubroutineCycles: {title:"Subroutines for cycles", description:"Enable output of subroutines for cycles.", group:3, type:"boolean"},
  // group 4
  writeMachine: {title:"Write machine", description:"Output the machine settings in the header of the code.", group:4, type:"boolean"},
  writeTools: {title:"Write tool list", description:"Output a tool list in the header of the code.", group:4, type:"boolean"},
  writeVersion: {title:"Write version", description:"Write the version number in the header of the code.", group:4, type:"boolean"},
  showSequenceNumbers: {title:"Use sequence numbers", description:"Use sequence numbers for each block of outputted code.", group:4, type:"boolean"},
  sequenceNumberStart: {title:"Start sequence number", description:"The number at which to start the sequence numbers.", group:4, type:"integer"},
  sequenceNumberIncrement: {title:"Sequence number increment", description:"The amount by which the sequence number is incremented by in each block.", group:4, type:"integer"},
  sequenceNumberOnlyOnToolChange: {title:"Block number only on tool change", description:"Specifies that block numbers should only be output at tool changes.", group:4, type:"boolean"},
  showNotes: {title:"Show notes", description:"Enable to output notes for operations.", group: 4, type:"boolean"},
  useM130PartImages: {title:"Include M130 part images", description:"Enable to include M130 part images with the NC file.", group: 4, type:"boolean"},
  useM130ToolImages: {title:"Include M130 tool images", description:"Enable to include M130 tool images with the NC file.", group: 4, type:"boolean"}
};

var singleLineCoolant = false; // specifies to output multiple coolant codes in one line rather than in separate lines
// samples:
// {id: COOLANT_THROUGH_TOOL, on: 88, off: 89}
// {id: COOLANT_THROUGH_TOOL, on: [8, 88], off: [9, 89]}
var coolants = [
  {id: COOLANT_FLOOD, on: 8},
  {id: COOLANT_MIST},
  {id: COOLANT_THROUGH_TOOL, on: 88, off: 89},
  {id: COOLANT_AIR, on: 83, off: 84},
  {id: COOLANT_AIR_THROUGH_TOOL, on: 73, off: 74},
  {id: COOLANT_SUCTION},
  {id: COOLANT_FLOOD_MIST},
  {id: COOLANT_FLOOD_THROUGH_TOOL, on: [88, 8], off: [89, 9]},
  {id: COOLANT_OFF, off: 9}
];

// old machines only support 4 digits
var oFormat = createFormat({width:5, zeropad:true, decimals:0});
var nFormat = createFormat({decimals:0});

var gFormat = createFormat({prefix:"G", decimals:0});
var mFormat = createFormat({prefix:"M", decimals:0});
var hFormat = createFormat({prefix:"H", decimals:0});
var dFormat = createFormat({prefix:"D", decimals:0});
var probe154Format = createFormat({decimals:0, zeropad:true, width:2});

var xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var rFormat = xyzFormat; // radius
var abcFormat = createFormat({decimals:3, forceDecimal:true, scale:DEG});
var feedFormat = createFormat({decimals:(unit == MM ? 2 : 3), forceDecimal:true});
var pitchFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var toolFormat = createFormat({decimals:0});
var rpmFormat = createFormat({decimals:0});
var secFormat = createFormat({decimals:3, forceDecimal:true}); // seconds - range 0.001-1000
var milliFormat = createFormat({decimals:0}); // milliseconds // range 1-9999
var taperFormat = createFormat({decimals:1, scale:DEG});

var xOutput = createVariable({prefix:"X"}, xyzFormat);
var yOutput = createVariable({prefix:"Y"}, xyzFormat);
var zOutput = createVariable({onchange: function() {retracted = false;}, prefix:"Z"}, xyzFormat);
var aOutput = createVariable({prefix:"A"}, abcFormat);
var bOutput = createVariable({prefix:"B"}, abcFormat);
var cOutput = createVariable({prefix:"C"}, abcFormat);
var feedOutput = createVariable({prefix:"F"}, feedFormat);
var inverseTimeOutput = createVariable({prefix:"F", force:true}, feedFormat);
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
var gRotationModal = createModal({}, gFormat); // modal group 16 // G68-G69

// fixed settings
var firstFeedParameter = 100; // the first variable to use with parametric feed
var forceResetWorkPlane = false; // enable to force reset of machine ABC on new orientation
var minimumCyclePoints = 5; // minimum number of points in cycle operation to consider for subprogram
var useDwoForPositioning = true; // specifies to use the DWO feature for XY positioning for multi-axis operations

var WARNING_WORK_OFFSET = 0;

var ANGLE_PROBE_NOT_SUPPORTED = 0;
var ANGLE_PROBE_USE_ROTATION = 1;
var ANGLE_PROBE_USE_CAXIS = 2;

var SUB_UNKNOWN = 0;
var SUB_PATTERN = 1;
var SUB_CYCLE = 2;

// collected state
var sequenceNumber;
var currentWorkOffset;
var optionalSection = false;
var forceSpindleSpeed = false;
var activeMovements; // do not use by default
var currentFeedId;
var maximumCircularRadiiDifference = toPreciseUnit(0.005, MM);
var maximumLineLength = 80; // the maximum number of charaters allowed in a line
var g68RotationMode = 0;
var angularProbingMode;
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
  var maximumSequenceNumber = (properties.useSubroutines || properties.useSubroutinePatterns ||
    properties.useSubroutineCycles) ? initialSubprogramNumber : 99999;
  if (properties.showSequenceNumbers) {
    if (sequenceNumber >= maximumSequenceNumber) {
      sequenceNumber = properties.sequenceNumberStart;
    }
    if (optionalSection || skipBlock) {
      if (text) {
        writeWords("/", "N" + sequenceNumber, text);
      }
    } else {
      writeWords2("N" + sequenceNumber, arguments);
    }
    sequenceNumber += properties.sequenceNumberIncrement;
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
  var show = properties.showSequenceNumbers;
  properties.showSequenceNumbers = show || properties.sequenceNumberOnlyOnToolChange;
  writeBlock(arguments);
  properties.showSequenceNumbers = show;
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
  writeOptionalBlock("T" + toolFormat.format(tool.number), mFormat.format(6)); // get tool
  writeOptionalBlock(mFormat.format(0)); // wait for operator
}

function writeToolMeasureBlock(tool) {
  var writeFunction = measureTool ? writeBlock : writeOptionalBlock;
  var comment = measureTool ? formatComment("MEASURE TOOL") : "";
  if (true) { // use Macro P9023 to measure tools
    var probingType = getHaasProbingType(tool.type, true);
    writeFunction(
      gFormat.format(65),
      "P9023",
      "A" + probingType + ".",
      "T" + toolFormat.format(tool.number),
      conditional((probingType != 12), "H" + xyzFormat.format(tool.bodyLength + tool.holderLength)),
      conditional((probingType != 12), "D" + xyzFormat.format(tool.diameter)),
      comment
    );
  } else { // use Macro P9995 to measure tools
    writeFunction("T" + toolFormat.format(tool.number), mFormat.format(6)); // get tool
    writeFunction(
      gFormat.format(65),
      "P9995",
      "A0.",
      "B" + getHaasToolType(tool.type) + ".",
      "C" + getHaasProbingType(tool.type, false) + ".",
      "T" + toolFormat.format(tool.number),
      "E" + xyzFormat.format(tool.bodyLength + tool.holderLength),
      "D" + xyzFormat.format(tool.diameter),
      "K" + xyzFormat.format(0.1),
      "I0.",
      comment
    ); // probe tool
  }
  measureTool = false;
}

function defineMachine() {
  switch (properties.machineModel) {
  case "umc-500":
    var axis1 = createAxis({coordinate:1, table:true, axis:[0, 1, 0], range:[-35, 120], preference:1});
    var axis2 = createAxis({coordinate:2, table:true, axis:[0, 0, 1], cyclic:true, preference:0});
    machineConfiguration = new MachineConfiguration(axis1, axis2);
    machineConfiguration.setHomePositionX(toPreciseUnit(0, IN));
    machineConfiguration.setHomePositionY(toPreciseUnit(0, IN));
    machineConfiguration.setRetractPlane(toPreciseUnit(0, IN));
    properties.homePositionCenter = false;
    properties.forceHomeOnIndexing = true;
    maximumSpindleRPM = 8100;
    break;
  case "umc-750":
    var axis1 = createAxis({coordinate:1, table:true, axis:[0, 1, 0], range:[-35, 120], preference:1});
    var axis2 = createAxis({coordinate:2, table:true, axis:[0, 0, 1], cyclic:true, preference:0});
    machineConfiguration = new MachineConfiguration(axis1, axis2);
    machineConfiguration.setHomePositionX(toPreciseUnit(-29.0, IN));
    machineConfiguration.setHomePositionY(toPreciseUnit(-8, IN));
    machineConfiguration.setRetractPlane(toPreciseUnit(2.5, IN));
    properties.homePositionCenter = false;
    properties.forceHomeOnIndexing = true;
    maximumSpindleRPM = 8100;
    break;
  case "umc-1000":
    var axis1 = createAxis({coordinate:1, table:true, axis:[0, 1, 0], range:[-35, 120], preference:1});
    var axis2 = createAxis({coordinate:2, table:true, axis:[0, 0, 1], cyclic:true, preference:0});
    machineConfiguration = new MachineConfiguration(axis1, axis2);
    machineConfiguration.setHomePositionX(toPreciseUnit(0, IN));
    machineConfiguration.setHomePositionY(toPreciseUnit(0, IN));
    machineConfiguration.setRetractPlane(toPreciseUnit(0, IN));
    properties.homePositionCenter = false;
    properties.forceHomeOnIndexing = true;
    maximumSpindleRPM = 8100;
    break;
  }
  machineConfiguration.setModel(properties.machineModel.toUpperCase());
  machineConfiguration.setVendor("Haas Automation");
  setMachineConfiguration(machineConfiguration);
  optimizeMachineAngles2(properties.useTCPC ? 0 : 1); // map tip mode
}

function onOpen() {
  if (properties.useDPMFeeds) {
    gFeedModeModal.format(94);
  }
  if (properties.useRadius) {
    maximumCircularSweep = toRad(90); // avoid potential center calculation errors for CNC
  }
  if (properties.sequenceNumberOnlyOnToolChange) {
    properties.showSequenceNumbers = false;
  }
  if (!properties.useDWO) {
    useDwoForPositioning = false;
  }

  gRotationModal.format(69); // Default to G69 Rotation Off

  hasA = properties.hasAAxis != "false";
  hasB = properties.hasBAxis != "false";
  hasC = properties.hasCAxis != "false";

  if (hasA && hasB && hasC) {
    error(localize("Only two rotary axes can be active at the same time."));
    return;
  } else if ((hasA || hasB || hasC) && properties.machineModel != "none") {
    error(localize("You can only select either a machine model or use the ABC axis properties."));
    return;
  }
  if (properties.machineModel == "none") {
    if (hasA || hasB || hasC) { // configure machine
      var aAxis;
      var bAxis;
      var cAxis;

      if (hasA) { // A Axis - For horizontal machines and trunnions (Modified by Devon at DSI 11_16_21)
        var dir = properties.hasAAxis == "reversed" ? -1 : 1;
        if (hasC || hasB) {
         // var aMin = (dir == 1) ? -120 - 0.0001 : -120 - 0.0001;
         // var aMax = (dir == 1) ? 120 + 0.0001 : 120 + 0.0001;
          aAxis = createAxis({coordinate:0, table:true, axis:[dir, 0, 0], range:[-1,120], preference:dir});
        } else {
          aAxis = createAxis({coordinate:0, table:true, axis:[dir, 0, 0], cyclic:true});
        }
      }

      if (hasB) { // B Axis - For horizontal machines and trunnions
        var dir = properties.hasBAxis == "reversed" ? -1 : 1;
        if (hasC) {
          var bMin = (dir == 1) ? -120 - 0.0001 : -30 - 0.0001;
          var bMax = (dir == 1) ? 30 + 0.0001 : 120 + 0.0001;
          bAxis = createAxis({coordinate:1, table:true, axis:[0, dir, 0], range:[bMin, bMax], preference:-dir});
        } else if (hasA) {
          bAxis = createAxis({coordinate:1, table:true, axis:[0, 0, dir], cyclic:true});
        } else {
          bAxis = createAxis({coordinate:1, table:true, axis:[0, dir, 0], cyclic:true});
        }
      }

      if (hasC) { // C Axis - For trunnions only
        var dir = properties.hasCAxis == "reversed" ? -1 : 1;
        cAxis = createAxis({coordinate:2, table:true, axis:[0, 0, dir], cyclic:true});
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
      }

      if (hasA || hasB || hasC) {
        setMachineConfiguration(machineConfiguration);
        optimizeMachineAngles2(properties.useTCPC ? 0 : 1); // map tip mode
      }
    }
  } else {
    defineMachine();
  }

  if (!machineConfiguration.isMachineCoordinate(0)) {
    aOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(1)) {
    bOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(2)) {
    cOutput.disable();
  }

  if (highFeedrate <= 0) {
    error(localize("You must set 'highFeedrate' because axes are not synchronized for rapid traversal."));
    return;
  }
  
  if (!properties.separateWordsWithSpace) {
    setWordSeparator("");
  }

  sequenceNumber = properties.sequenceNumberStart;
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
  
  if (properties.useG0) {
    writeComment(localize("Using G0 which travels along dogleg path."));
  } else {
    writeComment(subst(localize("Using high feed G1 F%1 instead of G0."), feedFormat.format(highFeedrate)));
  }

  if (properties.writeVersion) {
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

  if (properties.writeMachine && (vendor || model || description)) {
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

  // write user name
  if (hasGlobalParameter("username")) {
        var usernameprint = getGlobalParameter("username");
        writeln("");
        writeComment("Username: " + usernameprint);
    }

  // write date	
  if (hasGlobalParameter("generated-at")) {
        var datetime = getGlobalParameter("generated-at");
        writeComment("Program Posted: " + datetime);
    }

  // dump tool information
  if (properties.writeTools) {
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

        if (properties.useM130ToolImages) {
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
  if (properties.optionallyCycleToolsAtStart || properties.optionallyMeasureToolsAtStart) {
    var tools = getToolTable();
    if (tools.getNumberOfTools() > 0) {
      writeln("");

      writeOptionalBlock(mFormat.format(0), formatComment(localize("Read note"))); // wait for operator
      writeComment(localize("With BLOCK DELETE turned off each tool will cycle through"));
      writeComment(localize("the spindle to verify that the correct tool is in the tool magazine"));
      if (properties.optionallyMeasureToolsAtStart) {
        writeComment(localize("and to automatically measure it"));
      }
      writeComment(localize("Once the tools are verified turn BLOCK DELETE on to skip verification"));
      
      for (var i = 0; i < tools.getNumberOfTools(); ++i) {
        var tool = tools.getTool(i);
        if (properties.optionallyMeasureToolsAtStart && (tool.type == TOOL_PROBE)) {
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
        if (properties.optionallyMeasureToolsAtStart) {
          writeToolMeasureBlock(tool);
        } else {
          writeToolCycleBlock(tool);
        }
      }
    }
    writeln("");
  }

  if (false /*properties.useDWO*/) {
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

  if (properties.chipTransport) {
    onCommand(COMMAND_START_CHIP_TRANSPORT);
  }
  // Probing Surface Inspection
  if (typeof inspectionWriteVariables == "function") {
    inspectionWriteVariables();
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
    // set working plane after datum shift

    if (_section.isMultiAxis()) {
      cancelTransformation();
      abc = _section.getInitialToolAxisABC();
      if (_setWorkPlane) {
        if (activeG254) {
          writeBlock(gFormat.format(255)); // cancel DWO
          activeG254 = false;
        }
        if (!retracted) {
          writeRetract(Z);
        }
        forceWorkPlane();
        onCommand(COMMAND_UNLOCK_MULTI_AXIS);
        gMotionModal.reset();
        writeBlock(
          gMotionModal.format(0),
          conditional(machineConfiguration.isMachineCoordinate(0), "A" + abcFormat.format(abc.x)),
          conditional(machineConfiguration.isMachineCoordinate(1), "B" + abcFormat.format(abc.y)),
          conditional(machineConfiguration.isMachineCoordinate(2), "C" + abcFormat.format(abc.z))
        );
      }
    } else {
      abc = getWorkPlaneMachineABC(_section.workPlane, _setWorkPlane);
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

  if (activeG254) {
    activeG254 = false;
    writeBlock(gFormat.format(255)); // cancel DWO
  }

  gMotionModal.reset();
  skipBlock = _skipBlock;
  writeBlock(
    gMotionModal.format(0),
    conditional(machineConfiguration.isMachineCoordinate(0), "A" + abcFormat.format(abc.x)),
    conditional(machineConfiguration.isMachineCoordinate(1), "B" + abcFormat.format(abc.y)),
    conditional(machineConfiguration.isMachineCoordinate(2), "C" + abcFormat.format(abc.z))
  );
  
  skipBlock = _skipBlock;
  onCommand(COMMAND_LOCK_MULTI_AXIS);

  if (properties.useDWO &&
      (abcFormat.isSignificant(abc.x) || abcFormat.isSignificant(abc.y) || abcFormat.isSignificant(abc.z))) {
    skipBlock = _skipBlock;
    activeG254 = true;
    writeBlock(gFormat.format(254)); // enable DWO
  }

  currentWorkPlaneABC = abc;
}

var closestABC = false; // choose closest machine angles
var currentMachineABC;

function getWorkPlaneMachineABC(workPlane, _setWorkPlane) {
  var W = workPlane; // map to global frame

  var abc = machineConfiguration.getABC(W);
  if (closestABC) {
    if (currentMachineABC) {
      abc = machineConfiguration.remapToABC(abc, currentMachineABC);
    } else {
      abc = machineConfiguration.getPreferredABC(abc);
    }
  } else {
    abc = machineConfiguration.getPreferredABC(abc);
  }
  
  try {
    abc = machineConfiguration.remapABC(abc);
    if (_setWorkPlane) {
      currentMachineABC = abc;
    }
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

function isProbeOperation() {
  return hasParameter("operation-strategy") && ((getParameter("operation-strategy") == "probe" || getParameter("operation-strategy") == "probe_geometry"));
}

function isInspectionOperation(section) {
  return section.hasParameter("operation-strategy") && (section.getParameter("operation-strategy") == "inspectSurface");
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
    }
    break;
  default:
    expandManualNC(command, value);
  }
}

function onParameter(name, value) {
  if (name == "probe-output-work-offset") {
    probeOutputWorkOffset = (value > 0) ? value : 1;
  } else if (name == "action") {
    if (String(value).toUpperCase() == "CYCLE_REVERSAL") {
      cycleReverse = true;
    }
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

      if (!properties.useM130PartImages || !permittedExtension) {
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
  if (currentSection.isPatterned && currentSection.isPatterned() && properties.useSubroutinePatterns) {
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
        patternType: SUB_PATTERN,
        patternId: currentPattern,
        subProgram: currentSubprogram,
        validPattern: usePattern,
        initialPosition: _initialPosition,
        finalPosition: _initialPosition
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
  if (!usePattern && properties.useSubroutineCycles && currentSection.doesStrictCycle &&
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
        patternType: SUB_CYCLE,
        patternId: currentPattern,
        subProgram: currentSubprogram,
        validPattern: usePattern,
        initialPosition: _initialPosition,
        finalPosition: finalPosition
      });
    }
    cycleSubprogramIsActive = usePattern;
  }

  // Output each operation as a subprogram
  if (!usePattern && properties.useSubroutines) {
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
  saveShowSequenceNumbers = properties.showSequenceNumbers;
  properties.showSequenceNumbers = false;
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
  properties.showSequenceNumbers = saveShowSequenceNumbers;
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

          if (areSpatialBoxesSame(masterPosition, patternPosition) && areSpatialBoxesSame(masterBox, patternBox)) {
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
  _output = _incr ? createIncrementalVariable({prefix: _prefix}, _format) : createVariable({prefix: _prefix}, _format);
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

  var insertToolCall = isFirstSection() ||
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

  operationNeedsSafeStart = properties.safeStartAllOperations && !isFirstSection();
  
  if (insertToolCall || operationNeedsSafeStart) {
    nullProbeAngle(true);
    if (properties.fastToolChange && !isProbeOperation()) {
      currentCoolantMode = COOLANT_OFF;
    } else if (insertToolCall) { // no coolant off command if safe start operation
      onCommand(COMMAND_COOLANT_OFF);
    }
  }

  if ((insertToolCall && !properties.fastToolChange) || newWorkOffset || newWorkPlane || toolChecked) {
    
    // stop spindle before retract during tool change
    if (insertToolCall && !isFirstSection() && !toolChecked && !properties.fastToolChange) {
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
  
  if (properties.showNotes && hasParameter("notes")) {
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

  defineWorkPlane(currentSection, false);
  var initialPosition = getFramePosition(currentSection.getInitialPosition());
  forceAny();
  if (!retracted && !insertToolCall) {
    if (getCurrentPosition().z < initialPosition.z) {
      writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
      zIsOutput = true;
    }
  }

  if (operationNeedsSafeStart) {
    if (!retracted) {
      skipBlock = true;
      writeRetract(Z);
    }
  }
  
  if (insertToolCall || operationNeedsSafeStart) {
    if (insertToolCall) {
      forceWorkPlane();
    }

    if (properties.useM130ToolImages) {
      writeBlock(mFormat.format(130), "(tool" + tool.number + ".png)");
    }

    if (!isFirstSection() && properties.optionalStop && insertToolCall) {
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
      writeToolMeasureBlock(tool);
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
  var spindleChanged = !isInspectionOperation(currentSection) && !isProbeOperation() &&
    (insertToolCall || forceSpindleSpeed || isFirstSection() ||
    (rpmFormat.areDifferent(spindleSpeed, sOutput.getCurrent())) ||
    (tool.clockwise != getPreviousSection().getTool().clockwise));
  if (spindleChanged || operationNeedsSafeStart) {
    forceSpindleSpeed = false;

    if (spindleSpeed < 1) {
      error(localize("Spindle speed out of range."));
      return;
    }
    if (spindleSpeed > maximumSpindleRPM) {
      warning(localize("Spindle speed exceeds maximum value."));
    }
    skipBlock = !spindleChanged;
    writeBlock(
      sOutput.format(spindleSpeed), mFormat.format(tool.clockwise ? 3 : 4)
    );
  }

  previewImage();
  
  if (properties.useParametricFeed &&
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
  var workOffset = currentSection.workOffset;
  if (workOffset == 0) {
    warningOnce(localize("Work offset has not been specified. Using G54 as WCS."), WARNING_WORK_OFFSET);
    workOffset = 1;
  }
  if (workOffset > 0) {
    if (workOffset > 6) {
      var code = workOffset - 6;
      if (code > 99) {
        error(localize("Work offset out of range."));
        return;
      }
      if (workOffset != currentWorkOffset) {
        if (insertToolCall) {
          forceWorkPlane();
        }
        writeBlock(gFormat.format(154), "P" + code);
        currentWorkOffset = workOffset;
      }
    } else {
      if (workOffset != currentWorkOffset) {
        if (insertToolCall) {
          forceWorkPlane();
        }
        writeBlock(gFormat.format(53 + workOffset)); // G54->G59
        currentWorkOffset = workOffset;
      }
    }
  }
  
  if (newWorkPlane || (insertToolCall && !retracted)) { // go to home position for safety
    if (!retracted) {
      writeRetract(Z);
    }
    if (properties.forceHomeOnIndexing && machineConfiguration.isMultiAxisConfiguration()) {
      writeRetract(X, Y);
    }
  }

  if (g68RotationMode != 0 && (insertToolCall || operationNeedsSafeStart || gRotationModal.getCurrent() == 69)) {
    setProbingAngle();
  }
 
  // Unwind axis if previous section was Multi-Axis
  if (!isFirstSection() && getPreviousSection().isMultiAxis() && (hasC || properties.machineModel.indexOf("umc") != -1)) {
    writeBlock(gFormat.format(28), gAbsIncModal.format(91), "C" + abcFormat.format(0));
    writeBlock(gAbsIncModal.format(90));
    currentMachineABC.setZ(0);
  }
  
  if (newWorkOffset) {
    forceWorkPlane();
  }
  
  var abc = defineWorkPlane(currentSection, true);

  // set coolant after we have positioned at Z
  setCoolant(tool.coolant);

  gMotionModal.reset();

  if (properties.useG187) {
    writeG187();
  }

  if (insertToolCall || retracted || operationNeedsSafeStart ||
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
      if ((currentSection.getOptimizedTCPMode() == 0) && useDwoForPositioning && currentSection.isMultiAxis()) {
        var O = machineConfiguration.getOrientation(abc);
        var initialPositionDWO = O.getTransposed().multiply(getGlobalPosition(currentSection.getInitialPosition()));
        // writeComment("PREPOSITIONING START");
        skipBlock = _skipBlock;
        writeBlock(gFormat.format(254));
        skipBlock = _skipBlock;
        writeBlock(gAbsIncModal.format(90), gMotionModal.format(0), xOutput.format(initialPositionDWO.x), yOutput.format(initialPositionDWO.y));
        skipBlock = _skipBlock;
        writeBlock(gFormat.format(255));
        // writeComment("PREPOSITIONING END");
        skipBlock = _skipBlock;
        writeBlock(
          gMotionModal.format(0),
          conditional(!currentSection.isMultiAxis() || (currentSection.getOptimizedTCPMode() == 1), gFormat.format(43)),
          conditional(currentSection.isMultiAxis() && (currentSection.getOptimizedTCPMode() == 0), gFormat.format(234)),
          xOutput.format(initialPosition.x), yOutput.format(initialPosition.y), zOutput.format(initialPosition.z),
          hFormat.format(lengthOffset)
        );
      } else {
        skipBlock = _skipBlock;
        writeBlock(gAbsIncModal.format(90), gMotionModal.format(0), xOutput.format(initialPosition.x), yOutput.format(initialPosition.y));
        skipBlock = _skipBlock;
        writeBlock(
          gMotionModal.format(0),
          conditional(!currentSection.isMultiAxis() || (currentSection.getOptimizedTCPMode() == 1), gFormat.format(43)),
          conditional(currentSection.isMultiAxis() && (currentSection.getOptimizedTCPMode() == 0), gFormat.format(234)),
          zOutput.format(initialPosition.z),
          hFormat.format(lengthOffset)
        );
      }
    } else {
      skipBlock = _skipBlock;
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(0),
        conditional(!currentSection.isMultiAxis() || (currentSection.getOptimizedTCPMode() == 1), gFormat.format(43)),
        conditional(currentSection.isMultiAxis() && (currentSection.getOptimizedTCPMode() == 0), gFormat.format(234)),
        xOutput.format(initialPosition.x),
        yOutput.format(initialPosition.y),
        zOutput.format(initialPosition.z),
        hFormat.format(lengthOffset)
      );
    }
    zIsOutput = true;
    if (_skipBlock) {
      forceXYZ();
      var x = xOutput.format(initialPosition.x);
      var y = yOutput.format(initialPosition.y);
      if (!properties.useG0 && x && y) {
        // axes are not synchronized
        writeBlock(gAbsIncModal.format(90), gMotionModal.format(1), x, y, getFeed(highFeedrate));
      } else {
        writeBlock(gAbsIncModal.format(90), gMotionModal.format(0), x, y);
      }
    }

    gMotionModal.reset();
  } else {
    var x = xOutput.format(initialPosition.x);
    var y = yOutput.format(initialPosition.y);
    if (!properties.useG0 && x && y) {
      // axes are not synchronized
      writeBlock(gAbsIncModal.format(90), gMotionModal.format(1), x, y, getFeed(highFeedrate));
    } else {
      writeBlock(gAbsIncModal.format(90), gMotionModal.format(0), x, y);
    }
  }

  if (insertToolCall || operationNeedsSafeStart) {
    if (properties.preloadTool) {
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
    if (g68RotationMode != 0) {
      error(localize("You cannot probe while G68 Rotation is in effect."));
      return;
    }
    angularProbingMode = getAngularProbingMode();
    writeBlock(gFormat.format(65), "P" + 9832); // spin the probe on
  }
  if (isInspectionOperation(currentSection) && (typeof inspectionProcessSectionStart == "function")) {
    inspectionProcessSectionStart();
  }
  // define subprogram
  subprogramDefine(initialPosition, abc, retracted, zIsOutput);
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
  forceXYZ(); // force xyz on first drill hole of any cycle
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

function getRotationalAxis() {
  if (machineConfiguration.getAxisU().isEnabled() &&
      isSameDirection((machineConfiguration.getAxisU().getAxis()).getAbsolute(), new Vector(0, 0, 1)) &&
      machineConfiguration.getAxisU().isTable()) {
    return (machineConfiguration.getAxisU().getCoordinate());
  } else if (machineConfiguration.getAxisV().isEnabled() &&
      isSameDirection((machineConfiguration.getAxisV().getAxis()).getAbsolute(), new Vector(0, 0, 1)) &&
      machineConfiguration.getAxisV().isTable()) {
    return (machineConfiguration.getAxisV().getCoordinate());
  } else if (machineConfiguration.getAxisW().isEnabled() &&
      isSameDirection((machineConfiguration.getAxisW().getAxis()).getAbsolute(), new Vector(0, 0, 1)) &&
      machineConfiguration.getAxisW().isTable()) {
    return (machineConfiguration.getAxisW().getCoordinate());
  } else {
    return -1;
  }
}

/**
  Determine if angular probing is supported.
*/
var rotationalAxis = -1;
var isWCSProbing = false;

function getAngularProbingMode() {
  rotationalAxis = getRotationalAxis();
  isWCSProbing = (hasParameter("operation-strategy") && (getParameter("operation-strategy") == "probe"));
  if (rotationalAxis != -1) {
    return (ANGLE_PROBE_USE_CAXIS);
  } else if (machineConfiguration.getNumberOfAxes() < 5 || is3D()) {
    return (ANGLE_PROBE_USE_ROTATION);
  } else {
    return (ANGLE_PROBE_NOT_SUPPORTED);
  }
}

/**
  Output rotation offset based on angular probing cycle.
*/
function setProbingAngle() {
  if (((g68RotationMode == 1) || (g68RotationMode == 2)) && isWCSProbing) { // Rotate coordinate system for Angle Probing
    if (angularProbingMode == ANGLE_PROBE_USE_ROTATION) {
      gRotationModal.reset();
      gAbsIncModal.reset();
      var xCode = (g68RotationMode == 1) ? "X0" : "X[#185]";
      var yCode = (g68RotationMode == 1) ? "Y0" : "Y[#186]";
      writeBlock(gRotationModal.format(68), gAbsIncModal.format(90), xCode, yCode, "R[#194]");
    } else if (angularProbingMode == ANGLE_PROBE_USE_CAXIS) {
      var workOffset = probeOutputWorkOffset ? probeOutputWorkOffset : currentWorkOffset;
      if (workOffset > 6) {
        error(localize("Angle Probing only supports work offsets 1-6."));
        return;
      }
      var param = 5200 + workOffset * 20 + rotationalAxis + 4;
      writeBlock("#" + param + "=" + "[#" + param + " + #194]");
      g68RotationMode = 0;
    } else {
      error(localize("Angular Probing is not supported for this machine configuration."));
      return;
    }
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

/**
  Null the probing angle when needed.
*/
function nullProbeAngle(force) {
  var cycleType = currentSection.getFirstCycle();
  if (g68RotationMode != 0) {
    writeBlock(gRotationModal.format(69));
  } else if (force && cycleType.indexOf("probing") != -1) {
    gRotationModal.reset();
    forceXYZ();
    writeBlock(gRotationModal.format(69));
  }
}

function onCyclePoint(x, y, z) {
  if (isInspectionOperation(currentSection) && (typeof inspectionCycleInspect == "function")) {
    inspectionCycleInspect(cycle, x, y, z);
    return;
  }
  if (!isSameDirection(getRotation().forward, new Vector(0, 0, 1))) {
    expandCyclePoint(x, y, z);
    return;
  }
  var probeWorkOffsetCode;
  if (isProbeOperation()) {
    if (!isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1)) && (!cycle.probeMode || (cycle.probeMode == 0)) && properties.useDWO) {
      error(localize("Your machine does not support the selected probing operation with DWO enabled."));
      return;
    }
    protectedProbeMove(cycle, x, y, z);

    var workOffset = probeOutputWorkOffset ? probeOutputWorkOffset : currentWorkOffset;
    if (workOffset > 99) {
      error(localize("Work offset is out of range."));
      return;
    } else if (workOffset > 6) {
      probeWorkOffsetCode = "154." + probe154Format.format(workOffset - 6);
    } else {
      probeWorkOffsetCode = workOffset + "."; // G54->G59
    }
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
      F = (properties.useG95forTapping ? tool.getThreadPitch() : tappingFPM);
      if (properties.useG95forTapping) {
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
      F = (properties.useG95forTapping ? tool.getThreadPitch() : tappingFPM);
      if (properties.useG95forTapping) {
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
      F = (properties.useG95forTapping ? tool.getThreadPitch() : tappingFPM);
      if (properties.useG95forTapping) {
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
      F = (properties.useG95forTapping ? tool.getThreadPitch() : tappingFPM);
      if (properties.useG95forTapping) {
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
            pitchOutput.format(F)
          );
        } else {
          var position;
          var depth;
          switch (gPlaneModal.getCurrent()) {
          case 17:
            xOutput.reset();
            position = xOutput.format(x);
            depth = "Z" + xyzFormat.format(u);
            break;
          case 18:
            zOutput.reset();
            position = zOutput.format(z);
            depth = "Y" + xyzFormat.format(u);
            break;
          case 19:
            yOutput.reset();
            position = yOutput.format(y);
            depth = "X" + xyzFormat.format(u);
            break;
          }
          writeBlock(conditional(u <= cycle.bottom, gRetractModal.format(98)), position, depth);
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
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-y":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9811,
        "Y" + xyzFormat.format(y + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-z":
      protectedProbeMove(cycle, x, y, Math.min(z - cycle.depth + cycle.probeClearance, cycle.retract));
      writeBlock(
        gFormat.format(65), "P" + 9811,
        "Z" + xyzFormat.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, probeWorkOffsetCode)
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
        getProbingArguments(cycle, probeWorkOffsetCode)
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
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-x-channel":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "X" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        // not required "R" + xyzFormat.format(cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
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
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-y-channel":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Y" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        // not required "R" + xyzFormat.format(cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
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
        getProbingArguments(cycle, probeWorkOffsetCode)
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
        getProbingArguments(cycle, probeWorkOffsetCode)
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
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-xy-circular-hole":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9814,
        "D" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        // not required "R" + xyzFormat.format(cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
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
        getProbingArguments(cycle, probeWorkOffsetCode)
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
        getProbingArguments(cycle, probeWorkOffsetCode)
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
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-xy-rectangular-hole":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "X" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        // not required "R" + xyzFormat.format(-cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Y" + xyzFormat.format(cycle.width2),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        // not required "R" + xyzFormat.format(-cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
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
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Z" + xyzFormat.format(z - cycle.depth),
        "Y" + xyzFormat.format(cycle.width2),
        "R" + xyzFormat.format(cycle.probeClearance),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, probeWorkOffsetCode)
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
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Z" + xyzFormat.format(z - cycle.depth),
        "Y" + xyzFormat.format(cycle.width2),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(-cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-xy-inner-corner":
      var cornerX = x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2);
      var cornerY = y + approach(cycle.approach2) * (cycle.probeClearance + tool.diameter / 2);
      var cornerI = 0;
      var cornerJ = 0;
      if (cycle.probeSpacing && (cycle.probeSpacing != 0)) {
        cornerI = cycle.probeSpacing;
        cornerJ = cycle.probeSpacing;
      }
      if ((cornerI != 0) && (cornerJ != 0)) {
        g68RotationMode = 2;
      }
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9815, xOutput.format(cornerX), yOutput.format(cornerY),
        conditional(cornerI != 0, "I" + xyzFormat.format(cornerI)),
        conditional(cornerJ != 0, "J" + xyzFormat.format(cornerJ)),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        conditional((g68RotationMode == 0) || (angularProbingMode == ANGLE_PROBE_USE_CAXIS), getProbingArguments(cycle, probeWorkOffsetCode))
      );
      break;
    case "probing-xy-outer-corner":
      var cornerX = x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2);
      var cornerY = y + approach(cycle.approach2) * (cycle.probeClearance + tool.diameter / 2);
      var cornerI = 0;
      var cornerJ = 0;
      if (cycle.probeSpacing && (cycle.probeSpacing != 0)) {
        cornerI = cycle.probeSpacing;
        cornerJ = cycle.probeSpacing;
      }
      if ((cornerI != 0) && (cornerJ != 0)) {
        g68RotationMode = 2;
      }
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9816, xOutput.format(cornerX), yOutput.format(cornerY),
        conditional(cornerI != 0, "I" + xyzFormat.format(cornerI)),
        conditional(cornerJ != 0, "J" + xyzFormat.format(cornerJ)),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        conditional((g68RotationMode == 0) || (angularProbingMode == ANGLE_PROBE_USE_CAXIS), getProbingArguments(cycle, probeWorkOffsetCode))
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
      g68RotationMode = 1;
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
      g68RotationMode = 1;
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
        error(localize("Update tool action is not supported with this cycle"));
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
        error(localize("Update tool action is not supported with this cycle"));
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

function getProbingArguments(cycle, probeWorkOffsetCode) {
  var probeWCS = hasParameter("operation-strategy") && (getParameter("operation-strategy") == "probe");
  return [
    (cycle.angleAskewAction == "stop-message" ? "B" + xyzFormat.format(cycle.toleranceAngle ? cycle.toleranceAngle : 0) : undefined),
    ((cycle.updateToolWear && cycle.toolWearErrorCorrection < 100) ? "F" + xyzFormat.format(cycle.toolWearErrorCorrection ? cycle.toolWearErrorCorrection / 100 : 100) : undefined),
    (cycle.wrongSizeAction == "stop-message" ? "H" + xyzFormat.format(cycle.toleranceSize ? cycle.toleranceSize : 0) : undefined),
    (cycle.outOfPositionAction == "stop-message" ? "M" + xyzFormat.format(cycle.tolerancePosition ? cycle.tolerancePosition : 0) : undefined),
    ((cycle.updateToolWear && cycleType == "probing-z") ? "T" + xyzFormat.format(cycle.toolLengthOffset) : undefined),
    ((cycle.updateToolWear && cycleType !== "probing-z") ? "T" + xyzFormat.format(cycle.toolDiameterOffset) : undefined),
    (cycle.updateToolWear ? "V" + xyzFormat.format(cycle.toolWearUpdateThreshold ? cycle.toolWearUpdateThreshold : 0) : undefined),
    (cycle.printResults ? "W" + xyzFormat.format(1 + cycle.incrementComponent) : undefined), // 1 for advance feature, 2 for reset feature count and advance component number. first reported result in a program should use W2.
    conditional(probeWorkOffsetCode && probeWCS, "S" + probeWorkOffsetCode)
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
      writeBlock(gCycleModal.format(80), conditional(properties.useG95forTapping, gFeedModeModal.format(94)));
      gMotionModal.reset();
    }
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
    if (!properties.useG0 && (((x ? 1 : 0) + (y ? 1 : 0) + (z ? 1 : 0)) > 1)) {
      // axes are not synchronized
      writeBlock(gMotionModal.format(1), x, y, z, getFeed(highFeedrate));
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
      writeBlock(gPlaneModal.format(17));
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
  if (!currentSection.isOptimizedForMachine()) {
    error(localize("This post configuration has not been customized for 5-axis simultaneous toolpath."));
    return;
  }
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation mode cannot be changed at rapid traversal."));
    return;
  }

  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = aOutput.format(_a);
  var b = bOutput.format(_b);
  var c = cOutput.format(_c);

  if (!properties.useG0 && (((x ? 1 : 0) + (y ? 1 : 0) + (z ? 1 : 0) + (a ? 1 : 0) + (b ? 1 : 0) + (c ? 1 : 0)) > 1)) { // required for multi-axis
    // axes are not synchronized
    writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), x, y, z, a, b, c, getFeed(highFeedrate));
  } else {
    if (x || y || z || a || b || c) {
      writeBlock(gMotionModal.format(0), x, y, z, a, b, c);
      forceFeed();
    }
  }
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed) {
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
  
  // get feedrate number
  var f = {frn:0, fmode:0};
  if ((a || b || c) && !properties.useTCPC) {
    f = getMultiaxisFeed(_x, _y, _z, _a, _b, _c, feed);
    if (properties.useDPMFeeds) {
      f.frn = feedOutput.format(f.frn);
    } else {
      f.frn = inverseTimeOutput.format(f.frn);
    }
  } else {
    f.frn = feedOutput.format(feed);
    f.fmode = 94;
  }

  if (x || y || z || a || b || c) {
    writeBlock(gFeedModeModal.format(f.fmode), gMotionModal.format(1), x, y, z, a, b, c, f.frn);
  } else if (f.frn) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      feedOutput.reset(); // force feed on next line
    } else {
      writeBlock(gFeedModeModal.format(f.fmode), gMotionModal.format(1), f.frn);
    }
  }
}

// Start of multi-axis feedrate logic
/***** Be sure to add 'useInverseTime' to post properties if necessary. *****/
/***** 'inverseTimeOutput' should be defined if Inverse Time feedrates are supported. *****/
/***** 'previousABC' can be added throughout to maintain previous rotary positions. Required for Mill/Turn machines. *****/
/***** 'headOffset' should be defined when a head rotary axis is defined. *****/
/***** The feedrate mode must be included in motion block output (linear, circular, etc.) for Inverse Time feedrate support. *****/
var dpmBPW = 1.0; // ratio of rotary accuracy to linear accuracy for DPM calculations
var inverseTimeUnits = 1.0; // 1.0 = minutes, 60.0 = seconds
var maxInverseTime = 9999; // maximum value to output for Inverse Time feeds
var maxDPM = 9999.99; // maximum value to output for DPM feeds
var previousDPMFeed = 0; // previously output DPM feed
var dpmFeedToler = 0.5; // tolerance to determine when the DPM feed has changed
// var previousABC = new Vector(0, 0, 0); // previous ABC position if maintained in post, don't define if not used
var forceOptimized = undefined; // used to override optimized-for-angles points (XZC-mode)
  
/** Calculate the multi-axis feedrate number. */
function getMultiaxisFeed(_x, _y, _z, _a, _b, _c, feed) {
  var f = {frn:0, fmode:0};
  if (feed <= 0) {
    error(localize("Feedrate is less than or equal to 0."));
    return f;
  }
    
  var length = getMoveLength(_x, _y, _z, _a, _b, _c);
    
  if (!properties.useDPMFeeds) { // inverse time
    f.frn = getInverseTime(length.tool, feed);
    f.fmode = 93;
    feedOutput.reset();
  } else { // degrees per minute
    f.frn = getFeedDPM(length, feed);
    f.fmode = 94;
  }
  return f;
}
  
/** Returns point optimization mode. */
function getOptimizedMode() {
  if (forceOptimized != undefined) {
    return forceOptimized;
  }
  // return (currentSection.getOptimizedTCPMode() != 0); // TAG:doesn't return correct value
  return true; // always return false for non-TCP based heads
}
    
/** Calculate the DPM feedrate number. */
function getFeedDPM(_moveLength, _feed) {
  if ((_feed == 0) || (_moveLength.tool < 0.0001) || (toDeg(_moveLength.abcLength) < 0.0005)) {
    previousDPMFeed = 0;
    return _feed;
  }
  var moveTime = _moveLength.tool / _feed;
  if (moveTime == 0) {
    previousDPMFeed = 0;
    return _feed;
  }
  
  var dpmFeed;
  var tcp = false; // !getOptimizedMode() && (forceOptimized == undefined);   // set to false for rotary heads
  if (tcp) { // TCP mode is supported, output feed as FPM
    dpmFeed = _feed;
  } else if (false) { // standard DPM
    dpmFeed = Math.min(toDeg(_moveLength.abcLength) / moveTime, maxDPM);
    if (Math.abs(dpmFeed - previousDPMFeed) < dpmFeedToler) {
      dpmFeed = previousDPMFeed;
    }
  } else if (true) { // combination FPM/DPM
    var length = Math.sqrt(Math.pow(_moveLength.xyzLength, 2.0) + Math.pow((toDeg(_moveLength.abcLength) * dpmBPW), 2.0));
    dpmFeed = Math.min((length / moveTime), maxDPM);
    if (Math.abs(dpmFeed - previousDPMFeed) < dpmFeedToler) {
      dpmFeed = previousDPMFeed;
    }
  } else { // machine specific calculation
    dpmFeed = _feed;
  }
  previousDPMFeed = dpmFeed;
  return dpmFeed;
}
  
/** Calculate the Inverse time feedrate number. */
function getInverseTime(_length, _feed) {
  var inverseTime;
  if (_length < 1.e-6) { // tool doesn't move
    if (typeof maxInverseTime === "number") {
      inverseTime = maxInverseTime;
    } else {
      inverseTime = 999999;
    }
  } else {
    inverseTime = _feed / _length / inverseTimeUnits;
    if (typeof maxInverseTime === "number") {
      if (inverseTime > maxInverseTime) {
        inverseTime = maxInverseTime;
      }
    }
  }
  return inverseTime;
}
  
/** Calculate radius for each rotary axis. */
function getRotaryRadii(startTool, endTool, startABC, endABC) {
  var radii = new Vector(0, 0, 0);
  var startRadius;
  var endRadius;
  var axis = new Array(machineConfiguration.getAxisU(), machineConfiguration.getAxisV(), machineConfiguration.getAxisW());
  for (var i = 0; i < 3; ++i) {
    if (axis[i].isEnabled()) {
      var startRadius = getRotaryRadius(axis[i], startTool, startABC);
      var endRadius = getRotaryRadius(axis[i], endTool, endABC);
      radii.setCoordinate(axis[i].getCoordinate(), Math.max(startRadius, endRadius));
    }
  }
  return radii;
}
  
/** Calculate the distance of the tool position to the center of a rotary axis. */
function getRotaryRadius(axis, toolPosition, abc) {
  if (!axis.isEnabled()) {
    return 0;
  }
  
  var direction = axis.getEffectiveAxis();
  var normal = direction.getNormalized();
  // calculate the rotary center based on head/table
  var center;
  var radius;
  if (axis.isHead()) {
    var pivot;
    if (typeof headOffset === "number") {
      pivot = headOffset;
    } else {
      pivot = tool.getBodyLength();
    }
    if (axis.getCoordinate() == machineConfiguration.getAxisU().getCoordinate()) { // rider
      center = Vector.sum(toolPosition, Vector.product(machineConfiguration.getDirection(abc), pivot));
      center = Vector.sum(center, axis.getOffset());
      radius = Vector.diff(toolPosition, center).length;
    } else { // carrier
      var angle = abc.getCoordinate(machineConfiguration.getAxisU().getCoordinate());
      radius = Math.abs(pivot * Math.sin(angle));
      radius += axis.getOffset().length;
    }
  } else {
    center = axis.getOffset();
    var d1 = toolPosition.x - center.x;
    var d2 = toolPosition.y - center.y;
    var d3 = toolPosition.z - center.z;
    var radius = Math.sqrt(
      Math.pow((d1 * normal.y) - (d2 * normal.x), 2.0) +
        Math.pow((d2 * normal.z) - (d3 * normal.y), 2.0) +
        Math.pow((d3 * normal.x) - (d1 * normal.z), 2.0)
    );
  }
  return radius;
}
    
/** Calculate the linear distance based on the rotation of a rotary axis. */
function getRadialDistance(radius, startABC, endABC) {
  // calculate length of radial move
  var delta = Math.abs(endABC - startABC);
  if (delta > Math.PI) {
    delta = 2 * Math.PI - delta;
  }
  var radialLength = (2 * Math.PI * radius) * (delta / (2 * Math.PI));
  return radialLength;
}
    
/** Calculate tooltip, XYZ, and rotary move lengths. */
function getMoveLength(_x, _y, _z, _a, _b, _c) {
  // get starting and ending positions
  var moveLength = {};
  var startTool;
  var endTool;
  var startXYZ;
  var endXYZ;
  var startABC;
  if (typeof previousABC !== "undefined") {
    startABC = new Vector(previousABC.x, previousABC.y, previousABC.z);
  } else {
    startABC = getCurrentDirection();
  }
  var endABC = new Vector(_a, _b, _c);
      
  if (!getOptimizedMode()) { // calculate XYZ from tool tip
    startTool = getCurrentPosition();
    endTool = new Vector(_x, _y, _z);
    startXYZ = startTool;
    endXYZ = endTool;
  
    // adjust points for tables
    if (!machineConfiguration.getTableABC(startABC).isZero() || !machineConfiguration.getTableABC(endABC).isZero()) {
      startXYZ = machineConfiguration.getOrientation(machineConfiguration.getTableABC(startABC)).getTransposed().multiply(startXYZ);
      endXYZ = machineConfiguration.getOrientation(machineConfiguration.getTableABC(endABC)).getTransposed().multiply(endXYZ);
    }
  
    // adjust points for heads
    if (machineConfiguration.getAxisU().isEnabled() && machineConfiguration.getAxisU().isHead()) {
      if (typeof getOptimizedHeads === "function") { // use post processor function to adjust heads
        startXYZ = getOptimizedHeads(startXYZ.x, startXYZ.y, startXYZ.z, startABC.x, startABC.y, startABC.z);
        endXYZ = getOptimizedHeads(endXYZ.x, endXYZ.y, endXYZ.z, endABC.x, endABC.y, endABC.z);
      } else { // guess at head adjustments
        var startDisplacement = machineConfiguration.getDirection(startABC);
        startDisplacement.multiply(headOffset);
        var endDisplacement = machineConfiguration.getDirection(endABC);
        endDisplacement.multiply(headOffset);
        startXYZ = Vector.sum(startTool, startDisplacement);
        endXYZ = Vector.sum(endTool, endDisplacement);
      }
    }
  } else { // calculate tool tip from XYZ, heads are always programmed in TCP mode, so not handled here
    startXYZ = getCurrentPosition();
    endXYZ = new Vector(_x, _y, _z);
    startTool = machineConfiguration.getOrientation(machineConfiguration.getTableABC(startABC)).multiply(startXYZ);
    endTool = machineConfiguration.getOrientation(machineConfiguration.getTableABC(endABC)).multiply(endXYZ);
  }
  
  // calculate axes movements
  moveLength.xyz = Vector.diff(endXYZ, startXYZ).abs;
  moveLength.xyzLength = moveLength.xyz.length;
  moveLength.abc = Vector.diff(endABC, startABC).abs;
  for (var i = 0; i < 3; ++i) {
    if (moveLength.abc.getCoordinate(i) > Math.PI) {
      moveLength.abc.setCoordinate(i, 2 * Math.PI - moveLength.abc.getCoordinate(i));
    }
  }
  moveLength.abcLength = moveLength.abc.length;
  
  // calculate radii
  moveLength.radius = getRotaryRadii(startTool, endTool, startABC, endABC);
    
  // calculate the radial portion of the tool tip movement
  var radialLength = Math.sqrt(
    Math.pow(getRadialDistance(moveLength.radius.x, startABC.x, endABC.x), 2.0) +
      Math.pow(getRadialDistance(moveLength.radius.y, startABC.y, endABC.y), 2.0) +
      Math.pow(getRadialDistance(moveLength.radius.z, startABC.z, endABC.z), 2.0)
  );
    
  // calculate the tool tip move length
  // tool tip distance is the move distance based on a combination of linear and rotary axes movement
  moveLength.tool = moveLength.xyzLength + radialLength;
  
  // debug
  if (false) {
    writeComment("DEBUG - tool   = " + moveLength.tool);
    writeComment("DEBUG - xyz    = " + moveLength.xyz);
    var temp = Vector.product(moveLength.abc, 180 / Math.PI);
    writeComment("DEBUG - abc    = " + temp);
    writeComment("DEBUG - radius = " + moveLength.radius);
  }
  return moveLength;
}
// End of multi-axis feedrate logic

// Start of onRewindMachine logic
/***** Be sure to add 'safeRetractDistance' to post properties. *****/
var performRewinds = false; // enables the onRewindMachine logic
var safeRetractFeed = (unit == IN) ? 20 : 500;
var safePlungeFeed = (unit == IN) ? 10 : 250;
var stockAllowance = (unit == IN) ? 0.1 : 2.5;

/** Allow user to override the onRewind logic. */
function onRewindMachineEntry(_a, _b, _c) {
  return false;
}

/** Retract to safe position before indexing rotaries. */
function moveToSafeRetractPosition(isRetracted) {
  if (properties.useG28) {
    if (!isRetracted) {
      writeRetract(Z);
    }
    if (properties.forceHomeOnIndexing) {
      writeRetract(X, Y);
    }
  } else {
    if (!isRetracted) {
      writeRetract(Z);
    }
    if (properties.forceHomeOnIndexing) { // e.g. when machining very big parts
      writeRetract(X, Y);
    }
  }
}

/** Return from safe position after indexing rotaries. */
function returnFromSafeRetractPosition(position) {
  forceXYZ();
  xOutput.reset();
  yOutput.reset();
  zOutput.disable();
  onExpandedRapid(position.x, position.y, position.z);
  zOutput.enable();
  onExpandedRapid(position.x, position.y, position.z);
}

/** Determine if a point is on the correct side of a box side. */
function isPointInBoxSide(point, side) {
  var inBox = false;
  switch (side.side) {
  case "-X":
    if (point.x >= side.distance) {
      inBox = true;
    }
    break;
  case "-Y":
    if (point.y >= side.distance) {
      inBox = true;
    }
    break;
  case "-Z":
    if (point.z >= side.distance) {
      inBox = true;
    }
    break;
  case "X":
    if (point.x <= side.distance) {
      inBox = true;
    }
    break;
  case "Y":
    if (point.y <= side.distance) {
      inBox = true;
    }
    break;
  case "Z":
    if (point.z <= side.distance) {
      inBox = true;
    }
    break;
  }
  return inBox;
}

/** Intersect a point-vector with a plane. */
function intersectPlane(point, direction, plane) {
  var normal = new Vector(plane.x, plane.y, plane.z);
  var cosa = Vector.dot(normal, direction);
  if (Math.abs(cosa) <= 1.0e-6) {
    return undefined;
  }
  var distance = (Vector.dot(normal, point) - plane.distance) / cosa;
  var intersection = Vector.diff(point, Vector.product(direction, distance));
  
  if (!isSameDirection(Vector.diff(intersection, point).getNormalized(), direction)) {
    return undefined;
  }
  return intersection;
}

/** Intersect the point-vector with the stock box. */
function intersectStock(point, direction) {
  var stock = getWorkpiece();
  var sides = new Array(
    {x:1, y:0, z:0, distance:stock.lower.x, side:"-X"},
    {x:0, y:1, z:0, distance:stock.lower.y, side:"-Y"},
    {x:0, y:0, z:1, distance:stock.lower.z, side:"-Z"},
    {x:1, y:0, z:0, distance:stock.upper.x, side:"X"},
    {x:0, y:1, z:0, distance:stock.upper.y, side:"Y"},
    {x:0, y:0, z:1, distance:stock.upper.z, side:"Z"}
  );
  var intersection = undefined;
  var currentDistance = 999999.0;
  var localExpansion = -stockAllowance;
  for (var i = 0; i < sides.length; ++i) {
    if (i == 3) {
      localExpansion = -localExpansion;
    }
    if (isPointInBoxSide(point, sides[i])) { // only consider points within stock box
      var location = intersectPlane(point, direction, sides[i]);
      if (location != undefined) {
        if ((Vector.diff(point, location).length < currentDistance) || currentDistance == 0) {
          intersection = location;
          currentDistance = Vector.diff(point, location).length;
        }
      }
    }
  }
  return intersection;
}

/** Calculates the retract point using the stock box and safe retract distance. */
function getRetractPosition(currentPosition, currentDirection) {
  var retractPos = intersectStock(currentPosition, currentDirection);
  if (retractPos == undefined) {
    if (tool.getFluteLength() != 0) {
      retractPos = Vector.sum(currentPosition, Vector.product(currentDirection, tool.getFluteLength()));
    }
  }
  if ((retractPos != undefined) && properties.safeRetractDistance) {
    retractPos = Vector.sum(retractPos, Vector.product(currentDirection, properties.safeRetractDistance));
  }
  return retractPos;
}

/** Determines if the angle passed to onRewindMachine is a valid starting position. */
function isRewindAngleValid(_a, _b, _c) {
  // make sure the angles are different from the last output angles
  if (!abcFormat.areDifferent(getCurrentDirection().x, _a) &&
      !abcFormat.areDifferent(getCurrentDirection().y, _b) &&
      !abcFormat.areDifferent(getCurrentDirection().z, _c)) {
    error(
      localize("REWIND: Rewind angles are the same as the previous angles: ") +
      abcFormat.format(_a) + ", " + abcFormat.format(_b) + ", " + abcFormat.format(_c)
    );
    return false;
  }
  
  // make sure angles are within the limits of the machine
  var abc = new Array(_a, _b, _c);
  var ix = machineConfiguration.getAxisU().getCoordinate();
  var failed = false;
  if ((ix != -1) && !machineConfiguration.getAxisU().isSupported(abc[ix])) {
    failed = true;
  }
  ix = machineConfiguration.getAxisV().getCoordinate();
  if ((ix != -1) && !machineConfiguration.getAxisV().isSupported(abc[ix])) {
    failed = true;
  }
  ix = machineConfiguration.getAxisW().getCoordinate();
  if ((ix != -1) && !machineConfiguration.getAxisW().isSupported(abc[ix])) {
    failed = true;
  }
  if (failed) {
    error(
      localize("REWIND: Rewind angles are outside the limits of the machine: ") +
      abcFormat.format(_a) + ", " + abcFormat.format(_b) + ", " + abcFormat.format(_c)
    );
    return false;
  }
  
  return true;
}

function onRewindMachine(_a, _b, _c) {
  
  if (!performRewinds) {
    error(localize("REWIND: Rewind of machine is required for simultaneous multi-axis toolpath and has been disabled."));
    return;
  }
  
  // Allow user to override rewind logic
  if (onRewindMachineEntry(_a, _b, _c)) {
    return;
  }
  
  // Determine if input angles are valid or will cause a crash
  if (!isRewindAngleValid(_a, _b, _c)) {
    error(
      localize("REWIND: Rewind angles are invalid:") +
      abcFormat.format(_a) + ", " + abcFormat.format(_b) + ", " + abcFormat.format(_c)
    );
    return;
  }
  
  // Work with the tool end point
  if (currentSection.getOptimizedTCPMode() == 0) {
    currentTool = getCurrentPosition();
  } else {
    currentTool = machineConfiguration.getOrientation(getCurrentDirection()).multiply(getCurrentPosition());
  }
  var currentABC = getCurrentDirection();
  var currentDirection = machineConfiguration.getDirection(currentABC);
  
  // Calculate the retract position
  var retractPosition = getRetractPosition(currentTool, currentDirection);

  // Output warning that axes take longest route
  if (retractPosition == undefined) {
    error(localize("REWIND: Cannot calculate retract position."));
    return;
  } else {
    var text = localize("REWIND: Tool is retracting due to rotary axes limits.");
    warning(text);
    writeComment(text);
  }

  // Move to retract position
  var position;
  if (currentSection.getOptimizedTCPMode() == 0) {
    position = retractPosition;
  } else {
    position = machineConfiguration.getOrientation(getCurrentDirection()).getTransposed().multiply(retractPosition);
  }
  onExpandedLinear(position.x, position.y, position.z, safeRetractFeed);
  
  // Cancel TCP so that tool doesn't follow tables
  writeBlock(gFormat.format(49), formatComment("TCPC OFF"));

  //Position to safe machine position for rewinding axes
  moveToSafeRetractPosition(false);

  // Rotate axes to new position above reentry position
  xOutput.disable();
  yOutput.disable();
  zOutput.disable();
  onRapid5D(position.x, position.y, position.z, _a, _b, _c);
  xOutput.enable();
  yOutput.enable();
  zOutput.enable();

  // Reinstate TCP
  writeBlock(gFormat.format(234), hFormat.format(tool.lengthOffset), formatComment("TCPC ON"));

  // Move back to position above part
  if (currentSection.getOptimizedTCPMode() != 0) {
    position = machineConfiguration.getOrientation(new Vector(_a, _b, _c)).getTransposed().multiply(retractPosition);
  }
  returnFromSafeRetractPosition(position);

  // Plunge tool back to original position
  if (currentSection.getOptimizedTCPMode() != 0) {
    currentTool = machineConfiguration.getOrientation(new Vector(_a, _b, _c)).getTransposed().multiply(currentTool);
  }
  onExpandedLinear(currentTool.x, currentTool.y, currentTool.z, safePlungeFeed);
}
// End of onRewindMachine logic

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
    if (properties.useRadius || isHelical()) { // radius mode does not support full arcs
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
  } else if (!properties.useRadius) {
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
  if (Array.isArray(coolantCodes)) {
    if (singleLineCoolant) {
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
  if (isProbeOperation()) { // avoid coolant output for probing
    coolant = COOLANT_OFF;
  }
  if (coolant == currentCoolantMode) {
    if (operationNeedsSafeStart && coolant != COOLANT_OFF && !isSpecialCoolantActive) {
      isOptionalCoolant = true;
    } else {
      return undefined; // coolant is already active
    }
  }
  if ((coolant != COOLANT_OFF) && (currentCoolantMode != COOLANT_OFF) && !isOptionalCoolant) {
    if (Array.isArray(coolantOff)) {
      for (var i in coolantOff) {
        multipleCoolantBlocks.push(mFormat.format(coolantOff[i]));
      }
    } else {
      multipleCoolantBlocks.push(mFormat.format(coolantOff));
    }
  }

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
        multipleCoolantBlocks.push(mFormat.format(m[i]));
      }
    } else {
      multipleCoolantBlocks.push(mFormat.format(m));
    }
    currentCoolantMode = coolant;
    return multipleCoolantBlocks; // return the single formatted coolant value
  }
  return undefined;
}

var mapCommand = {
  COMMAND_STOP:0,
  COMMAND_OPTIONAL_STOP:1,
  COMMAND_END:2,
  COMMAND_SPINDLE_CLOCKWISE:3,
  COMMAND_SPINDLE_COUNTERCLOCKWISE:4,
  COMMAND_STOP_SPINDLE:5,
  COMMAND_ORIENTATE_SPINDLE:19,
  COMMAND_LOAD_TOOL:6
};

function onCommand(command) {
  switch (command) {
  case COMMAND_STOP:
    writeBlock(mFormat.format(0));
    forceSpindleSpeed = true;
    return;
  case COMMAND_OPTIONAL_STOP:
    writeBlock(mFormat.format(1));
    forceSpindleSpeed = true;
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
      writeBlock(mFormat.format(10)); // lock 4th-axis motion
      if (machineConfiguration.getNumberOfAxes() == 5) {
        skipBlock = _skipBlock;
        writeBlock(mFormat.format(12)); // lock 5th-axis motion
      }
    }
    return;
  case COMMAND_UNLOCK_MULTI_AXIS:
    if (machineConfiguration.isMultiAxisConfiguration() && (machineConfiguration.getNumberOfAxes() >= 4)) {
      var _skipBlock = skipBlock;
      writeBlock(mFormat.format(11)); // unlock 4th-axis motion
      if (machineConfiguration.getNumberOfAxes() == 5) {
        skipBlock = _skipBlock;
        writeBlock(mFormat.format(13)); // unlock 5th-axis motion
      }
    }
    return;
  case COMMAND_BREAK_CONTROL:
    if (!toolChecked) { // avoid duplicate COMMAND_BREAK_CONTROL
      onCommand(COMMAND_STOP_SPINDLE);
      onCommand(COMMAND_COOLANT_OFF);
      
      var retract = false;
      if (currentSection.isMultiAxis()) {
        if (getCurrentDirection().length != 0) {
          retract = true;
        }
      } else if ((currentWorkPlaneABC != undefined) && (currentWorkPlaneABC.length != 0)) {
        retract = true;
      }
      if (retract) { // move to safe position
        moveToSafeRetractPosition(false);
      }

      if (activeG254) { // cancel DWO
        writeBlock(gFormat.format(255));
        activeG254 = false;
      }
      
      if (retract) { // position rotary axes at 0-degrees
        writeBlock(
          gMotionModal.format(0),
          conditional(machineConfiguration.isMachineCoordinate(0), "A" + abcFormat.format(0)),
          conditional(machineConfiguration.isMachineCoordinate(1), "B" + abcFormat.format(0)),
          conditional(machineConfiguration.isMachineCoordinate(2), "C" + abcFormat.format(0))
        );
      }
      
      writeBlock(
        gFormat.format(65),
        "P" + 9853,
        "T" + toolFormat.format(tool.number),
        "B" + xyzFormat.format(0),
        "H" + xyzFormat.format(properties.toolBreakageTolerance)
      );
      toolChecked = true;
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
  if (typeof inspectionProcessSectionEnd == "function") {
    inspectionProcessSectionEnd();
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

  if (currentSection.isMultiAxis()) {
    if (currentSection.isOptimizedForMachine()) {
      // the code below gets the machine angles from previous operation.  closestABC must also be set to true
      currentMachineABC = currentSection.getFinalToolAxisABC();
    }
    if (currentSection.getOptimizedTCPMode() == 0) {
      writeBlock(gFormat.format(49), "(TCPC OFF)");
    }
  }

  if (isProbeOperation()) {
    writeBlock(gFormat.format(65), "P" + 9833); // spin the probe off
    if (angularProbingMode == ANGLE_PROBE_USE_CAXIS) {
      setProbingAngle(); // define rotation of part
    }
  }
  
  operationNeedsSafeStart = false; // reset for next section
  cycleReverse = false;
}

/** Output block to do safe retract and/or move to home position. */
function writeRetract() {
  // initialize routine
  var _xyzMoved = new Array(false, false, false);
  var _useG28 = properties.useG28; // can be either true or false

  // check syntax of call
  if (arguments.length == 0) {
    error(localize("No axis specified for writeRetract()."));
    return;
  }
  for (var i = 0; i < arguments.length; ++i) {
    if ((arguments[i] < 0) || (arguments[i] > 2)) {
      error(localize("Bad axis specified for writeRetract()."));
      return;
    }
    if (_xyzMoved[arguments[i]]) {
      error(localize("Cannot retract the same axis twice in one line"));
      return;
    }
    _xyzMoved[arguments[i]] = true;
  }
  
  // special conditions
  if (_useG28 && _xyzMoved[2] && (_xyzMoved[0] || _xyzMoved[1])) { // XY don't use G28
    error(localize("You cannot move home in XY & Z in the same block."));
    return;
  }
  if ((_xyzMoved[0] || _xyzMoved[1]) && !retracted) { // retract Z first before moving to X/Y home
    error(localize("Retracting in X/Y is not possible without being retracted in Z."));
    return;
  }
  if (_xyzMoved[0] || _xyzMoved[1]) {
    _useG28 = false;
  }

  // define home positions
  var _xHome;
  var _yHome;
  var _zHome;
  if (_useG28) {
    _xHome = 0;
    _yHome = 0;
    _zHome = 0;
  } else {
    if (homePositionCenter &&
      hasParameter("part-upper-x") && hasParameter("part-lower-x")) {
      _xHome = (getParameter("part-upper-x") + getParameter("part-lower-x")) / 2;
    } else {
      _xHome = machineConfiguration.hasHomePositionX() ? machineConfiguration.getHomePositionX() : 0;
    }
    _yHome = machineConfiguration.hasHomePositionY() ? machineConfiguration.getHomePositionY() : 0;
    _zHome = machineConfiguration.getRetractPlane();
  }

  // format home positions
  var words = []; // store all retracted axes in an array
  for (var i = 0; i < arguments.length; ++i) {
    // define the axes to move
    switch (arguments[i]) {
    case X:
      // special conditions
      if (homePositionCenter) { // output X in standard block by itself if centering
        writeBlock(gMotionModal.format(0), xOutput.format(_xHome));
        _xyzMoved[0] = false;
        break;
      }
      words.push("X" + xyzFormat.format(_xHome));
      break;
    case Y:
      words.push("Y" + xyzFormat.format(_yHome));
      break;
    case Z:
      words.push("Z" + xyzFormat.format(_zHome));
      retracted = !skipBlock;
      break;
    }
  }

  // output move to home
  if (words.length > 0) {
    if (_useG28) {
      gAbsIncModal.reset();
      writeBlock(gFormat.format(28), gAbsIncModal.format(91), words);
      writeBlock(gAbsIncModal.format(90));
    } else {
      gMotionModal.reset();
      writeBlock(gAbsIncModal.format(90), gFormat.format(53), gMotionModal.format(0), words);
    }

    // force any axes that move to home on next block
    if (_xyzMoved[0]) {
      xOutput.reset();
    }
    if (_xyzMoved[1]) {
      yOutput.reset();
    }
    if (_xyzMoved[2]) {
      zOutput.reset();
    }
  }
}

function onClose() {
  nullProbeAngle(false);
  writeln("");

  optionalSection = false;

  onCommand(COMMAND_STOP_SPINDLE);
  onCommand(COMMAND_COOLANT_OFF);

  // retract
  writeRetract(Z);

  homePositionCenter = properties.homePositionCenter;
  writeRetract(X, Y);

  if (activeG254) {
    writeBlock(gFormat.format(255)); // cancel DWO
    activeG254 = false;
  }
  
  // MAY NEED CHANGE HOMING ORDER TO ROTARY THEN LINEAR FOR NON-UMC MACHINES

  // Unwind Rotary table at end
  if (hasC || properties.machineModel.indexOf("umc") != -1) {
    writeBlock(gFormat.format(28), gAbsIncModal.format(91), "C" + abcFormat.format(0));
    writeBlock(gAbsIncModal.format(90));
  } else if (hasB) {
    writeBlock(gFormat.format(28), gAbsIncModal.format(91), "B" + abcFormat.format(0));
    writeBlock(gAbsIncModal.format(90));
  } else if (hasA) {
    writeBlock(gFormat.format(28), gAbsIncModal.format(91), "A" + abcFormat.format(0));
    writeBlock(gAbsIncModal.format(90));
  }

  if (machineConfiguration.isMultiAxisConfiguration()) {
    var abc = new Vector(0, 0, 0);
    gMotionModal.reset();
    writeBlock(
      gMotionModal.format(0),
      conditional(machineConfiguration.isMachineCoordinate(0), "A" + abcFormat.format(abc.x)),
      conditional(machineConfiguration.isMachineCoordinate(1), "B" + abcFormat.format(abc.y)),
      conditional(machineConfiguration.isMachineCoordinate(2), "C" + abcFormat.format(abc.z))
    );
  }
  
  writeBlock(gRotationModal.format(69));
  onImpliedCommand(COMMAND_END);
  onImpliedCommand(COMMAND_STOP_SPINDLE);
  
  if (properties.useM130PartImages || properties.useM130ToolImages) {
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
// <<<<< INCLUDED FROM ../../../haas next generation.cps

description = "HAAS - Next Generation Control Inspect Surface";
minimumRevision = 42251;
longDescription = "Generic post for the HAAS Next Generation control with inspect surface capabilities.";

var controlType = "NGC"; // Specifies the control model "NGC" or "Classic"
// >>>>> INCLUDED FROM ../common/haas base inspection.cps
properties.probeLocalVar = (controlType == "NGC" ? 10000 : 100); // start address of control local variables that are used for calculations (NGC 10000 - 101999, Classic 100 - 199)
properties.singleResultsFile = true; // create a single file containing the results for all posted inspection toolpath
properties.useDirectConnection = false; // determines whether the inspection results are writen to a file or read directly into Fusion
properties.probeResultsBuffer = (controlType == "NGC" ? 10100 : 150); // starting address of the FIFO buffer for the probe contact points (NGC 10000 - 101999, Classic 100 - 199)
properties.probeNumberofPoints = 4; // maximum number of measurement points stored in the results buffer
properties.controlConnectorVersion = 1; // control connector version
properties.toolOffsetType = "geomWear";
properties.commissioningMode = true; // Enables commissioning mode where M0 and messages are output at key points in the program
properties.probeOnCommand = "G65 P9832"; // Command to turn the probe on, this can be a M code or sub program call
properties.probeOffCommand = "G65 P9833"; // Command to turn the probe off, this can be a M code or sub program call
properties.probeCalibratedRadius = (controlType == "NGC" ? 10556 : 556); // Parameter used for storing probe calibrated radi
properties.probeEccentricityX = (controlType == "NGC" ? 10558 : 558); // Parameter used for storing the X eccentricity
properties.probeEccentricityY = (controlType == "NGC" ? 10559 : 559); // Parameter used for storing the Y eccentricity
properties.probeCalibrationMethod = "Renishaw"; // determines which calibration parameters are used
properties.calibrationNCOutput = "none"; // Choose the calibration type if NC is for calibration, or none
if (propertyDefinitions === undefined) {
  propertyDefinitions = {};
}

propertyDefinitions.probeLocalVar = {title: "Local variable start", description: "Specify the starting value for macro # variables that are to be used for calculations during inspection paths.", group: 99, type: "integer"};
propertyDefinitions.singleResultsFile = {title: "Create Single Results File", description: "Set to false if you want to store the measurement results for each inspection toolpath in a seperate file.", group: 99, type: "boolean"};
propertyDefinitions.useDirectConnection = {title: "Stream Measured Point Data", description: "Set to true to stream inspection results.", group: 99, type: "boolean"};
propertyDefinitions.probeResultsBuffer = {title: "Measurement results store start", description: "Specify the starting value of macro # variables where measurement results are stored.", group: 99, type: "integer"};
propertyDefinitions.probeNumberofPoints = {title: "Measurement number of points to store", description: "This is the maximum number of measurement results that can be stored in the buffer.", group: 99, type: "integer"};
propertyDefinitions.controlConnectorVersion = {title: "Results connector version", description: "Interface version for direct connection to read inspection results.", group: 99, type: "integer"};
propertyDefinitions.toolOffsetType = {
  title: "Tool offset type",
  description: "Select the which offsets are available on the tool offset page.",
  group: 99,
  type: "enum",
  values: [
    {id: "geomWear", title: "Geometry & Wear"},
    {id: "geomOnly", title: "Geometry only"}
  ]
};
propertyDefinitions.commissioningMode = {title: "Inspection Commissioning Mode", description: "Enables commissioning mode where M0 and messages are output at key points in the program.", group: 99, type: "boolean"};
propertyDefinitions.probeOnCommand = {title: "Probe On Command", description: "The command used to turn the probe on, this can be a M code or sub program call.", group: 99, type: "string"};
propertyDefinitions.probeOffCommand = {title: "Probe Off Command", description: "The command used to turn the probe off, this can be a M code or sub program call.", group: 99, type: "string"};
propertyDefinitions.probeCalibratedRadius = {title: "Calibrated Radius", description: "Macro Variable used for storing probe calibrated radi.", group: 99, type: "integer"};
propertyDefinitions.probeEccentricityX = {title: "Eccentricity X", description: "Macro Variable used for storing the X eccentricity.", group: 99, type: "integer"};
propertyDefinitions.probeEccentricityY = {title: "Eccentricity Y", description: "Macro Variable used for storing the Y eccentricity.", group: 99, type: "integer"};
propertyDefinitions.probeCalibrationMethod = {
  title: "Probe calibration Method",
  description: "Select the probe calibration method.",
  group: 99,
  type: "enum",
  values: [
    {id: "Renishaw", title: "Renishaw"},
    {id: "Autodesk", title: "Autodesk"},
    {id: "Other", title: "Other"}
  ]
};
propertyDefinitions.calibrationNCOutput = {
  title: "Calibration NC Output Type",
  description: "Choose none if the NC program created is to be used for calibrating the probe.",
  group: 99,
  type: "enum",
  values: [
    {id: "none", title: "none"},
    {id: "Ring Gauge", title: "Ring Gauge"},
  ]
};

var ijkFormat = createFormat({decimals:5, forceDecimal:true});
// inspection variables
var inspectionVariables = {
  localVariablePrefix: "#",
  probeRadius: 0,
  systemVariableMeasuredX: 5061,
  systemVariableMeasuredY: 5062,
  systemVariableMeasuredZ: 5063,
  pointNumber: 1,
  probeResultsBufferFull: false,
  probeResultsBufferIndex: 1,
  inspectionSections: 0,
  inspectionSectionCount: 0,
  systemVariableOffsetLengthTable: 2200,
  systemVariableOffsetWearTable: 2000,
  workpieceOffset: "",
  systemVariablePreviousX: 5001,
  systemVariablePreviousY: 5002,
  systemVariablePreviousZ: 5003,
  systemVariableCurrentX: 5021,
  systemVariableCurrentY: 5022,
  systemVariableCurrentZ: 5023,
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
  // loop through all NC stream sections to check for surface inspection
  for (var i = 0; i < getNumberOfSections(); ++i) {
    var section = getSection(i);
    if (isInspectionOperation(section)) {
      if (inspectionVariables.inspectionSections == 0) {
        inspectionVariables.workpieceOffset = section.workOffset;
        var count = 1;
        var localVar = properties.probeLocalVar;
        var prefix = inspectionVariables.localVariablePrefix;
        inspectionVariables.probeRadius = prefix + count;
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
        inspectionVariables.wcsVectorX = prefix + ++count;
        inspectionVariables.wcsVectorY = prefix + ++count;
        inspectionVariables.wcsVectorZ = prefix + ++count;
        inspectionVariables.previousWCSX = prefix + ++count;
        inspectionVariables.previousWCSY = prefix + ++count;
        inspectionVariables.previousWCSZ = prefix + ++count;
        if (properties.calibrationNCOutput == "Ring Gauge") {
          inspectionVariables.measuredXStartingAddress = localVar;
          inspectionVariables.measuredYStartingAddress = localVar + 10;
          inspectionVariables.measuredZStartingAddress = localVar + 20;
          inspectionVariables.measuredIStartingAddress = localVar + 30;
          inspectionVariables.measuredJStartingAddress = localVar + 40;
          inspectionVariables.measuredKStartingAddress = localVar + 50;
        }
        inspectionValidateInspectionSettings();
        inspectionVariables.probeResultsReadPointer = prefix + (properties.probeResultsBuffer + 2);
        inspectionVariables.probeResultsWritePointer = prefix + (properties.probeResultsBuffer + 3);
        inspectionVariables.probeResultsCollectionActive = prefix + (properties.probeResultsBuffer + 4);
        inspectionVariables.probeResultsStartAddress = properties.probeResultsBuffer + 5;
        if (properties.toolOffsetType == "geomOnly") {
          inspectionVariables.systemVariableOffsetLengthTable = "2000";
        }
        if (properties.commissioningMode) {
          writeBlock("#3006=1(Inspection commissioning mode is active, when the machine is measuring correctly please disable this in the post properties)");
        }
        if (properties.useDirectConnection) {
          // check to make sure local variables used in results buffer and inspection do not clash
          var localStart = properties.probeLocalVar;
          var localEnd = count;
          var BufferStart = properties.probeResultsBuffer;
          var bufferEnd = properties.probeResultsBuffer + ((3 * properties.probeNumberofPoints) + 8);
          if ((localStart >= BufferStart && localStart <= bufferEnd) || (localEnd >= BufferStart && localEnd <= bufferEnd)) {
            error("Local variables defined (" + prefix + localStart + "-" + prefix + localEnd +
              ") and live probe results storage area (" + prefix + BufferStart + "-" + prefix + bufferEnd + ") overlap."
            );
          }
          writeBlock(macroFormat.format(properties.probeResultsBuffer) + " = " + properties.controlConnectorVersion);
          writeBlock(macroFormat.format(properties.probeResultsBuffer + 1) + " = " + properties.probeNumberofPoints);
          writeBlock(inspectionVariables.probeResultsReadPointer + " = 0");
          writeBlock(inspectionVariables.probeResultsWritePointer + " = 1");
          writeBlock(inspectionVariables.probeResultsCollectionActive + " = 0");
          if (properties.probeResultultsBuffer == 0) {
            error("Probe Results Buffer start address cannot be zero when using a direct connection.");
          }
          inspectionWriteFusionConnectorInterface("HEADER");
        }
      }
      inspectionVariables.inspectionSections += 1;
    }
  }
}

function inspectionValidateInspectionSettings() {
  var errorText = "";
  if (properties.probeOnCommand == "") {
    errorText += "\n-Probe On Command-";
  }
  if (properties.probeOffCommand == "") {
    errorText += "\n-Probe Off Command-";
  }
  if (properties.probeCalibratedRadius == 0) {
    errorText += "\n-Calibrated Radius-";
  }
  if (properties.probeEccentricityX == 0) {
    errorText += "\n-Eccentricity X-";
  }
  if (properties.probeEccentricityY == 0) {
    errorText += "\n-Eccentricity Y-";
  }
  if (errorText != "") {
    error(localize("The following properties need to be configured:" + errorText + "\n-Please visit https://forums.autodesk.com/t5/hsm-post-processor-forum/bd-p/218 for more information-"));
  }
}

function onProbe(status) {
  if (status) { // probe ON
    if (properties.commissioningMode && properties.calibrationNCOutput == "Ring Gauge") {
      writeBlock(mFormat.format(19), "R#1");
    } else {
      writeBlock(mFormat.format(19));
    }
    writeBlock(properties.probeOnCommand); // Command for switching the probe on
    onDwell(2);
    if (properties.commissioningMode) {
      writeBlock("#3006=1(Ensure Probe Is Active)");
    }
  } else { // probe OFF
    writeBlock(properties.probeOffCommand); // Command for switching the probe off
    onDwell(2);
    if (properties.commissioningMode) {
      writeBlock("#3006=1(Ensure Probe Has Deactivated)");
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
      writeBlock(gFormat.format(61)); //exact stop mode on
      writeBlock(gAbsIncModal.format(91), gFormat.format(1),
        "X-" + macroFormat.format(properties.probeEccentricityX),
        "Y-" + macroFormat.format(properties.probeEccentricityY),
        feedOutput.format(cycle.safeFeed)
      );
      writeBlock("G103 P1 (LOOKAHEAD OFF)");
      inspectionGetCoordinates(true);
      inspectionCalculateTargetEndpoint(x, y, z, SAFE_MOVE_DWO);
      // move alond probing vector with DWO off
      inspectionWriteCycleMove(gAbsIncModal.format(91), cycle.safeFeed, SAFE_MOVE_DWO, ALARM_IF_DEFLECTED);
      // Apply radius delta correction
      writeBlock(gAbsIncModal.format(91), gFormat.format(1),
        "Z+[" + xyzFormat.format(tool.diameter / 2) + "-" + inspectionVariables.probeRadius + "]",
        feedOutput.format(cycle.safeFeed)
      );
      writeBlock("G103 P1 (LOOKAHEAD OFF)");
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
    writeBlock(gFormat.format(64)); //exact stop mode on
    return;
  }
  // measure move
  if (properties.commissioningMode && (inspectionVariables.pointNumber == 1)) {
    writeBlock("#3006=1(Probe is about to contact part. Axes should stop on contact)");
  }
  inspectionWriteNominalData(cycle);
  if (properties.useDirectConnection) {
    inspectionWriteFusionConnectorInterface("MEASURE");
  }
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
  writeBlock("DPRNT[G800" +
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
    writeBlock(inspectionVariables.wcsVectorX + " =" + macroFormat.format(inspectionVariables.systemVariableCurrentX) + "-" + inspectionVariables.previousWCSX);
    writeBlock(inspectionVariables.wcsVectorY + " =" + macroFormat.format(inspectionVariables.systemVariableCurrentY) + "-" + inspectionVariables.previousWCSY);
    writeBlock(inspectionVariables.wcsVectorZ + " =[" + macroFormat.format(inspectionVariables.systemVariableCurrentZ) + "-" + inspectionVariables.activeToolLength + "]-" + inspectionVariables.previousWCSZ);
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
    writeBlock(inspectionVariables.xTarget + " =" + xyzFormat.format(x) + "-" + macroFormat.format(properties.probeEccentricityX));
    writeBlock(inspectionVariables.yTarget + " =" + xyzFormat.format(y) + "-" + macroFormat.format(properties.probeEccentricityY));
    writeBlock(inspectionVariables.zTarget + " =" + xyzFormat.format(z) + "+[" + xyzFormat.format(tool.diameter / 2) + "-" + inspectionVariables.probeRadius + "]");
  }
}

function inspectionWriteCycleMove(absInc, feedRate, moveType, triggerCheck) {
  // writeComment("moveType = " + moveType, triggerCheck);
  var motionCommand = moveType == LINEAR_MOVE ? 1 : 31;
  gMotionModal.reset();
  writeBlock(absInc,
    gFormat.format(motionCommand),
    "X" + inspectionVariables.xTarget,
    "Y" + inspectionVariables.yTarget,
    "Z" + inspectionVariables.zTarget,
    feedOutput.format(feedRate),
    triggerCheck
  );
  writeBlock("G103 P1 (LOOKAHEAD OFF)");
}

function inspectionProbeTriggerCheck(triggered) {
  var condition = triggered ? " LT " : " GT ";
  var message = triggered ? "(NO POINT TAKEN)" : "(PATH OBSTRUCTED)";
  var inPositionTolerance = (unit == MM) ? 0.01 : 0.0004;
  writeBlock(inspectionVariables.macroVariable1 + " =" + inspectionVariables.xTarget + "-" + macroFormat.format(inspectionVariables.systemVariableMeasuredX));
  writeBlock(inspectionVariables.macroVariable2 + " =" + inspectionVariables.yTarget + "-" + macroFormat.format(inspectionVariables.systemVariableMeasuredY));
  writeBlock(inspectionVariables.macroVariable3 + " =" + inspectionVariables.zTarget + "-" + macroFormat.format(inspectionVariables.systemVariableMeasuredZ) + "+" + inspectionVariables.activeToolLength);
  writeBlock(inspectionVariables.macroVariable4 + " =" +
    "[" + inspectionVariables.macroVariable1 + "*" + inspectionVariables.macroVariable1 + "]" + "+" +
    "[" + inspectionVariables.macroVariable2 + "*" + inspectionVariables.macroVariable2 + "]" + "+" +
    "[" + inspectionVariables.macroVariable3 + "*" + inspectionVariables.macroVariable3 + "]"
  );
  writeBlock("IF [" + inspectionVariables.macroVariable4 + condition + inPositionTolerance + "] THEN #3000 = 1 (" + message + ")");
}

function inspectionCorrectProbeMeasurement() {
  writeComment("Correct Measurements");
  var MeasuredX = macroFormat.format(inspectionVariables.systemVariableMeasuredX);
  var MeasuredY = macroFormat.format(inspectionVariables.systemVariableMeasuredY);
  var MeasuredZ = macroFormat.format(inspectionVariables.systemVariableMeasuredZ);
  if (activeG254) {
    // Actual is previous target system parameter - with eccentricity correction
    MeasuredX = macroFormat.format(inspectionVariables.systemVariablePreviousX);
    MeasuredY = macroFormat.format(inspectionVariables.systemVariablePreviousY);
    MeasuredZ = macroFormat.format(inspectionVariables.systemVariablePreviousZ);
  }
  writeBlock(inspectionVariables.xMeasured + " =" + MeasuredX + "+" + macroFormat.format(properties.probeEccentricityX));
  writeBlock(inspectionVariables.yMeasured + " =" + MeasuredY + "+" + macroFormat.format(properties.probeEccentricityY));
  // need to consider probe centre tool output point in future too
  var correctToolLength = activeG254 ? "" : ("-" + inspectionVariables.activeToolLength);
  writeBlock(inspectionVariables.zMeasured + " =" + MeasuredZ + "+" + inspectionVariables.probeRadius + correctToolLength);
}

function inspectionWriteFusionConnectorInterface(ncSection) {
  if (ncSection == "MEASURE") {
    writeBlock("IF " + inspectionVariables.probeResultsCollectionActive + " NE 1 GOTO " + inspectionVariables.pointNumber);
    writeBlock("WHILE [" + inspectionVariables.probeResultsReadPointer + " EQ " + inspectionVariables.probeResultsWritePointer + "] DO 1");
    onDwell(0.5);
    writeComment("WAITING FOR FUSION CONNECTION");
    writeBlock("G53");
    writeBlock("END 1");
    writeBlock("N" + inspectionVariables.pointNumber);
  } else {
    writeBlock("WHILE [" + inspectionVariables.probeResultsCollectionActive + " NE 1] DO 1");
    onDwell(0.5);
    writeComment("WAITING FOR FUSION CONNECTION");
    writeBlock("G53");
    writeBlock("END 1");
  }
}

function inspectionWriteMeasuredData() {
  var outputFormat = getParameter("operation:metric") == 1 ? "[53]" : "[44]";
  writeBlock("DPRNT[G801" +
    "*N" + inspectionVariables.pointNumber +
    "*X" + inspectionVariables.xMeasured + outputFormat +
    "*Y" + inspectionVariables.yMeasured + outputFormat +
    "*Z" + inspectionVariables.zMeasured + outputFormat +
    "*R" + inspectionVariables.probeRadius + outputFormat +
    "]"
  );
  if (properties.useDirectConnection) {
    var writeResultIndexX = inspectionVariables.probeResultsStartAddress + (3 * inspectionVariables.probeResultsBufferIndex);
    var writeResultIndexY = inspectionVariables.probeResultsStartAddress + (3 * inspectionVariables.probeResultsBufferIndex) + 1;
    var writeResultIndexZ = inspectionVariables.probeResultsStartAddress + (3 * inspectionVariables.probeResultsBufferIndex) + 2;

    writeBlock(macroFormat.format(writeResultIndexX) + " = " + inspectionVariables.xMeasured);
    writeBlock(macroFormat.format(writeResultIndexY) + " = " + inspectionVariables.yMeasured);
    writeBlock(macroFormat.format(writeResultIndexZ) + " = " + inspectionVariables.zMeasured);
    inspectionVariables.probeResultsBufferIndex += 1;
    if (inspectionVariables.probeResultsBufferIndex > properties.probeNumberofPoints) {
      inspectionVariables.probeResultsBufferIndex = 0;
    }
    writeBlock(inspectionVariables.probeResultsWritePointer + " = " + inspectionVariables.probeResultsBufferIndex);
  }
  if (properties.commissioningMode && (properties.calibrationNCOutput == "Ring Gauge")) {
    writeBlock(macroFormat.format(inspectionVariables.measuredXStartingAddress + inspectionVariables.pointNumber) +
      " =" + inspectionVariables.xMeasured);
    writeBlock(macroFormat.format(inspectionVariables.measuredYStartingAddress + inspectionVariables.pointNumber) +
      " =" + inspectionVariables.yMeasured);
    writeBlock(macroFormat.format(inspectionVariables.measuredZStartingAddress + inspectionVariables.pointNumber) +
      " =" + inspectionVariables.zMeasured);
    writeBlock(macroFormat.format(inspectionVariables.measuredIStartingAddress + inspectionVariables.pointNumber) +
      " =" + xyzFormat.format(cycle.nominalI));
    writeBlock(macroFormat.format(inspectionVariables.measuredJStartingAddress + inspectionVariables.pointNumber) +
      " =" + xyzFormat.format(cycle.nominalJ));
    writeBlock(macroFormat.format(inspectionVariables.measuredKStartingAddress + inspectionVariables.pointNumber) +
      " =" + xyzFormat.format(cycle.nominalK));
  }
  inspectionVariables.pointNumber += 1;
}

function inspectionProcessSectionStart() {
  saveShowSequenceNumbers = properties.showSequenceNumbers;
  properties.showSequenceNumbers = false;

  writeBlock("G103 P1 (LOOKAHEAD OFF)");
  // only write header once if user selects a single results file
  if (inspectionVariables.inspectionSectionCount == 0 || !properties.singleResultsFile || (currentSection.workOffset != inspectionVariables.workpieceOffset)) {
    inspectionCreateResultsFileHeader();
  }
  // write the toolpath name as a comment
  writeBlock("DPRNT[TOOLPATHID*" + getParameter("autodeskcam:operation-id") + "]");
  writeBlock("DPRNT[TOOLPATH*" + getParameter("operation-comment") + "]");
  inspectionWriteCADTransform();
  inspectionVariables.inspectionSectionCount += 1;
  inspectionWriteWorkplaneTransform();
  if (properties.toolOffsetType == "geomOnly") {
    writeComment("Geometry Only");
    writeBlock(
      inspectionVariables.activeToolLength + " =" +
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
  if (properties.probeCalibrationMethod == "Renishaw") {
    writeBlock(inspectionVariables.probeRadius + "=[[" +
      macroFormat.format(properties.probeCalibratedRadius) + " + " +
      macroFormat.format(properties.probeCalibratedRadius + 1) + "]" + "/2]"
    );
  } else {
    writeBlock(inspectionVariables.probeRadius + "=" + macroFormat.format(properties.probeCalibratedRadius));
  }
  if (properties.commissioningMode) {
    var outputFormat = (unit == MM) ? "[53]" : "[44]";
    writeBlock("DPRNT[CALIBRATED*RADIUS*" + inspectionVariables.probeRadius + outputFormat + "]");
    writeBlock("DPRNT[ECCENTRICITY*X****" + macroFormat.format(properties.probeEccentricityX) + outputFormat + "]");
    writeBlock("DPRNT[ECCENTRICITY*Y****" + macroFormat.format(properties.probeEccentricityY) + outputFormat + "]");
    writeBlock("IF [" + inspectionVariables.probeRadius + " EQ #0] THEN #3000 = 1(PROBE NOT CALIBRATED OR PROPERTY CALIBRATED RADIUS INCORRECT)");
    writeBlock("IF [" + inspectionVariables.probeRadius + " EQ 0] THEN #3000 = 1(PROBE NOT CALIBRATED OR PROPERTY CALIBRATED RADIUS INCORRECT)");
    writeBlock("IF [" + inspectionVariables.probeRadius + " GT " + xyzFormat.format(tool.diameter / 2) + "] THEN #3000 = 1(PROBE NOT CALIBRATED OR PROPERTY CALIBRATED RADIUS INCORRECT)");
    var maxEccentricity = (unit == MM) ? 0.2 : 0.0079;
    writeBlock("IF [ABS[" + macroFormat.format(properties.probeEccentricityX) + "] GT " + maxEccentricity + "] THEN #3000 = 1(PROBE NOT CALIBRATED OR PROPERTY ECCENTRICITY X INCORRECT)");
    writeBlock("IF [ABS[" + macroFormat.format(properties.probeEccentricityY) + "] GT " + maxEccentricity + "] THEN #3000 = 1(PROBE NOT CALIBRATED OR PROPERTY ECCENTRICITY Y INCORRECT)");
    writeBlock("IF [" + macroFormat.format(properties.probeEccentricityX) + " EQ #0] THEN #3000 = 1(PROBE NOT CALIBRATED OR PROPERTY ECCENTRICITY X INCORRECT)");
    writeBlock("IF [" + macroFormat.format(properties.probeEccentricityY) + " EQ #0] THEN #3000 = 1(PROBE NOT CALIBRATED OR PROPERTY ECCENTRICITY Y INCORRECT)");
  }
}

function inspectionCreateResultsFileHeader() {
  writeBlock("PCLOS");
  writeBlock("POPEN");
  // check for existence of none alphanumeric characters but not spaces
  var resFile;
  if (properties.singleResultsFile) {
    resFile = getParameter("job-description") + "_RESULTS";
  } else {
    resFile = getParameter("operation-comment") + "_RESULTS";
  }
  resFile = resFile.replace(/:/g, "_");
  var regExPattern = /(?!\s)\W/g;
  var regExResult = regExPattern.test(resFile);
  if (regExResult) {
    error(localize("Setup name can only contain alphanumeric, space, and underscore characters"));
  }
  // replace spaces with underscore as controllers don't like spaces in filenames
  resFile = resFile.replace(/\s/g, "_");
  writeBlock("DPRNT[RESULTSFILE*" + resFile + "]");
  if (inspectionVariables.inspectionSectionCount == 0 || !properties.singleResultsFile) {
    writeBlock("DPRNT[START]");
    if (hasGlobalParameter("document-id")) {
      writeBlock("DPRNT[DOCUMENTID*" + getGlobalParameter("document-id") + "]");
    }
    if (hasGlobalParameter("model-version")) {
      writeBlock("DPRNT[MODELVERSION*" + getGlobalParameter("model-version") + "]");
    }
  }
  inspectionVariables.workpieceOffset = currentSection.workOffset;
}

function inspectionWriteCADTransform() {
  var cadOrigin = currentSection.getModelOrigin();
  var cadWorkPlane = currentSection.getModelPlane().getTransposed();
  var cadEuler = cadWorkPlane.getEuler2(EULER_XYZ_S);
  writeBlock(
    "DPRNT[G331" +
    "*N" + inspectionVariables.pointNumber +
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
  writeBlock("DPRNT[G330" +
    "*N" + inspectionVariables.pointNumber +
    "*A" + abcFormat.format(abc.x) +
    "*B" + abcFormat.format(abc.y) +
    "*C" + abcFormat.format(abc.z) +
    "*X0*Y0*Z0*I0*R0]"
  );
}

function inspectionProcessSectionEnd() {
  if (isInspectionOperation(currentSection)) {
    // close inspection results file if the NC has inspection toolpaths
    if ((!properties.singleResultsFile) || (inspectionVariables.inspectionSectionCount == inspectionVariables.inspectionSections)) {
      writeBlock("DPRNT[END]");
      writeBlock("PCLOS");
      if (properties.commissioningMode) {
        if (controlType == "NGC") {
          writeBlock(inspectionVariables.macroVariable1 + " = #20261 + 100");
          writeBlock("GOTO " + inspectionVariables.macroVariable1);
          writeBlock("N100");
          writeBlock("#3006=1(DPRNT LOCATION NOT SET)");
          onCommand(COMMAND_STOP);
          writeBlock("GOTO 120");
          writeBlock("N101");
          writeBlock("#3006=1(CHECK SETTING 262 FOR RESULTS FILE LOCATION)");
          onCommand(COMMAND_STOP);
          writeBlock("GOTO 120");
          writeBlock("N102");
          writeBlock("#3006=1(RESULTS FILE WRITTEN TO TCP PORT)");
          onCommand(COMMAND_STOP);
          writeBlock("N120");
        } else {
          writeBlock("#3006=1(RESULTS FILE WRITTEN TO SERIAL PORT)");
        }
      }
    }
    writeBlock("G103 P0 (LOOKAHEAD ON)");
    properties.showSequenceNumbers = saveShowSequenceNumbers;
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
  writeBlock(inspectionVariables.previousWCSX + " =" + macroFormat.format(inspectionVariables.systemVariableCurrentX));
  writeBlock(inspectionVariables.previousWCSY + " =" + macroFormat.format(inspectionVariables.systemVariableCurrentY));
  writeBlock(inspectionVariables.previousWCSZ + " =" + macroFormat.format(inspectionVariables.systemVariableCurrentZ) + "-" + inspectionVariables.activeToolLength);
  inspectionReconfirmPositionDWO(cycle.safeFeed);
}

function inspectionReconfirmPositionDWO(f) {
  // zero length move to re-confirm current position
  writeComment("Re-confirm position DWO Active");
  writeBlock(gFormat.format(254));
  writeBlock(gAbsIncModal.format(91), gMotionModal.format(1), "X0.0 Y0.0", feedOutput.format(f));
  writeBlock("Z0.0");
  writeBlock("G103 P1 (LOOKAHEAD OFF)");
}
// <<<<< INCLUDED FROM ../common/haas base inspection.cps
