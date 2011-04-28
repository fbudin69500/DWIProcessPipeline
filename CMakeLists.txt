cmake_minimum_required(VERSION 2.8)
CMAKE_POLICY(VERSION 2.8)

project (DWIResamplingSlicer3Module)

IF(CMAKE_COMPILER_2005)
  ADD_DEFINITIONS(-D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE)
ENDIF(CMAKE_COMPILER_2005)

IF (${CMAKE_SOURCE_DIR} STREQUAL ${DWIResamplingSlicer3Module_SOURCE_DIR})
  SET (LIBRARY_OUTPUT_PATH ${DWIResamplingSlicer3Module_BINARY_DIR}/lib CACHE PATH "Single output directory for building all libraries.")
  SET (EXECUTABLE_OUTPUT_PATH ${DWIResamplingSlicer3Module_BINARY_DIR}/bin CACHE PATH "Single output directory for building all executables.")
ENDIF (${CMAKE_SOURCE_DIR} STREQUAL ${DWIResamplingSlicer3Module_SOURCE_DIR})


FIND_PACKAGE(Slicer3 QUIET NO_DEFAULT_PATH)
IF (Slicer3_FOUND)
  INCLUDE(${Slicer3_USE_FILE})
  slicer3_set_default_install_prefix_for_external_projects()
  if( NOT GenerateCLP_FOUND)
    message( FATAL_ERROR "GenerateCLP not found. Please set GenerateCLP_DIR. " )
  endif(NOT GenerateCLP_FOUND)
  if(NOT BatchMake_FOUND )
    message( FATAL_ERROR "BatchMake not found. Please set BatchMake_DIR. " )
  endif(NOT BatchMake_FOUND )
  if(NOT ITK_FOUND )
    message( FATAL_ERROR "ITK not found. Please set ITK_DIR. " )
  endif(NOT ITK_FOUND )
ELSE (Slicer3_FOUND)
  find_package(ITK REQUIRED)
  include(${ITK_USE_FILE})
  find_package(BatchMake REQUIRED)
  include(${BatchMake_USE_FILE})
  find_package(GenerateCLP REQUIRED)
  if(GenerateCLP_FOUND)
    include(${GenerateCLP_USE_FILE})
  endif(GenerateCLP_FOUND)
ENDIF (Slicer3_FOUND)

#Find tools

macro( FindSlicerTools path name )
  find_program(${path} ${name} )
  if(NOT ${path} )
    IF(Slicer3_FOUND)
      set( ${path} ${Slicer3_HOME}/${Slicer3_INSTALL_PLUGINS_BIN_DIR}/${name} )
    else(Slicer3_FOUND)
      message( WARNING "${name} not found. Its path is not set" )
    endIF (Slicer3_FOUND)
  endif(NOT ${path} )
endmacro( FindSlicerTools )

set( COMPILE_NEUROLIB OFF )
OPTION(USE_LOG_EUCLIDEAN "Use ResampleDTIlogEuclidean" OFF)
if( USE_LOG_EUCLIDEAN )
#  unset( RESAMPLEDTILOGEUCLIDEANTOOL CACHE )
  find_program(RESAMPLEDTILOGEUCLIDEANTOOL ResampleDTIlogEuclidean )
  if(NOT RESAMPLEDTILOGEUCLIDEANTOOL )
    message( WARNING "ResampleDTIlogEuclidean not found. CMake external used to download it and compile it" )
    set( COMPILE_LOG ON )
    set( COMPILE_NEUROLIB ON )
    set( RESAMPLEDTILOGEUCLIDEANTOOL ${DWIResamplingSlicer3Module_BINARY_DIR}/bin/ResampleDTIlogEuclidean )
  else( NOT RESAMPLEDTILOGEUCLIDEANTOOL )
    set( COMPILE_LOG OFF )
  endif(NOT RESAMPLEDTILOGEUCLIDEANTOOL )
endif( USE_LOG_EUCLIDEAN )
#  unset( RESAMPLEDTITOOL CACHE )

