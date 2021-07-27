# preprocessPipeline
code to preprocess ephys data stored in date files to extract spike times, LFP information, spike sort etc.

'preprocess1' (or 'preprocess1NP' for neuropixel) and 'preprocess2' have code laid out to go from raw dats to place fields.
'preprocess1' is everything leading up to manual spike sorting and 'preprocess2' is everything after

all of the code called is organized in the follow subdirectories:

- behavior: everything to do with optitrack, intan accelerometer, trial identification, etc.

- files: managing data files by indentifying paths, concatenating dat files, etc.

- lfp: everything to do with lfp (use 'bz_LFPfromDat_km' to compute lfp originally then 'bz_GetLFP' to access thereafter), theta & ripples

- metadata: general info about experiment, proble layout, etc

- spikes: spike sorting, accessing spikes, classifying cell types, computing tuning, etc.

Let me know how it works, feel free to make additions

Love you,
Kathryn
