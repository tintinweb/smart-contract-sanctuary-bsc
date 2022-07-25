contract FibonacciBalance {

    address public fibonacciLibrary;
    // the current Fibonacci number to withdraw
    uint public calculatedFibNumber;
    // the starting Fibonacci sequence number
    uint public start = 3;
    uint public withdrawalCounter;

    uint public reward = 0;

    // constructor - loads the contract with ether
    constructor(address lib) {
        fibonacciLibrary = lib;
    }

    function withdraw() public {
        withdrawalCounter += 1;
        
        (bool success, ) = fibonacciLibrary.delegatecall(abi.encodeWithSignature("setFibonacci(uint256)", withdrawalCounter));
        require(success, "not success in withdraw");

        reward = calculatedFibNumber * 1 ether;
    }

    // allow users to call Fibonacci library functions
    fallback() external {
        (bool success, ) = fibonacciLibrary.delegatecall(msg.data);
        require(success, "not success in fallback");
    }
}