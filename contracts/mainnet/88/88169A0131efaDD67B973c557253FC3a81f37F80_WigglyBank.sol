// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./IERC20.sol";
import "./Ownable.sol";

contract WigglyBank is Ownable {
    IERC20 token; // ERC20 Token Address

    address private _contract;

    function Setup(address token_addr, address _contaddr) public onlyOwner {
        token = IERC20(token_addr);
        _contract = address(_contaddr);
    }

    function withdrawContract(address _addr, uint256 _amount)
        external
        returns (bool)
    {
        require(msg.sender == _contract, "Invalid Sender");
        require(token.transfer(_addr, _amount), "TRANSFER FAILED");
        return true;
    }

    function sendToken(address _account, uint256 _amount)
        external
        onlyOwner
        returns (bool)
    {
        require(token.transfer(_account, _amount), "TRANSFER FAILED");
        return true;
    }

    function withdrawToken(uint256 _amount) external onlyOwner returns (bool) {
        require(token.transfer(owner(), _amount), "TRANSFER FAILED");
        return true;
    }

    function withdrawBnb() external onlyOwner returns (bool) {
        if (address(this).balance >= 0) {
            payable(owner()).transfer(address(this).balance);
        }
        return true;
    }
}