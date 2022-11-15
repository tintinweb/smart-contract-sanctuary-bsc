/**
 *Submitted for verification at BscScan.com on 2022-11-15
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

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;
 
    function safeTransfer(ERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
 
    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
 
    function safeApprove(ERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),"SafeERC20: approve from non-zero to non-zero allowance");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
 
    function safeIncreaseAllowance(ERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
 
    function safeDecreaseAllowance(ERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
 
    function callOptionalReturn(ERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        // 空字符串hash值
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;  
        //内联编译（inline assembly）语言，是用一种非常底层的方式来访问EVM
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
 
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
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

//------------------------------------------------------------------------------
contract ZXDToken is StandardToken,Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    string public name = "ZXD";
    string public symbol = "ZXD";
    uint8 public decimals = 18;

    address public pankFactory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address public pankRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public tokenAddressA = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    // address public pankFactory = 0xd24c504a942c7F74fe36aAE8C6DD08172BD3b13b;
    // address public pankRouter = 0x7C0d34a5183c4CDE05a0B650Aa31b31e024eeedd;
    // address public tokenAddressA = 0x56dea0acca13ECc80Af8D94E7019267275803760;

    address public lpPriseAccount;
    address public daoAccount = 0xe6DE69ba362Df55f4C6b4c529e6A349797516DA2;

    address public pankPair = address(0);
    address public tokenAddressB = address(0);

    //----------------------------------------------------------------------------------------
    constructor(
      
    ) public {
        totalSupply_ = 3000 * (10 ** uint256(decimals));
        controler = msg.sender;

        balances[msg.sender] = totalSupply_;
        tokenAddressB = address(this);

        IPancakeFactory(pankFactory).createPair(tokenAddressA,tokenAddressB);
        pankPair = IPancakeFactory(pankFactory).getPair(tokenAddressA,tokenAddressB);
    }

    function init() public onlyControler {
      if(ERC20(tokenAddressA).allowance(address(this),pankRouter)==0){
          SafeERC20.safeApprove(ERC20(tokenAddressA),pankRouter,uint(-1));
      }
      if(ERC20(tokenAddressB).allowance(address(this),pankRouter)==0){
          SafeERC20.safeApprove(ERC20(tokenAddressB),pankRouter,uint(-1));
      }
    }

    uint BUY = 1;
    uint REMOVELIQUIDITY = 2;
    uint TRANSFER = 3;
    uint SALE = 4;
    uint ADDLIQUIDITY = 5;
    uint TRANSFERFROM = 6;

    uint public sort = 0;
    uint public state = 0;// 0-close  1-抢购  2-开放交易

    //---------------------------------------------------------------
    function transfer(address dst, uint256 wad) public returns (bool){
      if(msg.sender == controler || dst == controler || msg.sender == address(this) || dst == address(this) || msg.sender == lpPriseAccount || dst == lpPriseAccount){
        return super.transfer(dst,wad);
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

      //-----------------------------------------------------------------------------
      if(state==0){
        return false;
      }else if(state == 1){
        if(sort==BUY){
          if((balances[dst]+wad)>100000000000000000){
            return false;
          }

          uint256 wadLpPrise = wad.div(1000).mul(5);
          uint256 wadDao = wad.div(100).mul(1);

          wad = wad.sub(wadLpPrise);
          wad = wad.sub(wadDao);

          super.transfer(lpPriseAccount,wadLpPrise);
          super.transfer(daoAccount,wadDao);
          super.transfer(dst,wad);

          return true;
        }else{
          return false;
        }
      }else if(state == 2){
        if(sort==BUY){
          uint256 wadLpPrise = wad.div(1000).mul(5);
          uint256 wadDao = wad.div(100).mul(1);

          wad = wad.sub(wadLpPrise);
          wad = wad.sub(wadDao);

          super.transfer(lpPriseAccount,wadLpPrise);
          super.transfer(daoAccount,wadDao);
          super.transfer(dst,wad);

          return true;
        }else if(sort==REMOVELIQUIDITY){
          super.transfer(dst, wad);
          return true;
        }else if(sort==TRANSFER){
          super.transfer(dst, wad);
          return true;
        }
      }

      return false;
    }

    function transferFrom(address src, address dst, uint256 wad) public returns (bool)
    { 
      if(src == controler || dst == controler || src == address(this) || dst == address(this) || src == lpPriseAccount || dst == lpPriseAccount){
        //更新LP用户列表
        addLpPlayer(src);
        return super.transferFrom(src,dst,wad);
      }

      if(isV2Pair(dst)) {
        if(!isAddLiquidity(dst,wad)){
          sort = SALE;
        }else{
          sort = ADDLIQUIDITY;
        }
      }else{
        sort = TRANSFERFROM;
      }

      if(state==0){
        return false;
      }else if(state == 1){
        return false;
      }else if(state == 2){
        if(sort==SALE){
          uint256 wadLpPrise = wad.div(1000).mul(5);
          uint256 wadDao = wad.div(100).mul(1);

          wad = wad.sub(wadLpPrise);
          wad = wad.sub(wadDao);

          super.transferFrom(src,lpPriseAccount,wadLpPrise);
          super.transferFrom(src,daoAccount,wadDao);
          super.transferFrom(src,dst,wad);

          return true;
        }else if(sort==ADDLIQUIDITY){
          super.transferFrom(src,dst,wad);
          //更新LP用户列表
          addLpPlayer(src);
          return true;
        }else if(sort==TRANSFERFROM){
          super.transferFrom(src,dst,wad);
          return true;
        }
      }

      return false;
    }

    //-----------------------------------------------------------------------------
    mapping (uint256 => address) public lpUserList;
    uint256 public lpUserListIndex = 0;
    function addLpPlayer(address to) private {
      bool have = false;
        for(uint256 i=0;i<lpUserListIndex;i++){
            if(lpUserList[i]==to){
            have = true;
            break;
            }
        }
        if(!have){
            lpUserList[lpUserListIndex++] = to;
        }
    }

    //-----------------------------------------------------------------------------
    function updateState(uint _state) public onlyControler onlySelf{
      state = _state;
    }

    function updateLpPriseAccount(address _lpPriseAccount) public onlyControler onlySelf {
        lpPriseAccount = _lpPriseAccount;
    }

    function () external payable {
        revert();
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