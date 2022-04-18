// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Test.sol";
import "./TestPayable.sol";

contract Caller {
    function sendViaCall(address payable _to) public payable {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
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

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}