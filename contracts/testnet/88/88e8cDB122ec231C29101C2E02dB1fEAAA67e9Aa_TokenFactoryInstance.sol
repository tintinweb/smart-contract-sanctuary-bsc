/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol


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

// File: tokenFactory.sol

pragma solidity ^0.8.0;

contract TokenFactory {
    // Token name
    string public name;
    // Token symbol
    string public symbol;
    // Total supply
    uint256 public totalSupply;

    bool public mintable;
    bool public burnable;
    bool public isBlacklist;
    bool public isMaxWalletLimit;
    bool public isMaxTransactionLimit;
    bool public isRewardsToHolders;
    address[] public blacklist;
    uint256 public maxWalletLimit;
    uint256 public maxTransactionLimit;
    uint8 public rewardsToHolders;
    mapping (address => uint256) public balanceOf;
    address[] public holders;
    mapping (address => bool) public isBlacklisted;
    event Blacklist(address addr);

    //Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event BlackList(address addr);

    // Constructor
    constructor(string memory _name, uint256 _totalSupply, string memory _symbol,bool _mintable, bool _burnable  )public {
        name = _name;
        totalSupply = _totalSupply;
        symbol = _symbol;
        mintable = _mintable;
        burnable = _burnable;
        balanceOf[msg.sender] = _totalSupply;
        holders.push(msg.sender);


    }

    // Functions
    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance.");
        require(balanceOf[_to] + _value >= balanceOf[_to], "Arithmetic overflow.");
        require(checkMaxWalletLimit(_to, _value), "Exceeded maximum limit for wallet.");
        require(checkMaxTransactionLimit(_value), "Exceeded maximum limit for transaction.");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        holders.push(_to);

        emit Transfer(msg.sender, _to, _value);
    }

    function burn(uint256 _value) public {
        require(burnable, "Token is not burnable.");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance.");

        balanceOf[msg.sender] -= _value;

        emit Burn(msg.sender, _value);
    }

    function mint(address _to, uint256 _value) public {
        require(mintable, "Token is not mintable.");

        balanceOf[_to] += _value;
        holders.push(_to);

        emit Transfer(address(0), _to, _value);
    }
    function checkMaxWalletLimit(address _to, uint256 _value) public view returns (bool) {
    uint256 walletBalance = balanceOf[_to];
    return walletBalance + _value <= maxWalletLimit;
    }
        function checkMaxTransactionLimit(uint256 _value) public view returns (bool) {
        uint256 transactionSum = totalSupply + _value;
        return transactionSum <= maxTransactionLimit;
    }

    // rewardsToHolders flag
    function rewards() public {
        uint256 totalSupply = this.totalSupply();
        uint256 reward = totalSupply * (rewardsToHolders / 100);
        for (uint256 i = 0; i < holders.length; i++) {
            address holder = holders[i];
            uint256 holderBalance = balanceOf[holder];
            uint256 holderReward = holderBalance * (rewardsToHolders / 100);
            holderReward = holderReward / holders.length;
            holderReward = holderReward / 1000000000000000000;
            if (holderReward > 0) {
                balanceOf[holder] += holderReward * 1000000000000000000;
                reward -= holderReward * 1000000000000000000;
                emit Transfer(address(0), holder, holderReward * 1000000000000000000);
            }
        }
    }

 

}




// File: Delay.sol

pragma solidity ^0.8.0;



contract TokenFactoryInstance is Ownable {
    TokenFactory public tokenFactory;


    constructor() public {
    }   

    function createToken(string memory _name, uint256 _totalSupply, string memory _symbol, bool _transferable, bool _mintable, bool _burnable, uint256 _transferFee, uint256 _mintFee, uint256 _burnFee) public payable returns(address) {
    require(msg.value >= 0.1 ether, "Transaction fee must be at least 0.1 ETH");
    tokenFactory = new TokenFactory(_name, _totalSupply, _symbol,  _mintable, _burnable);
    return address(tokenFactory);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(getBalance());
    }
    function getContractAddress() public view returns (address) {
        return address(tokenFactory);
    }

}