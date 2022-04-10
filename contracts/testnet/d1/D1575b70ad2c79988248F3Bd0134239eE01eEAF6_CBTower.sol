/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

    function mint(address to, uint256 amount) external returns (bool);

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
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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

interface DividendPayingTokenInterface {
    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function dividendOf(address _owner) external view returns(uint256);

    /// @notice Distributes ether to token holders as dividends.
    /// @dev SHOULD distribute the paid ether to token holders as dividends.
    ///  SHOULD NOT directly transfer ether to token holders in this function.
    ///  MUST emit a `DividendsDistributed` event when the amount of distributed ether is greater than 0.
    function distributeDividends(uint256 amount) external;

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev SHOULD transfer `dividendOf(msg.sender)` wei to `msg.sender`, and `dividendOf(msg.sender)` SHOULD be 0 after the transfer.
    ///  MUST emit a `DividendWithdrawn` event if the amount of ether transferred is greater than 0.
    function withdrawDividend() external;

    function setTowerContract(address _address) external;

    /// @dev This event MUST emit when ether is distributed to token holders.
    /// @param from The address which sends ether to this contract.
    /// @param weiAmount The amount of distributed ether in wei.
    event DividendsDistributed(
        address indexed from,
        uint256 weiAmount
    );

    /// @dev This event MUST emit when an address withdraws their dividend.
    /// @param to The address which withdraws ether from this contract.
    /// @param weiAmount The amount of withdrawn ether in wei.
    event DividendWithdrawn(
        address indexed to,
        uint256 weiAmount
    );
}

interface DividendPayingTokenOptionalInterface {
    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function withdrawableDividendOf(address _owner) external view returns(uint256);

    /// @notice View the amount of dividend in wei that an address has withdrawn.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has withdrawn.
    function withdrawnDividendOf(address _owner) external view returns(uint256);

    /// @notice View the amount of dividend in wei that an address has earned in total.
    /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has earned in total.
    function accumulativeDividendOf(address _owner) external view returns(uint256);
}

interface ICBTower {
    function getCurrentFloor() external view returns (uint256);
}

