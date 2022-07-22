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

contract WoolToken is ERC20, Whitelist {
    using SafeMath for uint256;

    struct Stats {
        uint256 txs;
        uint256 minted;
    }

    struct MintInfo {

        //Amount Tracker
        uint256 pending;
        uint256 total;

        //Block Tracker
        uint256 lastBlock;
        uint256 lastTimestamp;
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
    mapping(address => MintInfo) public users;

    mapping (address => uint8) private _customTaxRate;
    
    mapping (address => bool) private _hasCustomTax;
    mapping (address => bool) private _isExcluded;

    mapping (address => bool) internal _ecosystem;
    mapping (address => bool) internal _blacklisted;

    event TaxPayed(address from, address vault, uint256 amount);

    event onToggleBlacklistAddress(address indexed _caller, bool _setting, uint256 _timestamp);
    event onToggleSystemContract(address indexed _caller, bool _setting, uint256 _timestamp);

    constructor(uint256 _initialMint, address _operator) ERC20("Degen Protocol: WOOL", "WOOL") Ownable() {

        addAddressToWhitelist(_operator);
        
        _mint(_operator, _initialMint);
        
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

    // DELAYED-MINT TECH BY @BANKTELLER

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

    // Delayed-mint token delivery system
    // contributed by @BankTeller of Elephant Money

    function claim() external returns (bool) {

        address _user = msg.sender;
        uint256 _amount = users[_user].pending;

        bool _minted = _mintTokens(_user, _amount);
        require(_minted == true, "FAILED_TO_MINT");

        return true;
    }

    function directMint(address _user, uint256 _amount) external onlyWhitelisted returns (bool) {
        users[_user].total += _amount;
        users[_user].lastBlock = block.number;
        users[_user].lastTimestamp = block.timestamp;

        bool _minted = _mintTokens(_user, _amount);
        require(_minted == true, "FAILED_TO_MINT");

        return true;
    }

    function addMint(address _user, uint256 _amount) external onlyWhitelisted {
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

    function toggleBlacklisted(address _addr, bool _marked) onlyOwner() public returns (bool) {
        require(_addr != address(0), "INVALID_ADDRESS");
        
        _blacklisted[_addr] = _marked;

        emit onToggleBlacklistAddress(msg.sender, _marked, block.timestamp);
        return true;
    }

    function toggleSystemContract(address _contract, bool _marked) onlyOwner() public returns (bool) {
        require(Address.isContract(_contract), "INVALID_ADDRESS");

        _ecosystem[_contract] = _marked;

        emit onToggleSystemContract(msg.sender, _marked, block.timestamp);
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
        if (_ecosystem[_user] || _blacklisted[_user]) {
            return false;
        }

        //Mint Tokens to user
        _mint(_user, _amount);
        mintedSupply_ = mintedSupply_.add(_amount);

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