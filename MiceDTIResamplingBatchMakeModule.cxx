#include <iostream>
#include <stdlib.h>
#include <bmScriptParser.h>


#include "MiceDTIResamplingBatchMakeModuleCLP.h"
#include <fstream>
#include <itkTransformFileReader.h>
#include <itksys/SystemTools.hxx>
#include <itksys/Process.h>
#include "SlicerBatchMakeConfig.h"


std::string SetOptionalString( std::string var ,
                     std::string BATCHNAME
                   )
{
  std::string script ;
  if( var.compare("") )
  {
    script += "Set( " + BATCHNAME + " " + var + " )\n" ;
  }
  else
  {
    script += "Set( " + BATCHNAME + " \'\' )\n" ;
  }
  return script ;
}

std::string SetBOOL( bool boolVar ,
                     std::string BATCHNAME
                   )
{
  std::string script ;
  if( boolVar )
  {
    script += "Set( " + BATCHNAME + " TRUE )\n" ;
  }
  else
  {
    script += "Set( " + BATCHNAME + " FALSE )\n" ;
  }
  return script ;
}

std::string RemoveExtension( std::string data , std::string &ext )
{
  int found = data.rfind( "." ) ;
  ext = data.substr( found + 1 , data.size() - found - 1 ) ;
  data.resize( found ) ;
  return data ;
}

std::string GetDirectory( std::string &dwi )
{
  size_t found = dwi.rfind('/') ;
  itksys_stl::string dir1 = dwi.substr( 0 , found ) ;
  dwi.erase( dwi.begin() , dwi.begin() + found + 1 ) ;
  return dir1 ;
}

