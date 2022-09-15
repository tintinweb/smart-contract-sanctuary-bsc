// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ERC20Interface.sol";
import {Verification} from "./Verification.sol";

// This line is added for temporary use
contract Deskillz is Ownable, Verification {
    address busdAddress;
    uint256 BUSDToLP;
    uint256 AdminShare;
    constructor(address _busd, uint256 _BUSDToLP) {
        busdAddress = _busd;
        BUSDToLP = _BUSDToLP;
    }
    using SafeMath for uint256;
    mapping(address => mapping(uint256 => bool)) seenNonces;
    mapping(uint256 => uint256) gamesBalances;
    mapping(address => uint256) developersBalances;
    mapping(address => uint256) playersBalances;
    mapping(uint256 => address) gamesDevelopers;
    mapping(uint256 => uint256) tournamentGame;
    
    struct TournamentParticipationData {
        string encodeKey;
        uint256 nonce;
        bytes signature;
        uint256 amount;
        address developer;
        uint256 game;
        uint256 tournamentId;
    }
    struct WithdrawData {
        string encodeKey;
        uint256 nonce;
        bytes signature;
        uint256 amount;
    }
    struct RefundData {
        string encodeKey;
        uint256 nonce;
        bytes signature;
        uint256 amount;
        uint256 tournamentId;
    }
    struct LoyaltyPointsConversionData {
        string encodeKey;
        uint256 nonce;
        bytes signature;
        uint256 amount;
    }
    function tournamentParticipation(TournamentParticipationData memory _tournamentParticipation) external payable {
        require(!seenNonces[msg.sender][_tournamentParticipation.nonce], "Invalid request");
        seenNonces[msg.sender][_tournamentParticipation.nonce] = true;
        require(verify(msg.sender, msg.sender, _tournamentParticipation.amount, _tournamentParticipation.encodeKey, _tournamentParticipation.nonce, _tournamentParticipation.signature), "invalid signature");
        uint256 platformSharePercent = calculatePercentValue(_tournamentParticipation.amount, AdminShare);
        transferFromERC20(msg.sender, address(this), _tournamentParticipation.amount, busdAddress);
        uint256 gameBalance = gamesBalances[_tournamentParticipation.game] + (_tournamentParticipation.amount-platformSharePercent);
        gamesBalances[_tournamentParticipation.game] = gameBalance;
        gamesDevelopers[_tournamentParticipation.game] = _tournamentParticipation.developer;
        tournamentGame[_tournamentParticipation.tournamentId] = _tournamentParticipation.game;
        uint256 developerBalance = developersBalances[_tournamentParticipation.developer] + (_tournamentParticipation.amount - platformSharePercent);
        developersBalances[_tournamentParticipation.developer] = developerBalance;
    }
    function loyaltyPointsConversion(LoyaltyPointsConversionData memory _loyaltyPointsConversionData) external {
        require(!seenNonces[msg.sender][_loyaltyPointsConversionData.nonce], "Invalid request");
        seenNonces[msg.sender][_loyaltyPointsConversionData.nonce] = true;
        require(verify(msg.sender, msg.sender, _loyaltyPointsConversionData.amount, _loyaltyPointsConversionData.encodeKey, _loyaltyPointsConversionData.nonce, _loyaltyPointsConversionData.signature), "invalid signature");
        uint256 busd = calculateBUSD(_loyaltyPointsConversionData.amount);
        uint256 playerBalance = playersBalances[msg.sender] + busd;
        playersBalances[msg.sender] = playerBalance;
    }
    function checkPlayerBalance (address player) view public returns(uint256) {
        return playersBalances[player];
    }
    function checkDeveloperBalance (address developer) view public returns(uint256) {
        return developersBalances[developer];
    }
    function withdrawPlayerBanalce(WithdrawData memory _withdrawData) external {
        require(!seenNonces[msg.sender][_withdrawData.nonce], "Invalid request");
        seenNonces[msg.sender][_withdrawData.nonce] = true;
        require(verify(msg.sender, msg.sender, _withdrawData.amount, _withdrawData.encodeKey, _withdrawData.nonce, _withdrawData.signature), "invalid signature");
        uint256 playerBalance = playersBalances[msg.sender];
        require(playerBalance >= _withdrawData.amount);
        transferERC20(msg.sender, _withdrawData.amount, busdAddress);
        playersBalances[msg.sender] = playerBalance - _withdrawData.amount;
    }
    function refundParticipation(RefundData memory _refundData) external {
        require(!seenNonces[msg.sender][_refundData.nonce], "Invalid request");
        seenNonces[msg.sender][_refundData.nonce] = true;
        require(verify(msg.sender, msg.sender, _refundData.amount, _refundData.encodeKey, _refundData.nonce, _refundData.signature), "invalid signature");
        uint256 gameId = tournamentGame[_refundData.tournamentId];
        address developer = gamesDevelopers[gameId];
        developersBalances[msg.sender] = developersBalances[developer] - _refundData.amount;
        transferERC20(msg.sender, _refundData.amount, busdAddress);
    }
    function withdrawDeveloperBanalce(WithdrawData memory _withdrawData) external {
        require(!seenNonces[msg.sender][_withdrawData.nonce], "Invalid request");
        seenNonces[msg.sender][_withdrawData.nonce] = true;
        require(verify(msg.sender, msg.sender, _withdrawData.amount, _withdrawData.encodeKey, _withdrawData.nonce, _withdrawData.signature), "invalid signature");
        uint256 developerBalance = developersBalances[msg.sender];
        require(developerBalance >= _withdrawData.amount);
        transferERC20(msg.sender, _withdrawData.amount, busdAddress);
        developersBalances[msg.sender] = developerBalance - _withdrawData.amount;
    }
    function calculatePercentValue(uint256 total, uint256 percent) pure private returns(uint256) {
        uint256 division = total.mul(percent);
        uint256 percentValue = division.div(100);
        return percentValue;
    }
    fallback () payable external {}
    receive () payable external {}
    function transferFromERC20(address from, address to, uint256 amount, address tokenAddress) private {
        IERC20Token token = IERC20Token(tokenAddress);
        uint256 balance = token.balanceOf(from);
        require(balance >= amount, "insufficient balance" );
        token.transferFrom(from, to, amount);
    }
    function transferERC20(address to, uint256 amount, address tokenAddress) private {
        IERC20Token token = IERC20Token(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance >= amount, "insufficient balance" );
        token.transfer(to, amount);
    }
    function withdrawBNB() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
    function withdrawBUSD() public onlyOwner {
        IERC20Token busd = IERC20Token(busdAddress);
        uint256 balance = busd.balanceOf(address(this));
        require(balance >= 0, "insufficient balance" );
        busd.transfer(owner(), balance);
    }
    function updateLPToBUSD(uint256 _BUSDToLP) public onlyOwner {
        BUSDToLP = _BUSDToLP;
    }
    function calculateBUSD(uint256 lpValue) view public returns(uint256) {
        return lpValue.div(BUSDToLP);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Verification {
    function verify( address _signer, address _to, uint256 _amount, string memory _message, uint256 _nonce, bytes memory signature) internal pure returns (bool) {
        bytes32 messageHash = getMessageHash(_to, _amount, _message, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }
    function getMessageHash( address _to, uint256 _amount, string memory _message, uint256 _nonce) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount, _message, _nonce));
    }
    function getEthSignedMessageHash(bytes32 _messageHash) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }
    function splitSignature(bytes memory sig) internal pure returns ( bytes32 r, bytes32 s, uint8 v ) {
        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20Token { //BUSD
    function transferFrom(address _from,address _to, uint _value) external returns (bool success);
    function balanceOf(address _owner) external returns (uint balance);
    function transfer(address _to, uint256 _amount) external returns (bool);
}

// SPDX-License-Identifier: MIT
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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