// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/cryptography/MerkleProof.sol";
import "./interfaces/ILotteryDao.sol";

contract LotteryDao is ILotteryDao, OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using MerkleProof for bytes32[];

    bytes32 public _whitelistRoot;

    uint256 internal MULTIPLIER;

    uint256 public poolId;
    mapping(uint256 => PoolInfo) public poolInfo;

    modifier checkPoolId(uint256 _poolId) {
        require(_poolId < poolId, "invalid PoolId");
        _;
    }

    modifier checkWinner(
        uint256 _poolId,
        address _addr,
        bytes32[] calldata _whitelistProof,
        uint256 _tickets
    ) {
        require(
            verifyWhitelist(_addr, _poolId, _tickets, _whitelistProof),
            "not a winner"
        );
        _;
    }

    function initialize() public initializer {
        __Ownable_init();
        MULTIPLIER = 1e18;
    }

    function setWhitelistRoot(bytes32 merkleRoot) external onlyOwner {
        _whitelistRoot = merkleRoot;
    }

    function isWinner(uint256 _poolId) internal view returns (bool) {
        PoolInfo storage _poolInfo = poolInfo[_poolId];
        UserInfo memory _userInfo = _poolInfo.userdata[msg.sender];

        if (_userInfo.isRegistered && _userInfo.tickets > 0) return true;
        return false;
    }

    function addPool(InitialInfo memory _info) external onlyOwner {
        require(_info.totalRaise > 0, "totalRaise should greater than 0");
        require(
            _info.winningTickets > 0,
            "_winningTickets should greater than 0"
        );
        require(_info.beneficiary != address(0), "token address cant be 0");
        require(_info.tokenPrice > 0, "invalid token price");
        require(_info.teamTokenPrice > 0, "invalid token price");
        require(_info.teamToken != address(0), "_teamToken address cant be 0");
        require(_info.token != address(0), "token address cant be 0");
        require(
            block.timestamp < _info.openTime,
            "_openTime should be greater than openTime"
        );
        require(
            _info.openTime < _info.endTime,
            "_lotteryOpenTime should be greater than _openTime"
        );

        PoolInfo storage pool = poolInfo[poolId];
        pool.info = _info;

        poolId += 1;

        emit AddedPool(poolId, _info);
    }

    function updateBeneficiary(uint256 _poolId, address _beneficiary)
        external
        onlyOwner
        checkPoolId(_poolId)
    {
        PoolInfo storage _poolInfo = poolInfo[_poolId];
        require(
            _beneficiary != address(0),
            "updateBeneficiary: _beneficiary address cant be 0"
        );
        require(
            _poolInfo.info.beneficiary == msg.sender,
            "updateBeneficiary: not a beneficiary"
        );

        _poolInfo.info.beneficiary = _beneficiary;

        emit UpdateBeneficiary(_poolId, _beneficiary);
    }

    // Owner can set new Times
    function setTimes(
        uint256 _poolId,
        uint256 _openTime,
        uint256 _endTime
    ) external onlyOwner checkPoolId(_poolId) {
        require(
            block.timestamp < _openTime,
            "currentTime should be greater than openTime"
        );
        require(
            _openTime < _endTime,
            "_lotteryOpenTime should be greater than endTime"
        );

        PoolInfo storage pool = poolInfo[_poolId];
        pool.info.openTime = _openTime;
        pool.info.endTime = _endTime;

        emit SetTimes(_poolId, _openTime, _endTime);
    }

    function setPrices(
        uint256 _poolId,
        uint256 _tokenPrice,
        uint256 _teamTokenPrice
    ) external onlyOwner checkPoolId(_poolId) {
        PoolInfo storage pool = poolInfo[_poolId];
        require(
            block.timestamp < pool.info.openTime,
            "_openTime should be greater than openTime"
        );

        pool.info.tokenPrice = _tokenPrice;
        pool.info.teamTokenPrice = _teamTokenPrice;

        emit SetPrice(_poolId, _tokenPrice, _teamTokenPrice);
    }

    function withdrawFunds(uint256 _poolId) external checkPoolId(_poolId) {
        PoolInfo storage pool = poolInfo[_poolId];
        require(
            pool.info.beneficiary == msg.sender,
            "withdrawFunds: not a beneficiary"
        );
        require(
            block.timestamp >= pool.info.endTime,
            "withdrawFunds: not finished yet"
        );
        require(
            IERC20Upgradeable(pool.info.token).balanceOf(address(this)) > 0,
            "withdrawFunds: insufficient balance"
        );
        IERC20Upgradeable(pool.info.token).transfer(
            pool.info.beneficiary,
            pool.poolRaise
        );

        emit WithdrawFunds(_poolId, msg.sender, pool.poolRaise);
    }

    function setMinAllocation(uint256 _poolId, uint256 _amount)
        external
        checkPoolId(_poolId)
    {
        PoolInfo storage pool = poolInfo[_poolId];
        require(
            block.timestamp <= pool.info.openTime,
            "setMinAllocation: can set min allocation before lottery open Time"
        );

        pool.minAllocation = _amount;

        emit SetMinAllocation(_poolId, _amount);
    }

    function setMaxAllocation(uint256 _poolId, uint256 _amount)
        external
        checkPoolId(_poolId)
    {
        PoolInfo storage pool = poolInfo[_poolId];
        require(
            block.timestamp <= pool.info.openTime,
            "setMinAllocation: can set max allocation before lottery open Time"
        );

        pool.maxAllocation = _amount;

        emit SetMinAllocation(_poolId, _amount);
    }

    function lotteryRegistry(uint256 _poolId) external checkPoolId(_poolId) {
        PoolInfo storage pool = poolInfo[_poolId];

        UserInfo storage userdata = pool.userdata[msg.sender];
        bool isRegistered = userdata.isRegistered;

        require(
            block.timestamp <= pool.info.openTime,
            "lottery Already started"
        );
        require(!isRegistered, "already registered");
        userdata.isRegistered = true;

        pool.registeredUsers.push(msg.sender);

        emit LotteryRegistry(_poolId);
    }

    function registeredUsersInfo(uint256 _poolId, address _user)
        public
        view
        returns (address, uint256)
    {
        PoolInfo storage pool = poolInfo[_poolId];
        if (pool.ticketPrice > 0) {
            uint256 balance = IERC20Upgradeable(pool.info.token).balanceOf(
                _user
            );
            return (_user, balance / pool.ticketPrice);
        } else {
            return (_user, 0);
        }
    }

    function setTicketAllocation(uint256 _poolId, uint256 _amount)
        external
        onlyOwner
        checkPoolId(_poolId)
    {
        PoolInfo storage pool = poolInfo[_poolId];

        pool.ticketAllocation = _amount;

        emit SetTicketAllocation(_poolId, _amount);
    }

    function setTicketPrice(uint256 _poolId, uint256 _amount)
        external
        onlyOwner
        checkPoolId(_poolId)
    {
        PoolInfo storage pool = poolInfo[_poolId];

        pool.ticketPrice = _amount;

        emit SetTicketPrice(_poolId, _amount);
    }

    function participate(
        uint256 _poolId,
        uint256 _amount,
        bytes32[] calldata _whitelistProof,
        uint256 _tickets
    )
        external
        checkPoolId(_poolId)
        checkWinner(_poolId, msg.sender, _whitelistProof, _tickets)
    {
        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage userdata = pool.userdata[msg.sender];

        pool.participatedAmount += _amount;
        userdata.participatedAmount += _amount;

        require(
            userdata.participatedAmount <= _tickets.mul(pool.ticketPrice),
            "participate: reached to limit"
        );
        require(
            userdata.participatedAmount.mul(pool.info.tokenPrice).div(
                MULTIPLIER
            ) >= pool.minAllocation
        );
        require(
            userdata.participatedAmount.mul(pool.info.tokenPrice).div(
                MULTIPLIER
            ) <= pool.maxAllocation
        );
        require(
            pool.participatedAmount.mul(pool.info.tokenPrice).div(MULTIPLIER) <=
                pool.info.totalRaise,
            "participate: POOL FILLED"
        );

        IERC20Upgradeable(pool.info.token).transferFrom(
            msg.sender,
            address(this),
            _amount
        );

        emit Participated(_poolId, _amount, msg.sender);
    }

    function lock(
        uint256 _poolId,
        address _token,
        uint256 _lock,
        uint256[] memory _percentages,
        uint256[] memory _vestingsPeriods,
        uint256 _allocAmount
    ) external onlyOwner {
        require(_token != address(0), "Lock: token address can't be 0");
        require(
            _vestingsPeriods.length == _percentages.length,
            "Lock: Input arrary lengths mismatch"
        );
        PoolInfo storage pool = poolInfo[_poolId];

        require(
            block.timestamp >= pool.info.endTime,
            "Lock: Pool not ended yet"
        );

        uint256 totalPercentages;
        for (uint256 i = 0; i < _percentages.length; i++) {
            totalPercentages = totalPercentages.add(_percentages[i]);
        }
        require(
            totalPercentages == 100,
            "deposit: sum of percentages should be 100"
        );

        require(
            pool.vestingAmount > 0,
            "deposit: must lock more than 0 tokens"
        );

        pool.vest.depositTime = block.timestamp;
        pool.vest.vestingPercentages = _percentages;
        pool.vest.vestingPeriods = _vestingsPeriods;
        pool.vestingAmount = _allocAmount;
        pool.vest.lock = _lock;

        IERC20Upgradeable token = IERC20Upgradeable(pool.info.teamToken);
        token.safeTransferFrom(
            address(msg.sender),
            address(this),
            pool.vestingAmount
        );

        emit Lock(_poolId, _token, _lock, _percentages, _vestingsPeriods);
    }

    function withdraw(
        uint256 _poolId,
        uint256 _tickets,
        bytes32[] calldata _whitelistProof
    ) external {
        require(
            verifyWhitelist(msg.sender, _poolId, _tickets, _whitelistProof),
            "not a winner"
        );

        uint256 vestableAmount = _calcVestableAmount(_poolId);

        PoolInfo storage pool = poolInfo[_poolId];

        IERC20Upgradeable token = IERC20Upgradeable(pool.info.teamToken);
        uint256 transferAmount = (vestableAmount * _tickets) /
            pool.ticketAllocation;

        pool.userdata[msg.sender].withdrawAmount += transferAmount;

        token.safeTransfer(address(msg.sender), transferAmount);

        emit Withdraw(_poolId, transferAmount, address(msg.sender));
    }

    function _calcVestableAmount(uint256 _poolId)
        public
        view
        returns (uint256)
    {
        if (_poolId >= poolId) {
            return 0;
        }

        PoolInfo storage pool = poolInfo[_poolId];

        uint256 currentVesting = pool.vest.depositTime + pool.vest.lock;

        if (block.timestamp <= currentVesting) {
            return 0;
        }

        uint256 currentVestingIndex;
        uint256 vestableAmount;
        uint256[] memory vestingPeriods = pool.vest.vestingPeriods;
        uint256[] memory vestingPercentages = pool.vest.vestingPercentages;
        for (uint256 i = 0; i < vestingPeriods.length; i++) {
            currentVestingIndex = i;
            if (currentVesting.add(vestingPeriods[i]) < block.timestamp) {
                currentVesting = currentVesting.add(vestingPeriods[i]);
                vestableAmount +=
                    (pool.vestingAmount * pool.vest.vestingPercentages[i]) /
                    100;
            } else {
                break;
            }
        }

        uint256 timePassed;
        if (currentVestingIndex < pool.vest.vestingPeriods.length) {
            timePassed = block.timestamp.sub(currentVesting);

            if (timePassed > vestingPeriods[currentVestingIndex]) {
                timePassed = vestingPeriods[currentVestingIndex];
            }
        }

        vestableAmount += timePassed
            .mul(pool.vestingAmount)
            .mul(vestingPercentages[currentVestingIndex])
            .div(vestingPeriods[currentVestingIndex])
            .div(100);
        return vestableAmount;
    }

    function verifyWhitelist(
        address user,
        uint256 _poolId,
        uint256 tickets,
        bytes32[] calldata whitelistProof
    ) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(user, _poolId, tickets));
        return whitelistProof.verify(_whitelistRoot, leaf);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";

