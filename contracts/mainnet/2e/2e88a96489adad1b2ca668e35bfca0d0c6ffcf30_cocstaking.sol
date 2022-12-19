/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// SPDX-License-Identifier: MIT LICENSE
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

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity ^0.8.2;

interface BEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface cocswap {
    function getrate() external view returns(uint256);
}

contract cocstaking is Ownable{
    address public token;
    uint256 public minstake = 50;
    uint256 public maxstake = 2000;
    uint256 public dayPerCycle = 10 days; 
    address public swapaddress;
    event tokenstake(address user, uint256 amountbusd, uint256 tokenamount);
    event tokenwithdrawal(address user, uint256 amountbusd, uint256 tokenamount);
    struct stakeHistory {
        address user;
        uint amount;
        uint token;
        uint starttime;
        uint endtime;
    }

    struct withdrawHistory {
        address user;
        uint amount;
        uint token;
        uint time;
    }
    
    stakeHistory[] public shistory;
    withdrawHistory[] public whistory;

    constructor(address _cocswapaddress, address _tokenaddress){
        token = _tokenaddress;
        swapaddress = _cocswapaddress;
    }

    function rate() public view returns(uint256){
        return cocswap(swapaddress).getrate();
    }

    function stake (uint256 _amount) public {
        uint256 totaltoken = ((_amount * 1e36) / cocswap(swapaddress).getrate());
        BEP20 paytoken = BEP20(token);
        paytoken.transferFrom(msg.sender,address(this), totaltoken);
        shistory.push(
            stakeHistory({
                user : msg.sender,
                amount : _amount,
                token : totaltoken,
                starttime : block.timestamp,
                endtime : block.timestamp
            })
        );
        emit tokenstake(msg.sender, _amount, totaltoken);
    }
    
    function withdraw(address _user, uint256 _amount, uint256 _token) public onlyOwner {
        
        BEP20 wtoken = BEP20(token);
        wtoken.transfer(_user, _token);
        shistory.push(
            stakeHistory({
                user : msg.sender,
                amount : _amount,
                token : _token,
                starttime : block.timestamp,
                endtime : block.timestamp
            })
        );
        emit tokenwithdrawal(msg.sender, _amount, _token);
    }
    
    function withdrawtoken( address _token, uint256 _amount) public onlyOwner {
        BEP20 wtoken = BEP20(_token);
        wtoken.transfer(msg.sender, _amount);
    }
    
    function withdrawCoin() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}