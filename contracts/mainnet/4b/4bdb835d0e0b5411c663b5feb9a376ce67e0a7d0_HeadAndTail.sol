/**
 *Submitted for verification at BscScan.com on 2022-12-09
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

contract HeadAndTail is Pausable {
    using Address for address;
    uint256 public devFee = 250; // 2.5% fee for each other player per game
    address devFeeAddress = 0xe5F50Be3D15C2A601880218A1058E26e3a3BE22c;
    // uint256 maxOpeningGame = 3;
    uint256 mintAmount = 0.01 ether;
    bool mustDifferencePrediction = true;
    event OpenGame(
        uint256 indexed player1GameId,
        uint256 indexed player2GameId
    );
    event EndGame(uint256 indexed player1GameId, uint256 indexed player2GameId);

    enum COIN_SIDE {
        NONE, //0
        HEAD, //1
        TAIL //2
    }

    struct Game {
        address player1;
        address player2;
        uint256 amount;
        COIN_SIDE player1Prediction;
        COIN_SIDE player2Prediction;
        address winner;
        //uint256 created;
        uint256 player1GameId;
        uint256 player2GameId;
    }

    uint256[] internal openingGames;
    mapping(uint256 => Game) games;
    mapping(uint256 => uint256) joinedGames;

    struct HelperState {
        uint256 devFee;
        uint256 totalOpeningGame;
        uint256 mintAmount;
        bool mustDifferencePrediction;
    }

    function _state() external view returns (HelperState memory) {
        return
            HelperState({
                devFee: devFee,
                totalOpeningGame: openingGames.length,
                mintAmount: mintAmount,
                mustDifferencePrediction: mustDifferencePrediction
            });
    }

    function cancelGame(uint256 id, address player1)
        external
        whenNotPaused
        onlyOwner
    {
        _cancelGame(id, player1);
    }

    function cancelAllGame() external whenNotPaused onlyOwner {
        uint256[] memory _openingGames = openingGames;
        uint256 oglength = _openingGames.length;
        for (uint256 i = 0; i < oglength; ) {
            if (games[_openingGames[i]].winner == address(0)) {
                // cancel this game
                _cancelGame(_openingGames[i], games[_openingGames[i]].player1);
                unchecked {
                    --oglength;
                }
                if (i >= oglength) {
                    return;
                }
            } else {
                unchecked {
                    ++i;
                }
            }
        }
    }

    function cancelMyGame(uint256 id) external whenNotPaused {
        _cancelGame(id, msg.sender);
    }

    function cancelAllMyGame() external whenNotPaused {
        uint256[] memory _openingGames = openingGames;
        uint256 oglength = _openingGames.length;
        for (uint256 i = 0; i < oglength; ) {
            if (
                games[_openingGames[i]].winner == address(0) &&
                games[_openingGames[i]].player1 == msg.sender
            ) {
                // cancel this game
                _cancelGame(_openingGames[i], games[_openingGames[i]].player1);
                unchecked {
                    --oglength;
                }
                if (i >= oglength) {
                    return;
                }
            } else {
                unchecked {
                    ++i;
                }
            }
        }
    }

    function _cancelGame(uint256 id, address player1) internal {
        require(games[id].winner == address(0), "game has finished");
        require(games[id].player1 == player1, "not player1 game");
        payable(games[id].player1).transfer(games[id].amount);
        games[id].player1 = address(0);
        games[id].player1Prediction = COIN_SIDE.NONE;
        games[id].amount = 0;
        // removeGameIdFromPlayer(player1, id);
        closeOpeningGame(id);
    }

    function joinGame(uint256 id, uint256 player2GameId)
        external
        payable
        whenNotPaused
    {
        require(games[id].player1 != address(0), "game not exists");
        require(
            (games[id].player1Prediction == COIN_SIDE.HEAD ||
                games[id].player1Prediction == COIN_SIDE.TAIL) &&
                games[id].winner == address(0),
            "game has finished"
        );
        require(
            msg.value >=
                games[id].amount + (devFee * (games[id].amount / 10000)) &&
                msg.value >= mintAmount,
            "wrong amount"
        );

        games[id].player2 = msg.sender;
        games[id].player2Prediction = games[id].player1Prediction ==
            COIN_SIDE.HEAD
            ? COIN_SIDE.TAIL
            : COIN_SIDE.HEAD;
        COIN_SIDE win = getRandomNumber(games[id].player2GameId) == 0
            ? COIN_SIDE.HEAD
            : COIN_SIDE.TAIL;

        if (mustDifferencePrediction) {
            if (games[id].player1Prediction == win) {
                games[id].winner = games[id].player1;
                payable(games[id].player1).transfer(2 * games[id].amount);
            } else {
                games[id].winner = games[id].player2;
                payable(games[id].player2).transfer(2 * games[id].amount);
            }
        } else {
            if (COIN_SIDE.HEAD == win) {
                games[id].winner = games[id].player1;
                payable(games[id].player1).transfer(2 * games[id].amount);
            } else {
                games[id].winner = games[id].player2;
                payable(games[id].player2).transfer(2 * games[id].amount);
            }
        }

        payable(devFeeAddress).transfer(msg.value - games[id].amount);
        // addGameIdToPlayer(msg.sender, id);
        joinedGames[player2GameId] = id;
        closeOpeningGame(id);
        emit EndGame(id, 0);
    }

    function flipCoin(
        COIN_SIDE prediction,
        uint256 amount,
        uint256 id
    ) external payable whenNotPaused {
        require(
            msg.value >= mintAmount &&
                msg.value >= amount + (devFee * (amount / 10000)),
            "wrong amount"
        );
        require(
            prediction == COIN_SIDE.HEAD || prediction == COIN_SIDE.TAIL,
            "wrong prediction"
        );

        require(games[id].player1 == address(0), "id exists");

        uint256 oldid;
        uint256[] memory _openingGames = openingGames;
        uint256 oglength = _openingGames.length;
        for (uint256 i = 0; i < oglength; ) {
            if (
                games[_openingGames[i]].amount == amount &&
                games[_openingGames[i]].player1 != msg.sender
            ) {
                //join this game and flip a coin
                if (
                    games[_openingGames[i]].winner == address(0) &&
                    (mustDifferencePrediction == false ||
                        games[_openingGames[i]].player1Prediction != prediction)
                ) {
                    oldid = _openingGames[i];
                    break;
                }
            }

            unchecked {
                ++i;
            }
        }
        if (oldid > 0) {
            COIN_SIDE win = getRandomNumber(games[id].player2GameId) == 0
                ? COIN_SIDE.HEAD
                : COIN_SIDE.TAIL;

            games[oldid].player2 = msg.sender;
            games[oldid].player2Prediction = prediction;
            games[oldid].player2GameId = id;
            if (mustDifferencePrediction) {
                if (games[oldid].player1Prediction == win) {
                    games[oldid].winner = games[oldid].player1;
                    payable(games[oldid].player1).transfer(2 * amount);
                } else {
                    games[oldid].winner = games[oldid].player2;
                    payable(games[oldid].player2).transfer(2 * amount);
                }
            } else {
                if (COIN_SIDE.HEAD == win) {
                    games[oldid].winner = games[oldid].player1;
                    payable(games[oldid].player1).transfer(2 * amount);
                } else {
                    games[oldid].winner = games[oldid].player2;
                    payable(games[oldid].player2).transfer(2 * amount);
                }
            }
            payable(devFeeAddress).transfer(msg.value - amount);
            // addGameIdToPlayer(msg.sender, oldid);
            joinedGames[id] = oldid;
            closeOpeningGame(oldid);
            emit EndGame(oldid, id);
        } else {
            games[id].player1 = msg.sender;
            games[id].amount = amount;
            games[id].player1Prediction = prediction;
            games[id].player1GameId = id;
            payable(devFeeAddress).transfer(msg.value - amount);

            openingGames.push(id);
            //addGameIdToPlayer(msg.sender, id);
            emit OpenGame(id, 0);
        }
    }

    // function countOpeningGameOfPlayer(address player)
    //     internal
    //     view
    //     returns (uint256)
    // {
    //     uint256 total = 0;
    //     for (uint256 i = 0; i < players[player].length; ++i) {
    //         if (
    //             games[players[player][i]].winner == address(0) &&
    //             games[players[player][i]].player1 == player
    //         ) {
    //             total++;
    //         }
    //     }
    //     return total;
    // }

    // function addGameIdToPlayer(address player, uint256 gameId) internal {
    //     if (players[player].length < maxOpeningGame) {
    //         players[player].push(gameId);
    //     } else {
    //         for (uint256 i = 0; i < players[player].length; ++i) {
    //             if (
    //                 games[players[player][i]].win != COIN_SIDE.NONE &&
    //                 games[players[player][i]].player2 != address(0)
    //             ) {
    //                 if (players[player].length > 1) {
    //                     players[player][i] = players[player][
    //                         players[player].length - 1
    //                     ];
    //                 }
    //                 players[player].pop();
    //                 players[player].push(gameId);
    //                 return;
    //             }
    //         }
    //     }
    // }

    // function removeGameIdFromPlayer(address player, uint256 gameId) internal {
    //     if (players[player].length <= 0) {
    //         return;
    //     }
    //     for (uint256 i = 0; i < players[player].length; ++i) {
    //         if (players[player][i] == gameId) {
    //             if (players[player].length > 1) {
    //                 players[player][i] = players[player][
    //                     players[player].length - 1
    //                 ];
    //             }
    //             players[player].pop();
    //             return;
    //         }
    //     }
    // }

    function getGame(uint256 id) external view returns (Game memory) {
        if (games[id].player1 == address(0)) {
            return games[joinedGames[id]];
        } else {
            return games[id];
        }
    }

    // function getGames(address player) external view returns (uint256[] memory) {
    //     return players[player];
    // }

    function getOpeningGames(uint256 skip, uint256 limit)
        external
        view
        returns (uint256[] memory)
    {
        if (openingGames.length > skip) {
            uint256[] memory result = new uint256[](limit);
            uint256 index = 0;
            uint256[] memory _openingGames = openingGames;
            uint256 alength = skip + limit >= _openingGames.length
                ? _openingGames.length
                : skip + limit;
            for (uint256 i = skip; i < alength; ) {
                result[index] = _openingGames[i];
                unchecked {
                    index++;
                    ++i;
                }
            }
            return result;
        }
        return new uint256[](0);
    }

    constructor() {
        devFeeAddress = msg.sender;
    }

    function getRandomNumber(uint256 prediction)
        internal
        view
        returns (uint256)
    {
        return (prediction + block.timestamp + block.difficulty) % 2;
    }

    function closeOpeningGame(uint256 id) internal {
        uint256[] memory _openingGames = openingGames;
        if (openingGames.length <= 0) {
            return;
        }
        uint256 length = _openingGames.length;
        for (uint256 i = 0; i < length; ) {
            if (id == _openingGames[i]) {
                if (_openingGames.length > 1) {
                    openingGames[i] = _openingGames[_openingGames.length - 1];
                }
                openingGames.pop();
                return;
            }
            unchecked {
                ++i;
            }
        }
    }

    function deposit() external payable {
        return;
    }

    // function _getAmountToWithdraw() internal view returns (uint256) {
    //     uint256 skipAmount = 0;
    //     uint256 ugLength = openingGames.length;
    //     for (uint256 i = 0; i < ugLength; ) {
    //         skipAmount += games[openingGames[i]].amount;
    //         unchecked {
    //             ++i;
    //         }
    //     }
    //     return address(this).balance - skipAmount;
    // }

    // function getAmountToWithdraw() external view returns (uint256) {
    //     return _getAmountToWithdraw();
    // }

    // function withdrawTo(address to, uint256 amount) external onlyOwner {
    //     uint256 remainAmount = _getAmountToWithdraw();
    //     require(amount <= remainAmount, "Exceed balance of contract");
    //     payable(to).transfer(amount);
    // }

    function setDevFee(uint256 _devFee) external onlyOwner {
        require(_devFee <= 1000, "always less than 10%");
        require(_devFee >= 0, "_");
        devFee = _devFee;
    }

    function setDevFeeAddress(address _devFeeAddress) external onlyOwner {
        devFeeAddress = _devFeeAddress;
    }

    // function setMaxOpeningGame(uint256 _maxOpeningGame) external onlyOwner {
    //     require(_maxOpeningGame > 0, "_");
    //     maxOpeningGame = _maxOpeningGame;
    // }

    function setMintAmount(uint256 _mintAmount) external onlyOwner {
        require(_mintAmount > 0, "_");
        mintAmount = _mintAmount;
    }

    function flipMustDifferencePrediction() external onlyOwner {
        mustDifferencePrediction = !mustDifferencePrediction;
    }
}