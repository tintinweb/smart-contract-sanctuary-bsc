/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: tokenStaking.sol



pragma solidity 0.8.4;



interface IUSMT{
function burn(address holder, uint amount) external;
function mint(address _address , uint amount) external;
function balanceOf(address _address) external returns (uint);
function transfer(address to, uint256 amount) external;
function transferFrom( address from,   address to, uint256 amount) external;
}

contract USMTTokenStake is Ownable {

    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public isStaking;
    mapping(address => uint256) public startTime;
    mapping(address => uint256) public usmtBalance;

    uint public multiplier = 2 ;
    address public USMTcontract =  0x75d20A0452d3d7F2d7Ea56f2F59aF25af6fbB488;
    IUSMT USMT= IUSMT(USMTcontract);

    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
    event YieldWithdraw(address indexed to, uint256 amount);

    constructor() {
    }

    function stake(uint256 amount) public {
        require(amount > 0 && USMT.balanceOf(msg.sender) >= amount, "You cannot Stake 0 tokens / Not enough Token balance");

        if(isStaking[msg.sender] == true){
            uint256 toTransfer = calculateYieldTotal(msg.sender);
            usmtBalance[msg.sender] += toTransfer;
        }

        USMT.transferFrom(msg.sender, address(this), amount);
        stakingBalance[msg.sender] += amount;
        startTime[msg.sender] = block.timestamp;
        isStaking[msg.sender] = true;
        emit Stake(msg.sender, amount);
    }

    function unstake(uint256 amount) public {
        require(
            isStaking[msg.sender] = true && stakingBalance[msg.sender] >= amount, "Nothing to unstake"
        );

        uint256 yieldTransfer = calculateYieldTotal(msg.sender);
        startTime[msg.sender] = block.timestamp;
        uint256 balTransfer = amount;
        amount = 0;
        stakingBalance[msg.sender] -= balTransfer;
        USMT.transfer(msg.sender, balTransfer);
        usmtBalance[msg.sender] += yieldTransfer;
        if(stakingBalance[msg.sender] == 0){
            isStaking[msg.sender] = false;
        }
        emit Unstake(msg.sender, balTransfer);
    }

    function withdrawYield() public{
        uint256 toTransfer = calculateYieldTotal(msg.sender);

        require(toTransfer>0 || usmtBalance[msg.sender]>0 ,"Nothing to Withdraw");

        if(usmtBalance[msg.sender] != 0){
            uint oldBalance = usmtBalance[msg.sender];
            usmtBalance[msg.sender] = 0;
            toTransfer += oldBalance;
        }

        startTime[msg.sender] = block.timestamp;
        USMT.mint(msg.sender, toTransfer);
        emit YieldWithdraw(msg.sender, toTransfer);

    }

    function checkStakedtTokenBalance(address user) public view returns(uint){
        return stakingBalance[user];
    }

    function calculateYieldTime(address user) public view returns(uint256){
        uint256 end = block.timestamp;
        uint256 totalTime = end - startTime[user];
        return totalTime;
    }

    function calculateYieldTotal(address user) public view returns(uint256) {
        uint256 time = calculateYieldTime(user) * 10**18;
        uint256 rate = 86400;
        uint256 timeRate = time / rate;
        uint256 rawYield = (stakingBalance[user] * timeRate * multiplier) / 10**18;
        return rawYield;
    } 

    function setUSMTTokenAddress (address contractAddr) external onlyOwner {
        USMT= IUSMT(contractAddr);
    }
    function setMultiplier (uint _multiplier) external onlyOwner {
        multiplier = _multiplier; 
	}

}