/**
 *Submitted for verification at BscScan.com on 2022-06-27
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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

contract Whitelist is Ownable {

    mapping(address => bool) public whitelist;
    
    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], 'not whitelisted');
        _;
    }

    function addAddressToWhitelist(address addr) public onlyOwner returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
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

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);

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

    struct Stats {
        uint256 txs;
        uint256 minted;
        uint256 burned;
    }

    struct UserInfo {

        // Can receive from mint calls
        bool blacklisted;

        //Amount Tracker
        uint256 pending;
        uint256 total;

        //Block Tracker
        uint256 lastBlock;
        uint256 lastTimestamp;

        // Fee Settings
        bool hasCustomTax;
        bool isExcluded;

        // Custom Fee Rate
        uint8 customTaxRate;
    }

    address[] private _excluded;

    address public feeRecipient;

    uint8 constant internal taxDefault = 10; // 10% tax on transfers

    uint256 public totalTxs;
    uint256 public players;

    mapping(address => Stats) private stats;
    mapping(address => UserInfo) public users;

    event TaxPayed(address from, address vault, uint256 amount);

    event onToggleBlacklistAddress(address indexed _caller, bool _setting, uint256 _timestamp);

    constructor(string memory _name, string memory _symbol, address _feeRecipient) ERC20(_name, _symbol) Ownable() {
        feeRecipient = _feeRecipient;
    }

    ////////////////////////////
    // PUBLIC WRITE FUNCTIONS //
    ////////////////////////////

    // Claim any tokens entitled to caller
    function claim() external returns (bool) {

        address _user = msg.sender;
        uint256 _amount = users[_user].pending;

        bool _minted = _mintTokens(_user, _amount);
        require(_minted == true, "FAILED_TO_MINT");

        settle(_user);

        return true;
    }

    // Burn tokens
    function burn(uint256 _amount) public returns (bool) {
        require(_amount > 0, "NON_ZERO_TRANSACTIONS_FORBIDDEN");

        (uint256 adjustedValue, uint256 taxAmount) = calculateTransferTaxes(msg.sender, _amount);

        if (taxAmount > 0){
            require(super.transfer(feeRecipient, taxAmount));
            emit TaxPayed(msg.sender, feeRecipient, taxAmount);
        }

        _burn(msg.sender, adjustedValue);

        stats[msg.sender].txs += 1;
        stats[msg.sender].burned += _amount;

        totalTxs += 1;

        return true;
    }

    // Transfer tokens
    function transfer(address _to, uint256 _value) public override returns (bool) {

        (uint256 adjustedValue, uint256 taxAmount) = calculateTransferTaxes(msg.sender, _value);

        if (taxAmount > 0){
            require(super.transfer(feeRecipient, taxAmount));
            emit TaxPayed(msg.sender, feeRecipient, taxAmount);
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

    // TransferFrom tokens
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {

        (uint256 adjustedValue, uint256 taxAmount) = calculateTransferTaxes(_from, _value);

        if (taxAmount > 0){
            require(super.transferFrom(_from, feeRecipient, taxAmount));
            emit TaxPayed(_from, feeRecipient, taxAmount);
        }
        require(super.transferFrom(_from, _to, adjustedValue));

        /* Members */
        if (stats[_to].txs == 0) {
            players += 1;
        }

        stats[_to].txs += 1;
        stats[_from].txs += 1;

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

    // Returns the number of tokens minted by the player
    function mintedBy(address player) public view returns (uint256){
        return stats[player].minted;
    }

    // Check if an address is exempt from transfer fees
    function isExcluded(address account) public view returns (bool) {
        return users[account].isExcluded;
    }

    // Calculate transfer taxes
    function calculateTransferTaxes(address _from, uint256 _value) public view returns (uint256 adjustedValue, uint256 taxAmount){
        adjustedValue = _value;
        taxAmount = 0;

        // If user is not excluded from fees,
        if (!users[_from].isExcluded) {
            uint8 taxPercent = taxDefault; // set to default tax 10%

            // set custom tax rate if applicable
            if (users[_from].hasCustomTax){
                taxPercent = users[_from].customTaxRate;
            }

            (adjustedValue, taxAmount) = calculateTransactionTax(_value, taxPercent);
        }
        return (adjustedValue, taxAmount);
    }

    /////////////////////////////
    // EXTERNAL VIEW FUNCTIONS //
    /////////////////////////////

    // Tokens available to claim by _user
    function available(address _user) external view returns (uint256) {
        if (users[_user].pending > 0 && block.number > users[_user].lastBlock.add(2)){
            return users[_user].pending;
        } else {
            return 0;
        }
    }

    // Check if _user can claim tokens
    function ready(address _user)  external view returns (bool) {
        return block.number > users[_user].lastBlock.add(2);
    }

    // Tokens pending to claim by _user
    function pending(address _user)  external view returns (uint256) {
        return users[_user].pending;
    } 

    // Get last block and time of mint by _user
    function lastMint(address _user)  external view returns (uint256 lastBlock, uint256 lastTimestamp) {
        lastBlock = users[_user].lastBlock;
        lastTimestamp = users[_user].lastTimestamp;
    }

    ////////////////////////////////
    // RESTRICTED WRITE FUNCTIONS //
    ////////////////////////////////

    // Add more tokens to the Fee Recipient
    function topUpRewards(uint256 _amount) external onlyWhitelisted returns (bool) {
        users[feeRecipient].total += _amount;
        users[feeRecipient].lastBlock = block.number;
        users[feeRecipient].lastTimestamp = block.timestamp;

        require(_mintTokens(feeRecipient, _amount), "FAILED_TO_MINT");

        settle(feeRecipient);

        return true;
    }

    // Add tokens to _user credits, for _user to claim after mint delay
    function credit(address _user, uint256 _amount) public onlyWhitelisted {
        users[_user].pending += _amount;
        users[_user].total += _amount;
        users[_user].lastBlock = block.number;
        users[_user].lastTimestamp = block.timestamp;
    }
    
    // Settle rewards debt to _user
    function settle(address _user) public onlyWhitelisted {
        users[_user].pending = 0;
        users[_user].lastBlock = block.number;
        users[_user].lastTimestamp = block.timestamp;
    }

    // Heartbeat for _user
    function touch(address _user) public onlyWhitelisted {
        users[_user].lastBlock = block.number;
        users[_user].lastTimestamp = block.timestamp;
    }

    ////////////////////////////////
    // OWNER-ONLY WRITE FUNCTIONS //
    ////////////////////////////////

    // Set Fee Recipient Address
    function setFeeRecipientAddress(address _newVaultAddress) public onlyOwner() {
        feeRecipient = _newVaultAddress;
    }

    // Set custom tax for account
    function setAccountCustomTax(address account, uint8 taxRate) external onlyOwner() {
        require(taxRate >= 0 && taxRate <= 100, "Invalid tax amount");
        users[account].hasCustomTax = true;
        users[account].customTaxRate = taxRate;
    }

    // Remove custom tax for account
    function removeAccountCustomTax(address account) external onlyOwner() {
        users[account].hasCustomTax = false;
    }

    // Exclude an account from fees
    function excludeAccount(address account) external onlyOwner() {
        require(!users[account].isExcluded, "Account is already excluded");
        users[account].isExcluded = true;
        _excluded.push(account);
    }

    // Include an account to fees
    function includeAccount(address account) external onlyOwner() {
        require(users[account].isExcluded, "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                users[account].isExcluded = false;
                delete _excluded[_excluded.length - 1];
                break;
            }
        }
    }

    // Prevent an address from receiving minted tokens
    function toggleBlacklisted(address _addr, bool _marked) onlyOwner() public returns (bool) {
        require(_addr != address(0), "INVALID_ADDRESS");
        
        users[_addr].blacklisted = _marked;

        emit onToggleBlacklistAddress(msg.sender, _marked, block.timestamp);
        return true;
    }

    ///////////////////////////////////////
    // INTERNAL / PRIVATE VIEW FUNCTIONS //
    ///////////////////////////////////////

    function calculateTransactionTax(uint256 _value, uint8 _tax) internal pure returns (uint256 adjustedValue, uint256 taxAmount){
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
}