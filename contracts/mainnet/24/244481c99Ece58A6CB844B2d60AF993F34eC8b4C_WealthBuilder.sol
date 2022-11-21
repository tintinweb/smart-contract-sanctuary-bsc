/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

/**
*
*
*
*    ___       __   _______   ________  ___   _________  ___  ___                 ________  ___  ___  ___  ___       ________  _______   ________     
*   |\  \     |\  \|\  ___ \ |\   __  \|\  \ |\___   ___\\  \|\  \               |\   __  \|\  \|\  \|\  \|\  \     |\   ___ \|\  ___ \ |\   __  \    
*   \ \  \    \ \  \ \   __/|\ \  \|\  \ \  \\|___ \  \_\ \  \\\  \  ____________\ \  \|\ /\ \  \\\  \ \  \ \  \    \ \  \_|\ \ \   __/|\ \  \|\  \   
*    \ \  \  __\ \  \ \  \_|/_\ \   __  \ \  \    \ \  \ \ \   __  \|\____________\ \   __  \ \  \\\  \ \  \ \  \    \ \  \ \\ \ \  \_|/_\ \   _  _\  
*     \ \  \|\__\_\  \ \  \_|\ \ \  \ \  \ \  \____\ \  \ \ \  \ \  \|____________|\ \  \|\  \ \  \\\  \ \  \ \  \____\ \  \_\\ \ \  \_|\ \ \  \\  \| 
*      \ \____________\ \_______\ \__\ \__\ \_______\ \__\ \ \__\ \__\              \ \_______\ \_______\ \__\ \_______\ \_______\ \_______\ \__\\ _\ 
*       \|____________|\|_______|\|__|\|__|\|_______|\|__|  \|__|\|__|               \|_______|\|_______|\|__|\|_______|\|_______|\|_______|\|__|\|__|
*                                                                                                                                                     
*                                                                                                                                            
*
*                                                                     
*/

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
    address referrer;
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
    uint256 feePercentage;
}

