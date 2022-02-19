// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./BEP20/SafeBEP20.sol";
import "./lib/Context.sol";

/**
 * @dev A contract for creating lottery for anyone who wants to participate.
 * When the win() method is triggered, half of the tokens in contract's account
 * are locked for the single lottery winner. After the time lock (set in _winningReleaseTime
 * right after the winner is chosen) passes, the winner is able to execute claimWin() function,
 * which transfers all the winning amount to winner's address. Another half is distributed through
 * all the participants as consolation prizes. All the participants can then
 * claim their consolation prizes by executing claimConsolationPrize() function.
 */
contract TokenLottery is Context {
    using SafeBEP20 for IBEP20;

    // Amount of days winner's tokens are locked for after win()
    // function is executed.
    uint constant WINNER_TOKENS_LOCK_DAYS = 90;

    // What part of contract's balance should be given for a
    // winner (another part will be distributed as consolation prizes)
    uint constant WINNER_AMOUNT_PERCENTAGE = 20;

    /**
     * @dev This event is emitted for each new participant
     * registered in the lottery.
     */
    event NewParticipant(address indexed participantAddress, uint index);

    /**
     * @dev WinLock event is emitted whenever the winner is picked and
     * amount is locked for winner's address.
     */
    event WinLock(address indexed winnerAddress, uint256 amount);

    /**
     * @dev WinClaim event is emitted when winner has claimed his winning.
     */
    event WinClaim(address indexed winnerAddress, uint256 amount);

    /**
     * @dev ConsolationPrizeClaim event is emitted when lottery participant
     * claims his consolation prize.
     */
    event ConsolationPrizeClaim(address indexed participantAddress, uint256 amount);

    // Contract owner address that is able to trigger winner choosing function.
    address private _owner;

    // BEP20 token which will be used for paying out the winning.
    IBEP20 private immutable _token;

    // The minimum time when win() function can be executed for choosing
    // the lottery winner and start claiming consolation prizes.
    uint256 private immutable _minWinningTime;

    // An address of the lottery winner. It's selected on win() function call.
    address private _winnerAddress;

    // A timestamp after which the winner is able to get his tokens.
    // It's calculated when lottery winner is chosen by adding WINNER_TOKENS_LOCK_DAYS
    // days to current block time.
    uint256 private _winningReleaseTime;

    // Amount of tokens that are locked for the winner. It is set when
    // the winner is chosen, by formula: TOKEN AMOUNT IN ADDRESS * WINNER_AMOUNT_PERCENTAGE / 100
    uint256 private _winningAmount;

    // A list of participants waiting for winning time.
    address[] private _participants;

    // A map pointing to index of participants in _participants array.
    mapping(address => uint) private _participantsIndex;

    // A map of addresses that have already claimed their consolation prizes.
    mapping(address => bool) private _consolationClaimed;

    // Count of addresses that have already claimed their consolation prizes.
    uint private _consolationClaimedCount;

    // Amount of tokens to be given to each participants as a consolation
    // prize. It's calculated and set when lottery winner is chosen, by
    // following formula: (TOKEN AMOUNT IN ADDRESS - WIN AMOUNT) / PARTICIPANTS COUNT.
    // Since win amount = 50% of the tokens, _consolationPrizeAmount is just another half
    // divided by participants count.
    uint256 private _consolationPrizeAmount;

    constructor(
        IBEP20 token_,
        uint256 minWinningTime_
    ) {
        require(address(token_) != address(0), "TokenLottery: token is zero address");
        require(minWinningTime_ > block.timestamp, "TokenLottery: min winning time is in the past");

        _token = token_;
        _minWinningTime = minWinningTime_;
        _owner = _msgSender();

        // We add zero-address as a first element in order to have correct
        // mapping in _participantsIndex (don't have pointer to 0st array element)
        _participants.push(address(0));
    }

    /**
     * @return the token used for lottery.
     */
    function token() public view virtual returns (IBEP20) {
        return _token;
    }

    /**
     * @return the address of lottery winner. It's address(0) until the winner is selected.
     */
    function winnerAddress() public view virtual returns (address) {
        return _winnerAddress;
    }

    /**
     * @return the earliest time when winner can be picked.
     */
    function minWinningTime() public view virtual returns (uint256) {
        return _minWinningTime;
    }

    /**
     * @return the earliest time when winner is able to claim tokens.
     */
    function winningReleaseTime() public view virtual returns (uint256) {
        return _winningReleaseTime;
    }

    /**
     * @return the amount of tokens locked for the winner.
     */
    function winningAmount() public view virtual returns (uint256) {
        return _winningAmount;
    }

    /**
     * @return the amount of tokens calculated as a consolation prize
     * for each participant.
     */
    function consolationPrizeAmount() public view virtual returns (uint256) {
        return _consolationPrizeAmount;
    }

    /**
     * @return a list of participants in this lottery.
     */
    function participants() public view virtual returns (address[] memory) {
        return _participants;
    }

    /**
     * @return returns a count of participants.
     * We subtract 1 because first participant is always address(0)
     */
    function participantsCount() public view virtual returns (uint) {
        return _participants.length - 1;
    }

    /**
     * @return amount of addresses that have already claimed their
     * consolation prizes.
     */
    function consolationClaimedCount() public view virtual returns (uint) {
        return _consolationClaimedCount;
    }

    /**
     * @return address of contract creator.
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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyWinner() {
        require(winnerAddress() == _msgSender(), "TokenLottery: caller is not the winner");
        _;
    }

    /**
     * @dev Throws if winner is not yet selected.
     */
    modifier onlyAfterWinnerSelected() {
        require(isWinnerSelected(), "TokenLottery: winner is not selected yet");
        _;
    }

    /**
     * @dev Throws if winner is already selected.
     */
    modifier onlyBeforeWinnerSelected() {
        require(!isWinnerSelected(), "TokenLottery: winner is already selected");
        _;
    }

    /**
     * @dev Adds a method caller to participants if it doesn't participate yet.
     */
    function participate() public virtual onlyBeforeWinnerSelected {
        address sender = _msgSender();
        require(!isParticipating(sender), "TokenLottery: address already participates in this lottery");

        _participants.push(sender);

        uint index = _participants.length - 1;
        _participantsIndex[sender] = index;

        emit NewParticipant(sender, index);
    }

    /**
     * @dev Checks if address is already participating
     */
    function isParticipating(address addr) public view returns (bool) {
        return _participantsIndex[addr] != 0;
    }

    /**
     * @dev Checks if winner was already selected. If so, it also means that
     * all the needed values for consolation prizes are already calculated as well.
     */
    function isWinnerSelected() public view returns (bool) {
        return winnerAddress() != address(0);
    }

    /**
     * @dev Picks a pseudo-random index for participants array.
     */
    function _random() internal view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants())));
    }

    /**
     * @dev Picks a single pseudo-random address from all the
     * participants.
     */
    function _pickWinner() internal view returns (address) {
        // +1 because we want to skip the first element, which is address(0)
        uint winnerIndex = (_random() % (participants().length - 1)) + 1;

        return participants()[winnerIndex];
    }

    /**
     * @dev win() selects a lottery winner, calculates win amount as well as consolation prize amount
     * for each participants. After this function is executed the participants are able to claim their
     * consolation prizes.
     */
    function win() public onlyOwner onlyBeforeWinnerSelected {
        require(block.timestamp >= minWinningTime(), "TokenLottery: current time is before winning time");
        require(participantsCount() > 0, "TokenLottery: there are no participants for winning");

        uint256 amount = token().balanceOf(address(this));
        require(amount > 0, "TokenLottery: no amount to win");

        address winnerAddress_ = _pickWinner();
        require(winnerAddress_ != address(0), "TokenLottery: winner address is zero-address");

        // Half of the amount goes for the winner.
        uint256 winAmount = amount * WINNER_AMOUNT_PERCENTAGE / 100;
        require(winAmount > 0, "TokenLottery: win amount is <= 0");

        // Leftover amount goes into consolation prize pot.
        uint256 consolationPrizePot = amount - winAmount;
        require(consolationPrizePot > 0, "TokenLottery: consolation prize pot <= 0");

        // Each participant gets equal part of the consolation prize pot.
        uint256 consolationPrizePerParticipant = consolationPrizePot / participantsCount();

        _winnerAddress = winnerAddress_;
        _winningAmount = winAmount;
        // Lock winner's tokens for WINNER_TOKENS_LOCK_DAYS days into the future.
        _winningReleaseTime = block.timestamp + (WINNER_TOKENS_LOCK_DAYS * 3600 * 24);
        _consolationPrizeAmount = consolationPrizePerParticipant;

        // From now on winner's tokens are locked and participants are able
        // to claim their consolation prize.
        emit WinLock(winnerAddress_, winAmount);
    }

    /**
     * @dev claimWin() actually sends winner's tokens to the winner's balance.
     * Only winner is allowed to execute this method and it's only possible after
     * _winningReleaseTime timestamp.
     */
    function claimWin() public onlyAfterWinnerSelected onlyWinner {
        require(block.timestamp >= winningReleaseTime(), "TokenLottery: current time is before winning release time");

        uint256 amount = winningAmount();
        require(amount > 0, "TokenLottery: there is no winning amount");

        uint256 balance = token().balanceOf(address(this));

        // Double check for the possible case of small tokens amount
        // error caused by division and rounding.
        if (amount > balance) {
            amount = balance;
        }

        address winnerAddress_ = winnerAddress();
        token().safeTransfer(winnerAddress_, amount);
        _winningAmount = 0;

        emit WinClaim(winnerAddress_, amount);
    }

    /**
     * @dev Checks if address has already claimed its consolation prize.
     */
    function hasClaimedConsolationPrize(address addr) public onlyAfterWinnerSelected view returns (bool) {
        return _consolationClaimed[addr];
    }

    /**
     * @dev Transfers caller's consolation prize to his address and adds the address
     * to already claimed map.
     */
    function claimConsolationPrize() public onlyAfterWinnerSelected {
        address sender = _msgSender();
        require(!hasClaimedConsolationPrize(sender), "TokenLottery: address has already claimed the consolation prize");

        uint256 amount = consolationPrizeAmount();
        uint256 balance = token().balanceOf(address(this));

        // Double check for the possible case of small tokens amount
        // error caused by division and rounding.
        if (amount > balance) {
            amount = balance;
        }

        token().safeTransfer(sender, amount);

        _consolationClaimed[sender] = true;
        _consolationClaimedCount++;

        emit ConsolationPrizeClaim(sender, amount);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.9;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
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
        return functionCall(target, data, 'Address: low-level call failed');
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
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
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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

pragma solidity 0.8.9;

import './IBEP20.sol';
import '../lib/Address.sol';

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeBEP20: decreased allowance below zero");
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
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.9;

interface IBEP20 {
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