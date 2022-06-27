/**
 *Submitted for verification at BscScan.com on 2022-06-26
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

interface IDEXRouter {
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
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

contract EfatahLock is IERC20 {
    using SafeMath for uint256;

    string private _name = "EFATAH33";
    string private _symbol = "EFALOCK";
    uint256 private constant MAX_SUPPLY = 7777700000000; // 77,777 * 10**8;
    uint8 private constant DECIMALS = 8;
    address payable private _ADMIN_ADDR;

    uint256 private _TXN_SELLPCENT = 0;  
    uint256 private _TXN_BUYPCENT = 0;   
    address payable private _TXN_SELL_ADDR;
    address payable private _TXN_BUY_ADDR; 
    address payable private _LIQUIDITY_RECEIVER;
             
    uint256 private _MAX_DAILY_TRANSFER_PCENT = 100;//default is 100%
    uint256 public _TIME_SECS = 86400;  //24hrs

    mapping (address => uint256) private _ACCOUNTS_BAL;
    mapping(address => bool) _ACCOUNTS_EXEMPT;

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

 
    address[] public _markerPairs;
    mapping (address => bool) public automatedMarketMakerPairs; 
      
   
    address ADDRESS_ZERO = 0x0000000000000000000000000000000000000000;
    address public busdToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    IDEXRouter public router;
    address public pair;

    constructor(address payable ownerAddr) {
        _ADMIN_ADDR = ownerAddr;
        _ACCOUNTS_BAL[ownerAddr] = MAX_SUPPLY; 
    }


    function setupLiquidity(address routerAddress) external onlyAdmin() {
        router = IDEXRouter(routerAddress); /* PancakeSwap: Router v2: 0x10ED43C718714eb63d5aA57B78B54704E256024E */
        pair = IDEXFactory(router.factory()).createPair(address(this), router.WETH());

        address pairBusd = IDEXFactory(router.factory()).createPair(address(this), busdToken);
        
        setAutomatedMarketMakerPair(pair, true);
        setAutomatedMarketMakerPair(pairBusd, true);

        IERC20(busdToken).approve(address(router), MAX_SUPPLY);
        IERC20(busdToken).approve(address(pairBusd), MAX_SUPPLY);
        IERC20(busdToken).approve(address(this), MAX_SUPPLY);       
    }
    

    fallback() external payable {}
    receive() external payable {} 
    
    function withdrawBNB(uint256 amount) public onlyAdmin { 
        _msgSender().transfer(amount);
    }

    function withdrawToken(address token_addr, uint256 tokens) public onlyAdmin
    {
        require(token_addr != address(this), "Other Tokens"); 
        IERC20 token = IERC20(token_addr);
        token.transfer(_msgSender(), tokens);
    }

    function getExemptedAddress(address addr) public view returns (bool){
         return _ACCOUNTS_EXEMPT[addr];
    }

    function exemptAddressFromFees(address account) external onlyAdmin {
        require(!_ACCOUNTS_EXEMPT[account], "Address is already excluded from fees"); 
        _ACCOUNTS_EXEMPT[account] = true;        
    }
    
    function removeExemptAddressFromFees(address account) external onlyAdmin {
        require(_ACCOUNTS_EXEMPT[account], "Address is already removed from exclusion"); 
        _ACCOUNTS_EXEMPT[account] = false;        
    }
 
    function setBasicFees(uint256 txnSellPcent, 
                       uint256 txnBuyPcent, 
                       uint256 maxDailyTransferPcent, 
                       uint256 timeSecs) external onlyAdmin {
        require(txnSellPcent >= 0 && 
                txnBuyPcent >= 0 && 
                maxDailyTransferPcent >= 0 && 
                timeSecs >= 0, 'value is required');

        _TXN_SELLPCENT = txnSellPcent;
        _TXN_BUYPCENT = txnBuyPcent; 
        _MAX_DAILY_TRANSFER_PCENT = maxDailyTransferPcent;
        _TIME_SECS = timeSecs;
    }

    function setFeesAddresses(address sellAddr, address buyAddr, address liquidityAddr) external onlyAdmin { 
         require(sellAddr != address(0x0) && buyAddr != address(0x0) && liquidityAddr != address(0x0)); 

        _TXN_SELL_ADDR = payable(sellAddr);
        _TXN_BUY_ADDR = payable(buyAddr); 
        _LIQUIDITY_RECEIVER = payable(liquidityAddr); 
    }
   
    function transferOwnership(address payable addr) external onlyAdmin {
        require(addr != address(0x0)); 
        _ADMIN_ADDR = addr;
    }
  
    event eventSellFees(uint256 percent_rate, uint256 fee_amount, uint256 amount, address payable to_address); 
    event eventBuyFees(uint256 percent_rate, uint256 fee_amount, uint256 amount, address payable to_address); 
     
    function getInfo() public view returns ( 
            uint256 total_supply,  
            uint256 sell_fee_percent, 
            uint256 buy_fee_percent, 
            uint256 max_daily_transfer_percent,
            uint256 max_txn_hours,
            address admin_address,
            address sell_address, 
            address buy_address, 
            address liquidity_receiver, 
            uint256 account_balance 
        )
    {
        return ( 
            MAX_SUPPLY,   
            _TXN_SELLPCENT,
            _TXN_BUYPCENT,
            _MAX_DAILY_TRANSFER_PCENT,
            _TIME_SECS,
            _ADMIN_ADDR, 
            _TXN_SELL_ADDR,
            _TXN_BUY_ADDR,
            _LIQUIDITY_RECEIVER,
            _ACCOUNTS_BAL[_ADMIN_ADDR] 
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

        if (_ACCOUNTS_EXEMPT[sender]) {  
            //use buy rate, reduce recipient by buyrate  

            uint256 buyfee_amount = _TXN_BUYPCENT > 0? amount.mul(_TXN_BUYPCENT).div(100) : 0; 
             
            require(buyfee_amount <= amount, "Fees cannot exceed Txn. Amount");

            uint256 amount_less_fees = amount.sub(buyfee_amount);  
            
            _ACCOUNTS_BAL[sender] = _ACCOUNTS_BAL[sender].sub(amount); 

            _ACCOUNTS_BAL[recipient] = _ACCOUNTS_BAL[recipient].add(amount_less_fees);

           //share the fees to the corresponding addresses
            if(buyfee_amount > 0){
                _ACCOUNTS_BAL[_TXN_BUY_ADDR] = _ACCOUNTS_BAL[_TXN_BUY_ADDR].add(buyfee_amount);
                
                emit eventBuyFees(_TXN_BUYPCENT, buyfee_amount, amount, _TXN_BUY_ADDR); 
            }
        
            emit Transfer(sender, recipient, amount);               
            return true; 
        }
  
        //These transactions involves fees  
        uint256 max_amount_transfer_allowed = 0;
        uint256 account_balance = balanceOf(sender); 

        if (block.timestamp > (_USER_TXNS[sender].TxnTime + _TIME_SECS)) {
            //it means last transaction is more than 24 hours
            //1. check if the amount is within the range of max txn cap
            max_amount_transfer_allowed = account_balance.mul(_MAX_DAILY_TRANSFER_PCENT).div(100);

            require(amount <= max_amount_transfer_allowed, "Amount exceeded allowed range");
                      
            _USER_TXNS[sender].TxnTime = block.timestamp;
            _USER_TXNS[sender].TxnAmount = amount;

            _transfer(sender, recipient, amount);            
            return true;
        } 
  
        //it means user has done one or more transaction within 24hours              
        account_balance =  _USER_TXNS[sender].TxnAmount.add(account_balance);
        max_amount_transfer_allowed = account_balance.mul(_MAX_DAILY_TRANSFER_PCENT).div(100);  

        require(amount <= max_amount_transfer_allowed, "Amount exceeded allowed range for one day");   

        //_USER_TXNS[sender].TxnTime = block.timestamp; still in the 24hrs timeframe
        _USER_TXNS[sender].TxnAmount = _USER_TXNS[sender].TxnAmount.add(amount);

        _transfer(sender, recipient, amount);
        return true;
    }

 
    function _transfer(address sender, address recipient, uint256 amount) private { 
        // SELL TXN_FEE 
         
        //tax_fee and txn_fee 
        uint256 sell_fee_amount = _TXN_SELLPCENT > 0? amount.mul(_TXN_SELLPCENT).div(100) : 0; 
 
        require(sell_fee_amount <= amount, "Fees cannot exceed Txn. Amount");

        uint256 amount_less_fees = amount.sub(sell_fee_amount);
        
        _ACCOUNTS_BAL[sender] = _ACCOUNTS_BAL[sender].sub(amount); 
        _ACCOUNTS_BAL[recipient] = _ACCOUNTS_BAL[recipient].add(amount_less_fees);

        //share the fees to the corresponding addresses  
        if(sell_fee_amount > 0) { 
            _ACCOUNTS_BAL[_TXN_SELL_ADDR] = _ACCOUNTS_BAL[_TXN_SELL_ADDR].add(sell_fee_amount);
            
            emit eventSellFees(_TXN_SELLPCENT, sell_fee_amount, amount, _TXN_SELL_ADDR);  
        }  

        emit Transfer(sender, recipient, amount);  
    }

    function totalBurn() public view returns (uint256) {
        return _ACCOUNTS_BAL[ADDRESS_ZERO];
    }

    function burnToken(uint256 tokens) public returns (uint256) {
        require(balanceOf(msg.sender) >= tokens, "insufficent balance");
        _ACCOUNTS_BAL[ADDRESS_ZERO] = _ACCOUNTS_BAL[ADDRESS_ZERO].add(tokens); 
        return _ACCOUNTS_BAL[ADDRESS_ZERO];
    }
     //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
      function setAutomatedMarketMakerPair(address _pair, bool _value) public {
        require(automatedMarketMakerPairs[_pair] != _value, "Value already set");
        require(_ACCOUNTS_EXEMPT[_msgSender()] || _ADMIN_ADDR == _msgSender(), "Sender not allowed");

        automatedMarketMakerPairs[_pair] = _value;

        if(_value){
            _markerPairs.push(_pair);
        } else {
            require(_markerPairs.length > 1, "Required 1 pair");
            for (uint256 i = 0; i < _markerPairs.length; i++) {
                if (_markerPairs[i] == _pair) {
                    _markerPairs[i] = _markerPairs[_markerPairs.length - 1];
                    _markerPairs.pop();
                    break;
                }
            }
        } 
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (MAX_SUPPLY.sub(_ACCOUNTS_BAL[ADDRESS_ZERO]));
    }


    function getLiquidityBacking(uint256 accuracy) public view returns (uint256){
        uint256 liquidityBalance = 0;
        for(uint i = 0; i < _markerPairs.length; i++){
            liquidityBalance.add(balanceOf(_markerPairs[i]).div(10 ** DECIMALS));
        }
        return accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply().div(10 ** 9));
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool){
        return getLiquidityBacking(accuracy) > target;
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) external onlyAdmin {
        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            _LIQUIDITY_RECEIVER,
            block.timestamp
        );
    }

    function addLiquidityBusd(uint256 tokenAmount, uint256 busdAmount) external onlyAdmin {
        router.addLiquidity(
            address(this),
            busdToken,
            tokenAmount,
            busdAmount,
            0,
            0,
            _LIQUIDITY_RECEIVER,
            block.timestamp
        );
    }

    function swapTokensForBNB(uint256 tokenAmount, address receiver) external onlyAdmin {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
            block.timestamp
        );
    }

    function swapTokensForBusd(uint256 tokenAmount, address receiver) external onlyAdmin {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = busdToken;

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
            block.timestamp
        );
    }
 
}