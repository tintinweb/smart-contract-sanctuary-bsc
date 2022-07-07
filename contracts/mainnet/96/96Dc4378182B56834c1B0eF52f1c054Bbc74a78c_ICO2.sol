// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ICO2 {
    using SafeMath for uint;

    IERC20 public BUSD;//busd: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    IERC20 public TOKEN;
    struct Sale {
        address buyer;
        uint tokenAmount;
        uint investAmount;
        bool hasWithdrawn;
    }

    uint public constant OWNER_FEE = 40;//40%
    uint public constant MARKETING_FEE = 40;//40%
    uint public constant PERCENT_DIVIDER = 100;
    address public devAddress;
    address public owner;
    address public marketingAddress;

    uint constant public HARDCAP = 20_000 ether;
    uint public constant MIN_INVEST_AMOUNT = 10 ether;
    uint public constant MAX_INVEST_AMOUNT = 1000 ether;


    mapping(address => Sale) public sales;
    mapping(uint => address) public investors;
    uint public totalInverstorsCount;
    address public admin;
    uint public initDate;
    uint public busdtoToken = 5;
    uint public busdDivider = 1;

    uint public totalInvested;
    uint public totalTokenSale;
    bool public isActive = false;
    bool public startWithdraw;

    event SaleEvent (address indexed _investor, uint indexed _investAmount, uint indexed _tokenAmount);
    event StartWithdrawEvent(bool _canWithdraw);
    event WithdrawEvent(address indexed _investor, uint _tokenAmount);

    constructor(address _dev, address _owner, address _marketingAddress, address _BUSD, address _TOKEN) {
        admin = msg.sender;
        devAddress = _dev;
        owner = _owner;
        marketingAddress = _marketingAddress;
        BUSD = IERC20(_BUSD);
        TOKEN = IERC20(_TOKEN);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin");
        _;
    }

    modifier saleIsActive() {
        require(isActive, "sale is not active");
        _;
    }

    modifier canWithdraw() {
        require(startWithdraw, "can not withdraw");
        _;
    }

    function start() external onlyAdmin {
        require(!isActive, "ICO is already active");
        isActive = true;
    }

    function stop() external onlyAdmin {
        require(isActive, "ICO is not active");
        isActive = false;
    }

    function starTWithDraw() external onlyAdmin {
        require(!startWithdraw, "ICO is already active");
        startWithdraw = true;
    }

    function stopWithDraw() external onlyAdmin {
        require(startWithdraw, "ICO is not active");
        startWithdraw = false;
    }

    function buy(uint _amountBUSD) external saleIsActive {
        require(sales[msg.sender].hasWithdrawn == false, "you cant withdraw twice");
        require(_amountBUSD >= MIN_INVEST_AMOUNT, "busd must be greater than MIN_INVEST_AMOUNT");
        require(_amountBUSD <= MAX_INVEST_AMOUNT, "busd must be less than MAX_INVEST_AMOUNT");
        uint amount = _amountBUSD;
        if(amount > getReserveToInvest()) {
            amount = getReserveToInvest();
            isActive = false;
        }

        Sale memory sale = sales[msg.sender];

        if(sale.investAmount == 0) {
            sales[msg.sender].buyer = msg.sender;
            investors[totalInverstorsCount] = msg.sender;
            totalInverstorsCount += 1;
        }

        uint tokenAmount = amount.mul(busdtoToken).div(busdDivider);

        sales[msg.sender].tokenAmount = sale.tokenAmount.add(tokenAmount);
        sales[msg.sender].investAmount = sale.investAmount.add(amount);

        totalInvested = totalInvested.add(amount);
        totalTokenSale = totalTokenSale.add(tokenAmount);
        BUSD.transferFrom(msg.sender, address(this), amount);
        payFees(amount);
        emit SaleEvent(msg.sender, amount, tokenAmount);
        require(sales[msg.sender].investAmount <= MAX_INVEST_AMOUNT, "you cant invest more than MAX_INVEST_AMOUNT");
        require(totalInvested <= HARDCAP, "total invested must be less than HARDCAP");
        if(totalInvested == HARDCAP) {
            isActive = false;
        }
    }

    function withdrawTokens() external canWithdraw {
        require(sales[msg.sender].hasWithdrawn == false, "you cant withdraw twice");
        sales[msg.sender].hasWithdrawn = true;
        emit WithdrawEvent(msg.sender, sales[msg.sender].tokenAmount);
        TOKEN.transfer(msg.sender, sales[msg.sender].tokenAmount);
    }

    function withdrawDividens() public onlyAdmin {
        payFees(BUSD.balanceOf(address(this)));
        TOKEN.transfer(admin, TOKEN.balanceOf(address(this)));
    }

    function finish() external onlyAdmin {
        isActive = false;
        withdrawDividens();
    }

    function transferAdmin(address newAdmin) external onlyAdmin {
        admin = newAdmin;
    }

    function getReserveToInvest() public view returns (uint) {
        return HARDCAP.sub(totalInvested);
    }

    function getAllInvestorsAdress() public view returns (address[] memory) {
        address[] memory _investors = new address[](totalInverstorsCount);
        for(uint i; i < totalInverstorsCount; i++) {
            _investors[i] = investors[i];
        }
        return _investors;
    }

    function getAllTokens() public view returns (uint[] memory) {
        uint[] memory _tokens = new uint[](totalInverstorsCount);
        for(uint i; i < totalInverstorsCount; i++) {
            _tokens[i] = sales[investors[i]].tokenAmount;
        }
        return _tokens;
    }

    function getAllInvestorAndTokes() public view returns (Sale[] memory) {
        Sale[] memory _investors = new Sale[](totalInverstorsCount);
        for(uint i; i < totalInverstorsCount; i++) {
            _investors[i] = sales[investors[i]];
        }
        return _investors;
    }

    function getAllInvestorAndTokesByindex(uint _first, uint last) public view returns (Sale[] memory) {
        uint length = last.sub(_first).add(1);
        Sale[] memory _investors = new Sale[](length);
        for(uint i; i < length; i++) {
            _investors[i] = sales[investors[_first + i]];
        }
        return _investors;
    }

    struct SaleToken {
        address buyer;
        uint tokenAmount;
    }

    function getAllInvestors() external view returns (SaleToken[] memory) {	
        SaleToken[] memory _investors = new SaleToken[](totalInverstorsCount);
        for(uint i; i < totalInverstorsCount; i++) {
            _investors[i] = SaleToken(investors[i], sales[investors[i]].tokenAmount);
        }
        return _investors;
    }
    

    function getTokensByInvestor(address investor) public view returns (uint) {
        return sales[investor].tokenAmount;
    }

    function getInvestByInvestor(address investor) public view returns (uint) {
        return sales[investor].investAmount;
    }

    function payFees(uint _amount) internal {
        uint ownerFee = _amount.mul(OWNER_FEE).div(PERCENT_DIVIDER);
        transferHandler(owner, ownerFee);
        uint markFee = _amount.mul(MARKETING_FEE).div(PERCENT_DIVIDER);
        transferHandler(marketingAddress, markFee);
        uint devFee = _amount.sub(ownerFee + markFee);
        transferHandler(devAddress, devFee);
    }

    function transferHandler(address _to, uint _value) internal {
        BUSD.transfer(_to, _value);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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