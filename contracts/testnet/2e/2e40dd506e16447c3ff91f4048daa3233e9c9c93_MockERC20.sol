// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC20.sol";
import "./IERC20Metadata.sol";

import "./Context.sol";
import "./Ownable.sol";

import "./ERC20.sol";

contract MockERC20 is ERC20("DEGEN TEST TOKEN", "DGT"), Ownable {

    mapping(address => uint256) internal _mintedBy;
    mapping(address => uint256) internal _mintedTo;

    constructor() {
        _mint(msg.sender, 1000000 * 10**18);
    }

    function mint(address _to, uint256 _amount) public {
        
        _mint(_to, _amount);

        _mintedBy[msg.sender] += _amount;
        _mintedTo[_to] += _amount;
    }

    function mintedBy(address _user) public view returns (uint256) {
        return _mintedBy[_user];
    }

    function mintedTo(address _user) public view returns (uint256) {
        return _mintedTo[_user];
    }
}