/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

pragma solidity ^0.8.0;

interface ERC20token {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// interface ERC20token {
//     function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
//     function transfer(address _to, uint256 _value) external returns (bool success);
// }

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20token;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        ERC20token token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        ERC20token token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {ERC20token-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        ERC20token token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        ERC20token token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        ERC20token token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(ERC20token token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender == owner)
            _;
    }

    modifier everyoneElseBesideOwner() {
        if (msg.sender != owner)
            _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) owner = newOwner;
    }
}

contract SafeMath {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract AutoDex is Ownable, SafeMath {

    // using SafeMath for uint256;

    ERC20token public Usdt;
    ERC20token public Token;
    uint256 public pUsdt;
    uint256 public pToken;
    uint256 public pool;
    uint256 public price;
    uint256 private deci = 10 ** 18;
    uint256 public stakeFromBuy = 5;
    
    bool internal locked;

    uint256 public stakingFee; // percentage
    uint256 public unstakingFee; // percentage
    uint256 public round = 1;
    uint256 public totalStakes = 0;
    uint256 public totalDividends = 0;
    uint256 private scaling = 10 ** 10;
    bool public stakingStopped = false;
    address public acceleratorAddress = address(0);

    struct Staker {
        uint256 stakedTokens;
        uint256 round;
        uint256 remainder;
    }

    uint256 public PoolStartTime;
    uint256 public poolCurrentTime;
    bool public timestampSet;
    uint256 public timePeriod;

    mapping(address => Staker) public stakers;
    mapping(uint256 => uint256) public payouts;

    constructor(address _erc20token_address, uint256 _stakingFee, uint256 _unstakingFee, ERC20token _usdt, uint256 _pUsdt, uint256 _pToken) public {

        // Timestamp values not set yet
        timestampSet = true;
        poolCurrentTime = block.timestamp;
        PoolStartTime = block.timestamp;
        timePeriod = block.timestamp;
        // Set the erc20 contract address which this timelock is deliberately paired to
        require(address(_erc20token_address) != address(0), "_erc20_contract_address address can not be zero");
        // Initialize the reentrancy variable to not locked
        locked = false;
        Token = ERC20token(_erc20token_address);
        stakingFee = _stakingFee;
        unstakingFee = _unstakingFee;
        Usdt = _usdt;
        pUsdt = _pUsdt * 10 ** 18;
        pToken = _pToken * 10 ** 18;
        pool = pUsdt * pToken;
        uint256 pSim = pUsdt * 10 ** 18;
        price = pSim/pToken;
    }

    // ==================================== EVENTS ====================================
    event staked(address staker, uint256 tokens, uint256 fee);
    event unstaked(address staker, uint256 tokens, uint256 fee);
    event payout(uint256 round, uint256 tokens, address sender);
    event claimedReward(address staker, uint256 reward);
    event Bought(uint256 amount);
    event Sold(uint256 amount);
    // ==================================== /EVENTS ====================================

    // ==================================== MODIFIERS ====================================
    modifier onlyAccelerator() {
        require(msg.sender == address(acceleratorAddress));
        _;
    }

    modifier checkIfStakingStopped() {
        require(!stakingStopped, "Staking is stopped.");
        _;
    }

        // Modifier
    /**
     * @dev Prevents reentrancy
     */
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    // Modifier
    /**
     * @dev Throws if called by any account other than the owner.
     */
    // modifier onlyOwner() {
    //     require(msg.sender == owner, "Message sender must be the contract's owner.");
    //     _;
    // }

    // Modifier
    /**
     * @dev Throws if timestamp already set.
     */
    modifier timestampNotSet() {
        require(timestampSet == false, "The time stamp has already been set.");
        _;
    }

    // Modifier
    /**
     * @dev Throws if timestamp not set.
     */
    modifier timestampIsSet() {
        require(timestampSet == true, "Please set the time stamp first, then try again.");
        _;
    }
    // ==================================== /MODIFIERS ====================================

    // ==================================== CONTRACT ADMIN ====================================

    function modifyPoolTime(uint256 _timePeriodInSeconds) public onlyOwner  {
        timestampSet = true;
        poolCurrentTime = block.timestamp;
        timePeriod = poolCurrentTime + _timePeriodInSeconds;
    }

    function setStakePercent(uint256 _sharePercent) public onlyOwner {
        require(_sharePercent > 0);
        require(_sharePercent <= 10);
        stakeFromBuy = _sharePercent;
    }

    function stopUnstopStaking() external onlyOwner {
        if (!stakingStopped) {
            stakingStopped = true;
        } else {
            stakingStopped = false;
        }
    }

    function setFees(uint256 _stakingFee, uint256 _unstakingFee) external onlyOwner {
        require(_stakingFee <= 10 && _unstakingFee <= 10, "Invalid fees.");

        stakingFee = _stakingFee;
        unstakingFee = _unstakingFee;
    }

    function setAcceleratorAddress(address _address) external onlyOwner {
        acceleratorAddress = address(_address);
    }
    // ==================================== /CONTRACT ADMIN ====================================

    // ==================================== CONTRACT BODY ====================================
    function stake(uint256 _tokens_amount) external checkIfStakingStopped {
        require(_tokens_amount > 0, "Invalid token amount.");
        require(Token.transferFrom(msg.sender, address(this), _tokens_amount), "Tokens cannot be transferred from sender.");

        uint256 _fee = 0;
        if (totalStakes  > 0) {
            // calculating this user staking fee based on the tokens amount that user want to stake
            _fee = div(mul(_tokens_amount, stakingFee), 100);
            _addPayout(_fee);
        }

        // if staking not for first time this means that there are already existing rewards
        uint256 existingRewards = getPendingReward(msg.sender);
        if (existingRewards > 0) {
            stakers[msg.sender].remainder = add(stakers[msg.sender].remainder, existingRewards);
        }

        // saving user staked tokens minus the staking fee
        stakers[msg.sender].stakedTokens = add(sub(_tokens_amount, _fee), stakers[msg.sender].stakedTokens);
        stakers[msg.sender].round = round;

        // adding this user stake to the totalStakes
        totalStakes = add(totalStakes, sub(_tokens_amount, _fee));

        emit staked(msg.sender, sub(_tokens_amount, _fee), _fee);
    }

    function _stake(uint256 _tokens_amount, uint256 iUsdtamt) internal checkIfStakingStopped {
        require(_tokens_amount > 0, "Invalid token amount.");
        require(Usdt.transferFrom(msg.sender, address(this), iUsdtamt), "Tokens cannot be transferred from sender.");

        uint256 _fee = 0;
        if (totalStakes  > 0) {
            // calculating this user staking fee based on the tokens amount that user want to stake
            _fee = div(mul(_tokens_amount, stakingFee), 100);
            _addPayout(_fee);
        }

        // if staking not for first time this means that there are already existing rewards
        uint256 existingRewards = getPendingReward(msg.sender);
        if (existingRewards > 0) {
            stakers[msg.sender].remainder = add(stakers[msg.sender].remainder, existingRewards);
        }

        // saving user staked tokens minus the staking fee
        stakers[msg.sender].stakedTokens = add(sub(_tokens_amount, _fee), stakers[msg.sender].stakedTokens);
        stakers[msg.sender].round = round;

        // adding this user stake to the totalStakes
        totalStakes = add(totalStakes, sub(_tokens_amount, _fee));

        emit staked(msg.sender, sub(_tokens_amount, _fee), _fee);
    }

    function acceleratorStake(uint256 _tokens_amount, address _staker) external checkIfStakingStopped onlyAccelerator {
        require(acceleratorAddress != address(0), "Invalid address.");
        require(_tokens_amount > 0, "Invalid token amount.");
        require(Token.transferFrom(msg.sender, address(this), _tokens_amount), "Tokens cannot be transferred from sender.");

        uint256 _fee = 0;
        if (totalStakes  > 0) {
            // calculating this user staking fee based on the tokens amount that user want to stake
            _fee = div(mul(_tokens_amount, stakingFee), 100);
            _addPayout(_fee);
        }

        // if staking not for first time this means that there are already existing rewards
        uint256 existingRewards = getPendingReward(_staker);
        if (existingRewards > 0) {
            stakers[_staker].remainder = add(stakers[_staker].remainder, existingRewards);
        }

        // saving user staked tokens minus the staking fee
        stakers[_staker].stakedTokens = add(sub(_tokens_amount, _fee), stakers[_staker].stakedTokens);
        stakers[_staker].round = round;

        // adding this user stake to the totalStakes
        totalStakes = add(totalStakes, sub(_tokens_amount, _fee));

        emit staked(_staker, sub(_tokens_amount, _fee), _fee);
    }

    function claimReward() external {
        uint256 pendingReward = getPendingReward(msg.sender);
        if (pendingReward > 0) {
            stakers[msg.sender].remainder = 0;
            stakers[msg.sender].round = round; // update the round

            require(Token.transfer(msg.sender, pendingReward), "ERROR: error in sending reward from contract to sender.");

            emit claimedReward(msg.sender, pendingReward);
        }
    }

    function unstake(uint256 _tokens_amount) external {
        require(_tokens_amount > 0 && stakers[msg.sender].stakedTokens >= _tokens_amount, "Invalid token amount to unstake.");

        

        stakers[msg.sender].stakedTokens = sub(stakers[msg.sender].stakedTokens, _tokens_amount);
        stakers[msg.sender].round = round;

        // calculating this user unstaking fee based on the tokens amount that user want to unstake
        uint256 _fee = div(mul(_tokens_amount, unstakingFee), 100);

        if (block.timestamp >= timePeriod) {
        // sending to user desired token amount minus his unstacking fee
        require(Token.transfer(msg.sender, sub(_tokens_amount, _fee)), "Error in unstaking tokens.");
        } else {
            revert("Tokens are only available after correct time period has elapsed");
        }
        totalStakes = sub(totalStakes, _tokens_amount);
        if (totalStakes > 0) {
            _addPayout(_fee);
        }

        emit unstaked(msg.sender, sub(_tokens_amount, _fee), _fee);
    }

    function addRewards(uint256 _tokens_amount) external checkIfStakingStopped {
        require(Token.transferFrom(msg.sender, address(this), _tokens_amount), "Tokens cannot be transferred from sender.");
        _addPayout(_tokens_amount);
    }

    function _addPayout(uint256 _fee) private {
        uint256 dividendPerToken = div(mul(_fee, scaling), totalStakes);
        totalDividends = add(totalDividends, dividendPerToken);
        payouts[round] = add(payouts[round-1], dividendPerToken);
        round+=1;

        emit payout(round, _fee, msg.sender);
    }

    function getPendingReward(address _staker) public view returns(uint256) {
        uint256 amount = mul((sub(totalDividends, payouts[stakers[_staker].round - 1])), stakers[_staker].stakedTokens);
        return add(div(amount, scaling), stakers[_staker].remainder);
    }
    // ===================================== DEX BODY =====================================


        function swapusdTforToken(uint256 iUsdt, uint256 slippage) public {
        require(slippage > 0 );
        require(slippage < 46);
        require(iUsdt > 0);

        simulate(iUsdt, slippage);
        // uint256 amt = simulate(iUsdt, slippage);
        // processStake(iUsdt, amt);
        
    }

    function simulate(uint256 iUsdt, uint256 tolerance) internal {
        uint256 nUsdt = add(pUsdt, iUsdt);
        uint256 nToken = div(pool, nUsdt);
        
        uint256 amtofTokens = sub(pToken, nToken);
        pUsdt = nUsdt;
        pToken = nToken;
        calcPimpact(nUsdt, tolerance, nToken);
        processStake(iUsdt, amtofTokens);


    }
    function calcPimpact(uint256 input, uint256 slippage, uint256 newtoken) internal {
        uint256 nSim = mul(input, deci);
        uint256 nPrice = div(nSim, newtoken);
        uint256 pDiff = sub(nPrice, price);
        uint256 diffSim = mul(pDiff, deci);
        uint256 pImpact = div(diffSim, price);
        uint256 PriceImpact = mul(pImpact, 100);
        price = nPrice;
        uint256 tSlippage = mul(slippage, deci);
       if (PriceImpact > tSlippage) {
           revert ('Price Impact too high');
    }

    }

    function processStake(uint256 input, uint256 amtofTokens) internal {

        uint256 stakePercent = amtofTokens/100;
        uint256 stakeRatio = stakePercent * stakeFromBuy;
        uint256 amtToSend = amtofTokens - stakeRatio;
        uint256 amountToStake = amtofTokens - amtToSend;

        _stake(amountToStake, input);
        Token.transfer(msg.sender, amtToSend);
        emit Bought(amtToSend);
    }
    
    function swapTokenforusd(uint256 iTokenamt, uint256 slippage) external {
        require(slippage > 0 );
        require(slippage < 46);
        require(iTokenamt > 0);

        uint256 nToken = pToken + iTokenamt;
        uint256 nUsdt = pool/nToken;
        uint256 nSim = nUsdt * deci;
        uint256 nPrice = nSim/nToken;
        uint256 pDiff = price - nPrice;
        uint256 diffSim = pDiff * deci;
        uint256 pImpact = diffSim/price;
        uint256 PriceImpact = pImpact * 100;
        uint256 amtToSend = pUsdt - nUsdt;
        uint256 tSlippage = slippage * deci;

        price = nPrice;
        pUsdt = nUsdt;
        pToken = nToken;

       if (PriceImpact > tSlippage) {
           revert ('Price Impact too high');
       } else {
           Token.transferFrom(msg.sender, address(this), iTokenamt);
           Usdt.transfer(msg.sender, amtToSend);
           emit Sold(amtToSend);
       }
        
    }
}