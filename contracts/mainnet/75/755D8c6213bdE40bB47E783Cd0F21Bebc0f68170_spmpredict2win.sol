/**
 *Submitted for verification at BscScan.com on 2022-10-17
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
contract spmpredict2win {
 
  address payable [] public BeterAddresses;
  address public owner;
  uint public BnbBet= 74*10**15;
  uint public BetUsd= 20*10**18;
  uint public BetSPM= 50*10**18;
  uint public ContractBusdBalance;
  uint public ContractUsdtBalance;
  uint public ContractBnbBalance;
  uint public ContractSpmBalance;
  uint[] public Percent = [5*10**18 , 10*10**18 , 15*10**18 , 20*10**18,25*10**18,50*10**18];
  address private DappWallet;
  address public usdtAddress;
  address public spmAddress;
  address public busdAddress;
  address public Feewallet;
  struct Account {
    bool exists;
    string [10] Data;
    uint BetCount;
    uint BnbBetAmount;
    uint SpmBetAmount;
    uint UsdtBetAmount;
    uint BusdBetAmount;
    uint UsdtBalance;
    uint BusdBalance;
    uint BnbBalance;
    uint SpmBalance;
    }
   mapping(address => Account) public accounts;
constructor(address _usdt, address _spm, address _busd,address _DappWallet,address _feeWallet) {
    usdtAddress =_usdt;
    spmAddress=_spm;
    busdAddress=_busd;
    DappWallet=_DappWallet;
    Feewallet=_feeWallet;
    owner = msg.sender;
  }
function BetBnb(address _BeterAddress , string memory data) public payable returns(bool){
    require(msg.sender == _BeterAddress,"Only user can bet");
    require(accounts[_BeterAddress].BetCount<=10,"You have placed max bets");
    require(msg.value>= BnbBet,"Min bet amount is 20$");
    Account memory account;
    if(accounts[_BeterAddress].exists)
    {
    account = accounts[_BeterAddress];
    account.Data[account.BetCount]=data;
    account.BetCount+=1;
    account.BnbBetAmount+=msg.value;
    accounts[_BeterAddress]=account;
    return true;
    }
    account = Account(true,["","","","","","","","","",""],0,0,0,0,0,0,0,0,0);
    BeterAddresses.push(payable (_BeterAddress));
    account.exists = true;
    account.Data[account.BetCount]=data;
    account.BetCount+=1;
    account.BnbBetAmount+=msg.value;
    accounts[_BeterAddress]=account;
    return true;
}
function BetOtherCurrency(address _BeterAddress , string memory data , uint ammount, string memory currency) public returns(bool){
    require(msg.sender == _BeterAddress,"Only user can bet");
    require(accounts[_BeterAddress].BetCount<=10,"You have placed max bets");
    
    Account memory account;
    if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("USDT"))))
    {
        require(ammount>= BetUsd,"Min bet amount is 20$");
        IERC20 usdt = IERC20(address(usdtAddress));
        if(accounts[_BeterAddress].exists)
            {
                account = accounts[_BeterAddress];
                account.Data[account.BetCount]=data;
                account.BetCount+=1;
                account.UsdtBetAmount+=ammount;
                accounts[_BeterAddress]=account;
                
                
              usdt.transferFrom(_BeterAddress, address(this),ammount);
                return true;
            }
            account = Account(true,["","","","","","","","","",""],0,0,0,0,0,0,0,0,0);
            BeterAddresses.push(payable (_BeterAddress));
            account.exists = true;
            account.Data[account.BetCount]=data;
            account.BetCount+=1;
            account.UsdtBetAmount+=ammount;
            accounts[_BeterAddress]=account;
            usdt.transferFrom(_BeterAddress, address(this),ammount);
            return true;

    }
     if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("BUSD"))))
    {
        require(ammount>= BetUsd,"Min bet amount is 20$");
        IERC20 busd = IERC20(address(busdAddress));
        if(accounts[_BeterAddress].exists)
            {
                account = accounts[_BeterAddress];
                account.Data[account.BetCount]=data;
                account.BetCount+=1;
                account.BusdBetAmount+=ammount;
                accounts[_BeterAddress]=account;
                
            
         
                busd.transferFrom(_BeterAddress, address(this),ammount);
                return true;
            }
            account = Account(true,["","","","","","","","","",""],0,0,0,0,0,0,0,0,0);
            BeterAddresses.push(payable (_BeterAddress));
            account.exists = true;
            account.Data[account.BetCount]=data;
            account.BetCount+=1;
            account.BusdBetAmount+=ammount;
            accounts[_BeterAddress]=account;
            busd.transferFrom(_BeterAddress, address(this),ammount);
            return true;

    }
    if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("SPM"))))
    {
        require(ammount>= BetSPM,"Min bet amount is 20$");
        IERC20 spm = IERC20(address(spmAddress));
        if(accounts[_BeterAddress].exists)
            {
                account = accounts[_BeterAddress];
                account.Data[account.BetCount]=data;
                account.BetCount+=1;
                account.SpmBetAmount+=ammount;
                accounts[_BeterAddress]=account;
                
            
                spm.transferFrom(_BeterAddress, address(this),ammount);
                return true;
            }
            account = Account(true,["","","","","","","","","",""],0,0,0,0,0,0,0,0,0);
            BeterAddresses.push(payable (_BeterAddress));
            account.exists = true;
            account.Data[account.BetCount]=data;
            account.SpmBetAmount+=ammount;
            account.BetCount+=1;
            accounts[_BeterAddress]=account;
            spm.transferFrom(_BeterAddress, address(this),ammount);
            return true;

    }
    return false;
    
}
function GetData(address _UserAddress ) external view returns( string[] memory){
    uint n = accounts[_UserAddress].BetCount;
    string[] memory array = new string[](n);
    for (uint i = 0; i < n; i++)
            array[i] = accounts[_UserAddress].Data[i];
    return array;
   
}
function remove(uint index, string[10] memory array) internal pure returns(string[10] memory) {
        if (index >= array.length) return array;

        for (uint i = index; i<array.length-1; i++){
            array[i] = array[i+1];
        }
        delete array[array.length-1];
        return array;
    }

function CheckWin(address _UserAddress , bool check, uint _amount , uint _type, string memory currency, uint index) public returns(bool){
    require(accounts[_UserAddress].exists,"You have not placed any bet yet");
    require(msg.sender==DappWallet,"Only user can run");
    Account memory account;
    account = accounts[_UserAddress];
    if(check)
    {
        if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("USDT"))))
        {
            require(account.UsdtBetAmount>= BetUsd,"Min bet amount is 20$");
            account.UsdtBalance+=_amount*_type;
            account.Data=remove(index,account.Data);
            account.UsdtBetAmount-=_amount;
            account.BetCount-=1;
        }
        else if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("BUSD"))))
        {
            require(account.BusdBetAmount>= BetUsd,"Min bet amount is 20$");
            account.BusdBalance+=_amount*_type;
            account.Data=remove(index,account.Data);
            account.BusdBetAmount-=_amount;
            account.BetCount-=1;

        }
        else if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("SPM"))))
        {
            require(account.SpmBetAmount>= BetSPM,"Min bet amount is 20$");
            account.SpmBalance+=_amount*_type;
            account.Data=remove(index,account.Data);
            account.SpmBetAmount-=_amount;
            account.BetCount-=1;

        }
        else if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("BNB"))))
        {
            require(account.BnbBetAmount>= BnbBet,"Min bet amount is 20$");
            account.BnbBalance+=_amount*_type;
            account.Data=remove(index,account.Data);
            account.BnbBetAmount-=_amount;
            account.BetCount-=1;

        }
    }
    else if(!check)
    {
        uint balance;
      
            if(_type==2)
                {
                    balance=Percent[0]*_amount/(100*10**18);
                }
            else if(_type==3)
                {
                    balance=Percent[1]*_amount/(100*10**18);   
                }
            else if(_type==4)
                {
                    balance=Percent[2]*_amount/(100*10**18);
                }
            else if(_type==5)
                {
                    balance=Percent[3]*_amount/(100*10**18);
                } 
            else if(_type==10)
                {
                    balance=Percent[4]*_amount/(100*10**18);
                }
            else if(_type==20)
                {
                    balance=Percent[5]*_amount/(100*10**18);
                } 
            else if(_type==50)
                {
                    balance=_amount;
                } 
            else if(_type==100)
                {
                    balance=_amount;
                }     
                  if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("USDT"))))
        {
                IERC20 usdt = IERC20(address(usdtAddress));
                usdt.transfer(Feewallet,balance/2);
              
                ContractUsdtBalance += balance/2;
                account.UsdtBalance += _amount-balance;
                account.Data=remove(index,account.Data);
                account.UsdtBetAmount-=_amount;
                account.BetCount-=1;       
        }
        else if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("BNB"))))
        {
            
           payable(Feewallet).transfer(balance/2);
           ContractBnbBalance += balance/2;
                account.BnbBalance += _amount-balance;
                account.Data=remove(index,account.Data);
                account.BnbBetAmount-=_amount;
                account.BetCount-=1;                
        }
        else if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("BUSD"))))
        {
            IERC20 busd = IERC20(address(busdAddress));
           busd.transfer(Feewallet,balance/2);
             ContractBusdBalance +=balance/2;
                account.BusdBalance += _amount-balance;
                account.Data=remove(index,account.Data);
                account.BusdBetAmount-=_amount;
                account.BetCount-=1;        
        }
        else if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("SPM"))))
        {
             IERC20 spm = IERC20(address(spmAddress));
    spm.transfer(Feewallet,balance/2);
             ContractSpmBalance += balance/2;
                account.SpmBalance += _amount-balance;
                account.Data=remove(index,account.Data);
                account.SpmBetAmount-=_amount;
                account.BetCount-=1;              
        }
        

    }
    accounts[_UserAddress]=account;
  return true;
}
function UserWithdrawal(address _UserAddress) public returns(bool){
    require(msg.sender == _UserAddress,"Only user can withdraw");
    require(accounts[_UserAddress].exists,"You do not have any Balance");
    IERC20 usdt = IERC20(address(usdtAddress));
    usdt.transfer(_UserAddress,accounts[_UserAddress].UsdtBalance);
    IERC20 busd = IERC20(address(busdAddress));
    busd.transfer(_UserAddress,accounts[_UserAddress].BusdBalance);
    IERC20 spm = IERC20(address(spmAddress));
    spm.transfer(_UserAddress,accounts[_UserAddress].SpmBalance);
    payable(_UserAddress).transfer(accounts[_UserAddress].BnbBalance);
    Account memory account;
    account= accounts[_UserAddress];
    account.UsdtBalance = 0;
    account.BusdBalance = 0;
    account.SpmBalance = 0;
    account.BusdBalance = 0;

    return true;


}
function OwnerWithdrawal() public returns(bool){
    require(msg.sender == owner,"Only owner can withdraw");
    
    IERC20 usdt = IERC20(address(usdtAddress));
    usdt.transfer(owner,ContractUsdtBalance);
    IERC20 busd = IERC20(address(busdAddress));
    busd.transfer(owner,ContractBusdBalance);
    IERC20 spm = IERC20(address(spmAddress));
    spm.transfer(owner,ContractSpmBalance);
    payable(owner).transfer(ContractBnbBalance);
    ContractBnbBalance =0;
    ContractBusdBalance =0;
    ContractSpmBalance =0;
    ContractUsdtBalance=0;

    return true;


}
function TopUpBnb() public payable returns(bool){
    require(msg.value>0,"TopUp amount is too low");
    ContractBnbBalance += msg.value;
    return true;
}
function TopUpOtherCurrencies(string memory currency, uint _amount) public returns(bool)
{
    require(_amount>0,"Amount must be greater then zero");
    if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("BUSD"))))
    {
        IERC20 Busd = IERC20(address(spmAddress));
        Busd.transferFrom(msg.sender, address(this),_amount);
        ContractSpmBalance += _amount;
        return true;
    }
    if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("USDT"))))
    {
        IERC20 Usdt = IERC20(address(spmAddress));
        Usdt.transferFrom(msg.sender, address(this),_amount);
        ContractSpmBalance += _amount;
        return true;
    }
    if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("SPM"))))
    {
        IERC20 spm = IERC20(address(spmAddress));
        spm.transferFrom(msg.sender, address(this),_amount);
        ContractSpmBalance += _amount;
        return true;

    }
    return false;

}

function ChangeBetFeePercentage(uint _type, uint _NewFeePercentage) public returns(bool)
{
        require(msg.sender==owner,"You must be owner to run this");
        require(_type>=5&&_type<=2,"Invalid Type");
        if(_type==2)
        {
            Percent[0]=_NewFeePercentage;
            return true;
        }
        if(_type==3)
        {
            Percent[1]=_NewFeePercentage;
            return true;
        }
        if(_type==4)
        {
            Percent[2]=_NewFeePercentage;
            return true;
        }
        if(_type==5)
        {
            Percent[3]=_NewFeePercentage;
            return true;
        }
         if(_type==10)
        {
            Percent[4]=_NewFeePercentage;
            return true;
        }
         if(_type==50)
        {
            Percent[5]=_NewFeePercentage;
            return true;
        }
        return false;

}

}