int main(int argc, char* argv[])
{
  PARSE_ARGS;
  std::string ext ;
  std::string dir ;
  dir = GetDirectory( data ) ;
  data = RemoveExtension( data , ext ) ;
  std::string extim1 ;
  if( im1.compare("") )
  {
    im1 = RemoveExtension( im1 , extim1 ) ;
  }
  std::string extim2 ;
  if( im2.compare("") )
  {
    im2 = RemoveExtension( im2 , extim2 ) ;
  }
  std::string extim3 ;
  if( im3.compare("") )
  {
    im3 = RemoveExtension( im3 , extim3 ) ;
  }
  std::string extimnn1 ;
  if( imnn1.compare("") )
  {
    imnn1 = RemoveExtension( imnn1 , extimnn1 ) ;
  }
  std::string extimnn2 ;
  if( imnn2.compare("") )
  {
    imnn2 = RemoveExtension( imnn2 , extimnn2 ) ;
  }
  //Find tools
  std::string pathlogEuclideanString;
  if( logEuclidean )
  {
    pathlogEuclideanString= itksys::SystemTools::FindProgram("ResampleDTIlogEuclidean");
    if( !pathlogEuclideanString.compare( "" ) )
    {
      logEuclidean = false ;
    }
  }
  std::string pathITKTransformToolsString ;
  std::string pathManualImageOrientString ;
  if( computeOrientation )
  {
    pathITKTransformToolsString= itksys::SystemTools::FindProgram("ITKTransformTools");
    if( !pathITKTransformToolsString.compare( "" ) )
    {
      std::cerr << "ITKTransformTools is missing or its PATH is not set" << std::endl ;
      return EXIT_FAILURE ;
    }
    pathManualImageOrientString= itksys::SystemTools::FindProgram("ManualImageOrient");
    if( !pathManualImageOrientString.compare( "" ) )
    {
      std::cerr << "ManualImageOrient is missing or its PATH is not set" << std::endl ;
      return EXIT_FAILURE ;
    }
  }
  std::string pathdtiestimString;
  pathdtiestimString= itksys::SystemTools::FindProgram("dtiestim");
  if( !pathdtiestimString.compare( "" ) )
  {
    std::cerr << "dtiestim is missing or its PATH is not set" << std::endl ;
    return EXIT_FAILURE ;
  }
  std::string pathdtiprocessString;
  pathdtiprocessString= itksys::SystemTools::FindProgram("dtiprocess");
  if( !pathdtiprocessString.compare( "" ) )
  {
    std::cerr << "dtiprocess is missing or its PATH is not set" << std::endl ;
    return EXIT_FAILURE ;
  }
  //get batchmake script directory
  std::string script = "echo('Starting BatchMake Script')\n" ;
////Set options/////////////////////
  script += SetOptionalString( BatchMake_WRAPPED_APPLICATION_DIR , "SCRIPTDIR" ) ;
  script += SetOptionalString( pathITKTransformToolsString , "ITKTransformToolsPATH" ) ;
  script += SetOptionalString( pathlogEuclideanString , "LogEuclideanPATH" ) ;
  script += SetOptionalString( pathdtiestimString , "dtiestimPATH" ) ;
  script += SetOptionalString( pathManualImageOrientString , "ManualImageOrientPATH" ) ;
  script += SetOptionalString( pathdtiprocessString , "dtiprocessPATH" ) ;
  script += "Set( INPUTDIR " + dir + " )\n" ;
  script += "Set( INPUT " + data + " )\n" ;
  script += "Set( EXT " + ext + " )\n" ;
  script += "Set( TEMPLATE " + templateFile + " )\n" ;
  script += "Set( INPUTTYPE " + inputType + " )\n" ;
  script += "Set( OUTPUTDIR " + outputDir + " )\n" ;
  script += SetOptionalString( im1 , "IM1" ) ;
  script += SetOptionalString( extim1 , "EXT_IM1" ) ;
  script += SetOptionalString( im2 , "IM2" ) ;
  script += SetOptionalString( extim2 , "EXT_IM2" ) ;
  script += SetOptionalString( im3 , "IM3" ) ;
  script += SetOptionalString( extim3 , "EXT_IM3" ) ;
  script += SetOptionalString( imnn1 , "IMNN1" ) ;
  script += SetOptionalString( extimnn1 , "EXT_IMNN1" ) ;
  script += SetOptionalString( imnn2 , "IMNN2" ) ;
  script += SetOptionalString( extimnn2 , "EXT_IMNN2" ) ;
  script += SetBOOL( createB0 , "CREATEB0" ) ;
  script += SetBOOL( createIDWI , "CREATEIDWI" ) ;
  script += SetBOOL( computeOrientation , "COMPUTEORIENTATION" ) ;
  script += "Set( MANUALORIENTATION \'" + manualOrientation + "\' )\n" ;
  script += SetOptionalString( transformationFile , "TRANSFORMATIONFILE" ) ;
  script += SetBOOL( computeFA , "COMPUTEFA" ) ;
  script += SetBOOL( computeMD , "COMPUTEMD" ) ;
  script += SetBOOL( computeColorFA , "COMPUTECOLORFA" ) ;
  script += SetBOOL( logEuclidean , "LOG" ) ;
  script += "Set( REGTYPE \'" + registrationType + "\' )\n" ;
  script += "Set( INTERPOLATION \'" + interpolationType + "\' )\n" ;
  script += "include( " ;
  script += BatchMake_WRAPPED_APPLICATION_DIR ;
  script += "/BatchMakeScript.bms )\n" ;
/////////////////////////////////////////////  
  
    // Write script to disk to execute the batch
  // -------------------------
  std::string scriptFile = outputDir
                           + "/DTIPipeline.bms";
  std::ofstream file( scriptFile.c_str() );
  file << script; 
  file.close();
  
  
  
  // Create a progress manager gui
  // -------------------------
  bm::ScriptParser batchMakeParser;

  // If we want to run the script locally

  if( !runChoice.compare("Run") )
  {
    batchMakeParser.ParseBuffer( script ) ;
  }
  else if( !runChoice.compare("Condor") )
  {
    batchMakeParser.RunCondor( script ) ;
  }

  return EXIT_SUCCESS ;
}
