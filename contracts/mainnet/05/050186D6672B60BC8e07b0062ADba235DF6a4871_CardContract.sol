/**
 *Submitted for verification at BscScan.com on 2022-10-28
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

interface Reward {
    function AddCardPower(address _user, uint256 _power) external;
    function NewCardProfit(address _composer, uint256 _token, uint256 _busd, uint _price) external;
}

contract CardContract is  Context,  Ownable{
    using SafeMath for uint256;
    struct CardData {
        address composerAddr;
        uint256 composeTime;
        uint256 busd;
        uint256 token;
        uint256 power;
    }

    mapping(uint256 => CardData) public _carddata;
    mapping(address => uint256[]) public _usercarddata;
    uint256 public index;

    mapping(address => uint256) public _lastTime;
    uint256 public perTime = 24 * 3600;
    uint256 public pNumerator = 100;    //token
    uint256 public pDenominator = 100;  //busd
    uint256 public ammPoint = 50;
    bool public addLiquidity = false;
    uint256 public profitPoint = 900;
    address public token;
    address public buytoken;
    address public busd;
    address public reward;
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
    );

    event Composed(address indexed _composer, uint256 _token, uint256 _busd, uint256 _pow, uint256 _power, uint liquidity);

    function getUserCardDatas(address who) public view returns (uint256[] memory){
      return _usercarddata[who];
    }

    function SetContracts(address _token, address _busd, address _reward) public onlyOwner {
        busd = _busd;
        token = _token;
        reward = _reward;
    }

    function SetCompose(address _buytoken, uint256 _profitPoint, bool _addLiquidity) public onlyOwner {
        require(_buytoken != address(0), "Cannot set to the zero address");
        require(Address.isContract(_buytoken), "Cannot set to a non-contract address");
        require(_profitPoint <= 1000, "ProfitPoint Must 0 to 1000");
        buytoken = _buytoken;
        profitPoint = _profitPoint;
        addLiquidity = _addLiquidity;
    }

    function SetRouter(address _router) public onlyOwner {
        require(_router != address(0), "Cannot set to the zero address");
        require(Address.isContract(_router), "Cannot set to a non-contract address");
        uniswapV2Router = IUniswapV2Router02(_router);
    }

    function SetProportion(uint256 _numerator, uint256 _denominator) public onlyOwner {
        pNumerator = _numerator;
        pDenominator = _denominator;
    }

    function SetAmmPoint(uint256 _ammPoint) public onlyOwner {
        require(_ammPoint <= 1000, "AmmPoint Must 0 to 1000");
        ammPoint = _ammPoint;
    }

    function getProportion() public view returns (uint256 numerator, uint256 denominator){
        if (pNumerator == 0 || pDenominator == 0) {
            address[] memory path = new address[](2);
            path[1] = busd; path[0] = token;
            uint[] memory _price = uniswapV2Router.getAmountsOut(100 * 10**18, path);
            return (_price[0], _price[1]);
        }else {
            return (pNumerator, pDenominator); 
        }
    }

    function SetPerTime(uint256 _perTime) public onlyOwner {
        perTime = _perTime;
    }

    function Compose(address _composer, uint256 _token, uint256 _busd) internal returns (uint256 _pow, uint256 _power){
        require(block.timestamp >= (_lastTime[_composer] + perTime), "waitting Time End!");

        IBEP20(token).transferFrom( _composer,address(this),_token);
        IBEP20(busd).transferFrom(_composer,address(this),_busd);
        uint liquidity = 0;
        uint burntoken = _token;
        uint swapBusd = _busd;
        if (addLiquidity) {
            (burntoken, swapBusd, liquidity) = checkAddLiquidity(_token, _busd);
        }
        
        IBEP20(token).transfer(deadWallet,burntoken);

        uint price = getPrice();
        _pow = random();
        _power = _busd * _pow;
        Reward(reward).AddCardPower(_composer, _power);

        uint porfit = swaping(swapBusd);

        if (porfit > 0){
            IBEP20(buytoken).transfer(reward, porfit);
            Reward(reward).NewCardProfit(_composer, porfit, _busd, price);
        }

        _lastTime[_composer] = block.timestamp;

        _usercarddata[_composer].push(index);
        _carddata[index].composerAddr = _composer;
        _carddata[index].composeTime = block.timestamp;
        _carddata[index].busd = _busd;
        _carddata[index].token = _token;
        _carddata[index].power = _power;
        index += 1;
        
        emit Composed(_composer, _token, _busd, _pow, _power, liquidity);
    } 

    function composeCardFormBusd(uint256 _busd) public returns (uint256 _pow, uint256 _power) {
        (uint256 numerator, uint256 denominator) = getProportion();
        uint256 _token = _busd.mul(numerator).div(denominator);
        (_pow,_power)=Compose(msg.sender, _token, _busd);
    }

    function WithdrawToken(address _token) public onlyOwner{
        uint256 tokenvalue = IBEP20(_token).balanceOf(address(this));
        require(tokenvalue > 0, "no token");
        IBEP20(_token).transfer(msg.sender,tokenvalue);
    } 

    function checkAddLiquidity(uint256 _token, uint256 _busd) internal returns (uint,uint,uint) {       
        uint addbusd = _busd * ammPoint / 1000;
        if (addbusd > 0 ) {
            IBEP20(busd).approve(address(uniswapV2Router), addbusd);
            IBEP20(token).approve(address(uniswapV2Router), _token);
            (uint amountA, uint amountB, uint liquidity) = uniswapV2Router.addLiquidity(busd, token, addbusd , _token, 0, 0, owner(), block.timestamp);
            require(amountA == addbusd, "AddLiquidity Error!");
            return ( _token - amountB, _busd - addbusd , liquidity);
        }
        else{
            return ( _token, _busd, 0);
        }
    }

    function swaping(uint256 _busd) internal returns (uint) {
        address[] memory path = new address[](2);
        path[0] = busd; path[1] = buytoken;
        IBEP20(busd).approve(address(uniswapV2Router), _busd);
        uint balanceBefore = IBEP20(buytoken).balanceOf(address(this));
        uniswapV2Router.swapExactTokensForTokens(_busd,0,path,address(this),block.timestamp);

        uint balanceAfter = IBEP20(buytoken).balanceOf(address(this));

        return (balanceAfter - balanceBefore) *  profitPoint / 1000;
    }

    function getPrice() internal view returns (uint) {
        address[] memory path = new address[](2);
        path[1] = busd; path[0] = buytoken;
        uint[] memory _price = uniswapV2Router.getAmountsOut(100 * 10**18, path);
        return _price[1];
    }

    function random() internal view returns (uint256 pow) {
        uint256 size;
        size = uint256(keccak256(abi.encodePacked(block.timestamp,block.difficulty))) % 100;
        if (size <= 30) {
            pow = 12; 
        }else if (size <= 50){
            pow = 14; 
        }else if (size <= 65){
            pow = 16; 
        }else if (size <= 75){
            pow = 18; 
        }else if (size <= 80){
            pow = 20; 
        }else if (size == 85){
            pow = 22; 
        }else if (size == 90){
            pow = 24; 
        }else if (size == 95){
            pow = 26; 
        }else if (size == 99){
            pow = 28; 
        }else {
            pow = 0;
        }
    }

    function checkProportion(uint256 _token, uint256 _busd) internal view returns (bool) {
        if (pNumerator == 0 || pDenominator == 0) {
            address[] memory path = new address[](2);
            path[1] = busd; path[0] = token;
            uint[] memory _price = uniswapV2Router.getAmountsOut(100 * 10**18, path);
            return _price[1].mul(_token) == _price[0].mul(_busd);
        }else {
            return pNumerator.mul(_busd) == pDenominator.mul(_token); 
        }
    }
}