/**
 *Submitted for verification at BscScan.com on 2022-12-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.5;


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

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
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

  function mint(uint256 amount) external returns (bool);

  function transferOwnership(address newOwner) external;

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
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

interface IReward{
  function RewardProfit(uint256 _token, uint _price) external;
  function DoReward(uint256 _token, uint _price) external;
}

interface IPowerPool {
    function tatolpower() external view returns (uint256);
}

interface IDao{
    function GetConfigParam() external view returns (
        uint256 _maxUser,
        uint256 _maxLv,
        uint256 _minValid,
        uint256 _lvUpUsed,
        uint256 _activatePoint
    );
    function GetConfigTotal() external view returns (
        uint256 _totalProForLv,    //每级份累积收益
        uint256 _totalLv, //总等级
        uint256 _totalActUsed //未结算激活销耗
    );
    function GetDaoUser(address who) external view returns (
        uint256 status, //状态
        uint256 daoLv,  //dao等级
        uint256 profit,//未提取收益
        uint256 withdawedProfit //已提取收益
    );
}

contract DistContract is  Context,  Ownable{
    using SafeMath for uint256;

    string constant public Version = "BASEDIST V1.2.0";
    address private token;
    address private busd;
    address private reward;   
    address private powerAddr;
    address private businessPower;
    address private daoReward;
    address private daoAddr;
    uint256 private eff = 2;
    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
    );
/**************************************************** constructor *************************************/
    constructor() public {}
/************************************owner function *********************************/
    function SetContracts(address _token, address _busd, address _reward, address _powerAddr) public onlyOwner {
        busd = _busd;
        token = _token;
        reward = _reward;
        powerAddr = _powerAddr;
    }

    function SetConfig(address _businessPower, address _daoReward, address _daoAddr, uint256 _eff) public onlyOwner {
        businessPower = _businessPower;
        daoReward = _daoReward;
        daoAddr = _daoAddr;
        eff = _eff;
    }

    function SetRouter(address _router) public onlyOwner {
        uniswapV2Router = IUniswapV2Router02(_router);
    }
    
    function MintAndDist(uint256 _amount, bool _hasReward, bool _hasDao, bool _hasBusiness) public onlyOwner {
        IBEP20(token).mint(_amount);
        uint price = getPrice();
        uint256 rPower = _hasReward ? IPowerPool(powerAddr).tatolpower() : 0;
        uint256 dPower = _hasDao ? getDeadPower(price) : 0;
        uint256 bPower = _hasBusiness ? IPowerPool(businessPower).tatolpower() : 0;
        uint256 totalPower = rPower.add(dPower).add(bPower);

        if(_hasReward) distProfit(reward, _amount.mul(rPower).div(totalPower), price);
        if(_hasDao) distProfit(daoReward, _amount.mul(dPower).div(totalPower), price);
        if(_hasBusiness) distProfitForApproval(businessPower, _amount.mul(bPower).div(totalPower), price);
    }

    function transferTokenOwnership(address newOwner) public onlyOwner {
        IBEP20(token).transferOwnership(newOwner);
    }
/***************************************public function *********************************************/
    function Dist(uint256 _amount, bool _hasReward, bool _hasDao, bool _hasBusiness) public returns (bool){
        IBEP20(token).transferFrom(_msgSender(), address(this), _amount);
        uint price = getPrice();

        uint256 rPower = _hasReward ? IPowerPool(powerAddr).tatolpower() : 0;
        uint256 dPower = _hasDao ? getDeadPower(price) : 0;
        uint256 bPower = _hasBusiness ? IPowerPool(businessPower).tatolpower() : 0;
        uint256 totalPower = rPower.add(dPower).add(bPower);

        if(_hasReward) distProfit(reward, _amount.mul(rPower).div(totalPower), price);
        if(_hasDao) distProfit(daoReward, _amount.mul(dPower).div(totalPower), price);
        if(_hasBusiness) distProfitForApproval(businessPower, _amount.mul(bPower).div(totalPower), price);
        return true;
    }

/********************************************** view function*****************************/
    function GetContracts() public view returns (
        address _token,
        address _busd,
        address _reward,   
        address _powerAddr
    ) { 
        return (token,busd,reward,powerAddr);
    }
    function GetConfig() public view returns (
        address _businessPower,
        address _daoReward,
        address _daoAddr,
        uint256 _eff
    ) { 
        return (businessPower,daoReward, daoAddr, eff);
    }

    function getAllDeadPower() public view returns (uint) {
        uint _price = getPrice();
        return getDeadPower(_price);
    }

    function getDeadPowerOf(address _who) public view returns (uint) {
        uint _price = getPrice();
        (,,,uint256 _lvUpUsed,) = IDao(daoAddr).GetConfigParam();
        (,uint256 daoLv,,) = IDao(daoAddr).GetDaoUser(_who);
        return daoLv.mul(_lvUpUsed).mul(_price).mul(eff).div(1e21);
    }
/***********************************************internal function*****************************/
    function getDeadPower(uint256 _price) internal view returns (uint) {
        (,,,uint256 _lvUpUsed,) = IDao(daoAddr).GetConfigParam();
        (,uint256 _totalLv,) = IDao(daoAddr).GetConfigTotal();
        return _totalLv.mul(_lvUpUsed).mul(_price).mul(eff).div(1e21);
    }

    function getPrice() internal view returns (uint) {
        address[] memory path = new address[](2);
        path[1] = busd; path[0] = token;
        uint[] memory _price = uniswapV2Router.getAmountsOut(1e18, path);
        return _price[1];
    }
/********************************private function******************************/    
    function distProfit(address _reward, uint256 _amount, uint256 _price) private {
        IBEP20(token).transfer(_reward, _amount);
        IReward(_reward).RewardProfit(_amount, _price);
    }

    function distProfitForApproval(address _reward, uint256 _amount, uint256 _price) private {
        IBEP20(token).approve(_reward, _amount);
        IReward(_reward).DoReward(_amount, _price);
    }
}