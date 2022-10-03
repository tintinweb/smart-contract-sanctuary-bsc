/**
 *Submitted for verification at BscScan.com on 2022-10-03
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}
interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function getOwner() external view returns (address);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Ownable is Context {
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract MetaSage is Ownable{
    IERC20 public token;

    struct User {
        uint256 id;        
        address sponsor;
        uint40 directs;        
        uint256 total_balance;       
        uint256 direct_commision;       
        uint256 claimed;               
        uint256 total_deposit;               
        uint40 timestamp;       
    }

    struct Batchstatus {
        uint40 b1;        
        uint40 b2;        
        uint40 b3;        
        uint40 b4;        
        uint40 b5;        
        uint40 b6;        
        uint40 b7;        
    }

    uint256 public batchusers = 0;
    struct Batchdata {
        uint256 batchid;
        uint256[] bch1;        
        uint256[] bch2;        
        uint256[] bch3;        
        uint256[] bch4;        
        uint256[] bch5;        
        uint256[] bch6;        
        uint256[] bch7;        
    }

    mapping (uint256 => Batchdata) public Batch_data; 
    mapping (uint256 => Batchstatus) public Batch_status; 

    function adduser(uint256 nw,uint256 prnt) public returns (bool) {
        batchusers++;
        Batch_data[nw].batchid = batchusers;

        if(Batch_data[prnt].batchid!=0){
            Batch_data[prnt].bch1.push(nw);
        }
        
        return true;
    }

    function getbatchdata(uint256 uid) public view returns(uint256){
        return Batch_data[uid].bch1.length;
    }

}