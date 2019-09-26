# Polis Economic Modeling

Our goal is to model a new world consisting of agents connected on a trusted network, earning crypto UBI, subject to Demurrage and spending their currencies with each other via mutually agreed upon economic transactions. Coins are transferred between agents using a transitive-transaction model. Much of our work and findings to date can be found [here](//https://blog.polis.global/tag/economic-modeling/).

## Getting Started

There are 2 main algorithms

* An algorithm for generating a random network named "generateHybridNetwork". It's located in /economic-modeling/Network Generation Models along with supporting functions. It's preferrential attachment mode is described [here](https://blog.polis.global/the-networks/), but models spanning the range from purely random to purely preferrential attachment can be generated.

* An algorithm for simulating the economic model named "model_commerce_V1_4". It's located in the root folder /economic-modelling. It's described in detail [here](https://blog.polis.global/the-economic-model/)

### Prerequisites

* Matlab is required to execute all code
* Octave is an option, but the code is not converted (smallish job maybe)
* Output files nodes.csv and edges.csv, where ever you see them, are designed to be inported into [Gephi](https://gephi.org) for further analysis (though being comma delimineted they well may work with other programs)

### Installing and Running

## Installation

* Clone a branch, most usually master 
* Launch Matlab and navigate to the project root /economic-model
* Set your path to /economic-model and include all subfolders 

## Running Network generation - generateHybridNetwork.m

* The input file is named inputFile_Hybrid.txt. 
* You can generate an input file from the script named makeHybridInputFile.m, but you don't have to. 
* Output is sent to the folder /economic-modeling/output.

## Running Economic Model generation - model_commerce_V1_4.m

* The input file is named inputCommerce.txt, but it can be any name because the program searches for a parameter named inputFilename to locate the input file. So, type inputFilename = "inputCommerce.txt" from the command line before executing model_commerce_V1_4.m or you will receive an error.
* You can generate an input file from the script named make_commerce_inputfile.m, but you don't have to. 
* Output is sent to the folder /economic-modeling/output.
* Batch: If you want to chain a bunch of simulations together, look at batch_run_commerce.m

## Source Tree Description

Assume they need to be on the path unless specified (does not hurt if they all are on the path)

* /economic-modeling: This is the root folder and contains model commerce script, associated input files and the batch run script
* /economic-modeling/Classes: All the classes defined for the economic-model algorithm 
* /economic-modeling/Classes/TestScripts: All the test scripts for economic-model algorithm 
* /economic-modeling/Historical: Dead wood, forget it. Not required on the path.
* /economic-modeling/lib: Functions used by all programs (or not). A few test scripts for these functions exist here as well.
* /economic-modeling/Network Generation Model: Contains anything relevant specifcally to the networ generation algorithms. 
* /economic-modeling/Network Models: Contains mostly network models we are keeping / using as inputs to the economic model.
* /economic-modeling/Output: The main algorithms output their results in subdirectors here
* /economic-modeling/Reference Models: Some early reference models useful for historical purposes. Not required on the path.
* /economic-modeling/Simulation Suites: Simulation results we are saving because we have documented them and want to be able to reference them in the future. Not required on the path.
* /economic-modeling/TestPlans: Early testplans and associated with the Reference Models. Still useful for reference. Not required on the path

## Running the tests

* Run the script /economic-model/Classes/TestScripts/testSuite.m. If they pass, yea (they should)!

## Deployment

All code is designed to run on your local computer

## Built With

* Matlab R2019a

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

For the versions available, see the [tags on this repository](https://github.com/Acro-polis/economic-model/tags). 

## Authors

* **Jess Taylor** - *Initial work* - [Polis Economic Modeling](https://github.com/Acro-polis/economic-model)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* This project is inspired by [Polis](https://blog.polis.global)
