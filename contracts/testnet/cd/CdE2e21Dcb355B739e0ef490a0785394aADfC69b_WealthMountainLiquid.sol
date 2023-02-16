/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function sub( uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            require(b <= a, "SafeMath: Error" );
            return a - b;
        }
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            uint256 c = a + b;
            return c;
        }
    }

}

abstract contract ReentrancyGuard {
    bool internal locked;
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

struct LiqUser{
    uint256 lastWithdrawal;
    uint256 totalWithdrawn;
    uint256 totalStaked;
    uint256 stakeCount;
    uint256 numOfStakesActive;
    uint256 refearned;
    LiqStake [] LiqStakeList;
}

struct LiqStake{
    uint256 id;
    uint256 amt;
    uint256 staketime;
    bool initialWithdrawn;
}

struct LiqProf{
    uint256 lpid;
    uint256 lpamount;
    uint256 lpwithdrawcount;
    uint256 lptimestamp;
    uint256 lptotalcomputed;
    uint256 lptotalwithdrawn;
}

struct DailyData {
    uint256 dailydate;
    uint256 liquidpoolvalue;
    uint256 injtotal;
}

contract WealthMountainLiquid is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    uint256 public AllTimeLiqStakeCount; 
    uint256 public AllTimeSumOfStakeValues; 
    uint256 public AllTimeUniqueUsers; 
    uint256 public LiquidPoolTotal;
    uint256 public LiqProfitCurrentTotal;
    uint256 public LiqProfitCount;
    uint256 public CurrentLiqUsers;
    uint256 public TotalLiqUsers;
    uint256 public injectedTotal;
    uint256 public dailyValueTime;
    uint256 public leftoverFunds;
    uint256 public leftOverDayLimit;
    uint256 constant public sixtydays = 60 days;
    uint256 constant public liqfee = 50;
    uint256 constant public reffee = 10;
    uint256 constant public thousand = 1000;
    bool public ctrigger;
    IERC20 public USDT;
    address public InvWallet;
    address public CharityAddress;
    DailyData [] public dailyValueArray;
    mapping (address => LiqUser) public LiqUserKey;
    mapping (uint256 => LiqProf) public LProf;
    mapping (address => mapping (uint256 => bool)) public LiqProfTaken;
    mapping(address => bool) public UserCount;
    mapping(uint256 => DailyData) public DailyKey;
    constructor(){
        USDT = IERC20(0x55d398326f99059fF775485246999027B3197955); // BSC Mainnet
        InvWallet = 0x64b7A3CD189a886438243F0337b64f7ddf1B18D3;
        dailyValueTime = block.timestamp;
        leftOverDayLimit = 60 days; 
        CharityAddress = 0x000000000000000000000000000000000000dEaD;
    }

    function DepoLiqProfits(uint256 profamount) public noReentrant {
        require (profamount > 2000 ether, "Injections must be a minimum of 2000 USDT.");
        USDT.safeTransferFrom(msg.sender, address(this), profamount); 
        LiqProfitCurrentTotal += profamount; 
        LiqProf storage profit = LProf[LiqProfitCount]; 
        uint256 currentpool = LiquidPoolTotal; 
        profit.lpid = LiqProfitCount; 
        profit.lpamount = profamount.add(leftoverFunds); 
        profit.lptimestamp = block.timestamp; 
        profit.lptotalcomputed = currentpool; 
        leftoverFunds = 0;
        injectedTotal += profamount; 
        LiqProfitCount += 1; 
    }

    function StakeLiq(uint256 stakeamt, address reffy) public noReentrant{
        LiqUser storage user = LiqUserKey[msg.sender];
        LiqUser storage ref = LiqUserKey[reffy];
        require (stakeamt >= 50 ether, "A minimum of 50 USDT is required to create a liquid stake."); 
        require (reffy != msg.sender, "You cannot refer yourself.");
        checkUsers(msg.sender);
        if (user.LiqStakeList.length < 1){
            CurrentLiqUsers += 1;
            TotalLiqUsers += 1;
        }
        USDT.safeTransferFrom(msg.sender, address(this), stakeamt);
        uint256 liqf = stakeamt.mul(liqfee).div(thousand);
        uint256 r = stakeamt.mul(reffee).div(thousand);
        uint256 adjustedamt = stakeamt.sub(liqf).sub(r);

        if (reffy != 0x000000000000000000000000000000000000dEaD && ref.totalStaked >= 50 ether){
            ref.refearned += r;
        }

        USDT.safeTransfer(InvWallet, liqf);
        user.LiqStakeList.push(LiqStake({
            id: user.stakeCount,
            amt: adjustedamt,
            staketime: block.timestamp,
            initialWithdrawn: false
        }));
        AllTimeLiqStakeCount += 1;
        AllTimeSumOfStakeValues += adjustedamt; 
        LiquidPoolTotal += adjustedamt; 
        user.totalStaked += adjustedamt; 
        user.numOfStakesActive += 1; 
        user.stakeCount += 1; 
        addDailyValues();
   }

    function WithdrawInitialLiq(uint256 key) public noReentrant {
        LiqUser storage user = LiqUserKey[msg.sender];
        uint256 transferamt;
        for (uint256 i = 0; i < user.LiqStakeList.length; i++){
            if (user.LiqStakeList[i].id == key){
                require (user.LiqStakeList[i].initialWithdrawn == false, "Already unstaked!");
                    transferamt = user.LiqStakeList[i].amt;
                    user.LiqStakeList[i].amt = 0;
                    user.LiqStakeList[i].staketime = 0;
                    user.LiqStakeList[i].initialWithdrawn = true;
            }       
        }
        LiquidPoolTotal -= transferamt;
        user.lastWithdrawal = block.timestamp;
        user.totalStaked -= transferamt;
        user.numOfStakesActive -= 1;
        if (user.numOfStakesActive < 1){
            CurrentLiqUsers -= 1;
        }
        USDT.safeTransfer(msg.sender, transferamt);
        addDailyValues();
    }

    function DisplayUserStakeInfo(address userwallet) public view returns(LiqStake [] memory LiqStakeList) {	
        LiqUser storage user = LiqUserKey[userwallet];	
        return user.LiqStakeList;	
    }

    function WithdrawLiqProfit(uint256 key) public noReentrant {
        LiqUser storage user = LiqUserKey[msg.sender];
        LiqProf storage profit = LProf[key];
        require (profit.lptimestamp + leftOverDayLimit > block.timestamp);
        require (LiqProfTaken[msg.sender][key] == false, "Already claimed!");
        uint256 halfvar;
        uint256 qualifiers;
        for (uint256 i = 0; i < user.LiqStakeList.length; i++){
            if (user.LiqStakeList[i].initialWithdrawn == false && user.LiqStakeList[i].staketime < profit.lptimestamp){
                uint256 diff = (block.timestamp).sub(user.LiqStakeList[i].staketime);
                if (diff < sixtydays){
                    qualifiers += user.LiqStakeList[i].amt.div(2);
                    halfvar += user.LiqStakeList[i].amt.div(2);
                }
                if (diff >= sixtydays){
                    qualifiers += user.LiqStakeList[i].amt;
                }
            }
        }
        uint256 qualifiedpercent = qualifiers.mul(thousand).div(profit.lptotalcomputed);
        uint256 qualifiedamt = qualifiedpercent.mul(profit.lpamount).div(thousand);
        uint256 halfvarpercent = halfvar.mul(thousand).div(profit.lptotalcomputed);
        uint256 halfamt = halfvarpercent.mul(profit.lpamount).div(thousand);
        if (halfamt > 0){
            leftoverFunds += halfamt;
            profit.lptotalwithdrawn += halfamt;
            LiqProfitCurrentTotal -= halfamt;
        }
        profit.lptotalwithdrawn += qualifiedamt;
        profit.lpwithdrawcount += 1;
        LiqProfitCurrentTotal -= qualifiedamt;
        LiqProfTaken[msg.sender][key] = true;
        uint256 damt;
        if (ctrigger == true){
            damt = donationRecalc(qualifiedamt);
            USDT.safeTransfer(CharityAddress, damt);
            qualifiedamt = profitRecalc(qualifiedamt);
        }
        user.totalWithdrawn += qualifiedamt;
        USDT.safeTransfer(msg.sender, qualifiedamt);
        addDailyValues();
    }


    function checkUsers(address theAddy) internal { 
        if (UserCount[theAddy] == false){
            AllTimeUniqueUsers += 1;
            UserCount[theAddy] = true;
        }
    }

    function setCharityAddy(address theaddy) public onlyOwner {

        CharityAddress = theaddy;

    }

    function addDailyValues() internal {
        if (block.timestamp.sub(dailyValueTime) > 86400){
            dailyValueTime = block.timestamp;
            dailyValueArray.push(DailyData({
                dailydate: block.timestamp,
                liquidpoolvalue: LiquidPoolTotal,
                injtotal: injectedTotal
            }));
        }
    }

    function getDailyValues() public view returns (DailyData [] memory dd){
        return dailyValueArray;
    }

    function profitRecalc(uint256 amtw) public pure returns (uint256 recalcamtg){
        uint256 newamt = amtw.mul(950).div(thousand);
        return newamt;
    }

    function liqProfAccess(uint256 lid) public view returns (LiqProf memory lpar) {
        LiqProf storage lp = LProf[lid];
        return lp;
    }

    function calcdivProf(address calcaddy, uint256 ckey) public view returns (uint256) {
        LiqUser storage user = LiqUserKey[calcaddy];
        LiqProf storage profit = LProf[ckey];
        uint256 qualifiers;
        if (LiqProfTaken[calcaddy][ckey] == false){
            for (uint256 i = 0; i < user.LiqStakeList.length; i++){
                if (user.LiqStakeList[i].initialWithdrawn == false && user.LiqStakeList[i].staketime < profit.lptimestamp){
                    uint256 diff = (block.timestamp).sub(user.LiqStakeList[i].staketime);
                    if (diff < sixtydays){
                    qualifiers += user.LiqStakeList[i].amt.div(2);
                    }
                    if (diff >= sixtydays){
                    qualifiers += user.LiqStakeList[i].amt;
                    }
                }
            }
        }
        uint256 qualifiedpercent = qualifiers.mul(thousand).div(profit.lptotalcomputed);
        uint256 qualifiedamt = qualifiedpercent.mul(profit.lpamount).div(thousand);
        if (ctrigger == true){
            qualifiedamt = profitRecalc(qualifiedamt);
        }
        return qualifiedamt;
    }

     function WithdrawRefs() public noReentrant {	
        LiqUser storage user = LiqUserKey[msg.sender];	
        uint256 wdamt; 	
        if (user.refearned > 0){	
            wdamt = user.refearned;	
            user.refearned = 0;	
        }	
        USDT.safeTransfer(msg.sender, wdamt);	
    }


    function donationRecalc(uint256 amtq) pure internal returns (uint256 doamt){
        uint256 newamt2 = amtq.mul(50).div(thousand);
        return newamt2;
    } 

    function userActLiqs(address laddy) public view returns (uint256){
        LiqUser storage lu = LiqUserKey[laddy];
        return lu.numOfStakesActive;
    }


    function userAmtLiqStakes(address laddy) public view returns (uint256){
        LiqUser storage lu = LiqUserKey[laddy];
        return lu.totalStaked;
    }

    function returnAverageStakeValue() public view returns (uint256 avg) {	
        uint256 average = AllTimeSumOfStakeValues / AllTimeLiqStakeCount;	
        return average;	
    }

    function avgLiqStakeLength(address avgaddy) public view returns (uint256) {
        uint256 diff;
        uint256 count;
        LiqUser storage lp = LiqUserKey[avgaddy];
        for (uint256 i = 0; i < lp.LiqStakeList.length; i++){
            if (lp.LiqStakeList[i].initialWithdrawn == false){
            diff += block.timestamp.sub(lp.LiqStakeList[i].staketime);
            count += 1;
            }
        }
        return diff.div(count);
    }

    function transferLeftoverLP(uint256 lkey) public onlyOwner {
        LiqProf storage lp = LProf[lkey];
        require (lp.lptimestamp + leftOverDayLimit < block.timestamp);
        uint256 diff;
        if (lp.lpamount.sub(lp.lptotalwithdrawn) > 0){
            diff = lp.lpamount.sub(lp.lptotalwithdrawn);
            leftoverFunds += diff;
            lp.lptotalwithdrawn = lp.lpamount;
            }
    }

    function leftOverDaySetter(uint256 amtofdays) public onlyOwner {

        leftOverDayLimit = amtofdays;

    }

    function ctrigSwitch() public onlyOwner {
        ctrigger = !ctrigger;
    }
}