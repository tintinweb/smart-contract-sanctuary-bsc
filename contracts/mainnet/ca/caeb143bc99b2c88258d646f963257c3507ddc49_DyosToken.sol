// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.7;

import "./ERC20.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";

contract DyosToken is ERC20 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    address public governance;
    mapping(address => bool) private minters;
     constructor(
        string memory _name, 
        string memory _symbol
    ) ERC20(_name, _symbol) {
       governance = msg.sender;
    }

    function mintDyos(address _to, uint256 _amount) external {
        require(minters[msg.sender],"!minter");
        _mint(_to,_amount);
    }  

    function burnDyosFrom(address _account, uint256 _amount) external {
        _burn(_account, _amount);
        _approve(_account, _msgSender(), allowance(_account,_msgSender()).sub(_amount, "ERC20: burn amount exceeds allowance"));
    }

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function addMinter(address _minter) public {
        require(msg.sender == governance, "!governance");
        minters[_minter] = true;
    }

    function removeMinter(address _minter) public {
        require(msg.sender == governance, "!governance");
        minters[_minter] = false;
    }

    
}