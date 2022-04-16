// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

import './interfaces/IWETH.sol';

contract TestWeth {
    IWETH public constant WETH = IWETH(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);

    function withdrawETH(uint amount)
        external
    {
        WETH.withdraw(amount);
    }
    function() external payable {
        // React to receiving ether
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}