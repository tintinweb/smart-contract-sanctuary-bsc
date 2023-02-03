/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

// File: contracts/MaiBox.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

library SafeMath {
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
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

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

interface IMaiDAONFT {
    function getAdmin() external returns(address);
}

abstract contract Administrable {
    IMaiDAONFT public maiDAONFT;
    
    constructor (address maiDAONFTAddress)
    {
        maiDAONFT = IMaiDAONFT(maiDAONFTAddress);
    }

    modifier onlyAdmin() {
        require(maiDAONFT.getAdmin() == msg.sender, "Administrable: caller is not the admin");
        _;
    }
}

contract MaiBox is Administrable {
    using SafeMath for uint;

    IERC20 public busdToken;
    uint public withdrawalFee;
    mapping(address => uint) private balance;
    uint public constant PERCENT_ALLOWED = 30*10**4;
    uint public constant FULL_PERCENT = 100*10**4;
    mapping(address => uint) public lastDeposit;
    uint timeToWaitAfterWithdraw = 5 minutes;

    event Deposit (address account, uint amount);
    event Withdraw(address account, uint amount);
    event UpgradeGremio(address account, uint amount);
    event CreateGremio(address account, uint amount);

    constructor(address maiDaoNFTAddress, address busdTokenAddress, uint withdrawalFeeValue) Administrable(maiDaoNFTAddress)
    {
        busdToken = IERC20(busdTokenAddress);
        setWithdrawalFee(withdrawalFeeValue);
    }

    /**
     * @dev set time in minutes to wait until next withdrawal
     */
    function setTimeToWaitAfterWithdraw(uint timeToWait) external onlyAdmin {
        timeToWaitAfterWithdraw = timeToWait * 1 minutes;
    }

    /**
     * @dev set the percent to discount on withdrawals 0 - 100
     */
    function setWithdrawalFee(uint withdrawalFeeValue) public onlyAdmin {
        uint newFee = withdrawalFeeValue *10**4;
        require(newFee >= 0 && newFee <= PERCENT_ALLOWED, "Invalid fee");
        withdrawalFee = withdrawalFeeValue;
    }

    function deposit(uint amount, uint _type) external {
        require (busdToken.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");
       
       if(_type == 0){
            busdToken.transferFrom(msg.sender, address(this), amount);
            balance[msg.sender] += amount;
            lastDeposit[msg.sender] = block.timestamp;
            emit Deposit(msg.sender, amount);
       
       }else if( _type == 1){
           busdToken.transferFrom(msg.sender, address(this), amount);
           emit UpgradeGremio(msg.sender, amount);
       
       }else if( _type == 2){
           busdToken.transferFrom(msg.sender, address(this), amount);
           emit CreateGremio(msg.sender, amount);
       
       }
    }

    function withdraw(uint amount) external {
        require(amount <= balance[msg.sender] && amount <= busdToken.balanceOf(address(this)), "Insufficient funds");
        require(lastDeposit[msg.sender] + timeToWaitAfterWithdraw < block.timestamp, "Still can't withdraw from your balance");
        balance[msg.sender] -= amount;
        uint256 amountWithFee = amount.mul(withdrawalFee).div(FULL_PERCENT);
        uint256 amountToTransfer = amount.sub(amountWithFee);
        transferTo(msg.sender, amountToTransfer);
        transferTo(maiDAONFT.getAdmin(), amountWithFee);
        emit Withdraw(msg.sender, amount);
    }

    function transferTo(address account, uint amount) internal {
        if (amount > 0) {
            busdToken.transfer(account, amount);
        }
    }

    function updateBalance(address[] calldata accounts, uint[] calldata amounts) external onlyAdmin {
        require(accounts.length == amounts.length, "need to provide the same size for acounts and amounts");

        for (uint i =0; i < accounts.length; i++) {
            require(accounts[i] != address(0), "Unable to update balance of address zero");
            require(amounts[i] <= busdToken.balanceOf(address(this)), "Unable to update balance, cannot be greater than actual");
            balance[accounts[i]] = amounts[i];
        }
    }

    function getBalance(address account) view external returns (uint) {
        return balance[account];
    }
}