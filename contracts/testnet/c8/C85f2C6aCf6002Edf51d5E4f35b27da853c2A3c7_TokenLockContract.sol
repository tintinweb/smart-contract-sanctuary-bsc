/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: contracts/TokenLockContract.sol


pragma solidity ^0.8.0;


contract TokenLockContract {

    mapping(address => TLockInfo) accounts;

    enum TLockType {
        SEED_SALE,
        DEV,
        ADVISORS,
        MARKETING,
        LIQUIDITY,
        TREASURY,
        PRIVATE_SALE,
        PUBLIC_SALE,
        AIRDROP,
        SKILL_TO_EARN
    }

    struct TLockInfo {
        address owner;
        TLockType lockType;
        uint256 balance;
        uint256 claimed;
        uint256 createdAt;
    }

    address operator;
    IERC20 Token;
    uint32 deltaTime = 300;

    event WithdrawTokenEvent(address _toAddress, uint256 _amount);
    event LockTokenEvent(address _toAddress, TLockType _lockType, uint256 _amount);
    event ReceivedEvent(address _from, uint _amount);

    modifier onlyOwner {
        require(msg.sender == operator);
        _;
    }

    constructor(address _tokenAddress, address _operator) {
        operator  = _operator;
        Token = IERC20(_tokenAddress);
    }

    function getAccounts(address _user) public view returns (TLockInfo memory) {
        return accounts[_user];
    }

    function getAvailableToken(address _user) public view returns (uint256) {
        uint256 balance = accounts[_user].balance;
        uint256 claimed = accounts[_user].claimed;

        if (balance <= 0 || claimed >= balance) {
            return 0;
        }
        uint256 availableToken = 0;
        uint256 totalTime = block.timestamp - accounts[_user].createdAt;
        uint16 d = uint16 (totalTime / deltaTime) + 1;
        
        TLockType lockType = accounts[_user].lockType;
        if (lockType == TLockType.SEED_SALE) {
            if (d < 6) {
                return 0;
            } else if (d >= 16) {
                availableToken = balance - claimed;
                return availableToken;
            } else {
                availableToken = (d - 5) * balance / 10 - claimed;
                return availableToken;
            }
        } else if (lockType == TLockType.DEV) {
            if (d < 10) {
                return 0;
            } else if (d >= 20) {
                availableToken = balance - claimed;
                return availableToken;
            } else {
                availableToken = (d - 9) * balance / 10 - claimed;
                return availableToken;
            }
        } else if (lockType == TLockType.ADVISORS) {
            if (d < 6) {
                return 0;
            } else if (d >= 16) {
                availableToken = balance - claimed;
                return availableToken;
            } else {
                availableToken = (d - 5) * balance / 10 - claimed;
                return availableToken;
            }
        } else if (lockType == TLockType.MARKETING) {
            if (d >= 10) {
                availableToken = balance - claimed;
                return availableToken;
            } else {
                availableToken = d * balance / 10 - claimed;
                return availableToken;
            }
        } else if (lockType == TLockType.LIQUIDITY) {
            if (d <= 5) {
                if (claimed == 0) {
                    availableToken = 3 * balance / 10;
                }
            } else if (d <= 10) {
                availableToken = (4 * balance / 10) - claimed;
            } else if (d <= 15) {
                availableToken = (5 * balance / 10) - claimed;
            } else if (d <= 20) {
                availableToken = (6 * balance / 10) - claimed;
            } else if (d <= 25) {
                availableToken = (7 * balance / 10) - claimed;
            } else if (d <= 30) {
                availableToken = (8 * balance / 10) - claimed;
            } else if (d <= 36) {
                availableToken = (9 * balance / 10) - claimed;
            } else {
                availableToken = balance - claimed;
            }
        } else if (lockType == TLockType.TREASURY) {
            if (d <= 30) {
                availableToken = (d * balance / 30) - claimed;
            } else {
                availableToken = balance - claimed;
            }
        } else if (lockType == TLockType.PRIVATE_SALE) {
            if (d <= 1) {
                return 0;
            } else if (d <= 6) {
                availableToken = ((d - 1) * balance / 5) - claimed;
            } else {
                availableToken = balance - claimed;
            }
        } else if (lockType == TLockType.PUBLIC_SALE) {
            availableToken = balance - claimed;
        } else if (lockType == TLockType.AIRDROP) {
            if (d <= 20) {
                availableToken = (d * balance / 20) - claimed;
            } else {
                availableToken = balance - claimed;
            }
        } else if (lockType == TLockType.SKILL_TO_EARN) {
            if (d <= 40) {
                availableToken = (d * balance / 40) - claimed;
            } else {
                availableToken = balance - claimed;
            }
        }
        return availableToken;
    }

    function withdrawTokens() public {
        require(accounts[msg.sender].balance > 0, "You don't have any token to withdraw!");
        uint256 availableToken = getAvailableToken(msg.sender);
        require(accounts[msg.sender].claimed + availableToken <= accounts[msg.sender].balance, "The number of tokens withdrawn exceeds the limit!");

        Token.transfer(msg.sender, availableToken);        
        accounts[msg.sender].claimed += availableToken;

        emit WithdrawTokenEvent(msg.sender, availableToken);
    }

    function transferWithLock(address _toAddress, TLockType _lockType, uint256 _amount) public  onlyOwner {
        require(_amount > 0, "Require msg.value > 0");
        require(accounts[_toAddress].balance <= 0, "Address is exist!");
        accounts[_toAddress] = TLockInfo(_toAddress, _lockType, 0, 0, block.timestamp); 
        Token.transferFrom(msg.sender, address(this), _amount);
        accounts[_toAddress].balance = _amount;
        emit LockTokenEvent(_toAddress, _lockType, _amount);
    }

    receive() external payable {
        emit ReceivedEvent(msg.sender, msg.value);
    }
}