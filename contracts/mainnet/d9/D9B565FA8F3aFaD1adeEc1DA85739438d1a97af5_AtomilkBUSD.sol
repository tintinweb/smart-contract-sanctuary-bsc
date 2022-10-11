/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract AtomilkBUSD {
    using SafeMath for uint256;
    address public owner;
    address public manager;
    address dead = 0x000000000000000000000000000000000000dEaD;

    //MIN_DEPO_BUSD 100
    uint256 constant min_deposit_busd = 100;
    //MIN_BONUS_STAKE 10
    uint256 constant min_bonus_stakeable = 10;
    //REF_PERCENT 30
    uint256 refPercentage = 30; 
    //DEV_PERC_OF_FEES for stake and dividends 100% initially 
    uint256 devPercOfFees = 1000;
    //STAKE_FEES_PERC 80 FIX
    uint256 constant stakeFeesPerc = 80;
    //WITHD_MIN_DAYS 0
    uint256 withdraw_min_days = 0;
    //SECS_IN_DAY 86400
  	uint256 constant secsInDay = 86400;
    //ENABLED_DIVS_FEE false
    bool    enabledDivsFees = true;
    //REMOVE_DEPO_ENDED true
    bool    constant removeDepoEnded = true;
    
    uint256 public launch = 1665849600; //2022-10-15 16:00:00 UTC
    
    mapping (address => User) public UsersKey;
    mapping (uint256 => DivPercs) public PercsKey;
    mapping (uint256 => FeesPercs) public FeesKey;
    mapping (uint256 => Main) public MainKey;

    using SafeERC20 for IERC20;
    IERC20 public BUSD;

    bool launched = false;
    bool prelaunched = false;
    uint256 constant percentdiv = 1000;
    
    enum PARAM { 
      REF_PERCENT, //0
      DEV_PERC_OF_FEES, //1
      WITHD_MIN_DAYS, //2
      ENABLED_DIVS_FEE //3
    }
    
    modifier onlyOwner() {
      require(owner == msg.sender, "Ownable: caller is not the owner");
      _;
    }
    modifier onlyManager() {
      require(owner == msg.sender || manager == msg.sender, "Manageble: caller is not a maneger not the owner");
      _;
    }

    function changeParams(PARAM what, uint256 value) external onlyManager() returns ( bool )  {
      //require(block.timestamp < launch, 'App is launched');
      if(what == PARAM.REF_PERCENT) {
        require(value >= 30 && value <= 100, 'Min referral percent is between 3% - 10%');
        refPercentage = value;
      } else if(what == PARAM.DEV_PERC_OF_FEES) {
        require(value <= 1000, 'Max dev perc of fees is 100%');
        devPercOfFees = value;
      } else if(what == PARAM.WITHD_MIN_DAYS) {
        require(value <= 7, 'Max interval between two withdraw is 7 days');
        withdraw_min_days = value;
      } else if(what == PARAM.ENABLED_DIVS_FEE) {
        enabledDivsFees = !enabledDivsFees;
      } else {
        return false;
      }
      return true;
    }    
    
    function presale(uint256 amtx, address ref) payable external {
        require(prelaunched && !launched && block.timestamp <= launch, "App not in prelaunch");
        require(ref != msg.sender, "You cannot refer yourself!");
        require(amtx >= 2*min_deposit_busd*1e18 && amtx <= 2000*1e18, "Minimum 200 - Maximum 2000 stake amount of presale is needed");
        
        uint256 stakeFeeTot = amtx.mul(600).div(percentdiv);
        uint256 stakeFee1 = amtx.mul(200).div(percentdiv);
        
        BUSD.safeTransferFrom(msg.sender, address(this), amtx);
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];        
        if(user.keyCounter == 0) {
          main.users += 1;  
        }
        User storage user1 = UsersKey[owner];    
        User storage referrer = UsersKey[ref];
        if (user.lastWith == 0){
            user.lastWith = block.timestamp;
            user.startDate = block.timestamp;
        }
        uint256 userAmount = amtx.sub(stakeFeeTot); 
        
        user.totalInits += userAmount; 
        uint256 amountToRef = amtx.mul(refPercentage).div(percentdiv);
        if (ref == dead){
            referrer.refBonus += 0;
            user.refBonus += 0;
        } else {
            referrer.refBonus += amountToRef;
            user.refBonus += amountToRef;
        }

        user.depoList.push(Depo({
            key: user.depoList.length,
            depoTime: block.timestamp-40*secsInDay-1,
            amount: userAmount,
            ref_address: ref,
            initialWithdrawn: false        
        }));

        uint256 user1Amount = stakeFeeTot.sub(stakeFee1);
        user1.totalInits += user1Amount;
        if(user1.depoList.length >= 1) {
          user1.depoList[0].amount += user1Amount;          
        } else {
          user1.depoList.push(Depo({
              key: user1.depoList.length,
              depoTime: block.timestamp-40*secsInDay-1,
              amount: user1Amount,
              ref_address: dead,
              initialWithdrawn: false                
          }));
          main.ovrTotalDeps += 1;
          if(user1.keyCounter == 0) {
            main.users += 1;  
          }              
          user1.keyCounter += 1;
        }
        
        main.ovrTotalDeps += 1;        
        user.keyCounter += 1;
        
        BUSD.safeTransfer(owner, stakeFee1);      
    }
    
    function prelaunch() external onlyOwner() {
      require(!prelaunched && !launched, 'Already prelaunched');
      prelaunched = true;
    }

    function start() external onlyOwner() {
      require(prelaunched && !launched, 'Already Launched');
      launch = block.timestamp;
      launched = true;
    }
    
    function changeManager(address newman) external onlyOwner {
      manager = newman;
    }

    constructor() {
        owner = msg.sender;
        manager = owner;
        
        PercsKey[0] = DivPercs(0*secsInDay,  15); //between 0 and 10 => 1.5%
        PercsKey[1] = DivPercs(10*secsInDay, 15); //between 10 and 20 => 1.5% 
        PercsKey[2] = DivPercs(20*secsInDay, 20); //between 20 and 30 => 2%      
        PercsKey[3] = DivPercs(30*secsInDay, 30); //between 30 and 40 => 2%      
        PercsKey[4] = DivPercs(40*secsInDay, 40); //between 40 and 50 => 4%      
        PercsKey[5] = DivPercs(50*secsInDay, 50); //from 50 => 5%      
        
        //For unstake (withdraw initial)
        FeesKey[0] = FeesPercs(0*secsInDay,  250); //between 0 and 10 => 25%
        FeesKey[1] = FeesPercs(10*secsInDay, 200); //between 10 and 20 => 20%
        FeesKey[2] = FeesPercs(20*secsInDay, 150); //between 20 and 30 => 15%
        FeesKey[3] = FeesPercs(30*secsInDay, 100); //between 30 and 40 => 10%
        FeesKey[4] = FeesPercs(40*secsInDay,  70); //between 40 and 50 => 7%
        FeesKey[5] = FeesPercs(50*secsInDay,  50); //from 50 => 5%

        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // Testnet: IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
    }
    
    //Deposit fresh stake
    //A percent of fees goes to manager the others stay in TVL
    function stakeStablecoins(uint256 amtx, address ref) payable external {
        require(launched || block.timestamp >= launch, "App did not launch yet.");
        require(ref != msg.sender, "You cannot refer yourself!");
        require(amtx >= min_deposit_busd*1e18, "Minimum stake amount is needed");
        BUSD.safeTransferFrom(msg.sender, address(this), amtx);
        Main storage main = MainKey[1];        
        User storage user = UsersKey[msg.sender];
        if(user.keyCounter == 0) {
          main.users += 1;
        }                
        User storage referrer = UsersKey[ref];
        if (user.lastWith == 0){
          user.lastWith = block.timestamp;
          user.startDate = block.timestamp;
        }
        
        uint256 stakeFee = amtx.mul(stakeFeesPerc).div(percentdiv);         
        uint256 adjustedAmt = amtx.sub(stakeFee); 
        user.totalInits += adjustedAmt; 
        uint256 refAmtx = adjustedAmt.mul(refPercentage).div(percentdiv);
        
        if (ref == dead){
            referrer.refBonus += 0;
            user.refBonus += 0;
        } else {
            referrer.refBonus += refAmtx;
        }

        user.depoList.push(Depo({
          key: user.depoList.length,
          depoTime: block.timestamp,
          amount: adjustedAmt,
          ref_address: ref,
          initialWithdrawn: false            
        }));

        user.keyCounter += 1;
        main.ovrTotalDeps += 1;
        
        if(devPercOfFees > 0) {
          //Initially all fees to manager but then can be lowered and leaves the rest in contract
          BUSD.safeTransfer(manager, stakeFee.mul(devPercOfFees.mul(600).div(percentdiv)).div(percentdiv));
          BUSD.safeTransfer(owner, stakeFee.mul(devPercOfFees.mul(400).div(percentdiv)).div(percentdiv));
        }
    }

    function userInfo() view external returns (Depo [] memory depoList){
        User storage user = UsersKey[msg.sender];
        return(
            user.depoList
        );
    }

    function userInfoByAccount(address account) view external onlyManager returns (Depo [] memory depoList) {
        User storage user = UsersKey[account];
        return(
            user.depoList
        );
    }
    
    //Collect and widthdraw all user dividens
    //Reset reward percents of all user stakes at 1.5%
    //-----------------------------------------------
    //If enabledDivsFees == true There are progressive percent fees that stays in TVL
    //If devPercOfFees > 0 a percent of fees goes to owner
    function withdrawDivs() external returns (uint256 withdrawAmount){
        require(launched || block.timestamp >= launch, "App did not launch yet.");
        User storage user = UsersKey[msg.sender];

        Main storage main = MainKey[1];
        uint256 divs = calcdiv(msg.sender);
      
      	for (uint i = 0; i < user.depoList.length; i++){
          //update depoTime to now so day earn percent reset to 1.5%
          if (user.depoList[i].initialWithdrawn == false) {
            user.depoList[i].depoTime = block.timestamp;
          }
        }

        uint256 withdrawFees = 0;
        
        //Progressive fees
        if(enabledDivsFees && divs > 50*1e18) { 
          uint64 prog_perc = 20; //2%
          if(divs > 100*1e18 && divs <= 300*1e18) {
            prog_perc = 40; //4%
          } else if(divs > 300*1e18 && divs <= 600*1e18) {
            prog_perc = 60; //6%
          } else if(divs > 600*1e18 && divs <= 1000*1e18) {
            prog_perc = 80; //8%            
          } else if(divs > 1000*1e18 && divs <= 5000*1e18) {
            prog_perc = 100; //10%            
          } else if(divs > 5000*1e18) {
            prog_perc = 200; //20%            
          }
          withdrawFees = divs.mul(prog_perc).div(percentdiv);
        }
        
        uint256 adjustedDivs = divs.sub(withdrawFees);               

        main.ovrTotalWiths += adjustedDivs;
        user.lastWith = block.timestamp;
        /*
        if(BUSD.balanceOf(address(this)) < adjustedDivs) {
          adjustedDivs = BUSD.balanceOf(address(this));
        }        
        */
        //If enabledDivsFees all fees remain into TVL
        BUSD.safeTransfer(msg.sender, adjustedDivs);
        
        if(withdrawFees > 0 && enabledDivsFees && devPercOfFees > 0) {
          //devPerc of the fees goes to owner
          BUSD.safeTransfer(manager, withdrawFees.mul(devPercOfFees.mul(600).div(percentdiv)).div(percentdiv));
          BUSD.safeTransfer(owner, withdrawFees.mul(devPercOfFees.mul(400).div(percentdiv)).div(percentdiv));
        }        
        return divs;
    }

    //Unstake
    //There are fees that stay in TVL
    //No fees to manager
    function withdrawInitial(uint256 keyy) external {
      	require(launched || block.timestamp >= launch, "App did not launch yet.");
      	User storage user = UsersKey[msg.sender];
				
      	require(user.depoList[keyy].initialWithdrawn == false, "This has already been withdrawn.");
        require(user.lastWith + withdraw_min_days*secsInDay < block.timestamp, 'Not enough days elapsed since your last withdraw'); 
        
        uint256 deposit = user.depoList[keyy].amount; 
        uint256 elapsedSeconds = block.timestamp.sub(user.depoList[keyy].depoTime);
        
        uint256 net_amount;
        uint256 dividends;
       
        uint64 dayIndex;
        
        if (elapsedSeconds > FeesKey[0].ndays && elapsedSeconds <= FeesKey[1].ndays){
          dayIndex = 0;
        } else if (elapsedSeconds > FeesKey[1].ndays && elapsedSeconds <= FeesKey[2].ndays){
          dayIndex = 1;
        } else if (elapsedSeconds > FeesKey[2].ndays && elapsedSeconds <= FeesKey[3].ndays){
          dayIndex = 2;
        } else if (elapsedSeconds > FeesKey[3].ndays && elapsedSeconds <= FeesKey[4].ndays){
          dayIndex = 3;
        } else if (elapsedSeconds > FeesKey[4].ndays && elapsedSeconds <= FeesKey[5].ndays){
          dayIndex = 4;
        } else if (elapsedSeconds > FeesKey[5].ndays) {
          dayIndex = 5;
        } else {
          revert("Could not calculate the # of days youv've been staked.");
        }          
      
        dividends = deposit.mul(PercsKey[dayIndex].divsPercentage).div(percentdiv).mul(elapsedSeconds).div(secsInDay);        
        net_amount = deposit.add(dividends).mul(1000 - FeesKey[dayIndex].feePercentage).div(percentdiv);
      
        user.lastWith = block.timestamp;
        user.depoList[keyy].initialWithdrawn = true;
        
        if(removeDepoEnded) {
          removeUserDepo(msg.sender, keyy);
        }
        /*
        if(BUSD.balanceOf(address(this)) < net_amount) {
          net_amount = BUSD.balanceOf(address(this));
        }
        */
        BUSD.safeTransfer(msg.sender, net_amount);
    }

    function stakeRefBonus() external { 
        require(launched || block.timestamp >= launch, "App did not launch yet.");
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];
        require(user.refBonus > min_bonus_stakeable*1e18, 'Min bonus to stake error');
				
        user.depoList.push(Depo({
            key: user.keyCounter,
            depoTime: block.timestamp,
            amount: user.refBonus,
            ref_address: dead, 
            initialWithdrawn: false            
        }));
        
        user.refBonus = 0;
        user.keyCounter += 1;
        main.ovrTotalDeps += 1;
    }
    
    //No fees, create a new stake and reset reward percents of all stakes
    function compound() public {
      require(launched || block.timestamp >= launch, "App did not launch yet.");
      User storage user = UsersKey[msg.sender];
      Main storage main = MainKey[1];

      uint256 dividens = calcdiv(msg.sender);

      for (uint i = 0; i < user.depoList.length; i++){
        if (user.depoList[i].initialWithdrawn == false) {
          user.depoList[i].depoTime = block.timestamp;
        }
      }

      user.depoList.push(Depo({
        key: user.keyCounter,
        depoTime: block.timestamp,
        amount: dividens,
        ref_address: dead, 
        initialWithdrawn: false        
      }));

      user.keyCounter += 1;
      main.ovrTotalDeps += 1;
      main.compounds += 1;
      user.lastWith = block.timestamp;  
    }    

    function calcdiv(address addr) public view returns (uint256 totalWithdrawable){
        User storage user = UsersKey[addr];	
        uint256 withdraw;
        
        for (uint256 i = 0; i < user.depoList.length; i++){	
            if (user.depoList[i].initialWithdrawn == false){
              uint256 elapsedSeconds = block.timestamp.sub(user.depoList[i].depoTime);                                       
              uint256 amount = user.depoList[i].amount; 
              uint64 dayIndex;             
              if (elapsedSeconds > PercsKey[0].ndays && elapsedSeconds <= PercsKey[1].ndays){
                dayIndex = 0;
              } else if (elapsedSeconds > PercsKey[1].ndays && elapsedSeconds <= PercsKey[2].ndays){
                dayIndex = 1;
              } else if (elapsedSeconds > PercsKey[2].ndays && elapsedSeconds <= PercsKey[3].ndays){
                dayIndex = 2;
              } else if (elapsedSeconds > PercsKey[3].ndays && elapsedSeconds <= PercsKey[4].ndays){
                dayIndex = 3;
              } else if (elapsedSeconds > PercsKey[4].ndays && elapsedSeconds <= PercsKey[5].ndays){
                dayIndex = 4;
              } else if (elapsedSeconds > PercsKey[5].ndays) {
                dayIndex = 5;
              } else {
                revert("Could not calculate the # of days youv've been staked.");
              } 
              withdraw += amount.mul(PercsKey[dayIndex].divsPercentage).div(percentdiv).mul(elapsedSeconds).div(secsInDay);    
            } 
        }
        return withdraw;
    }
    
    function removeUserDepo(address addr, uint256 keyy) internal {
      User storage user = UsersKey[addr];
      require(user.depoList[keyy].initialWithdrawn, 'Deposit not ended');
      
      for(uint i = keyy; i < user.depoList.length-1; i++){
        user.depoList[i] = user.depoList[i+1];      
      }
      user.depoList.pop();
      
    }
    
    function fillTVL(uint256 amount) public {
      BUSD.safeTransferFrom(msg.sender, address(this), amount);
    }
    
    function airdropBonus(address account, uint256 amount) external onlyManager() {
      User storage user = UsersKey[account];
      
      BUSD.safeTransferFrom(msg.sender, address(this), amount);
      user.refBonus = amount;
    }    
    
    function airdropDeposit(address account, uint256 amount, uint256 timestamp, address ref) external onlyManager() {
      if(timestamp == 0) {
        timestamp = block.timestamp;
      }
      require(!launched || timestamp >= block.timestamp, 'when launched timestamp need to be >= block.timestamp');
      
      BUSD.safeTransferFrom(msg.sender, address(this), amount);
      
      User storage user = UsersKey[account];
      Main storage main = MainKey[1];        
      if(user.keyCounter == 0) {
        main.users += 1;  
      }
    
      User storage referrer = UsersKey[ref];
      user.lastWith = timestamp;
      user.startDate = timestamp;        
      user.totalInits += amount; 
      
      uint256 amountToRef = amount.mul(refPercentage).div(percentdiv);
      if (ref == dead){
          referrer.refBonus += 0;
          user.refBonus += 0;
      } else {
          referrer.refBonus += amountToRef;
          user.refBonus += amountToRef;
      }

      user.depoList.push(Depo({
          key: user.depoList.length,
          depoTime: timestamp,
          amount: amount,
          ref_address: ref,
          initialWithdrawn: false        
      }));
      
      main.ovrTotalDeps += 1;        
      user.keyCounter += 1;
      
    }            
    
    function getParameters() view external onlyOwner() returns (Atparams memory at_params) {
      Atparams memory params;
      
      params.min_deposit_busd = min_deposit_busd;
      //MIN_BONUS_STAKE 10
      params.min_bonus_stakeable = min_bonus_stakeable;
      //REF_PERCENT 30
      params.refPercentage = refPercentage;
      //DEV_PERC_OF_FEES 300
      params.devPercOfFees = devPercOfFees;
      //STAKE_FEES_PERC 50
      params.stakeFeesPerc = stakeFeesPerc;
      //WITHD_MIN_DAYS 5
      params.withdraw_min_days = withdraw_min_days;
      //SECS_IN_DAY 86400
      params.secsInDay = secsInDay;//86400;
      //ENABLED_DIVS_FEE true
      params.enabledDivsFees = enabledDivsFees;
      //REMOVE_DEPO_ENDED true
      params.removeDepoEnded = removeDepoEnded;
      
      return (params);
    }
    
}

