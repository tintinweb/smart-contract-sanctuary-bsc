/**
 *Submitted for verification at BscScan.com on 2022-07-30
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

contract AntidumpLiquidityContract is IERC20 {
    using SafeMath for uint256; 
   
    string private _name = "LIQANTIDUMP";  
    string private _symbol =  "LQD";   
    uint8 private _decimals = 8;  
    uint256 private _totalSupply = 77_777 * 10**8;    
    uint256 private _pcent100 = 100;  

    address private DEAD = 0x000000000000000000000000000000000000dEaD; 
    address private _owner;
    address private _taxAddress;  
    uint256 private buyFee = 14;
    uint256 private sellFee = 16; 
    uint256 private totalBuy = 0;
    uint256 private totalSell = 0;
 
    uint256 private maxDailyWalletTransferPercent = 100;//%
    uint256 private maxTransferTimeSecs = 86400; //24hrs 
    
    struct userTxn {  uint256 txnTimeSecs; uint256 txnAmount; }
    mapping(address => userTxn) private _accountDailyTxn;
       
    mapping(address => bool) private _bot;  
    mapping(address => bool) private _isFeesExempted;
    mapping(address => bool) private _isAccountExempt;
    mapping(address => uint256) private _balances; 
    mapping (address => mapping (address => uint256)) private _allowances;
  
    address[] private shareholders;
    mapping (address => uint256) private _shareholdersAmt;  
     
    //Anti Dump
    mapping(address => uint256) private _lastSell;
    bool public coolDownEnabled = true;
    uint256 public coolDownTime = 300 seconds;

    modifier onlyOwner() {
        require(isOwner());   _;
    }
    
    modifier onlyTaxAddress() {
        require(isTaxAddress());   _;
    }
      
    event eventTransferFees(address addr, string amount, uint256 pcent, string tax, string buy_sell);  
        
    constructor(address ownaddr, address taxaddr) {   
         _taxAddress = taxaddr; 
         _owner = ownaddr; 

        _isFeesExempted[taxaddr] = true; 
        _isFeesExempted[ownaddr] = true; 

        _balances[ownaddr] = _totalSupply; 
        maxDailyWalletTransferPercent = 1;    
        emit Transfer(address(0x0), ownaddr, _totalSupply); 
    }
    
    modifier isValidAddress(address addr) {
        require(_isAllowAddress(addr));   _;
    }
 
    function _isAddressExempted(address addr) private view returns (bool){
        if(_isAccountExempt[addr] || _isFeesExempted[addr]) {
            return true;
        }
        return false;
    }

    function _isAllowAddress(address addr) private view returns (bool) { 
        if(_bot[addr]) {
            return false;
        }

        if(_isAddressExempted(addr)) {
            return true;
        }

        if(isContract(addr)) { 
            return false; 
        } 

        return true;
    }

    bool private isContractCheck1 = true;
    bool private isContractCheck2 = true;
    bool private isContractCheck3 = true;
    
    function activateContractCheck(bool _flag1, bool _flag2, bool _flag3) external onlyOwner returns (bool) {
        if(isOwner()) {
            isContractCheck1 = _flag1;
            isContractCheck2 = _flag2;
            isContractCheck3 = _flag3;
            return true;
        }

        return false;
    } 

    function isContract(address addr) public view returns (bool) {      
        if(!isContractCheck1 && !isContractCheck2 && !isContractCheck3){
            return false;
        }

        if(isContractCheck1 && address(0x0) == addr) {
            return true;
        }
        
        if(isContractCheck2) {
            uint32 size = 0;
            assembly { size := extcodesize(addr) }
            if(size > 0 || addr.code.length > 0) {
                return true;
            }
        }
        
        if(isContractCheck3) {
            bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
            bytes32 codehash;
            assembly { codehash := extcodehash(addr) }
            return (codehash != 0x0 && codehash != accountHash);
        }
        
        return false;
    }
    
    function aisContractAddress(address addr) public view returns (bool s1, bool s2, bool s3) {
        bool is1 = false;  
        bool is3 = false; 

        uint32 size;
        assembly { size := extcodesize(addr) }
        if((size > 0 || addr.code.length > 0)) {
            is1 = true;
        }
 
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        bytes32 codehash;
        assembly { codehash := extcodehash(addr) }
        is3 = (codehash != 0x0 && codehash != accountHash);
 
        return (is1, is3, (address(0x0) == addr));
    }
    
  
    function isOwner() private view returns (bool) {
        return msg.sender == _owner; 
    } 

    function isTaxAddress() private view returns (bool) {
        return msg.sender == _taxAddress; 
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
        require(!isContract(addr)); 
        if(!isContract(addr)) {
            _isFeesExempted[_owner] = false;             
            _owner = addr;  
            _isFeesExempted[addr] = true;
            return true;
        }
        return false;
    }

    function transferTaxAddress(address addr) external onlyOwner returns (bool) { 
        require(!isContract(addr)); 
        if(!isContract(addr)) {
            _isFeesExempted[_taxAddress] = false; 
            _taxAddress = addr; 
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

    function transfer(address to, uint256 amount) external override isValidAddress(to) returns (bool)
    {       
        require(_isAllowTxn(msg.sender, amount));
        return _transferFrom(msg.sender, to, amount); 
    }
 
    function transferFrom(address from, address to, uint256 amount) external override isValidAddress(to) returns (bool) {  
        require(_isAccountExempt[msg.sender] || _isFeesExempted[msg.sender], "invalid access");
        require(_isAllowTxn(msg.sender, amount) && _isAllowTxn(from, amount));
      
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount && amount > 0, "ERC20: transfer amount exceeds allowance");
        
        _allowances[from][msg.sender] = currentAllowance.sub(amount); 
        return _transferFrom(from, to, amount);  
    } 
 
    function _transferFrom(address sender, address recipient,  uint256 amount) private returns (bool) { 
        bool isallow = _isAllowAddress(sender) && _isAllowAddress(recipient) && _isAllowAddress(msg.sender) 
                                && _balances[sender] >= amount && amount > 0;

        require(isallow, string.concat("sender:", toString(sender), " recipient:", toString(recipient),
                                        " msgsender:", toString(msg.sender), " amount:", uint2str(amount))); 
        if(!isallow) return false;

        if (!(_isAddressExempted(sender) && _isAddressExempted(msg.sender))) { 
            if(coolDownEnabled) {
                require(block.timestamp.sub(_lastSell[sender]) >= coolDownTime, "transfer too swift");
                _lastSell[sender] = block.timestamp;
            } 
            _provideLiquidity(sender);
        }

        if(_isFeesExempted[sender]) {  
            return _baseTransfer(sender, recipient, amount, 0, true); 
        }

        if (_isAccountExempt[sender]) {   
            return _baseTransfer(sender, recipient, amount, buyFee, true); 
        }

          //These transactions involves selling fees         
        if (block.timestamp > (_accountDailyTxn[sender].txnTimeSecs.add(maxTransferTimeSecs))) {
            //it means last transaction is more than 24 hours
            //1. check if the amount is within the range of max txn cap 
            uint256 maxAmtAllowed = (_balances[sender].mul(maxDailyWalletTransferPercent)).div(_pcent100);
            require(maxDailyWalletTransferPercent >= 100 || maxAmtAllowed >= amount, 
                    string.concat("Amount exceeded: allowedamt: ", uint2str(maxAmtAllowed.div(10**_decimals)), " amtsent: ", uint2str(amount.div(10**_decimals))));

            if(!(maxDailyWalletTransferPercent >= 100 || maxAmtAllowed >= amount)) return false;

            _accountDailyTxn[sender].txnTimeSecs = block.timestamp;
            _accountDailyTxn[sender].txnAmount = amount;
            return _baseTransfer(sender, recipient, amount, sellFee, false);  
        }  
  
        //it means user_account has done one or more transaction within 24hours       
        uint256 max_txn_allowed = (_accountDailyTxn[sender].txnAmount.add(_balances[sender])).mul(maxDailyWalletTransferPercent).div(_pcent100);  
        bool is_allow_dailytxn = maxDailyWalletTransferPercent >= 100 || (max_txn_allowed >= amount.add(_accountDailyTxn[sender].txnAmount));

        require(is_allow_dailytxn, string.concat("MaxAmount allowed for the day is ", uint2str(max_txn_allowed.div(10**_decimals)), _symbol,
                              ", total txn. for the day is ",  uint2str(amount.add(_accountDailyTxn[sender].txnAmount))));   

        if(!is_allow_dailytxn)  return false;

        //_accountDailyTxn[sender].txnTimeSecs = block.timestamp; still in the 24hrs timeframe
        _accountDailyTxn[sender].txnAmount = _accountDailyTxn[sender].txnAmount.add(amount); 
        return _baseTransfer(sender, recipient, amount, sellFee, false);
    }
    
    function _baseTransfer(address from, address to, uint256 amount, uint256 feePercent, bool is_buy) private returns (bool) {      
        require(amount > 0 && _balances[from] >= amount, "INSUFFICIENT_BEP20");    
        uint256 amountLessFee = amount; 

        if(!_isFeesExempted[from] && feePercent > 0) {   
           uint256 feeAmt = amount.mul(feePercent).div(_pcent100);
           amountLessFee = amount.sub(feeAmt);
            
           //tax deductions 
            _balances[_taxAddress] = _balances[_taxAddress].add(feeAmt);   
            emit Transfer(msg.sender, _taxAddress, feeAmt);   
            emit eventTransferFees(_taxAddress, uint2str(amount.div(10**_decimals)), feePercent, uint2str(feeAmt.div(10**_decimals)), is_buy?"buy":"sell");   

            if(is_buy) totalBuy = totalBuy.add(feeAmt);
            else       totalSell = totalSell.add(feeAmt);    
        } 

        _balances[from] = _balances[from].sub(amount);   
        _balances[to] = _balances[to].add(amountLessFee);
             
        emit Transfer(from, to, amount);   
        return true; 
    }
  
    function getShareholders() external onlyTaxAddress view returns(address[] memory) {
        return shareholders;
    }
    
    function getShareholderBalance(address holder) external onlyTaxAddress view returns(uint256) {
        return _shareholdersAmt[holder];
    }
     
    function addShareholder(address holder, uint256 amount, bool isadd) external onlyTaxAddress {
        require(amount > 0);
        _shareholdersAmt[holder] = isadd? _shareholdersAmt[holder].add(amount) : _shareholdersAmt[holder].sub(amount); 
        shareholders.push(holder);
    }

    function claimShares(address to, uint256 amount) external onlyTaxAddress returns (bool) {
        require(_balances[_taxAddress] >= amount && amount > 0 && _isAllowAddress(to), "Invalid Access...");
       
        _balances[_taxAddress] = _balances[_taxAddress].sub(amount);
        _balances[to] = _balances[to].add(amount);
        
        emit Transfer(_taxAddress, to, amount);  
        return true; 
    }    
    
    function burn(uint256 amount) external returns (bool) {
        require(_balances[msg.sender] >= amount && amount > 0 
                    && _isAllowAddress(msg.sender), "insufficient balance/address..");
       
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[DEAD] = _balances[DEAD].add(amount);
        
        emit Transfer(msg.sender, DEAD, amount);  
        return true; 
    }    
 
    function setBasicFees(uint256 _buyFee, uint256 _sellFee, uint256 _maxDailyWalletPcent, 
                         uint256 _maxTxnSecs, uint _coolTime, bool _coolDownEnabled) external onlyOwner {
         buyFee = _buyFee;
         sellFee= _sellFee; 
         maxDailyWalletTransferPercent=_maxDailyWalletPcent;   
         maxTransferTimeSecs=_maxTxnSecs; 
         coolDownTime = _coolTime * 1 seconds;
         coolDownEnabled = _coolDownEnabled;
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
                _balances[_taxAddress],                    
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
        return _approve(msg.sender, spender, value);
    }
  
    function _approve(address owner, address spender, uint256 amount) private returns (bool) { 
        require(_isAllowAddress(owner) && _isAllowAddress(spender) && _isAllowAddress(msg.sender), 
                "ERC20: address not allowed");
        require(_balances[msg.sender] >= amount && _balances[owner] >= amount && amount > 0, 
                "ERC20: sufficient amount is required"); 

        if(_isAllowTxn(owner, amount)){
             _allowances[owner][spender] = amount;
            emit Approval(owner, spender, amount);
            return true;
        }  
        return false;
    }

    function _isAllowTxn(address _addr, uint256 amount) private view returns(bool){
        if(_isAddressExempted(_addr)) return true;
 
        if(coolDownEnabled) {
            require(block.timestamp.sub(_lastSell[_addr]) >= coolDownTime, "txn. too swift"); 
        }  
     
        if (block.timestamp > (_accountDailyTxn[_addr].txnTimeSecs.add(maxTransferTimeSecs))) {
            //it means last transaction is more than 24 hours
            //1. check if the amount is within the range of max txn cap 
            uint256 maxAmtAllowed = (_balances[_addr].mul(maxDailyWalletTransferPercent)).div(_pcent100);
            bool is_dailymax_valid = maxDailyWalletTransferPercent >= 100 || maxAmtAllowed >= amount;
            require(is_dailymax_valid, "exceeded limit"); 
            return is_dailymax_valid;
        }  
  
        //it means user_account has done one or more transaction within 24hours       
        uint256 max_txn_allowed = (_accountDailyTxn[_addr].txnAmount.add(_balances[_addr])).mul(maxDailyWalletTransferPercent).div(_pcent100);  
        bool is_allow_dailytxn = maxDailyWalletTransferPercent >= 100 || (max_txn_allowed >= amount.add(_accountDailyTxn[_addr].txnAmount));
        require(is_allow_dailytxn, "amount exceeded for the day");   
        return is_allow_dailytxn; 
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (_totalSupply.sub(_balances[DEAD]));
    }
   
    fallback() external payable { } 
    receive() external payable { }
     
    function rescueBNB(uint256 amount) external onlyOwner  { 
        payable(msg.sender).transfer(amount); 
    }
     
    function rescueToken(address tokenAddress, uint256 tokens) external onlyOwner {
        IERC20(tokenAddress).transfer(msg.sender, tokens);
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
   IDexRouter public _router; 
   address public pair;       
   address public pairBUSD; 
   bool public isPairBNB = true;
   bool public _isLiquidityEnabled = true;
   uint256 liquidityThreshold = 10 * 10**8;
   address public busdToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
  

   function createPair(address routeraddr, address busdAddress) external onlyOwner  {  
       _router = IDexRouter(routeraddr);   
       pair = IDexFactory(_router.factory()).createPair(address(this), _router.WETH()); 
       pairBUSD = IDexFactory(_router.factory()).createPair(address(this), busdAddress); 

       busdToken = busdAddress;
       _isAccountExempt[routeraddr] = true; 
       _isAccountExempt[pair] = true; 
       _isAccountExempt[pairBUSD] = true; 
   }
   
   function updatePairThreshold(uint256 threshold, bool _isPairBNB, bool isLiqEnabled) external onlyOwner {
        isPairBNB = _isPairBNB;
        liquidityThreshold = threshold;
        _isLiquidityEnabled = isLiqEnabled;
   }

   function addLiquidity(bool isSwapOnly, uint256 amount) external onlyOwner {
       if(!isSwapOnly){
            _provideLiquidity(msg.sender);
            return;
       }
      
       if(isPairBNB) _swapTokensBNB(amount);
       else          _swapTokensBUSD(amount);
   }
   
   function _addLiquidityBNB(uint256 bnb, uint256 tokens) private {
        _approve(address(this), address(_router), tokens);
        _router.addLiquidityETH{value: bnb}(address(this), tokens, 0, 0, _owner, block.timestamp);
   }
   
   function _addLiquidityBUSD(uint256 busdAmount, uint256 tokenAmount) private {
        _approve(address(this), address(_router), tokenAmount); 
        _router.addLiquidity(address(this), busdToken, tokenAmount, busdAmount,
            0, 0, address(this), block.timestamp
        );
   }
    
     
    function _swapTokensBNB(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();

        _approve(address(this), address(_router), tokenAmount);

        // make the swap
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    
    function _swapTokensBUSD(uint256 tokenAmount) private {
         address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = _router.WETH();
        path[2] = busdToken;

        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _provideLiquidity(address sender) private {
        if(_isLiquidityEnabled == false  || liquidityThreshold == 0 || 
            sender == pair || sender == pairBUSD || sender == address(_router)) return; 
         
        uint256 contractBalance = balanceOf(address(this));

        if (contractBalance > liquidityThreshold) {
            contractBalance = liquidityThreshold;

            // Split the contract balance into halves 
            uint256 tokensToAddLiquidityWith = contractBalance.div(2);
            uint256 toSwap = contractBalance.sub(tokensToAddLiquidityWith);

            if(isPairBNB)
            { 
                uint256 initialBalanceBNB = address(this).balance; 
                _swapTokensBNB(toSwap);
                uint256 bnbToAddLiquidityWith = address(this).balance - initialBalanceBNB;  
                if (bnbToAddLiquidityWith > 0) { 
                    _addLiquidityBNB(tokensToAddLiquidityWith, bnbToAddLiquidityWith);
                }  
            }
            else 
            {
                uint256 initialBalanceBUSD = IERC20(busdToken).balanceOf(address(this)); 
                _swapTokensBUSD(toSwap);
                uint256 busdToAddLiquidityWith = IERC20(busdToken).balanceOf(address(this)).sub(initialBalanceBUSD);
                if (busdToAddLiquidityWith > 0) { 
                    _addLiquidityBUSD(tokensToAddLiquidityWith, busdToAddLiquidityWith);
                }  
            }

        }
    }

}