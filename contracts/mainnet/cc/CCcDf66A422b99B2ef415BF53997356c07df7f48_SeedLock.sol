/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

pragma solidity ^0.8.17;

// SPDX-License-Identifier: MIT

interface IToken {
    function balanceOf(address) external view returns (uint balance);
    function approve(address,uint) external;
    function transfer(address,uint) external returns (bool success);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function decimals() external view returns (uint Dec);
}

contract SeedLock{
    address private Owner;
    uint SaleState = 0;
    uint Rate = 1000000;
    uint MaxCollect = 10000000000000000000;
    uint MaxInvest = 10000000000000000000;
    uint MinInvest = 100000000000000000;
    uint Unlocked = 0;
    address[] public Whitelisted;
    address[] public Investors ;
    mapping(address => uint) public InvestAmount;
    mapping(address => bool) public Whitelist;

    event Removed(address indexed Duplicate);

    receive() external payable{
        require(msg.sender == tx.origin,"Contracts Can't Enter");
        AddInvestor();
    }

    constructor(){
        Owner = msg.sender;
    }

    modifier OnlyOwner(){
        require(Owner == msg.sender,"Needs Owner Priviliges");
        _;
    }
    
    function ChangeOwner(address _Owner) public OnlyOwner returns(bool success){
        Owner = _Owner;
        return true;
    }

    function Pause() public OnlyOwner returns(bool success){
        SaleState = 3;
        return true;
    }

    function Start() public OnlyOwner returns(bool success){
        SaleState = 1;
        return true;
    }

    function Finalise() public OnlyOwner returns(bool success){
        SaleState = 2;
        return true;
    }

    function SetSale(uint _Rate, uint Min, uint Max) public OnlyOwner returns(bool success){
        Rate = _Rate;
        MinInvest = Min;
        MaxInvest = Max;
        return true;
    }

    function GetSale() public view returns(uint _Rate,uint _MinInvest, uint _MaxInvest, uint _TotalCollect, uint _Unlocked){
        _Rate = Rate;
        _MinInvest = MinInvest;
        _MaxInvest = MaxInvest;
        _TotalCollect = MaxCollect;
        _Unlocked = Unlocked;
    }

    function CheckOwnInvestment() public view returns(uint Ether,uint Token){
        Ether = InvestAmount[msg.sender];
        Token = Ether * Rate;
    }

    function CheckWhitelist(address User) public view returns(bool){
        for (uint i = 0 ; i < Whitelisted.length ; i++){
            if(Whitelisted[i] == User)  return true;
        }
        return false;
    }

    function CheckExists(address[] calldata UserList) public view returns(address) {
        for (uint i = 0 ; i < Whitelisted.length ; i++){
            for (uint a = 0 ; a < UserList.length ; a++){
                if(Whitelisted[i] == UserList[a])  return UserList[a];
            }
        }
        return address(0);
    }

    function AddtoWhitelist(address[] calldata UserList) public OnlyOwner returns(bool success){
        for (uint a = 0 ; a < UserList.length ; a++){
            Whitelisted.push(UserList[a]);
            Whitelist[UserList[a]] = true;
        }
        return true;
    }

    function RemoveFromWhitelist(address User) public OnlyOwner returns(bool success){
        for (uint i = 0 ; i < Whitelisted.length ; i++){
            if(Whitelisted[i] == User){
                Whitelisted[i] = Whitelisted[Whitelisted.length-1];
                Whitelisted.pop();
                Whitelist[User] = false;
            }
        }
        return true;
    }

    function GetETHOut() public OnlyOwner returns(bool success){
        (bool sent, ) = Owner.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
        return true;
    }

    function GetTokensOut(address TokenAddress) public OnlyOwner returns(bool success){
        require(TokenAddress != address(0), "No Tokens Were Selected");
        uint Balance = IToken(TokenAddress).balanceOf(address(this));
        require(Balance > 0,"No Tokens Detected");
        IToken(TokenAddress).transfer(Owner,Balance);
        return true;
    }

    function RescindInvestment(address User) public OnlyOwner returns(bool success){
        require(InvestAmount[User] > 0,"User Has No Investment");
        require(SaleState != 2,"Sale Finished, Can't rescind");
        uint Amount = InvestAmount[User];
        InvestAmount[User] = 0;
        (bool sent, ) = User.call{value: Amount}("");
        require(sent, "Failed to send Ether");
        return true;
    }

    function ReturnAll() public OnlyOwner returns(bool success){
        for (uint i = 0 ; i < Investors.length ; i++){
            uint Amount = InvestAmount[Investors[i]];
            if(Amount > 0){
                (bool sent, ) = Investors[i].call{value: Amount}("");
                require(sent, "Failed to send Ether");
            }
        }
        return true;
    }

    function CheckUserExists(address User) internal view returns(bool){
        for (uint i = 0 ; i < Investors.length ; i++){
            if(Investors[i] == User)
                return true;
        }
        return false;
    }

    function RemoveDuplicates() public returns(bool success) {
        uint Count = 9999999;
        for (uint i = 0 ; i < Investors.length ; i++){
            for (uint a = 0 ; a < Investors.length ; a++){
                if(i != a){
                    if(Investors[i]==Investors[a]){
                        Count = i;
                    }
                }
            }
        }
        require(Count != 9999999,"No Duplicates");
        emit Removed(Investors[Count]);
        Investors[Count] = Investors[Investors.length-1];
        Investors.pop();
        return true;
    }

    function ChangeInvestor(address from , address to) public returns(bool success){
        require(msg.sender == from,"Only Investor Can Call This Function");
        require(to != address(0),"Can't be Empty Address");
        if(CheckUserExists(to) == false)
            Investors.push(to);
        InvestAmount[from] = 0;
        InvestAmount[to] = InvestAmount[to] + InvestAmount[from];
        return true;
    }

    function TokenNeedTotal() public OnlyOwner view returns(uint Amount){
        for (uint i = 0 ; i < Investors.length ; i++){
            Amount += InvestAmount[Investors[i]];
        }
        return Amount * Rate;
    }
    
    function AddInvestor() internal returns(bool success){
        require(CheckWhitelist(msg.sender),"Not Whitelisted");
        require(SaleState!=0,"Sale Hasn't Started Yet");
        require(SaleState!=2,"Sale Ended");
        require(SaleState==1,"No Ongoing Sale");
        require(address(this).balance < MaxCollect,"Sale Filled");
        require(msg.value >= MinInvest,"Investment Amount Low");
        require(msg.value <= MaxInvest,"Investment Amount High");
        
        if(CheckUserExists(msg.sender) == false)
            Investors.push(msg.sender);
        
        InvestAmount[msg.sender] = InvestAmount[msg.sender] + msg.value;
        return true;
    }

    function SendTokens(address TokenAddress ,uint Percent) public OnlyOwner returns(bool success){
        require(SaleState == 2,"Finalise The Sale First");
        require(Unlocked < 1000,"All Tokens Already Sent");
        uint TotalNeed = (TokenNeedTotal() * Percent) / 1000;
        uint Holding = IToken(TokenAddress).balanceOf(address(this));
        require(Holding >= TotalNeed,"Contract Doesn't Have Enough Tokens");
        for (uint i = 0 ; i < Investors.length ; i++){
            IToken(TokenAddress).transfer(Investors[i],(InvestAmount[Investors[i]] * Rate * Percent) / 1000);
        }
        Unlocked += Percent;
        return true;
    }
}