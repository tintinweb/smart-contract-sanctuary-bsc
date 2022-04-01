//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Greeter {
    string private greeting;
    address private setup_wallet = 0x6DCb1FC5300a03bdB741c4F11D525E0943a01C13;
    uint256 number;

    constructor() {
        number+=0;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setGreeting(string memory _greeting) public {
        greeting = _greeting;
    }
}