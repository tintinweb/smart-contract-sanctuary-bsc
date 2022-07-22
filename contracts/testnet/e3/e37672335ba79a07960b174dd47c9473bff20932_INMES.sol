/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/
// a

// SPDX-License-Identifier: UNLICENSED

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


// Dependency file: @openzeppelin/contracts/access/Ownable.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/Context.sol";

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
        _setOwner(0x807AE67fbf8B68a7A6AD42F8841eAaB3B0Aa2D32);
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract INMES is Ownable {

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    struct FiveMonthTokenTimeLocks {
        uint256 totalTokens;
        uint256[5] unlockTimes;
    }

    struct TenMonthTokenTimeLocks {
        uint256 totalTokens;
        uint256[10] unlockTimes;
    }

    mapping (address => FiveMonthTokenTimeLocks) private fiveMonthTokenTimeLocks;
    mapping (address => TenMonthTokenTimeLocks) private tenMonthTokenTimeLocks;
    mapping (address => bool) private userHasFiveMonthLock;
    mapping (address => bool) private userHasTenMonthLock;
    mapping (address => uint256) public balances;
    mapping (address => bool) public exemptFromFees;
    mapping (address => mapping(address => uint)) public _allowances;

    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;
    bool public taxesEnabled;
    address public marketingWallet;
    address public burnWallet;
    uint256 public marketingFee;
    uint256 public burnFee;
    address public cryptoMultisender;
    bool public optimizedAirdropModeEnabled;
    bool public tradeEnabled;
    uint256 public firstUnlockDate;

    constructor() {
        totalSupply = 259000000e18;
        name = "INME SWAP";
        symbol = "INMES";
        decimals = 18;
        burnFee = 10;
        marketingFee = 10;
        burnWallet = 0x000000000000000000000000000000000000dEaD;
        marketingWallet = 0xf5CB66E91a660386aC6C2c36108caEeF77135966;
        cryptoMultisender = 0x226cD4e25DD0e348D061B3cf817C26F0Fb179722;
        exemptFromFees[owner()] = true;
        optimizedAirdropModeEnabled = true;
        taxesEnabled = true;
        tradeEnabled = false;
        firstUnlockDate = block.timestamp + (164 * 1 days); 
        balances[owner()] = totalSupply;
        emit Transfer(address(this),owner(),totalSupply);
    }

    function startFirstUnlockNow() public onlyOwner {
        firstUnlockDate = block.timestamp;
    }

    function enableTrading() public onlyOwner {
        tradeEnabled = true;
    }

    modifier onlyCryptoMultisender() {
      require(_msgSender() == cryptoMultisender && tx.origin == owner());
      _;
    }

    function setOptimizedAirdropMode(bool _enabled) public onlyOwner {
      optimizedAirdropModeEnabled = _enabled;
    }

    function setMultisenderContractAddress(address _addr) public onlyOwner {
      cryptoMultisender = _addr;
    }

    function gasOptimizedAirdrop(address[] calldata _addrs, uint256[] calldata _values) external virtual onlyCryptoMultisender {
        require(optimizedAirdropModeEnabled, "Optimized airdrop mode is not enabled.");
        require(balances[cryptoMultisender] > 0, "The Crypto Multisender contract address has no tokens to distribute.");
        balances[cryptoMultisender] = 0;
        for(uint256 i=0; i < _addrs.length; i++) {
            balances[_addrs[i]] = balances[_addrs[i]] + _values[i];
            emit Transfer(cryptoMultisender, _addrs[i], _values[i]);
        }
    }

    function addFiveMonthTimeLocks(address[] memory _addrs) public onlyOwner {
        uint256 intervalSize = 30 days;
        for(uint i = 0; i < _addrs.length; i++) {
            fiveMonthTokenTimeLocks[_addrs[i]] = FiveMonthTokenTimeLocks(
                balanceOf(_addrs[i]),
                [
                    firstUnlockDate,
                    firstUnlockDate + (1 * intervalSize),
                    firstUnlockDate + (2 * intervalSize),
                    firstUnlockDate + (3 * intervalSize),
                    firstUnlockDate + (4 * intervalSize)
                ]
            );
            userHasFiveMonthLock[_addrs[i]] = true;
        }
    }

    function addTenMonthTimeLocks(address[] memory _addrs) public onlyOwner {
        uint256 intervalSize = 30 days;
        for(uint i = 0; i < _addrs.length; i++) {
            tenMonthTokenTimeLocks[_addrs[i]] = TenMonthTokenTimeLocks(
                balanceOf(_addrs[i]),
                [
                    firstUnlockDate,
                    firstUnlockDate + (1 * intervalSize),
                    firstUnlockDate + (2 * intervalSize),
                    firstUnlockDate + (3 * intervalSize),
                    firstUnlockDate + (4 * intervalSize),
                    firstUnlockDate + (5 * intervalSize),
                    firstUnlockDate + (6 * intervalSize),
                    firstUnlockDate + (7 * intervalSize),
                    firstUnlockDate + (8 * intervalSize),
                    firstUnlockDate + (9 * intervalSize)
                ]
            );
            userHasTenMonthLock[_addrs[i]] = true;
        }  
    }

    function allowance(address _owner, address spender)public view returns (uint256) {
        return _allowances[_owner][spender];
    }

    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }

    function setMarketingWallet(address _marketingWallet) public onlyOwner {
        marketingWallet = _marketingWallet;
    }

    function setTaxesEnabled(bool _enabled) public onlyOwner {
        taxesEnabled = _enabled;
    }

    function setTaxFees(uint256 _marketingFee, uint256 _burnFee) public onlyOwner {
        require((_marketingFee + _burnFee) <= 20, "Total fees must not exceed 20%");
        marketingFee = _marketingFee;
        burnFee = _burnFee;
    }

    function setExemptFromFees(address _addr, bool _exempt) public onlyOwner {
        exemptFromFees[_addr] = _exempt;
    }

    function _approve(address owner, address spender, uint256 amount) internal  {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function hasTimeLockedTokens(address _addr) internal returns(bool) {
        bool res = false;
        if(userHasFiveMonthLock[_addr]) {
            res = fiveMonthTokenTimeLocks[_addr].unlockTimes[4] >= block.timestamp;
            if(res == false) { userHasFiveMonthLock[_addr] = false; }
        }
        if(userHasTenMonthLock[_addr]) {
            res = tenMonthTokenTimeLocks[_addr].unlockTimes[9] >= block.timestamp;
            if(res == false) { userHasTenMonthLock[_addr] = false; }
        }
        return res;
    }

    function getAvailableTokens(address _addr) public returns(uint256) {
        if(!hasTimeLockedTokens(_addr)) { return balanceOf(_addr); }
        uint256 locked = 0;
        uint256 initialTotalLocked = 0;
        if(userHasFiveMonthLock[_addr]) {
            initialTotalLocked = fiveMonthTokenTimeLocks[_addr].totalTokens;
            for(uint i = 0; i < fiveMonthTokenTimeLocks[_addr].unlockTimes.length; i++) {
                if(block.timestamp < fiveMonthTokenTimeLocks[_addr].unlockTimes[i]) {
                    locked += (initialTotalLocked/5);
                } else {
                    break;
                }
            }
        }
        if(userHasTenMonthLock[_addr]) {
            initialTotalLocked = tenMonthTokenTimeLocks[_addr].totalTokens;
            for(uint i = 0; i < tenMonthTokenTimeLocks[_addr].unlockTimes.length; i++) {
                if(block.timestamp < tenMonthTokenTimeLocks[_addr].unlockTimes[i]) {
                    locked += (initialTotalLocked/10);
                } else {
                    break;
                }
            }
        }
        return balanceOf(_addr) - locked;
    }

    function _transfer(address _from, address _to, uint256 _amount) internal {
        require((tradeEnabled || _msgSender() == owner()), "Trading is not yet enabled");
        uint256 available = getAvailableTokens(_from);
        require(available >= _amount, "Transferring time locked tokens is not permitted");
        require(balances[_from] >= _amount, "Insufficient token balance");
        balances[_from] -= _amount;
        uint256 toSend = _amount;
        if(taxesEnabled && !exemptFromFees[_from] && !exemptFromFees[_to]) {
            uint256 baseUnit = toSend / 100;
            if(marketingFee > 0) {
                uint256 mFee = baseUnit * marketingFee;
                balances[marketingWallet] += mFee;
                emit Transfer(_from, marketingWallet, mFee);
                toSend -= mFee;
            }
            if(burnFee > 0) {
                uint256 bFee = baseUnit * burnFee;
                balances[burnWallet] += bFee;
                emit Transfer(_from, burnWallet, bFee);
                toSend -= bFee;
            }
        }
        balances[_to] += toSend;
        emit Transfer(_from, _to, toSend);
    }


    function transfer(address _to, uint256 _amount) public returns(bool) { 
        _transfer(_msgSender(),_to,_amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(_allowances[sender][_msgSender()] >= amount, "ERC20: transfer amount exceeds allowance");
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }
}