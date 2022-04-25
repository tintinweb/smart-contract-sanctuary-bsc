/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

pragma solidity ^0.6.0;

// SPDX-License-Identifier: UNLICENSED

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode
        return msg.data;
    }
}

//OWnABLE contract that define owning functionality
contract Ownable {
  address public owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
  constructor() public {
    owner = msg.sender;
  }

  /**
    * @dev Throws if called by any account other than the owner.
    */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeERC20 {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(token.approve(spender, value));
    }
}

//UNISWAP INTERFACE
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface ITIER{
    function mint(address _to, uint _level) external;
    function cost(uint _tierLevel) external view returns(uint);
}

interface IGELVN{
    function totalAvailableBalance(address _owner) external view returns(uint);
    function unvestedPayment(address _owner,uint _cost) external;
    function approve(address _spender, uint _amount) external;
    function swapFromOriginal(uint _amount) external;
}

contract NFTMinter is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public ERC20Interface;
    address public tokenAddress;
    address public ELVNAddress;
    address public tierAddress;
    address public gELVNAddress;

    //Swap Variables
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    event SwappedAndLiquified(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    // CONSTRUCTOR
    constructor() public { 
        tokenAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        ELVNAddress = 0xE8DE5e3689c42729CE53BB950FfF2e625Ccf23A7;
        gELVNAddress = 0x6a0CC3C5110E6a4e6F01dC2450D30c2fbDf28d5c;
        tierAddress = 0xFC584f0f4691CDb08a447D8e9249aeFBd7a84e9E;

        //UniSwap
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = 0x6d7e6558e57DFf6555192564C994337414b5cDAF;
        uniswapV2Router = _uniswapV2Router;
    }

    function missingBalanceBusd(address _owner, uint _tierLevel) public view returns(uint _missingBusd){
        uint _elvnBalance = IERC20(ELVNAddress).balanceOf(_owner);
        uint _gelvnBalance = IGELVN(gELVNAddress).totalAvailableBalance(_owner);
        uint _totalAvailableBalance = _elvnBalance + _gelvnBalance;
        uint _cost = ITIER(tierAddress).cost(_tierLevel);
        if(_totalAvailableBalance >= _cost){
            _missingBusd = 0;
        }
        else{
            _missingBusd = amountsIn(_cost-_totalAvailableBalance);
        }
        return _missingBusd;
    }

    function amountsIn(uint _amount) public view returns(uint){
        address[] memory path = new address[](2);
        path[0] = tokenAddress;
        path[1] = ELVNAddress;
        uint[] memory _busdAmount = uniswapV2Router.getAmountsIn(_amount,path);
        return _busdAmount[0];
    }

    function swapMint(uint _tierLevel) public {
        uint _elvnBalance = IERC20(ELVNAddress).balanceOf(msg.sender);
        uint _gelvnBalance = IGELVN(gELVNAddress).totalAvailableBalance(msg.sender);
        uint _totalAvailableBalance = _elvnBalance + _gelvnBalance;
        uint _cost = ITIER(tierAddress).cost(_tierLevel);
        require(_totalAvailableBalance >= _cost,"Not enough ELVN/gELVN");
        if(_gelvnBalance >= _cost){
            IGELVN(gELVNAddress).unvestedPayment(msg.sender, _cost);
            ITIER(tierAddress).mint(msg.sender, _tierLevel);
        }
        else{
            uint swapAmount = _cost - _gelvnBalance;
            IERC20(ELVNAddress).transferFrom(msg.sender, address(this), swapAmount);
            IERC20(ELVNAddress).approve(gELVNAddress,swapAmount);
            IGELVN(gELVNAddress).swapFromOriginal(swapAmount);
            IGELVN(gELVNAddress).unvestedPayment(msg.sender, _gelvnBalance);
            ITIER(tierAddress).mint(msg.sender, _tierLevel);
        }
    }

    function busdMint(uint _tierLevel) public {
        uint _missingBalance = missingBalanceBusd(msg.sender,_tierLevel);
        require(_missingBalance > 0,"You got enough ELVN/gELVN, no need to mint with BUSD");
        require(_missingBalance <= IERC20(tokenAddress).balanceOf(msg.sender), "You don't have enough BUSD");
        uint _elvnBalance = IERC20(ELVNAddress).balanceOf(msg.sender);
        uint _gelvnBalance = IGELVN(gELVNAddress).totalAvailableBalance(msg.sender);
        uint _cost = ITIER(tierAddress).cost(_tierLevel);

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _missingBalance);
        swapStableForToken(_cost - _elvnBalance - _gelvnBalance,msg.sender);
        
        IERC20(ELVNAddress).transferFrom(msg.sender, address(this), _elvnBalance);
        IERC20(ELVNAddress).approve(gELVNAddress,_elvnBalance);
        IGELVN(gELVNAddress).swapFromOriginal(_elvnBalance);
        IGELVN(gELVNAddress).unvestedPayment(msg.sender, _gelvnBalance);

        ITIER(tierAddress).mint(msg.sender, _tierLevel);
    }

    function swapStableForToken(uint256 _tokenAmount, address _receiver) private {
        
        address[] memory path = new address[](2);
        path[0] = tokenAddress;
        path[1] = ELVNAddress;

        
        uint _busdBalance = amountsIn(_tokenAmount) * 110 / 100;
        IERC20(tokenAddress).approve(uniswapV2Pair, _busdBalance);
        // make the swap
        uniswapV2Router.swapTokensForExactTokens(
            _tokenAmount,
            _busdBalance, // accept any amount
            path,
            _receiver,
            block.timestamp
        );
    }

    function withdraw(address _tokenAddress, uint _amount) external onlyOwner  {
        IERC20 tokenContract = IERC20(_tokenAddress);
        tokenContract.transfer(msg.sender, _amount);
    }
}