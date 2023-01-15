//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract DaylightMaxi is Ownable, IERC20 {
    using SafeMath for uint256;

    // Staking Token
    IERC20 public immutable token;

    // Staking Protocol Token Info
    string private constant _name = "Daylight MAXI";
    string private constant _symbol = "DAYL MAXI";
    uint8 private constant _decimals = 18;

    // Trackable User Info
    struct UserInfo {
        uint256 balance;
        uint256 unlockBlock;
        uint256 totalStaked;
        uint256 totalWithdrawn;
    }
    // User -> UserInfo
    mapping(address => UserInfo) public userInfo;

    // Unstake Early Fee
    uint256 public leaveEarlyFee = 300;

    // Unstake Early Fee Recipient
    address public leaveEarlyFeeRecipient;

    // Timer For Leave Early Fee
    uint256 public leaveEarlyFeeTimer = 403_200;

    // total supply of MAXI
    uint256 private _totalSupply;

    // Swapper To Purchase Token From BNB
    address public tokenSwapper;

    // precision factor
    uint256 private constant precision = 10**18;

    // Reentrancy Guard
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    modifier nonReentrant() {
        require(_status != _ENTERED, "Reentrancy Guard call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    // Events
    event Deposit(address depositor, uint256 amountToken);
    event Withdraw(address withdrawer, uint256 amountToken);
    event FeeTaken(uint256 fee);

    constructor(
        address token_,
        address swapper_,
        address feeRecipient_
    ) {
        // set reentrancy
        _status = _NOT_ENTERED;

        // set token
        token = IERC20(token_);

        // set swapper
        tokenSwapper = swapper_;

        // set fee recipient
        leaveEarlyFeeRecipient = feeRecipient_;

        // emit transfer so bscscan registers contract as token
        emit Transfer(address(0), msg.sender, 0);
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return token.balanceOf(address(this));
    }

    /** Shows The Value Of Users' Staked Token */
    function balanceOf(address account) public view override returns (uint256) {
        return ReflectionsFromContractBalance(userInfo[account].balance);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        if (recipient == msg.sender) {
            withdraw(amount);
        }
        return true;
    }

    function transferFrom(
        address,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (recipient == msg.sender) {
            withdraw(amount);
        }
        return true;
    }

    function setLeaveEarlyFee(uint256 newLeaveEarlyFee) external onlyOwner {
        require(newLeaveEarlyFee <= 500, "Early Fee Too High");
        leaveEarlyFee = newLeaveEarlyFee;
    }

    function setLeaveEarlyFeeRecipient(address newLeaveEarlyFeeRecipient)
        external
        onlyOwner
    {
        require(newLeaveEarlyFeeRecipient != address(0), "Zero Address");
        leaveEarlyFeeRecipient = newLeaveEarlyFeeRecipient;
    }

    function setLeaveEarlyFeeTimer(uint256 newLeaveEarlyFeeTimer)
        external
        onlyOwner
    {
        require(newLeaveEarlyFeeTimer <= 10**7, "Fee Timer Too High");
        leaveEarlyFeeTimer = newLeaveEarlyFeeTimer;
    }

    function setTokenSwapper(address newTokenSwapper) external onlyOwner {
        require(newTokenSwapper != address(0), "Zero Address");
        tokenSwapper = newTokenSwapper;
    }

    function withdrawBNB() external onlyOwner {
        (bool s, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(s, "Error On BNB Withdrawal");
    }

    function recoverForeignToken(IERC20 _token) external onlyOwner {
        require(
            address(_token) != address(token),
            "Cannot Withdraw Staking Tokens"
        );
        require(
            _token.transfer(msg.sender, _token.balanceOf(address(this))),
            "Error Withdrawing Foreign Token"
        );
    }

    /** 
        Native Sent To Contract Will Buy And Stake Token
        Standard Token Purchase Rates Still Apply
     */
    receive() external payable {
        require(msg.value > 0, "Zero Value");

        // Track Balance Before Deposit
        uint256 previousBalance = token.balanceOf(address(this));

        // Purchase Staking Token
        uint256 received = _buyToken(msg.value);

        if (_totalSupply == 0 || previousBalance == 0) {
            _registerFirstPurchase(received);
        } else {
            _mintTo(msg.sender, received, previousBalance);
        }
    }

    /**
        Transfers in `amount` of Token From Sender
        And Locks In Contract, Minting MAXI Tokens
     */
    function deposit(uint256 amount) external nonReentrant {
        // Track Balance Before Deposit
        uint256 previousBalance = token.balanceOf(address(this));

        // Transfer In Token
        uint256 received = _transferIn(amount);

        if (_totalSupply == 0 || previousBalance == 0) {
            _registerFirstPurchase(received);
        } else {
            _mintTo(msg.sender, received, previousBalance);
        }
    }

    /**
        Redeems `amount` of Underlying Tokens, As Seen From BalanceOf()
     */
    function withdraw(uint256 amount) public nonReentrant returns (uint256) {
        // Token Amount Into Contract Balance Amount
        uint256 MAXI_Amount = amount == balanceOf(msg.sender)
            ? userInfo[msg.sender].balance
            : TokenToContractBalance(amount);

        require(
            userInfo[msg.sender].balance > 0 &&
                userInfo[msg.sender].balance >= MAXI_Amount &&
                balanceOf(msg.sender) >= amount &&
                amount > 0 &&
                MAXI_Amount > 0,
            "Insufficient Funds"
        );

        // burn MAXI Tokens From Sender
        _burn(msg.sender, MAXI_Amount, amount);

        // increment total withdrawn
        unchecked {
            userInfo[msg.sender].totalWithdrawn += amount;
        }

        // Take Fee If Withdrawn Before Timer
        uint256 fee = remainingLockTime(msg.sender) == 0
            ? 0
            : _takeFee(amount.mul(leaveEarlyFee).div(1000));

        // send amount less fee
        uint256 sendAmount = amount.sub(fee);
        uint256 balance = token.balanceOf(address(this));
        if (sendAmount > balance) {
            sendAmount = balance;
        }

        // transfer token to sender
        require(
            token.transfer(msg.sender, sendAmount),
            "Error On Token Transfer"
        );

        emit Withdraw(msg.sender, sendAmount);
        return sendAmount;
    }

    function donate() external payable nonReentrant {
        // buy staking token
        _buyToken(address(this).balance);
    }

    /**
        Registers the First Stake
     */
    function _registerFirstPurchase(uint256 received) internal {
        // increment total staked
        userInfo[msg.sender].totalStaked += received;

        // mint MAXI Tokens To Sender
        _mint(msg.sender, received, received);

        emit Deposit(msg.sender, received);
    }

    function _takeFee(uint256 fee) internal returns (uint256) {
        require(
            token.transfer(leaveEarlyFeeRecipient, fee),
            "Failure On Fee Transfer"
        );
        emit FeeTaken(fee);
        return fee;
    }

    function _mintTo(
        address sender,
        uint256 received,
        uint256 previousBalance
    ) internal {
        // Number Of Maxi Tokens To Mint
        uint256 nToMint = (_totalSupply.mul(received).div(previousBalance)).sub(
            10
        );
        require(nToMint > 0, "Zero To Mint");

        // increment total staked
        userInfo[sender].totalStaked += received;

        // mint MAXI Tokens To Sender
        _mint(sender, nToMint, received);

        emit Deposit(sender, received);
    }

    function _buyToken(uint256 amount) internal returns (uint256) {
        require(amount > 0, "Zero Amount");
        uint256 before = token.balanceOf(address(this));
        (bool s, ) = payable(tokenSwapper).call{value: amount}("");
        require(s, "Failure On Token Purchase");
        uint256 received = token.balanceOf(address(this)).sub(before);
        require(received > 0, "Zero Received");
        return received;
    }

    function _transferIn(uint256 amount) internal returns (uint256) {
        uint256 before = token.balanceOf(address(this));
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Failure On TransferFrom"
        );
        uint256 received = token.balanceOf(address(this)).sub(before);
        require(received <= amount && received > 0, "Error On Transfer In");
        return received;
    }

    /**
     * Burns `amount` of Contract Balance Token
     */
    function _burn(
        address from,
        uint256 amount,
        uint256 amountToken
    ) private {
        userInfo[from].balance = userInfo[from].balance.sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(from, address(0), amountToken);
    }

    /**
     * Mints `amount` of Contract Balance Token
     */
    function _mint(
        address to,
        uint256 amount,
        uint256 stablesWorth
    ) private {
        // allocate
        userInfo[to].balance = userInfo[to].balance.add(amount);
        _totalSupply = _totalSupply.add(amount);
        // update locker info
        userInfo[to].unlockBlock = block.number + leaveEarlyFeeTimer;
        emit Transfer(address(0), to, stablesWorth);
    }

    /**
        Converts A Staking Token Amount Into A MAXI Amount
     */
    function TokenToContractBalance(uint256 amount)
        public
        view
        returns (uint256)
    {
        return amount.mul(precision).div(_calculatePrice());
    }

    /**
        Converts A MAXI Amount Into An Token Amount
     */
    function ReflectionsFromContractBalance(uint256 amount)
        public
        view
        returns (uint256)
    {
        return amount.mul(_calculatePrice()).div(precision);
    }

    /** Conversion Ratio For MAXI -> Token */
    function calculatePrice() external view returns (uint256) {
        return _calculatePrice();
    }

    /**
        Lock Time Remaining For Stakers
     */
    function remainingLockTime(address user) public view returns (uint256) {
        return
            userInfo[user].unlockBlock < block.number
                ? 0
                : userInfo[user].unlockBlock - block.number;
    }

    /** Returns Total Profit for User In Token From MAXI */
    function getTotalProfits(address user) external view returns (uint256) {
        uint256 top = balanceOf(user) + userInfo[user].totalWithdrawn;
        return
            top <= userInfo[user].totalStaked
                ? 0
                : top - userInfo[user].totalStaked;
    }

    /** Conversion Ratio For MAXI -> Token */
    function _calculatePrice() internal view returns (uint256) {
        uint256 backingValue = token.balanceOf(address(this));
        return (backingValue.mul(precision)).div(_totalSupply);
    }

    /** function has no use in contract */
    function allowance(address, address)
        external
        pure
        override
        returns (uint256)
    {
        return 0;
    }

    /** function has no use in contract */
    function approve(address spender, uint256) public override returns (bool) {
        emit Approval(msg.sender, spender, 0);
        return true;
    }
}