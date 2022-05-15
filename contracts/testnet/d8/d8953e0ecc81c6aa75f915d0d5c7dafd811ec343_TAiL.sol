/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.23;

library Math {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 6;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

contract TAiLNN {
    
    using Math for uint;
    
    //Network Owner
    address NetworkOwner;
    bool NetworkSet;
    
    //Network Configuration
    uint NumberOutputs;
    uint NumberInputs;
    uint NumberLayers;
    uint NumberNeurons;
    
    //Neural Network Values
    mapping(uint => uint) LayerSizes;
    mapping(uint => uint) NeuronLayers;
    mapping(uint => uint) NeuronBiases;
    mapping(uint => mapping(uint => uint)) NeuronConnectionWeights;
    mapping(uint => mapping(uint => uint)) NeuronActivationFunctions;
    
    constructor () public {
        //set the owner of the network to the contract creator
        NetworkOwner = msg.sender;
    }
    
    //set up the neural network
    function SetupNetwork(uint[] _LayerSizes, uint[] _Biases, uint[] _Weights) public {
        
        require(NetworkSet == false, "Network has already been set up");
        require(_Weights.length % 4 == 0 , "Invalid weight data");
        
        //set the networks configuration
        NumberLayers = _LayerSizes.length;
        NumberNeurons = _Biases.length;
        
        //seting layer sizes
        uint i;
        uint j;
        uint counter = 0;
        
        for(i=0; i<_LayerSizes.length; i++){
            
            //set the input/output sizes
            if(i == 0) {
                NumberInputs = _LayerSizes[i];
            }
            else if(i == _LayerSizes.length -1){
                NumberOutputs = _LayerSizes[i];
            }
            
            LayerSizes[i] = _LayerSizes[i];
            
            //set the biases of the network
            for(j=0; j<_LayerSizes[i]; j++){
                
                NeuronBiases[counter] = _Biases[counter];
                NeuronLayers[counter] = i;

                counter += 1;
            }
            
        }
        
        //set the weights of the network
        for(i=0; i<_Weights.length; i+=4){
            
            uint neuron1 = _Weights[i];
            uint neuron2 = _Weights[i+1];
            
            //set the networks weights
            NeuronConnectionWeights[neuron1][neuron2] = _Weights[i+2];
            
            //set the networks activation functions
            NeuronActivationFunctions[neuron1][neuron2] = _Weights[i+3];
        }
        
        
        emit NetworkCreated(NumberInputs, NumberOutputs, NetworkOwner);
        
        //set the network to a perment change where it cant be changed.
        NetworkSet = true;
    }
    
    //event that shows that a neural network has been initialised.
    event NetworkCreated (uint ins, uint out, address owner);
        
    //make a prediction on user given data 
    function Predict(uint[] data) public returns(uint[]){
        
        require(data.length == NumberInputs, "Data is not the correct length");
        
        uint[] memory CalculatedValues = new uint[](NumberNeurons);
        
        //set the values for the first layer
        for(uint i=0; i<data.length; i++){
            CalculatedValues[i] = data[i];
        }
        
        uint NeuronCount = data.length;
        uint layerStart = 0;
        //calculate values for each layer
        for(i = 1; i<NumberLayers; i++){
            
            //get the layer sizes so that connection can be found
            uint prevLayerSize = LayerSizes[i-1];
            uint LayerSize = LayerSizes[i];
            
            //calculate values for a given layers neurons
            for (uint j = 0; j<LayerSize; j ++){
                uint value = 0;
                
                //calculate a value for each node multiplying by the weights.
                for(uint k = 0; k<prevLayerSize; k++){
                    uint ConnectedNeuron = layerStart + k;
                    uint calculatedWeight = CalculatedValues[ConnectedNeuron].wmul(uint(NeuronConnectionWeights[ConnectedNeuron][NeuronCount]));
                    //The nodes value is increased by the the multiplacation of connection values, biases, and previous node values.
                    
                    // apply the activation function (this doesnt really do anything)...
                    value += IntegerRelu(calculatedWeight);
                }
                
                CalculatedValues[NeuronCount] = value;
                
                NeuronCount += 1;
            }
            
            //this counter helps keep track/point to where the current layer is
            layerStart += prevLayerSize;
            
        }
        
        //generating values for an event emit
        uint LastLayerSize = LayerSizes[NumberLayers - 1];
        uint[] memory RawValues = new uint[](LastLayerSize);
        
        for(i =0; i<LastLayerSize; i++){
            
            RawValues[((LastLayerSize-i) - 1)] = CalculatedValues[((CalculatedValues.length-1)-i)];
        }
        
        //emit an event to tell the user what the neural Prediction is for the last layer
        emit PredictionMade(RawValues);
        
        return RawValues;
    }
    
    //the prediction event tells the user what the network predicts, as well as raw values
    event PredictionMade(uint[] RawValues);
    
    //the relu activation wont change anything as the neural networks are not using ints, therefore cannot be negative
    //its here as its better to remember we need some activation function!
    function IntegerRelu(uint x) public returns (uint){
        if(x < 0){
            return 0;
        }else {
            return x;
        }
    }
    
}


contract TAiL {
    
    uint networkNumber = 0;

    //Neural Network Values
    mapping(uint => address) Networks;
    mapping(uint => address) NetworkOwners;
    mapping(uint => mapping(uint => uint[])) NetworkPredictionHistory;
    mapping(uint => uint) NetworkTotalPrediction;
    
    constructor () public {
        networkNumber = 0;
    }
    
    
    
    //set up the neural network
    function SetupNetwork(uint[] _LayerSizes, uint[] _Biases, uint[] _Weights) public {
        
        TAiLNN a = new TAiLNN();
        a.SetupNetwork(_LayerSizes, _Biases, _Weights);
        
        address NewNetwork = address(a);
        Networks[networkNumber] = NewNetwork;
        NetworkOwners[networkNumber] = msg.sender;
        
        emit NetworkCreated(NewNetwork, networkNumber, msg.sender);
        networkNumber += 1;

    }
    
    //event that shows that a neural network has been initialised.
    event NetworkCreated (address Network, uint NetworkNumber, address owner);
        
    //make a prediction on user given data 
    function Predict(uint NetworkNumber, uint[] data) public {
        
        uint[] memory prediction = TAiLNN(Networks[NetworkNumber]).Predict(data);
        uint totalPrediction = NetworkTotalPrediction[NetworkNumber];

        //store predictions on chain as opposed to events only - api.trongrid doesnt store history well!
        NetworkPredictionHistory[NetworkNumber][totalPrediction] = prediction;
        NetworkTotalPrediction[NetworkNumber] = totalPrediction + 1;

        emit NetworkPredictionMade(NetworkNumber, prediction);
        
    }
    
    //the prediction event tells the user what the network predicts, as well as raw values
    event NetworkPredictionMade(uint network, uint[] RawValues);

    //get the network address
    function getNetworkAddress(uint NetworkNumber) public view returns (address) {
        return Networks[NetworkNumber];
    }

    //get the network Owners address
    function getNetworkOwners(uint NetworkNumber) public view returns (address) {
        return NetworkOwners[NetworkNumber];
    }

    //get the total number of predictions for a network
    function getTotalNetworkPredictions(uint NetworkNumber) public view returns (uint) {
        return NetworkTotalPrediction[NetworkNumber];
    }

    //get the total number of predictions for a network
    function getHistoricPrediction(uint NetworkNumber, uint PredictionNumber) public view returns (uint[]) {
        return NetworkPredictionHistory[NetworkNumber][PredictionNumber];
    }

    //get the total number of deployed networks
    function getNetworkCount() public view returns (uint) {
        return networkNumber;
    }


}