FindSlicerTools( RESAMPLEDTITOOL ResampleDTI )
#find_program(RESAMPLEDTITOOL ResampleDTI )
#if(NOT RESAMPLEDTITOOL )
#  IF(Slicer3_FOUND)
#    set( RESAMPLEDTITOOL ${Slicer3_HOME}/${Slicer3_INSTALL_PLUGINS_BIN_DIR}/ResampleDTI )
#  else(Slicer3_FOUND)
#    message( WARNING "ResampleDTI not found. Its path is not set" )
#  endIF (Slicer3_FOUND)
#endif(NOT RESAMPLEDTITOOL )



find_program(ITKTRANSFORMTOOLSTOOL ITKTransformTools )
if(NOT ITKTRANSFORMTOOLSTOOL )
  message( WARNING "ITKTransformTools not found. CMake external used to download it and compile it" )
  set( COMPILE_NEUROLIB ON )
  set( ITKTRANSFORMTOOLSTOOL ${DWIResamplingSlicer3Module_BINARY_DIR}/bin/ITKTransformTools )
endif(NOT ITKTRANSFORMTOOLSTOOL )

find_program(ImageMathTOOL ImageMath )
if(NOT ImageMathTOOL )
  message( WARNING "ImageMath not found. CMake external used to download it and compile it" )
  set( COMPILE_NEUROLIB ON )
  set( ImageMathTOOL ${DWIResamplingSlicer3Module_BINARY_DIR}/bin/ImageMath )
endif(NOT ImageMathTOOL )

find_program(REGISTERIMAGESTOOL RegisterImages )
if(NOT REGISTERIMAGESTOOL )
  IF(Slicer3_FOUND)
    set( REGISTERIMAGESTOOL ${Slicer3_HOME}/${Slicer3_INSTALL_PLUGINS_BIN_DIR}/RegisterImages )
  else(Slicer3_FOUND)
    message( WARNING "RegisterImages not found. Its path is not set" )
  endIF (Slicer3_FOUND)
endif(NOT REGISTERIMAGESTOOL )

find_program(HistogramMatchingTOOL HistogramMatching )
if(NOT HistogramMatchingTOOL )
  IF(Slicer3_FOUND)
    set( HistogramMatchingTOOL ${Slicer3_HOME}/${Slicer3_INSTALL_PLUGINS_BIN_DIR}/HistogramMatching )
  else(Slicer3_FOUND)
    message( WARNING "HistogramMatching not found. Its path is not set" )
  endIF (Slicer3_FOUND)
endif(NOT HistogramMatchingTOOL )

find_program(RESAMPLEVOLUME2TOOL ResampleVolume2 )
if(NOT RESAMPLEVOLUME2TOOL )
  IF(Slicer3_FOUND)
    set( RESAMPLEVOLUME2TOOL ${Slicer3_HOME}/${Slicer3_INSTALL_PLUGINS_BIN_DIR}/ResampleVolume2 )
  else(Slicer3_FOUND)
    message( WARNING "ResampleVolume2 not found. Its path is not set" )
  endIF (Slicer3_FOUND)
endif(NOT RESAMPLEVOLUME2TOOL )

find_program(DIFFUSIONTENSORESTIMATIONTOOL DiffusionTensorEstimation )
if(NOT DIFFUSIONTENSORESTIMATIONTOOL )
  IF(Slicer3_FOUND)
    set( DIFFUSIONTENSORESTIMATIONTOOL ${Slicer3_HOME}/${Slicer3_INSTALL_PLUGINS_BIN_DIR}/DiffusionTensorEstimation )
  else(Slicer3_FOUND)
    message( WARNING "DiffusionTensorEstimation not found. Its path is not set" )
  endIF (Slicer3_FOUND)
endif(NOT DIFFUSIONTENSORESTIMATIONTOOL )

find_program(COMPUTEORIENTATIONTOOL ManualImageOrient )
if( NOT COMPUTEORIENTATIONTOOL )
  message( WARNING "ManualImageOrient not found. CMake external used to download it and compile it" )
  set( ManualImageOrientexternal ON )
  set( COMPUTEORIENTATIONTOOL ${DWIResamplingSlicer3Module_BINARY_DIR}/bin/ManualImageOrient )
else( NOT COMPUTEORIENTATIONTOOL )
  set( ManualImageOrientexternal OFF )
endif( NOT COMPUTEORIENTATIONTOOL )

