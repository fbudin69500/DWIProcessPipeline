#Find tools

macro( FindSlicerToolsMacro path name )
  find_program(${path} ${name} )
  if(NOT ${path} )
    IF(Slicer3_FOUND)
      set( ${path} ${Slicer3_HOME}/${Slicer3_INSTALL_PLUGINS_BIN_DIR}/${name} )
    else(Slicer3_FOUND)
      message( WARNING "${name} not found. Its path is not set" )
    endIF (Slicer3_FOUND)
  endif(NOT ${path} )
endmacro( FindSlicerToolsMacro )

FindSlicerToolsMacro( RESAMPLEDTITOOL ResampleDTI )
FindSlicerToolsMacro( REGISTERIMAGESTOOL RegisterImages )
FindSlicerToolsMacro( HistogramMatchingTOOL HistogramMatching )
FindSlicerToolsMacro( RESAMPLEVOLUME2TOOL ResampleVolume2 )
FindSlicerToolsMacro( DIFFUSIONTENSORESTIMATIONTOOL DiffusionTensorEstimation )


macro( FindExecutableMacro path name extra)
  find_program(${path} ${name} )
  if(NOT ${path} )
    message( STATUS "${name} not found. CMake external used to download it and compile it" )
    set( ${path} ${DWIResamplingSlicer3Module_BINARY_DIR}/bin/${name} )
    set( ${extra} ON )
  else(NOT ${path} )
    set( ${extra} OFF )
  endif(NOT ${path} )
endmacro( FindExecutableMacro )


OPTION(USE_LOG_EUCLIDEAN "Use ResampleDTIlogEuclidean" OFF)
if( USE_LOG_EUCLIDEAN )
  FindExecutableMacro( RESAMPLEDTILOGEUCLIDEANTOOL ResampleDTIlogEuclidean COMPILE_ResampleDTIlogEuclidean )
endif( USE_LOG_EUCLIDEAN )

FindExecutableMacro( ITKTRANSFORMTOOLSTOOL ITKTransformTools COMPILE_ITKTransformTools )
FindExecutableMacro( ImageMathTOOL ImageMath COMPILE_ImageMath )
FindExecutableMacro(COMPUTEORIENTATIONTOOL ManualImageOrient ManualImageOrientexternal )
FindExecutableMacro(MaskTOOL MaskComputationWithThresholding MaskTOOLexternal )


find_program(CREATEMRMLTOOL CreateMRML )
if(NOT CREATEMRMLTOOL )
  IF(Slicer3_FOUND)
    message( STATUS "CreateMRML not found. CMake external used to download it and compile it" )
    set( CreateMRMLexternal ON )
    set( CREATEMRMLTOOL ${Slicer3_HOME}/${Slicer3_INSTALL_PLUGINS_BIN_DIR}/CreateMRML )
  else(Slicer3_FOUND)
    message( WARNING "CreateMRML not found and will not be downloaded and compiled. Set path if already on the system or manually download and install it from here: git://github.com/booboo69500/CreateMRML.git" )
    set( CreateMRMLexternal OFF )
  endIF (Slicer3_FOUND)
else(NOT CREATEMRMLTOOL )
  set( CreateMRMLexternal OFF )
endif(NOT CREATEMRMLTOOL )

macro( FindDtiExecutableMacro path name extra)
  find_program( ${path} ${name} )
  if(NOT ${path} )
    if( ${ITK_USE_REVIEW} )
      message( STATUS "${name} not found. CMake external used to download it and compile it" )
      set( ${extra} ON )
      set( ${path} ${DWIResamplingSlicer3Module_BINARY_DIR}/bin/${name} )
    else( ${ITK_USE_REVIEW} )
      message( WARNING "${name} not found and will not be downloaded and compiled. ITK should be compiled with ITK_USE_REVIEW set to ON" )
    endif( ${ITK_USE_REVIEW} )
  endif(NOT ${path} )
endmacro( FindDtiExecutableMacro )

