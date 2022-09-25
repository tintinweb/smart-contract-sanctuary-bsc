/**
 *Submitted for verification at BscScan.com on 2022-09-25
*/

/**
 *Submitted for verification 2022-09-26
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


contract GoldenSeaBSC {

    using SafeMath for uint256;
    
    uint256 constant launch = 1664542800; 
  	uint256 constant hardDays = 86400; 
    uint256 constant percentdiv = 1000; 
    uint256 refPercentage = 30; 
    uint256 devPercentage = 100; 
    address public owner;
    address public tokenAdress;

    struct UserInfo {
        uint256 createDate; 
        uint256 promoteBonus; 
        uint256 stakeTotal; 
        uint256 lastSign; 
        uint256 keyCount; 
        address refAddress; 
        Depo [] treasuryList; 
    }
    struct Depo {
        uint256 key; 
        uint256 investTime; 
        uint256 amt; 
        address reffy; 
        bool depositSign; 
    }
    struct Main {
        uint256 allTotalDeps; 
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

    mapping (address => mapping(uint256 => Depo)) public DeposMap;
    mapping (address => UserInfo) public UsersKey;
    mapping (uint256 => DivPercs) public PercsKey;
    mapping (uint256 => FeesPercs) public FeesKey;
    mapping (uint256 => Main) public MainKey;
    using SafeERC20 for IERC20;
    IERC20 public BUSD;

    constructor() {
        tokenAdress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

        owner = msg.sender; 
        PercsKey[10] = DivPercs(864000, 20);    // 10  2%
        PercsKey[20] = DivPercs(1728000, 30);   // 20  3%
        PercsKey[30] = DivPercs(2592000, 40);   // 30  4%
        PercsKey[40] = DivPercs(3456000, 50);   // 40  5%
        PercsKey[50] = DivPercs(4320000, 100);   // 50  10%

        FeesKey[10] = FeesPercs(864000, 100);   // 10
        FeesKey[20] = FeesPercs(1728000, 80);   // 20
        FeesKey[30] = FeesPercs(3456000, 40);   // 40
        FeesKey[40] = FeesPercs(4320000, 20);   // 50

        BUSD = IERC20(tokenAdress);

    }
     
    function stakeStablecoins(uint256 amtx, address ref) payable public { 
        require(block.timestamp >= launch || msg.sender == owner, "App did not launch yet."); 
        require(ref != msg.sender, "You cannot refer yourself!");
 
        BUSD.safeTransferFrom(msg.sender, address(this), amtx);

        // 
        UserInfo storage user = UsersKey[msg.sender]; 
        UserInfo storage user2 = UsersKey[ref]; 
        Main storage main = MainKey[1];

        if (user.lastSign == 0){ 
            user.lastSign = block.timestamp;
            user.createDate = block.timestamp;
        }

        uint256 userStakePercentAdjustment = 1000 - devPercentage; 
        uint256 adjustedAmt = amtx.mul(userStakePercentAdjustment).div(percentdiv); 
        uint256 stakeFee = amtx.mul(devPercentage).div(percentdiv); 
        
        user.stakeTotal += adjustedAmt; 

        uint256 refAmtx = adjustedAmt.mul(refPercentage).div(percentdiv); 
        if (ref == 0x000000000000000000000000000000000000dEaD){ 
            user2.promoteBonus += 0;
            user.promoteBonus += 0;
        } else {
            user2.promoteBonus += refAmtx;  
            user.promoteBonus += refAmtx; 
        }

        user.treasuryList.push(Depo({  
            key: user.treasuryList.length,
            investTime: block.timestamp,
            amt: adjustedAmt,
            reffy: ref,
            depositSign: false
        }));

        user.keyCount += 1;  
        main.allTotalDeps += 1; 
        main.users += 1; 
        
        BUSD.safeTransfer(owner, stakeFee); 
    }

    function userInfo() view external returns (Depo [] memory treasuryList){
        UserInfo storage user = UsersKey[msg.sender];
        return(
            user.treasuryList
        );
    }

    function withdrawDivs() public returns (uint256 withdrawAmount){
        UserInfo storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];

        uint256 x = calcdiv(msg.sender); 
      
      	for (uint i = 0; i < user.treasuryList.length; i++){
          if (user.treasuryList[i].depositSign == false) {
            user.treasuryList[i].investTime = block.timestamp; 
          }
        }

        main.ovrTotalWiths += x;
        user.lastSign = block.timestamp; 
        BUSD.safeTransfer(msg.sender, x); 
        return x;
    }

    function redeemInitial (uint256 num ) public {
      	  
      	UserInfo storage user = UsersKey[msg.sender];
		
        
      	require(user.treasuryList[num].depositSign == false, "This has already been redeem.");
      
        uint256 initialAmt = user.treasuryList[num].amt; 
        uint256 currDays1 = user.treasuryList[num].investTime; 
        uint256 currTime = block.timestamp; 
        uint256 currDays = currTime - currDays1; 

        uint256 transferAmt; 

        if (currDays < FeesKey[10].daysInSeconds){ 
            uint256 minusAmt = initialAmt.mul(FeesKey[10].feePercentage).div(percentdiv); 
           	
          	uint256 dailyReturn = initialAmt.mul(PercsKey[10].divsPercentage).div(percentdiv); 
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays); 
          	
          	transferAmt = initialAmt + currentReturn - minusAmt; 
                
            user.treasuryList[num].amt = 0;
            user.treasuryList[num].depositSign = true;
            user.treasuryList[num].investTime = block.timestamp;
            
            BUSD.safeTransfer(msg.sender, transferAmt);
            BUSD.safeTransfer(owner, minusAmt);
          
        } else if (currDays >= FeesKey[10].daysInSeconds && currDays < FeesKey[20].daysInSeconds){ 
            uint256 minusAmt = initialAmt.mul(FeesKey[20].feePercentage).div(percentdiv); 
						
          	uint256 dailyReturn = initialAmt.mul(PercsKey[10].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);

		    transferAmt = initialAmt + currentReturn - minusAmt;

            user.treasuryList[num].amt = 0;
            user.treasuryList[num].depositSign = true;
            user.treasuryList[num].investTime = block.timestamp;
            
            BUSD.safeTransfer(msg.sender, transferAmt);
            BUSD.safeTransfer(owner, minusAmt);

        } else if (currDays >= FeesKey[20].daysInSeconds && currDays < FeesKey[30].daysInSeconds){ 
            uint256 minusAmt = initialAmt.mul(FeesKey[30].feePercentage).div(percentdiv); 
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[20].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
	        transferAmt = initialAmt + currentReturn - minusAmt;
            
            user.treasuryList[num].amt = 0;
            user.treasuryList[num].depositSign = true;
            user.treasuryList[num].investTime = block.timestamp;
            
            BUSD.safeTransfer(msg.sender, transferAmt);
            BUSD.safeTransfer(owner, minusAmt);

        } else if (currDays >= FeesKey[30].daysInSeconds && currDays < FeesKey[40].daysInSeconds){ 
            uint256 minusAmt = initialAmt.mul(FeesKey[40].feePercentage).div(percentdiv); 
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[30].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
		    transferAmt = initialAmt + currentReturn - minusAmt;
            
            user.treasuryList[num].amt = 0;
            user.treasuryList[num].depositSign = true;
            user.treasuryList[num].investTime = block.timestamp;
            
            BUSD.safeTransfer(msg.sender, transferAmt);
            BUSD.safeTransfer(owner, minusAmt);

        } else if (currDays >= FeesKey[40].daysInSeconds && currDays < FeesKey[50].daysInSeconds){ 
            uint256 minusAmt = initialAmt.mul(FeesKey[40].feePercentage).div(percentdiv); 
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[40].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
			transferAmt = initialAmt + currentReturn - minusAmt;

            user.treasuryList[num].amt = 0;
            user.treasuryList[num].depositSign = true;
            user.treasuryList[num].investTime = block.timestamp;
            
            BUSD.safeTransfer(msg.sender, transferAmt);
            BUSD.safeTransfer(owner, minusAmt);

        } else if (currDays >= FeesKey[50].daysInSeconds){ 
            uint256 minusAmt = initialAmt.mul(FeesKey[40].feePercentage).div(percentdiv); 
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[50].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
		    transferAmt = initialAmt + currentReturn - minusAmt;
            
            user.treasuryList[num].amt = 0;
            user.treasuryList[num].depositSign = true;
            user.treasuryList[num].investTime = block.timestamp;
            
            BUSD.safeTransfer(msg.sender, transferAmt);
            BUSD.safeTransfer(owner, minusAmt);

        } else {
            revert("Could not calculate the # of days youv've been staked.");
        }
        
    }
     
    function withdrawRefBonus() public {
        UserInfo storage user = UsersKey[msg.sender];
        uint256 amtz = user.promoteBonus;
        user.promoteBonus = 0;

        BUSD.safeTransfer(msg.sender, amtz);
    }
 
    function stakeRefBonus() public { 
        UserInfo storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];
        
        require(user.promoteBonus > 10); 

      	uint256 refferalAmount = user.promoteBonus;
        user.promoteBonus = 0;
        address ref = 0x000000000000000000000000000000000000dEaD; 
				
        user.treasuryList.push(Depo({ 
            key: user.keyCount,
            investTime: block.timestamp,
            amt: refferalAmount,
            reffy: ref, 
            depositSign: false
        }));

        user.keyCount += 1;  
        main.allTotalDeps += 1; 
    }
 
    function calcdiv(address dy) public view returns (uint256 totalWithdrawable){
        UserInfo storage user = UsersKey[dy];	

        uint256 with;
          
        for (uint256 i = 0; i < user.treasuryList.length; i++){	 
            uint256 elapsedTime = block.timestamp.sub(user.treasuryList[i].investTime);
 
            uint256 amount = user.treasuryList[i].amt;
            
            if (user.treasuryList[i].depositSign == false){ 
 
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

        UserInfo storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];

        uint256 y = calcdiv(msg.sender); 

        for (uint i = 0; i < user.treasuryList.length; i++){ 
            if (user.treasuryList[i].depositSign == false) {
                user.treasuryList[i].investTime = block.timestamp;
            }
        }

        user.treasuryList.push(Depo({ 
            key: user.keyCount,
            investTime: block.timestamp,
            amt: y,
            reffy: 0x000000000000000000000000000000000000dEaD, 
            depositSign: false 
        }));

        user.keyCount += 1; 
        main.allTotalDeps += 1; 
        main.compounds += 1; 
        user.lastSign = block.timestamp; 
    }

    function getBalance() public view returns(uint256){
         return BUSD.balanceOf(address(this));
    }
}


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}