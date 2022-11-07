/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

/*

BBTC Wallet To Wallet Transfer helper

Send tokens between wallets with a 0% fee.

Baby Bitcoin - Prince of Crypto
https://babybitcoin.finance/

*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/utils/math/SignedSafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SignedSafeMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SignedSafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SignedSafeMath {
    /**
     * @dev Returns the multiplication of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two signed integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        return a / b;
    }

    /**
     * @dev Returns the subtraction of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        return a - b;
    }

    /**
     * @dev Returns the addition of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        return a + b;
    }
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: BBTC_freeWalletSender.sol


pragma solidity >=0.8.7 <0.9.0;


interface IBEP20 {
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

struct TxInfo {
    uint256 id;
    address from;
    address to;
    uint256 amount;
    uint256 timestamp;
}

contract BBTCWalletSender is ReentrancyGuard {

    using SafeMath for uint256;
    using SignedSafeMath for int256;

    address private _tokenContract;
    uint256 private _txCount;
    mapping(uint256 => TxInfo) private _txInfo;
    mapping(address => uint256[]) private _walletSendTx;
    mapping(address => uint256[]) private _walletReceiveTx;

    event TokenTransfer(
        uint256 id,
        address from,
        address to,
        uint256 amount,
        uint256 timestamp
    );

    constructor() {
        _tokenContract = 0x8Ccd38C965DE0597b3AaDF9dfbcb82FC90E674Fe; //BBTC Contract
        _txCount = 1;
    }

    function getTxLength() public view returns (uint256) {
        return _txCount;
    }

    function getTxInfo(uint256 _txId) public view returns (TxInfo memory) {        
        return _txInfo[_txId];
    }

    function getTxList(int256 page, int256 pageSize) public view returns (TxInfo[] memory) {
        uint256 txLength = getTxLength();
        int256 queryStartTxIndex = int256(txLength).sub(pageSize.mul(page)).add(pageSize).sub(1);
        require(queryStartTxIndex >= 0, "Out of bounds");
        int256 queryEndTxIndex = queryStartTxIndex.sub(pageSize);
        if (queryEndTxIndex < 0) {
            queryEndTxIndex = 0;
        }
        int256 currentTxIndex = queryStartTxIndex;
        require(uint256(currentTxIndex) <= txLength.sub(1), "Out of bounds");
        TxInfo[] memory results = new TxInfo[](uint256(currentTxIndex - queryEndTxIndex));
        uint256 index = 0;

        for (currentTxIndex; currentTxIndex > queryEndTxIndex; currentTxIndex--) {
            uint256 currentVerificationIndexAsUnsigned = uint256(currentTxIndex);
            if (currentVerificationIndexAsUnsigned <= txLength.sub(1)) {
                results[index] = getTxInfo(currentVerificationIndexAsUnsigned);
            }
            index++;
        }
        return results;
    }

    function getTxOfUserSendLength(address wallet) public view returns (uint256){
        return _walletSendTx[wallet].length;
    }

    function getTxOfUserReceiveLength(address wallet) public view returns (uint256){
        return _walletReceiveTx[wallet].length;
    }

    function getTxOfUserSend(address wallet, uint256 arIndex, uint256 arEnd) public view returns (TxInfo[] memory) {
        uint256 txOfUserSendLength = _walletSendTx[wallet].length;
        if (arEnd<txOfUserSendLength){
            txOfUserSendLength = arEnd;
        }

        TxInfo[] memory results = new TxInfo[](uint256(txOfUserSendLength-arIndex));
        uint256 index = 0;
        uint256 current = arIndex;

        for (current; current < txOfUserSendLength; current++) {
            uint256 currentVerificationIndexAsUnsigned = _walletSendTx[wallet][current];
            results[index] = getTxInfo(currentVerificationIndexAsUnsigned);
            index++;
        }
        return results;
    }

    function getTxOfUserReceive(address wallet, uint256 arIndex, uint256 arEnd) public view returns (TxInfo[] memory) {
        uint256 txOfUserReceiveLength = _walletReceiveTx[wallet].length;
        if (arEnd<txOfUserReceiveLength){
            txOfUserReceiveLength = arEnd;
        }

        TxInfo[] memory results = new TxInfo[](uint256(txOfUserReceiveLength-arIndex));
        uint256 index = 0;
        uint256 current = arIndex;

        for (current; current < txOfUserReceiveLength; current++) {
            uint256 currentVerificationIndexAsUnsigned = _walletReceiveTx[wallet][current];
            results[index] = getTxInfo(currentVerificationIndexAsUnsigned);
            index++;
        }
        return results;
    }


    function transferTokens(address _to, uint256 _amount) public nonReentrant {

        require(msg.sender == tx.origin,
            "Only EOA allowed"
        );

        require(msg.sender != address(0), "IBEP20: transfer from the zero address");

        require(_to != address(0), "IBEP20: transfer to the zero address");

        require(_to != address(this), "IBEP20: transfer to this contract address");

        require(_to != address(_tokenContract), "IBEP20: transfer to token contract address");

        require(_amount > 0, "Transfer amount must be greater than zero");

        require(IBEP20(_tokenContract).allowance(msg.sender, address(this)) >= _amount, "Allowance required");

        require(IBEP20(_tokenContract).transferFrom(msg.sender, _to, _amount) == true, "Error in transfer");

        uint256 index = _txCount++;
        TxInfo storage txInfo = _txInfo[index];

        txInfo.id = index;
        txInfo.from = msg.sender;
        txInfo.to = _to;
        txInfo.amount = _amount;
        txInfo.timestamp = block.timestamp;

        _walletSendTx[msg.sender].push(index);
        _walletReceiveTx[_to].push(index);

        emit TokenTransfer(txInfo.id, txInfo.from, txInfo.to, txInfo.amount, txInfo.timestamp);

    }

}