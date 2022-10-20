pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract DewinBet is AccessControl, ReentrancyGuard {

    using Counters for Counters.Counter;
    event CreateMatch(uint256 indexed id, Match, BetPair);
    event Bet(address account, uint256 indexed id, uint256 betPairIndex, uint256 optionPairIndex, uint256 amount);
    event Refund(address account, uint256 id, uint256 betPairIndex, uint256 optionPairIndex, uint256 amount);
    event Claim(address account, uint256 id, uint256 betPairIndex, uint256 optionPairIndex, uint256 amount);

    uint256 constant DECIMAL = 10000;
    bytes32 public constant COMMITER_ROLE = keccak256("COMMITER_ROLE");
    Counters.Counter private _nonce;

    address public benefiter;
    mapping (uint256 => Match) public matchInfos;
    mapping (uint256 => uint256) public totalMatchBet;
    mapping (uint256 => Win) private winInfo;
    mapping (uint256 => BetPair) private pairInfos;
    mapping (address => mapping (uint256 => BetInfo)) public userBetInfos; // account => match id => info
    mapping (uint256 => Status) private _matchStatus;

    enum Status {
        NONE, // not create

        NORMAL, // include CREATED_WAIT_BET BETTING WAIT_REVEAL
        REVEALED,
        CANCELED, // match has been canceled, usr can withdraw his token
        SUSPENDED, // match suspended, wait manual operate

        CREATED_WAIT_BET,
        BETTING,
        WAIT_REVEAL
    }

    struct BetInfo {
        mapping (uint256 => mapping (uint256 => uint256)) usrBet; // bet pair index => option pair index => token amount
        mapping (uint256 => mapping (uint256 => uint256)) usrClaim; // bet pair index => option pair index => claim amount
        mapping (uint256 => bool) kindBet; // bet pair index is bet ?
        uint256 betNumKind;
        uint256 totalBetAmount;
    }

    struct Win {
        uint256[] optionIndexs;
        uint256[] rewardPerShares; // already * DECIMAL  provied 2.1 -> 2.1* 10000 = 21000
    }

    struct Match {
        address betToken;
        uint256 fee; // 5.0%  0.05 * DECIMAL = 500
        uint256 startTime;
        uint256 endTime;
        string homeTeam;
        string awayTeam;
        string matchName;
        string matchType;
        uint256 maxBetNumKindForEach;
        uint256 maxBetAmountForEach;
        uint256 maxBetCap;
    }

    struct OptionPair {
        string[] options;
        uint256[] amounts;
        uint256 cap;
    }

    struct BetPair {
        OptionPair[] pairs;
    }

   constructor() {

        benefiter = _msgSender();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(COMMITER_ROLE, _msgSender());
        _setRoleAdmin(COMMITER_ROLE, DEFAULT_ADMIN_ROLE);
    }

    function matchStatus(uint256 id)  public view returns (Status) {
        Match memory match_ = matchInfos[id];
        Status status = _matchStatus[id];
        if (status == Status.NORMAL) {
            if (match_.startTime > block.timestamp) {
                return Status.CREATED_WAIT_BET;
            } else if (match_.startTime <= block.timestamp && match_.endTime >= block.timestamp) {
                return Status.BETTING;
            } else if (match_.endTime < block.timestamp) {
                return Status.WAIT_REVEAL;
            }
        }
        return status;
    }

    function bet(uint256 id, uint256 betPairIndex, uint256 optionPairIndex, uint256 amount) external nonReentrant notContract {
        Match memory match_ = matchInfos[id];
        BetPair storage betPair = pairInfos[id];
        BetInfo storage betInfo = userBetInfos[_msgSender()][id];
        require(matchStatus(id) == Status.BETTING, "not betting time");
        require(totalMatchBet[id] + amount <= match_.maxBetCap, "over max bet cap");
        require(betPair.pairs[betPairIndex].amounts[optionPairIndex] + amount <= betPair.pairs[betPairIndex].cap, "over pair cap");
        require(betInfo.usrBet[betPairIndex][optionPairIndex] + amount <= match_.maxBetAmountForEach, "over each person cap");
        uint256 kindBet = betInfo.betNumKind;
        if (!betInfo.kindBet[betPairIndex]) {
            kindBet++;
        }
        require(kindBet <= match_.maxBetNumKindForEach, "over each person bet kinds");

        IERC20 token = IERC20(match_.betToken);
        token.transferFrom(_msgSender(), address(this), amount);
        _userBet(_msgSender(), id, betPairIndex, optionPairIndex, amount);
        betPair.pairs[betPairIndex].amounts[optionPairIndex] += amount;
        totalMatchBet[id] += amount;
    }

    function _userBet(address account, uint256 id, uint256 betPairIndex, uint256 optionPairIndex, uint256 amount) internal {
        BetInfo storage betInfo = userBetInfos[account][id];
        betInfo.usrBet[betPairIndex][optionPairIndex] += amount;
        if (!betInfo.kindBet[betPairIndex]) {
            betInfo.kindBet[betPairIndex] = true;
            betInfo.betNumKind += 1;
        }
        betInfo.totalBetAmount += amount;
        emit Bet(account, id, betPairIndex, optionPairIndex, amount);
    }

    function _createMatch(address account, uint256 id, Match memory match_, BetPair calldata betPair) internal {
        require(id == _useNonce(), "nonce error");
        require(betPair.pairs.length > 0, "bet pairs error");
        require(match_.fee < DECIMAL, "fee error");
        uint256 totalAmount = 0;
        for (uint i = 0; i < betPair.pairs.length; i++) {
            require(betPair.pairs[i].options.length > 1 && betPair.pairs[i].options.length == betPair.pairs[i].amounts.length, "single pair error");
            for (uint j = 0; j < betPair.pairs[i].options.length; j++) {
                _userBet(account, id, i, j, betPair.pairs[i].amounts[j]);
                totalAmount += betPair.pairs[i].amounts[j];
            }
        }
        IERC20 token = IERC20(match_.betToken);
        token.transferFrom(_msgSender(), address(this), totalAmount);

        matchInfos[id] = match_;
        _matchStatus[id] = Status.NORMAL;

        pairInfos[id] = betPair;
        totalMatchBet[id] += totalAmount;
        emit CreateMatch(id, match_, betPair);
    }

    function batchCreateMatch(uint256 id, Match[] memory matchs, BetPair[] calldata betPairs) external onlyRole(COMMITER_ROLE) {
        for (uint i = 0; i < matchs.length; i++) {
            _createMatch(_msgSender(), id + i, matchs[i], betPairs[i]);
        }
    }

    function cancelMatch(uint256 id) external onlyRole(COMMITER_ROLE) {
        require(_matchStatus[id] == Status.NORMAL, "must be NORMAL");
        _matchStatus[id] = Status.CANCELED;
    }

    function suspendMatch(uint256 id) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_matchStatus[id] != Status.CANCELED, "CANCELED cant suspend");
        _matchStatus[id] = Status.SUSPENDED;
    }

    function reveal(uint256 id, uint256[] calldata optionIndexs_) external onlyRole(COMMITER_ROLE) {
        require(matchStatus(id) == Status.WAIT_REVEAL, "status error");
        _matchStatus[id] = Status.REVEALED;

        BetPair memory betPair = pairInfos[id];
        require(betPair.pairs.length == optionIndexs_.length, "option index length error");
        uint256[] memory optionIndexs = new uint256[](optionIndexs_.length);
        uint256[] memory rewardPerShares = new uint256[](optionIndexs_.length);
        Match memory match_ = matchInfos[id];
        for (uint256 i = 0; i < optionIndexs_.length; i++) {
            require(betPair.pairs[i].options.length > optionIndexs_[i], "option index over range");
            optionIndexs[i] = optionIndexs_[i];
            uint256 totalAmount = 0;
            for (uint256 j = 0; j < betPair.pairs[i].amounts.length; j++) {
                totalAmount += betPair.pairs[i].amounts[j];
            }
            uint256 payFee = totalAmount * DECIMAL / match_.fee;
            IERC20(match_.betToken).transfer(benefiter, payFee);
            rewardPerShares[i] = (totalAmount - payFee) * DECIMAL / betPair.pairs[i].amounts[optionIndexs_[i]];
        }
        winInfo[id].optionIndexs = optionIndexs;
        winInfo[id].rewardPerShares = rewardPerShares;
    }

    function batchClaim(uint256[] calldata ids, uint256[] calldata betPairIndexs, uint256[] calldata optionPairIndexs) external nonReentrant notContract {
        for (uint256 i = 0; i < ids.length; i++) {
            _claim(_msgSender(), ids[i], betPairIndexs[i], optionPairIndexs[i]);
        }
    }

    function _claim(address account, uint256 id, uint256 betPairIndex, uint256 optionPairIndex) internal {
        require(matchStatus(id) == Status.REVEALED, "match not REVEALED");
        Win memory win = winInfo[id];
        require(win.optionIndexs[betPairIndex] == optionPairIndex, "option pair lose");

        BetInfo storage betInfo = userBetInfos[account][id];
        uint256 reward = betInfo.usrBet[betPairIndex][optionPairIndex] * win.rewardPerShares[betPairIndex] / DECIMAL;
        uint256 waitClaimAmount = reward - betInfo.usrClaim[betPairIndex][optionPairIndex];
        require(betInfo.usrBet[betPairIndex][optionPairIndex] > 0, "bet amount zero");
        require(waitClaimAmount > 0, "all claimed");

        betInfo.usrClaim[betPairIndex][optionPairIndex] = reward;

        IERC20(matchInfos[id].betToken).transfer(account, waitClaimAmount);
        emit Claim(account, id, betPairIndex, optionPairIndex, waitClaimAmount);
    }

    function batchRefund(uint256[] calldata ids, uint256[] calldata betPairIndexs, uint256[] calldata optionPairIndexs) external nonReentrant notContract {
        for (uint256 i = 0; i < ids.length; i++) {
            _refund(_msgSender(), ids[i], betPairIndexs[i], optionPairIndexs[i]);
        }
    }

    function _refund(address account, uint256 id, uint256 betPairIndex, uint256 optionPairIndex) internal {
        require(matchStatus(id) == Status.CANCELED, "match not canceled");

        Match memory match_ = matchInfos[id];
        BetPair storage betPair = pairInfos[id];
        BetInfo storage betInfo = userBetInfos[account][id];

        uint256 amount = betPair.pairs[betPairIndex].amounts[optionPairIndex];
        require(amount > 0, "not bet");

        betPair.pairs[betPairIndex].amounts[optionPairIndex] = 0;
        
        betInfo.usrBet[betPairIndex][optionPairIndex] -= amount;
        betInfo.kindBet[betPairIndex] = false;
        betInfo.betNumKind -= 1;
        betInfo.totalBetAmount -= amount;

        totalMatchBet[id] -= amount;

        IERC20 token = IERC20(match_.betToken);
        token.transfer(account, amount);

        emit Refund(account, id, betPairIndex, optionPairIndex, amount);
    }

    function getPairInfo(uint256 id) external view returns (BetPair memory) {
        return pairInfos[id];
    }

    function getWinInfo(uint256 id) external view returns (Win memory) {
        return winInfo[id];
    }

    function emergencyClaim(address token, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC20(token).transfer(_msgSender(), amount);
    }

    function setBenefiter(address benefiter_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(benefiter_ != address(0));
        benefiter = benefiter_;
    }

    function _useNonce() internal returns (uint256 current) {
        current = _nonce.current();
        _nonce.increment();
    }

    function nonce() public view returns (uint256) {
        return _nonce.current();
    }

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    function _isContract(address _addr) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}