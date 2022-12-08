/**
  Copyright (C) 2012-2022 by Autodesk, Inc.
  All rights reserved.

  Siemens SINUMERIK 840D post processor configuration.

  $Revision: 43980 fc70482ee2fa0f3f8331ea789e5a02be310463cb $
  $Date: 2022-10-12 11:33:35 $

  FORKID {75AF44EA-0A42-4803-8DE7-43BF08B352B3}
*/

description = "Siemens SINUMERIK 840D";
vendor = "Siemens";
vendorUrl = "http://www.siemens.com";
legal = "Copyright (C) 2012-2022 by Autodesk, Inc.";
certificationLevel = 2;
minimumRevision = 45821;

longDescription = "Generic post for Siemens 840D. Note that the post will use D1 always for the tool length compensation as this is how most users work.";

extension = "mpf";
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
allowedCircularPlanes = undefined; // allow any circular motion

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
  useCIP: {
    title      : "Use CIP",
    description: "Enable to use the CIP command.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  useSmoothing: {
    title      : "Use CYCLE832",
    description: "Enable to use CYCLE832.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
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
      {id:"39", title:"39 (CAB)"},
      {id:"27", title:"27 (CBA)"},
      {id:"57", title:"57 (ABC)"},
      {id:"45", title:"45 (ACB)"},
      {id:"30", title:"30 (BCA)"},
      {id:"54", title:"54 (BAC)"},
      {id:"192", title:"192 (Rotary angles)"}
    ],
    value: "27",
    scope: "post"
  },
  cycle800SwivelDataRecord: {
    title      : "CYCLE800 Swivel Data Record",
    description: "Specifies the label to use for the Swivel Data Record for CYCLE800.",
    group      : "multiAxis",
    type       : "string",
    value      : "",
    scope      : "post"
  },
  useExtendedCycles: {
    title      : "Extended cycles",
    description: "Specifies whether the extended cycles should be used.",
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
    title      : "Home XY at end",
    description: "Specifies that the machine moves to the home position in XY at the end of the program.",
    group      : "homePositions",
    type       : "boolean",
    value      : false,
    scope      : "post"
  }
};

// wcs definiton
wcsDefinitions = {
  useZeroOffset: false,
  wcs          : [
    {name:"Standard", format:"G", range:[54, 57]},
    {name:"Extended", format:"G", range:[505, 599]}
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
  {id:COOLANT_THROUGH_TOOL},
  {id:COOLANT_AIR},
  {id:COOLANT_AIR_THROUGH_TOOL},
  {id:COOLANT_SUCTION},
  {id:COOLANT_FLOOD_MIST},
  {id:COOLANT_FLOOD_THROUGH_TOOL},
  {id:COOLANT_OFF, off:9}
];

var gFormat = createFormat({prefix:"G", decimals:0});
var mFormat = createFormat({prefix:"M", decimals:0});
var hFormat = createFormat({prefix:"H", decimals:0});
var dFormat = createFormat({prefix:"D", decimals:0});
var nFormat = createFormat({prefix:"N", decimals:0});

var xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4)});
var abcFormat = createFormat({decimals:3, scale:DEG});
var abcDirectFormat = createFormat({decimals:3, scale:DEG, prefix:"=DC(", suffix:")"});
var abc3Format = createFormat({decimals:6});
var feedFormat = createFormat({decimals:(unit == MM ? 1 : 2)});
var inverseTimeFormat = createFormat({decimals:3, forceDecimal:true});
var toolFormat = createFormat({decimals:0});
var toolProbeFormat = createFormat({decimals:0, zeropad:true, width:3});
var rpmFormat = createFormat({decimals:0});
var secFormat = createFormat({decimals:3});
var taperFormat = createFormat({decimals:1, scale:DEG});
var arFormat = createFormat({decimals:3, scale:DEG});

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

// circular output
var iOutput = createReferenceVariable({prefix:"I", force:true}, xyzFormat);
var jOutput = createReferenceVariable({prefix:"J", force:true}, xyzFormat);
var kOutput = createReferenceVariable({prefix:"K", force:true}, xyzFormat);

