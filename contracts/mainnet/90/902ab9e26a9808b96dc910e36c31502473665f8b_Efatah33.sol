/**
 *Submitted for verification at BscScan.com on 2022-07-10
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
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

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, 
        address to, uint deadline) external returns (uint[] memory amounts);

    function swapExactTokensForTokens(uint amountIn, uint amountOutMin,
            address[] calldata path,  address to,  uint deadline) external returns (uint[] memory amounts);

}

interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakeSwapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function sync() external;
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}
  

contract Efatah33 is IERC20 {
    using SafeMath for uint256; 
   
    string private _name = "EFATAH33";
    string private _symbol =  "EFALOCK";
    uint8 private _decimals = 8;  
    uint256 public _totalSupply = 7777700000000; // 77,777 * 10**8;   
    uint256 public _pcent100 = 100; //100%

    address DEAD = 0x000000000000000000000000000000000000dEaD; 
    address public marketingReceiver = 0x167395322efA5A9938BA84aC1aA092dE86b7087e; 
    address public liquidityReceiver = 0x7B797C2a37d70C36c2925708961052F0cE59bC08;
    address public projectReceiver = 0x2355205C9aE00672fF3243C91c44dA128324Df80; 
    address public epifReceiver = 0xD4Cd573eC16D21e3790f23D3ed399ED4b6057F84; 
    address public devReceiver = 0x73d4a3972f305F2F8b498aD29bd433eBcadd0CC2; 
    address public teamReceiver = 0x1bc4DDB70Ea30e90F633822fE569d0A4B24B64F5;  
     
    uint256 public liquidityFee = 1;
    uint256 public devFee = 2;
    uint256 public teamFee = 1;
    uint256 public epifFee = 6;

    uint256 public buyMarketingFee = 3; 
    uint256 public buyProjectFee = 1;  
    uint256 public buyTotalFee =
        buyMarketingFee.add(liquidityFee).add(buyProjectFee).add(devFee).add(teamFee).add(epifFee);

    uint256 public sellMarketingFee = 4; 
    uint256 public sellProjectFee = 2;  
    uint256 public sellTotalFee =
        sellMarketingFee.add(liquidityFee).add(sellProjectFee).add(devFee).add(teamFee).add(epifFee);
 
    uint256 public maxDailyWalletTransferPercent = 100;// 100%
    uint256 public maxTransferTimeSecs = 86400; //24hrs  
    uint256 public maxSellTransactionAmount = _totalSupply;
    
    struct userTxn {  uint256 txnTimeSecs; uint256 txnAmount; }
    mapping(address => userTxn) public _accountDailyTxn;
      
    mapping(address => bool) _isAccountExempt;
    mapping(address => uint256) private _balances; 
    mapping(address => bool) public _blacklistBot; 
    mapping (address => mapping (address => uint256)) private _allowances;

  
    address[] public shareholders;
    mapping (address => bool) _mapShareholders;  
    uint256 public totalSharesTokens;  

    modifier validRecipient(address to) {
        require(to != address(0x0)); _;
    }

    address private _owner;
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }
      
    event eventTransferFees(address addr, uint256 amount, uint256 _pcent100, uint256 fee_amount, uint is_buy);  
     
    constructor(address ownerWallet) {
        _owner = ownerWallet;  
        maxDailyWalletTransferPercent = 1;  
        _swapThresholdAmt = 2;
        //>>>>>>>>>>>
         
        _isAccountExempt[_owner] = true;
        _isAccountExempt[address(this)] = true; 
        _isAccountExempt[DEAD] = true; 
        _isAccountExempt[marketingReceiver] = true; 
        _isAccountExempt[liquidityReceiver] = true; 
        _isAccountExempt[projectReceiver] = true; 
        _isAccountExempt[epifReceiver] = true; 
        _isAccountExempt[devReceiver] = true; 
        _isAccountExempt[teamReceiver] = true; 
 
        _balances[_owner] = _totalSupply;  
        emit Transfer(address(0x0), _owner, _totalSupply);

        //>>>>>>>>>>>>>>>  
        _isLiquidityEnabled = true;   
         _router = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); /* PancakeSwap: Router v2: 0x10ED43C718714eb63d5aA57B78B54704E256024E */
        
        pair = IDexFactory(_router.factory()).createPair(address(this), _router.WETH()); 
        _changeBusdPair(busdToken);
        
        _allowances[address(this)][address(_router)] = _totalSupply;
        _allowances[address(this)][address(this)] = _totalSupply;
        _allowances[address(this)][pair] = _totalSupply;
  
        _isAccountExempt[address(_router)] = true; 
        _isAccountExempt[pair] = true;
        //>>>>>>>>>>>>>>>>>>>>>
  
    }
    
    function _isAdminAddress(address addr) internal view returns (bool) { 
        return addr == _owner || addr == marketingReceiver || addr == liquidityReceiver || addr == projectReceiver || 
               addr == epifReceiver || addr == devReceiver || addr == teamReceiver;
    }

    function setBusdPair(address usdAddress) public onlyOwner returns (bool) {
        _changeBusdPair(usdAddress);
        return true;
    }

    function _changeBusdPair(address tokenAddr) private {
        busdToken = tokenAddr; 
        pairBusd = IDexFactory(_router.factory()).createPair(address(this), busdToken);

        _allowances[address(this)][pairBusd] = _totalSupply;  
        _isAccountExempt[busdToken] = true;
        _isAccountExempt[pairBusd] = true;
        
        IERC20(busdToken).approve(address(_router), _totalSupply);
        IERC20(busdToken).approve(address(pairBusd), _totalSupply);
        IERC20(busdToken).approve(address(this), _totalSupply);
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    } 

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        //emit OwnershipTransferred(_owner, newOwner);
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

    function transfer(address to, uint256 value) external override validRecipient(to) returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external override validRecipient(to) returns (bool) {
        _transferFrom(from, to, value);
        return true;
    }

    function _baseTransfer(address from, address to, uint256 amount, uint256 feePercent) internal returns (bool) { 
        require(_balances[from] >= amount, "Fees cannot exceed Txn. Amount"); 
        
        if(_isAdminAddress(from) || _isAdminAddress(to)) {   
            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from, to, amount);   
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
        }  
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return _isLiquidityEnabled && !inSwap &&  (msg.sender != pair && msg.sender != pairBusd); 
            //&& block.timestamp >= (_lastAddLiquidityTime + 2 days);
    }

    function _transferFrom(address sender, address recipient,  uint256 amount) internal returns (bool) {
        require(amount > 0 && _balances[sender] >= amount, "valid amount required");      
        require(!_blacklistBot[sender] && !_blacklistBot[recipient], "in_blacklist");
        require(maxSellTransactionAmount >= amount || _isAccountExempt[sender] || _isAdminAddress(sender), "Amount exceeds Transaction Limit");

        if(inSwap || _isAdminAddress(sender) || _isAdminAddress(recipient)) {  
            return _baseTransfer(sender, recipient, amount, 0); 
        }

        if (_isAccountExempt[sender]) {  
           //share the fees to the corresponding addresses
            if(buyTotalFee > 0) {
                //_baseTransferFee(address to, uint256 amount, uint256 feePercent, uint is_buy)               
                _baseTransferFee(marketingReceiver, amount, buyMarketingFee, 1);
                _baseTransferFee(liquidityReceiver, amount, liquidityFee, 1);
                _baseTransferFee(projectReceiver, amount, buyProjectFee, 1);
                _baseTransferFee(devReceiver, amount, devFee, 1);
                _baseTransferFee(teamReceiver, amount, teamFee, 1);
                _baseTransferFee(epifReceiver, amount, epifFee, 1); 
                _setShareTotal(amount);                
            } 
            return _baseTransfer(sender, recipient, amount, buyTotalFee); 
        }

        if (shouldAddLiquidity()) {
            addLiquidity();
        }        

        if (shouldSwapBack()) {
            swapBack();
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
        require(maxDailyWalletTransferPercent >= 100 || (max_txn_allowed >= amount.add(_accountDailyTxn[sender].txnAmount)), "Amount exceeded allowed range for one day");   

        //_accountDailyTxn[sender].txnTimeSecs = block.timestamp; still in the 24hrs timeframe
        _accountDailyTxn[sender].txnAmount = _accountDailyTxn[sender].txnAmount.add(amount); 
        _transferAsSell(sender, recipient, amount);
        return true; 
    }
  
    function _transferAsSell(address sender, address recipient, uint256 amount) private { 
        bool is_transfer = _baseTransfer(sender, recipient, amount, sellTotalFee);  
        if(sellTotalFee > 0 && is_transfer && !(_isAdminAddress(sender) || _isAdminAddress(recipient))) {                
            _baseTransferFee(marketingReceiver, amount, sellMarketingFee, 0);             
            _baseTransferFee(liquidityReceiver, amount, liquidityFee, 0);             
            _baseTransferFee(projectReceiver, amount, sellProjectFee, 0);             
            _baseTransferFee(epifReceiver, amount, epifFee, 0);             
            _baseTransferFee(devReceiver, amount, devFee, 0);             
            _baseTransferFee(teamReceiver, amount, teamFee, 0);  
            _setShareTotal(amount); 
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
    
    function _setShareTotal(uint256 amount) internal {
         uint256 feeAmt = epifFee > 0? amount.mul(epifFee).div(_pcent100) : 0;  
        totalSharesTokens = totalSharesTokens.add(feeAmt);
    } 
  
    event eventClaimShares(address sender, uint256 amount);
    
    function claimShares(address sender, uint256 amount) external returns (bool) {
        require(_balances[epifReceiver] >= amount && (epifReceiver == msg.sender || msg.sender == _owner), "Invalid Access...");
       
        _balances[epifReceiver] = _balances[epifReceiver].sub(amount);
        _balances[sender] = _balances[sender].add(amount);
        
        emit Transfer(epifReceiver, sender, amount); 
        emit eventClaimShares(sender, amount); 
        return true; 
    }    
 

    function setBasicFees(uint256 denom, uint256 liqfee, uint256 epifee,  
            uint256 sMarketFee, uint256 sProjFee, 
            uint256 maxDailyWalletPcent, 
            uint256 maxTxnSecs) external onlyOwner {
          require((liqfee>=0 && liqfee<=10) &&
                  (epifee>=0 && epifee<=10) && sProjFee >= 0 &&
                  (sMarketFee>=0 && sMarketFee<=10) &&
                  (maxDailyWalletPcent>=0 && maxDailyWalletPcent<=100) && maxTxnSecs >= 0 
                  );
                  
         _pcent100=denom;
         liquidityFee=liqfee; 
         epifFee=epifee; 
         sellMarketingFee=sMarketFee;
         sellProjectFee=sProjFee;
         maxDailyWalletTransferPercent=maxDailyWalletPcent;
         maxTransferTimeSecs=maxTxnSecs; 
    }
 
    function getBalancesInfo() public view returns ( 
            uint256 balDead,  
            uint256 balMarketing,  
            uint256 balLiquidity, 
            uint256 balProject, 
            uint256 balEpif,
            uint256 balDev,
            uint256 balTeam 
        )
    {
        return ( 
            _balances[DEAD], 
            _balances[marketingReceiver],  
            _balances[liquidityReceiver],  
            _balances[projectReceiver],  
            _balances[epifReceiver],  
            _balances[devReceiver],     
            _balances[teamReceiver]
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
  
    function setAccountExempt(address _addr, bool _flag) public onlyOwner {
        _isAccountExempt[_addr] = _flag;
    }

    function setBotBlacklist(address _botAddress, bool _flag) external onlyOwner {
        require(isContract(_botAddress), "only contract address, not allowed externally owned account");
        _blacklistBot[_botAddress] = _flag;    
    }
 
    function setMaxSellTransaction(uint256 _maxTxn) external onlyOwner {
        maxSellTransactionAmount = _maxTxn;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
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
     
    //>>>>>>>>>>>LIQUIDITY >>>>>>>>>>>>>.
    bool _isLiquidityEnabled = true;
    bool public swapEnabled = true;
    uint256 private _swapThresholdAmt = (_totalSupply * 10) / 10000;
    bool public isLiquidityInBnb = false;

    IDexRouter public _router;
    address public pair;       
    address public pairBusd; 

    address public busdToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    bool inSwap;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 
    
    event eventLiquidity(uint256 efaToken, uint256 blockchainToken, uint isBNB);  
    
    function activateLiquidity(bool _flag) external onlyOwner {
        _isLiquidityEnabled = _flag;  
    }
         
    function setIsLiquidityInBnb(bool _value) external onlyOwner {
        require(isLiquidityInBnb != _value, "Not changed");
        isLiquidityInBnb = _value;
    } 

    function shouldSwapBack() internal view returns (bool) {  
        return _isLiquidityEnabled && !_isAccountExempt[msg.sender] && 
                msg.sender != pair && msg.sender != pairBusd &&
                !inSwap && swapEnabled  && _balances[liquidityReceiver] >= _swapThresholdAmt;
    }
     
    function getLiquidityBacking() public view returns (uint256){
        return (balanceOf(pair).add(balanceOf(pairBusd))).div(10 ** _decimals); 
    }

    function manualSync() public { 
        IPancakeSwapPair(pair).sync();
        IPancakeSwapPair(pairBusd).sync(); 
    }
 
   function addLiquidity() internal {
        if(isLiquidityInBnb){
            _addLiquidityBNB();
        }
        else {
            _addLiquidityBUSD();
        }
      }

    function _addLiquidityBNB() internal swapping {
        uint256 autoLiquidityAmount = _balances[liquidityReceiver];
        if(autoLiquidityAmount == 0) {
            return;
        }
        
        (uint reserveA, uint reserveB, ) = IPancakeSwapPair(pair).getReserves();
        if(reserveA == 0 || reserveB == 0){
            return;
        }

        _balances[address(this)] = _balances[address(this)].add(autoLiquidityAmount);
        _balances[liquidityReceiver] = 0;
        uint256 amountToLiquify = autoLiquidityAmount.div(2);
        uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

        if( amountToSwap == 0 ) {
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();

        uint256 balanceBefore = address(this).balance;
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap, 0, path, address(this), block.timestamp
        );

        uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);
        if (amountToLiquify > 0 && amountETHLiquidity > 0) {
            _router.addLiquidityETH{value: amountETHLiquidity}(
                address(this), amountToLiquify, 0, 0, liquidityReceiver, block.timestamp
            );
        }
    }

    function _addLiquidityBUSD() internal swapping {
        uint256 efaLiquid = _balances[address(this)].add(_balances[liquidityReceiver]);
        if(efaLiquid == 0) {
            emit evtLiquidity(false, "efaLiquid == 0");
            return;
        }

        (uint busdReserveA, uint busdReserveB, ) = IPancakeSwapPair(pairBusd).getReserves();
        if(busdReserveA == 0 || busdReserveB == 0){
            return;
        }

        _balances[address(this)] = efaLiquid;
        _balances[liquidityReceiver] = 0;
        
        uint256 efaToLiquify = efaLiquid.div(2);
        uint256 efaToSwap = efaLiquid.sub(efaToLiquify);
        if(efaToSwap == 0 || efaToLiquify == 0) {
            emit evtLiquidity(false, "efaToSwap/efaToLiquify == 0");
            return;
        }
         
        uint256 initialBusdBalance = IERC20(busdToken).balanceOf(address(this)); 
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = _router.WETH();
        path[2] = busdToken;         
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(efaToSwap, 0, path, address(this), block.timestamp);
        
        uint256 busdToLiquify = IERC20(busdToken).balanceOf(address(this)).sub(initialBusdBalance);
        if(busdToLiquify > 0) {
            bool success = _addLiquidityOfBUSD(efaToLiquify, busdToLiquify);
            emit evtLiquidity(success, string.concat("liquidify BUSD, token:", uint2str(efaToLiquify), " busd:", uint2str(busdToLiquify)));
        } 
    }

    function _addLiquidityOfBUSD(uint256 tokenAmount, uint256 busdAmount) private returns (bool) { 
        bool issuccess = false;        
        IERC20(address(this)).approve(address(_router), tokenAmount);
        IERC20(busdToken).approve(address(_router), busdAmount);

        try _router.addLiquidity(address(this), busdToken, tokenAmount, busdAmount, 0, 0, address(this), block.timestamp) {
                issuccess = true;
        } catch(bytes memory err) {
            emit evtLiquidity(false, string.concat("_router.addLiquidity: ", string(abi.encodePacked(err))));
        }
        return issuccess;
    }
    event evtLiquidity(bool success, string message);

    function getLiquidBalance() external view returns(
        uint256 bnbContract, uint256 efaContract,
        uint256 bnbToken, uint256 efaToken,
        
        uint256 reserveContractTokenA, uint256 reserveContractTokenB,
        uint256 reserveBusdTokenA, uint256 reserveBusdTokenB
     ){
          (uint reserveA, uint reserveB, ) = IPancakeSwapPair(pair).getReserves();
          (uint busdReserveA, uint busdReserveB, ) = IPancakeSwapPair(pairBusd).getReserves();

         return (
            address(this).balance,
            _balances[address(this)],
            address(liquidityReceiver).balance,
            _balances[liquidityReceiver],
            reserveA, reserveB,
            busdReserveA, busdReserveB
         );
     }
    
    function callLiquidate() external payable returns (bool) {
       addLiquidity();
       return true;
    }
    
    function callSwap() external payable returns (bool){
        swapBack();
        return true;
    }
      
    function swapBack() internal {
        if(isLiquidityInBnb){
            _swapBackBNB();
        }
        else{
            _swapBackBUSD();
        }
    }

    function _swapBackBNB() internal swapping {
        uint256 amountToSwap = _balances[address(this)];
        if(amountToSwap == 0) {
            return;
        }

        (uint reserveA, uint reserveB, ) = IPancakeSwapPair(pair).getReserves();
        if(reserveA == 0 || reserveB == 0){
            return;
        }

        uint256 balanceBefore = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();
        
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHToLiqReceiver = address(this).balance.sub(balanceBefore);
        if(amountETHToLiqReceiver > 0){
            (bool success, ) = payable(liquidityReceiver).call{
                        value: amountETHToLiqReceiver, gas: 30000 }("");        
            emit evtSwap(amountToSwap, amountETHToLiqReceiver, success);
        }
        
    }
    
    function _swapBackBUSD() internal swapping {
        uint256 amountToSwap = _balances[address(this)];
        if(amountToSwap == 0) {
            return;
        }

        (uint busdReserveA, uint busdReserveB, ) = IPancakeSwapPair(pairBusd).getReserves();
        if(busdReserveA == 0 || busdReserveB == 0){
            return;
        }
        
        IERC20 ercToken = IERC20(busdToken);
        uint256 initialBalance = ercToken.balanceOf(address(this)); 
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = _router.WETH();
        path[2] = busdToken;  
        
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        ); 
        uint256 amountBUSDToLiqReceiver = ercToken.balanceOf(address(this)).sub(initialBalance);
        emit evtSwap(amountToSwap, amountBUSDToLiqReceiver, false);
    }

    event evtSwap(uint256 amtToken, uint256 amtBnb, bool isBNB);

    function setSwapBackSettings(bool _enabled, uint256 _amtThreshold) external onlyOwner {
        swapEnabled = _enabled;
        _swapThresholdAmt = _amtThreshold;
    }

}