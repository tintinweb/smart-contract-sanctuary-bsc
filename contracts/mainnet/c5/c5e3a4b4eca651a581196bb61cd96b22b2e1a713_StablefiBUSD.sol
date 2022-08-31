/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

// SPDX-License-Identifier: UNLICENSED


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
    uint256 dividendsWithdrawn;
}
struct Main {
    uint256 ovrTotalDeps;
    uint256 ovrTotalWiths;
    uint256 users;
    uint256 compounds;
}
struct DivPercs{
    uint256 daysInSeconds;
    uint256 divsPercentage;
}
struct FeesPercs{
    uint256 daysInSeconds;
    uint256 feePercentage;
}
contract StablefiBUSD {
    using SafeMath for uint256;
    uint256 constant launch = 1662120000; //Fri Sep 02 2022 12:00:00 GMT+0000
    uint256 constant hardDays = 86400;
    uint256 constant percentdiv = 1000;
    uint256 constant min_invest = 30 ether;
    uint256 bonusPercent = 20;
    uint256 refPercentage = 30;
    uint256 devPercentage = 100;
    uint256 public constant MAXIMUM_NUMBER_DEPOSITS = 200;

    
    mapping (address => mapping(uint256 => Depo)) public DeposMap;
    mapping (address => User) public UsersKey;
    mapping (uint256 => DivPercs) public PercsKey;
    mapping (uint256 => FeesPercs) public FeesKey;
    mapping (uint256 => Main) public MainKey;

    event Newbie(address user);
	event NewDeposit(address indexed user, uint256 amount, uint256 time);
    event Reinvest(address indexed user, uint256 amount, uint256 time);
    event DepositRef(address indexed user, uint256 amount, uint256 time);
	event WithdrawCapital(address indexed user, uint256 amount, uint256 time);
    event WithdrawDividend(address indexed user, uint256 amount, uint256 time);
    event WithdrawRef(address indexed user, uint256 amount, uint256 time);
	event RefBonus(address indexed referrer, address indexed referral, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

    using SafeERC20 for IERC20;
    IERC20 public BUSD;
    address public owner;

    constructor() {
            owner = msg.sender;
            PercsKey[0] = DivPercs(0, 10);
            PercsKey[1] = DivPercs(20 days, 20);
            PercsKey[2] = DivPercs(30 days, 30);
            PercsKey[3] = DivPercs(40 days, 40);
            PercsKey[4] = DivPercs(50 days, 30);
            
            FeesKey[0] = FeesPercs(0, 50);
            FeesKey[1] = FeesPercs(20 days, 100);
            FeesKey[2] = FeesPercs(30 days, 150);
            FeesKey[3] = FeesPercs(40 days, 200);
            FeesKey[4] = FeesPercs(50 days, 250);

            BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); 
    }
    function stakeStablecoins(uint256 amtx, address ref) public {
        require(block.timestamp >= launch, "App did not launch yet.");
        require(ref != msg.sender, "You cannot refer yourself!");
        require(amtx >= min_invest, "less than min amount");
        BUSD.safeTransferFrom(msg.sender, address(this), amtx);
        User storage user = UsersKey[msg.sender];
        require(user.depoList.length < MAXIMUM_NUMBER_DEPOSITS, "Maximum number of deposits reached.");

        User storage user2 = UsersKey[ref];
        Main storage main = MainKey[1];
        if (user.lastWith == 0){
            user.lastWith = block.timestamp;
            user.startDate = block.timestamp;
        }
        uint256 userStakePercentAdjustment = 1000 - devPercentage;
        uint256 adjustedAmt = amtx.mul(userStakePercentAdjustment).div(percentdiv); 
        uint256 stakeFee = amtx.mul(devPercentage).div(percentdiv); 
        
        user.totalInits += adjustedAmt; 
        uint256 refAmtx = adjustedAmt.mul(refPercentage).div(percentdiv);
        if (ref == 0x000000000000000000000000000000000000dEaD){
            user2.refBonus += 0;
        } else {
            user2.refBonus += refAmtx;
            emit RefBonus(ref, msg.sender, refAmtx);
        }

        user.depoList.push(Depo({
            key: user.depoList.length,
            depoTime: block.timestamp,
            amt: adjustedAmt,
            reffy: ref,
            initialWithdrawn: false,
            dividendsWithdrawn: 0
        }));

        if (user.depoList.length == 0) {
			main.users += 1;
			emit Newbie(msg.sender);
		}

        user.keyCounter += 1;
        main.ovrTotalDeps += 1;
        
        BUSD.safeTransfer(owner, stakeFee);
        emit FeePayed(msg.sender, stakeFee);
        emit NewDeposit(msg.sender, adjustedAmt, block.timestamp);
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
        uint256 x = _calcdiv(msg.sender);
      
      	for (uint i = 0; i < user.depoList.length; i++){
          if (user.depoList[i].initialWithdrawn == false) {
            user.depoList[i].depoTime = block.timestamp;
          }
        }

        main.ovrTotalWiths += x;
        user.lastWith = block.timestamp;
        BUSD.safeTransfer(msg.sender, x);
        emit WithdrawDividend(msg.sender, x, block.timestamp);
        return x;
    }

    function withdrawInitial(uint256 keyy) public {
      	  
      	User storage user = UsersKey[msg.sender];
				
      	require(user.depoList[keyy].initialWithdrawn == false, "This has already been withdrawn.");
      
        uint256 initialAmt = user.depoList[keyy].amt; 
        uint256 currDays = block.timestamp - user.depoList[keyy].depoTime;
        uint256 transferAmt;
        uint256 currentFeePercent;

        if (currDays > FeesKey[0].daysInSeconds && currDays <= FeesKey[1].daysInSeconds){ // LESS THAN 20 DAYS STAKED
            currentFeePercent = FeesKey[0].feePercentage;

        } else if (currDays > FeesKey[1].daysInSeconds && currDays <= FeesKey[2].daysInSeconds){ // BETWEEN 20 and 30 DAYS
            currentFeePercent = FeesKey[1].feePercentage;

        } else if (currDays > FeesKey[2].daysInSeconds && currDays <= FeesKey[3].daysInSeconds){ // BETWEEN 30 and 40 DAYS
            currentFeePercent = FeesKey[2].feePercentage;

        } else if (currDays > FeesKey[3].daysInSeconds && currDays <= FeesKey[4].daysInSeconds){ // BETWEEN 40 and 50 DAYS
            currentFeePercent = FeesKey[3].feePercentage;

        } else if (currDays > FeesKey[4].daysInSeconds){ // GREATER THAN 50 DAYS
            currentFeePercent = FeesKey[4].feePercentage;

        } else {
            revert("Could not calculate the # of days youv've been staked.");
        }

        uint256 minusAmt = initialAmt.mul(currentFeePercent).div(percentdiv);
        require(initialAmt > (user.depoList[keyy].dividendsWithdrawn.add(minusAmt)), "your withdrawn dividends are more than your initial investment");
        transferAmt = initialAmt - user.depoList[keyy].dividendsWithdrawn - minusAmt;
        
        user.depoList[keyy].amt = 0;
        user.depoList[keyy].initialWithdrawn = true;
        user.depoList[keyy].depoTime = block.timestamp;

        BUSD.safeTransfer(msg.sender, transferAmt);
        BUSD.safeTransfer(owner, minusAmt);

        emit FeePayed(msg.sender, minusAmt);
        emit WithdrawCapital(msg.sender, transferAmt, block.timestamp);
        
    }
    function withdrawRefBonus() public {
        User storage user = UsersKey[msg.sender];
        uint256 amtz = user.refBonus;
        user.refBonus = 0;

        BUSD.safeTransfer(msg.sender, amtz);
        emit WithdrawRef(msg.sender, amtz, block.timestamp);
    }

    function stakeRefBonus() public { 
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];
        require(user.depoList.length < MAXIMUM_NUMBER_DEPOSITS, "Maximum number of deposits reached.");
      	uint256 refferalAmount = user.refBonus;
        user.refBonus = 0;
        address ref = 0x000000000000000000000000000000000000dEaD; //DEAD ADDRESS
				
        user.depoList.push(Depo({
            key: user.keyCounter,
            depoTime: block.timestamp,
            amt: refferalAmount,
            reffy: ref, 
            initialWithdrawn: false,
            dividendsWithdrawn: 0
        }));

        user.keyCounter += 1;
        main.ovrTotalDeps += 1;

        emit DepositRef(msg.sender, refferalAmount, block.timestamp);
    }

    function _calcdiv(address dy) internal returns (uint256 totalWithdrawable){
        User storage user = UsersKey[dy];	

        uint256 with;
        
        for (uint256 i = 0; i < capped(user.depoList.length); i++){	
            uint256 elapsedTime = block.timestamp.sub(user.depoList[i].depoTime);

            uint256 amount = user.depoList[i].amt;
            if (user.depoList[i].initialWithdrawn == false){
                if (elapsedTime > PercsKey[0].daysInSeconds && elapsedTime <= PercsKey[1].daysInSeconds){ 
                    uint256 dailyReturn = amount.mul(PercsKey[0].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(hardDays);
                    user.depoList[i].dividendsWithdrawn = user.depoList[i].dividendsWithdrawn.add(currentReturn);
                    with += currentReturn;
                } else if (elapsedTime > PercsKey[1].daysInSeconds && elapsedTime <= PercsKey[2].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[1].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(hardDays);
                    user.depoList[i].dividendsWithdrawn = user.depoList[i].dividendsWithdrawn.add(currentReturn);
                    with += currentReturn;
                } else if (elapsedTime > PercsKey[2].daysInSeconds && elapsedTime <= PercsKey[3].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[2].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(hardDays);
                    user.depoList[i].dividendsWithdrawn = user.depoList[i].dividendsWithdrawn.add(currentReturn);
                    with += currentReturn;
                } else if (elapsedTime > PercsKey[3].daysInSeconds && elapsedTime <= PercsKey[4].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[3].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(hardDays);
                    user.depoList[i].dividendsWithdrawn = user.depoList[i].dividendsWithdrawn.add(currentReturn);
                    with += currentReturn;
                } else if (elapsedTime > PercsKey[4].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[4].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(hardDays);
                    user.depoList[i].dividendsWithdrawn = user.depoList[i].dividendsWithdrawn.add(currentReturn);
                    with += currentReturn;
                }
                
            } 
        }
        return with;
    }

    function calcdiv(address dy) public view returns (uint256 totalWithdrawable){
        User storage user = UsersKey[dy];	

        uint256 with;
        
        for (uint256 i = 0; i < capped(user.depoList.length); i++){	
            uint256 elapsedTime = block.timestamp.sub(user.depoList[i].depoTime);

            uint256 amount = user.depoList[i].amt;
            if (user.depoList[i].initialWithdrawn == false){
                if (elapsedTime > PercsKey[0].daysInSeconds && elapsedTime <= PercsKey[1].daysInSeconds){ 
                    uint256 dailyReturn = amount.mul(PercsKey[0].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(hardDays);
                    with += currentReturn;
                } else if (elapsedTime > PercsKey[1].daysInSeconds && elapsedTime <= PercsKey[2].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[1].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(hardDays);
                    with += currentReturn;
                } else if (elapsedTime > PercsKey[2].daysInSeconds && elapsedTime <= PercsKey[3].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[2].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(hardDays);
                    with += currentReturn;
                } else if (elapsedTime > PercsKey[3].daysInSeconds && elapsedTime <= PercsKey[4].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[3].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(hardDays);
                    with += currentReturn;
                } else if (elapsedTime > PercsKey[4].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[4].divsPercentage).div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(hardDays);
                    with += currentReturn;
                }
                
            } 
        }
        return with;
    }

    function capped(uint256 length) public pure returns (uint256 cap) {
        if (length < MAXIMUM_NUMBER_DEPOSITS) {
            cap = length;
        } else {
            cap = MAXIMUM_NUMBER_DEPOSITS;
        }
    }
      
    function compound() public {
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];
        require(user.depoList.length < MAXIMUM_NUMBER_DEPOSITS, "Maximum number of deposits reached.");

        uint256 y = _calcdiv(msg.sender);

        for (uint i = 0; i < user.depoList.length; i++){
          if (user.depoList[i].initialWithdrawn == false) {
            user.depoList[i].depoTime = block.timestamp;
          }
        }
        uint256 Compoundbonus = y.mul(bonusPercent).div(percentdiv);
        uint256 finalCompoundAmount = y.add(Compoundbonus);

        user.depoList.push(Depo({
              key: user.keyCounter,
              depoTime: block.timestamp,
              amt: finalCompoundAmount,
              reffy: 0x000000000000000000000000000000000000dEaD, 
              initialWithdrawn: false,
              dividendsWithdrawn: 0
        }));

        user.keyCounter += 1;
        main.ovrTotalDeps += 1;
        main.compounds += 1;
        user.lastWith = block.timestamp;  
        emit Reinvest(msg.sender, finalCompoundAmount, block.timestamp);
      }

      function getContractBalance() public view returns (uint256) {
		return BUSD.balanceOf(address(this));
	}
}