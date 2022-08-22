//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IGoldToken {
    function mint(address to, uint256 amount) external;
}

contract Presale is Ownable {
    uint256 public userWithdrawTime;
    uint256 public perMaxBuyUsdt = 100 * 10 ** 18;
    address private teamAddress;
    address public saleToken;
    address public usdtToken;
    address public goldTokenAddress;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public userBuyTotalUsdt;
    mapping(address => uint256) public rewardBalances;
    mapping(address => address) public reffers;
    mapping(address => uint256) public refferNumber;
    mapping(address => bool) public firstIdo;
    uint256 public totalIdoUSDT;
    uint256 public totalIdoUser;
    uint256 public totalSale;
    uint256 public inviteMin = 10;
    
    uint256[] public rewardLevel = [300, 200, 100, 50, 50, 30, 30, 20, 20, 10];

    struct PresaleInfo {
        uint256 startTime;
        uint256 endTime;
        uint256 price;
    }

    PresaleInfo public presaleInfo;

    constructor(address _saleToken, address _usdtToken, address _goldTokenAddress, uint256 _userWithdrawTime) public {
        saleToken = _saleToken;
        usdtToken = _usdtToken;
        goldTokenAddress = _goldTokenAddress;
        userWithdrawTime = _userWithdrawTime;
        teamAddress = msg.sender;
    }

    function createPreSale(PresaleInfo calldata _presaleInfo) public onlyOwner {
        presaleInfo = _presaleInfo;
    }
    
    function sale() public {
        require(reffers[msg.sender] != address(0), "Not bind parent inviter");
        require(block.timestamp >= presaleInfo.startTime);
        require(block.timestamp <= presaleInfo.endTime);
        if(refferNumber[msg.sender] >= inviteMin) {
            require(userBuyTotalUsdt[msg.sender] < 3*perMaxBuyUsdt, "Over max buy amount");
        } else {
            require(userBuyTotalUsdt[msg.sender] < perMaxBuyUsdt, "Over max buy amount");
        }

        address parent = reffers[msg.sender];
        if(!firstIdo[msg.sender]) {
            totalIdoUser++;
            firstIdo[msg.sender] = true;
            if (parent != address(0)) {
                refferNumber[parent] += 1;
                IGoldToken(goldTokenAddress).mint(parent, 10 * 10 ** 18);
            }

            IGoldToken(goldTokenAddress).mint(msg.sender, 10 * 10 ** 18);
        } 

        uint256 getTokenNum = perMaxBuyUsdt * 10 ** 18 / presaleInfo.price;
        IERC20(usdtToken).transferFrom(msg.sender, address(this), perMaxBuyUsdt);
        balances[msg.sender] += getTokenNum;
        userBuyTotalUsdt[msg.sender] += perMaxBuyUsdt;
        totalSale += getTokenNum;
        totalIdoUSDT += perMaxBuyUsdt;

        for(uint256 i = 0; i < rewardLevel.length; i++) {
            if(parent == address(0)) break;
            uint256 reward = 0; 
            reward = getTokenNum * rewardLevel[i]/10000;
            
            rewardBalances[parent] += reward;
            parent = reffers[parent];
            totalSale += reward;
        }
    }

    function getCanIdoAmount(address owner) public view returns (uint256) {
        uint256 userIdoAmount = userBuyTotalUsdt[owner];
        if(refferNumber[owner] >= inviteMin) {
            return 3*perMaxBuyUsdt - userIdoAmount;
        } else {
            return perMaxBuyUsdt - userIdoAmount;
        }
    }

    function bindReffer(address parent) public {
        require(reffers[msg.sender] == address(0), "Has bind invite");
        require(parent == teamAddress || userBuyTotalUsdt[parent] > 0, "Bind address not is a valid address");
        reffers[msg.sender] = parent;        
    }

    function userBalance(address userAddress) public view returns (uint256) {
        uint256 bal = balances[userAddress];
        return bal;
    }

    function userRewardBalance(address userAddress) public view returns (uint256) {
        uint256 bal = rewardBalances[userAddress];
        return bal;
    }

    function userWithdraw() public {
        require(block.timestamp > userWithdrawTime);
        uint256 bal = balances[msg.sender] + rewardBalances[msg.sender]; 
        require(bal > 0, "balance is 0");

        balances[msg.sender] = 0;
        rewardBalances[msg.sender] = 0;
        IERC20(saleToken).transfer(msg.sender, bal);
    }

    function teamWithdraw(address addr) public onlyOwner {
        uint bal = IERC20(addr).balanceOf(address(this));
        IERC20(addr).transfer(teamAddress, bal);
    }

    function setUserWithdrawTime(uint256 _userWithdrawTime) public onlyOwner {
        userWithdrawTime = _userWithdrawTime;
    }

    function setInviteMin(uint256 _inviteMin) public onlyOwner {
        inviteMin = _inviteMin;
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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