/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

//SPDX-License-Identifier: UNLICENSED

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
        // require(isContract(target), "Address: call to non-contract"); //discuss this line
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
    uint256 firstDepoDate;
    uint256 lastWithdrawal;
    uint256 totalWithdrawn;
    uint256 totalStaked;
    uint256 stakeCount;
    uint256 numOfStakesActive;
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
    uint256 lptotalusercount;
}

struct DailyData {
    uint256 dailydate;
    uint256 liqpoool;
    uint256 injtotal;
}

contract WealthMountainLiquid is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Amount of totalStakes All times $

    uint256 public LiqPoolTotal;

    //Total Of Profits All Time 

    // uint256 public LiqProfitTotal; --> unused
   
    // Current Amounts of Profit Pool;
    
    uint256 public LiqProfitCurrentTotal;

    // Amount of profits entered, each profit's count

    uint256 public LiqProfitCount;

    // Current Amount of Users In Liq Pool

    uint256 public CurrentLiqUsers;

    // Total All Time User Count for Each Category
    
    uint256 public TotalLiqUsers;

    // 

    // Global globals

    // uint256 public flatPrice; --> unused
    uint256 public UserCountGlobal;
    uint256 public injectedTotal;
    uint256 public dailyValueTime;
    // uint256 public SplitStakeCount; --> unused
    uint256 public CharityPoolTotal;
    uint256 public leftoverFunds;

    // Switches

    bool public ctrigger;

    // constants

    uint256 constant public sixtydays = 60 days;
    uint256 constant public liqFee = 50;
    // uint256 constant public stakeFeeLiq = 50; --> unused
    // uint256 constant public liqMinDays = 15 days; --> unused
    uint256 constant public liqfee = 100;
    uint256 constant public thousand = 1000;

    IERC20 public BUSD;

    // addresses

    address public invfee;
    address public charitytoken;

    // Daily Values Record
    DailyData [] public dailyValueArray;

    // Mapping for ie. User storage user = LiqUserKey[msg.sender] // to access User's struct

    mapping (address => LiqUser) public LiqUserKey;

    // Mapping for ie LProf[LiqProfitCount].lpamount // to access each Profit's struct through ProfitCount key;

    mapping (uint256 => LiqProf) public LProf;

    // Mapping for ie LiqProfTake[msg.sender][4] = true => msg.sender has already taken profits from this pool

    mapping (address => mapping (uint256 => bool)) public LiqProfTaken;

    // Mapping user count

    mapping(address => bool) public UserCount;
    mapping(uint256 => DailyData) public DailyKey;

    constructor(){
        BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7); // TESTNET BUSD
        // BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // MAINNET

        dailyValueTime = block.timestamp;
    }

    function DepoLiqProfits(uint256 profamount) public {

        BUSD.safeTransferFrom(msg.sender, address(this), profamount); // get transfer of amt
        
        LiqProfitCurrentTotal += profamount; // add to global total of all liq profits

        LiqProf storage profit = LProf[LiqProfitCount]; //creating a new mapping for liqprof

        uint256 currentpool = LiqPoolTotal; // takes total staked for all users

        profit.lpid = LiqProfitCount; // id = count
        profit.lpamount = profamount.add(leftoverFunds); // amt
        profit.lptimestamp = block.timestamp; //time
        profit.lptotalcomputed = currentpool; //amount for basing math off

        leftoverFunds = 0;
        injectedTotal += profamount; // add to injected total

        LiqProfitCount += 1; // change count

    }

    function StakeLiq(uint256 stakeamt) public {
        LiqUser storage user = LiqUserKey[msg.sender];

        require (stakeamt > 50, "Minimum stake amount not met.");

        if (user.LiqStakeList.length < 1){
            CurrentLiqUsers += 1;
            TotalLiqUsers += 1;
            user.firstDepoDate = block.timestamp;
        }

        BUSD.safeTransferFrom(msg.sender, address(this), stakeamt);

        uint256 liqf = stakeamt.mul(liqfee).div(thousand);
        uint256 adjustedamt = stakeamt.sub(liqf);

        // BUSD.safeTransfer(InvWallet, address(this), liqf);

        user.LiqStakeList.push(LiqStake({
            id: user.stakeCount,
            amt: adjustedamt,
            staketime: block.timestamp,
            initialWithdrawn: false
        }));

        LiqPoolTotal += adjustedamt;
        user.totalStaked += adjustedamt;
        user.numOfStakesActive += 1;
        user.stakeCount += 1;
        addDailyValues();//getDailyValues
    }

    function WithdrawInitialLiq(uint256 key) public {
        
        LiqUser storage user = LiqUserKey[msg.sender];

        uint256 transferamt;

        for (uint256 i = 0; i < user.LiqStakeList.length; i++){
            if (user.LiqStakeList[i].id == key){
                require (user.LiqStakeList[i].initialWithdrawn == false, "You've already unstaked!");
                    transferamt = user.LiqStakeList[i].amt;
                    user.LiqStakeList[i].amt = 0;
                    user.LiqStakeList[i].staketime = 0;
                    user.LiqStakeList[i].initialWithdrawn = true;
            }       
        }

        LiqPoolTotal -= transferamt;
        user.lastWithdrawal = block.timestamp;
        user.totalStaked -= transferamt;
        user.numOfStakesActive -= 1;

        if (user.numOfStakesActive < 1){
            CurrentLiqUsers -= 1;
        }

        BUSD.safeTransfer(msg.sender, transferamt);
    }

    function WithdrawLiqProfit(uint256 key) public {
        
        LiqUser storage user = LiqUserKey[msg.sender];
        LiqProf storage profit = LProf[key];

        require (LiqProfTaken[msg.sender][key] == false, "You've already withdrawn your Liquid rewards!");

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

        leftoverFunds += halfamt;

        profit.lptotalwithdrawn += qualifiedamt;
        profit.lpwithdrawcount += 1;

        LiqProfTaken[msg.sender][key] = true;

        uint256 damt;

        if (ctrigger == true){
            damt = donationRecalc(qualifiedamt);
            BUSD.safeTransfer(msg.sender, damt);
            qualifiedamt = profitRecalc(qualifiedamt);
        }

        user.totalWithdrawn += qualifiedamt;
        
        BUSD.safeTransfer(msg.sender, qualifiedamt);
    }

    // function WithdrawAllLiqProfits() public {

    //     LiqUser storage user = LiqUserKey[msg.sender];

    //     uint256 qualamt;
    //     uint256 qualtotal;
    //     uint256 qualmax;

    //     for (uint256 y = 0; y < LiqProfitCount; y++){
    //         LiqProf storage profit = LProf[y];
    //         if (LiqProfTaken[msg.sender][profit.lpid] == false){
    //             for (uint256 i = 0; i < user.LiqStakeList.length; i++){
    //                 if (user.LiqStakeList[i].initialWithdrawn == false && user.LiqStakeList[i].staketime < profit.lptimestamp){
    //                 uint256 diff = (block.timestamp).sub(user.LiqStakeList[i].staketime);
    //                     if (diff < sixtydays){
    //                         qualamt += user.LiqStakeList[i].amt.div(2);
    //                         qualmax += profit.lptotalcomputed;
    //                         qualtotal += profit.lpamount;
    //                         profit.lptotalwithdrawn += qualamt.div(qualmax).mul(thousand).mul(qualtotal).div(thousand);
    //                         LiqProfTaken[msg.sender][profit.lpid] == true;
    //                         LProf[profit.lpid].lptotalusercount += 1;
    //                     }
    //                     if (diff >= sixtydays){
    //                         qualamt += user.LiqStakeList[i].amt;
    //                         qualmax += profit.lptotalcomputed;
    //                         qualtotal += profit.lpamount;
    //                         profit.lptotalwithdrawn += qualamt.div(qualmax).mul(thousand).mul(qualtotal).div(thousand);
    //                         LiqProfTaken[msg.sender][profit.lpid] == true; 
    //                         LProf[profit.lpid].lptotalusercount += 1;
    //                     }
    //                 }
    //             }
    //         }
    //     }

    //     uint256 qualpercent = qualamt.div(qualmax).mul(thousand);
    //     uint256 qualified = qualpercent.mul(qualtotal).div(thousand);
    //     user.lastWithdrawal = block.timestamp;
        
    //     // add ctrigger function here

    //     user.totalWithdrawn += qualified;

    //     uint256 damt;

    //     if (ctrigger == true){
    //         damt = donationRecalc(qualified);
    //         CharityPoolTotal += damt;
    //         qualified = profitRecalc(qualified);
    //     }

    //     BUSD.safeTransfer(msg.sender, qualified);
    // }

    function checkUsers(address theAddy) internal { //unique addresses interacting with smart contract

        if (UserCount[theAddy] == false){
            UserCountGlobal += 1;
            UserCount[theAddy] = true;
        }
        //add struct/mapping for this
    }

    function addDailyValues() internal {
        
        if (block.timestamp.sub(dailyValueTime) > 86400){
            dailyValueTime = block.timestamp;
            dailyValueArray.push(DailyData({
                dailydate: block.timestamp,
                liqpoool: LiqPoolTotal,
                injtotal: injectedTotal
            }));
        }
    }

    function getDailyValues() public view returns (DailyData [] memory dd){

        return dailyValueArray;

    }

    function profitRecalc(uint256 amtw) public view returns (uint256 recalcamtg){

        uint256 newamt = amtw.mul(950).div(thousand);

        return newamt;

    }

    function liqProfAccess(uint256 lid) public view returns (LiqProf memory lpar) {

        LiqProf storage lp = LProf[lid];

        return lp;

    }

    function calcdivProf(address calcaddy) public view returns (uint256) {

        LiqUser storage user = LiqUserKey[msg.sender];

        uint256 qualamt;
        uint256 qualtotal;
        uint256 qualmax;

        for (uint256 y = 0; y < LiqProfitCount; y++){
            LiqProf storage profit = LProf[y];
            if (LiqProfTaken[msg.sender][profit.lpid] == false){
                for (uint256 i = 0; i < user.LiqStakeList.length; i++){
                    if (user.LiqStakeList[i].initialWithdrawn == false && user.LiqStakeList[i].staketime < profit.lptimestamp){
                    uint256 diff = (block.timestamp).sub(user.LiqStakeList[i].staketime);
                        if (diff < sixtydays){
                            qualamt += user.LiqStakeList[i].amt.div(2);
                            qualmax += profit.lptotalcomputed;
                            qualtotal += profit.lpamount;
                        }
                        if (diff >= sixtydays){
                            qualamt += user.LiqStakeList[i].amt;
                            qualmax += profit.lptotalcomputed;
                            qualtotal += profit.lpamount;
                        }
                    }
                }
            }
        }

        uint256 qualpercent = qualamt.div(qualmax).mul(thousand);
        uint256 qualified = qualpercent.mul(qualtotal).div(thousand);
        
        // add ctrigger function here

        uint256 damt;

        if (ctrigger == true){
            qualified = profitRecalc(qualified);
        }

        return qualified;

    }

    function donationRecalc(uint256 amtq) public returns (uint256 doamt){

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

    function setCharityAddy(address chaddy) onlyOwner public {

        charitytoken = chaddy;

    }

    function SendToCharity() public {

        uint256 tamount = CharityPoolTotal;
        CharityPoolTotal = 0;

        BUSD.safeTransfer(charitytoken, tamount);

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

}