find_program(CREATEMRMLTOOL CreateMRML )
if(NOT CREATEMRMLTOOL )
  IF(Slicer3_FOUND)
    message( WARNING "CreateMRML not found. CMake external used to download it and compile it" )
    set( CreateMRMLexternal ON )
    set( CREATEMRMLTOOL ${Slicer3_HOME}/${Slicer3_INSTALL_PLUGINS_BIN_DIR}/CreateMRML )
  else(Slicer3_FOUND)
    message( WARNING "CreateMRML not found and will not be downloaded and compiled. Its path is not set" )
    set( CreateMRMLexternal OFF )
  endIF (Slicer3_FOUND)
else(NOT CREATEMRMLTOOL )
  set( CreateMRMLexternal OFF )
endif(NOT CREATEMRMLTOOL )

find_program(MaskTOOL MaskComputationWithThresholding )
if( NOT MaskTOOL )
  message( WARNING "MaskComputationWithThresholding not found. CMake external used to download it and compile it" )
  set( MaskTOOLexternal ON )
  set( MaskTOOL ${DWIResamplingSlicer3Module_BINARY_DIR}/bin/MaskComputationWithThresholding )
else( NOT MaskTOOL )
  set( MaskTOOLexternal OFF )
endif( NOT MaskTOOL )

set( COMPILE_DTIPROCESS OFF )

find_program(DTIESTIMTOOL dtiestim )
if(NOT DTIESTIMTOOL )
  message( WARNING "dtiestim not found. CMake external used to download it and compile it" )
  set( COMPILE_DTIPROCESS ON )
  set( DTIESTIMTOOL ${DWIResamplingSlicer3Module_BINARY_DIR}/bin/dtiestim )
endif(NOT DTIESTIMTOOL )

find_program(DTIPROCESSTOOL dtiprocess )
if(NOT DTIPROCESSTOOL )
  message( WARNING "dtiprocess not found. CMake external used to download it and compile it" )
  set( COMPILE_DTIPROCESS ON )
  set( DTIPROCESSTOOL ${DWIResamplingSlicer3Module_BINARY_DIR}/bin/dtiprocess )
endif(NOT DTIPROCESSTOOL )

# Configure a header
if(WIN32)
   set(BatchMake_WRAPPED_APPLICATION_DIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE})
else(WIN32)
   set(BatchMake_WRAPPED_APPLICATION_DIR ${CMAKE_CURRENT_BINARY_DIR})
endif(WIN32)

configure_file( "${CMAKE_CURRENT_SOURCE_DIR}/BatchMakeScript.bms.in"
      "${BatchMake_WRAPPED_APPLICATION_DIR}/BatchMakeScript.bms" COPYONLY )
configure_file( "${CMAKE_CURRENT_SOURCE_DIR}/Prepare.bms.in"
      "${BatchMake_WRAPPED_APPLICATION_DIR}/Prepare.bms" COPYONLY )
configure_file( "${CMAKE_CURRENT_SOURCE_DIR}/Registration.bms.in"
      "${BatchMake_WRAPPED_APPLICATION_DIR}/Registration.bms" COPYONLY )
configure_file( "${CMAKE_CURRENT_SOURCE_DIR}/Transform.bms.in"
      "${BatchMake_WRAPPED_APPLICATION_DIR}/Transform.bms" COPYONLY )
configure_file( "${CMAKE_CURRENT_SOURCE_DIR}/PostProcessing.bms.in"
      "${BatchMake_WRAPPED_APPLICATION_DIR}/PostProcessing.bms" COPYONLY )
configure_file( "${CMAKE_CURRENT_SOURCE_DIR}/CreateMRMLScene.bms.in"
      "${BatchMake_WRAPPED_APPLICATION_DIR}/CreateMRMLScene.bms" COPYONLY )
configure_file( "${CMAKE_CURRENT_SOURCE_DIR}/MaskImage.bms.in"
      "${BatchMake_WRAPPED_APPLICATION_DIR}/MaskImage.bms" COPYONLY )
configure_file( "${CMAKE_CURRENT_SOURCE_DIR}/SlicerBatchMakeConfig.h.in"
      "${CMAKE_CURRENT_BINARY_DIR}/SlicerBatchMakeConfig.h")


# Set the name of the Slicer3 BatchMake module to be created
set(Slicer3BatchModule DWIResamplingSlicer3Module)

# Set the source code for the Slicer3 BatchMake module
set(Slicer3BatchModule_SOURCE DWIResamplingSlicer3Module.cxx)





