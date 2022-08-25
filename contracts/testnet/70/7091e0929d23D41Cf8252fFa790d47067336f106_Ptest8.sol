/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}



library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface InterfaceLP {
    function sync() external;
}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}



abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 _tokenDecimals
    ) {
        _name = _tokenName;
        _symbol = _tokenSymbol;
        _decimals = _tokenDecimals;
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

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


// contract Ligerplay is ERC20Detailed, Ownable {
contract Ptest8 is ERC20Detailed, Ownable  ,  ReentrancyGuard {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    mapping(address => uint256) _gonBalances;

    mapping(address => mapping (address => uint256)) _allowedFragments;


   
    bool public initialDistributionFinished = false;
   
    bool public feesOnNormalTransfers = false;
    bool public launchMode = true;

    uint256 public maxSellTransactionAmount = 1000000 * 10 ** 18;

    mapping(address => bool) _isFeeExempt;
   
    address[] public _markerPairs;
    mapping (address => bool) public automatedMarketMakerPairs;

    uint256 public constant MAX_FEE_RATE = 25;
    uint256 private constant DECIMALS = 18;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant _totalSupply = 10**9 * 10**DECIMALS;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public treasuryReceiver = 0xa620E9619847830CFb99FB81dB9a1F6f10D1DD59;

    IDEXRouter public router;
    address public pair;

    uint256 public treasuryFee = 8;
    uint256 public sellFeeTreasuryAdded = 10;
   
    uint256 public totalBuyFee = treasuryFee;
    uint256 public totalSellFee = totalBuyFee.add(sellFeeTreasuryAdded);
    uint256 public feeDenominator = 100;

   
    uint256 public SellLimit = 1;
    uint256 percentfactor = uint256(100);

  

    uint256 private MAX_INT = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

   
    struct user {
        uint256 lastTradeTime;
        uint256 tradeAmount;
    }

    uint256 public TwentyFourhours = 86400;

    mapping(address => user) public tradeData;
    
    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

   

    constructor() ERC20Detailed("PTEST8", "PTEST8", uint8(DECIMALS)) {
      //  router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
        router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        
        pair = IDEXFactory(router.factory()).createPair(address(this), router.WETH());
        

        _allowedFragments[address(this)][address(router)] = uint256(MAX_INT);
        _allowedFragments[address(this)][pair] = uint256(MAX_INT);
        _allowedFragments[address(this)][address(this)] = uint256(MAX_INT);
       

        setAutomatedMarketMakerPair(pair, true);

        _gonBalances[msg.sender] = _totalSupply;
      
        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[msg.sender] = true;

        emit Transfer(address(0x0), msg.sender, _totalSupply);

    } 

    receive() external payable {}

    

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

   
    function shouldTakeFee(address from, address to) internal view returns (bool) {
        if (launchMode) {
          return false;
        }else if (_isFeeExempt[from] || _isFeeExempt[to]){
            return false;
        }else if (feesOnNormalTransfers){
            return true;
        }else{
            return (automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]);
        }
    }

   
    function manualSync() public {
        for(uint i = 0; i < _markerPairs.length; i++){
            InterfaceLP(_markerPairs[i]).sync();
        }
    }


    function totalSupply()  public pure  override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _gonBalances[account] ;
    }

    function approve(address spender, uint256 value) external override returns (bool) {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner_, address spender) external view override returns (uint256) {
        return _allowedFragments[owner_][spender];
    }

   
    function transfer(address to, uint256 value)
        external
        override
        validRecipient(to)
        nonReentrant
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

        
        
    function transferFrom(  address from,  address to,  uint256 value
    ) external  override validRecipient(to) nonReentrant returns (bool) {
      
       // if (_allowedFragments[from][msg.sender] != uint256(-1)) {
        if (_allowedFragments[from][msg.sender] != MAX_UINT256) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
                msg.sender
            ].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }


    function _basicTransfer(  address from, address to, uint256 amount
    ) internal returns (bool) {
       
        _gonBalances[from] = _gonBalances[from].sub(amount);
        _gonBalances[to] = _gonBalances[to].add(amount);
        
        emit Transfer(from, to, amount);
        return true;
    }
 
        


    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool excludedAccount = _isFeeExempt[sender] || _isFeeExempt[recipient];
        require(initialDistributionFinished || excludedAccount, "Trading not started");
        
        if (
            automatedMarketMakerPairs[recipient] &&
            !excludedAccount
        ) {
            require(amount <= maxSellTransactionAmount, "Error amount");

            uint blkTime = block.timestamp;
          

            uint256 onePercent = _gonBalances[sender].mul(SellLimit).div(percentfactor);  
            require(amount <= onePercent, "ERR: Can't sell more than set %");
            
            if( blkTime > tradeData[sender].lastTradeTime + TwentyFourhours) {
                tradeData[sender].lastTradeTime = blkTime;
                tradeData[sender].tradeAmount = amount;
            }
            else if( (blkTime < tradeData[sender].lastTradeTime + TwentyFourhours) && (( blkTime > tradeData[sender].lastTradeTime)) ){
                require(tradeData[sender].tradeAmount + amount <= onePercent, "ERR: Can't sell more than 1% in One day");
                tradeData[sender].tradeAmount = tradeData[sender].tradeAmount + amount;
            }
        } 


        _gonBalances[sender] = _gonBalances[sender].sub(amount);
        uint256 amountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, amount)
            : amount;
        _gonBalances[recipient] = _gonBalances[recipient].add(
            amountReceived
        );


        emit Transfer(sender, recipient, amountReceived);
        
        

        return true;
    }

   
    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256){

    uint256 _realFee = totalBuyFee;
    if(automatedMarketMakerPairs[recipient]) _realFee = totalSellFee;

    uint256 feeAmount = amount.mul(_realFee).div(feeDenominator);

    _gonBalances[treasuryReceiver] = _gonBalances[treasuryReceiver].add(feeAmount)  ;
 
    emit Transfer(sender, address(this), feeAmount);
    return amount.sub(feeAmount);
    
    }

  

    function setAutomatedMarketMakerPair(address _pair, bool _value) public onlyOwner {
        require(automatedMarketMakerPairs[_pair] != _value, "Value already set");

        automatedMarketMakerPairs[_pair] = _value;
        

        if(_value){
            _markerPairs.push(_pair);
        }else{
            require(_markerPairs.length > 1, "Required 1 pair");
            for (uint256 i = 0; i < _markerPairs.length; i++) {
                if (_markerPairs[i] == _pair) {
                    _markerPairs[i] = _markerPairs[_markerPairs.length - 1];
                    _markerPairs.pop();
                    break;
                }
            }
        }

        emit SetAutomatedMarketMakerPair(_pair, _value);
    }

    function setInitialDistributionFinished(bool _value) external onlyOwner {
        require(initialDistributionFinished != _value, "Not changed");
        initialDistributionFinished = _value;
    }

    function setFeeExempt(address _addr, bool _value) external onlyOwner {
        require(_isFeeExempt[_addr] != _value, "Not changed");
        _isFeeExempt[_addr] = _value;
    }

    function setSellLimit(uint _addr) external onlyOwner {
        SellLimit = _addr;
    }

    function setTwentyFourhours(uint256 _time) external onlyOwner {
        TwentyFourhours = _time;
    }


    function setFeeReceivers( address _treasuryReceiver) external onlyOwner {
       treasuryReceiver = _treasuryReceiver;  
    }

    function setFees( uint256 _treasuryFee, uint256 _sellFeeTreasuryAdded, uint256 _feeDenominator) external onlyOwner {
        require(
            _treasuryFee <= MAX_FEE_RATE &&
            _sellFeeTreasuryAdded <= MAX_FEE_RATE ,
            "wrong"
        );
  
        treasuryFee = _treasuryFee;
        sellFeeTreasuryAdded = _sellFeeTreasuryAdded;    
        totalBuyFee = treasuryFee;
        totalSellFee = totalBuyFee.add(sellFeeTreasuryAdded);
        feeDenominator = _feeDenominator;
        require(totalBuyFee < feeDenominator / 4);
    }

    function clearStuckBalance(address _receiver) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_receiver).transfer(balance);
    }

    function rescueToken(address tokenAddress, uint256 tokens) external onlyOwner returns (bool success){
        return ERC20Detailed(tokenAddress).transfer(msg.sender, tokens);
    }

    function setFeesOnNormalTransfers(bool _enabled) external onlyOwner {
        require(feesOnNormalTransfers != _enabled, "Not changed");
        feesOnNormalTransfers = _enabled;
    }

    function setLaunchMode(bool _enabled) external onlyOwner {
        require(launchMode != _enabled, "Not changed");
        launchMode = _enabled;
    }


    function setMaxSellTransaction(uint256 _maxTxn) external onlyOwner {
        maxSellTransactionAmount = _maxTxn;
    }

       function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }


// airdrop individual specific number of tokens to batch of addresses 
  function multiTransfer(address[] calldata addresses, uint256[] calldata tokens) nonReentrant() external onlyOwner {

    require(addresses.length < 501,"GAS Error: max airdrop limit is 500 addresses"); // to prevent overflow
    require(addresses.length == tokens.length,"Mismatch between Address and token count");

    uint256 airdropcount = 0;

    for(uint i=0; i < addresses.length; i++){
        airdropcount = airdropcount + tokens[i];
    }

    require(balanceOf(msg.sender) >= airdropcount, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        _basicTransfer(msg.sender,addresses[i],tokens[i]);
    }
   
  }

  // airdrop fixed amount to batch of addresses 
  function multiTransfer_fixed(address[] calldata addresses, uint256 tokens) nonReentrant() external onlyOwner {

    require(addresses.length < 2001,"GAS Error: max airdrop limit is 2000 addresses"); // to prevent overflow

    uint256 airdropcount = tokens * addresses.length;

    require(balanceOf(msg.sender) >= airdropcount, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        _basicTransfer(msg.sender,addresses[i],tokens);
    }
}


    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
}