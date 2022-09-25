// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

// File: @openzeppelin/contracts/math/Math.sol

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// File: @openzeppelin/contracts/GSN/Context.sol

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/ownership/Ownable.sol
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);
    function mint(address account, uint amount) external;

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/utils/Address.sol

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * Available since v2.4.0.
     */
    function toPayable(address account) internal pure returns (address payable) {
        return payable(address(uint160(account)));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * Available since v2.4.0.
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        // (bool success, ) = recipient.call.value(amount)("");
        (bool success, ) = recipient.call{value:amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) - value;
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract TraderDAO is Ownable{
    using SafeERC20 for IERC20;
    using Address for address;
    
    uint public PoolId = 0;
    uint public PoolIdCounter = 0;
    uint public TotalFund = 0;
    uint public MovingPointer = 0;
    uint public PointerBalance = 0;
    bool public End = false;
    
    // mapping(uint => mapping(uint => address)) public PoolData;  // PoolId => SubPoolId => UserAddress
    // mapping(address => mapping(uint => uint)) public UserInPool; // UserAddress => PoolId => SubPoolId
    mapping(uint => address) public UserList; // Counter => UserAddress
    mapping(uint => uint) public UserStakeAmount; // Counter => UserStakeAmount
    mapping(uint => uint) public PoolTotalCapital; // PoolId => TotalCount
    mapping(uint => uint) public PoolPayoutTimestamp; // PoolId => PayoutTime
    mapping(uint => bool) public PoolReadyToPayout; // PoolIdCounter => Ready To Payout
    mapping(uint => uint) public PoolIdStart;
    mapping(uint => uint) public PoolIdEnd;
    mapping(uint => uint) public PoolTradeAmount;

    mapping(uint => uint) public PoolRealizedAmount;
    mapping(uint => uint) public UserReliazedAmount;
    mapping(uint => uint) public PoolRewardCounter;
    mapping(uint => bool) public PoolRewardDistributed;
    mapping(uint => bool) public PoolAPYUpdated;
    mapping(address => bool) public UserReinvestStatus;
    mapping(uint => bool) public EndByOwner;
    mapping(uint => bool) public PoolProfited;
    
    uint public PlatformFee = 50;
    uint public ProfitSharing = 500;
    mapping(uint => uint) public PoolDataARPPercentage; // PoolId => PoolPercentage
    uint16 public Denominator = 1000;

    mapping(address => uint) public UserCapitalAmountLock;
    mapping(address => mapping(uint => uint)) public UserRewardAmount;
    mapping(address => uint) public UserAmountToClaim;
    
    address public PlatformAccount;
    address public TraderAccount;
    IERC20 public USDT;
    
    event TradeStarted(uint indexed _poolid, uint indexed _endtime, uint indexed _amount);
    event UserDeposit(address indexed _address, uint indexed _poolid, uint indexed _amount);
    event RewardAmount(address indexed _address, uint indexed _poolid, uint indexed _subpoolid);
    event RewardClaimed(address indexed _address, uint indexed _amount);
    event UpdateFee(uint indexed _newFee);
    event UpdateProfitSharing(uint indexed _profitSharing);
    event SetReinvest(address indexed _address, bool indexed _reinvestStatus);

    constructor(){
        PlatformAccount = 0x74eB85BcF3BA51dBbF1fA0973a8DaF74A70b44d7;
        TraderAccount = 0x12Be2198D17a9ce2Fc56Ac28feA7481Da78247d0;
        USDT = IERC20(0xc57E7901308DBDc56885Ac9CbADb3e25643474Ae);
    }
    
    function Deposit(uint amount) public{
        require(End == false, "Pool end");

        USDT.safeTransferFrom(msg.sender, address(this), amount);
        uint fee = CalculateFee(amount);
        USDT.safeTransfer(PlatformAccount, fee);
        USDT.safeTransfer(TraderAccount, amount - fee);

        Insert(msg.sender, amount - fee);
        
        emit UserDeposit(msg.sender, PoolIdCounter, amount - fee);
    }

    function Insert(address userAddress, uint amount) public{
        PoolIdCounter++;
        UserList[PoolIdCounter] = userAddress;
        UserStakeAmount[PoolIdCounter] = amount;
        TotalFund = TotalFund + amount;
    }

    function StartTrade(uint _amount, uint _payoutTimeStamp) external onlyOwner{
        require(_amount <= TotalFund, "Insufficient Fund");
        PoolId++;
        PoolPayoutTimestamp[PoolId] = _payoutTimeStamp;
        PoolTradeAmount[PoolId] = _amount;
        
        if(PointerBalance > _amount){
            PointerBalance = PointerBalance - _amount;
            PoolIdStart[PoolId] = MovingPointer;
            PoolIdEnd[PoolId] = MovingPointer;
        }
        else{
            PoolIdStart[PoolId] = MovingPointer;
            if(PoolIdStart[PoolId] == 0){
                PoolIdStart[PoolId] = 1;
            }
            
            uint tempamount = 0 ;
            if(PointerBalance > 0){
                tempamount = _amount - PointerBalance;
            }
            uint sumdeposit = 0;
            while(_amount > sumdeposit){
                MovingPointer++;
                sumdeposit = sumdeposit + UserStakeAmount[MovingPointer];
            }

            if(sumdeposit > _amount){
                PointerBalance = sumdeposit - _amount;
            }

            if(PointerBalance == 0){
                MovingPointer++;
                PointerBalance = UserStakeAmount[MovingPointer];
            }

            PoolIdEnd[PoolId] = MovingPointer;
            TotalFund = TotalFund - _amount;
        }

        emit TradeStarted(PoolId, _payoutTimeStamp, _amount);
    }


    function UpdateAPY(uint _poolid, uint _depositamount) external onlyOwner{
        // DistributeReward(_poolid, _depositamount);
    }

    function CheckPoolPayout(uint _poolid) external view returns(uint[3] memory returnValue){
        returnValue[0] = PoolIdStart[_poolid];
        returnValue[1] = PoolIdEnd[_poolid];
        returnValue[2] = PoolIdEnd[_poolid] - PoolIdStart[_poolid]; 
    }

    function DistributeReward(uint _poolid, uint[] memory _ids, uint[] memory _amounts) external onlyOwner{
        require(PoolRealizedAmount[_poolid] == 0, "Already Distributed");
        require(_ids.length == _amounts.length, "Number of ids and amounts should be same");
        uint sum = 0;
        uint i = _ids[0];
        for(i; i<_ids.length; i++) {
            UserReliazedAmount[i] = UserReliazedAmount[i] + _amounts[i];
            UserAmountToClaim[UserList[i]] = UserAmountToClaim[UserList[i]] + _amounts[i];
            sum = sum + _amounts[i];
        }
        PoolRealizedAmount[_poolid] = sum;
    }

    // function DistributeReward(uint _poolid, uint _counter, uint _depositamount) public onlyOwner{
    //     require(PoolRewardDistributed[_poolid] == false, "Pool Reward Distribution Completed");
    //     if(PoolRewardAmount[_poolid] == 0){
    //         PoolRewardAmount[_poolid] = _depositamount;
    //         if(PoolRewardAmount[_poolid] > PoolTotalStakeAmount[_poolid]){
    //             PoolProfited[_poolid] = true;
    //         }
    //     }
        
    //     uint i = PoolRewardCounter[_poolid];
    //     if(i == 0){
    //         i = 1;
    //     }
            
    //     for(i; i <= _counter; i++){
    //         address useraddress = PoolData[_poolid][i];
    //         if(UserReinvestStatus[useraddress] == true){

    //             uint poolTotal = PoolTotalStakeAmount[_poolid];
    //             uint poolReward = PoolRewardAmount[_poolid];
    //             uint userstakeamount = UserStakeAmount[useraddress][_poolid];
    //             uint rewardBeforeFee = CalculateReward(poolTotal, poolReward, userstakeamount);
                
    //             if(PoolProfited[_poolid] == true){
    //                 uint profitToTax = ProfitToShare(rewardBeforeFee, userstakeamount);
    //                 USDT.transfer(PlatformAccount, profitToTax);
    //                 UserRewardAmount[useraddress][_poolid] = rewardBeforeFee - profitToTax;
    //             }
    //             else{
    //                 UserRewardAmount[useraddress][_poolid] = rewardBeforeFee;
    //             }

    //             UserRewardAmount[useraddress][_poolid] = UserRewardAmount[useraddress][_poolid];
    //             Deposit(UserRewardAmount[useraddress][PoolId]);
    //             emit RewardAmount(useraddress, _poolid, UserRewardAmount[useraddress][_poolid]);
    //         }
    //     }
    //     PoolRewardCounter[_poolid] = PoolRewardCounter[_poolid] + _counter;
    //     if(PoolRewardCounter[_poolid] == PoolTotalDepositor[_poolid]){
    //         PoolRewardDistributed[_poolid] = true;
    //     }
    // }

    // function ProfitToShare(uint rewardamount, uint stakeamount) public view returns (uint){
    //     return (rewardamount - stakeamount) * ProfitSharing / Denominator;
    // }

    // function CalculateReward(uint pooltotal, uint poolreward, uint stakeamount) public pure returns(uint){
    //     uint percent = poolreward * 10 ** 6 / pooltotal;
    //     uint reward = stakeamount * percent / 10 ** 6;
    //     return reward;
    // }

    function CalculateFee(uint _amount) public view returns(uint){
        return _amount * PlatformFee / Denominator;
    }

    // function CalculateReward(address _useraddress, uint _poolid) public view returns(uint){
    //     uint poolTotal = PoolTotalStakeAmount[_poolid];
    //     uint poolReward = PoolRewardAmount[_poolid];
    //     uint userstakeamount = UserStakeAmount[_useraddress][_poolid];
    //     uint percent = poolReward * 10 ** 6 / poolTotal;
    //     uint reward = userstakeamount * percent / 10 ** 6;
    //     return reward;
    // }

    function OwnerEndPool() external onlyOwner{
        EnablePool(true);
        
        //Loop and distribute token back to users

    }

    function EnablePool(bool _status) public onlyOwner{
        End = _status;
    }
    
    function Claim() external{
        require(UserAmountToClaim[msg.sender] > 0, "No amount to claim.");
        uint amount = UserAmountToClaim[msg.sender];
        UserAmountToClaim[msg.sender] = 0;
        USDT.safeTransfer(msg.sender, amount);
        emit RewardClaimed(msg.sender, amount);
    }

    // function Claim() public{
    //     //Check if user can payout
    //     require(UserAmountToClaim[msg.sender] != 0, "No Amount To Claim");
        
    //     USDT.safeTransfer(msg.sender, UserAmountToClaim[msg.sender]);
    //     UserAmountToClaim[msg.sender] = 0;

    //     emit RewardClaimed(msg.sender, UserAmountToClaim[msg.sender]);
    // }
    
    function SetFee(uint _fee) external onlyOwner{
        PlatformFee = _fee;
        emit UpdateFee(_fee);
    }

    function SetProfitSharing(uint _profitSharing) external onlyOwner{
        ProfitSharing = _profitSharing;
        emit UpdateProfitSharing(_profitSharing);
    }

    function SetPlatfrom(address _address) external onlyOwner{
        PlatformAccount = _address;
    }

    function EnableReinvest(bool _status) external{
        UserReinvestStatus[msg.sender] = _status;

        emit SetReinvest(msg.sender, _status);
    }

    function ImmediatePayoutTest(uint _poolId) external onlyOwner{
        PoolPayoutTimestamp[_poolId] = block.timestamp; 
    }
}