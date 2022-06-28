/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

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
}
struct DivPercs{
    uint256 daysInSeconds; // updated to be in seconds
    uint256 divsPercentage;
}
struct FeesPercs{
    uint256 daysInSeconds;
    uint256 feePercentage;
}
contract WealthMountain {
    using SafeMath for uint256;
    uint256 constant launch = 1849839043;
    uint256 constant percentdiv = 1000;
    uint256 refPercentage = 50;
    uint256 devPercentage = 50;
    // address public owner;
    mapping (address => mapping(uint256 => Depo)) public DeposMap;
    mapping (address => User) public UsersKey;
    mapping (uint256 => DivPercs) public PercsKey;
    mapping (uint256 => FeesPercs) public FeesKey;
    mapping (uint256 => Main) public MainKey;
    IERC20 public BUSD;
    address public owner;
    //ui stats?
    //things to display
    constructor() {
            owner = msg.sender;
            // PercsKey[10] = DivPercs(864000, 10);
            // PercsKey[20] = DivPercs(1728000, 20);
            // PercsKey[30] = DivPercs(2592000, 30);
            // PercsKey[40] = DivPercs(3456000, 40);
            // PercsKey[50] = DivPercs(4320000, 50);
            // FeesKey[10] = FeesPercs(864000, 100);
            // FeesKey[20] = FeesPercs(1728000, 80);
            // FeesKey[30] = FeesPercs(3456000, 50);
            // FeesKey[40] = FeesPercs(4320000, 20);
            PercsKey[10] = DivPercs(30, 10);
            PercsKey[20] = DivPercs(60, 20);
            PercsKey[30] = DivPercs(90, 30);
            PercsKey[40] = DivPercs(120, 40);
            PercsKey[50] = DivPercs(150, 50);
            FeesKey[10] = FeesPercs(30, 100);
            FeesKey[20] = FeesPercs(60, 80);
            FeesKey[30] = FeesPercs(90, 50);
            FeesKey[40] = FeesPercs(120, 20);
            // BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

            // uint256 divPerc = 10;
            // for (uint256 daysB = 10; daysB <= 50; daysB + 10){
            //     PercsKey[daysB] = DivPercs(daysB, divPerc);
            //     divPerc += 10;
            // }
            // uint256 feePerc = 10;
            // for(uint256 daysC = 10; daysC <= 30; daysC + 10){
            //     FeesKey[daysC] = FeesPercs(daysC, feePerc);
            //     feePerc = feePerc.div(2);
            // }
            // should we get rid of feePerc if we're taking the hardcoded route for withdrawInitial?
    }
    function dep(uint256 amtx, address ref) payable public {
        require (msg.value == amtx, "did you add value in ether"); // just to serve as a reminder for testing - remove later

        // BUSD.safeTransferFrom(msg.sender, address(this), amtx);
        User storage user = UsersKey[msg.sender];
        User storage user2 = UsersKey[ref];
        Main storage main = MainKey[1];
        if (user.lastWith == 0){
            user.lastWith = block.timestamp;
            user.startDate = block.timestamp;
        }
        uint256 adjustedAmt = amtx.mul(900).div(percentdiv); //adjust their stake to be 90% - applies to all stakes all the time
        uint256 stakeFee = amtx.mul(100).div(percentdiv); // stakeFee is 10% of their stake
        
        user.totalInits += adjustedAmt; //total initial deposits + the users stake
        uint256 refAmtx = adjustedAmt.mul(50).div(percentdiv); //referral amount is 5% of adjusted stake
    
        user2.refBonus += refAmtx;
        user.refBonus += refAmtx;

        user.depoList.push(Depo({
            key: user.depoList.length,
            depoTime: block.timestamp,
            amt: adjustedAmt,
            reffy: ref,
            initialWithdrawn: false
        }));

        // DeposMap[msg.sender][user.keyCounter].depoTime = block.timestamp;
        // DeposMap[msg.sender][user.keyCounter].amt = adjustedAmt; // updated the amt to be adjusted for stakeFee (flat 10%)
        // DeposMap[msg.sender][user.keyCounter].reffy = ref;
        // DeposMap[msg.sender][user.keyCounter].initialWithdrawn = false;

        user.keyCounter += 1;
        main.ovrTotalDeps += 1;
        main.users += 1;
        
        payable(owner).transfer(stakeFee); //pay someone the stakeFee
        // BUSD.safeTransfer(owner, stakeFee);
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
      
      	for (uint i = 0; i < user.depoList.length - 1; i++){
          if (user.depoList[i].initialWithdrawn == false) {
            user.depoList[i].depoTime = block.timestamp;
          }
        }
        // uint256 x = 5;
        main.ovrTotalWiths += x;
        user.lastWith = block.timestamp;
        payable(msg.sender).transfer(x);
        return x;
    }

    function withdrawInitial(uint256 keyy) public {
        User storage user = UsersKey[msg.sender];

        uint256 initialAmt = user.depoList[keyy].amt; // works
        uint256 currDays1 = user.depoList[keyy].depoTime; // works
        uint256 currTime = block.timestamp; // works
        uint256 currDays = currTime - currDays1;
        uint256 transferAmt;
        
        // for (uint256 z = 10; z <= 30; z + 10){
        //     if (currDays <= FeesKey[z].amtxdays * 86400){
        //         uint256 minusAmt = initialAmt.mul(FeesKey[z].amtxfees).div(percentdiv);
        //         transferAmt = initialAmt - minusAmt;
        //     }
        // }
        // Is this being used to calculate the fee they had taken out during their deposit? 
        // Why not just adjust `initialAmt` on deposit? 
        // Can we get rid of this?
        
        
        if (currDays <= FeesKey[10].daysInSeconds){ // LESS THAN 20 DAYS STAKED
            uint256 minusAmt = initialAmt.mul(FeesKey[10].feePercentage).div(percentdiv); //10% fee
            transferAmt = initialAmt - minusAmt;
            require(transferAmt > 0, "transferring nothing");

            user.depoList[keyy].amt = 0;
            user.depoList[keyy].initialWithdrawn = true;
            user.depoList[keyy].depoTime = block.timestamp;

            // withdrawDivs();
            payable(msg.sender).transfer(transferAmt);
            payable(owner).transfer(minusAmt); // amtx in deposits needs to be in Wei for this to work


        } else if (currDays >= FeesKey[10].daysInSeconds && currDays <= FeesKey[20].daysInSeconds){ // BETWEEN 20 and 30 DAYS
            uint256 minusAmt = initialAmt.mul(FeesKey[20].feePercentage).div(percentdiv); //8% fee
            transferAmt = initialAmt - minusAmt;

            user.depoList[keyy].amt = 0;
            user.depoList[keyy].initialWithdrawn = true;
            user.depoList[keyy].depoTime = block.timestamp;
            // withdrawDivs();
            payable(msg.sender).transfer(transferAmt);
            payable(owner).transfer(minusAmt); // amtx in deposits needs to be in Wei for this to work


        } else if (currDays >= FeesKey[20].daysInSeconds && currDays <= FeesKey[30].daysInSeconds){ // BETWEEN 30 and 40 DAYS
            uint256 minusAmt = initialAmt.mul(FeesKey[20].feePercentage).div(percentdiv); //5% fee
            transferAmt = initialAmt - minusAmt;

            user.depoList[keyy].amt = 0;
            user.depoList[keyy].initialWithdrawn = true;
            user.depoList[keyy].depoTime = block.timestamp;
            // withdrawDivs();
            payable(msg.sender).transfer(transferAmt);
            payable(owner).transfer(minusAmt); // amtx in deposits needs to be in Wei for this to work


        } else if (currDays >= FeesKey[40].daysInSeconds){ // 40+ DAYS
            uint256 minusAmt = initialAmt.mul(FeesKey[40].feePercentage).div(percentdiv); //2% fee
            transferAmt = initialAmt - minusAmt;

            user.depoList[keyy].amt = 0;
            user.depoList[keyy].initialWithdrawn = true;
            user.depoList[keyy].depoTime = block.timestamp;
            // withdrawDivs();
            payable(msg.sender).transfer(transferAmt);
            payable(owner).transfer(minusAmt); // amtx in deposits needs to be in Wei for this to work

        } else {
            revert("Could not calculate the # of days youv've been staked.");
        }
        
    }
    function withdrawRefBonus() public {
        User storage user = UsersKey[msg.sender];
        uint256 amtz = user.refBonus;
        user.refBonus = 0;
        payable(msg.sender).transfer(amtz);
    }

    function stakeRefBonus() public { 
        // Users can stake their referral rewards as opposed to depositing them?
        // We can then advertise it as a 0 fee option
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

        // DeposMap[msg.sender][user.keyCounter].depoTime = block.timestamp;
        // DeposMap[msg.sender][user.keyCounter].amt = refferalAmount; // updated the amt to be adjusted for stakeFee (flat 10%)
        // DeposMap[msg.sender][user.keyCounter].reffy = msg.sender;
        // DeposMap[msg.sender][user.keyCounter].initialWithdrawn = false;

        user.keyCounter += 1;
        main.ovrTotalDeps += 1;
    }

    function calcdiv(address dy) public view returns (uint256 totalWithdrawable){	// right here baby 
        User storage user = UsersKey[dy];	

        uint256 with;
        
        for (uint256 i = 0; i <= user.depoList.length - 1; i++){	
            uint256 elapsedTime = block.timestamp.sub(user.depoList[i].depoTime);
            // uint256 timeToDays = elapsedTime.div(86400);
            uint256 timeToDays = elapsedTime.div(1);
            uint256 amount = user.depoList[i].amt;
            if (user.depoList[i].initialWithdrawn == false){
                if (elapsedTime <= PercsKey[20].daysInSeconds){ //replace with FeesPercs[10].amt
                    uint256 returnAmt = amount.mul(PercsKey[10].divsPercentage).mul(timeToDays).div(percentdiv);
                    with += returnAmt;
                }
                if (elapsedTime > PercsKey[20].daysInSeconds && elapsedTime <= PercsKey[30].daysInSeconds){
                    uint256 returnAmt = amount.mul(PercsKey[20].divsPercentage).mul(timeToDays).div(percentdiv);
                    with += returnAmt;
                }
                if (elapsedTime > PercsKey[30].daysInSeconds && elapsedTime <= PercsKey[40].daysInSeconds){
                    uint256 returnAmt = amount.mul(PercsKey[30].divsPercentage).mul(timeToDays).div(percentdiv);
                    with += returnAmt;
                }
                if (elapsedTime > PercsKey[40].daysInSeconds && elapsedTime <= PercsKey[50].daysInSeconds){
                    uint256 returnAmt = amount.mul(PercsKey[40].divsPercentage).mul(timeToDays).div(percentdiv);
                    with += returnAmt;
                }
                if (elapsedTime > PercsKey[50].daysInSeconds){
                    uint256 returnAmt = amount.mul(PercsKey[50].divsPercentage).mul(timeToDays).div(percentdiv);
                    with += returnAmt;
                }
                
            } 
        }
        return with;
            // amount += user.depoList[i].amt;
            // if (user.depoList[i].initialWithdrawn == false && elapsedTime <= 864000){
                
                // if (elapsedTime <= 864000){
                    // total += user.depoList[i].amt.mul(10).mul(elapsedTime).div(86400).div(percentdiv);
                    // return user.depoList[i].amt;
                    // total += user.depoList[i].amt;
                // } else {
                //     return 1337;
                // }
                
                
            
            


            // if (DeposMap[msg.sender][i].initialWithdrawn == false){	
            //     require(DeposMap[msg.sender][i].depoTime > 0, "depoTime is 0");
            //     elapsedTime = DeposMap[msg.sender][i].depoTime;
                // divDays = elapsedTime.div(86400);

                // 
            // }	
        // }	
    }


    function bonustime (uint256 dayss, uint256 percentage) public{
        require (msg.sender == owner); // owner has the option to increase or decrease dividends by 1% across the board
        require (dayss <= 50);
        require (percentage <= 60);
        require (percentage >= 10);
        if (dayss == 10){
            require(percentage >= 10);
            require(percentage <= 20);
        } else if (dayss == 20){
            require(percentage >= 20);
            require(percentage <= 30);
        } else if (dayss == 30){
            require(percentage >= 30);
            require(percentage <= 40);
        }else if (dayss == 40){
            require(percentage >= 40);
            require(percentage <= 50);
        }else if (dayss == 50){
            require(percentage >= 50);
            require(percentage <= 60);
        }
        PercsKey[dayss] = DivPercs(dayss, percentage);
    }
  
  
  	function compound() public {
      User storage user = UsersKey[msg.sender];
      Main storage main = MainKey[1];
      
      uint256 y = calcdiv(msg.sender);
      
      for (uint i = 0; i < user.depoList.length - 1; i++){
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
      user.lastWith = block.timestamp;  
    }
}

    // //change divPerentages
    // }
    //deposit fee/sus fee
    //wdfee/susfee
    // function doSomething(uint256 bricks, uint256 ladder, heightList[])
    //     for (uint256 i = 0, i < heightList.length, i++){
    //         if heightList[i] < heightList[i+1]
    //     }
       //
            // struct DivPercs[10]{
            //     uint256 10;
            //     uint256 10;
            // }
            // struct DivPercs[20]{
            //     uint256 20;
            //     uint256 2
            // }
            //struct DivPercs[30]{
            //     uint256 30;
            //     uint256 3;
            // }
            // struct FeesPercs{
            //     uint256 amtxdays;
            //     uint256 amtxfees;
            // }