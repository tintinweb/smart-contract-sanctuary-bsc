/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// File: contracts\openzeppelin-contracts\contracts\utils\Context.sol


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

// File: contracts\openzeppelin-contracts\contracts\access\Ownable.sol


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

// File: contracts\FiveTigerBoxOffer.sol

pragma solidity ^0.8.0;

interface IERC1155{
    function mint(address to, uint256 id, uint256 amount, bytes memory data) external;
}

contract FiveTigerBoxOffer is Ownable {
    uint256 public startTime;
    uint256 public totalSupply;
    uint256 public perUser;
    uint256 public price;
    mapping(address => bool) public whiteList;
    bool public enableWhiteList;
    IERC1155 public  box;
    uint256 public boxId;
    uint256 public leftSupply;
    mapping(address => uint256) public perUsers;
    
    constructor(IERC1155 _box, uint256 _boxId, uint256 _startTime, uint256 _supply, uint256 _perUser, uint256 _price, bool _enableWhiteList){
        setParams(_box, _boxId, _startTime, _supply, _perUser, _price, _enableWhiteList);
    }
    
    function setParams(IERC1155 _box, uint256 _boxId, uint256 _startTime, uint256 _totalSupply, uint256 _perUser, uint256 _price, bool _enableWhiteList) public onlyOwner{
        box = _box;
        boxId = _boxId;
        startTime = _startTime;
        totalSupply = _totalSupply;
        perUser = _perUser;
        price = _price;
        leftSupply = _totalSupply;
        enableWhiteList = _enableWhiteList;
    }
    
    function newSupply(uint256 _supply) external onlyOwner{
        leftSupply = _supply;
    }
    
    function setWhiteList(address[] memory accounts, bool enable) external onlyOwner{
        for(uint256 i = 0; i < accounts.length; i++){
            whiteList[accounts[i]] = enable;
        }
    }
    
    function take(uint256 number) payable external {
        require(number > 0, "Offer:number limit");
        if(enableWhiteList){
            require(whiteList[msg.sender], "Offer:whilelist limit");
        }
        require(block.timestamp >= startTime, "Offer:time limit");
        require(msg.value >= number * price, "Offer:value limit");
        leftSupply -= number;
        require(leftSupply > 0, "Offer:supply limit");
        perUsers[msg.sender] += number;
        require(perUsers[msg.sender] <= perUser, "Offer:perUser limit");
        box.mint(msg.sender, boxId, number, "");
        uint256 left = msg.value - number * price;
        if(left > 0){
            payable(msg.sender).transfer(left);
        }
    }
    
    receive() payable external{}
    
    function claim(address payable to) external onlyOwner {
        to.transfer(address(this).balance);
    }
}