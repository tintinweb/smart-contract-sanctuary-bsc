// SPDX-License-Identifier: MIT

import "./ERC20.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";

pragma solidity ^0.8.1;

contract QuantumToken is ERC20("QUANTUM", "QTM"), Ownable {
    using SafeERC20 for IERC20;
    mapping(address => bool) public minterList;
    event SetMinter(address indexed minter, bool indexed status);

    constructor() {
        _mint(msg.sender, 2e24);
    }

    modifier onlyMinter() {
        require(minterList[msg.sender] == true, "QUANTUM: Not authorized");
        _;
    }

    function setMinter(address _address, bool _status) external onlyOwner {
        minterList[_address] = _status;
        emit SetMinter(_address, _status);
    }

    function mint(address _to, uint256 _amount) external onlyMinter {
        _mint(_to, _amount);
    }

    function recoverTokens(IERC20 _token) external onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, amount);
    }
}