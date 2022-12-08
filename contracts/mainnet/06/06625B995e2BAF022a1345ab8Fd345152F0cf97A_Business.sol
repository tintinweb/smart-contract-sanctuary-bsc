/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.5;

interface IBEP20 {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  function burn(uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {

  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}


interface IUniswapV2Router01 {
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

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
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

interface IPowerPool {
    function AddPowerAndProfit(address _storeWallet, address _userAddr, uint256 _power, uint256 _token, uint _price) external;
    function WithdrawProfit(address who) external;
    function GetUser(address who) external view returns (uint256 power, uint256 powerUsed, uint256 profited, uint256 powerProfit);
    function tatolpower() external view returns (uint256);
}

interface IBusiness {
    function AddPowerAndProfit(address _storeWallet, address _userAddr, uint256 _power, uint256 _token, uint _price) external;
    function WithdrawProfit(address who) external;


    function isStore(address) external view returns (bool);
    function orders(uint256) external view returns (        
        string memory orderNo,   //订单号
        address createrAddr,   //下单地址
        address storeWallet,   //店铺钱包地址
        uint256 CAV,     //核销额
        uint status //状态 0,默认，待处理；1，已核销；2，拒绝核销；  
        );
    function store(address) external view returns (        
        uint256 PDbusd,     //usdt额度
        uint256 PDtoken,    //token额度
        uint256 busdUsed,     //usdt消耗
        uint256 tokenUsed,    //token消耗
        uint256 tatolCAV     //累计核销额   
        );
    function getStoresInfo() external view returns (
        uint256 _feeTokenNum, 
        uint256 _storeIndex, 
        uint256 _orderIndex, 
        uint256 _RMBTOUSDTRATE, 
        uint256 _totalCAV, 
        uint256 _deadBusd
        );
}

contract Business is  Context,  Pausable{
    using SafeMath for uint;
/*********************************************struct ******************************************************************/
    struct StoreData {
        uint256 PDbusd;     //usdt额度
        uint256 PDtoken;    //token额度
        uint256 busdUsed;     //usdt消耗
        uint256 tokenUsed;    //token消耗
        uint256 tatolCAV;     //累计核销额        
    }

    struct Order {
        string orderNo;   //订单号
        address createrAddr;   //下单地址
        address storeWallet;   //店铺钱包地址
        uint256 CAV;     //核销额
        uint status; //状态 0,默认，待处理；1，已核销；2，拒绝核销；       
    }
/********************************************mapping *****************************/
    mapping(address => bool) private isStore; 
    mapping(uint256 => Order) private orders;      
    mapping(address => StoreData) private store;    
/**********************************************values **********************************************/
    string constant public Version = "BUSINESS V0.2.3";

    uint8 private tokenDecimals;
    uint8 private busdDecimals;
    uint256 private feeTokenNum;        //成为商家支付费用
    uint256 private storeIndex;          //当前商家数
    uint256 private orderIndex;          //订单索引
    uint256 private oldOrderIndex;          //旧合约订单索引
    uint256 private RMBTOUSDTRATE;          //RMB兑USDT汇率（1RMB = ?USDT）,小数位与U的一致
    uint256 private totalCAV;          //总累计已核销额    
    uint256 private deadBusd;           //待销毁数
    uint256 private doBurnBusd = 1e8;         //触发兑换销毁数

    address private token;
    address private busd;
    address private powerAddr;          //算力合约地址
    address private oldAddr;            //旧合约地址
    address private deadWallet = 0x000000000000000000000000000000000000dEaD;
    
    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
    );
/*****************************************************events ****************************************************/
    event NewStore(address indexed _storeWallet, string _storeName, string _storeAddr);
    event NewOrder(address indexed _storeWallet, address indexed creater, string _orderNo, uint256 _orderIndex,uint256 _CAV);
    event Audited(address indexed _storeWallet, uint256 _orderIndex, uint256 _busd, uint256 _token, bool _passed);
    event PositionChange(address indexed _storeWallet, uint256 _NewPDbusd, uint256 _OldPDbusd, uint256 _NewPDtoken, uint256 _OldPDtoken);
/**************************************************** constructor *************************************/
    constructor() public {}
/**************************************************** public view function *************************************/
    //获取价格
    function getPrice(address _sellToken, address _buyToken,uint _decimals) public view returns (uint) {
        address[] memory path = new address[](2);
        path[1] = _buyToken; path[0] = _sellToken;
        uint[] memory _price = uniswapV2Router.getAmountsOut(10 ** _decimals, path);
        return _price[1];
    }
    //获取主体信息
    function getMainInfo(address _addr) public view returns (uint256 _tatolpower, uint256 _totalCAV, uint256 _power, uint256 _powerUsed, uint256 _profited, uint256 _powerProfit) {
        if(powerAddr == address(0)) return(0,totalCAV,0,0,0,0);
        _tatolpower = IPowerPool(powerAddr).tatolpower();
        (_power,_powerUsed,_profited,_powerProfit) = IPowerPool(powerAddr).GetUser(_addr);
        return (_tatolpower,totalCAV,_power,_powerUsed, _profited,_powerProfit);
    }
    //获取全局设置信息
    function getConfig() public view returns (address _powerAddr, address _token, address _busd, address _deadWallet) {
        return (powerAddr,token,busd,deadWallet);
    }
    //获取全局信息
    function getStoresInfo() public view returns (uint256 _feeTokenNum, uint256 _storeIndex, uint256 _orderIndex, uint256 _RMBTOUSDTRATE, uint256 _totalCAV, uint256 _deadBusd) {
        return (feeTokenNum,storeIndex,orderIndex,RMBTOUSDTRATE,totalCAV,deadBusd);
    }
    //获取全局其它信息
    function getOtherInfo() public view returns (address _oldAddr, uint256 _oldOrderIndex, uint256 _doBurnBusd) {
        return (oldAddr,oldOrderIndex,doBurnBusd);
    }
    //检查是否是商家
    function IsStore(address who) public view returns (bool){
        if (isStore[who]) return true;
        if (oldAddr == address(0)) return false;
        return IBusiness(oldAddr).isStore(who);
    }
    //获取商家信息
    function getStore(address who) public view returns (        
        uint256 PDbusd,     //usdt额度
        uint256 PDtoken,    //token额度
        uint256 busdUsed,     //usdt消耗
        uint256 tokenUsed,    //token消耗
        uint256 tatolCAV     //累计核销额   
        ){
        if (isStore[who]) return (store[who].PDbusd,store[who].PDtoken,store[who].busdUsed,store[who].tokenUsed,store[who].tatolCAV);
        if (oldAddr == address(0)) return (0,0,0,0,0);
        return IBusiness(oldAddr).store(who);
    }
    //获取订单信息
    function getOrder(uint256 _index) public view returns (        
        string memory orderNo,   //订单号
        address createrAddr,   //下单地址
        address storeWallet,   //店铺钱包地址
        uint256 CAV,     //核销额
        uint status //状态 0,默认，待处理；1，已核销；2，拒绝核销
        ){
        if (_index >= oldOrderIndex) return (orders[_index].orderNo,orders[_index].createrAddr,orders[_index].storeWallet,orders[_index].CAV,orders[_index].status);
        if (oldAddr == address(0)) return ("",address(0),address(0),0,0);
        (orderNo,createrAddr,storeWallet,CAV,status) = IBusiness(oldAddr).orders(_index);
        if (status == 0) status = 2;
        return (orderNo,createrAddr,storeWallet,CAV,status);
    }

/************************************************* onlyOwner Set function **********************************************/
    //设置关联合约
    function SetContracts(address _token, address _busd, address _powerAddr) public onlyOwner {
        busd = _busd;
        token = _token;
        powerAddr = _powerAddr;
        tokenDecimals = IBEP20(_token).decimals();
        busdDecimals = IBEP20(_busd).decimals();
    }
    //设置swap路由合约
    function SetRouter(address _router) public onlyOwner {
        uniswapV2Router = IUniswapV2Router02(_router);
    }
    //设置关联地址
    function SetAddress(address _deadWallet) public onlyOwner {
        deadWallet = _deadWallet;
    }
    //设置参数
    function SetFeeAndRate(uint256 _fee, uint256 _rate) public onlyOwner {
        feeTokenNum = _fee;
        RMBTOUSDTRATE = _rate;
    }
    //设置触发兑换销毁数
    function SetDoBurnBusd(uint256 _doBurnBusd) public onlyOwner {
        doBurnBusd = _doBurnBusd;
    }
    //设置旧合约地址并读入订单/商家数/汇率/商家费用
    function SetOldAddr(address _oldAddr) public onlyOwner {
        oldAddr = _oldAddr;
        (feeTokenNum,storeIndex,orderIndex,RMBTOUSDTRATE,,) = IBusiness(oldAddr).getStoresInfo();
        oldOrderIndex = orderIndex;
    }
    //从旧合约读入商家数据
    function WriteInStoreFormOldAddr(address _storeWallet) public onlyOwner {
        checkStore(_storeWallet);
    }
    //修正全局数据
    function ReplaceInfo(uint256 _totalCAV,uint256 _deadBusd) public onlyOwner {
        totalCAV = _totalCAV;
        deadBusd = _deadBusd;
    }
    //提取指定
    function WithdrawToken(address _token) public onlyOwner{
        IBEP20(_token).transfer(msg.sender,IBEP20(_token).balanceOf(address(this)));
    }
/**************************************************************public function *****************************************************************/
    //申请
    function ToBeStore(address _storeWallet, string memory _storeName, string memory _storeAddr) whenNotPaused public returns (bool) {
        require(!IsStore(_storeWallet), "storeWallet had store!");
        IBEP20(token).transferFrom(_storeWallet,deadWallet,feeTokenNum);
        isStore[_storeWallet] = true;
        storeIndex++;

        emit NewStore(_storeWallet, _storeName, _storeAddr);      
        return true;
    }
    //提额
    function AddStorePosition(address _storeWallet, uint256 _Ptoken, uint256 _Pbusd) whenNotPaused public returns (bool) {
        checkStore(_storeWallet);
        
        IBEP20(token).transferFrom(_storeWallet,address(this),_Ptoken);
        IBEP20(busd).transferFrom(_storeWallet,address(this),_Pbusd);
        store[_storeWallet].PDbusd = store[_storeWallet].PDbusd.add(_Pbusd);
        store[_storeWallet].PDtoken = store[_storeWallet].PDtoken.add(_Ptoken);

        emit PositionChange(_storeWallet, store[_storeWallet].PDbusd, store[_storeWallet].PDbusd.sub(_Pbusd), store[_storeWallet].PDtoken, store[_storeWallet].PDtoken.sub(_Ptoken));
        return true;
    }
    //减额
    function SubStorePosition(address _storeWallet, uint256 _Ptoken, uint256 _Pbusd) whenNotPaused public returns (bool) {
        checkStore(_storeWallet);

        store[_storeWallet].PDbusd = store[_storeWallet].PDbusd.sub(_Pbusd);
        store[_storeWallet].PDtoken = store[_storeWallet].PDtoken.sub(_Ptoken);
        IBEP20(token).transfer(_storeWallet,_Ptoken);
        IBEP20(busd).transfer(_storeWallet,_Pbusd);

        emit PositionChange(_storeWallet, store[_storeWallet].PDbusd, store[_storeWallet].PDbusd.add(_Pbusd), store[_storeWallet].PDtoken, store[_storeWallet].PDtoken.add(_Ptoken));
        return true;
    }
    //下核销单
    function AddOrder(address _storeWallet, string memory _orderNo, uint256 _CAV) whenNotPaused public returns (bool) {
        checkStore(_storeWallet);

        orders[orderIndex].orderNo = _orderNo;
        orders[orderIndex].createrAddr = msg.sender;
        orders[orderIndex].storeWallet = _storeWallet;
        orders[orderIndex].CAV = _CAV;       
        orderIndex++;

        emit NewOrder(_storeWallet, msg.sender, _orderNo, orderIndex - 1, _CAV);
        return true;
    }
    //核销
    function AuditingOrder(uint256 _orderIndex, bool _passed) whenNotPaused public returns (bool) {
        checkStore(msg.sender);

        require(orders[_orderIndex].storeWallet == msg.sender, "not order storeWallet!");
        require(orders[_orderIndex].status == 0, "order is audited!");
        if(!_passed){
            //fail order
            orders[_orderIndex].status = 2;
            emit Audited(msg.sender, _orderIndex, 0, 0, _passed);
        }else{
            //pass order
            passOrder(_orderIndex);            
        }
        return true;
    }
    //提取收益
    function WithdrawProfit() whenNotPaused public {
        if(deadBusd >= doBurnBusd){
            swaping(busd, token, deadBusd, deadWallet);
            deadBusd = 0;
        } 
        IPowerPool(powerAddr).WithdrawProfit(msg.sender);
    }

/****************************************************** private function **********************************************************/
    function passOrder(uint256 _orderIndex) private {
        uint price = getPrice(busd,token,busdDecimals);
        uint256 _power = orders[_orderIndex].CAV.mul(RMBTOUSDTRATE);
        uint256 _busd = _power.div(10);
        uint256 _token = _busd.mul(price).div(10 ** uint256(busdDecimals));
        //扣额度
        store[orders[_orderIndex].storeWallet].PDbusd = store[orders[_orderIndex].storeWallet].PDbusd.sub(_busd);        
        store[orders[_orderIndex].storeWallet].PDtoken = store[orders[_orderIndex].storeWallet].PDtoken.sub(_token);        
        //更新累计
        store[orders[_orderIndex].storeWallet].busdUsed = store[orders[_orderIndex].storeWallet].busdUsed.add(_busd);
        store[orders[_orderIndex].storeWallet].tokenUsed = store[orders[_orderIndex].storeWallet].tokenUsed.add(_token);
        store[orders[_orderIndex].storeWallet].tatolCAV = store[orders[_orderIndex].storeWallet].tatolCAV.add(orders[_orderIndex].CAV);
        //更新订单
        orders[_orderIndex].status = 1;
        //U留存等待兑换销毁，token分佣
        totalCAV = totalCAV.add(orders[_orderIndex].CAV); 
        deadBusd = deadBusd.add(_busd);
        IBEP20(token).transfer(powerAddr, _token);
        IPowerPool(powerAddr).AddPowerAndProfit(orders[_orderIndex].storeWallet, orders[_orderIndex].createrAddr, _power, _token, price);
        emit Audited(msg.sender, _orderIndex, _busd, _token, true);
        emit PositionChange(msg.sender, store[msg.sender].PDbusd, store[msg.sender].PDbusd.add(_busd), store[msg.sender].PDtoken, store[msg.sender].PDtoken.add(_token));
    }

    function swaping(address _sellToken, address _buyToken,  uint256 _sellAmount, address to) private {
        address[] memory path = new address[](2);
        path[0] = _sellToken; path[1] = _buyToken;
        IBEP20(_sellToken).approve(address(uniswapV2Router), _sellAmount);
        uniswapV2Router.swapExactTokensForTokens(_sellAmount,0,path,to,block.timestamp);
    } 

    function checkStore(address _storeWallet) private {
        if (!isStore[_storeWallet]){
            require(IsStore(_storeWallet), "storeWallet had not store!");
            //从旧合约写入商家数据
            writeInStore(_storeWallet);
            isStore[_storeWallet]= true;
        }
    }

    function writeInStore(address _storeWallet) private {
        if(oldAddr == address(0)) return;
        (uint256 _PDbusd,uint256 _PDtoken,uint256 _busdUsed,uint256 _tokenUsed,uint256 _tatolCAV) = IBusiness(oldAddr).store(_storeWallet);
        store[_storeWallet] = StoreData({
            PDbusd: _PDbusd,
            PDtoken: _PDtoken,
            busdUsed: _busdUsed,
            tokenUsed: _tokenUsed,
            tatolCAV: _tatolCAV
        });
    }
/****************************************************** internal view function **********************************************************/
 
}