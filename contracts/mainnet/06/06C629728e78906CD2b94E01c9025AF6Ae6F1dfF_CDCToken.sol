/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

pragma solidity 0.5.8;

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
        return mod(a, b, "SafeMath: modulo by zero");
    }
 
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
    function getPair(address,address) external view returns (address);    
}

interface IPancakeRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountsIn(uint amountOut, address[] calldata path)
        external
        view
        returns (uint[] memory amounts);
}

interface IPancakePair {
    function totalSupply() external view returns (uint256);
    function getReserves() external view returns (uint,uint,uint);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
}

interface TokenLike {
    function award(address buyer, uint256 wad) external;
    function balanceOf(address) external view returns(uint256);
}

contract StandardToken is ERC20 {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;

  uint256 totalSupply_;

  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256){
    return allowed[_owner][_spender];
  }

  function increaseApproval(address _spender, uint _addedValue) public returns (bool){
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool){
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}

contract Ownable {
  address public owner;
  address public controler;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier onlyControler() {
    require(msg.sender == controler);
    _;
  }
  
  modifier onlySelf() {
    require(address(msg.sender) == address(tx.origin));
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = true;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() onlyControler onlySelf whenNotPaused public {
    paused = true;
    emit Pause();
  }

  function unpause() onlyControler onlySelf whenPaused public {
    paused = false;
    emit Unpause();
  }
}

//------------------------------------------------------------------------------
contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool){
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool){
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool){
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success){
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success){
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

contract CDCToken is PausableToken {
    string public name = "Chinese Dragon Coin";
    string public symbol = "CDC";
    uint8 public decimals = 18;

    uint256 public CDCPrice = 0;
    
    uint256 startTime;

    address public pankFactory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address public pankRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public tokenAddressA = 0x55d398326f99059fF775485246999027B3197955;

    // address public pankFactory = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;
    // address public pankRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    // address public tokenAddressA = 0x980D7F598AeC8A34c276183faE844D1B2dD0a487;

    address public pankPair = address(0);
    address public tokenAddressB = address(0);

    address public poolAccount = 0xc7F7BDB60F7727E3f26148125EBB6015aE5199CE;

    mapping(address => address) parentPlayer;

    uint256 public transactionTaxPool_buy = 1;//买 交易池子抽佣 为加池
    uint256 public transactionTaxParent_buy = 1;//买 上级返佣
    uint256 public transactionTaxParentParent_buy = 1;//买、上 上级返佣

    uint256 public transactionTaxPool_sale = 1;//卖 交易池子抽佣 为加池
    uint256 public transactionTaxParent_sale = 1;//卖上级返佣
    uint256 public transactionTaxParentParent_sale = 1;//卖、上 上级返佣

    constructor(
      
    ) public {
        totalSupply_ = 100000000 * (10 ** uint256(decimals));
        paused = false;

        startTime = now;
        controler = msg.sender;

        balances[controler] = totalSupply_;

        tokenAddressB = address(this);
        pankPair = IPancakeFactory(pankFactory).createPair(tokenAddressA,tokenAddressB);
    }
    
    uint BUY = 1;
    uint REMOVELIQUIDITY = 2;
    uint TRANSFER = 3;
    uint SALE = 4;
    uint ADDLIQUIDITY = 5;
    uint TRANSFERFROM = 6;

    uint public sort = 0;
    uint public state = 0;// 0-close  1-开放交易
    function transfer(address dst,uint256 wad) public whenNotPaused returns (bool) {
        if(msg.sender == controler || dst == controler || msg.sender == poolAccount || dst == poolAccount){
            return super.transfer(dst,wad);
        }

        if(state==0){
            return false;
        }
        
        if(balances[dst]==0 && parentPlayer[dst]==address(0)){
            if(parentPlayer[msg.sender] != dst){
                parentPlayer[dst] = msg.sender;
            }
        }

        sort = 0;
        if (isV2Pair(msg.sender)) {
            if(isBuy(msg.sender,wad)) {
                sort = BUY;
            }else{
                sort = REMOVELIQUIDITY;
            }
        }else{
            sort = TRANSFER;
        }

        if(sort==BUY){
            if(parentPlayer[dst]==address(0)){
                parentPlayer[dst] = owner;
            }
            if(parentPlayer[parentPlayer[dst]]==address(0)){
                parentPlayer[parentPlayer[dst]] = owner;
            }

            uint256 wadTransactionTaxPool = wad.mul(transactionTaxPool_buy).div(100);
            uint256 wadTransactionTaxParent = wad.mul(transactionTaxParent_buy).div(100);
            uint256 wadTransactionTaxParentParent = wad.mul(transactionTaxParentParent_buy).div(100);

            wad = wad.sub(wadTransactionTaxPool);
            wad = wad.sub(wadTransactionTaxParent);
            wad = wad.sub(wadTransactionTaxParentParent);

            super.transfer(poolAccount, wadTransactionTaxPool);
            super.transfer(parentPlayer[dst], wadTransactionTaxParent);
            super.transfer(parentPlayer[parentPlayer[dst]], wadTransactionTaxParentParent);
            super.transfer(dst, wad);
            return true;
        }else if(sort==REMOVELIQUIDITY){
            super.transfer(dst, wad);
            return true;
        }else if(sort==TRANSFER){
            super.transfer(dst, wad);
            return true;
        }
    }
    
    function transferFrom(address src,address dst,uint256 wad) public whenNotPaused returns (bool){
        if(src == controler || dst == controler || src == poolAccount || dst == poolAccount){
            return super.transferFrom(src,dst,wad);
        }

        if(state==0){
            return false;
        }

        sort = 0;
        if(isV2Pair(dst) && src!=poolAccount) {
            if(!isAddLiquidity(dst,wad)){
                sort = SALE;
            }else{
                sort = ADDLIQUIDITY;
            }
        }else{
            sort = TRANSFERFROM;
        }

        if(sort==SALE){
            if(parentPlayer[src]==address(0)){
                parentPlayer[src] = owner;
            }
            if(parentPlayer[parentPlayer[src]]==address(0)){
                parentPlayer[parentPlayer[src]] = owner;
            }

            uint256 wadTransactionTaxPool = wad.mul(transactionTaxPool_sale).div(100);
            uint256 wadTransactionTaxParent = wad.mul(transactionTaxParent_sale).div(100);
            uint256 wadTransactionTaxParentParent = wad.mul(transactionTaxParentParent_sale).div(100);

            wad = wad.sub(wadTransactionTaxPool);
            wad = wad.sub(wadTransactionTaxParent);
            wad = wad.sub(wadTransactionTaxParentParent);

            super.transferFrom(src, poolAccount, wadTransactionTaxPool);
            super.transferFrom(src, parentPlayer[src], wadTransactionTaxParent);
            super.transferFrom(src, parentPlayer[parentPlayer[src]], wadTransactionTaxParentParent);
            super.transferFrom(src, dst, wad);
            return true;
        }else if(sort==ADDLIQUIDITY){
            super.transferFrom(src,dst,wad);
            return true;
        }else if(sort==TRANSFERFROM){
            super.transferFrom(src,dst,wad);
            return true;
        }
    }

    function () external payable {
        revert();
    }

    //-------------------------------------------------------------------
    function updateState(uint _state) public onlyControler{
      state = _state;
    }

    function updateTransactionTax_buy(uint256 _transactionTaxPool_buy,uint256 _transactionTaxParent_buy,uint256 _transactionTaxParentParent_buy) onlyControler onlySelf whenNotPaused public {
        transactionTaxPool_buy = _transactionTaxPool_buy;
        transactionTaxParent_buy = _transactionTaxParent_buy;
        transactionTaxParentParent_buy = _transactionTaxParentParent_buy;
    }

    function updateTransactionTax_sale(uint256 _transactionTaxPool_sale,uint256 _transactionTaxParent_sale,uint256 _transactionTaxParentParent_sale) onlyControler onlySelf whenNotPaused public {
        transactionTaxPool_sale = _transactionTaxPool_sale;
        transactionTaxParent_sale = _transactionTaxParent_sale;
        transactionTaxParentParent_sale = _transactionTaxParentParent_sale;
    }

    function updatePoolAddress(address _poolAccount) public onlyControler onlySelf whenNotPaused {
        poolAccount = _poolAccount;
    }

    function syncParentPlayer(address _player,address _parentPlayer,address _parentparentPlayer) public onlyControler{
        parentPlayer[_player] = _parentPlayer;
        parentPlayer[_parentPlayer] = _parentparentPlayer;
    }

    //-----------------------------------------------------------------------------
    //Find a pair address in addition to the SPD token
    function getAsset(address _pair) private view returns (address){
        address _token0 = IPancakePair(_pair).token0();
        address _token1 = IPancakePair(_pair).token1();
        address asset = _token0 == address(this) ? _token1 : _token0;
        return asset;
    }

    //Check whether an address is PancakePair 
    function isV2Pair(address _pair) private view returns (bool) {
        bytes32 accountHash;
        bytes32 codeHash;  
        address pair = pankPair;  
        assembly { accountHash := extcodehash(pair)}
        assembly { codeHash := extcodehash(_pair) }
        return (codeHash == accountHash);
    }

    //Decide whether to add liquidity or sell,
    function isAddLiquidity(address _pair,uint256 wad) private view returns (bool) {
        address _asset = getAsset(_pair);
        uint balance1 = TokenLike(_asset).balanceOf(_pair);
        (uint reserve0, uint reserve1,) = IPancakePair(_pair).getReserves();
        if (reserve0 ==0 || reserve1 ==0 ) return true;
        address _token0 = IPancakePair(_pair).token0();
        (uint spdreserve, uint assetreserve)= _token0 == address(this) ? (reserve0,reserve1) : (reserve1,reserve0);
        uint assetamount = IPancakeRouter(pankRouter).quote(wad, spdreserve, assetreserve);
        return (balance1 > assetreserve + assetamount/2 );
     }
     
    //Determine whether you are buying or remove liquidity
    function isBuy(address _pair,uint256 wad) private view returns (bool) {
        if (!isV2Pair(_pair)) return false;
        (uint reserve0, uint reserve1,) = IPancakePair(_pair).getReserves();
        address _token0 = IPancakePair(_pair).token0();
        (,uint assetreserve)= _token0 == address(this) ? (reserve0,reserve1) : (reserve1,reserve0);
        address _asset = getAsset(_pair);
        address[] memory path = new address[](2);
        path[0] = _asset;
        path[1] = address(this);
        uint[] memory amounts = IPancakeRouter(pankRouter).getAmountsIn(wad,path);
        uint balance1 = TokenLike(_asset).balanceOf(_pair);
        return (balance1 > assetreserve + amounts[0]/2);
    }

    //-------------------------------------------------
    function changeControler(address _controler) public onlyOwner onlySelf{
        controler = _controler;
    }
}