var gMotionModal = createModal({force:true}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal({onchange:function () {gMotionModal.reset();}}, gFormat); // modal group 2 // G17-19
var gAbsIncModal = createModal({}, gFormat); // modal group 3 // G90-91
var gFeedModeModal = createModal({}, gFormat); // modal group 5 // G94-95
var gUnitModal = createModal({}, gFormat); // modal group 6 // G70-71

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
  if (false) { // note: setup your machine here
    var aAxis = createAxis({coordinate:0, table:true, axis:[1, 0, 0], range:[-120, 120], preference:1, tcp:useTCP});
    var cAxis = createAxis({coordinate:2, table:true, axis:[0, 0, 1], range:[-360, 360], preference:0, tcp:useTCP});
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

  if (programComment) {
    writeComment(programComment);
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

  if (true) { // stock - workpiece
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
    var DIR = turn ? -1 : 0; // direction
    if (machineConfiguration.isMultiAxisConfiguration()) {
      var machineABC = abc.isNonZero() ? getWorkPlaneMachineABC(currentSection.workPlane, false, false) : abc;
      DIR = turn ? (machineABC.x > 0 || machineABC.y > 0) ? 1 : -1 : 0;
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
    var FR = 1; // 0 = without moving to safety plane, 1 = move to safety plane only in Z, 2 = move to safety plane Z,X,Y
    var TC = getProperty("cycle800SwivelDataRecord");
    var ST = 0;
    var MODE = cycle800Config[0];
    var X0 = 0;
    var Y0 = 0;
    var Z0 = 0;
    var A = cycle800Config[1].x;
    var B = cycle800Config[1].y;
    var C = cycle800Config[1].z;
    var X1 = 0;
    var Y1 = 0;
    var Z1 = 0;
    var DMODE = 0; // keep the previous plane active
    if (!getProperty("useExtendedCycles")) {
      writeBlock(
        "CYCLE800(" + [
          FR,
          "\"" + TC + "\"",
          ST,
          MODE,
          xyzFormat.format(X0),
          xyzFormat.format(Y0),
          xyzFormat.format(Z0),
          abcFormat.format(A),
          abcFormat.format(B),
          abcFormat.format(C),
          xyzFormat.format(X1),
          xyzFormat.format(Y1),
          xyzFormat.format(Z1),
          DIR].join(",") + ")"
      );
    } else {
      writeBlock(
        "CYCLE800(" +
        [FR,
          "\"" + TC + "\"",
          ST,
          MODE,
          xyzFormat.format(X0),
          xyzFormat.format(Y0),
          xyzFormat.format(Z0),
          abcFormat.format(A),
          abcFormat.format(B),
          abcFormat.format(C),
          xyzFormat.format(X1),
          xyzFormat.format(Y1),
          xyzFormat.format(Z1),
          DIR,
          DMODE].join(",") + ")"
      );
    }
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
    onCommand(COMMAND_LOCK_MULTI_AXIS);
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
  if (insertToolCall || newWorkOffset || newWorkPlane) {

    // retract to safe plane
    writeRetract(Z);

    if (newWorkPlane && useMultiAxisFeatures) {
      setWorkPlane(new Vector(0, 0, 0), false); // reset working plane
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

  if (insertToolCall) {
    forceWorkPlane();

    setCoolant(COOLANT_OFF);

    if (!isFirstSection() && getProperty("optionalStop")) {
      onCommand(COMMAND_OPTIONAL_STOP);
    }

    if (tool.number > 99999999) {
      warning(localize("Tool number exceeds maximum value."));
    }

    var lengthOffset = 1; // optional, use tool.lengthOffset instead
    if (lengthOffset > 99) {
      error(localize("Length offset out of range."));
      return;
    }
    writeToolBlock("T" + (getProperty("toolAsName") ? "="  + "\"" + (tool.description.toUpperCase()) + "\"" : toolFormat.format(tool.number)), dFormat.format(lengthOffset));
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

  if (getProperty("useSmoothing")) {
    if (hasParameter("operation-strategy") && (getParameter("operation-strategy") == "drill")) {
      writeBlock("CYCLE832()");
    } else if (hasParameter("operation:tolerance")) {
      var tolerance = Math.max(getParameter("operation:tolerance"), 0);
      if (tolerance > 0) {
        var workMode = 1;
        var stockToLeaveThreshold = toUnit(0.1, MM);
        if ((hasParameter("operation:stockToLeave") && (xyzFormat.getResultingValue(getParameter("operation:stockToLeave")) < stockToLeaveThreshold)) ||
            (hasParameter("operation:verticalStockToLeave") && (xyzFormat.getResultingValue(getParameter("operation:verticalStockToLeave")) < stockToLeaveThreshold))) {
          workMode = 1;
        } else {
          workMode = 2;
        }
        writeBlock("CYCLE832(" + xyzFormat.format(tolerance) + ", 11200" + workMode + ")");
      } else {
        writeBlock("CYCLE832()");
      }
    } else {
      writeBlock("CYCLE832()");
    }
  }

  if ((insertToolCall ||
       forceSpindleSpeed ||
       isFirstSection() ||
       (rpmFormat.areDifferent(spindleSpeed, sOutput.getCurrent())) ||
       (tool.clockwise != getPreviousSection().getTool().clockwise))) {
    forceSpindleSpeed = false;

    if (tool.type == TOOL_PROBE) {
      if (insertToolCall) {
        writeBlock("SPOS=0");
      }
    } else {
      if (spindleSpeed < 1) {
        error(localize("Spindle speed out of range."));
        return;
      }
      if (spindleSpeed > 99999) {
        warning(localize("Spindle speed exceeds maximum value."));
      }
      writeBlock(
        sOutput.format(spindleSpeed), mFormat.format(tool.clockwise ? 3 : 4)
      );
    }
  }

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

  if (retracted && !insertToolCall) {
    var lengthOffset = 1; // optional, use tool.lengthOffset instead
    if (lengthOffset > 99) {
      error(localize("Length offset out of range."));
      return;
    }
    writeBlock(dFormat.format(lengthOffset));
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
    }
    if (operationSupportsTCP || !machineConfiguration.isMultiAxisConfiguration()) {
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
      if (tool.lengthOffset != 0) {
        warningOnce(localize("Length offset is not supported."), WARNING_LENGTH_OFFSET);
      }

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
          yOutput.format(initialPosition.y),
          zOutput.format(initialPosition.z)
        );
      }
    } else {
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(0),
        xOutput.format(initialPosition.x),
        yOutput.format(initialPosition.y)
      );
    }
  }

  // set coolant after we have positioned at Z
  if (insertToolCall) {
    // currentCoolantMode = undefined;
  }
  setCoolant(tool.coolant);

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

  var RTP = cycle.clearance; // return plane (absolute)
  var RFP = cycle.stock; // reference plane (absolute)
  var SDIS = cycle.retract - cycle.stock; // safety distance
  var DP = cycle.bottom; // depth (absolute)
  // var DPR = RFP - cycle.bottom; // depth (relative to reference plane)
  var DTB = cycle.dwell;
  var SDIR = tool.clockwise ? 3 : 4; // direction of rotation: M3:3 and M4:4

  switch (cycleType) {
  case "drilling":
    if (RTP > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    var GMODE = 0;
    var DMODE = 0; // keep the programmed plane active
    var AMODE = 10; // dwell is programmed in seconds and depth is taken from DP DPR settings
    writeBlock(
      "MCALL CYCLE81(" + [xyzFormat.format(RTP),
        xyzFormat.format(RFP),
        xyzFormat.format(SDIS),
        xyzFormat.format(DP),
        "" /*+ xyzFormat.format(DPR)*/ +
      (getProperty("useExtendedCycles") ? (cycleSeparator + [xyzFormat.format(GMODE),
        xyzFormat.format(DMODE), xyzFormat.format(AMODE)].join(cycleSeparator)) : "")].join(cycleSeparator) + ")"
    );
    break;
  case "counter-boring":
    if (RTP > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    var GMODE = 0;
    var DMODE = 0; // keep the programmed plane active
    var AMODE = 10; // dwell is programmed in seconds and depth is taken from DP DPR settings
    writeBlock(
      "MCALL CYCLE82(" + [xyzFormat.format(RTP),
        xyzFormat.format(RFP),
        xyzFormat.format(SDIS),
        xyzFormat.format(DP),
        "" /*+ xyzFormat.format(DPR)*/,
        conditional(DTB > 0, secFormat.format(DTB)) +
      (getProperty("useExtendedCycles") ? (cycleSeparator + [xyzFormat.format(GMODE), xyzFormat.format(DMODE), xyzFormat.format(AMODE)].join(", ")) : "")].join(cycleSeparator) + ")"
    );
    break;
  case "chip-breaking":
    if (cycle.accumulatedDepth < cycle.depth) {
      expandCurrentCycle = true;
    } else {
      if (RTP > getCurrentPosition().z) {
        writeBlock(gMotionModal.format(0), zOutput.format(RTP));
      }
      // add support for accumulated depth
      var FDEP = cycle.stock - cycle.incrementalDepth;
      var FDPR = cycle.incrementalDepth; // relative to reference plane (unsigned)
      var DAM = cycle.incrementalDepthReduction; // degression (unsigned)
      var DTS = 0; // dwell time at start
      var FRF = 1; // feedrate factor (unsigned)
      var VARI = 0; // chip breaking
      var _AXN = 3; // tool axis
      var _MDEP = (cycle.incrementalDepthReduction > 0) ? cycle.minimumIncrementalDepth : cycle.incrementalDepth; // minimum drilling depth
      var _VRT = cycle.chipBreakDistance; // retraction distance
      var _DTD = (cycle.dwell != undefined) ? cycle.dwell : 0;
      var _DIS1 = 0; // limit distance
      var GMODE = 0; // drilling with respect to the tip
      var DMODE = 0; // keep the programmed plane active
      var AMODE = 1001110;

      writeBlock(
        "MCALL CYCLE83(" + [xyzFormat.format(RTP),
          xyzFormat.format(RFP),
          xyzFormat.format(SDIS),
          xyzFormat.format(DP),
          "" /*+ xyzFormat.format(DPR)*/,
          xyzFormat.format(FDEP),
          "" /*+ xyzFormat.format(FDPR)*/,
          xyzFormat.format(DAM),
          "" /*conditional(DTB > 0, secFormat.format(DTB))*/, // only dwell at bottom
          conditional(DTS > 0, secFormat.format(DTS)),
          xyzFormat.format(FRF),
          xyzFormat.format(VARI),
          ""/*_AXN +*/,
          xyzFormat.format(_MDEP),
          xyzFormat.format(_VRT),
          secFormat.format(_DTD),
          "0" + /*xyzFormat.format(_DIS1) +*/
        (getProperty("useExtendedCycles") ? (cycleSeparator + [xyzFormat.format(GMODE), xyzFormat.format(DMODE), xyzFormat.format(AMODE)].join(cycleSeparator)) : "")].join(cycleSeparator) + ")"
      );
    }
    break;
  case "deep-drilling":
    if (RTP > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    var FDEP = cycle.stock - cycle.incrementalDepth;
    var FDPR = cycle.incrementalDepth; // relative to reference plane (unsigned)
    var DAM = cycle.incrementalDepthReduction; // degression (unsigned)
    var DTS = 0; // dwell time at start
    var FRF = 1; // feedrate factor (unsigned)
    var VARI = 1; // full retract
    var _MDEP = (cycle.incrementalDepthReduction > 0) ? cycle.minimumIncrementalDepth : cycle.incrementalDepth; // minimum drilling depth
    var _VRT = cycle.chipBreakDistance ? cycle.chipBreakDistance : 0; // retraction distance
    var _DTD = (cycle.dwell != undefined) ? cycle.dwell : 0;
    var _DIS1 = 0; // limit distance
    var GMODE = 0; // drilling with respect to the tip
    var DMODE = 0; // keep the programmed plane active
    var AMODE = 1001110;
    writeBlock(
      "MCALL CYCLE83(" + [xyzFormat.format(RTP),
        xyzFormat.format(RFP),
        xyzFormat.format(SDIS),
        xyzFormat.format(DP),
        "" /*+ xyzFormat.format(DPR)*/,
        xyzFormat.format(FDEP),
        "" /*+ xyzFormat.format(FDPR)*/,
        xyzFormat.format(DAM),
        "" /*conditional(DTB > 0, secFormat.format(DTB))*/, // only dwell at bottom
        conditional(DTS > 0, secFormat.format(DTS)),
        xyzFormat.format(FRF),
        xyzFormat.format(VARI),
        "", /*_AXN */
        xyzFormat.format(_MDEP),
        xyzFormat.format(_VRT),
        secFormat.format(_DTD),
        "0" + /*xyzFormat.format(_DIS1)*/
      (getProperty("useExtendedCycles") ? (cycleSeparator + [xyzFormat.format(GMODE), xyzFormat.format(DMODE), xyzFormat.format(AMODE)].join(cycleSeparator)) : "")
      ].join(cycleSeparator) + ")"
    );

    break;
  case "tapping":
  case "left-tapping":
  case "right-tapping":
    if (RTP > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    var SDAC = SDIR; // direction of rotation after end of cycle
    var MPIT = 0; // thread pitch as thread size
    var PIT = ((tool.type == TOOL_TAP_LEFT_HAND) ? -1 : 1) * tool.threadPitch; // thread pitch
    var POSS = 0; // spindle position for oriented spindle stop in cycle (in degrees)
    var SST = spindleSpeed; // speed for tapping
    var SST1 = spindleSpeed; // speed for return
    writeBlock(
      "MCALL CYCLE84(" + [xyzFormat.format(RTP),
        xyzFormat.format(RFP),
        xyzFormat.format(SDIS),
        xyzFormat.format(DP),
        ""/*xyzFormat.format(DPR)*/,
        conditional(DTB > 0, secFormat.format(DTB)),
        xyzFormat.format(SDAC),
        ""/*+ xyzFormat.format(MPIT)*/,
        xyzFormat.format(PIT),
        xyzFormat.format(POSS),
        xyzFormat.format(SST),
        xyzFormat.format(SST1)].join(cycleSeparator) + ")"
    );
    break;
  case "tapping-with-chip-breaking":
    if (cycle.accumulatedDepth < cycle.depth) {
      error(localize("Accumulated pecking depth is not supported for canned tapping cycles with chip breaking."));
      return;
    }
    if (RTP > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    var SDAC = SDIR; // direction of rotation after end of cycle
    var MPIT = 0; // thread pitch as thread size
    var PIT = ((tool.type == TOOL_TAP_LEFT_HAND) ? -1 : 1) * tool.threadPitch; // thread pitch
    var POSS = 0; // spindle position for oriented spindle stop in cycle (in degrees)
    var SST = spindleSpeed; // speed for tapping
    var SST1 = spindleSpeed; // speed for return
    var _AXN = 0; // tool axis
    var _PTAB = 0; // must be 0
    var _TECHNO = 0; // technology settings
    var _VARI = 1; // machining type: 0 = tapping full depth, 1 = tapping partial retract, 2 = tapping full retract
    var _DAM = cycle.incrementalDepth; // incremental depth
    var _VRT = cycle.chipBreakDistance; // retract distance for chip breaking
    var _PITM = 0; // string for pitch input (not used)
    var _PITAB = 0; // string for thread table (not used)
    var _PITABA = 0; // string for selection from thread table (not used)
    var GMODE = 0; // reserved (geometrical mode)
    var DMODE = 0; // units and active spindle (0 for tool spindle, 100 for turning spindle)
    var AMODE = 0; // alternate mode

    writeBlock(
      "MCALL CYCLE84(" + [xyzFormat.format(RTP),
        xyzFormat.format(RFP),
        xyzFormat.format(SDIS),
        xyzFormat.format(DP),
        "" /*+ xyzFormat.format(DPR)*/,
        secFormat.format(DTB),
        xyzFormat.format(SDAC),
        "" /*+ xyzFormat.format(MPIT)*/,
        xyzFormat.format(PIT),
        xyzFormat.format(POSS),
        xyzFormat.format(SST),
        xyzFormat.format(SST1),
        xyzFormat.format(_AXN),
        xyzFormat.format(_PTAB),
        xyzFormat.format(_TECHNO),
        xyzFormat.format(_VARI),
        xyzFormat.format(_DAM),
        xyzFormat.format(_VRT)
      ].join(cycleSeparator) + ")"
    );
    break;
  case "reaming":
    if (RTP > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    var FFR = cycle.feedrate;
    var RFF = cycle.retractFeedrate;
    var GMODE = 0; // reserved
    var DMODE = 0; // keep current plane active
    var AMODE = 0; // compatibility from DP and DT programming
    writeBlock(
      "MCALL CYCLE85(" + [xyzFormat.format(RTP),
        xyzFormat.format(RFP),
        xyzFormat.format(SDIS),
        xyzFormat.format(DP),
        ""/*xyzFormat.format(DPR)*/,
        conditional(DTB > 0, secFormat.format(DTB)),
        xyzFormat.format(FFR),
        xyzFormat.format(RFF) +
        (getProperty("useExtendedCycles") ? (cycleSeparator + [xyzFormat.format(GMODE), xyzFormat.format(DMODE), xyzFormat.format(AMODE)].join(cycleSeparator)) : "")
      ].join(cycleSeparator) + ")"
    );
    break;
  case "stop-boring":
    if (cycle.dwell > 0) {
      expandCurrentCycle = true;
    } else {
      if (RTP > getCurrentPosition().z) {
        writeBlock(gMotionModal.format(0), zOutput.format(RTP));
      }
      writeBlock(
        "MCALL CYCLE87(" + [xyzFormat.format(RTP),
          xyzFormat.format(RFP),
          xyzFormat.format(SDIS),
          xyzFormat.format(DP),
          "" /*+ xyzFormat.format(DPR)*/,
          SDIR].join(cycleSeparator) + ")"
      );
    }
    break;
  case "fine-boring":
    if (RTP > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    var RPA = 0; // return path in abscissa of the active plane (enter incrementally with)
    var RPO = 0; // return path in the ordinate of the active plane (enter incrementally sign)
    var RPAP = 0; // return plane in the applicate (enter incrementally with sign)
    var POSS = 0; // spindle position for oriented spindle stop in cycle (in degrees)
    var GMODE = 0; // lift off
    var DMODE = 0; // keep current plane active
    var AMODE = 10; // dwell in seconds and keep units abs/inc setting from DP/DPR
    writeBlock(
      "MCALL CYCLE86(" + [xyzFormat.format(RTP),
        xyzFormat.format(RFP),
        xyzFormat.format(SDIS),
        xyzFormat.format(DP),
        "" /*+ xyzFormat.format(DPR)*/,
        conditional(DTB > 0, secFormat.format(DTB)),
        SDIR,
        xyzFormat.format(RPA),
        xyzFormat.format(RPO),
        xyzFormat.format(RPAP),
        xyzFormat.format(POSS) +
      (getProperty("useExtendedCycles") ? (cycleSeparator + [xyzFormat.format(GMODE), xyzFormat.format(DMODE), xyzFormat.format(AMODE)].join(cycleSeparator)) : "")
      ].join(cycleSeparator) + ")"
    );
    break;
  case "back-boring":
    expandCurrentCycle = true;
    break;
  case "manual-boring":
    if (RTP > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    writeBlock(
      "MCALL CYCLE88(" + [xyzFormat.format(RTP),
        xyzFormat.format(RFP),
        xyzFormat.format(SDIS),
        xyzFormat.format(DP),
        "" /*+ xyzFormat.format(DPR)*/,
        conditional(DTB > 0, secFormat.format(DTB)),
        SDIR].join(cycleSeparator) + ")"
    );
    break;
  case "boring":
    if (feedFormat.getResultingValue(cycle.feedrate) != feedFormat.getResultingValue(cycle.retractFeedrate)) {
      expandCurrentCycle = true;
      break;
    }
    if (RTP > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    // retract feed is ignored
    writeBlock(
      "MCALL CYCLE89(" + [xyzFormat.format(RTP),
        xyzFormat.format(RFP),
        xyzFormat.format(SDIS),
        xyzFormat.format(DP),
        "" /*+ xyzFormat.format(DPR)*/,
        conditional(DTB > 0, secFormat.format(DTB))].join(cycleSeparator) + ")"
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
    var _FA = (!singleLine ? "_FA=" : "") + // measuring range (distance to surface), total measuring range=2*_FA
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
  writeBlock(gPlaneModal.format(17));

  var start = getCurrentPosition();
  var revolutions = Math.abs(getCircularSweep()) / (2 * Math.PI);
  var turns = useArcTurn ? (revolutions % 1) == 0 ? revolutions - 1 : Math.floor(revolutions) : 0; // full turns

  if (isFullCircle()) {
    if (isHelical()) {
      linearize(tolerance);
      return;
    }
    if (turns > 1) {
      error(localize("Multiple turns are not supported."));
      return;
    }
    // G90/G91 are dont care when we do not used XYZ
    switch (getCircularPlane()) {
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
      writeBlock(gMotionModal.format(clockwise ? 2 : 3), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    case PLANE_YZ:
      if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
        if ((gPlaneModal.getCurrent() !== null) && (gPlaneModal.getCurrent() != 19)) {
          error(localize("Plane cannot be changed when radius compensation is active."));
          return;
        }
      }
      writeBlock(gMotionModal.format(clockwise ? 2 : 3), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else if (useArcTurn) { // IJK mode
    if (isHelical()) {
      forceXYZ();
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
        if ((gPlaneModal.getCurrent() !== null) && (gPlaneModal.getCurrent() != 17)) {
          error(localize("Plane cannot be changed when radius compensation is active."));
          return;
        }
      }
      // arFormat.format(Math.abs(getCircularSweep()));
      if (turns > 0) {
        writeBlock(gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed), "TURN=" + turns);
      } else {
        writeBlock(gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed));
      }
      break;
    case PLANE_ZX:
      if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
        if ((gPlaneModal.getCurrent() !== null) && (gPlaneModal.getCurrent() != 18)) {
          error(localize("Plane cannot be changed when radius compensation is active."));
          return;
        }
      }
      if (turns > 0) {
        writeBlock(gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed), "TURN=" + turns);
      } else {
        writeBlock(gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      }
      break;
    case PLANE_YZ:
      if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
        if ((gPlaneModal.getCurrent() !== null) && (gPlaneModal.getCurrent() != 19)) {
          error(localize("Plane cannot be changed when radius compensation is active."));
          return;
        }
      }
      if (turns > 0) {
        writeBlock(gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed), "TURN=" + turns);
      } else {
        writeBlock(gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      }
      break;
    default:
      if (turns > 1) {
        error(localize("Multiple turns are not supported."));
        return;
      }
      if (getProperty("useCIP")) { // allow CIP
        var ip = getPositionU(0.5);
        writeBlock(
          "CIP",
          xOutput.format(x),
          yOutput.format(y),
          zOutput.format(z),
          "I1=" + xyzFormat.format(ip.x),
          "J1=" + xyzFormat.format(ip.y),
          "K1=" + xyzFormat.format(ip.z),
          getFeed(feed)
        );
        gMotionModal.reset();
        gPlaneModal.reset();
      } else {
        linearize(tolerance);
      }
    }
  } else { // use radius mode
    if (isHelical()) {
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
      writeBlock(gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    case PLANE_YZ:
      writeBlock(gMotionModal.format(clockwise ? 2 : 3), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    default:
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
    return;
  case COMMAND_UNLOCK_MULTI_AXIS:
    return;
  case COMMAND_START_CHIP_TRANSPORT:
    return;
  case COMMAND_STOP_CHIP_TRANSPORT:
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
  if (currentSection.isMultiAxis()) {
    if (operationSupportsTCP || !machineConfiguration.isMultiAxisConfiguration()) {
      writeBlock("TRAFOOF");
    }
    writeBlock(gFeedModeModal.format(94)); // inverse time feed off
  }
  if (!isLastSection() && (getNextSection().getTool().coolant != tool.coolant)) {
    setCoolant(COOLANT_OFF);
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
    _xHome = machineConfiguration.hasHomePositionX() ? machineConfiguration.getHomePositionX() : toPreciseUnit(0, MM);
    _yHome = machineConfiguration.hasHomePositionY() ? machineConfiguration.getHomePositionY() : toPreciseUnit(0, MM);
    _zHome = machineConfiguration.getRetractPlane() != 0 ? machineConfiguration.getRetractPlane() : toPreciseUnit(0, MM);
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
      break;
    case "SUPA":
      gMotionModal.reset();
      writeBlock(gMotionModal.format(0), "SUPA", words, dFormat.format(0)); // retract
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
  var lengthOffset = 1; // optional, use tool.lengthOffset instead
  if (lengthOffset > 99) {
    error(localize("Length offset out of range."));
    return;
  }
  writeBlock(dFormat.format(lengthOffset));
  if (operationSupportsTCP || !machineConfiguration.isMultiAxisConfiguration()) {
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

function onClose() {
  writeln("");

  writeRetract(Z);

  setWorkPlane(new Vector(0, 0, 0), true); // reset working plane

  if (getProperty("useParkPosition")) {
    writeRetract(X, Y);
  }

  onImpliedCommand(COMMAND_END);
  onImpliedCommand(COMMAND_STOP_SPINDLE);
  writeBlock(mFormat.format(30)); // stop program, spindle stop, coolant off
  if (subprograms.length > 0) {
    writeln("");
    write(subprograms);
  }
}

function setProperty(property, value) {
  properties[property].current = value;
}
