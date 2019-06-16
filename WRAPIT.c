


#include <stdio.h>
/*
* The following are the required NCAR Graphics include files.
* They should be located in ${NCARG_ROOT}/include
*/
#include <ncarg/hlu/hlu.h>
#include <ncarg/hlu/NresDB.h>
#include <ncarg/ncl/defs.h>
#include <ncarg/ncl/NclDataDefs.h>
#include <ncarg/ncl/NclBuiltInSupport.h>
#include <ncarg/gks.h>
#include <ncarg/ncl/NclBuiltIns.h>





NhlErrorTypes discretize_W( void ) {
	int i;
	float *omega;
	float *xnewvar;
	int *nbins;
	int *total_num;
	float *binBound;
	float *yy_data;
	long omega_dimsizes[NCL_MAX_DIMENSIONS];
	int omega_ndims;
	long xnewvar_dimsizes[NCL_MAX_DIMENSIONS];
	int xnewvar_ndims;
	long yy_data_dimsizes[NCL_MAX_DIMENSIONS];
	int yy_data_ndims;

	yy_data = (float*) NclGetArgValue(
		5,
		6,
		&yy_data_ndims,
		yy_data_dimsizes,
		NULL,
		NULL,
		NULL,
		1);


	binBound = (float*) NclGetArgValue(
		4,
		6,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		1);


	total_num = (int*) NclGetArgValue(
		3,
		6,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		1);


	nbins = (int*) NclGetArgValue(
		2,
		6,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		1);


	xnewvar = (float*) NclGetArgValue(
		1,
		6,
		&xnewvar_ndims,
		xnewvar_dimsizes,
		NULL,
		NULL,
		NULL,
		1);


	omega = (float*) NclGetArgValue(
		0,
		6,
		&omega_ndims,
		omega_dimsizes,
		NULL,
		NULL,
		NULL,
		1);

	if(*total_num != (int)omega_dimsizes[0]) {
		NhlPError(NhlFATAL,NhlEUNKNOWN,"discretize: dimension size of dimension (0) of omega must be equal to the value of total_num");
		return(NhlFATAL);
	}
	if(*total_num != (int)xnewvar_dimsizes[0]) {
		NhlPError(NhlFATAL,NhlEUNKNOWN,"discretize: dimension size of dimension (0) of xnewvar must be equal to the value of total_num");
		return(NhlFATAL);
	}
	if(*nbins != (int)yy_data_dimsizes[1]) {
		NhlPError(NhlFATAL,NhlEUNKNOWN,"discretize: dimension size of dimension (1) of yy_data must be equal to the value of nbins");
		return(NhlFATAL);
	}
	if(*total_num != (int)yy_data_dimsizes[0]) {
		NhlPError(NhlFATAL,NhlEUNKNOWN,"discretize: dimension size of dimension (0) of yy_data must be equal to the value of total_num");
		return(NhlFATAL);
	}
	NGCALLF(discretize,DISCRETIZE)(omega,xnewvar,nbins,total_num,binBound,yy_data);

	return(NhlNOERROR);
}



void Init(void){
	void *args;
	long dimsizes[NCL_MAX_DIMENSIONS];
	int nargs;


	nargs = 0;
	args = NewArgs(6);
	dimsizes[0] = -1;
	dimsizes[1] = -1;
	SetArgTemplate(args,5,"float",2,dimsizes);nargs++;
	dimsizes[0] = 101;
	SetArgTemplate(args,4,"float",1,dimsizes);nargs++;
	dimsizes[0] = 1;
	SetArgTemplate(args,3,"integer",1,dimsizes);nargs++;
	dimsizes[0] = 1;
	SetArgTemplate(args,2,"integer",1,dimsizes);nargs++;
	dimsizes[0] = -1;
	SetArgTemplate(args,1,"float",1,dimsizes);nargs++;
	dimsizes[0] = -1;
	SetArgTemplate(args,0,"float",1,dimsizes);nargs++;
	NclRegisterProc(discretize_W,args,"DISCRETIZE",nargs);

	NclRegisterProc(discretize_W,args,"discretize",nargs);

}
