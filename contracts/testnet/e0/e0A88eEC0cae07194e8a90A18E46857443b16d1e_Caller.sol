// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Test.sol";
import "./TestPayable.sol";

contract Caller {
    function callTestPayable(TestPayable test) public returns (bool) {
        (bool success,) = address(test).call(abi.encodeWithSignature("nonExistingFunction()"));
        require(success);
        // results in test.x becoming == 1 and test.y becoming 0.
        // (success,) = address(test).call{ value: 0.01 ether }(abi.encodeWithSignature("nonExistingFunction()"));
        // require(success);
        // results in test.x becoming == 1 and test.y becoming 1.
        // If someone sends Ether to that contract, the receive function in TestPayable will be called.
        payable(address(test)).transfer(0.1 ether);
        // results in test.x becoming == 2 and test.y becoming 2 ether.
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Test {
    // This function is called for all messages sent to
    // this contract (there is no other function).
    // Sending Ether to this contract will cause an exception,
    // because the fallback function does not have the `payable`
    // modifier.
    fallback() external { x = 1; }
    uint x;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TestPayable {
    
    fallback() external payable { }
    
    receive() external payable { }
}