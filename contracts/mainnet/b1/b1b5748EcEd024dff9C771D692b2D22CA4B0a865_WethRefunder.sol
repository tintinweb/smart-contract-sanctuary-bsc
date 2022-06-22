//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "../../interfaces/IWETH.sol";

/**
    @dev This is the utility contract, to refund ETH after withdraw from WETH by {address.call}.
    It aims to support the contract, not being able to receive ETH by {address.transfer}.
 */
contract WethRefunder {
    IWETH public WETH;

    constructor(address weth_) {
        WETH = IWETH(weth_);
    }

    function withdraw(uint256 amount) external {
        WETH.withdraw(amount);
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "EthRefunder: ETH transfer failed");
    }

    receive() external payable {}
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;

    function transfer(address, uint256) external returns (bool);
}