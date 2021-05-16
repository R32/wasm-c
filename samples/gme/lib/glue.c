#include "gme.h"
#include "WASM.h"

/*
static gme_type_t gme_type_array[] = {
	gme_ay_type,
	gme_gbs_type,
	gme_gym_type,
	gme_hes_type,
	gme_kss_type,
	gme_nsf_type,
	gme_nsfe_type,
	gme_sap_type,
	gme_spc_type,
	gme_vgm_type,
	gme_vgz_type
};
*/

EM_EXPORT(nsf_new) Music_Emu* gme_new_emu_nsf(int sample_rate) {
	return gme_new_emu(gme_nsf_type, sample_rate);
}
