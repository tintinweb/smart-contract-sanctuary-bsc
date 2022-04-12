/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IBEP20 {

    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {return payable(msg.sender);}
 
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
 
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    string private _name;
    
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
 
    function owner() public view virtual returns (address) {return _owner;}
 
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
 
    function renounceOwnership() internal virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
 
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract SafeToken is Ownable {
    address payable public safeManager;

    constructor() {

        safeManager = payable(msg.sender);
    }

    function setSafeManager(address payable _safeManager) public onlyOwner {
        safeManager = _safeManager;
    }

    function withdraw(address _token, uint256 _amount) external {
        require(msg.sender == safeManager);
        IBEP20(_token).transfer(safeManager, _amount);
    }

    function withdrawBNB(uint256 _amount) external {
        require(msg.sender == safeManager);
        safeManager.transfer(_amount);
    }
}

contract EarthSender is Ownable, SafeToken {
    
    uint256 public Fee = 0.1 ether ;
    uint256 public Multiple = 2;
    uint256 public Amount;
    
    mapping (address => mapping (address => uint256)) private _allowances;    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor () {}

    function ChangeMultiple(uint256 NewMultiple) external onlyOwner{
        Multiple = NewMultiple;
    } 
    
    function ChangeFee(uint256 NewAmount) external onlyOwner{
        Fee = NewAmount;
    }
    
    function disperseToken(IBEP20 token, address[] memory recipients, uint256[] memory values) external payable{
        uint256 total = 0;
                
        if (recipients.length <= Multiple){
            Amount = Fee;
            require(msg.value == Amount, 'Wrong Value');
        }else if(recipients.length <= Multiple*2){
            Amount = Fee*2;
            require(msg.value == Amount, 'Wrong Value');
        }else if(recipients.length <= Multiple*4){
            Amount = Fee*3;
            require(msg.value == Amount, 'Wrong Value');
        }else if(recipients.length <= Multiple*6){
            Amount = Fee*4;
            require(msg.value == Amount, 'Wrong Value');
        }else{
            Amount = Fee*5;
            require(msg.value == Amount, 'Wrong Value');
        }

        for (uint256 i = 0; i < recipients.length; i++)
            total += values[i];
        require(token.approve(msg.sender, total), "Not Approved by contract");
        require(token.allowance(msg.sender, address(this)) >= total, "Not enough Allowance for transfer");
        require(token.transferFrom(msg.sender, address(this), total), "can't get the total tokens required");

        for (uint256 i = 0; i < recipients.length; i++)
            require(token.transfer(recipients[i], values[i]));
    }

    function BNBBalance() public view onlyOwner returns(uint256) {
        uint256 bnbBalance =  address(this).balance;
        return bnbBalance;
    }    

    function TokenBalance(address token) public view onlyOwner returns(uint256) {
        uint256 tokenBalance = IBEP20(token).balanceOf(address(this));
        return tokenBalance;
    }    
}