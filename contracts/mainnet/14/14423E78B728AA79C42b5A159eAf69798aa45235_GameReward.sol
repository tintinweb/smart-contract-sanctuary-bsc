/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.3;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  public  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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


interface Token {
    
    function totalSupply() external view returns (uint256 supply);
    function transfer(address _to, uint256 _value) external  returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}

contract GameReward is Ownable {
    
    address payable public developer;
    Token tokenContract;
    
    mapping (address => uint) private _walletReward;
    
    uint public reward =  0x33B2E3C9FD0803CE8000000;
    
    constructor(Token _tokenContract) public  {
        address msgSender = _msgSender();
        developer = payable(msgSender);
        tokenContract = _tokenContract;
    }
    
    function getWalletReward(address _wallet) public view returns (uint) {
        uint walletReward = _walletReward[_wallet];
        return (walletReward);
    }

    function catchReward() external returns (bool){
        address senderAdr = msg.sender;
        address contractAdd = address(this);
        uint256 contractBallance = tokenContract.balanceOf(contractAdd);
        require(contractBallance >= _walletReward[senderAdr], "Have not enough balance.");
        bool transferData = tokenContract.transfer(senderAdr,_walletReward[senderAdr]);
        require(transferData, "There is a problem about transfer.");
        _walletReward[senderAdr] = 0;
        return transferData;
    }
    
    function sendReward(address _wallet) public onlyOwner returns (bool){
        address rewardAdr = _wallet;
        address contractAdd = address(this);
        uint256 contractBallance = tokenContract.balanceOf(contractAdd);
        require(contractBallance >= reward, "Have not enough balance.");
        bool transferData = tokenContract.transfer(rewardAdr, reward);
        require(transferData, "There is a problem about transfer.");
        return transferData;
    }
    
    function addReward(address _wallet) public onlyOwner returns (bool){
        _walletReward[_wallet] = _walletReward[_wallet] + reward;
    }

    function changeWalletReward(address _wallet,uint _reward) public onlyOwner {
        _walletReward[_wallet] = _reward;
    }   
    
    function getReward() public view returns (uint) {
        return reward;
    } 
    
    function changeReward(uint _reward) public onlyOwner {
        reward = _reward;
    } 

    function getDev() public view returns (address) {
        return developer;
    }
    
    function changeDev(address newAddress) public onlyOwner {
        developer = payable(newAddress);
    }
    
    function getTokenAdr() public view returns (address) {
        return address(tokenContract);
    }
    
    function changeTokenAdr(Token newToken) public onlyOwner {
        tokenContract = newToken;
    }

    fallback () external payable {}
    
    receive() external payable {}
    
    function transferToken() public onlyOwner{
        require(tokenContract.transfer(developer, tokenContract.balanceOf(address(this))));
    }
    
    function withdraw(address _address, uint256 _value) public onlyOwner returns (bool) {
        require(address(this).balance >= _value);
        payable(_address).transfer(_value);
        return true;
    }
    
    function withdrawToken(address tokenAddress,address _address, uint256 _value) public onlyOwner returns (bool success) {
        return Token(tokenAddress).transfer(_address, _value);
    }
        
}