/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

pragma solidity ^0.8.11;
pragma experimental ABIEncoderV2;

interface IERC20 {

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

library AddressUpgradeable {
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

/**
 * @dev Provides the msg.sender in the current execution context.
 */
abstract contract ContextSimpleUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    uint256[50] private __gap;
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableSafeUpgradeable is Initializable, ContextSimpleUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract SSSStaking is Initializable, OwnableSafeUpgradeable {

    struct Stake {
        uint256 amount;
        uint40 startTimestamp;
    }
    
    mapping(address => Stake[]) public allStakes;

    mapping(address => uint256) public stakeCount;

    mapping(address => uint256) public stakerID;

    address[] stakers;

    uint256 public cliff;
    uint256 public vaultAvailableBalance;

    uint256 private constant MAX = ~uint256(0);

    uint40 constant ONE_DAY = 60 * 60 * 24;
    uint40 constant ONE_YEAR = ONE_DAY * 365;

    IERC20 public SSS;

    event StakeBegan (
        uint256 indexed stakeID,
        address indexed staker,
        uint256 amount,
        uint40 startTimestamp
    );

    event StakeEnded (
        uint256 indexed stakeID,
        address indexed staker,
        uint256 rewardPaid,
        uint256 endTimestamp
    );

    function initialize(address _immutableSSS) public initializer {
        __Ownable_init_unchained();
        __SSSStaking_init_unchained(_immutableSSS);
    }

    function __SSSStaking_init_unchained(address _immutableSSS) internal initializer {
        SSS = IERC20(_immutableSSS);
        cliff = 30;
    }

    function setCliff(uint256 _days) external onlyOwner { 
        cliff = _days * ONE_DAY;
    }

    function stake(
        uint256 _amount
    )
        external
    {
        stakeFor(_msgSender(), _amount);
    }

    function stakeFor(
        address _account,
        uint256 _amount
    )
        private
    {
        require(_amount > 0, "SSS-Stake: Amount cannot be zero");
        
        vaultAvailableBalance += _amount;

        SSS.transferFrom(
            _account,
            address(this),
            _amount
        );

        uint40 blockTimestamp = uint40(block.timestamp);

        Stake memory newStake = Stake(
            _amount,
            blockTimestamp
        );

        if (stakeCount[_account] == 0) {
            stakers.push(_account);
            stakerID[_account] = stakers.length - 1;
        }

        allStakes[_account].push(newStake);
        stakeCount[_account] = allStakes[_account].length;

        emit StakeBegan(
            stakeCount[_account] - 1,
            _account,
            newStake.amount,
            newStake.startTimestamp
        );
    }

    function unstake(
        uint256 _stakeID,
        uint256 _amount
    )
        external
    {
        unstakeFor(_msgSender(), _stakeID, _amount);
    }

    function unstakeFor(
        address _account,
        uint256 _stakeID,
        uint256 _amount
    )
        private
    {
        require(_stakeID < allStakes[_account].length, "SSS-Stake: Index is out of range");

        Stake storage selected = allStakes[_account][_stakeID];

        require(
            block.timestamp - selected.startTimestamp >= cliff,
            "SSS-Stake: Cliff is not reached"
        );
        require(_amount <= available(_account, _stakeID), "SSS-Stake: Amount exceeds available");

        (uint256 reward,) = calculateReward(_account, _stakeID, _amount);
        
        vaultAvailableBalance -= _amount;

        SSS.transfer(
            _account,
            _amount + reward    
        );

        selected.amount -= _amount;

        if (selected.amount == 0) {
            Stake[] memory stakes = allStakes[_account];
            allStakes[_account][_stakeID] = stakes[stakes.length - 1];
            allStakes[_account].pop();
            stakeCount[_account] -= 1;
        } else {
            _resetTimeStamp(_account, _stakeID);
        }

        if (stakeCount[_account] == 0) {
            uint256 length = stakers.length;
            uint256 index = stakerID[_account];
            address last = stakers[length - 1];
            stakers[index] = last;
            stakerID[_account] = MAX;
            stakerID[last] = index;
            stakers.pop();
        }

        emit StakeEnded(
            _stakeID,
            _account,
            reward,
            block.timestamp
        );
    }

    function stakeInfo(
        address _staker,
        uint256 _stakeID
    )
        external
        view
        returns (
            uint256 amount,
            uint40 startTimestamp,
            uint40 currentTimestamp,
            uint40 lockedDays
        )
    {
        Stake memory selected = allStakes[_staker][_stakeID];

        amount = selected.amount;
        uint40 blockTimeStamp = uint40(block.timestamp);
        lockedDays = (blockTimeStamp - selected.startTimestamp) / ONE_DAY;
        startTimestamp = selected.startTimestamp;
        currentTimestamp = blockTimeStamp;
    }

    function available(
        address _account,
        uint256 _stakeID    
    )
        public
        view
        returns (uint256)
    {
        Stake memory selected = allStakes[_account][_stakeID];
        if (block.timestamp - selected.startTimestamp < cliff) {
            return 0;
        }
        return selected.amount;
    }

    function _stakeRewardableDuration(
        Stake memory _stake
    )
        private
        view
        returns (uint256 duration)
    {
        duration = block.timestamp - _stake.startTimestamp;
    }

    function _getValues() private view returns (uint256, uint256, uint256) {
        uint256 totalTimeStamp;
        uint256 totalBagSize;
        uint256 longestTimeStaked;
        uint256 length = stakers.length;
        
        for (uint256 i = 0 ; i < length ; i ++) {
            address account = stakers[i];
            uint256 count = stakeCount[account];
            for (uint256 j = 0 ; j < count ; j ++) {
                Stake memory selected = allStakes[account][j];
                uint256 duration = _stakeRewardableDuration(selected);

                if (duration > longestTimeStaked)
                    longestTimeStaked = duration;

                totalTimeStamp += duration;
                totalBagSize += selected.amount;
            }
        }

        return (totalTimeStamp, totalBagSize, longestTimeStaked);
    }

    function calculateReward(
        address _account,
        uint256 _stakeID,
        uint256 _amount
    )
        public
        view
        returns (uint256 reward, uint256 longestTimeStaked)
    {
        if (stakeCount[_account] == 0) {
            reward = 0;
            return (reward, 0);
        }
            
        (uint256 totalTimeStamp, uint256 totalBagSize, uint256 longestTS) = _getValues();
        Stake memory selected = allStakes[_account][_stakeID];
        if (_amount == 0)
            _amount = selected.amount;

        uint256 duration = _stakeRewardableDuration(selected);
        uint256 volume = SSS.balanceOf(address(this));
        uint256 totalRewards = volume - vaultAvailableBalance;
        uint256 rewardForTimeStamp = totalRewards * duration / totalTimeStamp;
        uint256 rewardForBagSize = totalRewards * _amount / totalBagSize;
        reward = (rewardForTimeStamp + rewardForBagSize) / 2;
        longestTimeStaked = longestTS;
    }

    function _resetTimeStamp(
        address _account,
        uint256 _stakeID
    )
        private
    {
        Stake storage selected = allStakes[_account][_stakeID];
        selected.startTimestamp = uint40(block.timestamp);
    }

    function claimTokens(address walletaddress) external onlyOwner() {
        SSS.transfer(walletaddress, SSS.balanceOf(address(this)));
    }
}