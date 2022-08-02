// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Address.sol";
import "./Math.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";

import "./IERC20.sol";

import "./Context.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";

import "./Whitelist.sol";
import "./ERC20.sol";

contract MintableToken is ERC20, Whitelist {
    using SafeMath for uint256;

    struct StatInfo {
        uint256 txs;
        uint256 minted;
        uint256 burned;
    }

    struct UserInfo {
        uint256 pending;
        uint256 total;

        uint256 lastBurnBlock;
        uint256 lastBurnTime;

        uint256 lastMintBlock;
        uint256 lastMintTime;
    }

    ///////////////////////////////
    // CONFIGURABLES & VARIABLES //
    ///////////////////////////////

    address[] public excludedFromFees;

    address public feeRecipient;

    uint8 public feePercent = 10; // 10% tax on transfers

    uint256 public totalTxs;
    uint256 public players;

    //////////////////
    // DATA MAPPING //
    //////////////////

    mapping(address => StatInfo) private stats;
    mapping(address => UserInfo) private users;

    mapping (address => uint8) private _customTaxRate;
    
    mapping (address => bool) private _hasCustomTax;
    mapping (address => bool) private _isExcluded;

    mapping (address => bool) private _blacklisted;

    /////////////////////
    // CONTRACT EVENTS //
    /////////////////////

    event TaxPayed(address from, address vault, uint256 amount);

    event onBurnTokens(address from, uint256 amount);
    event onMintTokens(address to, uint256 amount);

    event onSetBlacklist(address indexed _caller, bool _setting, uint256 _timestamp);

    ////////////////////////////
    // CONSTRUCTOR & FALLBACK //
    ////////////////////////////

    constructor(uint256 _initialMint, address _recipient) ERC20("Degen Protocol Wool", "WOOL") Ownable() {
        address _operator = msg.sender;

        addAddressToWhitelist(_operator);
        
        _mint(_recipient, _initialMint);
        
        removeAddressFromWhitelist(_operator);
    }

    ////////////////////////////
    // PUBLIC WRITE FUNCTIONS //
    ////////////////////////////

    // Mint available tokens to caller
    function claim() external returns (bool) {

        address _user = msg.sender;
        uint256 _amount = users[_user].pending;

        bool _minted = _mintTokens(_user, _amount);
        require(_minted == true, "FAILED_TO_MINT");

        emit onMintTokens(_user, _amount);
        return true;
    }

    // Burn tokens from the total supply
    function burn(uint256 _amount) external returns (bool) {
        address _user = msg.sender;
        require(balanceOf(_user) >= _amount, "FAILED_TO_BURN");
        
        bool _burned = _burnTokens(_user, _amount);
        require(_burned == true, "FAILED_TO_BURN");
        
        emit onBurnTokens(_user, _amount);
        return true;
    }

    // Transfers
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

    // Transfers (using transferFrom)
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
        return (
            stats[player].minted, 
            stats[player].burned, 
            stats[player].txs
        );
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
            uint8 taxPercent = feePercent; // set to default tax 10%

            // set custom tax rate if applicable
            if (_hasCustomTax[_from]){
                taxPercent = _customTaxRate[_from];
            }

            (adjustedValue, taxAmount) = calculateTransactionTax(_value, taxPercent);
        }
        return (adjustedValue, taxAmount);
    }

    // Tokens available to mint
    function available(address _user) external view returns (uint256) {
        if (users[_user].pending > 0 && block.number > users[_user].lastMintBlock.add(2)){
            return users[_user].pending;
        } else {
            return 0;
        }
    }

    // Mint readiness of an address (block cooldown)
    function ready(address _user) external view  returns (bool) {
        return block.number > users[_user].lastMintBlock.add(2);
    }

    // Pending mintable tokens of an address
    function pending(address _user) external view returns (uint256) {
        return users[_user].pending;
    } 

    // Last mint timestamp of an address
    function lastMint(address _user) external view returns (uint256 lastMintBlock, uint256 lastMintTime) {
        lastMintBlock = users[_user].lastMintBlock;
        lastMintTime = users[_user].lastMintTime;
    }

    // Last burn timestamp of an address
    function lastBurn(address _user) external view returns (uint256 lastBurnBlock, uint256 lastBurnTime) {
        lastBurnBlock = users[_user].lastBurnBlock;
        lastBurnTime = users[_user].lastBurnTime;
    }

    ////////////////////////////////
    // RESTRICTED WRITE FUNCTIONS //
    ////////////////////////////////

    // Mint _amount to FeeRecipient
    // This is generally for the Woolshed, to pay rewards if required.
    function print(uint256 _amount) external onlyWhitelisted() returns (bool) {
        users[feeRecipient].total += _amount;
        users[feeRecipient].lastMintBlock = block.number;
        users[feeRecipient].lastMintTime = block.timestamp;

        bool _minted = _mintTokens(feeRecipient, _amount);
        require(_minted == true, "FAILED_TO_MINT");

        return true;
    }

    // Credit _user with _amount of WOOL, and add to pending mintable tokens.
    function credit(address _user, uint256 _amount) external onlyWhitelisted() {
        users[_user].pending += _amount;
        users[_user].total += _amount;
        users[_user].lastMintBlock = block.number;
        users[_user].lastMintTime = block.timestamp;
    }
    
    // Settle _user's pending tokens, and remove from pending mintable tokens.
    function settle(address _user) external onlyWhitelisted() {
        users[_user].pending = 0;
        users[_user].lastMintBlock = block.number;
        users[_user].lastMintTime = block.timestamp;
    }

    // Update timestamps of _user
    function touch(address _user) external onlyWhitelisted() {
        users[_user].lastBurnBlock = block.number;
        users[_user].lastBurnTime = block.timestamp;

        users[_user].lastMintBlock = block.number;
        users[_user].lastMintTime = block.timestamp;
    }

    //////////////////////////
    // OWNER-ONLY FUNCTIONS //
    //////////////////////////

    function setFeeRecipient(address _addr) external onlyOwner() {
        feeRecipient = _addr;
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
        excludedFromFees.push(account);
    }

    function includeAccount(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < excludedFromFees.length; i++) {
            if (excludedFromFees[i] == account) {
                excludedFromFees[i] = excludedFromFees[excludedFromFees.length - 1];
                _isExcluded[account] = false;
                delete excludedFromFees[excludedFromFees.length - 1];
                break;
            }
        }
    }

    function setBlacklisted(address _addr, bool _bool) onlyOwner() public returns (bool) {
        require(_addr != address(0), "INVALID_ADDRESS");
        
        _blacklisted[_addr] = _bool;

        emit onSetBlacklist(msg.sender, _bool, block.timestamp);
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

        // Blacklisted addresses get no minted tokens
        if (_blacklisted[_user]) {
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

    function _burnTokens(address _user, uint256 _amount) internal returns (bool) {
        _burn(_user, _amount);

        stats[_user].txs += 1;
        stats[_user].burned += _amount;

        totalTxs += 1;

        return true;
    }
}