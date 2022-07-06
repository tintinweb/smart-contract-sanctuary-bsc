/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Pausable is Context {

    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    constructor () {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Whitelist is Ownable {
    bool active = true;

    mapping(address => bool) public whitelist;
    
    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    modifier onlyWhitelisted() {
        if(active){
            require(whitelist[msg.sender], 'not whitelisted');
        }
        _;
    }

    function addAddressToWhitelist(address addr) public onlyOwner returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }
    function activateDeactivateWhitelist() public onlyOwner {
        active = !active;
    }

    function addAddressesToWhitelist(address[] calldata addrs) public onlyOwner returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }

    function removeAddressesFromWhitelist(address[] calldata addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
    }
}

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        uint256 _rawAmount = (amount * (10**_decimals));
        _beforeTokenTransfer(address(0), account, _rawAmount);

        _totalSupply = _totalSupply.add(_rawAmount);
        _balances[account] = _balances[account].add(_rawAmount);

        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

contract MintableToken is ERC20, Whitelist {
    using SafeMath for uint256;

    // User Stats
    struct Stats {
        uint256 txs;
        uint256 minted;
    }

    // Mint Data
    struct MintInfo {

        // Inclusion / exclusion
        bool blacklisted;

        //Amount Tracker
        uint256 pending;
        uint256 total;

        //Block Tracker
        uint256 lastBlock;
        uint256 lastTimestamp;
    }

    // Fees Data
    struct FeesInfo {

        // Fee Rate
        uint8 feeRate;

        // Fees inclusion / exclusion
        bool hasCustomTax;
        bool isExcluded;
    }

    address public vaultAddress;

    uint8 internal taxDefault = 10; // 10% tax on transfers

    uint256 public totalTxs;
    uint256 public players;

    mapping(address => Stats) private stats;
    mapping(address => MintInfo) public users;
    mapping(address => FeesInfo) private fees;

    event onClaimRewards(address indexed _caller, uint256 amount, uint256 _timestamp);

    event TaxPayed(address from, address vault, uint256 amount);
    event onAddRewardsToVault(uint256 amount, uint256 timestamp);

    event onSetTaxVault(address indexed _caller, address _vault, uint256 _timestamp);
    event onToggleBlacklisted(address indexed _caller, address _wallet, bool _setting, uint256 _timestamp);

    constructor(
        string memory _name, 
        string memory _symbol, 
        uint256 _initialMint, 
        address _vault
        ) ERC20(_name, _symbol) Ownable() {
        _mint(_vault, _initialMint);
        vaultAddress = _vault;
    }

    ////////////////////////////
    // PUBLIC WRITE FUNCTIONS //
    ////////////////////////////

    // Transfers
    function transfer(address _to, uint256 _value) public override returns (bool) {

        (uint256 adjustedValue, uint256 taxAmount) = calculateTransferTaxes(msg.sender, _value);

        if (taxAmount > 0){
            require(super.transfer(vaultAddress, taxAmount));
            emit TaxPayed(msg.sender, vaultAddress, taxAmount);
        }

        require(super.transfer(_to, adjustedValue));

        /* Members */
        if (stats[_to].txs == 0) {
            players += 1;
        }

        stats[_to].txs += 1;
        stats[msg.sender].txs += 1;

        totalTxs += 1;

        return true;
    }

    // Transfers (using transferFrom)
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {

        (uint256 adjustedValue, uint256 taxAmount) = calculateTransferTaxes(_from, _value);

        if (taxAmount > 0){
            require(super.transferFrom(_from, vaultAddress, taxAmount));
            emit TaxPayed(_from, vaultAddress, taxAmount);
        }

        require(super.transferFrom(_from, _to, adjustedValue));

        /* Members */
        if (stats[_to].txs == 0) {
            players += 1;
        }

        stats[_to].txs += 1;
        stats[msg.sender].txs += 1;

        totalTxs += 1;

        return true;
    }

    ///////////////////////////
    // PUBLIC VIEW FUNCTIONS //
    ///////////////////////////

    // stats of player, (txs, minted)
    function statsOf(address player) public view returns (uint256, uint256, uint256){
        return (balanceOf(player), stats[player].txs, stats[player].minted);
    }

    // Check if an address is exempt from transfer taxes or not
    function isExcluded(address account) public view returns (bool) {
        return fees[account].isExcluded;
    }

    // Calculate transfer taxes
    function calculateTransferTaxes(address _from, uint256 _value) public view returns (uint256 adjustedValue, uint256 taxAmount){
        adjustedValue = _value;
        taxAmount = 0;

        if (!fees[_from].isExcluded) {
            uint8 taxPercent = taxDefault; // set to default tax 10%

            // set custom tax rate if applicable
            if (fees[_from].hasCustomTax){
                taxPercent = fees[_from].feeRate;
            }

            (adjustedValue, taxAmount) = calculateFee(_value, taxPercent);
        }
        return (adjustedValue, taxAmount);
    }

    function available(address _user)  external view returns (uint256) {
        if (users[_user].pending > 0 && block.number > users[_user].lastBlock.add(2)){
            return users[_user].pending;
        } else {
            return 0;
        }
    }

    function ready(address _user)  external view  returns (bool) {
        return block.number > users[_user].lastBlock.add(2);
    }

    function pending(address _user)  external view returns (uint256) {
        return users[_user].pending;
    } 

    function lastMint(address _user)  external view returns (uint256 lastBlock, uint256 lastTimestamp) {
        lastBlock = users[_user].lastBlock;
        lastTimestamp = users[_user].lastTimestamp;
    }

    ////////////////////////////////
    // RESTRICTED WRITE FUNCTIONS //
    ////////////////////////////////

    function claim() external returns (bool) {

        address _user = msg.sender;
        uint256 _amount = users[_user].pending;

        bool _minted = _mintTokens(_user, _amount);
        require(_minted == true, "FAILED_TO_MINT");

        emit onClaimRewards(_user, _amount, block.timestamp);

        return true;
    }

    function topUpRewards(uint256 _amount) external onlyWhitelisted returns (bool) {
        users[vaultAddress].total += _amount;
        users[vaultAddress].lastBlock = block.number;
        users[vaultAddress].lastTimestamp = block.timestamp;

        bool _minted = _mintTokens(vaultAddress, _amount);
        require(_minted == true, "FAILED_TO_MINT");

        emit onAddRewardsToVault(_amount, block.timestamp);

        return true;
    }

    function credit(address _user, uint256 _amount) external onlyWhitelisted {
        users[_user].pending += _amount;
        users[_user].total += _amount;
        users[_user].lastBlock = block.number;
        users[_user].lastTimestamp = block.timestamp;
    }
    
    function settle(address _user) external onlyWhitelisted {
        users[_user].pending = 0;
        users[_user].lastBlock = block.number;
        users[_user].lastTimestamp = block.timestamp;
    }

    function touch(address _user) external onlyWhitelisted {
        users[_user].lastBlock = block.number;
        users[_user].lastTimestamp = block.timestamp;
    }

    //////////////////////////
    // OWNER-ONLY FUNCTIONS //
    //////////////////////////

    function setVaultAddress(address _newVaultAddress) public onlyOwner returns (bool _success) {
        require(
            Address.isContract(_newVaultAddress) && 
            _newVaultAddress != address(0) && 
            _newVaultAddress != address(msg.sender), 
            "INVALID_TARGET"
        );
        
        vaultAddress = _newVaultAddress;

        emit onSetTaxVault(msg.sender, _newVaultAddress, block.timestamp);
        return true;
    }

    function setCustomFee(address account, uint8 taxRate) external onlyOwner() returns (bool _success) {
        require(taxRate >= 0 && taxRate <= 100, "Invalid tax amount");

        if (taxRate == 0) {
            fees[account].hasCustomTax = false;
            fees[account].feeRate = 0;
            return true;
        }

        fees[account].hasCustomTax = true;
        fees[account].feeRate = taxRate;
        return true;
    }

    function toggleFees(address account, bool _excluded) external onlyOwner() {
        require(!fees[account].isExcluded, "Account is already excluded");
        fees[account].isExcluded = _excluded;
    }

    function toggleblacklisted(address _addr, bool _marked) onlyOwner() public returns (bool) {
        require(_addr != address(0), "INVALID_ADDRESS");
        
        users[_addr].blacklisted = _marked;

        emit onToggleBlacklisted(msg.sender, _addr, _marked, block.timestamp);
        return true;
    }

    ///////////////////////////////////////
    // INTERNAL / PRIVATE VIEW FUNCTIONS //
    ///////////////////////////////////////

    function calculateFee(uint256 _value, uint8 _tax) internal pure returns (uint256 adjustedValue, uint256 taxAmount){
        taxAmount = _value.mul(_tax).div(100);
        adjustedValue = _value.mul(SafeMath.sub(100, _tax)).div(100);
        return (adjustedValue, taxAmount);
    }

    function _mintTokens(address _user, uint256 _amount) internal returns (bool) {

        // If recipient is a system contract, or blacklisted, 
        // give them nothing. Otherwise, continue with logic.
        if (users[_user].blacklisted) {
            return false;
        }

        //Mint Tokens to user
        _mint(_user, _amount);

        /* Members */
        if (stats[_user].txs == 0) {
            players += 1;
        }

        stats[_user].txs += 1;
        stats[_user].minted += _amount;

        totalTxs += 1;

        return true;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {

    }
}

contract NFTRewardsFactory is Pausable, Whitelist {
    using SafeMath for uint256;

    struct UserData {
        uint256 claimed;  // How many tokens claimed?
        uint256 xClaimed; // How many claims total?

        uint256 lastClaimTime; // When was the last claim time?

        // Tier ID to quantity of items held
        mapping(uint256 => uint256) itemCount;
    }

    // Contract interfaces
    MintableToken public rewardsToken;

    mapping(uint256 => address) watchedContracts;
    mapping(address => UserData) internal _user;

    constructor (address _token) {
        rewardsToken = MintableToken(_token);
        addAddressToWhitelist(msg.sender);
    }

    ////////////////////
    // VIEW FUNCTIONS //
    ////////////////////

    // Find claimed amount of WOOL by an address
    function claimedOf(address _addr) external view returns (uint256) {
        return (_user[_addr].claimed);
    }

    // Find how many claims total an address has made
    function claimsOf(address _addr) external view returns (uint256) {
        return (_user[_addr].xClaimed);
    }

    // How much WOOL is available for the user to mint
    function availableWoolOf(address _addr) public view returns (uint256) {

        // Get the last time of action, calculate the difference between then and now.
        uint256 _lastClaim = lastClaimTimeOf(_addr);
        uint256 _timeDiff = ((block.timestamp).sub(_lastClaim));
        
        // Find the 'tokens per second' and multiply by the time difference
        uint256 _wps = woolPerSecondOf(_addr);
        uint256 _toMint = ((_wps).mul(_timeDiff));

        return _toMint;
    }

    // WOOL per Second of an address
    function woolPerSecondOf(address _addr) public view returns (uint256) {
        (uint256 _tier1, uint256 _tier2, uint256 _tier3, uint256 _tier4, uint256 _tier5, uint256 _tier6) = viewItems(_addr);

        uint256 _tokensPerYear = (
            (_tier1 * getMintPriceOf(1)) + 
            (_tier2 * getMintPriceOf(2)) + 
            (_tier3 * getMintPriceOf(3)) + 
            (_tier4 * getMintPriceOf(4)) + 
            (_tier5 * getMintPriceOf(5)) + 
            (_tier6 * getMintPriceOf(6))
        );

        uint256 _tokensPerDay = (_tokensPerYear.div(365));
        uint256 _tokensPerSec = (_tokensPerDay.div(86400));

        return (_tokensPerSec);
    }

    // Last Claim Time of an address
    function lastClaimTimeOf(address _addr) public view returns (uint256) {

        // If the user has not claimed even once, their first claim time is yet untracked
        // For this, we keep their timestamp at the latest one of the block.
        if (_user[_addr].xClaimed == 0) {
            return block.timestamp;
        }
        return (_user[_addr].lastClaimTime);
    }

    // Get item count of a single tier for one _user
    function totalItemsOfTier(address _addr, uint256 _tierId) public view returns (uint256) {
        return (_user[_addr].itemCount[_tierId]);
    }

    // Get item counts from all tiers for one _user
    function viewItems(address _addr) public view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        uint256 _tier1 = _user[_addr].itemCount[1];
        uint256 _tier2 = _user[_addr].itemCount[2];
        uint256 _tier3 = _user[_addr].itemCount[3];
        uint256 _tier4 = _user[_addr].itemCount[4];
        uint256 _tier5 = _user[_addr].itemCount[5];
        uint256 _tier6 = _user[_addr].itemCount[6];

        return (_tier1, _tier2, _tier3, _tier4, _tier5, _tier6);
    }

    // Find a count of all NFTs from all tiers for an address (stored numbers)
    function totalItemsOf(address _addr) external view returns (uint256) {
        uint256 _tier1 = _user[_addr].itemCount[1];
        uint256 _tier2 = _user[_addr].itemCount[2];
        uint256 _tier3 = _user[_addr].itemCount[3];
        uint256 _tier4 = _user[_addr].itemCount[4];
        uint256 _tier5 = _user[_addr].itemCount[5];
        uint256 _tier6 = _user[_addr].itemCount[6];

        return (
            _tier1 + _tier2 + _tier3 + _tier4 + _tier5 + _tier6
        );
    }

    // Get the price of one of the NFTs (by Tier ID)
    function getMintPriceOf(uint256 _tier) public pure returns (uint256) {

        if (_tier == 1) {return 2e18;}
        if (_tier == 2) {return 4e18;}
        if (_tier == 3) {return 8e18;}
        if (_tier == 4) {return 16e18;}
        if (_tier == 5) {return 32e18;}
        if (_tier == 6) {return 64e18;}

        return 0;
    }

    /////////////////////
    // WRITE FUNCTIONS //
    /////////////////////

    // Add item to NFT array
    function addItem(uint256 _tier, address _item) external onlyWhitelisted() {
        require(_item != address(0), "INVALID_ADDRESS");
        
        watchedContracts[_tier] = _item;
    }

    // Store numbers of NFTs to calculate earnings from (stops buy-claim exploit)
    function updateItems(address _addr) external onlyWhitelisted() {
        _user[_addr].itemCount[1] = IERC721(watchedContracts[1]).balanceOf(_addr);
        _user[_addr].itemCount[2] = IERC721(watchedContracts[2]).balanceOf(_addr);
        _user[_addr].itemCount[3] = IERC721(watchedContracts[3]).balanceOf(_addr);
        _user[_addr].itemCount[4] = IERC721(watchedContracts[4]).balanceOf(_addr);
        _user[_addr].itemCount[5] = IERC721(watchedContracts[5]).balanceOf(_addr);
        _user[_addr].itemCount[6] = IERC721(watchedContracts[6]).balanceOf(_addr);
    }

    // Claim Tokens
    function claimTokens(address _addr) onlyWhitelisted() external returns (uint256) {

        // Find the current earnings of a user
        uint256 _toMint = availableWoolOf(_addr);

        if (_toMint > 0) {
            // Mint the appropriate tokens
            rewardsToken.credit(_addr, _toMint);
        }

        // Update stats
        _user[_addr].lastClaimTime = block.timestamp;
        _user[_addr].claimed += _toMint;
        _user[_addr].xClaimed += 1;

        // Return the amount minted
        return _toMint;
    }

    // Set the Rewards Token Address
    function setRewardsToken(address _newToken) public onlyOwner() {
        rewardsToken = MintableToken(_newToken);
    }
}