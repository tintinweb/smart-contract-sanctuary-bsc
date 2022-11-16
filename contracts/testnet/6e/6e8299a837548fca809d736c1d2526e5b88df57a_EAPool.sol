/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

pragma solidity ^0.8.13;


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
        // require(isContract(target), "Address: call to non-contract"); //
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


struct EaUser{
    uint256 entryDate;
    uint256 entitledAmt;
    uint256 totalWithdrawn;
    uint256 pendingWithdraw;
    uint256 [] wdlist;
}

struct EAentry{
    address uaddy;
    uint256 eainitial;
}

struct MiscEntry{
    address useraddy;
    uint256 amtEntitled;
}

struct EAProf{
    uint256 eaid;
    uint256 eaamount;
    uint256 eausers;
    uint256 eawithdrawcount;
    uint256 eatotalbased;
    uint256 eatimestamp;
    uint256 eaendtime;
    uint256 eatotalwithdrawn;
    uint256 eatotalusercount;
}

struct DailyData {
    uint256 dailydate;
    uint256 eapoool;
    uint256 injtotal;
}

contract EAPool is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // All 4 Current Pool Totals;

    uint256 public EAPoolTotal;

    // Current Amounts of Profit Pool;
    
    uint256 public EAProfitCurrentTotal;

    // Amount of profits entered, each profit's count

    uint256 public EAProfitCount;


    // Global globals

    uint256 public leftoverEAProfs;
    uint256 public UserCountGlobal;
    uint256 public injectedTotal;
    uint256 public leftoverFunds;
    uint256 public dailyValueTime;
    uint256 public profDuration;


    // constants

    uint256 constant public thousand = 1000;

    IERC20 public BUSD;

    // Daily Values Record
    DailyData [] public dailyValueArray;

    // Mapping for ie. User storage user = LiqUserKey[msg.sender] // to access User's struct
    mapping (address => EaUser) public EaUserKey;

    // Mapping for ie LProf[LiqProfitCount].lpamount // to access each Profit's struct through ProfitCount key;

    mapping (uint256 => EAProf) public EProf;

    // Mapping for ie LiqProfTake[msg.sender][4] = true => msg.sender has already taken profits from this pool

    mapping (address => mapping (uint256 => bool)) public EaProfTaken;

    // Mapping user count

    constructor(){
        BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);

        dailyValueTime = block.timestamp;
        profDuration = 180;

    }

    function EnterAddress(address dddy, uint256 aamt) public onlyOwner {

        EaUser storage e = EaUserKey[dddy];
        e.entryDate = block.timestamp;


        if (e.entitledAmt > 0){
            EAPoolTotal -= e.entitledAmt;
        }

        e.entitledAmt = aamt;
        EAPoolTotal += aamt;
        UserCountGlobal += 1;

    }

    function enterAddy(EAentry [] memory entries) public onlyOwner {
        for (uint256 i = 0; i < entries.length; i++){
            address ent = entries[i].uaddy;
            uint256 amtadded = entries[i].eainitial;

            EaUser storage e = EaUserKey[ent];
            e.entryDate = block.timestamp;
            e.entitledAmt = amtadded;
            EAPoolTotal += amtadded;
            UserCountGlobal += 1;
        }
    }

    function DepoMiscProfitss(MiscEntry [] memory misc) public {

        uint256 totalct;

        for (uint256 y = 0; y < misc.length; y++){
            uint256 randynt = misc[y].amtEntitled;
            totalct += randynt;
        }

        BUSD.safeTransferFrom(msg.sender, address(this), totalct);

        for (uint256 i = 0; i < misc.length; i++){
            address randaddy = misc[i].useraddy;
            uint256 randint = misc[i].amtEntitled;
            EaUser storage user = EaUserKey[randaddy];
            user.pendingWithdraw += randint;
        }

        injectedTotal += totalct;
        EAProfitCurrentTotal += totalct;

    }

    function DepoMiscProfits(address maddy, uint256 pw) public onlyOwner{

        BUSD.safeTransferFrom(msg.sender, address(this), pw);
        EaUser storage user = EaUserKey[maddy];
        user.pendingWithdraw += pw;
        injectedTotal += pw;

    }

    function DepoEAProfits(uint256 pamt) public {

        
        BUSD.safeTransferFrom(msg.sender, address(this), pamt);

        if (pamt < 5000 ether){
            leftoverEAProfs += pamt;
        }

        require (pamt > 5000, "Your deposit is too low!");
        
        uint256 newpamt = pamt + leftoverFunds;

        leftoverFunds = 0;
        
        EAProfitCurrentTotal += newpamt;
        

        EAProf storage p = EProf[EAProfitCount];
        uint256 curamt = EAPoolTotal;

        p.eaid = EAProfitCount;
        p.eaamount = newpamt;
        p.eatimestamp = block.timestamp;
        p.eatotalbased= curamt;
        p.eaendtime = block.timestamp.add(profDuration);

        EAProfitCount += 1;

        injectedTotal += newpamt;
        
    }

    function WithdrawMiscProfits() public {

        EaUser storage user = EaUserKey[msg.sender];

        require (user.pendingWithdraw > 0, "no custom profits");

        uint256 tmnt = user.pendingWithdraw;

        user.pendingWithdraw = 0;
        user.entitledAmt = 0;
        user.totalWithdrawn = 0;
        user.entryDate = 0;
        user.wdlist.push(tmnt);

        BUSD.safeTransfer(msg.sender, tmnt);

        addDailyValues();

    }


    function WithdrawEAProfits(uint256 pnum) public {
        
        EaUser storage user = EaUserKey[msg.sender];
        EAProf storage profit = EProf[pnum];

        require (profit.eaendtime > block.timestamp, "Too late to withdraw!");

        uint256 transferamt = calcEAProfits(msg.sender, pnum);

        EaProfTaken[msg.sender][pnum] = true;

        EAPoolTotal -= transferamt;
        EAProfitCurrentTotal -= transferamt;

        profit.eatotalwithdrawn += transferamt;
        profit.eatotalusercount += 1;

        user.totalWithdrawn += transferamt;
        user.wdlist.push(transferamt);

        BUSD.safeTransfer(msg.sender, transferamt);

        addDailyValues();
    } 

    function calcEAProfits(address calcaddy, uint256 profnum) public view returns (uint256) {
        
        EaUser storage user = EaUserKey[calcaddy];
        EAProf storage profit = EProf[profnum];

        uint256 newamt = user.entitledAmt.sub(user.totalWithdrawn);

        uint256 perc = newamt.mul(100000).div(profit.eatotalbased);
        
        uint256 rollamt;

        if (user.entryDate < profit.eatimestamp && EaProfTaken[msg.sender][profnum] == false){
                rollamt += perc.mul(profit.eaamount).div(100000);
            }

        if (rollamt.add(user.totalWithdrawn) >= user.entitledAmt){
            rollamt = user.entitledAmt.sub(user.totalWithdrawn);
        }

        return rollamt;

    }

    function addDailyValues() internal {
        if (block.timestamp.sub(dailyValueTime) > 86400){
            dailyValueArray.push(DailyData({
                dailydate: block.timestamp,
                eapoool: EAPoolTotal,
                injtotal: injectedTotal
            }));
        } 
    }

    function percentageOfPool(uint256 x) public view returns (uint256) {

        uint256 retval = x.mul(1000).div(EAPoolTotal);

        return retval;

    }

    function transferLeftover(uint256 profitnumber) public {

        EAProf storage profit = EProf[profitnumber];

        uint256 tamount;

        if (profit.eaendtime < block.timestamp){
            tamount = profit.eaamount.sub(profit.eatotalwithdrawn);
            profit.eatotalwithdrawn = profit.eaamount;
        }

        leftoverFunds += tamount;
        leftoverFunds += leftoverEAProfs;
        leftoverEAProfs = 0;
    }

    function returnWDList(address waddy) public view returns (uint256 [] memory wlist){

        EaUser storage user = EaUserKey[waddy];

        return user.wdlist;

    }

    function changeProfDuration(uint256 r) public onlyOwner {

        profDuration = r.mul(86400);

    }
}