generateclp(Slicer3BatchModule_SOURCE   ${Slicer3BatchModule}.xml )

#Do not compile as a library. We need the image files to be saved on the hard drive.
add_executable( ${Slicer3BatchModule} ${Slicer3BatchModule_SOURCE} )
target_link_libraries( ${Slicer3BatchModule} BatchMakeLib )

#FIND_PACKAGE(Subversion)
#IF(NOT Subversion_FOUND)
#  MESSAGE(FATAL_ERROR "error: Install SVN and try to re-configure")
#ENDIF()


#--------COMPILE DWIResamplingSlicer3Module AS STANDALONE PACKAGE--------
OPTION(COMPILE_EXTERNAL_PROJECTS "Compile External Projects." ON)
IF(COMPILE_EXTERNAL_PROJECTS)

  #External Projects
  include(ExternalProject)
  if(CMAKE_EXTRA_GENERATOR)
    set(gen "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
  else()
    set(gen "${CMAKE_GENERATOR}")
  endif()
  OPTION(COMPILE_EXTERNAL_NEUROLib "Compile External NEUROLib" ${COMPILE_NEUROLIB} )
  IF(COMPILE_EXTERNAL_NEUROLib)
    # Build NeuroLib cvs -d :pserver:anonymous@demeter.ia.unc.edu:/cvsroot
    set(proj NeuroLib)
      ExternalProject_Add(${proj}
        CVS_REPOSITORY ":pserver:anonymous@demeter.ia.unc.edu:/cvsroot/"
        CVS_MODULE ${proj}
        SOURCE_DIR ${proj}
        BINARY_DIR ${proj}-build
        DEPENDS  ${ITK_DEPEND}
        CMAKE_GENERATOR ${gen}
        CMAKE_ARGS
          ${LOCAL_CMAKE_BUILD_OPTIONS}
          -DITK_DIR:PATH=${ITK_DIR}
          -DGenerateCLP_DIR:PATH=${GenerateCLP_DIR}
          -DModuleDescriptionParser_DIR:PATH=${ModuleDescriptionParser_DIR}
          -DTCLAP_DIR:PATH=${TCLAP_DIR}
          -DCOMPILE_NeuroLib_LIBS:BOOL=OFF
          -DCOMPILE_ITKTransformTools:BOOL=ON
          -DUSE_ITK_LIBRARY:BOOL=ON
          -DCOMPILE_ResampleDTI-LogEuclidean:BOOL=${COMPILE_LOG}
          -DCOMPILE_IMAGEMATH:BOOL=ON
          -DCOMPILE_NeuroLib_APPLICATIONS:BOOL=ON
          -DSTATIC_RESAMPLEDTI:BOOL=OFF
          -DSlicer3_FOUND:BOOL=TRUE
          -DSlicer3_USE_FILE:PATH=${Slicer3_USE_FILE}
          -DSlicer3_DIR:PATH=${Slicer3_DIR}
          -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
          -DEXECUTABLE_OUTPUT_PATH:PATH=${DWIResamplingSlicer3Module_BINARY_DIR}/bin
      INSTALL_COMMAND ""
      )
  ENDIF(COMPILE_EXTERNAL_NEUROLib)
  OPTION(COMPILE_EXTERNAL_CreateMRML "Compile External CreateMRML" ${CreateMRMLexternal})
  IF(COMPILE_EXTERNAL_CreateMRML)
    set(proj CreateMRML)
      ExternalProject_Add(${proj}
        GIT_REPOSITORY "git://github.com/booboo69500/CreateMRML.git"
        SOURCE_DIR ${proj}
        BINARY_DIR ${proj}-build
        DEPENDS  ${ITK_DEPEND}
        CMAKE_GENERATOR ${gen}
        CMAKE_ARGS
          ${LOCAL_CMAKE_BUILD_OPTIONS}
          -DSlicer3_FOUND:BOOL=TRUE
          -DSlicer3_USE_FILE:PATH=${Slicer3_USE_FILE}
          -DSlicer3_DIR:PATH=${Slicer3_DIR}
          -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
          -DEXECUTABLE_OUTPUT_PATH:PATH=${DWIResamplingSlicer3Module_BINARY_DIR}/bin
      INSTALL_COMMAND ""
      )
  ENDIF(COMPILE_EXTERNAL_CreateMRML)
  OPTION(COMPILE_EXTERNAL_dtiprocess "Compile External dtiprocessToolkit" ${COMPILE_DTIPROCESS} )
  IF(COMPILE_EXTERNAL_dtiprocess)
    if(NOT Slicer3_FOUND)
      find_package(VTK REQUIRED)
      include(${VTK_USE_FILE})
    endif(NOT Slicer3_FOUND)
    set(proj dtiprocessTK)
      ExternalProject_Add(${proj}
        SVN_REPOSITORY "https://www.nitrc.org/svn/dtiprocess/trunk"
        SVN_USERNAME slicerbot
        SVN_PASSWORD slicer
        SOURCE_DIR ${proj}
        BINARY_DIR ${proj}-build
        DEPENDS  ${ITK_DEPEND}
        CMAKE_GENERATOR ${gen}
        CMAKE_ARGS
          ${LOCAL_CMAKE_BUILD_OPTIONS}
          -DBUILD_TESTING:BOOL=OFF
          -DVTK_DIR:PATH=${VTK_DIR}
          -DGenerateCLP_DIR:PATH=${GenerateCLP_DIR}
          -DModuleDescriptionParser_DIR:PATH=${ModuleDescriptionParser_DIR}
          -DTCLAP_DIR:PATH=${TCLAP_DIR}
          -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
          -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${DWIResamplingSlicer3Module_BINARY_DIR}/bin
      INSTALL_COMMAND ""
      )
  ENDIF(COMPILE_EXTERNAL_dtiprocess)
  OPTION(COMPILE_EXTERNAL_ManualImageOrient "Compile External ManualImageOrient" ${ManualImageOrientexternal})
  IF(COMPILE_EXTERNAL_ManualImageOrient)
    set(proj ManualImageOrient)
      ExternalProject_Add(${proj}
        GIT_REPOSITORY "git://github.com/booboo69500/ManualImageOrient.git"
        SOURCE_DIR ${proj}
        BINARY_DIR ${proj}-build
        DEPENDS  ${ITK_DEPEND}
        CMAKE_GENERATOR ${gen}
        CMAKE_ARGS
          ${LOCAL_CMAKE_BUILD_OPTIONS}
          -DITK_DIR:PATH=${ITK_DIR}
          -DGenerateCLP_DIR:PATH=${GenerateCLP_DIR}
          -DModuleDescriptionParser_DIR:PATH=${ModuleDescriptionParser_DIR}
          -DTCLAP_DIR:PATH=${TCLAP_DIR}
          -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
          -DEXECUTABLE_OUTPUT_PATH:PATH=${DWIResamplingSlicer3Module_BINARY_DIR}/bin
      INSTALL_COMMAND ""
      )
  ENDIF(COMPILE_EXTERNAL_ManualImageOrient)
  OPTION(COMPILE_EXTERNAL_MaskComputationWithThresholding "Compile External MaskComputationWithThresholding" ${MaskTOOLexternal})
  IF(COMPILE_EXTERNAL_MaskComputationWithThresholding)
    set(proj MaskComputationWithThresholding)
      ExternalProject_Add(${proj}
        GIT_REPOSITORY "git://github.com/booboo69500/MaskComputationWithThresholding.git"
        SOURCE_DIR ${proj}
        BINARY_DIR ${proj}-build
        DEPENDS  ${ITK_DEPEND}
        CMAKE_GENERATOR ${gen}
        CMAKE_ARGS
          ${LOCAL_CMAKE_BUILD_OPTIONS}
          -DITK_DIR:PATH=${ITK_DIR}
          -DGenerateCLP_DIR:PATH=${GenerateCLP_DIR}
          -DModuleDescriptionParser_DIR:PATH=${ModuleDescriptionParser_DIR}
          -DTCLAP_DIR:PATH=${TCLAP_DIR}
          -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
          -DEXECUTABLE_OUTPUT_PATH:PATH=${DWIResamplingSlicer3Module_BINARY_DIR}/bin
      INSTALL_COMMAND ""
      )
  ENDIF(COMPILE_EXTERNAL_MaskComputationWithThresholding)
ENDIF(COMPILE_EXTERNAL_PROJECTS)



