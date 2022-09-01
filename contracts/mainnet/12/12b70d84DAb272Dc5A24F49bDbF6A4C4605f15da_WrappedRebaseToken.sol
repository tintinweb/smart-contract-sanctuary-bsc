//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract WrappedRebaseToken is IERC20, Ownable {
    using SafeMath for uint256;

    // total supply
    uint256 private _totalSupply;

    // token data
    string private constant _name = "Wrapped-Aalto";
    string private constant _symbol = "wAalto";
    uint8 private constant _decimals = 18;

    // Token We Wrap Around
    IERC20 public immutable Aalto;

    // For Redeem Rate
    uint256 private constant precision = 10**18;

    // balances
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Taxation on transfers
    uint256 public buyFee = 1300;
    uint256 public sellFee = 1700;
    uint256 public transferFee = 1300;
    uint256 public constant TAX_DENOM = 10000;

    // permissions
    struct Permissions {
        bool isFeeExempt;
        bool isLiquidityPool;
    }
    mapping(address => Permissions) public permissions;

    // Fee Recipients
    address public sellFeeRecipient;
    address public buyFeeRecipient;
    address public transferFeeRecipient;

    // events
    event SetBuyFeeRecipient(address recipient);
    event SetSellFeeRecipient(address recipient);
    event SetTransferFeeRecipient(address recipient);
    event SetFeeExemption(address account, bool isFeeExempt);
    event SetAutomatedMarketMaker(address account, bool isMarketMaker);
    event SetFees(uint256 buyFee, uint256 sellFee, uint256 transferFee);

    constructor(address _aalto) {
        require(_aalto != address(0), "Aalto not set");
        Aalto = IERC20(_aalto);

        emit Transfer(address(0), msg.sender, 0);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function name() public pure override returns (string memory) {
        return _name;
    }

    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /** Transfer Function */
    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    /** Transfer Function */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(
            amount,
            "Insufficient Allowance"
        );
        return _transferFrom(sender, recipient, amount);
    }

    function burn(uint256 amount) external returns (bool) {
        return _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) external returns (bool) {
        _allowances[account][msg.sender] = _allowances[account][msg.sender].sub(
            amount,
            "Insufficient Allowance"
        );
        return _burn(account, amount);
    }

    /** Internal Transfer */
    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(recipient != address(0), "Zero Recipient");
        require(sender != address(0), "Zero Sender");
        require(amount > 0, "Zero Amount");
        require(amount <= balanceOf(sender), "Insufficient Balance");

        // decrement sender balance
        _balances[sender] = _balances[sender].sub(amount, "Balance Underflow");
        // fee for transaction
        (uint256 fee, address feeDestination) = getTax(
            sender,
            recipient,
            amount
        );

        // allocate fee
        if (fee > 0) {
            address feeRecipient = feeDestination == address(0)
                ? address(this)
                : feeDestination;
            _balances[feeRecipient] = _balances[feeRecipient].add(fee);
            emit Transfer(sender, feeRecipient, fee);
        }

        // give amount to recipient
        uint256 sendAmount = amount.sub(fee);
        _balances[recipient] = _balances[recipient].add(sendAmount);

        // emit transfer
        emit Transfer(sender, recipient, sendAmount);
        return true;
    }

    /**
        Wrap `amount` of Aalto into wAalto
     */
    function wrap(uint256 amount) external {
        require(amount > 0, "Zero Amount");
        require(
            amount <= Aalto.balanceOf(msg.sender),
            "Amount Exceeds Senders Aalto Balance"
        );

        // wAalto To Mint
        uint256 wAaltoToMint = _totalSupply == 0
            ? amount
            : getWrappedQuantity(amount);

        // Transfer In Aalto
        uint256 before = Aalto.balanceOf(address(this));
        bool s = Aalto.transferFrom(msg.sender, address(this), amount);
        uint256 received = Aalto.balanceOf(address(this)).sub(before);
        require(s && received > 0 && received <= amount, "Error TransferFrom");

        // Mint wAalto To Sender
        _mint(msg.sender, wAaltoToMint);
    }

    /**
        Unwrap `amount` of wAalto into Aalto
     */
    function unwrap(uint256 amount) external {
        require(amount > 0, "Zero Amount");
        require(amount <= balanceOf(msg.sender), "Amount Exceeds Balance");

        // calculate Aalto to redeem for wAalto
        uint256 AaltoToSend = getUnwrappedQuantity(amount);

        // burn tokens from balance and supply
        _burn(msg.sender, amount);

        // release Aalto for caller
        require(
            Aalto.transfer(msg.sender, AaltoToSend),
            "Error On Aalto Transfer"
        );
    }

    function withdraw(address token) external onlyOwner {
        require(token != address(0), "Zero Address");
        require(token != address(Aalto), "Cannot Withdraw Aalto");
        bool s = IERC20(token).transfer(
            msg.sender,
            IERC20(token).balanceOf(address(this))
        );
        require(s, "Failure On Token Withdraw");
    }

    function withdrawBNB() external onlyOwner {
        (bool s, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function setTransferFeeRecipient(address recipient) external onlyOwner {
        require(recipient != address(0), "Zero Address");
        transferFeeRecipient = recipient;
        permissions[recipient].isFeeExempt = true;
        emit SetTransferFeeRecipient(recipient);
    }

    function setBuyFeeRecipient(address recipient) external onlyOwner {
        require(recipient != address(0), "Zero Address");
        buyFeeRecipient = recipient;
        permissions[recipient].isFeeExempt = true;
        emit SetBuyFeeRecipient(recipient);
    }

    function setSellFeeRecipient(address recipient) external onlyOwner {
        require(recipient != address(0), "Zero Address");
        sellFeeRecipient = recipient;
        permissions[recipient].isFeeExempt = true;
        emit SetSellFeeRecipient(recipient);
    }

    function registerAutomatedMarketMaker(address account) external onlyOwner {
        require(account != address(0), "Zero Address");
        require(!permissions[account].isLiquidityPool, "Already An AMM");
        permissions[account].isLiquidityPool = true;
        emit SetAutomatedMarketMaker(account, true);
    }

    function unRegisterAutomatedMarketMaker(address account)
        external
        onlyOwner
    {
        require(account != address(0), "Zero Address");
        require(permissions[account].isLiquidityPool, "Not An AMM");
        permissions[account].isLiquidityPool = false;
        emit SetAutomatedMarketMaker(account, false);
    }

    function setFees(
        uint256 _buyFee,
        uint256 _sellFee,
        uint256 _transferFee
    ) external onlyOwner {
        require(_buyFee <= 2500, "Buy Fee Too High");
        require(_sellFee <= 2500, "Sell Fee Too High");
        require(_transferFee <= 2500, "Transfer Fee Too High");

        buyFee = _buyFee;
        sellFee = _sellFee;
        transferFee = _transferFee;

        emit SetFees(_buyFee, _sellFee, _transferFee);
    }

    function setFeeExempt(address account, bool isExempt) external onlyOwner {
        require(account != address(0), "Zero Address");
        permissions[account].isFeeExempt = isExempt;
        emit SetFeeExemption(account, isExempt);
    }

    function getTax(
        address sender,
        address recipient,
        uint256 amount
    ) public view returns (uint256, address) {
        if (
            permissions[sender].isFeeExempt ||
            permissions[recipient].isFeeExempt
        ) {
            return (0, address(0));
        }
        return
            permissions[sender].isLiquidityPool
                ? (amount.mul(buyFee).div(TAX_DENOM), buyFeeRecipient)
                : permissions[recipient].isLiquidityPool
                ? (amount.mul(sellFee).div(TAX_DENOM), sellFeeRecipient)
                : (
                    amount.mul(transferFee).div(TAX_DENOM),
                    transferFeeRecipient
                );
    }

    function getRedeemRate() public view returns (uint256) {
        return Aalto.balanceOf(address(this)).mul(precision).div(_totalSupply);
    }

    /**
        For an `amount` of wAalto, Returns the amount of Aalto to receive when unwrapping
     */
    function getUnwrappedQuantity(uint256 amount)
        public
        view
        returns (uint256)
    {
        uint256 unwrapQTY = amount.mul(getRedeemRate()).div(precision);
        uint256 aaltoBalance = Aalto.balanceOf(address(this));
        return unwrapQTY < aaltoBalance ? unwrapQTY : aaltoBalance;
    }

    /**
        For an `amount` of Aalto, Returns the amount of wAalto to receive when wrapping
     */
    function getWrappedQuantity(uint256 amount) public view returns (uint256) {
        return amount.mul(precision).div(getRedeemRate());
    }

    /**
        Burns `amount` wAalto from `account`
     */
    function _burn(address account, uint256 amount) internal returns (bool) {
        require(account != address(0), "Zero Address");
        require(amount > 0, "Zero Amount");
        require(amount <= balanceOf(account), "Insufficient Balance");
        _balances[account] = _balances[account].sub(
            amount,
            "Balance Underflow"
        );
        _totalSupply = _totalSupply.sub(amount, "Supply Underflow");
        emit Transfer(account, address(0), amount);
        return true;
    }

    /**
        Mints `amount` of wAalto to `account`
     */
    function _mint(address account, uint256 amount) internal returns (bool) {
        require(account != address(0), "Zero Address");
        require(amount > 0, "Zero Amount");
        _balances[account] = _balances[account].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(address(0), account, amount);
        return true;
    }

    receive() external payable {}
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.4;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}