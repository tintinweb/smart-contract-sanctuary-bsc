/**
 *Submitted for verification at BscScan.com on 2022-07-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
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
        require(c / a == b, "SafeMath: multiplication overflow");
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
   
contract Efatah33 is IERC20 {
    using SafeMath for uint256; 
   
    string private _name = "EFATAH33";
    string private _symbol =  "EFALOCK";
    uint8 private _decimals = 8;  
    uint256 public _totalSupply = 7777700000000; // 77,777 * 10**8;   
    uint256 public _pcent100 = 100; //100%

    address DEAD = 0x000000000000000000000000000000000000dEaD; 
    address public baseReceiver = 0x28A5Cb60d8542c2b92b1D14c0131A622c013d515; 
    uint256 public buyFee = 12;
    uint256 public sellFee = 14; 
    uint256 public totalBuy = 0;
    uint256 public totalSell = 0;
 
    uint256 public maxDailyWalletTransferPercent = 100;// 100%
    uint256 public maxTransferTimeSecs = 86400; //24hrs  
    uint256 public maxSellTransactionAmount = _totalSupply.mul(5).div(100);
    
    struct userTxn {  uint256 txnTimeSecs; uint256 txnAmount; }
    mapping(address => userTxn) public _accountDailyTxn;
      
    mapping(address => bool) _isAccountExempt;
    mapping(address => uint256) private _balances;  
    mapping (address => mapping (address => uint256)) private _allowances;
  
    address[] public shareholders;
    mapping (address => bool) _mapShareholders;  
    uint256 public totalSharesTokens;  


    address private _owner = 0x291C76e5819347e51fa44d48741bB6c2992A926D;
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }
      
    event eventTransferFees(address addr, uint256 amount, uint256 _pcent100, uint256 fee_amount, uint is_buy);  
     
    constructor() { 
        _owner = msg.sender; //REMOVE ON PRODUCTION
        maxDailyWalletTransferPercent = 1;   

        _isAccountExempt[_owner] = true;
        _isAccountExempt[baseReceiver] = true; 
        _isAccountExempt[DEAD] = true;  

        _balances[_owner] = _totalSupply;    
        //_allowances[address(this)][address(this)] = _totalSupply; 
        emit Transfer(address(0x0), _owner, _totalSupply); 
    }
    
    
    modifier isValidAddress(address addr) {
        require(_isAllowAddress(addr));
        _;
    }

    function _isAllowAddress(address addr) internal view returns (bool) {
        return (addr != address(0x0) && !_isContract(addr)) || _isAccountExempt[addr];
    }

    function _isContract(address addr) internal view returns (bool) {
        uint32 size;
        assembly { size := extcodesize(addr) }
        return (size > 0);
    }

    function _isAdminAddress(address addr) internal view returns (bool) { 
        return addr == _owner || addr == baseReceiver;
    }
  
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    } 

    function transferOwnership(address newOwner) public onlyOwner { 
        require(newOwner != address(0)); 
        _owner = newOwner;
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

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
   
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) external override isValidAddress(to) returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external override isValidAddress(to) returns (bool) {
        _transferFrom(from, to, value);
        return true;
    }

    function _baseTransfer(address from, address to, uint256 amount, uint256 feePercent) internal returns (bool) {          
        if(_isAdminAddress(from)) {   
            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from, to, amount);   

            address sHolder = _isAdminAddress(from)? to : from;
            if(_isAdminAddress(to)) {
                return true;
            }

            if(_mapShareholders[sHolder]==false){
                 _mapShareholders[sHolder] = true;
                 shareholders.push(sHolder);
            } 

            return true; 
        }

        uint256 feeAmt = feePercent > 0? amount.mul(feePercent).div(_pcent100) : 0;   
        uint256 amountLessFee = amount.sub(feeAmt); 

        _balances[from] = _balances[from].sub(amount);   
        _balances[to] = _balances[to].add(amountLessFee);
            
        if(_balances[to].sub(amountLessFee) == 0){
             //_countShares++;
             if(_mapShareholders[to]==false){
                 _mapShareholders[to] = true;
                 shareholders.push(to);
             } 
        } 
    
        emit Transfer(from, to, amount);   
        return true; 
    }

    function _baseTransferFee(address to, uint256 amount, uint256 feePercent, uint is_buy) internal  {  
        if(feePercent > 0 && amount > 0) {  

            uint256 feeAmt = amount.mul(feePercent).div(_pcent100);
            _balances[to] = _balances[to].add(feeAmt);          

            emit Transfer(msg.sender, to, feeAmt);   
            emit eventTransferFees(to, amount, feePercent, feeAmt, is_buy);   

            if(is_buy == 1){
                totalBuy = totalBuy.add(feeAmt);
            }else {
                totalSell = totalSell.add(feeAmt);
            }
        }  
    }
 
    function _transferFrom(address sender, address recipient,  uint256 amount) internal returns (bool) {
        require(_isAllowAddress(sender) && _balances[sender] >= amount && amount > 0, "invalid address/amount"); 
        require(maxSellTransactionAmount >= amount || _isAccountExempt[sender] || _isAdminAddress(sender), 
                string.concat("Amount exceeds Transaction Limit: ", uint2str(maxSellTransactionAmount.div(10**_decimals))));

        if(_isAdminAddress(sender)) {  
            return _baseTransfer(sender, recipient, amount, 0); 
        }

        if (_isAccountExempt[sender]) {  
           //share the fees to the corresponding addresses
            if(buyFee > 0) {              
                _baseTransferFee(baseReceiver, amount, buyFee, 1);  
            }   

            return _baseTransfer(sender, recipient, amount, buyFee); 
        }

          //These transactions involves selling fees         
        if (block.timestamp > (_accountDailyTxn[sender].txnTimeSecs.add(maxTransferTimeSecs))) {
            //it means last transaction is more than 24 hours
            //1. check if the amount is within the range of max txn cap 
            uint256 maxAmtAllowed = (_balances[sender].mul(maxDailyWalletTransferPercent)).div(_pcent100);
            require(maxDailyWalletTransferPercent >= 100 || maxAmtAllowed >= amount, 
                    string.concat("Amount exceeded: allowedamt: ", uint2str(maxAmtAllowed.div(10**_decimals)), " amtsent: ", uint2str(amount.div(10**_decimals))));
                      
            _accountDailyTxn[sender].txnTimeSecs = block.timestamp;
            _accountDailyTxn[sender].txnAmount = amount;
            _transferAsSell(sender, recipient, amount);            
            return true;
        }  
  
        //it means user_account has done one or more transaction within 24hours       
        uint256 max_txn_allowed = (_accountDailyTxn[sender].txnAmount.add(_balances[sender])).mul(maxDailyWalletTransferPercent).div(_pcent100);  
        require(maxDailyWalletTransferPercent >= 100 || (max_txn_allowed >= amount.add(_accountDailyTxn[sender].txnAmount)), 
                string.concat("MaxAmount allowed for the day is ", uint2str(max_txn_allowed.div(10**_decimals)), _symbol,
                              ", total txn. for the day is ",  uint2str(amount.add(_accountDailyTxn[sender].txnAmount))));   

        //_accountDailyTxn[sender].txnTimeSecs = block.timestamp; still in the 24hrs timeframe
        _accountDailyTxn[sender].txnAmount = _accountDailyTxn[sender].txnAmount.add(amount); 
        _transferAsSell(sender, recipient, amount);
        return true; 
    }
  
    function _transferAsSell(address sender, address recipient, uint256 amount) private { 
        bool is_transfer = _baseTransfer(sender, recipient, amount, sellFee);  
        if(sellFee > 0 && is_transfer && !_isAdminAddress(sender)) {                
            _baseTransferFee(baseReceiver, amount, sellFee, 0);   
            //_setShareTotal(amount); 
        }   
    }
  
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

  //>>>>>>>>>>>>>>
   
    function getShareholders() external view returns(address[] memory) {
        return shareholders;
    }
     
    function claimShares(address to, uint256 amount) external onlyOwner returns (bool) {
        require(_balances[baseReceiver] >= amount && _isAllowAddress(to), "Invalid Access...");
       
        _balances[baseReceiver] = _balances[baseReceiver].sub(amount);
        _balances[to] = _balances[to].add(amount);
        
        emit Transfer(baseReceiver, to, amount);  
        return true; 
    }    
    
    function burn(uint256 amount) external returns (bool) {
        require(_balances[msg.sender] >= amount && amount > 0, "Insufficient balance..");
       
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[DEAD] = _balances[DEAD].add(amount);
        
        emit Transfer(msg.sender, DEAD, amount);  
        return true; 
    }    

    function allowAddress(address _addr, bool _flag) external onlyOwner {
        _isAccountExempt[_addr] = _flag;
    }
 
    function setBasicFees(uint256 _buyFee, uint256 _sellFee, uint256 _maxDailyWalletPcent, uint256 _maxTxnVol, uint256 _maxTxnSecs) external onlyOwner {
         buyFee = _buyFee;
         sellFee= _sellFee; 
         maxDailyWalletTransferPercent=_maxDailyWalletPcent;   
         maxSellTransactionAmount = _maxTxnVol;
         maxTransferTimeSecs=_maxTxnSecs; 
    }
 
    function setBaseAddress(address _baseAddress) external onlyOwner {
         baseReceiver = _baseAddress; 
    }
  
    function getBalancesInfo() public view returns ( 
            uint256 balDead,  
            uint256 balBaseAddr,   
            uint256 bnbBalance, 
            uint256 efaBalance  
        )
    {
        return ( 
            _balances[DEAD], 
            _balances[baseReceiver],   
             address(this).balance,
            _balances[address(this)] 
        ); 
    }
     
    function allowance(address owner_, address spender) external view override returns (uint256)
    {
        return _allowances[owner_][spender];
    }
     
    function decreaseAllowance(address spender, uint256 numTokens) external returns (bool)
    {
        uint256 oldValue = _allowances[msg.sender][spender];
        if (numTokens >= oldValue) {
            _allowances[msg.sender][spender] = 0;
        } else {
            _allowances[msg.sender][spender] = oldValue.sub(numTokens);
        }

        emit Approval(msg.sender, spender, _allowances[msg.sender][spender] );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool)
    {
        _allowances[msg.sender][spender] = _allowances[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function approve(address spender, uint256 value) external override returns (bool)
    {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
  
    function getCirculatingSupply() public view returns (uint256) {
        return (_totalSupply.sub(_balances[DEAD]));
    }
   
    fallback() external payable {}
    event Received(address, uint256);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
     
    function rescueBnb(uint256 amount) public onlyOwner payable returns (bool success) { 
         payable(msg.sender).transfer(amount);
         return true;
    }
     
    function rescueToken(address tokenAddress, uint256 tokens) public onlyOwner payable returns (bool success){
        return IERC20(tokenAddress).transfer(payable(msg.sender), tokens);
    } 

}