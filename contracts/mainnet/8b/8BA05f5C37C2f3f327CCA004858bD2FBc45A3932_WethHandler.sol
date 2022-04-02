// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '.././interfaces/IWETH.sol';

contract WethHandler {

    address admin;
    IWETH weth;

    constructor(address _admin, address _weth) {
        admin =  _admin;
        weth = IWETH(_weth);
    }

    receive() external payable {

    }
    
    function unpackTokens(address to, uint256 amount) external {
      require(msg.sender == admin, "must be owner");
      weth.withdraw(amount);
      payable(to).transfer(amount);
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}