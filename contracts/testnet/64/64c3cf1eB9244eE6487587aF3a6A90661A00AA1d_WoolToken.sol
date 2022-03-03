// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Address.sol";
import "./Math.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";

import "./IERC20.sol";

import "./Context.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";

import "./Whitelist.sol";

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
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

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
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

contract WoolToken is ERC20, Whitelist {
    using SafeMath for uint256;

    struct Stats {
        uint256 txs;
        uint256 minted;
    }

    address[] private _excluded;

    address public vaultAddress;

    bool public mintingFinished = false;

    uint8 constant internal taxDefault = 10; // 10% tax on transfers

    uint256 public constant MAX_INT = 2**256 - 1;
    uint256 public constant targetSupply = MAX_INT;

    uint256 public totalTxs;
    uint256 public players;
    
    uint256 private mintedSupply_;

    mapping(address => Stats) private stats;

    mapping (address => uint8) private _customTaxRate;
    
    mapping (address => bool) private _hasCustomTax;
    mapping (address => bool) private _isExcluded;

    event TaxPayed(address from, address vault, uint256 amount);

    constructor(uint256 _initialMint, address _operator) ERC20("Degen Protocol: WOOL", "WOOL") Ownable() {

        addAddressToWhitelist(_operator);
        
        mint(_operator, _initialMint * 1e18);
        
        removeAddressFromWhitelist(_operator);
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
        stats[_from].txs += 1;

        totalTxs += 1;

        return true;


    }

    ///////////////////////////
    // PUBLIC VIEW FUNCTIONS //
    ///////////////////////////

    // Returns the supply still available to mint
    function remainingMintableSupply() public view returns (uint256) {
        return targetSupply.sub(mintedSupply_);
    }

    // Returns the cap for the token minting.
    function cap() public pure returns (uint256) {
        return targetSupply;
    }

    // total number of minted tokens
    function mintedSupply() public view returns (uint256) {
        return mintedSupply_;
    }

    // stats of player, (txs, minted)
    function statsOf(address player) public view returns (uint256, uint256, uint256){
        return (balanceOf(player), stats[player].txs, stats[player].minted);
    }

    // Returns the number of tokens minted by the player
    function mintedBy(address player) public view returns (uint256){
        return stats[player].minted;
    }

    // Check if an address is exempt from transfer taxes or not
    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    // Calculate transfer taxes for WOOL
    function calculateTransferTaxes(address _from, uint256 _value) public view returns (uint256 adjustedValue, uint256 taxAmount){
        adjustedValue = _value;
        taxAmount = 0;

        if (!_isExcluded[_from]) {
            uint8 taxPercent = taxDefault; // set to default tax 10%

            // set custom tax rate if applicable
            if (_hasCustomTax[_from]){
                taxPercent = _customTaxRate[_from];
            }

            (adjustedValue, taxAmount) = calculateTransactionTax(_value, taxPercent);
        }
        return (adjustedValue, taxAmount);
    }

    ////////////////////////////////
    // OWNER-ONLY WRITE FUNCTIONS //
    ////////////////////////////////

    function setVaultAddress(address _newVaultAddress) public onlyOwner {
        vaultAddress = _newVaultAddress;
    }

    function setAccountCustomTax(address account, uint8 taxRate) external onlyOwner() {
        require(taxRate >= 0 && taxRate <= 100, "Invalid tax amount");
        _hasCustomTax[account] = true;
        _customTaxRate[account] = taxRate;
    }

    function removeAccountCustomTax(address account) external onlyOwner() {
        _hasCustomTax[account] = false;
    }

    function excludeAccount(address account) external onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccount(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _isExcluded[account] = false;
                delete _excluded[_excluded.length - 1];
                break;
            }
        }
    }

    ////////////////////////////////
    // RESTRICTED WRITE FUNCTIONS //
    ////////////////////////////////

    function mint(address _to, uint256 _amount) onlyWhitelisted public returns (bool) {

        //Mint
        _mint(_to, _amount);
        mintedSupply_ = mintedSupply_.add(_amount);

        /* Members */
        if (stats[_to].txs == 0) {
            players += 1;
        }

        stats[_to].txs += 1;
        stats[_to].minted += _amount;

        totalTxs += 1;

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
}