set( COMPILE_DTIPROCESS OFF )
FindDtiExecutableMacro( DTIESTIMTOOL dtiestim COMPILE_DTIPROCESS )
FindDtiExecutableMacro( DTIPROCESSTOOL dtiprocess COMPILE_DTIPROCESS )


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
  if( USE_LOG_EUCLIDEAN )
    OPTION(COMPILE_EXTERNAL_ResampleDTIlogEuclidean "Compile External ResampleDTIlogEuclidean" ${COMPILE_ResampleDTIlogEuclidean} )
    IF(COMPILE_EXTERNAL_ResampleDTIlogEuclidean)
      set(proj ResampleDTIlogEuclidean)
        ExternalProject_Add(${proj}
          CVS_REPOSITORY ":pserver:anonymous@demeter.ia.unc.edu:/cvsroot/"
          CVS_MODULE NeuroLib/Applications/ResampleDTI-LogEuclidean
          SOURCE_DIR ${proj}
          BINARY_DIR ${proj}-build
          DEPENDS ${ITK_DEPEND}
          CMAKE_GENERATOR ${gen}
          CMAKE_ARGS
            ${LOCAL_CMAKE_BUILD_OPTIONS}
            -DITK_DIR:PATH=${ITK_DIR}
            -DGenerateCLP_DIR:PATH=${GenerateCLP_DIR}
            -DModuleDescriptionParser_DIR:PATH=${ModuleDescriptionParser_DIR}
            -DTCLAP_DIR:PATH=${TCLAP_DIR}
            -DSlicer3_FOUND:BOOL=TRUE
            -DSlicer3_USE_FILE:PATH=${Slicer3_USE_FILE}
            -DSlicer3_DIR:PATH=${Slicer3_DIR}
            -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
            -DEXECUTABLE_OUTPUT_PATH:PATH=${EXECUTABLE_OUTPUT_PATH}
        INSTALL_COMMAND ""
        )
    ENDIF(COMPILE_EXTERNAL_ResampleDTIlogEuclidean)
  endif( USE_LOG_EUCLIDEAN )
  OPTION(COMPILE_EXTERNAL_ImageMath "Compile External ImageMath" ${COMPILE_ImageMath} )
  IF(COMPILE_EXTERNAL_ImageMath)
    set(proj ImageMath)
      ExternalProject_Add(${proj}
        CVS_REPOSITORY ":pserver:anonymous@demeter.ia.unc.edu:/cvsroot/"
        CVS_MODULE NeuroLib/Applications/${proj}
        SOURCE_DIR ${proj}
        BINARY_DIR ${proj}-build
        DEPENDS ${ITK_DEPEND}
        CMAKE_GENERATOR ${gen}
        CMAKE_ARGS
          ${LOCAL_CMAKE_BUILD_OPTIONS}
          -DITK_DIR:PATH=${ITK_DIR}
          -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
          -DEXECUTABLE_OUTPUT_PATH:PATH=${EXECUTABLE_OUTPUT_PATH}
      INSTALL_COMMAND ""
      )
  ENDIF(COMPILE_EXTERNAL_ImageMath)
  OPTION(COMPILE_EXTERNAL_ITKTransformTools "Compile External ITKTransformTools" ${COMPILE_ITKTransformTools} )
  IF(COMPILE_EXTERNAL_ITKTransformTools)
    set(proj ITKTransformTools)
      ExternalProject_Add(${proj}
        CVS_REPOSITORY ":pserver:anonymous@demeter.ia.unc.edu:/cvsroot/"
        CVS_MODULE NeuroLib/Applications/${proj}
        SOURCE_DIR ${proj}
        BINARY_DIR ${proj}-build
        DEPENDS ${ITK_DEPEND}
        CMAKE_GENERATOR ${gen}
        CMAKE_ARGS
          ${LOCAL_CMAKE_BUILD_OPTIONS}
          -DITK_DIR:PATH=${ITK_DIR}
          -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
          -DEXECUTABLE_OUTPUT_PATH:PATH=${EXECUTABLE_OUTPUT_PATH}
      INSTALL_COMMAND ""
      )
  ENDIF(COMPILE_EXTERNAL_ITKTransformTools)
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
          -DEXECUTABLE_OUTPUT_PATH:PATH=${EXECUTABLE_OUTPUT_PATH}
      INSTALL_COMMAND ""
      )
  ENDIF(COMPILE_EXTERNAL_CreateMRML)
  OPTION(COMPILE_EXTERNAL_dtiprocess "Compile External dtiprocessToolkit" ${COMPILE_DTIPROCESS} )
  IF(COMPILE_EXTERNAL_dtiprocess)
    if(NOT Slicer3_FOUND)
      include(CMake/CMakeCommonExternalDefinitions.cmake)
      PACKAGE_NEEDS_VTK_NOGUI( ${CMAKE_GENERATOR} )
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
          -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${EXECUTABLE_OUTPUT_PATH}
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
          -DEXECUTABLE_OUTPUT_PATH:PATH=${EXECUTABLE_OUTPUT_PATH}
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
          -DEXECUTABLE_OUTPUT_PATH:PATH=${EXECUTABLE_OUTPUT_PATH}
      INSTALL_COMMAND ""
      )
  ENDIF(COMPILE_EXTERNAL_MaskComputationWithThresholding)

ENDIF(COMPILE_EXTERNAL_PROJECTS)
