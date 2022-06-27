/**
 *Submitted for verification at BscScan.com on 2022-06-26
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

// File: contracts/presale.sol


// @title TradersClubPresale Contract

pragma solidity ^0.8.13;


contract TradersClubPresale is Ownable {
    address public presale = 0x133A7Fb549AdB6e8459696663ED1cAb493cd9ed6;
    mapping(address => bool) private whitelist;
    uint public presaleStartTimestamp = block.timestamp;
    uint public presaleHours = 24;
    uint public presaleEndTimestamp = presaleStartTimestamp + presaleHours * 1 hours;
    uint256 public totalDepositedEthBalance;
    uint256 public softCapEthAmount = 20 * 10**18;
    uint256 public hardCapEthAmount = 40 * 10**18;
    uint256 public minimumDepositEthAmount = 0.5 * 10**18;
    uint256 public maximumDepositEthAmount = 4 * 10**18;
    uint256 public tokensForEth = 3000000 * 10**18; // 3m tokens
    bool public whitelistEnabled = false;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) private tokens;

    receive() payable external {
        deposit();
    }

    function deposit() public payable {
        require(block.timestamp >= presaleStartTimestamp && block.timestamp <= presaleEndTimestamp, "presale is not active");
        require(totalDepositedEthBalance + msg.value <= hardCapEthAmount, "deposit limits reached");
        require(deposits[msg.sender] + msg.value >= minimumDepositEthAmount && deposits[msg.sender] + msg.value <= maximumDepositEthAmount, "incorrect amount");
        if (whitelistEnabled) {
            require(whitelist[msg.sender], "Wallet must be whitelisted!");
        }

        uint256 tokenAmount = msg.value * 1e18 * tokensForEth;
        totalDepositedEthBalance = totalDepositedEthBalance + msg.value;
        deposits[msg.sender] = deposits[msg.sender] + msg.value;
        tokens[msg.sender] = tokens[msg.sender] + tokenAmount;
        emit Deposited(msg.sender, msg.value);
    }
    
    function releaseFunds() external onlyOwner {
        require(block.timestamp >= presaleEndTimestamp || totalDepositedEthBalance == hardCapEthAmount, "presale is active");
        payable(presale).transfer(address(this).balance);
    }

    function manageWhitelist(address[] calldata addresses, bool status)
        external
        onlyOwner
    {
        for (uint256 i; i < addresses.length; ++i) {
            whitelist[addresses[i]] = status;
        }
    }

    function setWhitelist(address _address, bool _status) external onlyOwner {
        whitelist[_address] = _status;
        emit changeWhitelist(_address, _status);
    }

    function setWhitelistEnabled(bool _status) external onlyOwner {
        whitelistEnabled = _status;
    }
    
    function getWhitelist(address _address) public view returns (bool){
        return whitelist[_address];
    }

    function getDepositAmount() public view returns (uint256) {
        return totalDepositedEthBalance;
    }
    
    function getLeftTimeAmount() public view returns (uint256) {
        if(block.timestamp > presaleEndTimestamp) {
            return 0;
        } else {
            return (presaleEndTimestamp - block.timestamp);
        }
    }

    event Deposited(address indexed user, uint256 amount);
    event changeWhitelist(address _address, bool status);
}