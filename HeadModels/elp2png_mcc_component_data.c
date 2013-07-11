/*
 * MATLAB Compiler: 4.4 (R2006a)
 * Date: Tue Feb 10 18:16:23 2009
 * Arguments: "-B" "macro_default" "-m" "-W" "main" "-T" "link:exe" "elp2png.m" 
 */

#include "mclmcr.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_elp2png_session_key[] = {
        '8', '8', '4', '7', '8', 'F', '8', '5', '2', '0', '4', '5', '5', 'B',
        '8', '5', 'A', '2', 'E', '9', 'F', 'D', '1', '3', 'D', 'A', '0', 'A',
        '1', '3', '9', 'D', '4', '0', '6', '9', '9', '2', '2', '6', 'A', '4',
        '1', '1', '8', '0', 'A', 'B', 'A', 'D', '4', '7', '8', 'D', 'E', '9',
        '6', 'C', 'A', '8', '9', 'E', 'A', '7', '6', 'F', '6', '8', 'D', 'C',
        '3', '1', '7', '0', 'B', '1', 'A', '9', 'B', '7', '8', 'B', 'B', '2',
        '6', '3', 'D', 'F', 'D', '7', 'C', 'F', 'F', '3', '4', '8', '4', 'F',
        '4', '4', 'D', '5', '1', 'D', '4', 'D', 'F', 'A', '2', '4', '2', '8',
        '0', '0', '7', '3', '8', '7', '2', 'B', 'C', '7', '3', 'C', '4', '5',
        '5', 'B', '5', '0', '3', '9', '6', '9', 'E', 'E', '1', '1', '0', 'A',
        '7', '6', '8', '2', 'B', '9', 'F', '7', 'E', '9', 'C', '9', '3', 'C',
        '9', '2', '4', 'A', '1', '2', 'A', 'C', 'F', 'F', 'A', '9', 'A', '0',
        '6', '7', '7', 'A', 'F', '4', '1', '3', 'A', 'F', '1', '4', 'B', 'A',
        '3', '0', 'F', 'D', '4', '3', '6', '8', 'E', '8', '1', '2', '1', '6',
        '1', '5', '6', '0', '3', '2', '5', '1', 'B', '3', '8', 'F', 'A', '8',
        '1', 'F', '0', '3', '6', 'F', 'D', '8', '8', 'B', 'F', '5', '0', '8',
        'F', '8', 'A', '7', '9', '9', 'F', '6', '7', 'E', 'D', '3', 'F', 'F',
        '9', '3', 'E', '7', 'B', 'B', 'C', '7', '1', 'B', '1', '2', '8', '3',
        '1', '1', 'D', '2', '\0'};

const unsigned char __MCC_elp2png_public_key[] = {
        '3', '0', '8', '1', '9', 'D', '3', '0', '0', 'D', '0', '6', '0', '9',
        '2', 'A', '8', '6', '4', '8', '8', '6', 'F', '7', '0', 'D', '0', '1',
        '0', '1', '0', '1', '0', '5', '0', '0', '0', '3', '8', '1', '8', 'B',
        '0', '0', '3', '0', '8', '1', '8', '7', '0', '2', '8', '1', '8', '1',
        '0', '0', 'C', '4', '9', 'C', 'A', 'C', '3', '4', 'E', 'D', '1', '3',
        'A', '5', '2', '0', '6', '5', '8', 'F', '6', 'F', '8', 'E', '0', '1',
        '3', '8', 'C', '4', '3', '1', '5', 'B', '4', '3', '1', '5', '2', '7',
        '7', 'E', 'D', '3', 'F', '7', 'D', 'A', 'E', '5', '3', '0', '9', '9',
        'D', 'B', '0', '8', 'E', 'E', '5', '8', '9', 'F', '8', '0', '4', 'D',
        '4', 'B', '9', '8', '1', '3', '2', '6', 'A', '5', '2', 'C', 'C', 'E',
        '4', '3', '8', '2', 'E', '9', 'F', '2', 'B', '4', 'D', '0', '8', '5',
        'E', 'B', '9', '5', '0', 'C', '7', 'A', 'B', '1', '2', 'E', 'D', 'E',
        '2', 'D', '4', '1', '2', '9', '7', '8', '2', '0', 'E', '6', '3', '7',
        '7', 'A', '5', 'F', 'E', 'B', '5', '6', '8', '9', 'D', '4', 'E', '6',
        '0', '3', '2', 'F', '6', '0', 'C', '4', '3', '0', '7', '4', 'A', '0',
        '4', 'C', '2', '6', 'A', 'B', '7', '2', 'F', '5', '4', 'B', '5', '1',
        'B', 'B', '4', '6', '0', '5', '7', '8', '7', '8', '5', 'B', '1', '9',
        '9', '0', '1', '4', '3', '1', '4', 'A', '6', '5', 'F', '0', '9', '0',
        'B', '6', '1', 'F', 'C', '2', '0', '1', '6', '9', '4', '5', '3', 'B',
        '5', '8', 'F', 'C', '8', 'B', 'A', '4', '3', 'E', '6', '7', '7', '6',
        'E', 'B', '7', 'E', 'C', 'D', '3', '1', '7', '8', 'B', '5', '6', 'A',
        'B', '0', 'F', 'A', '0', '6', 'D', 'D', '6', '4', '9', '6', '7', 'C',
        'B', '1', '4', '9', 'E', '5', '0', '2', '0', '1', '1', '1', '\0'};

