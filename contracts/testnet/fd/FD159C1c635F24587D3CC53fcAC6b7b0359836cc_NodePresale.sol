//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import '../common/SafeMath.sol';
import '../common/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';

contract NodePresale is Ownable {
    using SafeMath for uint256;

    address[] private addresses;
    mapping (address => bool) public allowance;
    mapping (address => bool) public supplies;
    uint256 public totalSupply = 0;
    uint256 public maxSupply = 150;
    uint256 public totalPlan = 0;
    uint256 public maxPlan = 200;
    uint256 public endTime = 0;
    uint256 public duration = 1 days;
    bool public started = false;
    uint256 public minVest = 1000 ether;
    uint256 public maxVest = 1000 ether;
    address public tokenVest = address(0);
    string public tokenVestSymbol = 'ETH';
    uint8 public tokenVestDecimals = 18;

    function updateDuration(uint256 _duration) public onlyOwner {
        require(started==false, "Already started");
        duration = _duration;
        endTime = block.timestamp.add(_duration);
    }

    function updateEndTime(uint256 _endTime) public onlyOwner {
        require(started==false, "Already started");
        endTime = _endTime;
    }

    function updateMaxPlan(uint256 _maxPlan) public onlyOwner {
        maxPlan = _maxPlan;
    }

    function updateMaxSupply(uint256 _maxSupply) public onlyOwner {
        maxSupply = _maxSupply;
    }

    function updateMaxVest(uint256 _maxVest) public onlyOwner {
        maxVest = _maxVest;
    }

    function updateMinVest(uint256 _minVest) public onlyOwner {
        minVest = _minVest;
    }

    function updateTokenVest(address _tokenVest) public onlyOwner {
        tokenVest = _tokenVest;
        if(_tokenVest==address(0)) {
            tokenVestDecimals = 18;
            tokenVestSymbol = "ETH";
        } else {
            IERC20Metadata token = IERC20Metadata(_tokenVest);
            tokenVestSymbol = token.symbol();
            tokenVestDecimals = token.decimals();
        }
    }

    function start(uint256 _endTime) public onlyOwner {
        if(_endTime>block.timestamp)
            updateEndTime(_endTime);
        else
            updateDuration(duration);
        started = true;
    }

    function allow(address[] memory _accounts) public onlyOwner {
        for(uint256 i = 0;i<_accounts.length;i++) {
            address account = _accounts[i];
            if(!allowance[account]) {
                addresses.push(account);
                allowance[account] = true;
                totalPlan ++;
            }
        }
        require(totalPlan < maxPlan, "Cannot add more addresses because of overflow MAX_PLAN.");
    }

    function deny(address[] memory _accounts) public onlyOwner {
        for(uint256 i = 0;i<_accounts.length;i++) {
            address account = _accounts[i];
            if(allowance[account] && !supplies[account]) {
                allowance[account] = false;
                totalPlan --;
            }
        }
    }

    function whitelist(bool _supplied) public view returns (address[] memory) {
        uint256 len = _supplied ? totalSupply : totalPlan;
        address[] memory accounts = new address[](len);
        if(len==0) return accounts;
        uint256 j = 0;
        for(uint256 i = 0;i<addresses.length;i++) {
            address account = addresses[i];
            if(_supplied && !supplies[account])
                continue;
            if(allowance[account]) 
                accounts[j++] = account;
        }
        return accounts;
    }

    function vest() public payable {
        address recipient = owner();
        require(started==true, "Presale does not started.");
        require(block.timestamp<endTime, "Presale finished.");
        require(allowance[recipient]==true, "Not allowed vester.");
        require(supplies[recipient]==false, "Already vested.");
        require(totalSupply<maxSupply, "Max supply overflow.");
        if(tokenVest==address(0)) {
            require(msg.value>=minVest && msg.value<=maxVest, "Insufficient ETH value.");
            payable(owner()).transfer(msg.value);
        } else {
            uint256 amountSend = maxVest.mul(tokenVestDecimals).div(18);
            IERC20 token = IERC20(tokenVest);
            require(token.balanceOf(msg.sender)>=amountSend, "Insufficient Token balance");
            token.transferFrom(msg.sender, owner(), amountSend);
        }
        supplies[owner()] = true;
        totalSupply ++;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
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
        // Gas optimization: this is TKNaper than requiring 'a' not being zero, but the
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
     * `revert` opcode (which leaves remaining gas untouTKNd) while Solidity
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
     * `revert` opcode (which leaves remaining gas untouTKNd) while Solidity
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
     * opcode (which leaves remaining gas untouTKNd) while Solidity uses an
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
     * opcode (which leaves remaining gas untouTKNd) while Solidity uses an
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}