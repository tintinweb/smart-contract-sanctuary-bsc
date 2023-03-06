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

pragma solidity 0.8.6;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract STO is Context, Ownable {
    using SafeMath for uint256;

    uint256 public rate;
    IERC20 private token;
    address private wallet;

    uint256 public softCap;
    uint256 public hardCap;

    uint256 private weiRaised;
    uint256 public endSTODate;
    uint256 public startSTODate;

    uint256 public minPurchase;
    uint256 public maxPurchase;
    uint256 public availableTokens;

    string[] acceptedCoins;
    mapping(string => address) acceptedCoin;

    mapping(address => bool) isClaimed;
    mapping(address => uint256) investedTotalOf;
    mapping(address => uint256) purchasedTokensOf;
    mapping(address => mapping(string => uint256)) investedCoinsOf;

    //This points if all claim processes were finished. After that, you can start another STO processes.
    bool public isFinished = true;

    event TokensPurchased(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    constructor(
        uint256 _rate,
        address _wallet,
        IERC20 _token
    ) {
        // When you deploying smart contract you shoul need to send all constructor data
        require(_rate > 0, "Pre-Sale: rate is 0");
        require(_wallet != address(0), "Pre-Sale: wallet is the zero address");
        require(
            address(_token) != address(0),
            "Pre-Sale: token is the zero address"
        );
        rate = _rate * 10**18;
        wallet = _wallet;
        token = _token;
    }

    modifier stoActive() {
        // Modifier that checking sto is active
        require(
            block.timestamp < endSTODate && hardCap > weiRaised,
            "Pre-Sale: STO must be active"
        );
        _;
    }
    modifier stoNotActive() {
        // Modifier that checking sto is should not be activated
        require(isFinished == true, "Pre-Sale: STO should not be active");
        _;
    }
    modifier stoSuccess() {
        require(
            hardCap <= weiRaised ||
                (endSTODate < block.timestamp && softCap <= weiRaised)
        );
        _;
    }
    modifier stoFailed() {
        require(endSTODate < block.timestamp && softCap > weiRaised);
        _;
    }

    //Start Pre-Sale
    function startSTO(
        uint256 _startSTO,
        uint256 _endSTO,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        uint256 _softCap,
        uint256 _hardCap
    ) external onlyOwner stoNotActive {
        // STO started by giving all data start time, end time, minimum token
        // could purchase, maximum token purchase limit, Token you want to sell, softcap must meet otherwise refund, hardcap all token sold nothing left
        // This function is only called by Owner.
        // STO should not active
        require(
            _startSTO > block.timestamp,
            "StartDate duration should be > 0"
        );
        require(_endSTO > _startSTO, "End Date should be > startDate");
        require(
            _softCap > 0 && _hardCap > _softCap,
            "Pre-Sale: softCap and hardCap should be > 0"
        );
        require(_minPurchase > 0, "Pre-Sale: _minPurchase should > 0");
        startSTODate = _startSTO;
        endSTODate = _endSTO;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        softCap = _softCap;
        hardCap = _hardCap;
        availableTokens = _getTokenAmount(_hardCap);
        isFinished = false;
    }

    function getCurrentTimestamp() public view returns (uint256) {
        // Its function just getting current block time from blockchain
        // Read only function called by any user
        return block.timestamp;
    }

    function getEndSTOTimestamp() public view returns (uint256) {
        // Get STO End Time
        // Readonly function called by any user return STO end time
        require(endSTODate > 0, "Error: Presale has finished already");
        return endSTODate;
    }

    function getStartSTOTimestamp() public view returns (uint256) {
        // Get STO Start Time
        // could call by any user its readonly function return sto start time when sto is started
        require(startSTODate > 0, "Error: Presale has not started yet");
        return startSTODate;
    }

    function buyTokens(
        address _beneficiary,
        uint256 _weiAmount,
        string memory _coinName
    ) public stoActive {
        // Through this function User Could Purchase Token by sending
        // beneficiary address whose get token, amount of Stable Coin he want to send, and _coinName stable token name like (USDT, USDC or nay other Token that you accepting)
        // Approve Stable coin of amount greater or equal to amount that you are passing.
        // _coinName is actually name of Stable Coins that you added it will be USDT or USDC or any other stable coin
        // STO should be active to call this function
        require(acceptedCoin[_coinName] != address(0), "Invalid Token");
        require(
            IERC20(acceptedCoin[_coinName]).balanceOf(_msgSender()) >=
                _weiAmount,
            "Not Enough Tokens"
        );
        require(
            IERC20(acceptedCoin[_coinName]).allowance(
                _msgSender(),
                address(this)
            ) >= _weiAmount,
            "NOT Enough Token Approved"
        );
        _preValidatePurchase(_beneficiary, _weiAmount);
        uint256 tokens = _getTokenAmount(_weiAmount);
        IERC20(acceptedCoin[_coinName]).transferFrom(
            _msgSender(),
            address(this),
            _weiAmount
        );
        weiRaised = weiRaised.add(_weiAmount);
        availableTokens = availableTokens.sub(tokens);
        isClaimed[_beneficiary] = false;
        investedTotalOf[_beneficiary] = investedTotalOf[_beneficiary].add(
            _weiAmount
        );
        purchasedTokensOf[_beneficiary] = purchasedTokensOf[_beneficiary].add(
            tokens
        );
        investedCoinsOf[_beneficiary][_coinName] = investedCoinsOf[
            _beneficiary
        ][_coinName].add(_weiAmount);
        _processPurchase(_beneficiary, tokens);
        emit TokensPurchased(_msgSender(), _beneficiary, _weiAmount, tokens);
    }

    /**
     *  @dev Internal function checking all rules and regulation before purchase token This is internal function no one could call from outside
     * @param _beneficiary Its beneficary address
     * @param _weiAmount wei amount
     * @notice Until and unless owner also couldn't call
     */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount)
        internal
        view
    {
        require(
            _beneficiary != address(0),
            "Pre-Sale: beneficiary is the zero address"
        );
        require(_weiAmount != 0, "Pre-Sale: weiAmount is 0");
        require(
            _weiAmount >= minPurchase,
            "have to send at least: minPurchase"
        );
        require(_weiAmount <= maxPurchase, "have to send max: maxPurchase");
        this;
    }

    /**
     *  @dev On Softcap Reached User could cliam token they will get Token on thier account  STO should not active when user calling claim Token
     * @param _beneficiary: User address whose get token
     * @notice All user Could call this but proceed those who has token
     */
    function claimToken(address _beneficiary) public stoSuccess {
        require(
            isClaimed[_beneficiary] == false,
            "Pre-Sale: You already claimed your tokens!"
        );
        isClaimed[_beneficiary] = true;
        _processPurchase(_beneficiary, purchasedTokensOf[_beneficiary]);
    }

    function claimRefund(address _beneficiary) public stoFailed {
        // If STO goal is not reached means softcap not rached then Investor/ User Claim thier fund that they spend for Purchse token
        require(
            isClaimed[_beneficiary] == false,
            "Pre-Sale: Only STO member can refund coins!"
        );
        isClaimed[_beneficiary] = true;
        for (uint256 i = 0; i < acceptedCoins.length; i++) {
            if (investedCoinsOf[_beneficiary][acceptedCoins[i]] > 0) {
                IERC20(acceptedCoin[acceptedCoins[i]]).transfer(
                    _beneficiary,
                    investedCoinsOf[_beneficiary][acceptedCoins[i]]
                );
            }
        }
    }

    function _deliverTokens(address _beneficiary, uint256 _tokenAmount)
        internal
    {
        // internal function which deliver Token to User
        token.transfer(_beneficiary, _tokenAmount);
    }

    function _processPurchase(
        // Internal function running _process Purchase
        address _beneficiary,
        uint256 _tokenAmount
    ) internal {
        _deliverTokens(_beneficiary, _tokenAmount);
    }

    function _getTokenAmount(
        // Internally Get Token Amount
        uint256 _weiAmount //amount in wei of USD from investor
    ) internal view returns (uint256) {
        return _weiAmount.div(rate).mul(10**18); // Here we need to double check if it is working properly the calc.
    }

    function withdraw() external stoSuccess onlyOwner {
        for (uint256 i = 0; i < acceptedCoins.length; i++) {
            IERC20(acceptedCoin[acceptedCoins[i]]).transfer(
                wallet,
                IERC20(acceptedCoin[acceptedCoins[i]]).balanceOf(address(this))
            );
        }
    }

    function getToken() public view returns (IERC20) {
        // Token Address that on sell
        return token;
    }

    function getWallet() public view returns (address) {
        // Wallet address that collecting fund or get withdraw funds
        return wallet;
    }

    function getRate() public view returns (uint256) {
        // Get Rate Of Token
        return rate;
    }

    function getSoftCap() public view returns (uint256) {
        return softCap;
    }

    function getHardCap() public view returns (uint256) {
        return hardCap;
    }

    function getAvailableTokens() public view returns (uint256) {
        return availableTokens;
    }

    function getIsFinished() public view returns (bool) {
        return isFinished;
    }

    function getWeiRaised() public view returns (uint256) {
        // total Wei raised
        return weiRaised;
    }

    function setRate(uint256 _newRate) public onlyOwner {
        // only Owner Get Rate of Token
        rate = _newRate;
    }

    function setSoftCap(uint256 _softCap) public onlyOwner {
        softCap = _softCap;
    }

    function setHardCap(uint256 _hardCap) public onlyOwner {
        hardCap = _hardCap;
    }

    function setAvailableTokens(uint256 _amount) public onlyOwner {
        // Owner will set Token Availability
        availableTokens = _amount;
    }

    //@notice this function is important. This contract doesn't call this function automatically when all claim processes were finished.
    //@notice So you have to call this function manually outside of this contract when all claims were finished.
    function setIsFinished(bool _isFinished) external onlyOwner {
        isFinished = _isFinished;
    }

    function acceptCoin(address _coin, string memory _coinName)
        public
        onlyOwner
    {
        // Only Owner can set Token that accepting for purchase Token that on sell
        require(acceptedCoin[_coinName] != address(0), "Already Exist");
        acceptedCoin[_coinName] = _coin;
        acceptedCoins.push(_coinName);
    }

    function removeAcceptedCoin(string memory _coinName) public onlyOwner {
        // Owner Remove Token Accept Token to purchase token
        require(acceptedCoin[_coinName] == address(0), "Token Not Exist");
        acceptedCoin[_coinName] = address(0);
    }
}