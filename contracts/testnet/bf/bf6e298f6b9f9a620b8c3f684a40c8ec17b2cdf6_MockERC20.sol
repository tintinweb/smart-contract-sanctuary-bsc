// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC20.sol";
import "./IERC20Metadata.sol";

import "./Context.sol";
import "./Ownable.sol";

import "./ERC20.sol";

contract MockERC20 is ERC20, Ownable {

    constructor() ERC20("DEGEN TEST TOKEN", "DGT") {
        _mint(msg.sender, 1000000 * 10**18);
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
}