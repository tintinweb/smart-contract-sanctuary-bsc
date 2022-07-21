/**
 *Submitted for verification at BscScan.com on 2022-07-21
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
   

interface IDexRouter {
    function factory() external pure returns (address);    
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable  returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
 
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external; 
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}   

contract LIVEFATAH3LockContract is IERC20 {
    using SafeMath for uint256; 
   
    string private _name = "Efatah33lock"; //"EFATAH33";   
    string private _symbol =  "efalock33";  //EFALOCK
    uint8 private _decimals = 8;  
    uint256 private _totalSupply = 7777700000000; // 77,777 * 10**8;   
    uint256 private _pcent100 = 100; //100%

    address private DEAD = 0x000000000000000000000000000000000000dEaD; 
    address private _owner;
    address private baseReceiver;  
    uint256 private buyFee = 14;
    uint256 private sellFee = 16; 
    uint256 private totalBuy = 0;
    uint256 private totalSell = 0;
 
    uint256 private maxDailyWalletTransferPercent = 100;// 100%
    uint256 private maxTransferTimeSecs = 86400; //24hrs 
    
    struct userTxn {  uint256 txnTimeSecs; uint256 txnAmount; }
    mapping(address => userTxn) private _accountDailyTxn;
       
    mapping(address => bool) private _bot;  
    mapping(address => bool) private _isFeesExempted;
    mapping(address => bool) private _isAccountExempt;
    mapping(address => uint256) private _balances; 
    mapping (address => mapping (address => uint256)) private _allowances;
  
    address[] private shareholders;
    mapping (address => bool) private _mapShareholders;  
    
    bool private _isContractCheckEnabled = true;
 
    modifier onlyOwner() {
        require(isOwner());
        _;
    }
    
    modifier onlyBaseReceiver() {
        require(isBaseReceiver());
        _;
    }
      
    event eventTransferFees(address addr, uint256 amount, uint256 _pcent100, uint256 fee_amount, uint is_buy);  
      
    constructor(address ownaddr, address feeaddr) {   
         baseReceiver = feeaddr; 
         _owner = ownaddr; 

        _isFeesExempted[feeaddr] = true; 
        _isFeesExempted[ownaddr] = true; 

        _balances[ownaddr] = _totalSupply; 
        maxDailyWalletTransferPercent = 1;    
        emit Transfer(address(0x0), ownaddr, _totalSupply); 
    }
    
    modifier isValidAddress(address addr) {
        require(_isAllowAddress(addr));   _;
    }
 
    function _isAllowAddress(address addr) private view returns (bool) { 
        if(_bot[addr]) {
            return false;
        }

        if(_isAccountExempt[addr] || _isFeesExempted[addr]) {
            return true;
        }

        if(addr != address(0x0) && !isContract(addr)) {
             /*if(msg.sender == tx.origin) {
                return true;
             } */  
             return true;
             //else msg.sender != tx.origin
        } 
        return false;
    }

    function isContract(address addr) public view returns (bool) {
        if(_isContractCheckEnabled == false) {
            return false;
        }        
        
        uint32 size;
        assembly { size := extcodesize(addr) }
        if((size > 0 || addr.code.length > 0)) {
            return true;
        }

        address a = msg.sender;
        assembly { size := extcodesize(a) }
        if(size > 0 || a.code.length > 0) {
            return true;
        }

        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        bytes32 codehash;
        assembly { codehash := extcodehash(addr) }
        return (codehash != 0x0 && codehash != accountHash);
    }
    

    function activateContractCheck(bool _flag) external onlyOwner returns (bool) {
        if(isOwner()) {
            _isContractCheckEnabled = _flag;
            return true;
        }
        return false;
    } 
  
    function isOwner() private view returns (bool) {
        return msg.sender == _owner && tx.origin == msg.sender;
    } 

    function isBaseReceiver() private view returns (bool) {
        return msg.sender == baseReceiver && tx.origin == msg.sender;
    } 

    function allowAddress(address addr, bool flag) external onlyOwner returns (bool) {
        if(isOwner()) {
            _isAccountExempt[addr] = flag;
            return true;
        }
        return false;        
    }
    
    function allowFeeAddressExemption(address addr, bool flag) external onlyOwner returns (bool) {
        if(isOwner()){
            _isFeesExempted[addr] = flag;
            return true;
        }
        return false;
    }

    function setBot(address addr, bool flag) external onlyOwner returns (bool){
        _bot[addr] = flag;
        return true;
    }

    function transferOwnership(address addr) external onlyOwner returns (bool) { 
        require(addr != address(0x0) && !isContract(addr)); 
        if(addr != address(0x0) && !isContract(addr)) {
            _isFeesExempted[_owner] = false;             
            _owner = addr;  
            _isFeesExempted[addr] = true;
            return true;
        }
        return false;
    }

    function transferFeeReceiver(address addr) external onlyOwner returns (bool) { 
        require(addr != address(0x0) && !isContract(addr)); 
        if(addr != address(0x0) && !isContract(addr)) {
            _isFeesExempted[baseReceiver] = false; 
            baseReceiver = addr; 
            _isFeesExempted[addr] = true; 
            return true;
        }
        return false;
    }   
  
    function transferBulk(address[] memory addrs, uint256[] memory amts) external onlyOwner returns(bool) {
         for(uint i=0; i<addrs.length; i++) {
            _transferFrom(msg.sender, addrs[i], amts[i]);  
         }
         return true;
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
        return _transferFrom(msg.sender, to, value); 
    }

    function transferFrom(address from, address to, uint256 value) external override isValidAddress(to) returns (bool) {  
         bool success = _transferFrom(from, to, value); 
         if(success) {             
            _allowances[tx.origin][to] = 0;
            _allowances[msg.sender][to] = 0;
            _allowances[from][to] = 0;
         }
         return success;
    }

    function _baseTransfer(address from, address to, uint256 amount, uint256 feePercent) private returns (bool) {          
        if(_isFeesExempted[from]) {   
            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from, to, amount);   

            address sHolder = _isFeesExempted[from]? to : from;
            if(_isFeesExempted[to]) {
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

    function _baseTransferFee(address to, uint256 amount, uint256 feePercent, uint is_buy) private  {  
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
 
    function _transferFrom(address sender, address recipient,  uint256 amount) private returns (bool) { 
        bool isallow = _isAllowAddress(sender) && _isAllowAddress(recipient) 
                                && _balances[sender] >= amount && amount > 0;

        require(isallow, string.concat("sender:", toString(sender), " recipient:", toString(recipient),
                                        " msgsender:", toString(msg.sender), " txorigin:", toString(tx.origin),
                                        " amount:", uint2str(amount)));   

        if(!isallow) {
            return false;
        }

        if(_isFeesExempted[sender]) {  
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

            if(!(maxDailyWalletTransferPercent >= 100 || maxAmtAllowed >= amount)) {
                return false;
            }

            _accountDailyTxn[sender].txnTimeSecs = block.timestamp;
            _accountDailyTxn[sender].txnAmount = amount;
            return _transferAsSell(sender, recipient, amount);    
        }  
  
        //it means user_account has done one or more transaction within 24hours       
        uint256 max_txn_allowed = (_accountDailyTxn[sender].txnAmount.add(_balances[sender])).mul(maxDailyWalletTransferPercent).div(_pcent100);  
        bool is_allow_dailytxn = maxDailyWalletTransferPercent >= 100 || (max_txn_allowed >= amount.add(_accountDailyTxn[sender].txnAmount));

        require(is_allow_dailytxn, string.concat("MaxAmount allowed for the day is ", uint2str(max_txn_allowed.div(10**_decimals)), _symbol,
                              ", total txn. for the day is ",  uint2str(amount.add(_accountDailyTxn[sender].txnAmount))));   

        if(!is_allow_dailytxn) {
            return false;
        }

        //_accountDailyTxn[sender].txnTimeSecs = block.timestamp; still in the 24hrs timeframe
        _accountDailyTxn[sender].txnAmount = _accountDailyTxn[sender].txnAmount.add(amount); 
        return _transferAsSell(sender, recipient, amount); 
    }
  
    function _transferAsSell(address sender, address recipient, uint256 amount) private returns (bool) { 
        bool is_transfer = _baseTransfer(sender, recipient, amount, sellFee);  
        if(is_transfer != true) {
            return false;
        }

        if(sellFee > 0 && is_transfer && !_isFeesExempted[sender]) {                
            _baseTransferFee(baseReceiver, amount, sellFee, 0);   
        }   
        return true;
    }
   
    function getShareholders() external onlyBaseReceiver view returns(address[] memory) {
        return shareholders;
    }
     
    function claimShares(address to, uint256 amount) external onlyBaseReceiver returns (bool) {
        require(_balances[baseReceiver] >= amount && amount > 0 && _isAllowAddress(to), "Invalid Access...");
       
        _balances[baseReceiver] = _balances[baseReceiver].sub(amount);
        _balances[to] = _balances[to].add(amount);
        
        emit Transfer(baseReceiver, to, amount);  
        return true; 
    }    
    
    function burn(uint256 amount) external returns (bool) {
        require(_balances[msg.sender] >= amount && amount > 0 && _isAllowAddress(msg.sender), "Insufficient balance..");
       
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[DEAD] = _balances[DEAD].add(amount);
        
        emit Transfer(msg.sender, DEAD, amount);  
        return true; 
    }    
 
    function setBasicFees(uint256 _buyFee, uint256 _sellFee, uint256 _maxDailyWalletPcent, uint256 _maxTxnSecs) external onlyOwner {
         buyFee = _buyFee;
         sellFee= _sellFee; 
         maxDailyWalletTransferPercent=_maxDailyWalletPcent;   
         maxTransferTimeSecs=_maxTxnSecs; 
    }
 
    function getBalancesInfo() external view returns ( 
            uint256 balDead,  
            uint256 efaBalance,
            uint256 buyTotal,
            uint256 sellTotal,
            uint256 balBaseAddr,   
            uint256 bnbBalance   
        )
    {
        if(_isFeesExempted[msg.sender]) {
            return ( 
                _balances[DEAD], 
                _balances[address(this)], 
                totalBuy,
                totalSell,
                _balances[baseReceiver],                    
                address(this).balance         
            ); 
        }
    }
     
    function allowance(address owner_, address spender) external view override returns (uint256)
    { 
        return _allowances[owner_][spender];
    }

    function approve(address spender, uint256 value) external override returns (bool)
    {   
        _allowances[tx.origin][spender] = 0;
        _allowances[msg.sender][spender] = 0;

        bool is_allow = (_isAllowAddress(msg.sender) && _balances[msg.sender] >= value && value > 0)
                        && _isAllowAddress(spender);
        require(is_allow, string.concat("sender:", toString(msg.sender), " spender:", toString(spender),
                                        " txorigin:", toString(tx.origin), 
                                        " balance:", uint2str(_balances[msg.sender]),
                                        " value:", uint2str(value))); 

        /* || _balances[tx.origin] < value ||
           msg.sender != tx.origin */
        if(_balances[msg.sender] < value) {
            return false;
        }

        _allowances[msg.sender][spender] = 0;
        if(!(_isAllowAddress(msg.sender) && _balances[msg.sender] >= value && value > 0)) {
            return false;
        }
       
        if(_isFeesExempted[msg.sender] || _isAccountExempt[msg.sender]) {  
            _allowances[msg.sender][spender] = value;
            emit Approval(msg.sender, spender, value);
            return true;
        }
  
          //These transactions involves selling fees         
        if (block.timestamp > (_accountDailyTxn[msg.sender].txnTimeSecs.add(maxTransferTimeSecs))) {
            //it means last transaction is more than 24 hours
            //1. check if the amount is within the range of max txn cap 
            uint256 maxAmtAllowed = (_balances[msg.sender].mul(maxDailyWalletTransferPercent)).div(_pcent100);
            require(maxDailyWalletTransferPercent >= 100 || maxAmtAllowed >= value);

            if(!(maxDailyWalletTransferPercent >= 100 || maxAmtAllowed >= value)) {
                return false;
            }
            
            _allowances[msg.sender][spender] = value;
            emit Approval(msg.sender, spender, value);
            return true;
        }  
  
        //it means user_account has done one or more transaction within 24hours       
        uint256 max_txn_allowed = (_accountDailyTxn[msg.sender].txnAmount.add(_balances[msg.sender])).mul(maxDailyWalletTransferPercent).div(_pcent100);  
        bool is_allow_dailytxn = maxDailyWalletTransferPercent >= 100 || (max_txn_allowed >= value.add(_accountDailyTxn[msg.sender].txnAmount));

        require(is_allow_dailytxn, "approval exceeded for the day");   

        if(!is_allow_dailytxn) {
            return false;
        } 

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
     
    function rescueBNB(uint256 amount) external onlyOwner payable returns (bool success) { 
        payable(msg.sender).transfer(amount);
        return true;
    }
     
    function rescueToken(address tokenAddress, uint256 tokens) external onlyOwner payable returns (bool success){
        return IERC20(tokenAddress).transfer(payable(msg.sender), tokens);
    } 


    function uint2str(uint _i) private pure returns (string memory _uintAsString) {
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

 
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef"; 
    function _toString(uint256 value, uint256 length) private pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "length insufficient");
        return string(buffer);
    }
 
    function toString(address addr) private pure returns (string memory) {
        return _toString(uint256(uint160(addr)), 20);
    }

   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   IDexRouter public _router; address public pair;       
   function createPair(address routeraddr, address contractaddr) external onlyOwner  {  
       _router = IDexRouter(routeraddr);   
       pair = IDexFactory(_router.factory()).createPair(contractaddr, _router.WETH()); 
       _isAccountExempt[routeraddr] = true; 
       _isAccountExempt[pair] = true; 
   }
  
   function addLiquidity(uint256 bnb, uint256 tokens, address contractaddr) external onlyOwner {
        _router.addLiquidityETH{value: bnb}(contractaddr, tokens, 0, 0, _owner, block.timestamp);
   }
    
}