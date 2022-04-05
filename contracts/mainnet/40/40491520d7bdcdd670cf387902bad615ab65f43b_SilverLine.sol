/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-16
*/
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount  ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IBEP20Metadata is IBEP20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BEP20 is Context, IBEP20, IBEP20Metadata{

    struct  userTime{
        uint256 transferTime;
        uint256 unlockTime ;        
    }

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private WhitelistNoLimit;

    mapping(address => bool) private whitelistedNoCooldown;

    mapping(address => userTime) private blacklistDetails;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event TransferLimitUpdated(uint256 updatedTransferLimit);
    event AddedUserNoLimit( address indexed userAddress);
    event RemovedUserNoLimit(address indexed userAddress);
    event AddedUserNoCoolDown( address indexed userAddress);
    event RemovedUserNoCoolDown(address indexed userAddress);
    event AntibotDelayDuration(uint256 delayTime);

    
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    address public owner;

    uint256 public _transferLimit = 100000000 * 10 ** decimals();
    uint256 public delayDuration = 10 ;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 12;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner{
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transfer(owner,newOwner,_balances[owner]);
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address _owner, address spender) public view virtual override returns (uint256) {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function updateTransferLimit(uint256 newtransferLimit) public onlyOwner{
        _transferLimit = newtransferLimit;
        emit TransferLimitUpdated(_transferLimit);
    }

    function addWhitelistTransferLimit (address _whitelistedAddress) public onlyOwner{
        require(!WhitelistNoLimit[_whitelistedAddress],"already user whitelisted");
        WhitelistNoLimit[_whitelistedAddress] = true ;
        emit AddedUserNoLimit(_whitelistedAddress);
    }

    function verifyUserTransferLimit(address _whitelistedAddress) public  view returns(bool) {
        bool userIsWhitelisted = WhitelistNoLimit[_whitelistedAddress];
        return userIsWhitelisted; 
    }

    function removeWhitelistTransferLimit(address _whitelistedAddress) public onlyOwner{
        require(WhitelistNoLimit[_whitelistedAddress],"user is not listed");
        WhitelistNoLimit[_whitelistedAddress] = false ;
        emit RemovedUserNoLimit(_whitelistedAddress);
    }

      function addWhitelistNoCoolDown(address _whitelistedAddress) public onlyOwner{
        require(!whitelistedNoCooldown[_whitelistedAddress],"already user whitelisted");
        whitelistedNoCooldown[_whitelistedAddress] = true ;
        emit AddedUserNoCoolDown(_whitelistedAddress);
    }

    function verifyUserNoCoolDown(address _whitelistedAddress) public  view returns(bool) {
        bool userIsWhitelisted = whitelistedNoCooldown[_whitelistedAddress];
        return userIsWhitelisted; 
    }

    function removeWhitelistNoCoolDown(address _whitelistedAddress) public onlyOwner{
        require(whitelistedNoCooldown[_whitelistedAddress],"user is not listed");
        whitelistedNoCooldown[_whitelistedAddress] = false ;
        emit RemovedUserNoCoolDown(_whitelistedAddress);
    }

    function setTransferInterval (uint256 _delayDuration) public onlyOwner{
        delayDuration = _delayDuration;
        emit AntibotDelayDuration (delayDuration);
    }
     
    function _coolDown(address sender) internal  {
        require( block.timestamp >= blacklistDetails[sender].unlockTime,"wait untill the cooldown ends");
        blacklistDetails[sender].transferTime = block.timestamp;
        blacklistDetails[sender].unlockTime = blacklistDetails[sender].transferTime + delayDuration;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        if(sender != owner  && !WhitelistNoLimit[sender]){
            require(amount <= _transferLimit,"BEP20: amount should be less than transfer limit owner");
        }

        if((sender != owner) && (delayDuration != 0)  && !whitelistedNoCooldown[sender]){
            _coolDown(sender);
        }     
        
        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address _owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(_owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    function burn(uint256 amount) public onlyOwner {
        _burn(msg.sender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


contract SilverLine is BEP20{

    constructor() BEP20("SilverLine", "SLN") {
        _mint(msg.sender, 1000000000000 * 10 ** decimals());
    }

}