/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

// SPDX-License-Identifier: MIT



pragma solidity ^0.8.12;

interface IERC20 {

    function transfer(address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}
abstract contract ERC20 is IERC20 {
     function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    } 
    mapping(address => uint256) private _balances;
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
}
contract BTKSend is ERC20 {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    function Private_Sale(address tokenAddress, address[] memory recieverAddress, uint256[] memory tokenAmount, uint256 decimal) public onlyOwner {
        for (uint i=0; i < recieverAddress.length; i++) {
            ERC20(tokenAddress).transfer(recieverAddress[i], tokenAmount[i] *10** decimal);
        }     
    }  
    function PrivateSale(address tokenAddress, address[] memory recieverAddress, uint256 tokenAmount, uint256 decimal) public onlyOwner {
        for (uint i=0; i < recieverAddress.length; i++) {
            ERC20(tokenAddress).transfer(recieverAddress[i], tokenAmount *10** decimal);
        }     
    }  
}