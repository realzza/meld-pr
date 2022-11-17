#!/usr/bin/env bash
# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

log() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "$(date '+%Y-%m-%dT%H:%M:%S') (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $*"
}
SECONDS=0


stage=1
stop_stage=1

datadir=./downloads_test
meld_root=${datadir}/MELD.Raw
data_url=https://web.eecs.umich.edu/~mihalcea/downloads/
data_url2=https://huggingface.co/datasets/declare-lab/MELD/resolve/main/


log "$0 $*"
. utils/parse_options.sh

. ./db.sh
. ./path.sh
. ./cmd.sh

if [ $# -ne 0 ]; then
    log "Error: No positional arguments are required."
    exit 2
fi

if [ -z "${MELD}" ]; then
    log "Fill the value of 'MELD' of db.sh"
    exit 1
fi

if [ ${stage} -le 1 ] && [ ${stop_stage} -ge 1 ]; then
    log "stage 1: Data Download"
    mkdir -p ${datadir}
    if ! local/download_and_untar.sh --remove-archive ${datadir} ${data_url}; then
        log "Failed to download from the original site, try a backup site."
        local/download_and_untar.sh --remove-archive ${datadir} ${data_url2}
    fi
fi

if [ ${stage} -le 2 ] && [ ${stop_stage} -ge 2 ]; then
    log "stage 2: Data Preparation"
    mkdir -p data/{train,valid,test}
    python3 local/data_prep.py ${MELD}
    for x in test valid train; do
        for f in text wav.scp utt2spk; do
            sort data/${x}/${f} -o data/${x}/${f}
        done
        utils/utt2spk_to_spk2utt.pl data/${x}/utt2spk > "data/${x}/spk2utt"
        utils/validate_data_dir.sh --no-feats data/${x} || exit 1
    done
fi

log "Successfully finished. [elapsed=${SECONDS}s]"
