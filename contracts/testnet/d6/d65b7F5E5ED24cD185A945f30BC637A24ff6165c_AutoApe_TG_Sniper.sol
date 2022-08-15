/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

// SPDX-License-Identifier: None

pragma solidity 0.8.15;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;
    address private _payee;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      _payee = msgSender;
    }

    function owner() public view returns (address) {
      return _owner;
    }

    function payee() public view returns(address) {
        return _payee;
    }

    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function setPayee(address reciever) external onlyOwner {
        _payee = reciever;
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

contract AutoApe_TG_Sniper is Context, Ownable {

    mapping (address => bool) private subStatus;
    uint256 subPrice = 20000000000000000;
    uint256 transferPrice = 1000000000000000;
    
    function subscribe() payable public {
        require(msg.value == subPrice, "* Invalid Amount *");
        subStatus[msg.sender] = true;
    }

    function transferSubscription(address to) payable public {
        require(subStatus[msg.sender] == true, "No subscription to transfer");
        require(msg.value == transferPrice, "* Invalid Amount *");
        subStatus[msg.sender] = false;
        subStatus[to] = true;
    }
        
    function getSubStatus(address account) public view returns(bool) {
        return subStatus[account];
    }

    function getSubPrice() public view returns(uint256) {
        return subPrice;
    }

    function getTransferPrice() public view returns(uint256) {
        return transferPrice;
    }

    function payTheProf() external onlyOwner {
        (bool success,) = payable(payee()).call{value: address(this).balance, gas: 50000}("");
        require(success);
    }

    function setSubPrice(uint256 _subPrice) external onlyOwner {
        subPrice = _subPrice;
    }

    function setTransferPrice(uint256 _transferPrice) external onlyOwner {
        transferPrice = _transferPrice;
    }

    function grantAccess(address[] memory accounts) external onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            subStatus[accounts[i]] = true;
        }
    }

    function revokeAccess(address[] memory accounts) external onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            subStatus[accounts[i]] = false;
        }
    }
}