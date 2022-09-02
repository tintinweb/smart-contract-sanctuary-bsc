/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: ICO1.sol



pragma solidity ^0.8.0;



interface Token{
    function mint(address _address , uint amount) external;
    function getMaxTotalSupply() external view returns (uint);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract ICO {
    using SafeMath for uint;
    struct Sale {
        address investor;
        uint amount;
        bool tokensWithdrawn;
    }
    mapping(address=> uint256) public addressAccuDai;
    mapping(address => Sale) public sales;
    address[] public investors;
    address public admin;
    uint public end;
    uint public duration;
    uint public availableTokens;
    uint public minPurchase;
    uint public maxPurchase;
    uint public priceMultiplier;
    uint public priceDivider;
    Token public token;
    IERC20 public dai = IERC20(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd);
    
    constructor(
        address tokenAddress,
        uint _duration,
        uint _priceMultiplier,
        uint _priceDivider,
        uint _availableTokens,
        uint _minPurchase,
        uint _maxPurchase) {
        token = Token(tokenAddress);
        uint maxSupply = token.getMaxTotalSupply();
        
        require(_duration > 0, 'duration should be > 0');
        require(
          _availableTokens > 0 && _availableTokens <= maxSupply, 
          '_availableTokens should be > 0 and <= maxTotalSupply'
        );
        require(_minPurchase > 0, '_minPurchase should > 0');
        require(
          _maxPurchase > 0 && _maxPurchase <= _availableTokens, 
          '_maxPurchase should be > 0 and <= _availableTokens'
        );

        admin = msg.sender;
        duration = _duration;
        priceMultiplier = _priceMultiplier;
        priceDivider = _priceDivider;
        availableTokens = _availableTokens;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
    }
    
    function start()
        external
        onlyAdmin() 
        icoNotActive() {
        end = block.timestamp + duration;
    }
    
    function buy(uint daiAmount)
        external
        icoActive() {
        require(
          daiAmount >= minPurchase && daiAmount <= maxPurchase, 
          'have to buy between minPurchase and maxPurchase'
        );
        uint tokenAmount = (daiAmount * priceMultiplier)/priceDivider;
        require(
          tokenAmount <= availableTokens, 
          'Not enough tokens left for sale'
        );

        if(addressAccuDai[msg.sender] > 0){
            uint prevDaiAmount = addressAccuDai[msg.sender];
            addressAccuDai[msg.sender] = prevDaiAmount.add(daiAmount);
        }else{
             addressAccuDai[msg.sender] = daiAmount;
        }

        if(sales[msg.sender].amount>0){
            uint prevAmount = sales[msg.sender].amount;
            sales[msg.sender].amount = prevAmount.add(tokenAmount);
        }else{
            investors.push(msg.sender);

            sales[msg.sender] = Sale(
            msg.sender,
            tokenAmount,
            false
            );
        }

        dai.transferFrom(msg.sender, address(this), daiAmount);
        token.mint(address(this), tokenAmount);
    }
    
    function withdrawTokens()
        external
        icoEnded() {
        Sale storage sale = sales[msg.sender];
        require(sale.amount > 0, 'only investors');
        require(sale.tokensWithdrawn == false, 'tokens were already withdrawn');
        sale.tokensWithdrawn = true;
        token.transfer(sale.investor, sale.amount);
    }
    
    function withdraw(uint amount)
        external
        onlyAdmin()
        icoEnded() {
        dai.transfer(admin, amount);
    }

    function getAddressTokenAmount(address _address) external view returns (uint){
        return sales[_address].amount;
    }

    function getAddressDaiAmount(address _address) external view returns (uint){
        return addressAccuDai[_address];
    }

    function getYourTokenAmount() external view returns (uint){
        return sales[msg.sender].amount;
    }

    function getYourDaiAmount() external view returns (uint){
        return addressAccuDai[msg.sender];
    }

     function getInvestors() external view returns (address[] memory){
        return investors;
    }
    
    modifier icoActive() {
        require(
          end > 0 && block.timestamp < end && availableTokens > 0, 
          'ICO must be active'
        );
        _;
    }
    
    modifier icoNotActive() {
        require(end == 0, 'ICO should not be active');
        _;
    }
    
    modifier icoEnded() {
        require(
          end > 0 && (block.timestamp >= end || availableTokens == 0), 
          'ICO must have ended'
        );
        _;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin, 'Only Admin');
        _;
    }
}