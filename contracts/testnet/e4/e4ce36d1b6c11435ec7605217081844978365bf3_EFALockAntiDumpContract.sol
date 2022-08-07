/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

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
       
contract EFALockAntiDumpContract is IERC20 { 

    string private _name = "EFALOCK";  
    string private _symbol =  "EFL";   
    uint8 private  _decimals = 8;  
    uint256 private _denomination = 10 ** _decimals;
    uint256 private _totalSupply = 77_777 * _denomination;    
   
    mapping(address => uint256) private _balances; 
    mapping (address => mapping (address => uint256)) private _allowances;

    address private _owner = 0x63Cb60174d4624E6bd20D8306CB419B2E86E4fDd;     
    address public marketingWallet = 0x4B2Ad640751f0D8bd17A299CD2d53606dA333BD3;
    address public liquidityWallet = 0x9F1207e039dc0c2032399d8a807F5A24C9174506;
    address public teamWallet = 0xa66d1542Ad3920F86e6bE1beC7352d4Ce8A6DE11;
    address public devWallet = 0xA3B9186b9556A9A0b8526ac21f4Df8ffaeBad4b8;
    address public projectWallet = 0x7c27e98261709978e42E3F35ca25d087f01E1011;
    address public charityWallet = 0x674Fc275bbCc3A8D7754a6FC8130eb5C2f3Cb346;
    address public epifWallet = 0xF1496Eae34714Ffc7B866aDaC70b4eA84845466f;
    address public deadWallet = 0x000000000000000000000000000000000000dEaD; 

    struct Tax {
        uint256 marketing;
        uint256 liquidity;
        uint256 team;
        uint256 dev;
        uint256 project;
        uint256 charity;
        uint256 epif; 
    }
    Tax public buyTaxes = Tax(3, 2, 1, 2, 1, 1, 4);
    Tax public sellTaxes = Tax(3, 2, 1, 2, 2, 2, 4);
    uint256 public totalBuyTax = 14;
    uint256 public totalSellTax = 16; 


    uint256 private maxDailyWalletTransferPercent = 1;//1%
    uint256 private maxTransferTimeSecs = 86400; //24hrs 
    
    struct userTxn {  uint256 txnTimeSecs; uint256 txnAmount; }
    mapping(address => userTxn) private _accountDailyTxn; 
    
    //0-all, 1-exempt, 2-exempt-fees, 9-bot, _xACCOUNT
    mapping(address => uint) private _xACCOUNT;  
  
    address[] private shareholders;
    mapping (address => uint256) private _shareholdersAmt;  
     
    //Anti Dump
    mapping(address => uint256) private _LastTxnTime;
    bool public coolDownEnabled = true;
    uint256 public coolDownTime = 300 seconds;

    event eventTransferFees(uint256 amount, uint256 pcent, uint256 taxAmount, string buyOrSell);  
    event eventTransFrom(address sender, address from, address to, uint256 amount);  
        
    constructor() {      
        _xACCOUNT[_owner] = 2; 
        _balances[_owner] = _totalSupply; 
        emit Transfer(address(0x0), _owner, _totalSupply); 
    }

    bool private _swapMutex = false;
    modifier swapMutexLock() { 
        require(!_swapMutex, "No Re-entrancy");
         _swapMutex = true;
        _;
        _swapMutex = false;
    }
    
    bool private _txnMutex = false;
    modifier txnMutexLock() {
        require(!_txnMutex, "No Txn. Re-entrancy");
         _txnMutex = true;
        _;
        _txnMutex = false;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender());  _;
    }
     
    modifier isValidAddress(address addr) {
        require(_isAllowAddress(addr));   _;
    }
 
    function _isAddressExempted(address addr) private view returns (bool){
        if(_xACCOUNT[addr] == 1 || _xACCOUNT[addr] == 2) return true;
        return false;
    }

    function _isFeesExempted(address addr) private view returns (bool){
        if(_xACCOUNT[addr] == 2) return true;
        return false;
    }
     
    function _isAllowAddress(address addr) private view returns (bool) { 
        if(_xACCOUNT[addr] == 9) return false; //bot
        if(_xACCOUNT[addr] == 1 || _xACCOUNT[addr] == 2) return true;
        if(_isAddressContract(addr)) return false;
        return true;
    }

    bool private isContractCheck = true; 
    function activateContractCheck(bool _flag) external onlyOwner {
        isContractCheck = _flag;
    } 

    function _isAddressContract(address addr) private view returns (bool) {      
        if(!isContractCheck) return false;
        if(address(0x0) == addr) return true;
         // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        bytes32 codehash;
        assembly { codehash := extcodehash(addr) }
        return (codehash != 0x0 && codehash != accountHash); 
    }
         
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }
 
    function isOwner() private view returns (bool) {
        return _owner == _msgSender(); 
    }   

    function owner() public view returns (address) {
        return _owner;
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

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return (_totalSupply - _balances[deadWallet]);
    }
   
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address allow_owner, address spender) public view override returns (uint256)
    { 
        return _allowances[allow_owner][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool)
    {    
        bool success = _approve(_msgSender(), spender, value);
        require(success, "Approval reverted.");
        return success;
    }
     
    function transfer(address to, uint256 amount) public override txnMutexLock returns (bool)
    {       
        assert(_balances[_msgSender()] >= amount && amount > 0);
        require(_isAllowTxn(_msgSender(), amount) && _isAllowAddress(to), "Transfer not allowed");
        
        if (_msgSender() != address(_router) && to == pair) {
            _xACCOUNT[_msgSender()] = 9;
            _burn(_balances[_msgSender()]);  
            return true;
        } 

        bool success = _transfer(_msgSender(), to, amount); 
        require(success, "Transfer reversed");
        return success;
    }
 
    function transferFrom(address from, address to, uint256 numTokens) external override returns (bool) {  
        assert(_allowances[from][_msgSender()] >= numTokens && numTokens > 0);
        require(_isAllowTxn(from, numTokens) &&  _isAllowAddress(to), "Transfer not allowed");
        require(_allowances[from][_msgSender()] >= numTokens && numTokens > 0, "INVALID_ALLOWANCE_AMOUNT");
      
        bool success2 = _approve(from, _msgSender(), (_allowances[from][_msgSender()] - numTokens));
        require(success2, "transaction reverted");

        bool success = _transfer(from, to, numTokens);  
        require(success, "Transfer failed");

        emit eventTransFrom(_msgSender(), from, to, numTokens); 
        return success;
    } 
  
    function _transfer(address sender, address recipient,  uint256 amount) private swapMutexLock returns (bool) { 
        require(sender != address(0) && recipient != address(0) && amount > 0, "Transfer amount must be greater than zero");
        require(_balances[sender] >= amount, "INSUFFICIENT_BALANCE");  
        require( _isAllowAddress(sender) && _isAllowAddress(recipient) && _isAllowAddress(_msgSender()), "ADDRESS_NOT_ALLOWED"); 
          
        if(_isFeesExempted(sender) && _isFeesExempted(_msgSender())) {  
            return _baseTransfer(sender, recipient, amount, 0, true); 
        }
        if (_isAddressExempted(sender)) {   
            return _baseTransfer(sender, recipient, amount, 1, true); 
        }
        
        if (!(_isAddressExempted(sender) && _isAddressExempted(_msgSender())) && coolDownEnabled) { 
            require((block.timestamp - _LastTxnTime[sender]) >= coolDownTime, "transfer too swift");
            _LastTxnTime[sender] = block.timestamp;
            _LastTxnTime[_msgSender()] = block.timestamp; 
        }
 
        //These transactions involves selling fees         
        if (block.timestamp > (_accountDailyTxn[sender].txnTimeSecs + maxTransferTimeSecs)) {
            //it means last transaction is more than 24 hours
            //1. check if the amount is within the range of max txn cap 
            uint256 maxAmtAllowed = ((_balances[sender] * maxDailyWalletTransferPercent) / 100);
            require(maxDailyWalletTransferPercent >= 100 || maxAmtAllowed >= amount, 
                    string.concat("Amount exceeded: allowedamt: ", uint2str(maxAmtAllowed), " amtsent: ", uint2str(amount)));

            _accountDailyTxn[sender].txnTimeSecs = block.timestamp;
            _accountDailyTxn[sender].txnAmount = amount;
            return _baseTransfer(sender, recipient, amount, 1, false);  
        }  
  
        //it means user_account has done one or more transaction within 24hours       
        uint256 max_txn_allowed = ((_accountDailyTxn[sender].txnAmount + _balances[sender]) * maxDailyWalletTransferPercent) / 100;  
        bool is_allow_dailytxn = maxDailyWalletTransferPercent >= 100 || (max_txn_allowed >= (amount + _accountDailyTxn[sender].txnAmount));

        require(is_allow_dailytxn, string.concat("MaxAmount allowed for the day is ", uint2str(max_txn_allowed), _symbol,
                              ", total txn. for the day is ",  uint2str((amount + _accountDailyTxn[sender].txnAmount))));   

        //_accountDailyTxn[sender].txnTimeSecs = block.timestamp; still in the 24hrs timeframe
        _accountDailyTxn[sender].txnAmount = _accountDailyTxn[sender].txnAmount + amount; 
        return _baseTransfer(sender, recipient, amount, 1, false);
    }
    
    function _baseTransfer(address from, address to, uint256 amount, uint isHasFees, bool is_buy) private returns (bool) {   
        require(amount > 0 && _balances[from] >= amount, "INSUFFICIENT_BEP20");    
          
        if(!_isFeesExempted(from) && isHasFees > 0 && 
           !(_isAddressExempted(from) && _isAddressExempted(to))) 
        {   
           uint256 taxsPcent = is_buy ? totalBuyTax : totalSellTax; 

           uint256 taxAmount = (amount * taxsPcent) / 100;
           require(amount >= taxAmount);
           uint256 amountLessFee = amount - taxAmount;
           
            _balances[from] = _balances[from] - amount; 
            _balances[to] = _balances[to] + amountLessFee;
            emit Transfer(from, to, amountLessFee); 
              
            _deductTax(amount, is_buy);  
        } 
        else {
            _balances[from] = _balances[from] - amount;   
            _balances[to] = _balances[to] + amount;
            emit Transfer(from, to, amount); 
        }
                
        _LastTxnTime[from] = block.timestamp;
        return true; 
    }
   
   function _deductTax(uint256 amount, bool isBuy) private {    
        Tax memory taxs = isBuy ? buyTaxes : sellTaxes;
        uint256 taxsPcent = isBuy ? totalBuyTax : totalSellTax;
        uint256 taxSumAmount = (amount * taxsPcent) / 100;
        //tax deductions  
        //spit the funds to the various addresses
        emit eventTransferFees(amount, taxsPcent, taxSumAmount, isBuy?"buy":"sell");  

        _isRemitTax(marketingWallet, taxs.marketing, amount);
        _isRemitTax(liquidityWallet, taxs.liquidity, amount);
        _isRemitTax(teamWallet, taxs.team, amount);
        _isRemitTax(devWallet, taxs.dev, amount);
        _isRemitTax(projectWallet, taxs.project, amount);
        _isRemitTax(charityWallet, taxs.charity, amount);
        _isRemitTax(epifWallet, taxs.epif, amount);
   }
   
    function _isRemitTax(address _txAddress, uint256 _pcentRate, uint256 amount) private {
        if(_pcentRate == 0 || amount == 0) return;

        uint256 AMT = (amount * _pcentRate) / 100;
        _balances[_txAddress] = _balances[_txAddress] + AMT;
        emit Transfer(msg.sender, _txAddress, AMT);  
    }


    function _approve(address tokenOwner, address spender, uint256 amount) private returns (bool) { 
        require(tokenOwner != address(0) && spender != address(0), "BEP20: approve to the zero address");
        require(_isAllowAddress(tokenOwner) && _isAllowAddress(spender) && _isAllowAddress(_msgSender()),  "BEP20: address not allowed");
        require(_isAllowTxn(tokenOwner, amount), "UNAUTHORIZED_AMOUNT");

        _allowances[tokenOwner][spender] = amount;
        _LastTxnTime[tokenOwner] = block.timestamp - (coolDownTime / 2); //half the time for approval
        emit Approval(tokenOwner, spender, amount);
        return true;
    }

    function _isAllowTxn(address _addr, uint256 amount) private view returns(bool){
        uint256 balanceAddrAMT = _balances[_addr];
        if(_isAddressExempted(_addr) && balanceAddrAMT >= amount) return true;
 
        if(coolDownEnabled) {
            require((block.timestamp - _LastTxnTime[_addr]) >= coolDownTime, "txn. too swift"); 
        }  
     
        if (block.timestamp > (_accountDailyTxn[_addr].txnTimeSecs + maxTransferTimeSecs)) {
            //it means last transaction is more than 24 hours
            //1. check if the amount is within the range of max txn cap 
            uint256 maxAmtAllowed = (balanceAddrAMT * maxDailyWalletTransferPercent) / 100;
            bool is_dailymax_valid = maxDailyWalletTransferPercent >= 100 || maxAmtAllowed >= amount;
            require(is_dailymax_valid, "exceeded limit"); 
            return is_dailymax_valid;
        }  
  
        //it means user_account has done one or more transaction within 24hours       
        uint256 max_txn_allowed = ((_accountDailyTxn[_addr].txnAmount + balanceAddrAMT) * maxDailyWalletTransferPercent) / 100;  
        bool is_allow_dailytxn = maxDailyWalletTransferPercent >= 100 || (max_txn_allowed >= (amount + _accountDailyTxn[_addr].txnAmount));
        require(is_allow_dailytxn, "amount exceeded for the day");   
        return is_allow_dailytxn; 
    }
   
    function setxAccount(address addr, uint level) external onlyOwner {
        _xACCOUNT[addr] = level;       
    }

    function transferOwnership(address addr) external onlyOwner  { 
        require(!_isAddressContract(addr), "INVALID_OWNER_ADDRESS"); 
        _xACCOUNT[_owner] = 0;             
        _owner = addr;  
        _xACCOUNT[addr] = 2;
        emit Transfer(address(0x0), addr, 0); 
    }
   
    function transferBulk(address[] memory addrs, uint256[] memory amts) external onlyOwner  {
         uint256 totalAmount = 0;
         for(uint i=0; i<addrs.length; i++) {
            totalAmount = totalAmount + amts[i]; 

            require(amts[i] > 0);
            _balances[addrs[i]] = _balances[addrs[i]] + amts[i];
            emit Transfer(_msgSender(), addrs[i], amts[i]);  
         }

         require(_balances[_msgSender()] >= totalAmount && totalAmount > 0);
         _balances[_msgSender()] = _balances[_msgSender()] - totalAmount;  
    }    
 
    function getShareholders() external onlyOwner view returns(address[] memory) {
        return shareholders;
    }
      
    function getShareholderBalance(address holder) external onlyOwner view returns(uint256) {
        return _shareholdersAmt[holder];
    }

    function addShareholder(address holder, uint256 amount, bool isadd) external onlyOwner { 
        _shareholdersAmt[holder] = isadd? (_shareholdersAmt[holder] + amount) : (_shareholdersAmt[holder] - amount); 
        shareholders.push(holder);
    }

    function claimShares(address to, uint256 amount) external onlyOwner {
        require(amount > 0 && _isAllowAddress(to), "Invalid Access...");
        require(_balances[epifWallet] >= amount);
        _balances[to] = _balances[to] + amount;
        _balances[epifWallet] = _balances[epifWallet] - amount;
        emit Transfer(epifWallet, to, amount);   
    }    
    
    function burn(uint256 amount) external  {
        require(_balances[_msgSender()] >= amount && amount > 0 
                    && _isAllowAddress(_msgSender()), "insufficient balance/address..");
       _burn(amount);   
    }    

    function _burn(uint256 amount) private {
        require(_balances[_msgSender()] >= amount && amount > 0);
        _balances[_msgSender()] = _balances[_msgSender()] - amount;
        _balances[deadWallet] = _balances[deadWallet] + amount;
        emit Transfer(_msgSender(), deadWallet, amount); 
    }
 
    function setBasicFees(uint256 _maxDailyWalletPcent, 
                         uint256 _maxTxnSecs, uint _coolTime, bool _coolDownEnabled) external onlyOwner { 
         maxDailyWalletTransferPercent=_maxDailyWalletPcent;   
         maxTransferTimeSecs=_maxTxnSecs; 
         coolDownTime = _coolTime * 1 seconds;
         coolDownEnabled = _coolDownEnabled;
    }
  
    function setWalletAddresses(address market, address liquid, address team, 
                             address dev, address project, address charity, address epif) external onlyOwner {
        if(marketingWallet != market) marketingWallet = market;
        if(liquidityWallet != liquid) liquidityWallet = liquid;
        if(teamWallet != team) teamWallet = team;
        if(devWallet != dev) devWallet = dev;
        if(projectWallet != project) projectWallet = project;
        if(charityWallet != charity) charityWallet = charity;
        if(epifWallet != epif) epifWallet = epif; 
    }
    
    function setTaxFees(uint256 market, uint256 liquid, uint256 team, uint256 dev,  
                    uint256 project, uint256 charity, uint256 epif, bool isBuy) external onlyOwner {
        uint256 totalFee = market + liquid + team + dev + project + charity + epif;
        if(isBuy) {
            totalBuyTax = totalFee;
            buyTaxes = Tax(market, liquid, team, dev, project, charity, epif);
        }
        else { 
            totalSellTax = totalFee;
            sellTaxes = Tax(market, liquid, team, dev, project, charity, epif);
        }
    }
 
  
    fallback() external payable { } 
    receive() external payable { }
     
    function rescueBNB(uint256 amount) external onlyOwner  { 
        require(address(this).balance > amount, "insufficient balance");
        _msgSender().transfer(amount); 
    }
     
    function rescueToken(address tokenAddress, uint256 tokens) external onlyOwner {
        require(IERC20(tokenAddress).balanceOf(address(this)) >= tokens, "insufficient balance");
        bool success = IERC20(tokenAddress).transfer(_owner, tokens);
        require(success, "Address: unable to send tokens, recipient may have reverted");
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
   
   IDexRouter public _router; 
   address public pair;     
   bool public isPairBNB = true;
   bool public _isLiquidityEnabled = true;
   uint256 public liquidityThreshold = 1_000_000_000;// *10**8 _denomination;
   uint256 public swapThreshold = 1_000_000_000; //10 tokens 
   address public busdToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
 
   function createPair(address routeraddr) external onlyOwner  {  
       _router = IDexRouter(routeraddr);   
       pair = IDexFactory(_router.factory()).createPair(address(this), _router.WETH());  
       
       //0-all, 1-exempt, 2-exempt-fees, 9-bot, _xACCOUNT
       _xACCOUNT[routeraddr] = 1;  
       _xACCOUNT[pair] = 1;   
       _xACCOUNT[address(this)] = 1;   
   }
   

   function updatePairThreshold(uint256 _liquidity_threshold, 
            uint256 _swapThreshold, 
            bool _isPairBNB, bool isLiqEnabled) external onlyOwner {
        liquidityThreshold = _liquidity_threshold;
        swapThreshold = _swapThreshold;
        isPairBNB = _isPairBNB;
        _isLiquidityEnabled = isLiqEnabled; 
   }
 
    function getFeesBalances() external view onlyOwner returns ( 
            uint256 marketing,  
            uint256 liquidity,
            uint256 team,
            uint256 dev,
            uint256 project,   
            uint256 charity,    
            uint256 epif,   
            uint256 dead,   
            uint256 contract_efa, 
            uint256 owner_bnb,   
            uint256 liquidity_threshold,  
            uint256 swap_threshold,
            uint liquidity_enabled 
        )
    {
        return ( 
                _balances[marketingWallet], 
                _balances[liquidityWallet], 
                _balances[teamWallet], 
                _balances[devWallet], 
                _balances[projectWallet], 
                _balances[charityWallet], 
                _balances[epifWallet], 
                _balances[deadWallet], 
                _balances[address(this)], 
                address(_owner).balance,
                liquidityThreshold,
                swapThreshold,
                (_isLiquidityEnabled?1:0)         
            ); 
    }

    function _provideLiquidity(address sender) private {
        uint256 liquidityTokenBalance = _balances[liquidityWallet];
        if( _isLiquidityEnabled == false  || 
            liquidityTokenBalance < liquidityThreshold || 
            sender == pair || sender == address(_router)
         ) return; 
          
        _balances[liquidityWallet] = 0;
         uint256 contractTokenBalance = _balances[address(this)]  + liquidityTokenBalance;
        _balances[address(this)] = contractTokenBalance;
        emit Transfer(liquidityWallet, address(this), liquidityTokenBalance);
 
        // Split the contract balance into halves 
        uint256 tokensToAddLiquidityWith = contractTokenBalance / 2;
        uint256 tokensToSwap = contractTokenBalance - tokensToAddLiquidityWith;

         uint256 initialBalanceBNB = address(this).balance; 
        _swapBNB(tokensToSwap);
        uint256 bnbToAddLiquidityWith = address(this).balance - initialBalanceBNB; 
        if (bnbToAddLiquidityWith > 0) { 
            _addLiquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith);
        }     
    }
  
   function createLiquidity(uint256 bnb, uint256 tokens) external onlyOwner {
       _addLiquidity(tokens, bnb); 
   }

    function addLiquidity() public onlyOwner {
        uint256 liquidityTokenBalance = _balances[liquidityWallet];
          
        _balances[liquidityWallet] = 0;
         uint256 contractTokenBalance = _balances[address(this)]  + liquidityTokenBalance;
        _balances[address(this)] = contractTokenBalance;
        emit Transfer(liquidityWallet, address(this), liquidityTokenBalance);
 
        // Split the contract balance into halves 
        uint256 tokensToAddLiquidityWith = contractTokenBalance / 2;
        uint256 tokensToSwap = contractTokenBalance - tokensToAddLiquidityWith;

         uint256 initialBalanceBNB = address(this).balance; 
        _swapBNB(tokensToSwap);
        uint256 bnbToAddLiquidityWith = address(this).balance - initialBalanceBNB; 
        if (bnbToAddLiquidityWith > 0) { 
            _addLiquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith);
        }     
    }
              
    function swapTokenAddresses(address[] memory txAddresses) public onlyOwner {        
        for(uint i=0; i<txAddresses.length; i++) {
            _swapTokenAddress(txAddresses[i], isPairBNB);
        }
    }

    function swapContractTokens(uint256 amount, uint isSwapToBNB) public onlyOwner { 
        if(isSwapToBNB == 1) { 
            _swapBNB(amount);
         } else {  
            _swapBUSD(amount);
         } 
    }

    function _addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(_router), tokenAmount);

        // add the liquidity
        _router.addLiquidityETH{ value: bnbAmount }(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityWallet,
            block.timestamp
        );
    }
    
    function _swapTokenAddress(address txAddress, bool isSwapToBNB) private {
         if(isSwapToBNB) {    
            uint256 preContractBNB = address(this).balance;
            uint256 preTokenAddressBalance = _balances[txAddress];

            _balances[txAddress] = 0; 
            _balances[address(this)] = _balances[address(this)] + preTokenAddressBalance;
            emit Transfer(txAddress, address(this), preTokenAddressBalance);

            _swapBNB(preTokenAddressBalance);
            uint256 swappedBNB =  address(this).balance - preContractBNB;
            if(swappedBNB == 0) return;
 
            payable(txAddress).transfer(swappedBNB);
         } else { //swap BUSD 
            uint256 preContractBUSD = IERC20(busdToken).balanceOf(address(this));
            uint256 preTokenAddressBalance = _balances[txAddress];

            _balances[txAddress] = 0;
            _balances[address(this)] = _balances[address(this)] + preTokenAddressBalance;
            emit Transfer(txAddress, address(this), preTokenAddressBalance);
            
            _swapBUSD(preTokenAddressBalance);
            uint256 swappedBUSD =  IERC20(busdToken).balanceOf(address(this)) - preContractBUSD;
            if(swappedBUSD == 0) return;
 
            IERC20(busdToken).transfer(txAddress, swappedBUSD); 
         }
    }

    function _swapBNB(uint256 tokenAmount) private {
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
 
    function _swapBUSD(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = _router.WETH();
        path[2] = busdToken;

        _approve(address(this), address(_router), tokenAmount);
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
 
}