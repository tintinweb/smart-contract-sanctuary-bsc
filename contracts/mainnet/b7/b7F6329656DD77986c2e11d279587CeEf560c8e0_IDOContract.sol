/**
 *Submitted for verification at BscScan.com on 2022-06-29
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

interface POWER {
    function AddIDOPower(address _user, uint256 _power) external;
}

contract IDOContract is  Context,  Ownable{

    struct IDOData {
        address composerAddr;
        uint256 composeTime;
        uint256 busd;
        uint256 token;
        uint256 power;
    }

    mapping(uint256 => IDOData) public _IDOdata;
    mapping(address => uint256[]) public _userIDOdata;
    uint256 public index;
    uint256 public maxIndex;

    address public token;
    address public busd;
    address public power;
    uint256 public proportion = 100;
    uint256 public pow = 5;

    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
    );

    event IDOAdded(address indexed _composer, uint256 _token, uint256 _busd, uint256 _power);

    function getUserIDODatas(address who) public view returns (uint256[] memory){
      return _userIDOdata[who];
    }

    function SetContracts(address _token, address _busd, address _power) public onlyOwner {
        require(_token != address(0), "Cannot set to the zero address");
        require(Address.isContract(_token), "Cannot set to a non-contract address");
        require(_busd != address(0), "Cannot set to the zero address");
        require(Address.isContract(_busd), "Cannot set to a non-contract address");
        busd = _busd;
        token = _token;
        power = _power;
    }

    function SetMaxIndex(uint256 _maxIndex) public onlyOwner {
        maxIndex = _maxIndex;
    }

    function SetRouter(address _router) public onlyOwner {
        require(_router != address(0), "Cannot set to the zero address");
        require(Address.isContract(_router), "Cannot set to a non-contract address");
        uniswapV2Router = IUniswapV2Router02(_router);
    }

    function SetProportion(uint256 _proportion) public onlyOwner {
        proportion = _proportion;
    }

    function getProportion() public view returns (uint256){
        if (proportion == 0) {
            address[] memory path = new address[](2);
            path[1] = busd; path[0] = token;
            uint[] memory _price = uniswapV2Router.getAmountsOut(100 * 10**18, path);
            uint256 pariProportion = (_price[1] * 100) / _price[0];
            return pariProportion;
        }else {
            return proportion; 
        }
    }

    function SetPow(uint256 _pow) public onlyOwner {
        pow = _pow;
    }

    function AddIDO(address _composer, uint256 _token, uint256 _busd) public returns (uint256 _power){
        require(maxIndex > index, "Out Of Max Times");
        require(checkProportion(_token, _busd), "Proportion Error!");
        
        IBEP20(token).transferFrom( _composer,address(this),_token);
        IBEP20(busd).transferFrom(_composer,address(this),_busd);
        IBEP20(token).burn( _token);
        _power = _busd * pow;

        _userIDOdata[_composer].push(index);
        _IDOdata[index].composerAddr = _composer;
        _IDOdata[index].composeTime = block.timestamp;
        _IDOdata[index].busd = _busd;
        _IDOdata[index].token = _token;
        _IDOdata[index].power = _power;
        index += 1;

        POWER(power).AddIDOPower(_composer, _power);
        emit IDOAdded(_composer, _token, _busd, _power);
    }

    function WithdrawBusd() public onlyOwner{
        uint balanceBusd = IBEP20(busd).balanceOf(address(this));
        require(balanceBusd > 0, "no Busd");
        IBEP20(busd).transfer( msg.sender,balanceBusd);
    } 

    function checkProportion(uint256 _token, uint256 _busd) internal view returns (bool) {
        uint256 _proportion = (_token * 100) / _busd;
        if (proportion == 0) {
            address[] memory path = new address[](2);
            path[1] = busd; path[0] = token;
            uint[] memory _price = uniswapV2Router.getAmountsOut(100 * 10**18, path);
            uint256 pariProportion = (_price[1] * 100) / _price[0];
            return pariProportion == _proportion;
        }else {
            return proportion == _proportion; 
        }
    }
}