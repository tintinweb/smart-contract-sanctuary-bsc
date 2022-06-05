/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;


interface ERC20 {

    function balanceOf(address _owner) view external  returns (uint256 balance);
    function transfer(address _to, uint256 _value) external  returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external  returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) view external  returns (uint256 remaining);
	//function FreezeAcc(address account, bool target) view external returns(bool);
	//function UnfreezeAcc(address account, bool target)view external returns(bool);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract banking{
    uint public totalWithdraw;
    uint public account;
    uint public totalInvested;
    uint public totalTransferAmount;
    address Owner;

    ERC20 public token;
 
   struct balanceOf{
       int256 accountnumber;
       string accountName;
       uint256 balanceStor;
       bool userExists;
      
   }

   mapping(address=>balanceOf)public users;
   mapping(uint=>address)public getUserAddress;
   

constructor(address _token){
  Owner=msg.sender;

  token=ERC20(_token);

}
  
    modifier onlyOwner(){
    require(msg.sender==Owner);

   _;
}
 function Accountinformation(int256 _accountnumber, string memory _accountName )public{
       //call.push(balance(accounts,accountsName,balanceStor));
        require(users[msg.sender].userExists==false, 'Account Already Created');
        users[msg.sender].accountnumber=_accountnumber;
        users[msg.sender].accountName=_accountName;
        account+=1;
        getUserAddress[account]=msg.sender;
        
        users[msg.sender].userExists=true;
}
 function UpdateAccount(string memory _accountName) public returns(string memory){
       require(users[msg.sender].userExists==true, 'Account UpdateAccount');
       users[msg.sender].accountName=_accountName;
      
       
       return 'Update account';  
}

  
 function deposit( uint256 amountInTokens) public  returns(string memory){
      require(token.balanceOf(msg.sender)>amountInTokens);
      require(users[msg.sender].userExists==true,"Account Already Created" );
      require(amountInTokens>0, "amountInTokens for deposit graterthen is Zero");
      token.transferFrom(msg.sender,address(this),amountInTokens);
      users[msg.sender].balanceStor=users[msg.sender].balanceStor+amountInTokens;
      totalInvested+=users[msg.sender].balanceStor;
      return 'Deposited Succesfully';
  }
  
 function withdraw(uint _balanceStor) public payable returns(string memory){
      require(users[msg.sender].balanceStor>_balanceStor);
      require(users[msg.sender].userExists==true, "Account Already Created");
      require(_balanceStor>0,"value for deposit graterthen is Zero");
      users[msg.sender].balanceStor=users[msg.sender].balanceStor-_balanceStor;
      totalWithdraw+=_balanceStor;
      token.transfer(msg.sender,_balanceStor);
    
      return 'withdrawal Succesful';
}
 
 function TransferAmount(address to, uint _balanceStor) public payable returns(string memory){
      require(users[msg.sender].balanceStor>_balanceStor);
      require(users[msg.sender].userExists==true,"Account Already Created");
      require(_balanceStor>0,"value for deposit graterthen is Zero");
      users[msg.sender].balanceStor=users[msg.sender].balanceStor-_balanceStor;
      users[to].balanceStor=users[to].balanceStor+_balanceStor;
       token.transfer(msg.sender,_balanceStor);
       totalTransferAmount+=_balanceStor;
      return 'transfer succesfully';

  
}

   
 function DeleteAccount( address _address )public  returns(string memory){
      
        require(users[_address].userExists==true, "Account Delete");
        // users[_address].accountName='';
        // users[_address].accountnumber=0;
        // users[_address].userExists=false;
        totalWithdraw=0;
        account-=1;
        totalInvested=0;
        totalTransferAmount=0;
        delete users[_address];
        return 'DeleteAccount';
}

 function getBalance()view public returns(uint){
    return token.balanceOf(address(this));

}
}