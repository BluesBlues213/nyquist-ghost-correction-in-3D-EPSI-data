Nyquist artifact correction in 3D Echo Planar Spectroscopic Imaging (EPSI) data

This algorithm was developed as part of a project to remove corruptions in 3D EPSI datasets known as Nyquist ghost artifacts. The method implemented follows work from Chen et al. 2004, Removal of EPI Nyquist ghost artifacts with two-dimensional phase correction.

The raw 3D EPSI dataset in the case considered is composed of 150 k-space and time or k-t volumes, each volume being an 384 x 128 x 32 array (kx, ky, echo). Odd-even echo inconsistencies in the readout (kx) direction creates the Nyquist artifact, see nyquist_artifact.png for illustration. Phase guided correction was performed by navigating to the center of k-space (ky=128/2) and acquiring the Fourier transform on the mean of the 1st and 3rd echoes along the kx or readout direction and then multiplying it with the conjugate of the Fourier transform of the 2nd echo. The product is then linearly fitted to obtain the phase offset. This process was performed iteratively over the 150 k-t volumes. Goodness-of-fit was greater near the center of k-space where SNR is high and was used to threshold the reliability of the fit. A mean over the phase offsets acquired near the center of k-space was calculated and used to correct/rearrange the k-t dataset globally. 

Notes: A large portion of the script deals with manipulating the 4D array. Specifically, lines 26 to 40 in  epsi3d_nyquist_correction.m focuses on the implementation of the phase guided technique.

# Results

results.png shows the complex signal phase from a sample voxel and its corresponding Fourier transform, with the distinct N/2 ghosting peak (N=32 echoes). Plots in red represent the cases with the Nyquist artifact. Results upon correction are shown in blue. The script epsi3d_nyquist_correction.m calls the routine rsquare.m 
