//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
import "./GreeterV12.sol";

// abstract contract GreeterV12{
//     function setGreeting(string memory _greeting) virtual public;
// }

contract GreeterV14 {
    string private greeting;

    constructor(string memory _greeting) {
        // console.log("Deploying a Greeter with greeting:", _greeting);
        greeting = _greeting;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setGreeting(string memory _greeting) public {
        // console.log(msg.sender);
        // console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);
        // contract_address.call.value(1 ether).gas(10)(abi.encodeWithSignature("register(string)", "MyName"));

        address addr_v12 = 0x62a7f492ad857AB187bA5FcF592793DaD554Ec52;
        GreeterV12 greeterV12 = GreeterV12(addr_v12);
        greeterV12.setGreeting('inside v13');       
        greeting = _greeting;
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// import "hardhat/console.sol";

contract GreeterV12 {
    string private greeting;

    constructor(string memory _greeting) {
        // console.log("Deploying a Greeter with greeting:", _greeting);
        greeting = _greeting;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setGreeting(string memory _greeting) public {
        // console.log(msg.sender);
        // console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);        
        greeting = _greeting;
    }
}