contract CBTower is Ownable, ICBTower {
    using SafeERC20 for IERC20;

    address public BCT;
    address public BBT;
    address public BWT;

    // testnet - 0x6384EE13E5f9379c02F4E24fFc25bf8A13715783
    /// BSC USDT - 0x55d398326f99059fF775485246999027B3197955
    IERC20 public USDT = IERC20(0x6384EE13E5f9379c02F4E24fFc25bf8A13715783);


    struct UserInfo {
        uint256 reinvestRatio;
        uint256 joinTime;
        uint256 lastUpdateFloor;
        // Referrals
        address level1;
        address level2;
        address level3;
        address level4;
        address level5;
        //
        uint256 lastAmount;
    }

    struct FloorInfo {
        uint256 startDate;
        uint256 endDate;
        uint256 collectionAmount;
        uint256 totalInvested;
    }

    mapping (uint256 => mapping (uint256 => uint256)) public floorReinvestAmounts;

    uint256 private grandFinalStartTime;
    uint256 private grandFinalEndTime;

    uint256 public currentFloor;
    FloorInfo[] public floorInfo;

    mapping(address => UserInfo) public userInfo;

    bool public building = true;

    event FloorFinished(uint256 floor);

    constructor(address _bct, address _bbt, address _bwt) {
        BCT = _bct;
        BBT = _bbt;
        BWT = _bwt;
        floorInfo.push(FloorInfo({
            startDate: block.timestamp,
            endDate: block.timestamp + getBuildTime(),
            collectionAmount: getCollectionAmount(),
            totalInvested: 0
            }));
    }

    /// @dev Public Functions

    function invest(address _referral, uint256 amount) public {
        // require(amount >= 10**18, "Minimum amount 1 USDT");
        USDT.safeTransferFrom(_msgSender(), address(this), amount);
        if (floorInfo[currentFloor].endDate <= block.timestamp) {
            _stopBuilding();
        }
        require(building, "Building has finished");

        UserInfo storage user = userInfo[_msgSender()];
        UserInfo storage referral = userInfo[_referral];

        if (user.joinTime == 0) {
            user.joinTime = block.timestamp;
            user.reinvestRatio = 500;
            user.lastUpdateFloor = currentFloor;
            if (_referral != address(0)) { // Sets referrals for user
                user.level1 = _referral;
                user.level2 = referral.level1;
                user.level3 = referral.level2;
                user.level4 = referral.level3;
                user.level5 = referral.level4;
            }
        } else {
            withdrawPendingUSDT();
        }

        _payReferrals(amount);

        uint256 left = amount;

        while (left > 0) {
            left = _invest(left);
        }

        uint256 BCTamount = amount * 2 / 10;
        DividendPayingTokenInterface(address(BBT)).distributeDividends(BCTamount);

        if (user.joinTime + 2 days >= block.timestamp && user.level1 != address(0)) {
            IERC20(BCT).mint(_msgSender(), amount);
        } else {
            IERC20(BCT).mint(_msgSender(), amount * 8 / 10);
        }

    }

    function leftForCurrentFloor() public view returns (uint256) {
        return floorInfo[currentFloor].collectionAmount - floorInfo[currentFloor].totalInvested;
    }

    function changeReinvestRatio(uint256 newRatio) public {
        require(newRatio >= 500, "Minimum 0.5");
        withdrawPendingUSDT();
        floorReinvestAmounts[currentFloor][userInfo[_msgSender()].reinvestRatio] -= userInfo[_msgSender()].lastAmount;
        userInfo[_msgSender()].reinvestRatio = newRatio;
        floorReinvestAmounts[currentFloor][userInfo[_msgSender()].reinvestRatio] += userInfo[_msgSender()].lastAmount;
    }

    function getGrandFinalInfo() public view returns (uint256, uint256) {
        return (grandFinalStartTime, grandFinalEndTime);
    }

    function getCurrentFloor() public override view returns (uint256) {
        return currentFloor;
    }

    /// @dev Only Owner Functions

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawERC20(IERC20 token) external onlyOwner {
        token.safeTransfer(owner(), token.balanceOf(address(this)));
    }

    /// @dev Internal Functions

    function withdrawPendingUSDT() public {
        require(userInfo[_msgSender()].joinTime != 0, "User has not participated");
        uint256 amount = _getWithdrawableUSDT(_msgSender());
        userInfo[_msgSender()].lastUpdateFloor = currentFloor;
        if (amount > 0) {
            USDT.safeTransfer(_msgSender(), amount);
            userInfo[_msgSender()].lastAmount -= amount;
        }
    }

    function _getWithdrawableUSDT(address _user) public view returns (uint256 amount) {
        UserInfo storage user = userInfo[_user];
        if (user.lastUpdateFloor < currentFloor) {
            uint256 difference = currentFloor - user.lastUpdateFloor;
            amount = (user.lastAmount - ( ( user.lastAmount*user.reinvestRatio * 10**18 / 1000 ) ** difference / (10**18)**difference ) );
        } else {
            amount = 0;
        }
    }

    function getBuildTime() internal view returns (uint256 buildTime) {   
        buildTime = (currentFloor + 1) * 2 days;
    }

    function getCollectionAmount() internal view returns (uint256 collectionAmount) {
        collectionAmount = (2**currentFloor)*(10**18);
    }

    function _initiateNewFloor() internal {
        require(floorInfo[currentFloor].totalInvested == floorInfo[currentFloor].collectionAmount, "Not enough is collected");
        emit FloorFinished(currentFloor);

        floorInfo[currentFloor].endDate = block.timestamp;

        currentFloor += 1;

        uint256 _startAmount;
        floorInfo.push(FloorInfo({
            startDate: block.timestamp,
            endDate: block.timestamp + getBuildTime(),
            collectionAmount: getCollectionAmount(),
            totalInvested: 0
        }));

        FloorInfo storage floor = floorInfo[currentFloor];
        for (uint256 i = 500; i < 1001; i++) {
            if (floorReinvestAmounts[currentFloor - 1][i] > 0) {
                uint256 _amount = floorReinvestAmounts[currentFloor - 1][i];
                floorReinvestAmounts[currentFloor][i] = _amount * i / 1000;
                _startAmount += _amount;
            }
        }
        floor.totalInvested = _startAmount;
    }
    
    function _payReferrals(uint256 amount) internal {
        UserInfo storage user = userInfo[_msgSender()];
        uint256 referralPay;
        if (user.level1 != address(0)) {
            referralPay = amount * 16 / 100;
            IERC20(BCT).mint(user.level1, referralPay);
            if (user.level2 != address(0)) {
                referralPay = amount * 32 / 1000;
                IERC20(BCT).mint(user.level2, referralPay);
                if (user.level3 != address(0)) {
                    referralPay = amount * 64 / 10000;
                    IERC20(BCT).mint(user.level3, referralPay);
                    if (user.level4 != address(0)) {
                        referralPay = amount * 128 / 100000;
                        IERC20(BCT).mint(user.level4, referralPay);
                        if (user.level5 != address(0)) {
                            referralPay = amount * 32 / 100000;
                            IERC20(BCT).mint(user.level5, referralPay);
                        }
                    }
                }
            }
        }
    }

    function _stopBuilding() internal {
        require(floorInfo[currentFloor].endDate <= block.timestamp, "Floor building has not finished");
        building = false;
        grandFinalStartTime = block.timestamp;
        grandFinalEndTime = block.timestamp + 60*60*24;
    }

    function _invest(uint256 amount) internal returns (uint256 left){ // change to internal
        FloorInfo storage floor = floorInfo[currentFloor];
        UserInfo storage user = userInfo[_msgSender()];

        withdrawPendingUSDT();

        uint256 leftForCurrentFloor_ = floor.collectionAmount - floor.totalInvested;

        if (leftForCurrentFloor_ > amount) {
            user.lastAmount += amount;
            left = 0;
            floor.totalInvested += amount;
            floorReinvestAmounts[currentFloor][userInfo[_msgSender()].reinvestRatio] += amount;
        } else {
            user.lastAmount += amount;
            left = amount - leftForCurrentFloor_;
            floor.totalInvested += leftForCurrentFloor_;
            floorReinvestAmounts[currentFloor][userInfo[_msgSender()].reinvestRatio] += leftForCurrentFloor_;
        }

        if (floor.collectionAmount == floor.totalInvested) {
                _initiateNewFloor();
        }

    }

    receive() external payable {
        revert("This contract is not designed to receive BNB");
    }

}