/**
 *Submitted for verification at BscScan.com on 2022-08-01
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
   
contract AutoLiquidContract is IERC20 {
    using SafeMath for uint256;  
   
    mapping(address => uint256) private _balances; 
    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name = "DUMPAUTOPAY";  
    string private _symbol =  "DAP";   
    uint8 private _decimals = 8;  
    uint256 private _totalSupply = 77_777 * 10**8;    

    address private _owner;  
    uint256 private totalBuyTaxAmount = 0;
    uint256 private totalSellTaxAmount = 0; 
    uint256 private _pcent100 = 100;  
  
    address public marketingWallet = 0xF786C82BE5517bE68ecc49F1f14C99C87f3a601E;
    address public liquidityWallet = 0x49B20f870D8A8D0cc375aBFf1875F2A2e73dEA21;
    address public teamWallet = 0xF786C82BE5517bE68ecc49F1f14C99C87f3a601E;
    address public devWallet = 0xF786C82BE5517bE68ecc49F1f14C99C87f3a601E;
    address public projectWallet = 0xF786C82BE5517bE68ecc49F1f14C99C87f3a601E;
    address public epifWallet = 0xF786C82BE5517bE68ecc49F1f14C99C87f3a601E;
    address public deadWallet = 0x000000000000000000000000000000000000dEaD; 

    struct Tax {
        uint256 marketing;
        uint256 liquidity;
        uint256 team;
        uint256 dev;
        uint256 project;
        uint256 epif; 
    }
    Tax public buyTaxes = Tax(3, 6, 1, 2, 1, 1);
    Tax public sellTaxes = Tax(4, 6, 1, 2, 2, 1);
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

    event eventTransferFees(string amount, uint256 pcent, string taxAmount, string buyOrSell);  
        
    constructor(address ownaddr) {    
         _owner = ownaddr;   
        _xACCOUNT[ownaddr] = 2; 

        _balances[ownaddr] = _totalSupply;  
        emit Transfer(address(0x0), ownaddr, _totalSupply); 
    }
     
    bool private _swapMutex = false;
    modifier swapMutexLock() {
       /*if (!_swapMutex) {
            _swapMutex = true;
            _;
            _swapMutex = false;
        }*/
        require(!_swapMutex, "No Re-entrancy");
         _swapMutex = true;
        _;
        _swapMutex = false;
    }
        
    bool private _txnMutex = false;
    modifier txnMutexLock() {
        require(!_txnMutex, "No Re-entrancy");
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
    
    //0-all, 1-exempt, 2-exempt-fees, 9-bot, _xACCOUNT

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

    //----------------------------- 
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
        return (_totalSupply.sub(_balances[deadWallet]));
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
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        bool success = _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        require(success, "Approval reverted.");
        return success;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        bool success = _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        require(success, "Approval reverted.");
        return success;
    }

    function transfer(address to, uint256 amount) public override isValidAddress(to) returns (bool)
    {       
        require(_isAllowTxn(_msgSender(), amount), "Transfer not allowed");
        bool success = _transfer(_msgSender(), to, amount); 
        require(success, "Transfer reversed");
        return success;
    }
 
    function transferFrom(address from, address to, uint256 numTokens) external override txnMutexLock returns (bool) {  
        require(_isAllowTxn(from, numTokens) &&  _isAllowAddress(to), "Transfer not allowed");
        require(_allowances[from][_msgSender()] >= numTokens && numTokens > 0, "INVALID_ALLOWANCE_AMOUNT");
      
        bool success2 = _approve(from, _msgSender(), _allowances[from][_msgSender()].sub(numTokens, "BEP20: transfer amount exceeds allowance"));
        require(success2, "transaction reverted");

        bool success = _transfer(from, to, numTokens);  
        require(success, "Transfer failed");

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
        if (!(_isAddressExempted(sender) && _isAddressExempted(_msgSender()))) { 
            if(coolDownEnabled) {
                require(block.timestamp.sub(_LastTxnTime[sender]) >= coolDownTime, "transfer too swift");
                _LastTxnTime[sender] = block.timestamp;
                _LastTxnTime[_msgSender()] = block.timestamp;
            } 

            _provideLiquidity(sender);
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
            return _baseTransfer(sender, recipient, amount, 1, false);  
        }  
  
        //it means user_account has done one or more transaction within 24hours       
        uint256 max_txn_allowed = (_accountDailyTxn[sender].txnAmount.add(_balances[sender])).mul(maxDailyWalletTransferPercent).div(_pcent100);  
        bool is_allow_dailytxn = maxDailyWalletTransferPercent >= 100 || (max_txn_allowed >= amount.add(_accountDailyTxn[sender].txnAmount));

        require(is_allow_dailytxn, string.concat("MaxAmount allowed for the day is ", uint2str(max_txn_allowed.div(10**_decimals)), _symbol,
                              ", total txn. for the day is ",  uint2str(amount.add(_accountDailyTxn[sender].txnAmount))));   
        if(!is_allow_dailytxn)  return false;

        //_accountDailyTxn[sender].txnTimeSecs = block.timestamp; still in the 24hrs timeframe
        _accountDailyTxn[sender].txnAmount = _accountDailyTxn[sender].txnAmount.add(amount); 
        return _baseTransfer(sender, recipient, amount, 1, false);
    }
    
    function _baseTransfer(address from, address to, uint256 amount, 
        uint isHasFees, bool is_buy) private returns (bool) {      

        require(amount > 0 && _balances[from] >= amount, "INSUFFICIENT_BEP20");    
        uint256 amountLessFee = amount; 

        if(!_isFeesExempted(from) && isHasFees > 0) {   
           uint256 taxsPcent = is_buy ? totalBuyTax : totalSellTax; 

           uint256 taxAmount = amount.mul(taxsPcent).div(_pcent100);
           amountLessFee = amount.sub(taxAmount);
            
            if(is_buy) totalBuyTaxAmount = totalBuyTaxAmount.add(taxAmount);
            else       totalSellTaxAmount = totalSellTaxAmount.add(taxAmount);
 
            _deductTax(amount, is_buy);  
        } 

        _balances[from] = _balances[from].sub(amount);   
        _balances[to] = _balances[to].add(amountLessFee);
                
        _LastTxnTime[from] = block.timestamp;
        emit Transfer(from, to, amount); 
        return true; 
    }
   
   function _deductTax(uint256 amount, bool isBuy) private {
    
        Tax memory taxs = isBuy ? buyTaxes : sellTaxes;
        uint256 taxsPcent = isBuy ? totalBuyTax : totalSellTax;
        uint256 taxSumAmount = amount.mul(taxsPcent).div(_pcent100);
        //tax deductions  
        //spit the funds to the various addresses
        uint256 marketingAMT = taxs.marketing>0? amount.mul(taxs.marketing).div(_pcent100) : 0;
        if (marketingAMT > 0)  isRemitTax(marketingWallet, marketingAMT);

        uint256 liquidAMT = taxs.liquidity>0? amount.mul(taxs.liquidity).div(_pcent100) : 0;
        if (liquidAMT > 0)  isRemitTax(liquidityWallet, liquidAMT);

        uint256 teamAMT = taxs.team>0? amount.mul(taxs.team).div(_pcent100) : 0;
        if (teamAMT > 0)  isRemitTax(teamWallet, teamAMT);

        uint256 devAMT = taxs.dev>0? amount.mul(taxs.dev).div(_pcent100) : 0;
        if (devAMT > 0)  isRemitTax(devWallet, devAMT);

        uint256 projectAMT = taxs.project>0? amount.mul(taxs.project).div(_pcent100) : 0;
        if (projectAMT > 0)  isRemitTax(projectWallet, projectAMT);

        uint256 epifAMT = taxs.epif>0? amount.mul(taxs.epif).div(_pcent100) : 0;
        if (epifAMT > 0)  isRemitTax(epifWallet, epifAMT); 

        emit eventTransferFees(uint2str(amount.div(10**_decimals)), 
                                taxsPcent, uint2str(taxSumAmount.div(10**_decimals)), 
                                isBuy?"buy":"sell");   
   }

    function _approve(address tokenOwner, address spender, uint256 amount) private returns (bool) { 
        require(tokenOwner != address(0) && spender != address(0), "BEP20: approve to the zero address");
        require(_isAllowAddress(tokenOwner) && _isAllowAddress(spender) && _isAllowAddress(_msgSender()),  "BEP20: address not allowed");
        require(_isAllowTxn(tokenOwner, amount), "UNAUTHORIZED_AMOUNT");

        _allowances[tokenOwner][spender] = amount;
        _LastTxnTime[tokenOwner] = block.timestamp.sub((coolDownTime.div(2))); //half the time for approval
        emit Approval(tokenOwner, spender, amount);
        return true;
    }

    function _isAllowTxn(address _addr, uint256 amount) private view returns(bool){
        if(_isAddressExempted(_addr) && _balances[_addr] >= amount) return true;
 
        if(coolDownEnabled) {
            require(block.timestamp.sub(_LastTxnTime[_addr]) >= coolDownTime, "txn. too swift"); 
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
   
    function setxAccount(address addr, uint level) external onlyOwner {
        _xACCOUNT[addr] = level;       
    }

    /* 0-all, 1-exempt, 2-exempt-fees, 9-bot, _xACCOUNT */    
    function transferOwnership(address addr) external onlyOwner  { 
        require(!_isAddressContract(addr), "INVALID_OWNER_ADDRESS"); 
        _xACCOUNT[_owner] = 0;             
        _owner = addr;  
        _xACCOUNT[addr] = 2;
    }
   
    function transferBulk(address[] memory addrs, uint256[] memory amts) external onlyOwner returns(bool) {
         for(uint i=0; i<addrs.length; i++) {
            _transfer(_msgSender(), addrs[i], amts[i]);  
         }
         return true;
    }    
 
    function getShareholders() external onlyOwner view returns(address[] memory) {
        return shareholders;
    }
     
    function getShareholderBalance(address holder) external onlyOwner view returns(uint256) {
        return _shareholdersAmt[holder];
    }

    function addShareholder(address holder, uint256 amount, bool isadd) external onlyOwner {
        require(amount > 0);
        _shareholdersAmt[holder] = isadd? _shareholdersAmt[holder].add(amount) : _shareholdersAmt[holder].sub(amount); 
        shareholders.push(holder);
    }

    function claimShares(address to, uint256 amount) external onlyOwner {
        require(amount > 0 && _isAllowAddress(to), "Invalid Access...");
        require(_balances[epifWallet] >= amount);
        _balances[to] = _balances[to].add(amount);
        _balances[epifWallet] = _balances[epifWallet].sub(amount);
        emit Transfer(epifWallet, to, amount);   
    }    
    
    function burn(uint256 amount) external returns (bool) {
        require(_balances[_msgSender()] >= amount && amount > 0 
                    && _isAllowAddress(_msgSender()), "insufficient balance/address..");
       
        _balances[_msgSender()] = _balances[_msgSender()].sub(amount);
        _balances[deadWallet] = _balances[deadWallet].add(amount);
        
        emit Transfer(msg.sender, deadWallet, amount);  
        return true; 
    }    
 
    function setBasicFees(uint256 _buyFee, uint256 _sellFee, uint256 _maxDailyWalletPcent, 
                         uint256 _maxTxnSecs, uint _coolTime, bool _coolDownEnabled) external onlyOwner {
         totalBuyTax = _buyFee;
         totalSellTax= _sellFee; 
         maxDailyWalletTransferPercent=_maxDailyWalletPcent;   
         maxTransferTimeSecs=_maxTxnSecs; 
         coolDownTime = _coolTime * 1 seconds;
         coolDownEnabled = _coolDownEnabled;
    }
  
    function setWalletAddresses(address market, address liquid, address team, 
                             address dev, address project, address epif) external onlyOwner {
        marketingWallet = market;
        liquidityWallet = liquid;
        teamWallet = team;
        devWallet = dev;
        projectWallet = project;
        epifWallet = epif;
    }
    
    function setTaxFees(uint256 market, uint256 liquid, uint256 team, 
                             uint256 dev, uint256 project, uint256 epif, bool isBuy) external onlyOwner {
        uint256 totalFee = market + liquid + team + dev + project + epif;
        if(isBuy) {
            totalBuyTax = totalFee;
            buyTaxes = Tax(market, liquid, team, dev, project, epif);
        }
        else { 
            totalSellTax = totalFee;
            sellTaxes = Tax(market, liquid, team, dev, project, epif);
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
  
    // function _sendBNB(address recipient, uint256 bnb) private {
    //     require(address(this).balance >= bnb, "Address: insufficient balance");
    //     (bool success, ) = payable(recipient).call{ value: bnb }("");
    //     require(success, "Address: unable to send value, recipient may have reverted");
    // }

    function isRemitTax(address _txAddress, uint256 amount) private {
        require(amount > 0);

        _balances[_txAddress] = _balances[_txAddress].add(amount);
        if(swapThreshold == 0 || _balances[_txAddress] < swapThreshold) return;

        //if it meets the threshold, you can swap for BNB/BUSD 
        if(liquidityWallet != _txAddress) {
            _Swap(amount, _txAddress); 
            return;
        }
        
        //its liquiidty 
        //move the balance of liquidity to contract, to provide liquidity 
        _balances[address(this)] = _balances[address(this)].add(_balances[_txAddress]);
        _balances[_txAddress] = 0; 
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
   
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   IDexRouter public _router; 
   address public pair;       
   address public pairBUSD; 
   bool public isPairBNB = true;
   bool public _isLiquidityEnabled = true;
   uint256 public liquidityThreshold = 10 * 10**8;
   uint256 public swapThreshold = 0;
   address public busdToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
  
   function createPair(address routeraddr, address busdAddress) external onlyOwner  {  
       _router = IDexRouter(routeraddr);   
       pair = IDexFactory(_router.factory()).createPair(address(this), _router.WETH()); 
       pairBUSD = IDexFactory(_router.factory()).createPair(address(this), busdAddress); 

       busdToken = busdAddress;
       
    //0-all, 1-exempt, 2-exempt-fees, 9-bot, _xACCOUNT
       _xACCOUNT[routeraddr] = 1; 
       //_xACCOUNT[pair] = 1; 
       //_xACCOUNT[pairBUSD] = 1; 
   }
   
   function updatePairThreshold(uint256 threshold, uint256 swapThold, bool _isPairBNB, bool isLiqEnabled) external onlyOwner {
        isPairBNB = _isPairBNB;
        liquidityThreshold = threshold;
        swapThreshold = swapThold;
        _isLiquidityEnabled = isLiqEnabled;
   }

   function addLiquidity(bool isSwapOnly, uint256 amount) external onlyOwner {
       if(!isSwapOnly){
            _provideLiquidity(msg.sender);
            return;
       }
      
      _Swap(amount, address(this));
   }
   
   function _addLiquidityBNB(uint256 bnb, uint256 tokens) private {
        _approve(address(this), address(_router), tokens);
        _router.addLiquidityETH{value: bnb}(address(this), tokens, 0, 0, liquidityWallet, block.timestamp);
   }
   
   function _addLiquidityBUSD(uint256 busdAmount, uint256 tokenAmount) private {
        _approve(address(this), address(_router), tokenAmount); 
        _router.addLiquidity(address(this), busdToken, tokenAmount, busdAmount,
            0, 0, liquidityWallet, block.timestamp
        );
   }
    
    function _Swap(uint256 amount, address _txAddress) private {
        if(isPairBNB) { 
            _swapTokensBNB(amount, _txAddress);
        }
        else {  
            _swapTokensBUSD(amount, _txAddress); 
        }
    }
     
    function _swapTokensBNB(uint256 tokenAmount, address tokenOwner) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();

        _approve(tokenOwner, address(_router), tokenAmount);

        // make the swap
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            tokenOwner,
            block.timestamp
        );
    }
    
    function _swapTokensBUSD(uint256 tokenAmount, address tokenOwner) private {
         address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = _router.WETH();
        path[2] = busdToken;

        _approve(tokenOwner, address(_router), tokenAmount);
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            tokenOwner,
            block.timestamp
        );
    }

    function _provideLiquidity(address sender) private {
        if(_isLiquidityEnabled == false  || liquidityThreshold == 0 || 
            sender == pair || sender == pairBUSD || sender == address(_router)) return; 
         
        //check the tokenbalance of liquidity balance 
        uint256 liquidityTokenBalance = _balances[liquidityWallet];
        if(liquidityTokenBalance < liquidityThreshold) return;

        _balances[liquidityWallet] = 0;
        _balances[address(this)] = _balances[address(this)].add(liquidityTokenBalance);
        uint256 contractTokenBalance = _balances[address(this)]; //balanceOf(address(this));
 
        // Split the contract balance into halves 
        uint256 tokensToAddLiquidityWith = contractTokenBalance.div(2);
        uint256 tokensToSwap = contractTokenBalance.sub(tokensToAddLiquidityWith);

        if(isPairBNB)
        { 
            uint256 initialBalanceBNB = address(this).balance; 
            _swapTokensBNB(tokensToSwap, address(this));
            uint256 bnbToAddLiquidityWith = address(this).balance.sub(initialBalanceBNB);  
            if (bnbToAddLiquidityWith > 0) { 
                _addLiquidityBNB(tokensToAddLiquidityWith, bnbToAddLiquidityWith);
            }  
        }
        else 
        {
            uint256 initialBalanceBUSD = IERC20(busdToken).balanceOf(address(this)); 
            _swapTokensBUSD(tokensToSwap, address(this));
            uint256 busdToAddLiquidityWith = IERC20(busdToken).balanceOf(address(this)).sub(initialBalanceBUSD);
            if (busdToAddLiquidityWith > 0) { 
                _addLiquidityBUSD(tokensToAddLiquidityWith, busdToAddLiquidityWith);
            }  
        }       
    }

}