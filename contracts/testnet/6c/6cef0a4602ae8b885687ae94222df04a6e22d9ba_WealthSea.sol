/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;


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
//libraries
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
struct Depo {
    uint256 key;
    uint256 depoTime;
    uint256 amt;
    address reffy;
    bool initialWithdrawn;
}
struct Main {
    uint256 ovrTotalDeps;
    uint256 ovrTotalWiths;
    uint256 users;
    uint256 compounds;
}
struct DivPercs{
    uint256 daysInSeconds; // updated to be in seconds
    uint256 divsPercentage;
}
struct FeesPercs{
    uint256 daysInSeconds;
    uint256 feePercentage;
}

struct jackpot_info {
    address lastWinner1;
    uint256 depositAmount1;

    address lastWinner2;
    uint256 depositAmount2;

    address lastWinner3;
    uint256 depositAmount3;

    uint256 drawTime;
}

struct today_big_deposits {
    address top1depositorAddress;
    uint256 top1depositAmount;

    address top2depositorAddress;
    uint256 top2depositAmount;

    address top3depositorAddress;
    uint256 top3depositAmount;
}

contract WealthSea {
    using SafeMath for uint256;
    uint256 constant launch = 1665426600; //10th Sept 2022 18:30 UTC
    
  	uint256 constant hardDays = 86400;
    uint256 constant percentdiv = 1000;
    uint256 constant jackpot_percent = 1;
    uint256 refPercentage = 100; //10%
    uint256 devPercentage = 0;
    mapping (address => mapping(uint256 => Depo)) public DeposMap;
    mapping (address => User) public UsersKey;
    mapping (uint256 => DivPercs) public PercsKey;
    mapping (uint256 => FeesPercs) public FeesKey;
    mapping (uint256 => Main) public MainKey;
    
    jackpot_info public jackpot;
    today_big_deposits public todayBigDeposit;
    
    using SafeERC20 for IERC20;
    IERC20 public BUSD;

    address public dev = 0xCB4F6f85d6Bee66572e9938E52a0806450872B69;

    constructor() {

            PercsKey[10] = DivPercs(864000, 15);
            PercsKey[20] = DivPercs(1728000, 25);
            PercsKey[30] = DivPercs(2592000, 35);
            PercsKey[40] = DivPercs(3456000, 45);
            PercsKey[50] = DivPercs(4320000, 55);
            FeesKey[10] = FeesPercs(864000, 120);
            FeesKey[20] = FeesPercs(1728000, 100);
            FeesKey[30] = FeesPercs(3456000, 80);
            FeesKey[40] = FeesPercs(4320000, 60);

            BUSD = IERC20(0xf4675722dbC841EEF6D88C8890d9A50FcCB153b8);

            jackpot.drawTime = launch;
    }

    function distributeJackpot() public {
        if(((block.timestamp - jackpot.drawTime)/3600) >= 24){
        
            jackpot.lastWinner1 = todayBigDeposit.top1depositorAddress;
            jackpot.depositAmount1 = todayBigDeposit.top1depositAmount;

            jackpot.lastWinner2 = todayBigDeposit.top2depositorAddress;
            jackpot.depositAmount2 = todayBigDeposit.top2depositAmount;

            jackpot.lastWinner3 = todayBigDeposit.top3depositorAddress;
            jackpot.depositAmount3 = todayBigDeposit.top3depositAmount;

            uint256 jackpotTotalAmount = SafeMath.div(SafeMath.mul(BUSD.balanceOf(address(this)),jackpot_percent),100);
            uint256 jackpotIndividualAmount = SafeMath.div(jackpotTotalAmount,3);

            if(jackpot.lastWinner1 != address(0)){
                BUSD.transfer(jackpot.lastWinner1, jackpotIndividualAmount);
            }
            if(jackpot.lastWinner2 != address(0)){
                BUSD.transfer(jackpot.lastWinner2, jackpotIndividualAmount);
            }
            if(jackpot.lastWinner3 != address(0)){
                BUSD.transfer(jackpot.lastWinner3, jackpotIndividualAmount);
            }

            todayBigDeposit.top1depositAmount = 0;
            todayBigDeposit.top1depositorAddress = address(0);

            todayBigDeposit.top2depositAmount = 0;
            todayBigDeposit.top2depositorAddress = address(0);

            todayBigDeposit.top3depositAmount = 0;
            todayBigDeposit.top3depositorAddress = address(0);

            jackpot.drawTime = block.timestamp;
        }
    }

    function checkAndSetTop3Deposits(uint256 _amount) internal {
        if(_amount > todayBigDeposit.top3depositAmount && _amount < todayBigDeposit.top2depositAmount){

            todayBigDeposit.top3depositAmount = _amount;
            todayBigDeposit.top3depositorAddress = msg.sender;

        } else if(_amount > todayBigDeposit.top2depositAmount && _amount < todayBigDeposit.top1depositAmount){

            todayBigDeposit.top1depositAmount = todayBigDeposit.top2depositAmount;
            todayBigDeposit.top1depositorAddress = todayBigDeposit.top2depositorAddress;

            todayBigDeposit.top2depositAmount = _amount;
            todayBigDeposit.top2depositorAddress = msg.sender;

        } else if(_amount > todayBigDeposit.top1depositAmount){

            todayBigDeposit.top1depositAmount = todayBigDeposit.top2depositAmount;
            todayBigDeposit.top1depositorAddress = todayBigDeposit.top2depositorAddress;

            todayBigDeposit.top2depositAmount = todayBigDeposit.top3depositAmount;
            todayBigDeposit.top2depositorAddress = todayBigDeposit.top3depositorAddress;

            todayBigDeposit.top3depositAmount = _amount;
            todayBigDeposit.top3depositorAddress = msg.sender;

        } 
    }

    function stakeStablecoins(uint256 amtx, address ref) payable public {
        require(block.timestamp >= launch, "App did not launch yet.");
        require(ref != msg.sender, "You cannot refer yourself!");
        checkAndSetTop3Deposits(amtx);
        BUSD.safeTransferFrom(msg.sender, address(this), amtx);
        User storage user = UsersKey[msg.sender];
        User storage user2 = UsersKey[ref];
        Main storage main = MainKey[1];
        
        uint256 userStakePercentAdjustment = 1000 - devPercentage;
        uint256 adjustedAmt = amtx.mul(userStakePercentAdjustment).div(percentdiv); 
        
        uint256 refAmtx = adjustedAmt.mul(refPercentage).div(percentdiv);

        if (user.lastWith == 0){
            user.lastWith = block.timestamp;
            user.startDate = block.timestamp;

            if (ref == 0x000000000000000000000000000000000000dEaD || ref == address(0)){
                user2.refBonus += 0;
                BUSD.safeTransfer(dev, refAmtx);
            } else {
                user2.refBonus += refAmtx;
            }
         }else{
            BUSD.safeTransfer(dev, refAmtx);
        }

        if(main.users <= 1000){ //$5 bonus for first 1000 users
            adjustedAmt += 5 ether;
        }

        user.totalInits += adjustedAmt; 
        
        user.depoList.push(Depo({
            key: user.depoList.length,
            depoTime: block.timestamp,
            amt: adjustedAmt,
            reffy: ref,
            initialWithdrawn: false
        }));

        user.keyCounter += 1;
        main.ovrTotalDeps += 1;
        main.users += 1;
        distributeJackpot();
    }

    function userInfo() view external returns (Depo [] memory depoList){
        User storage user = UsersKey[msg.sender];
        return(
            user.depoList
        );
    }

    function withdrawDivs() public returns (uint256 withdrawAmount){
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];
        uint256 x = calcdiv(msg.sender);
      
      	for (uint i = 0; i < user.depoList.length; i++){
          if (user.depoList[i].initialWithdrawn == false) {
            user.depoList[i].depoTime = block.timestamp;
          }
        }

        main.ovrTotalWiths += x;
        user.lastWith = block.timestamp;
        BUSD.safeTransfer(msg.sender, x);

        distributeJackpot();

        return x;
    }

    function withdrawInitial(uint256 keyy) public {
      	  
      	User storage user = UsersKey[msg.sender];
				
      	require(user.depoList[keyy].initialWithdrawn == false, "This has already been withdrawn.");
      
        uint256 initialAmt = user.depoList[keyy].amt; 
        uint256 currDays1 = user.depoList[keyy].depoTime;
        uint256 currTime = block.timestamp;
        uint256 currDays = currTime - currDays1;
        uint256 transferAmt;
      	
        if (currDays < FeesKey[10].daysInSeconds){ // LESS THAN 10 DAYS STAKED
            uint256 minusAmt = initialAmt.mul(FeesKey[10].feePercentage).div(percentdiv); //10% fee
           	
          	uint256 dailyReturn = initialAmt.mul(PercsKey[10].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
          	
          	transferAmt = initialAmt + currentReturn - minusAmt;
          
            user.depoList[keyy].amt = 0;
            user.depoList[keyy].initialWithdrawn = true;
            user.depoList[keyy].depoTime = block.timestamp;

            BUSD.safeTransfer(msg.sender, transferAmt);
            
        } else if (currDays >= FeesKey[10].daysInSeconds && currDays < FeesKey[20].daysInSeconds){ // BETWEEN 20 and 30 DAYS
            uint256 minusAmt = initialAmt.mul(FeesKey[20].feePercentage).div(percentdiv); //8% fee
						
          	uint256 dailyReturn = initialAmt.mul(PercsKey[10].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
						transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[keyy].amt = 0;
            user.depoList[keyy].initialWithdrawn = true;
            user.depoList[keyy].depoTime = block.timestamp;

            BUSD.safeTransfer(msg.sender, transferAmt);
       
        } else if (currDays >= FeesKey[20].daysInSeconds && currDays < FeesKey[30].daysInSeconds){ // BETWEEN 30 and 40 DAYS
            uint256 minusAmt = initialAmt.mul(FeesKey[30].feePercentage).div(percentdiv); //5% fee
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[20].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
						transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[keyy].amt = 0;
            user.depoList[keyy].initialWithdrawn = true;
            user.depoList[keyy].depoTime = block.timestamp;

            BUSD.safeTransfer(msg.sender, transferAmt);
     
        } else if (currDays >= FeesKey[30].daysInSeconds && currDays < FeesKey[40].daysInSeconds){ // BETWEEN 30 and 40 DAYS
            uint256 minusAmt = initialAmt.mul(FeesKey[40].feePercentage).div(percentdiv); //5% fee
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[30].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
						transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[keyy].amt = 0;
            user.depoList[keyy].initialWithdrawn = true;
            user.depoList[keyy].depoTime = block.timestamp;

            BUSD.safeTransfer(msg.sender, transferAmt);
          
        } else if (currDays >= FeesKey[40].daysInSeconds && currDays < FeesKey[50].daysInSeconds){ // BETWEEN 30 and 40 DAYS
            uint256 minusAmt = initialAmt.mul(FeesKey[40].feePercentage).div(percentdiv); //2% fee
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[40].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
						transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[keyy].amt = 0;
            user.depoList[keyy].initialWithdrawn = true;
            user.depoList[keyy].depoTime = block.timestamp;

            BUSD.safeTransfer(msg.sender, transferAmt);
   
        } else if (currDays >= FeesKey[50].daysInSeconds){ // 40+ DAYS
            uint256 minusAmt = initialAmt.mul(FeesKey[40].feePercentage).div(percentdiv); //2% fee
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[50].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
						transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[keyy].amt = 0;
            user.depoList[keyy].initialWithdrawn = true;
            user.depoList[keyy].depoTime = block.timestamp;
            
            BUSD.safeTransfer(msg.sender, transferAmt);
     
        } else {
            revert("Could not calculate the # of days youv've been staked.");
        }
        distributeJackpot();
    }

    function withdrawRefBonus() public {
        User storage user = UsersKey[msg.sender];
        uint256 amtz = user.refBonus;
        user.refBonus = 0;

        BUSD.safeTransfer(msg.sender, amtz);
    }

    function stakeRefBonus() public { 
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];
        require(user.refBonus > 10);
      	uint256 refferalAmount = user.refBonus;
        user.refBonus = 0;
        address ref = 0x000000000000000000000000000000000000dEaD; //DEAD ADDRESS
				
        user.depoList.push(Depo({
            key: user.keyCounter,
            depoTime: block.timestamp,
            amt: refferalAmount,
            reffy: ref, 
            initialWithdrawn: false
        }));

        user.keyCounter += 1;
        main.ovrTotalDeps += 1;
    }

    function calcdiv(address dy) public view returns (uint256 totalWithdrawable){
        User storage user = UsersKey[dy];	

        uint256 with;
        
        for (uint256 i = 0; i < user.depoList.length; i++){	
            uint256 elapsedTime = block.timestamp.sub(user.depoList[i].depoTime);

            uint256 amount = user.depoList[i].amt;
            if (user.depoList[i].initialWithdrawn == false){
                if (elapsedTime <= PercsKey[20].daysInSeconds){ 
                    uint256 dailyReturn = amount.mul(PercsKey[10].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(PercsKey[10].daysInSeconds / 10);
                    with += currentReturn;
                }
                if (elapsedTime > PercsKey[20].daysInSeconds && elapsedTime <= PercsKey[30].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[20].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(PercsKey[10].daysInSeconds / 10);
                    with += currentReturn;
                }
                if (elapsedTime > PercsKey[30].daysInSeconds && elapsedTime <= PercsKey[40].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[30].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(PercsKey[10].daysInSeconds / 10);
                    with += currentReturn;
                }
                if (elapsedTime > PercsKey[40].daysInSeconds && elapsedTime <= PercsKey[50].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[40].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(PercsKey[10].daysInSeconds / 10);
                    with += currentReturn;
                }
                if (elapsedTime > PercsKey[50].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[50].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(PercsKey[10].daysInSeconds / 10);
                    with += currentReturn;
                }
                
            } 
        }
        return with;
    }

    function compound() public {
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];

        uint256 y = calcdiv(msg.sender);

        for (uint i = 0; i < user.depoList.length; i++){
            if (user.depoList[i].initialWithdrawn == false) {
            user.depoList[i].depoTime = block.timestamp;
            }
        }

        user.depoList.push(Depo({
                key: user.keyCounter,
                depoTime: block.timestamp,
                amt: y,
                reffy: 0x000000000000000000000000000000000000dEaD, 
                initialWithdrawn: false
            }));

        user.keyCounter += 1;
        main.ovrTotalDeps += 1;
        main.compounds += 1;
        user.lastWith = block.timestamp;

        distributeJackpot();
    }

    //Testing functions
    function setJackpotTime() public {
        jackpot.drawTime = block.timestamp - 2 days;
    }

    function setLastWithdrawTime(uint256 _timestamp) public {
        User storage user = UsersKey[msg.sender];
      
      	for (uint i = 0; i < user.depoList.length; i++){
          if (user.depoList[i].initialWithdrawn == false) {
            user.depoList[i].depoTime = _timestamp;
          }
        }

        user.lastWith = _timestamp;
    }
}