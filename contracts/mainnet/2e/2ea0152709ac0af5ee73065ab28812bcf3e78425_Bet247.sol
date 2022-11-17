/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

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

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
        require(owner() == _msgSender(), "You are not the owner");
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

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}

contract Bet247 is Pausable {
    using Address for address;
    uint256 public minAmout = 0.05 ether;
    uint16 public devFee = 500; // 5% all bet amount
    address public devFeeAddress = 0x512C25204B317F433CA566670AAb97bc80b30D4c;

    enum MATCH_RESULT {
        NONE, //0
        PLAYER1_WIN, //1
        DRAW, //2
        PLAYER2_WIN //3
    }

    enum MATCH_STATUS {
        NONE, //0
        UPCOMING, //1
        POSTPONE, //2
        FINISHED //3
    }

    event NewMatch(string key, string player1, string player2);
    event BetMatch(
        address bettor,
        string key,
        uint16 numberOfTicket,
        MATCH_RESULT prediction
    );
    event Withdraw(address bettor, string key);
    event CloseMatch(string key, MATCH_RESULT prediction);
    event PauseMatch(string key);
    event ReopenMatch(string key, uint32 startTime);
    event EndMatch(string key);

    constructor() {
        editors[msg.sender] = true;
    }

    struct Bet {
        MATCH_RESULT prediction; //1 = player1 wins, 2 = player2 wins, 3 = draw
        uint256 amount;
        uint16 numberOfTicket; // number of tickets bettor brought
        bool withdraw;
    }

    struct Match {
        string key;
        string player1;
        string player2;
        MATCH_STATUS status; // status = 1 = ready to bet, status = 2, bet is closed, status = 3, ready to winner withdraws
        uint32 startTime;
        MATCH_RESULT prediction;
        uint256 amount;
        uint256 remainAmount;
        uint32 totalWinningTicket;
        uint256 player1WinAmount;
        uint256 drawAmount;
        uint256 player2WinAmount;
        mapping(address => mapping(MATCH_RESULT => Bet)) bettors;
        address[] _bettors;
    }

    struct MatchBaseInfo {
        string player1;
        string player2;
        MATCH_STATUS status;
        uint32 startTime;
        uint256 player1WinAmount;
        uint256 drawAmount;
        uint256 player2WinAmount;
    }

    struct MatchBetInfo {
        MATCH_RESULT prediction;
        uint256 amount;
        uint256 totalBettor;
        uint32 totalPlayer1Ticket;
        uint32 totalDrawTicket;
        uint32 totalPlayer2Ticket;
    }

    struct HelperState {
        uint256 minAmout;
        uint16 devFee;
    }

    mapping(string => Match) private matches;

    mapping(address => bool) private editors;

    modifier requireEditor() {
        require(editors[msg.sender]);
        _;
    }

    function _state() external view returns (HelperState memory) {
        return HelperState({minAmout: minAmout, devFee: devFee});
    }

    function getMatchInfo(string calldata key)
        external
        view
        returns (MatchBaseInfo memory baseInfo, MatchBetInfo memory betInfo)
    {
        uint256 amount = matches[key].amount;
        if (amount <= 0) {
            amount = getTotalAmount(key);
        }
        return (
            MatchBaseInfo({
                player1: matches[key].player1,
                player2: matches[key].player2,
                status: matches[key].status,
                startTime: matches[key].startTime,
                player1WinAmount: matches[key].player1WinAmount,
                drawAmount: matches[key].drawAmount,
                player2WinAmount: matches[key].player2WinAmount
            }),
            MatchBetInfo({
                prediction: matches[key].prediction,
                amount: amount,
                totalBettor: matches[key]._bettors.length,
                totalPlayer1Ticket: getTotalTicketByPrediction(
                    key,
                    MATCH_RESULT.PLAYER1_WIN
                ),
                totalDrawTicket: getTotalTicketByPrediction(
                    key,
                    MATCH_RESULT.DRAW
                ),
                totalPlayer2Ticket: getTotalTicketByPrediction(
                    key,
                    MATCH_RESULT.PLAYER2_WIN
                )
            })
        );
    }

    function getBetInfo(string calldata key, address bettor)
        external
        view
        returns (
            Bet memory player1Win,
            Bet memory draw,
            Bet memory player2Win
        )
    {
        return (
            matches[key].bettors[bettor][MATCH_RESULT.PLAYER1_WIN],
            matches[key].bettors[bettor][MATCH_RESULT.DRAW],
            matches[key].bettors[bettor][MATCH_RESULT.PLAYER2_WIN]
        );
    }

    function betMatch(
        string calldata key,
        uint16 numberOfTicket,
        MATCH_RESULT prediction
    ) external payable whenNotPaused {
        if (prediction == MATCH_RESULT.PLAYER1_WIN) {
            require(
                msg.value >= numberOfTicket * matches[key].player1WinAmount,
                "insufficient funds"
            );
        }
        if (prediction == MATCH_RESULT.PLAYER2_WIN) {
            require(
                msg.value >= numberOfTicket * matches[key].player2WinAmount,
                "insufficient funds"
            );
        }
        if (prediction == MATCH_RESULT.DRAW) {
            require(
                msg.value >= numberOfTicket * matches[key].drawAmount,
                "insufficient funds"
            );
        }
        require(
            matches[key].status == MATCH_STATUS.UPCOMING,
            "bet not ready or closed"
        );
        require(block.timestamp < matches[key].startTime, "overdue");
        require(
            prediction == MATCH_RESULT.PLAYER1_WIN ||
                prediction == MATCH_RESULT.DRAW ||
                prediction == MATCH_RESULT.PLAYER2_WIN,
            "prediction not valid"
        );

        if (
            matches[key]
            .bettors[msg.sender][MATCH_RESULT.DRAW].numberOfTicket <=
            0 &&
            matches[key]
            .bettors[msg.sender][MATCH_RESULT.PLAYER1_WIN].numberOfTicket <=
            0 &&
            matches[key]
            .bettors[msg.sender][MATCH_RESULT.PLAYER2_WIN].numberOfTicket <=
            0
        ) {
            matches[key]._bettors.push(msg.sender);
        }

        if (matches[key].bettors[msg.sender][prediction].numberOfTicket > 0) {
            matches[key].bettors[msg.sender][prediction].amount += msg.value;
            matches[key]
            .bettors[msg.sender][prediction].numberOfTicket += numberOfTicket;
        } else {
            matches[key]
            .bettors[msg.sender][prediction].prediction = prediction;
            matches[key].bettors[msg.sender][prediction].amount = msg.value;
            matches[key]
            .bettors[msg.sender][prediction].numberOfTicket = numberOfTicket;
        }

        emit BetMatch(msg.sender, key, numberOfTicket, prediction);
    }

    function openMatch(
        string calldata key,
        string calldata player1,
        string calldata player2,
        MATCH_STATUS status,
        uint32 startTime,
        uint256 player1WinAmount,
        uint256 drawAmount,
        uint256 player2WinAmount
    ) external requireEditor whenNotPaused {
        require(
            matches[key].status != MATCH_STATUS.POSTPONE &&
                matches[key].status != MATCH_STATUS.UPCOMING &&
                matches[key].status != MATCH_STATUS.FINISHED,
            "match exist"
        );
        matches[key].player1 = player1;
        matches[key].player2 = player2;
        matches[key].status = status;
        matches[key].startTime = startTime;
        matches[key].key = key;
        if (player1WinAmount <= 0) {
            player1WinAmount = minAmout;
        }
        if (drawAmount <= 0) {
            drawAmount = minAmout;
        }
        if (player2WinAmount <= 0) {
            player2WinAmount = minAmout;
        }
        matches[key].player1WinAmount = player1WinAmount;
        matches[key].drawAmount = drawAmount;
        matches[key].player2WinAmount = player2WinAmount;
        matches[key].prediction = MATCH_RESULT.NONE;
        emit NewMatch(key, player1, player2);
    }

    function withdrawMatch(string calldata key) external returns (uint256) {
        require(
            matches[key].status == MATCH_STATUS.FINISHED,
            "match not closed"
        );
        require(
            matches[key]
            .bettors[msg.sender][matches[key].prediction].numberOfTicket > 0,
            "wrong prediction"
        );
        require(
            matches[key]
            .bettors[msg.sender][matches[key].prediction].withdraw == false,
            "withdrawn"
        );

        require(
            matches[key].startTime + 60 * 24 * 3600 > block.timestamp,
            "expired"
        );

        uint256 payAmount = matches[key]
        .bettors[msg.sender][matches[key].prediction].numberOfTicket *
            (matches[key].amount / matches[key].totalWinningTicket);

        require(matches[key].remainAmount >= payAmount, "fund runs out");

        matches[key]
        .bettors[msg.sender][matches[key].prediction].withdraw = true;
        matches[key].remainAmount = matches[key].remainAmount - payAmount;

        payable(msg.sender).transfer(payAmount);
        emit Withdraw(msg.sender, key);
        return payAmount;
    }

    function closeMatch(string calldata key, MATCH_RESULT prediction)
        external
        requireEditor
    {
        require(matches[key].status != MATCH_STATUS.FINISHED, "match finished");
        matches[key].status = MATCH_STATUS.FINISHED;
        matches[key].prediction = prediction;
        uint256 amount = getTotalAmount(key);
        uint32 totalWinningTicket = getTotalTicketByPrediction(
            key,
            matches[key].prediction
        );
        uint256 devFeeAmount = devFee * (amount / 10000);
        payable(devFeeAddress).transfer(devFeeAmount);
        matches[key].amount = amount - devFeeAmount;
        matches[key].remainAmount = matches[key].amount;
        matches[key].totalWinningTicket = totalWinningTicket;
        emit CloseMatch(key, prediction);
    }

    function postponeMatch(string calldata key) external requireEditor {
        require(matches[key].status == MATCH_STATUS.UPCOMING, "match changed");
        matches[key].status = MATCH_STATUS.POSTPONE;
        emit PauseMatch(key);
    }

    function reopenMatch(
        string calldata key,
        string calldata player1,
        string calldata player2,
        uint32 startTime,
        uint256 player1WinAmount,
        uint256 drawAmount,
        uint256 player2WinAmount
    ) external requireEditor {
        require(matches[key].status != MATCH_STATUS.FINISHED, "match finished");
        matches[key].startTime = startTime;
        matches[key].status = MATCH_STATUS.UPCOMING;

        matches[key].player1 = player1;
        matches[key].player2 = player2;

        if (player1WinAmount <= 0) {
            player1WinAmount = minAmout;
        }
        if (drawAmount <= 0) {
            drawAmount = minAmout;
        }
        if (player2WinAmount <= 0) {
            player2WinAmount = minAmout;
        }
        matches[key].player1WinAmount = player1WinAmount;
        matches[key].drawAmount = drawAmount;
        matches[key].player2WinAmount = player2WinAmount;

        emit ReopenMatch(key, startTime);
    }

    function withdrawnMatchIfOver30(string calldata key)
        external
        requireEditor
    {
        require(matches[key].status == MATCH_STATUS.FINISHED, "_");
        require(matches[key].startTime + 60 * 24 * 3600 < block.timestamp, "_");
        if (matches[key].remainAmount > 0) {
            payable(devFeeAddress).transfer(matches[key].remainAmount);
            matches[key].remainAmount = 0;
        }
        emit EndMatch(key);
    }

    function setEditor(address editor, bool status) external onlyOwner {
        editors[editor] = status;
    }

    function setDevFee(uint256 _devFee) external onlyOwner {
        require(_devFee <= 1000, "always less than 10%");
        require(_devFee >= 0, "_");
        devFee = devFee;
    }

    function setDevFeeAddress(address _devFeeAddress) external onlyOwner {
        devFeeAddress = _devFeeAddress;
    }

    function setMintAmount(uint256 _mintAmount) external onlyOwner {
        minAmout = _mintAmount;
    }

    function getTotalAmount(string calldata key)
        internal
        view
        returns (uint256)
    {
        uint256 amount;
        for (uint256 i = 0; i < matches[key]._bettors.length; i++) {
            amount += (matches[key]
            .bettors[matches[key]._bettors[i]][MATCH_RESULT.PLAYER1_WIN]
                .amount +
                matches[key]
                .bettors[matches[key]._bettors[i]][MATCH_RESULT.DRAW].amount +
                matches[key]
                .bettors[matches[key]._bettors[i]][MATCH_RESULT.PLAYER2_WIN]
                    .amount);
        }
        return amount;
    }

    function getTotalTicketByPrediction(
        string calldata key,
        MATCH_RESULT prediction
    ) internal view returns (uint32) {
        uint32 totalTicket = 0;
        for (uint256 i = 0; i < matches[key]._bettors.length; i++) {
            totalTicket += matches[key]
            .bettors[matches[key]._bettors[i]][prediction].numberOfTicket;
        }
        return totalTicket;
    }

    function getWinningAmount(
        string calldata key,
        MATCH_RESULT prediction,
        uint16 numberOfTicket
    ) external view returns (uint256) {
        uint256 amount = getTotalAmount(key);
        uint32 totalWinningTicket = getTotalTicketByPrediction(key, prediction);
        if (totalWinningTicket <= 0) {
            return 0;
        }
        uint256 devFeeAmount = devFee * (amount / 10000);
        amount = amount - devFeeAmount;
        uint256 winning = numberOfTicket * (amount / totalWinningTicket);
        return winning;
    }
}