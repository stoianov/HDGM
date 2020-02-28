# HDGM - Hierarchical Dynamic Generative Model

This repository provides code and description of the following *open-access* paper: The hippocampal formation as a hierarchical generative model supporting generative replay and continual learning, currently pubblished as preprint in bioRxiv (http://dx.doi.org/10.1101/2020.01.16.908889). 

The paper describes a hierchical dynamic generative model capable to infer the hierarchical spatiotemporal structure of sequential experiences such as rodent trajecories during navigation and use this structure to sample fictive experiences such as the *replays* (or *sharp wave ripples*, SWR) found in the rodent brain. 

The code provides an extended dynamic visualization - in support of Figure 1 and Figure 2 - of the dynamical inference process in several replicas of the hierarchical dynamic generative model trained with additional generative replay. The code is written in Matlab thus to run it, you need to have Matlab installed.

To run the visualization, please download the code and evoke *>>hdgm_visualize* in Matlab. Check *>>help hdgm_visualize* to see the visualization options. Hereafter a snapshot of the dynamic visualization:

![a snapshot of the dynamic visualization](/hdmg_snapshot.png)



## Authors

* **Ivilin Stoianov** - *ideas, algorithm, and code*
* **Domenico Maisto** - *ideas* 
* **Giovanni Pezzulo** - *ideas*

## License

This repository is licensed under the MIT License.

If you use the code for research, please cite the paper: Stoianov, I., Maisto, D., & Pezzulo, G. (2020). The hippocampal formation as a hierarchical generative model supporting generative replay and continual learning. *BioRxiv*. doi:10.1101/2020.01.16.908889

