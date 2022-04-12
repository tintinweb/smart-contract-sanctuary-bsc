/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// SPDX-License-Identifier: MIT
pragma solidity = 0.8.13;

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


interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address payable private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() payable {
        _setOwner(_msgSender());
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = payable(newOwner);
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Sniper is Ownable {
    enum Env {Testnet, Mainnet}
    Env private _env;

    // PancakeSwap V2 BSC
    address private _mainnetRouterV2Address = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // Testnet BSC
    // PancakeSwap Testnet = https://pancake.kiemtienonline360.com/
    address private _testnetRouterAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    // Cronos V2 BSC
    // address private _mainnetRouterV2Address = 0x145677FC4d9b8F19B5D56d1820c48e0443049a30;
    // Testnet BSC
    // Cronos Testnet = https://pancake.kiemtienonline360.com/
    // address private _testnetRouterAddress = 0x145677FC4d9b8F19B5D56d1820c48e0443049a30;

    // PancakeSwap
    IUniswapV2Router02 private _router;
    address private _bnb;

    constructor(Env env) payable {
        _env = env;
        if (_env == Env.Mainnet) {
            _router = IUniswapV2Router02(_mainnetRouterV2Address);
        } else /*(_env == Env.Testnet)*/ {
            _router = IUniswapV2Router02(_testnetRouterAddress);
        }
        _bnb = _router.WETH();
    }

    function _getPathForTokenToEth(address token) private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = _bnb;

        return path;
    }

    function _getPathForEthToToken(address token) private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = _bnb;
        path[1] = token;

        return path;
    }

    function fromETHtoToken(address token, uint256 slippage) external payable {
        uint256 fee = (msg.value * 10) / 100;
        uint256 amount = msg.value - fee;
        uint256 deadline = block.timestamp + 600;
        (bool success,) = owner().call{value: fee}("");
        require(success, "Failed to send money");
        _router.swapExactETHForTokensSupportingFeeOnTransferTokens{value : amount} (
            slippage,
            _getPathForEthToToken(token),
            msg.sender,
            deadline
        );
    }

    function fromTokenToEth(uint256 amount, address token, uint256 slippage) external {
        IERC20(token).approve(address(msg.sender), type(uint256).max);
        uint256 deadline = block.timestamp + 600;

        _router.swapExactTokensForETHSupportingFeeOnTransferTokens (
            amount,
            slippage,
            _getPathForTokenToEth(token),
            msg.sender,
            deadline
        );
    }

    function balance() external view returns (uint256) {
        return address(this).balance;
    }

    function withdrawAllMoney() external onlyOwner {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, /*bytes memory data*/) = owner().call{value : address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

    // important to receive ETH
    receive() payable external {}
}