static const char * MCC_elp2png_matlabpath_data[] = 
    { "elp2png/", "toolbox/compiler/deploy/",
      "$TOOLBOXMATLABDIR/audiovideo/", "$TOOLBOXMATLABDIR/codetools/",
      "$TOOLBOXMATLABDIR/datafun/", "$TOOLBOXMATLABDIR/datatypes/",
      "$TOOLBOXMATLABDIR/demos/", "$TOOLBOXMATLABDIR/elfun/",
      "$TOOLBOXMATLABDIR/elmat/", "$TOOLBOXMATLABDIR/funfun/",
      "$TOOLBOXMATLABDIR/general/", "$TOOLBOXMATLABDIR/graph2d/",
      "$TOOLBOXMATLABDIR/graph3d/", "$TOOLBOXMATLABDIR/graphics/",
      "$TOOLBOXMATLABDIR/guide/", "$TOOLBOXMATLABDIR/hds/",
      "$TOOLBOXMATLABDIR/helptools/", "$TOOLBOXMATLABDIR/imagesci/",
      "$TOOLBOXMATLABDIR/iofun/", "$TOOLBOXMATLABDIR/lang/",
      "$TOOLBOXMATLABDIR/matfun/", "$TOOLBOXMATLABDIR/ops/",
      "$TOOLBOXMATLABDIR/plottools/", "$TOOLBOXMATLABDIR/polyfun/",
      "$TOOLBOXMATLABDIR/scribe/", "$TOOLBOXMATLABDIR/sparfun/",
      "$TOOLBOXMATLABDIR/specfun/", "$TOOLBOXMATLABDIR/specgraph/",
      "$TOOLBOXMATLABDIR/strfun/", "$TOOLBOXMATLABDIR/timefun/",
      "$TOOLBOXMATLABDIR/timeseries/", "$TOOLBOXMATLABDIR/uitools/",
      "$TOOLBOXMATLABDIR/verctrl/", "$TOOLBOXMATLABDIR/winfun/",
      "toolbox/local/", "toolbox/compiler/", "toolbox/shared/optimlib/" };

static const char * MCC_elp2png_classpath_data[] = 
    { "" };

static const char * MCC_elp2png_libpath_data[] = 
    { "" };

static const char * MCC_elp2png_app_opts_data[] = 
    { "" };

static const char * MCC_elp2png_run_opts_data[] = 
    { "" };

static const char * MCC_elp2png_warning_state_data[] = 
    { "" };


mclComponentData __MCC_elp2png_component_data = { 

    /* Public key data */
    __MCC_elp2png_public_key,

    /* Component name */
    "elp2png",

    /* Component Root */
    "",

    /* Application key data */
    __MCC_elp2png_session_key,

    /* Component's MATLAB Path */
    MCC_elp2png_matlabpath_data,

    /* Number of directories in the MATLAB Path */
    37,

    /* Component's Java class path */
    MCC_elp2png_classpath_data,
    /* Number of directories in the Java class path */
    0,

    /* Component's load library path (for extra shared libraries) */
    MCC_elp2png_libpath_data,
    /* Number of directories in the load library path */
    0,

    /* MCR instance-specific runtime options */
    MCC_elp2png_app_opts_data,
    /* Number of MCR instance-specific runtime options */
    0,

    /* MCR global runtime options */
    MCC_elp2png_run_opts_data,
    /* Number of MCR global runtime options */
    0,
    
    /* Component preferences directory */
    "elp2png_E9B0D90E49C3004F66B41CF8FA43FE0E",

    /* MCR warning status data */
    MCC_elp2png_warning_state_data,
    /* Number of MCR warning status modifiers */
    0,

    /* Path to component - evaluated at runtime */
    NULL

};

#ifdef __cplusplus
}
#endif