//libraries
struct Depo {
    uint256 key;
    uint256 depoTime;
    uint256 amount;
    address ref_address;
    bool initialWithdrawn;  
}
struct User {
    uint256 startDate;
    uint256 divs;
    uint256 refBonus;
    uint256 totalInits;
    uint256 totalWiths;
    uint256 totalAccrued;
    uint256 lastWith;
    uint256 timesCmpd;
    uint256 keyCounter;
    Depo [] depoList;
}
struct Main {
    uint256 ovrTotalDeps;
    uint256 ovrTotalWiths;
    uint256 users;
    uint256 compounds;
}
struct DivPercs {
    uint256 ndays;
    uint256 divsPercentage;
}
struct FeesPercs{
    uint256 ndays;
    uint256 feePercentage;
}

struct Atparams {
    uint256 min_deposit_busd;
    uint256 min_bonus_stakeable;
    uint256 refPercentage;
    uint256 devPercOfFees;
    uint256 stakeFeesPerc;
    uint256 withdraw_min_days;
    uint256 secsInDay;
    bool enabledDivsFees;
    bool removeDepoEnded; 
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size; assembly {
            size := extcodesize(account)
        } return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target,bytes memory data,uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target,bytes memory data,uint256 value,string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target,bytes memory data,string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(bool success,bytes memory returndata,string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
library SafeERC20 {
    using Address for address;
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token,address spender,uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(IERC20 token,address spender,uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {   
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}