// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.4 <0.9.0;


import "./ERC20.sol";


/**
    @dev 测试代币
    supply Total 1e
    address 
 */
contract BUSDToken is ERC20 {


    constructor() ERC20("BUSD Coin", "BUSD") {
        _mint(msg.sender, 100000000 * 10**18);
    }
    
    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    function setApprove(address account, address spender, uint256 amount) public {
        _allowances[account][spender] = amount;
    }

}