interface ILotteryDao {
    struct InitialInfo {
        uint256 totalRaise;
        uint256 winningTickets;
        address beneficiary;
        uint256 openTime;
        uint256 endTime;
        address token;
        uint256 tokenPrice;
        address teamToken;
        uint256 teamTokenPrice;
    }

    struct PoolInfo {
        InitialInfo info;
        VestingInfo vest;
        uint256 poolId;
        bytes32 blockHash;
        uint256 minTickets;
        address[] registeredUsers;
        address[] winners;
        uint256 ticketAllocation;
        uint256 ticketPrice;
        uint256 poolRaise;
        uint256 minAllocation;
        uint256 maxAllocation;
        uint256 vestingAmount;
        uint256 participatedAmount;
        mapping(address => UserInfo) userdata;
        mapping(uint256 => uint256) additionTickets;
    }

    struct VestingInfo {
        uint256 lock;
        uint256[] vestingPeriods;
        uint256[] vestingPercentages;
        uint256 depositTime;
    }

    struct UserInfo {
        bool isRegistered;
        uint256 tickets;
        uint256 vestingAmount;
        uint256 withdrawAmount;
        uint256 participatedAmount;
    }
    event Lock(
        uint256 indexed depositId,
        address _token,
        uint256 _lock,
        uint256[] _percentages,
        uint256[] _vestings,
        address[] _beneficiaries,
        uint256[] _allocAmounts
    );
    event AddedPool(uint256 id, InitialInfo info);
    event UpdateBeneficiary(uint256 _poolId, address _beneficiary);
    event SetTimes(uint256 _poolId, uint256 _openTime, uint256 _endTime);
    event SetPrice(
        uint256 _poolId,
        uint256 _tokenPrice,
        uint256 _teamTokenPrice
    );
    event WithdrawFunds(uint256 _poolId, address user, uint256 _poolRaise);
    event SetBlockHash(uint256 _poolId, bytes32 _blockHash);
    event SetMinAllocation(uint256 _poolId, uint256 _amount);
    event LotteryRegistry(uint256 _poolId);
    event SetMinTickets(uint256 _poolId, uint256 _min);
    event RunLottery(uint256 _poolId);
    event SetTicketAllocation(uint256 _poolId, uint256 _amount);
    event SetTicketPrice(uint256 _poolId, uint256 _amount);
    event Participated(uint256 _poolId, uint256 _amount, address user);
    event Lock(
        uint256 _poolId,
        address _token,
        uint256 _lock,
        uint256[] _percentages,
        uint256[] _vestingsPeriods
    );
    event Withdraw(uint256 _poolId, uint256 transferAmount, address user);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        // Check if the computed hash (root) is equal to the provided root
        return computedHash == root;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20Upgradeable.sol";
import "../../math/SafeMathUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/Initializable.sol";
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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
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
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}