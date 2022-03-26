/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

interface IMetaBaby is IERC20 {
    function decimals() external view returns (uint256);
}

contract PrivateSale {
    using SafeMath for uint256;

    address private owner;

    struct PresaleBuyer {
        uint256 amountDepositedWei; // Funds token amount per recipient.
        uint256 amountMetaBaby; // Rewards token that needs to be vested.
    }

    mapping(address => PresaleBuyer) public recipients; // Presale Buyers
    mapping(address => bool) public whitelistedAddresses; // Addresses eligible in presale

    uint256 public minInvestInWei = 1e17; // Minimum wei amount that can be invested per wallet address 0.1 BNB
    uint256 public maxInvestInWei = 2 ether; // Maximum wei amount that can be invested per wallet address 2 BNB
    uint256 public hardCapInWei = 80 ether; // Maximum wei amount that can be invested in presale 80 BNB
    uint256 public tokenAmountPerBNB = 32000000; // Token amount per 1 BNB

    uint256 public soldMetaBabyAmount;
    uint256 public totalCollectedWei; // Total wei collected
    IMetaBaby public metaBaby; // Rewards Token : Token for distribution as rewards.

    event PresaleRegistered(address _registeredAddress, uint256 _weiAmount, uint256 _stripAmount);
    event PresalePaused(uint256 _endTime);

    /********************** Modifiers ***********************/
    modifier onlyOwner() {
        require(owner == msg.sender, "Requires Owner Role");
        _;
    }

    modifier whitelistedAddressOnly() {
        require(whitelistedAddresses[msg.sender], "Address not whitelisted");
        _;
    }

    constructor(address _metaBaby) {
        owner = msg.sender;
        metaBaby = IMetaBaby(_metaBaby);
    }

    /********************** Internal ***********************/


    /********************** External ***********************/

    function setMetaBabyTokenAddress(address _metaBaby) external onlyOwner {
        require (_metaBaby != address(0x00));
        metaBaby = IMetaBaby(_metaBaby);
    }

    function addwhitelistedAddresses(address[] calldata _whitelistedAddresses) external onlyOwner {
        for (uint256 i = 0; i < _whitelistedAddresses.length; i++) {
            whitelistedAddresses[_whitelistedAddresses[i]] = true;
        }
    }

    /** 
     * @dev After presale ends, we withdraw all funds
     */ 
    function withdrawFunds(address _withdrawalAddress) external onlyOwner returns (uint256) {
        uint256 weiBalance = address(this).balance;
        require(weiBalance > 0, "Withdraw: No BNB balance to withdraw");

        (bool sent, ) = _withdrawalAddress.call{value: weiBalance}("");
        require(sent, "Withdraw: Failed to withdraw funds");

        return weiBalance;
    }

    /**
     * @dev Withdraw wrong token
     */ 
    function withdrawWrongTokenByEmergency(address _token, address _withdrawalAddress) external onlyOwner returns (uint256) {
        uint256 totalBalance = IERC20(_token).balanceOf(address(this));
        require(
            IERC20(_token).transfer(_withdrawalAddress, totalBalance),
            "Withdraw: can't withdraw Strip tokens"
        );

        return totalBalance;
    }

    /**
     * @dev Receive Wei from presale buyers
     */ 
    function deposit() external payable whitelistedAddressOnly returns (uint256) {
        require(msg.sender != address(0x00), "Deposit: Sender should be valid address");
        require(totalCollectedWei < hardCapInWei, "Deposit: Hard cap reached");

        uint256 weiAmount = msg.value;
        require(recipients[msg.sender].amountDepositedWei + weiAmount >= minInvestInWei, "Deposit: Sender can not invest less than 0.1 BNB");
        require(recipients[msg.sender].amountDepositedWei + weiAmount <= maxInvestInWei, "Deposit: Sender already invested maximum amount");

        uint256 newMetaBabyAmount = weiAmount * tokenAmountPerBNB;
        require(newMetaBabyAmount <= metaBaby.balanceOf(address(this)), "Deposit: Not Sufficient MetaBaby in privsale contract");

        soldMetaBabyAmount = soldMetaBabyAmount.add(newMetaBabyAmount);
        totalCollectedWei = totalCollectedWei.add(msg.value);

        recipients[msg.sender].amountDepositedWei += weiAmount;
        recipients[msg.sender].amountMetaBaby = recipients[msg.sender].amountMetaBaby.add(newMetaBabyAmount);

        metaBaby.transfer(msg.sender, newMetaBabyAmount);

        emit PresaleRegistered(msg.sender, weiAmount, recipients[msg.sender].amountMetaBaby);

        return recipients[msg.sender].amountMetaBaby;
    }
}