/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) { 
        return sub(a, b, "SafeMath: subtraction overflow"); 
    }
 
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) { 
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b; 
        require(c / a == b);

        return c;
    }
 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b; 
        return c;
    }
   
}


contract EfatahLock is IERC20 {
    using SafeMath for uint256;

    string private _name = "EFATAHLOCK";
    string private _symbol = "EFA";
    uint256 private constant MAX_SUPPLY = 7777700000000; // 77,777 * 10**8;
    uint8 private constant DECIMALS = 8;
    address payable private _ADMIN_ADDR;

    uint256 private _TRF_PCENT = 0; //Transfer Percentage
    uint256 private _TAX_PCENT = 0; 
    uint256 private _MAX_DAILY_TRANSFER_PCENT = 100;//default is 100%

    mapping (address => uint256) private _ACCOUNTS_BAL;
    mapping(address => bool) _ACCOUNTS_EXEMPT;
    uint256 public _TIME24_HOURS = 600;  

    struct user { 
        uint256 TxnTime;
        uint256 TxnAmount;
    }
    mapping(address => user) public _USER_TXNS;

     mapping (address => mapping (address => uint256)) private _ALLOWANCES;


    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    modifier onlyAdmin() {
        require(_ADMIN_ADDR == _msgSender(), "caller is not the admin");
        _;
    }

    constructor(address payable ownerAddr) {
        _ADMIN_ADDR = ownerAddr;
        _ACCOUNTS_BAL[ownerAddr] = MAX_SUPPLY;
    }

    fallback() external payable {}
    receive() external payable {} 
    
   

    function withdrawBNB(uint256 amount) public onlyAdmin { 
        _msgSender().transfer(amount);
    }

    function withdrawToken(address token_addr) public onlyAdmin
    {
        require(token_addr != address(this), "Other Tokens"); 
        IERC20 token = IERC20(token_addr);
        token.transfer(_msgSender(), token.balanceOf(address(this)));
    }

    function exemptAddressFromFees(address account) external onlyAdmin() {
        require(_ACCOUNTS_EXEMPT[account], "Address is already excluded from fees"); 
        _ACCOUNTS_EXEMPT[account] = true;        
    }
    
    function removeExemptAddressFromFees(address account) external onlyAdmin() {
        require(!_ACCOUNTS_EXEMPT[account], "Address is already removed from exclusion"); 
        _ACCOUNTS_EXEMPT[account] = false;        
    }
 
    function setTaxFeePercent(uint256 taxPercent) external onlyAdmin() {
        require(taxPercent >= 0 && taxPercent <= 5, 'taxFee should be between 0% - 5%');
        _TAX_PCENT = taxPercent;
    }

    function setTranferFeePercent(uint256 transferFeePercent) external onlyAdmin() {
        require(transferFeePercent >= 0 && transferFeePercent <= 100, 'transferFee should be between 0% - 100%');
        _TRF_PCENT = transferFeePercent;
    }
 
    function transferOwnership(address payable addr) external onlyAdmin() {
        require(addr != address(0x0)); 
        _ADMIN_ADDR = addr;
    }

    //event eventTransfer(address payable receiver, uint256 amt);
    //event eventSubscribe(address sender, uint256 bnb, uint256 cashback, uint256 efa, uint wallets);

 
    function getInfo() public view returns (
            //string memory name,
            //string memory symbol,
            uint256 total_supply, 
            uint256 tax_fee_percent,
            uint256 transfer_fee_percent, 
            uint256 max_daily_transfer_percent,
            address admin_address, 
            uint256 account_balance, 
            uint256 my_balance 
        )
    {
        return ( 
            MAX_SUPPLY,  
            _TAX_PCENT,
            _TRF_PCENT,
            _MAX_DAILY_TRANSFER_PCENT,
            _ADMIN_ADDR, 
            _ACCOUNTS_BAL[_ADMIN_ADDR],
            _ACCOUNTS_BAL[msg.sender]
        ); 
    }
  
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return DECIMALS;
    }

    function totalSupply() public pure override returns (uint256) {
        return MAX_SUPPLY;
    }

    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.
 
    modifier validAddress(address addr) {
        require(addr != address(0x0));
        _;
    }
    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 

    function balanceOf(address account) public view override returns (uint256) {
        return _ACCOUNTS_BAL[account];
    }
   
    function allowance(address allow_owner, address spender) external view override returns (uint256){
        return _ALLOWANCES[allow_owner][spender];
    }

    function approve(address spender, uint256 numTokens) public override returns (bool) {
        _approve(_msgSender(), spender, numTokens);
        return true;
    }

    function _approve(address tokenOwner, address spender, uint256 numTokens) private {
        require(tokenOwner != address(0x0), "BEP20: approve from the zero address");
        require(spender != address(0x0), "BEP20: approve to the zero address");

        _ALLOWANCES[tokenOwner][spender] = numTokens;
        emit Approval(tokenOwner, spender, numTokens);
    }
    
    function transfer(address recipient, uint256 numTokens) public override returns (bool){
        _transferFrom(_msgSender(), recipient, numTokens);
        return true;
    }

    function transferFrom(address sender,  address recipient,  uint256 numTokens) public override returns (bool) {
        _transferFrom(sender, recipient, numTokens);
         _approve(sender, _msgSender(), _ALLOWANCES[sender][_msgSender()].sub(numTokens, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
 
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _ALLOWANCES[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _ALLOWANCES[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {

        require(amount > 0, "Transfer amount must be greater than zero");
        require(sender != address(0x0), "BEP20: transfer from the zero address");
        require(recipient != address(0x0), "BEP20: transfer to the zero address");

        bool is_account_exempted = _ACCOUNTS_EXEMPT[sender] || _ACCOUNTS_EXEMPT[recipient];

        if (is_account_exempted) {  
            _ACCOUNTS_BAL[sender] = _ACCOUNTS_BAL[sender].sub(amount);
            _ACCOUNTS_BAL[recipient] = _ACCOUNTS_BAL[recipient].add(amount);

            emit Transfer(sender, recipient, amount);               
            return true;
        }
 
        //These transactions involves fees  
        uint256 max_amount_transfer_allowed = 0;
        uint256 account_balance = balanceOf(sender); 

        if (block.timestamp > (_USER_TXNS[sender].TxnTime + _TIME24_HOURS)) {
            //it means last transaction is more than 24 hours
            //1. check if the amount is within the range of max txn cap
            max_amount_transfer_allowed = account_balance.mul(_MAX_DAILY_TRANSFER_PCENT).div(100);
            require(amount <= max_amount_transfer_allowed, "Amount exceeded allowed range");
                      
            _transfer(sender, recipient, amount);            
            return true;
        } 
  
        //it means user has done one or more transaction within 24hours              
        account_balance =  _USER_TXNS[sender].TxnAmount.add(account_balance);
        max_amount_transfer_allowed = account_balance.mul(_MAX_DAILY_TRANSFER_PCENT).div(100);            
        require(amount <= max_amount_transfer_allowed, "Amount exceeded allowed range for one day");   

        _transfer(sender, recipient, amount);
        return true;
    }

 
    function _transfer(address sender, address recipient, uint256 amount) private { 
         
        _USER_TXNS[sender].TxnTime = block.timestamp;
        _USER_TXNS[sender].TxnAmount = amount;

        //tax_fee and txn_fee 
        uint256 transfer_fee_amount = _TRF_PCENT > 0? amount.mul(_TRF_PCENT).div(100) : 0; 

        uint256 tax_fee_amount = _TAX_PCENT > 0? amount.mul(_TAX_PCENT).div(100) : 0;

        require(transfer_fee_amount.add(tax_fee_amount) <= amount, "Fees cannot exceed Txn. Amount");

        uint256 amount_less_fees = amount.sub(transfer_fee_amount).sub(tax_fee_amount);
        
        _ACCOUNTS_BAL[sender] = _ACCOUNTS_BAL[sender].sub(amount); 

        _ACCOUNTS_BAL[recipient] = _ACCOUNTS_BAL[recipient].add(amount_less_fees);

        _ACCOUNTS_BAL[_ADMIN_ADDR] = _ACCOUNTS_BAL[_ADMIN_ADDR].add(transfer_fee_amount);
        
        emit Transfer(sender, recipient, amount); 
    }

     
}