contract WealthBuilder {
    using SafeMath for uint256;
    bool public launch;
  	uint256 constant hardDays = 86400;
    uint256 constant minStakeAmt = 50 * 10**18;
    uint256 constant percentdiv = 1000;
    uint256 refPercentage = 100;
    uint256 devPercentage = 100;
    mapping (address => mapping(uint256 => Depo)) public DeposMap;
    mapping (address => User) public UsersKey;
    mapping (uint256 => DivPercs) public PercsKey;
    mapping (uint256 => Main) public MainKey;
    uint256[] public REFERRAL_PERCENTS = [50, 20, 10, 10, 10]; 
    using SafeERC20 for IERC20;
    IERC20 public BUSD;
    address public owner;
    address public owner2;
    address public dev;

    fallback() external {}

    receive() external payable {}

    constructor() {
            owner = address(0x2547c7da46017b7caa3386ffeF04F62Bb4b4e73b);
            owner2 = address(0xA3D149f796850468206bC211152d80E53f17e5C6);
            dev = address(0x7419189d0f5B11A1303978077Ce6C8096d899dAd);
            PercsKey[30] = DivPercs(30 days, 5, 200);
            PercsKey[60] = DivPercs(60 days, 6, 180);
            PercsKey[90] = DivPercs(90 days, 7, 150);
            PercsKey[120] = DivPercs(120 days, 8, 120);
            PercsKey[150] = DivPercs(150 days, 9, 120);
            PercsKey[250] = DivPercs(250 days, 10, 120);

            BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    }

    function fundContract(uint256 _amount) external {
        BUSD.safeTransferFrom(msg.sender, address(this), _amount);
    }

    function setLaunch() external {
        require(msg.sender == owner, "only owner can launch");
        if (launch == false) {
            launch = true;
        }
    }

    function stakeStablecoins(uint256 amtx, address ref) external {
        require(launch == true, "App did not launch yet.");
        require(ref != msg.sender, "You cannot refer yourself!");
        require(amtx >= minStakeAmt, "You should stake at least 50.");
        BUSD.safeTransferFrom(msg.sender, address(this), amtx);
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];
        if (user.lastWith == 0){
            user.lastWith = block.timestamp;
            user.startDate = block.timestamp;
        }
        uint256 userStakePercentAdjustment = 1000 - devPercentage;
        uint256 adjustedAmt = amtx.mul(userStakePercentAdjustment).div(percentdiv); 
        uint256 stakeFee = amtx.mul(devPercentage).div(percentdiv); 
        
        user.totalInits += adjustedAmt; 
        if (ref != address(0)) {
            user.referrer = ref;
            address upline = ref;
            for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
                if (upline != address(0)) {
                    uint256 refAmount = amtx  * REFERRAL_PERCENTS[i] / percentdiv;
                    UsersKey[upline].refBonus += refAmount;
                    upline = UsersKey[upline].referrer;
                } else {
                    break;
                }
            }
        }

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
        
        BUSD.safeTransfer(owner, stakeFee * 4/10);
        BUSD.safeTransfer(owner2, stakeFee * 4/10);
        BUSD.safeTransfer(dev, stakeFee * 2/10);
    }

    function userInfo() view external returns (Depo [] memory depoList) {
        User storage user = UsersKey[msg.sender];
        return(
            user.depoList
        );
    }

    function withdrawDivs() external returns (uint256 withdrawAmount) {
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];
        uint256 x = calcdiv(msg.sender);
      
      	for (uint i = 0; i < user.depoList.length; i++){
          if (user.depoList[i].initialWithdrawn == false) {
            user.depoList[i].depoTime = block.timestamp;
          }
        }

        uint256 adjustedPercent = 1000 - devPercentage;
        uint256 adjustedAmt = x.mul(adjustedPercent).div(percentdiv); 
        uint256 withdrawFee = x.mul(devPercentage).div(percentdiv);

        main.ovrTotalWiths += x;
        user.lastWith = block.timestamp;

        BUSD.safeTransfer(owner, withdrawFee * 4/10);
        BUSD.safeTransfer(owner2, withdrawFee * 4/10);
        BUSD.safeTransfer(dev, withdrawFee * 2/10);
        BUSD.safeTransfer(msg.sender, adjustedAmt);

        return x;
    }

    function withdrawInitial(uint256 _key) external {
      	  
      	User storage user = UsersKey[msg.sender];
				
      	require(user.depoList[_key].initialWithdrawn == false, "This has already been withdrawn.");
      
        uint256 initialAmt = user.depoList[_key].amt; 
        uint256 elapsedTime = min(block.timestamp.sub(user.depoList[_key].depoTime), 250 days);
        uint256 transferAmt;
      	
        if (elapsedTime < PercsKey[30].daysInSeconds){ // LESS THAN 30 DAYS STAKED
            uint256 minusAmt = initialAmt.mul(PercsKey[30].feePercentage).div(percentdiv); //20% fee
           	
          	uint256 dailyReturn = initialAmt.mul(PercsKey[30].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(elapsedTime).div(hardDays);
          	
          	transferAmt = initialAmt + currentReturn - minusAmt;
          
            user.depoList[_key].amt = 0;
            user.depoList[_key].initialWithdrawn = true;
            user.depoList[_key].depoTime = block.timestamp;

            BUSD.safeTransfer(msg.sender, transferAmt);
        } else if (elapsedTime >= PercsKey[30].daysInSeconds && elapsedTime < PercsKey[60].daysInSeconds){ // BETWEEN 30 and 60 DAYS
            uint256 minusAmt = initialAmt.mul(PercsKey[60].feePercentage).div(percentdiv); //18% fee
						
          	uint256 dailyReturn = initialAmt.mul(PercsKey[60].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(elapsedTime).div(hardDays);
            transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[_key].amt = 0;
            user.depoList[_key].initialWithdrawn = true;
            user.depoList[_key].depoTime = block.timestamp;

            BUSD.safeTransfer(msg.sender, transferAmt);
        } else if (elapsedTime >= PercsKey[60].daysInSeconds && elapsedTime < PercsKey[90].daysInSeconds){ // BETWEEN 60 and 90 DAYS
            uint256 minusAmt = initialAmt.mul(PercsKey[90].feePercentage).div(percentdiv); //15% fee
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[90].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(elapsedTime).div(hardDays);
            transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[_key].amt = 0;
            user.depoList[_key].initialWithdrawn = true;
            user.depoList[_key].depoTime = block.timestamp;

            BUSD.safeTransfer(msg.sender, transferAmt);
        } else if (elapsedTime >= PercsKey[90].daysInSeconds && elapsedTime < PercsKey[120].daysInSeconds){ // BETWEEN 90 and 120 DAYS
            uint256 minusAmt = initialAmt.mul(PercsKey[120].feePercentage).div(percentdiv); //12% fee
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[120].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(elapsedTime).div(hardDays);
            transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[_key].amt = 0;
            user.depoList[_key].initialWithdrawn = true;
            user.depoList[_key].depoTime = block.timestamp;

            BUSD.safeTransfer(msg.sender, transferAmt);
        } else if (elapsedTime >= PercsKey[120].daysInSeconds && elapsedTime < PercsKey[150].daysInSeconds){ // BETWEEN 120 and 150 DAYS
            uint256 minusAmt = initialAmt.mul(PercsKey[150].feePercentage).div(percentdiv); //12% fee
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[150].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(elapsedTime).div(hardDays);
            transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[_key].amt = 0;
            user.depoList[_key].initialWithdrawn = true;
            user.depoList[_key].depoTime = block.timestamp;

            BUSD.safeTransfer(msg.sender, transferAmt);
        } else if (elapsedTime >= PercsKey[150].daysInSeconds){ // 150+ DAYS
            uint256 minusAmt = initialAmt.mul(PercsKey[250].feePercentage).div(percentdiv); //12% fee
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[250].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(elapsedTime).div(hardDays);
            transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[_key].amt = 0;
            user.depoList[_key].initialWithdrawn = true;
            user.depoList[_key].depoTime = block.timestamp;
            
            BUSD.safeTransfer(msg.sender, transferAmt);
        }

        uint256 withdrawFee = transferAmt.mul(devPercentage).div(percentdiv);

        BUSD.safeTransfer(owner, withdrawFee * 4/10);
        BUSD.safeTransfer(owner2, withdrawFee * 4/10);
        BUSD.safeTransfer(dev, withdrawFee * 2/10);
    }

    function withdrawRefBonus() external {
        User storage user = UsersKey[msg.sender];
        uint256 amtz = user.refBonus;
        user.refBonus = 0;

        BUSD.safeTransfer(msg.sender, amtz);
    }

    function stakeRefBonus() external { 
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];
        require(user.refBonus > 10);
      	uint256 refferalAmount = user.refBonus;
        user.refBonus = 0;
        address ref = 0x0000000000000000000000000000000000000000; //DEAD ADDRESS
				
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

    function calcdiv(address _account) public view returns (uint256 totalWithdrawable) {
        User storage user = UsersKey[_account];	

        uint256 with;
        
        for (uint256 i = 0; i < user.depoList.length; i++){	
            uint256 elapsedTime = min(block.timestamp.sub(user.depoList[i].depoTime), 250 days);

            uint256 amount = user.depoList[i].amt;
            if (user.depoList[i].initialWithdrawn == false){
                uint256 dailyReturn;
                if (elapsedTime <= PercsKey[30].daysInSeconds) { // 30days
                    dailyReturn = amount.mul(PercsKey[30].divsPercentage).div(percentdiv);
                }
                if (elapsedTime > PercsKey[60].daysInSeconds && elapsedTime <= PercsKey[90].daysInSeconds){ // 60days-90days
                    dailyReturn = amount.mul(PercsKey[60].divsPercentage).div(percentdiv);
                }
                if (elapsedTime > PercsKey[90].daysInSeconds && elapsedTime <= PercsKey[120].daysInSeconds){ // 90days-120days
                    dailyReturn = amount.mul(PercsKey[90].divsPercentage).div(percentdiv);
                }
                if (elapsedTime > PercsKey[120].daysInSeconds && elapsedTime <= PercsKey[150].daysInSeconds){ // 120days-150days
                    dailyReturn = amount.mul(PercsKey[120].divsPercentage).div(percentdiv);
                }
                if (elapsedTime > PercsKey[150].daysInSeconds){ // 150days-
                    dailyReturn = amount.mul(PercsKey[150].divsPercentage).div(percentdiv);
                }
                uint256 currentReturn = dailyReturn.mul(elapsedTime).div(1 days);
                with += currentReturn;
            } 
        }
        return with;
    }

    function compound() external {
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
              reffy: 0x0000000000000000000000000000000000000000, 
              initialWithdrawn: false
          }));

        user.keyCounter += 1;
        main.ovrTotalDeps += 1;
        main.compounds += 1;
        user.lastWith = block.timestamp;  
    }

    function changeOwner(address _account) external {
        require(msg.sender == owner, "Only owner is accessable");
        owner = _account;
    }

    function changeOwner2(address _account) external {
        require(msg.sender == owner2, "Only owner is accessable");
        owner2 = _account;
    }

    function changeDev(address _account) external {
        require(msg.sender == dev, "Only dev is accessable");
        dev = _account;
    }

    function min(uint256 a, uint256 b) private pure returns(uint256) {
        return a < b ? a : b;
    }
}