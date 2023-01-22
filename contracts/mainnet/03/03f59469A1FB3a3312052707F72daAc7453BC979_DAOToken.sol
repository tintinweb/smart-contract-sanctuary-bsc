/**
 *Submitted for verification at BscScan.com on 2023-01-22
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

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
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address public _owner;
    address private _previousOwner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }


}

contract DAOToken is Context, IERC20, Ownable {

    mapping (address => uint256) private owned;
    mapping (address => uint256) private lockedTokens;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromRestrictions; //no transaction restrictions. Privileged addresses.

    string private _name;
    string private _symbol;
    uint256 constant _decimals = 18;
    uint256 private _totalsupply;

    uint256 public maxTxAmount;

    address public saleContract;
    address public multiSig;

    bool public lockedTokensFreelyTradeable = true;
    event LockedTransfer (address from, address to, uint256 amount);
    event MintedTokens (address to, uint256 amount);
    event UnlockAllTokens(address from, bool unlockStatus);

    modifier onlyMultiSig() {
        require(multiSig == _msgSender(), "Ownable: caller is not the multisignature wallet");
        _;
    }

    constructor (string memory _NAME, string memory _Symbol, uint256 _Supply, address _multiSig) payable {
        //TOKEN CONSTRUCT
        _name = _NAME;
        _symbol = _Symbol;
        _totalsupply  = _Supply * 10 ** _decimals;

        maxTxAmount = (_totalsupply * 5 ) / 1000; //Enter maximum transaction size for all non-privileged accounts

        //*****************************************
        _owner = _msgSender(); //Enter owner address
        //*****************************************

        owned[_owner] = _totalsupply;
        multiSig = _multiSig;

        _isExcludedFromRestrictions[_owner] = true;
        _isExcludedFromRestrictions[address(this)] = true;

        payable(_owner).transfer(msg.value);
        emit Transfer(address(0), _owner, _totalsupply);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint256){
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalsupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return owned[account] + lockedTokens[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function saleApprove(address sender, address spender, uint256 amount) external returns (bool) {
        require(_msgSender() == saleContract, "You are not Sale Contract");
        require(spender == saleContract, "Spender must be Sale Contract");
        _approve(sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 balance = _allowances[sender][_msgSender()];
        require(balance >= amount, "Insufficient allowance");
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function changeAllowance(address spender, uint256 newValue) public virtual returns (bool) {
        require(owned[_msgSender()] >= newValue, "Insufficient balance");
        _approve(_msgSender(), spender, newValue);
        return true;
    }

    function mint(uint256 amount) external onlyOwner(){
        _totalsupply = amount + _totalsupply;
        owned[multiSig] = owned[multiSig] + amount;
        emit MintedTokens(multiSig, amount);
    }

    function lockedTransfer(address recipient, uint256 amount) external returns (bool) {
        address sender = _msgSender();
        require(sender == saleContract, "You are not authorized to perform this action");
        require(recipient != _owner && recipient != saleContract, "Cant do locked transfer to this account");
        require(amount > 0, "Transfer amount must be greater than 0");
        require(amount <= unlockedBalanceOf(sender), "Insufficient balance");
        require(recipient != address(0), "ERC20: transfer to the 0 address");

        owned[sender] = owned[sender] - amount;
        lockedTokens[recipient] = lockedTokens[recipient] + amount;
        emit LockedTransfer(sender, recipient, amount);
        return true;
    }

    function unlockedBalanceOf(address account) public view returns (uint256) {
        return owned[account];
    }

    function unlockAllTokens(bool unlock) external returns (bool){
        if(unlock == true){
            require(_msgSender() == multiSig, "You are not authorized");
        }
        else {
            require(_msgSender() == multiSig || _msgSender() == saleContract, "You are not authorized");
        }
        lockedTokensFreelyTradeable = unlock;
        emit UnlockAllTokens(_msgSender(), unlock);
        return lockedTokensFreelyTradeable;
    }

    function setMaxTxAmount(uint256 _amount) external onlyOwner() {
        require(_amount > 0, "MaxTxAmount cannot be 0");
        maxTxAmount = _amount;
    }

    function setSaleContract(address _salecontract) external onlyMultiSig() {
        require(lockedTokensFreelyTradeable == true, "Tokens are still locked");
        if(saleContract != address(0)){
            _isExcludedFromRestrictions[saleContract] = false;
        }
        _isExcludedFromRestrictions[_salecontract] = true;
        saleContract = _salecontract;
    }

    function setMultiSig(address _multisig) external onlyMultiSig() {
        multiSig = _multisig ;
    }

    //to recieve BNB to this contract
    receive() external payable {}

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the 0 address");
        require(amount > 0, "Transfer amount must be greater than 0");
        if(!_isExcludedFromRestrictions[sender]) {
            require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            require(recipient != address(0), "ERC20: transfer to the 0 address");
        }
        if(lockedTokensFreelyTradeable) {
            uint256 countlockedtokens = lockedTokens[sender];
            require(amount <= balanceOf(sender), "Insufficient balance");
            if(amount > countlockedtokens){
                uint256 newamount = amount - countlockedtokens;
                lockedTokens[sender] = 0;
                owned[sender] = owned[sender] - newamount;
                owned[recipient] = owned[recipient] + amount;
            }
            else{
                lockedTokens[sender] = countlockedtokens - amount;
                owned[recipient] = owned[recipient] + amount;
            }
        }
        else {
            require(amount <= owned[sender], "Tokens are locked or insufficient balance");
            owned[sender] = owned[sender] - amount;
            owned[recipient] = owned[recipient] + amount;
        }
        if(recipient == address(0)){
            _totalsupply = _totalsupply - amount;
        }
        emit Transfer(sender, recipient, amount);
    }

    function unlockMyTokens() external returns (uint256){
        require(lockedTokensFreelyTradeable == true, "Tokens are not unlocked yet");
        address sender = _msgSender();
        uint256 lockedtokens = lockedTokens[sender];
        lockedTokens[sender] = 0;
        owned[sender] = owned[sender] + lockedtokens;
        return lockedtokens;
    }

    function excludeFromRestrictions(address account, bool exclude) onlyOwner() public returns (bool) {
        _isExcludedFromRestrictions[account] = exclude;
        return _isExcludedFromRestrictions[account];
    }

    function rescueBNB(address to) external onlyOwner() {
        payable(to).transfer(address(this).balance);
    }

    function rescueBEP20Token(address token, address to) external onlyOwner() returns(bool returned) {
        IERC20 rescuedContract = IERC20(token);
        require(rescuedContract.transfer(to, rescuedContract.balanceOf(address(this))), "Token Address is incorrect or not ERC20");
        return true;
    }

}