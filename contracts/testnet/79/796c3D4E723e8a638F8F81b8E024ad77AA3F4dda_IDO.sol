/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

// File contracts/IDO.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * @dev Collection of functions related to the address type
 */
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
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
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
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

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
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

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

/**
 * @title IDO contract
 * @author gotbit
 */
contract IDO is Ownable {
    using SafeERC20 for IERC20Metadata;
    IERC20Metadata public GZT;
    // IDO start time and ido End time
    uint256 public idoStart;
    uint256 public idoFinish;
    //claim parameters
    uint256 public cooldownToClaim;
    Factor public claimPercentage;

    //reserved GZT for participated users
    uint256 public GZTRezerves;

    struct WhitelistInstance {
        uint256 maxAllocation;
        bool isWhitelisted;
    }
    // factor structure rate = numerator / denominator
    struct Factor {
        uint256 numerator;
        uint256 denominator;
    }

    struct IDOParticipant {
        uint256 start;
        uint256 amountToClaim;
        uint256 claimedAmount;
    }

    mapping(address => WhitelistInstance) public whitelist;
    mapping(address => IDOParticipant) public pool;

    mapping(IERC20Metadata => bool) public allowedTokens;
    mapping(IERC20Metadata => Factor) public rates;

    event TokenAddedToWhitelist(IERC20Metadata token, uint256 time);
    event TokenRemovedFromWhitelist(IERC20Metadata token, uint256 time);
    event Participated(
        IERC20Metadata indexed token,
        address indexed user,
        uint256 amount
    );
    event Claimed(address indexed user, uint256 time, uint256 amount);
    event ClaimedByOwner(IERC20Metadata token, uint256 time, uint256 amount);
    event WithdrawedGZT(uint256 time, uint256 amount);

    constructor(IERC20Metadata _IDO_TOKEN) {
        GZT = _IDO_TOKEN;
    }

    /// @dev allows user in whitlelist to participate in IDO with whitelisted for GZT tokens
    /// @param _amount token amount to be participated with
    /// @param _token token to be participated with
    function participate(uint256 _amount, IERC20Metadata _token) external {
        //check is user whitelisted
        require(
            whitelist[msg.sender].isWhitelisted,
            "participate: user not whitelisted"
        );

        //check is token whitelisted
        require(allowedTokens[_token], "participate: token not whitelisted");

        //check is IDO is passes now
        require(
            block.timestamp >= idoStart,
            "participate: ido is not started yet"
        );
        require(
            block.timestamp < idoFinish,
            "participate: ido is already finished"
        );

        require(
            _token.balanceOf(msg.sender) >= _amount,
            "participate: not enough balance"
        );

        Factor memory rate = rates[_token];

        // converting _token amount to GZT
        uint256 convertedAmount = ((_amount *
            rate.numerator *
            (10**GZT.decimals())) /
            rate.denominator /
            (10**_token.decimals()));
        uint256 amountToClaim = pool[msg.sender].amountToClaim +
            convertedAmount;
        // check is maxAllocation exceeded
        require(
            whitelist[msg.sender].maxAllocation >= amountToClaim,
            "participate: maxAllocation is exceeded"
        );
        // increase total reserved GZT token
        GZTRezerves += convertedAmount;
        // check if here enough free GZT token on contract
        require(
            GZT.balanceOf(address(this)) >= GZTRezerves,
            "participate: not enough GZT tokens on the contract"
        );
        _token.safeTransferFrom(msg.sender, address(this), _amount);

        pool[msg.sender] = IDOParticipant({
            start: block.timestamp,
            amountToClaim: amountToClaim,
            claimedAmount: 0
        });

        emit Participated(_token, msg.sender, convertedAmount);
    }

    /// @dev allow participated users to claim GZT tokens after IDO finishes
    function claim() external {
        IDOParticipant storage user = pool[msg.sender];
        require(block.timestamp > idoFinish, "claim: ido is not finished");
        require(user.start != 0, "claim: not participated in ido");
        uint256 unclaimed = calculateClaim(msg.sender);
        require(unclaimed > 0, "claim: nothing to claim");
        require(
            GZT.balanceOf(address(this)) >= unclaimed,
            "claim: not enough tokens on smart contract"
        );
        user.claimedAmount += unclaimed;
        GZT.safeTransfer(msg.sender, unclaimed);
        GZTRezerves -= unclaimed;
        emit Claimed(msg.sender, block.timestamp, unclaimed);
    }

    /// @dev calculate GZT tokens to claim by this moment of selected user
    /// @param _user address of selected user
    function calculateClaim(address _user) public view returns (uint256) {
        IDOParticipant storage user = pool[_user];
        if (user.start == 0) return 0;
        if (block.timestamp < idoFinish) return 0;
        uint256 timePassed = block.timestamp - idoFinish;
        uint256 units = timePassed / cooldownToClaim;
        uint256 vestingAmount = ((user.amountToClaim *
            units *
            claimPercentage.numerator) / claimPercentage.denominator);
        if (vestingAmount > user.amountToClaim)
            vestingAmount = user.amountToClaim;
        return vestingAmount - user.claimedAmount;
    }

    /// @dev allow owner to add users to whitelist
    /// @param _users array of users
    /// @param _maxAllocations array of user amounts correspondingly to users, users and amounts array lenghts should be the same
    function addUsersToWhitelist(
        address[] memory _users,
        uint256[] memory _maxAllocations
    ) external onlyOwner {
        require(
            _users.length == _maxAllocations.length,
            "invalid array lengths"
        );
        uint256 len = _users.length;
        for (uint256 i = 0; i < len; i++) {
            whitelist[_users[i]] = WhitelistInstance({
                maxAllocation: _maxAllocations[i],
                isWhitelisted: true
            });
        }
    }

    /// @dev allow owner to remove users from whitelist
    /// @param _users array of users
    function removeUsersFromWhitelist(address[] memory _users)
        external
        onlyOwner
    {
        uint256 len = _users.length;
        for (uint256 i = 0; i < len; i++) {
            whitelist[_users[i]] = WhitelistInstance({
                maxAllocation: 0,
                isWhitelisted: false
            });
        }
    }

    /// @dev allows owner to add ERC20 token to whitelist
    /// @param _token token address
    /// @param _rate token swap price factor accordingly to GZT token
    function allowToken(IERC20Metadata _token, Factor memory _rate)
        external
        onlyOwner
    {
        require(_rate.denominator > 0, "rate denominator cant be zero");
        allowedTokens[_token] = true;
        rates[_token] = _rate;
        emit TokenAddedToWhitelist(_token, block.timestamp);
    }

    /// @dev allows owner to remove ERC20 token from whitelist
    /// @param _token token address
    function disallowTokens(IERC20Metadata _token) external onlyOwner {
        require(allowedTokens[_token] == true, "token is not allowed");
        allowedTokens[_token] = false;
        emit TokenRemovedFromWhitelist(_token, block.timestamp);
    }

    /// @dev allows owner to start IDO at the start timestamp, and set vesting setting which started after IDO finish
    /// @param _start IDO start timestamp, lasts till finish
    /// @param _finish IDO finish timestamp, vesting will start after it
    /// @param _cooldown vesting cooldown
    /// @param _claimPercentage vesting amountToClaim after every cooldown till user allocation is paid
    function setIDO(
        uint256 _start,
        uint256 _finish,
        uint256 _cooldown,
        Factor memory _claimPercentage
    ) external onlyOwner {
        require(
            _start >= block.timestamp,
            "setIDO: start should be >= block.timestamp"
        );
        require(_finish > _start, "setIDO: finish should be > start");
        require(idoStart == 0, "setIDO: ido is already started");
        require(
            _claimPercentage.numerator > 0 && _claimPercentage.denominator > 0,
            "setIDO: percentage numerator || denominator cant be 0"
        );
        require(_cooldown > 0, "setIDO: cooldown cant be 0");
        idoStart = _start;
        idoFinish = _finish;
        cooldownToClaim = _cooldown;
        claimPercentage = _claimPercentage;
    }

    /// @dev allows owner to claim selected token after IDO finishes
    /// @param _token ERC20 token address
    function claimTheInvestments(IERC20Metadata _token) external onlyOwner {
        require(
            block.timestamp > idoFinish,
            "claimTheInvestments: ido is not finished yet"
        );
        uint256 amount;
        if (_token != GZT) {
            amount = _token.balanceOf(address(this));
            _token.safeTransfer(msg.sender, amount);
        } else {
            require(
                _token.balanceOf(address(this)) > GZTRezerves,
                "claimTheInvestments: nothing to claim"
            );
            amount = _token.balanceOf(address(this)) - GZTRezerves;
            _token.safeTransfer(msg.sender, amount);
        }
        emit ClaimedByOwner(_token, block.timestamp, amount);
    }

    /// @dev allows owner to withdraw not reserved GZT tokens
    /// @param _amount amount of GZT to be withdrawn
    function withdrawGZT(uint256 _amount) external onlyOwner {
        require(
            GZT.balanceOf(address(this)) >= GZTRezerves + _amount,
            "withdrawGZT: not enough not reserved tokens on the contract"
        );
        GZT.safeTransfer(msg.sender, _amount);
    }

    /// @dev info about selected user
    /// @param _user selected user address
    /// @return _whitelistInstance returns maxium allocation and whitelist status of a user
    /// @return _idoParticipantInstance returns IDOPartisipant of a user
    function infoBundler(address _user)
        external
        view
        onlyOwner
        returns (
            WhitelistInstance memory _whitelistInstance,
            IDOParticipant memory _idoParticipantInstance
        )
    {
        return (whitelist[_user], pool[_user]);
    }
}