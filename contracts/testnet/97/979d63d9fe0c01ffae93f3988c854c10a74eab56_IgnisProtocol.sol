// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.0;

import "./ERC20.sol";
import "./SafeMath.sol";

contract IgnisProtocol is ERC20 {
    using SafeMath for uint256;
    // IgnisProtocol token decimal
    uint8 public constant _decimals = 18;
    // Total supply for the IgnisProtocol token = 500M
    uint256 private _totalSupply = 500000000 * (10 ** uint256(_decimals));
    // Token IgnisProtocol deployer
    address private _ignisProtocolDeployerDeployer;

    constructor(address _deployer) ERC20("IgnisProtocol", "IGN", _decimals) {
        _ignisProtocolDeployerDeployer = _deployer;
        _mint(_ignisProtocolDeployerDeployer, _totalSupply);
    }

    // Allow to burn own wallet funds (which should be the amount from depositor contract)
    function burnFuel(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}