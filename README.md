# Divergence and the Complexity of Difference in Text and Culture

This is the code for examples in Chang and DeDeo, “Divergence and the Complexity of Difference in Text and Culture”. Readers may find it particularly useful as a source of raw data for further analysis, and as a source of example code.

The two examples are (1) the backbone of enclosure architecture in Darwin’s *The Origins of Spieces* (fig. 3) in the `darwin` folder, and (2) shortcuts in philosophical texts by Aristotle, Hume, and Kant (fig. 4) in the `shortcut` folder.

The `darwin` example makes use of topicexplorer, available at [https://github.com/inpho/topic-explorer](https://github.com/inpho/topic-explorer); we thank Colin Allen for the underlying topic model data. topicexplorer is presented in Murdock, Jaimie, and Colin Allen. “Visualization Techniques for Topic Model Checking.” In AAAI, pp. 4284-4285. 2015. It uses ruby for the backbone analysis itself, and Gephi for network visualization.

The `shortcut` example makes use of MALLET, which is available at For more on the chunk-level analysis, including links to additional replication code, see Thompson, William HW, Zachary Wojtowicz, and Simon DeDeo. “Lévy Flights of the Collective Imagination.” arXiv preprint arXiv:1812.04013 (2018); available at [https://arxiv.org/abs/1812.04013](https://arxiv.org/abs/1812.04013). It uses IDL for data visualization, although this is not necessary for the calculations themselves.

This code was originally implemented on macOS using Ruby 2.5; it also has been tested to work on Gentoo Linux. We welcome feedback; if you are interested in using these examples, or learning from them in greater detail, and have requests, please contact Kent K. Chang ([kentkchang@berkeley.edu](mailto:kentkchang@berkeley.edu)), and Simon DeDeo ([sdedeo@andrew.cmu.edu](mailto:sdedeo@andrew.cmu.edu)).