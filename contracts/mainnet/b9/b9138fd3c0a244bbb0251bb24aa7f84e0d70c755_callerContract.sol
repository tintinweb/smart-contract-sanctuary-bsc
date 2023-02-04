// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;
import "./IPancakeRouter02.sol";
import "./IERC20.sol";

contract callerContract{
    uint256 public value;
    address public sender;
    string  public name;
    bool    public callSuccess;
    event teste(string retorno);
    constructor() payable{
  
    }
    receive() external payable{

    }
    function swapTokensForTokensToCreator(address router, uint256 tokenAmount, address _token, address _tokenReceive) public  {
        IERC20(_token).approve(router, tokenAmount);
        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = _tokenReceive;
        IERC20(_token).approve(router, tokenAmount);
        IPancakeRouter02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function swapTokensForEthToCreator(address router, uint256 _tokenAmount, address _token) public {
        IERC20(_token).approve(router, _tokenAmount);
        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = IPancakeRouter02(router).WETH();
        IERC20(_token).approve(router, _tokenAmount);
        IPancakeRouter02(router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            _tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }
    function swapEthForTokensToCreator(address router, uint256 _tokenAmount, address _token) public {
        address[] memory path = new address[](2);
        path[0] = IPancakeRouter02(router).WETH();
        path[1] = _token;
        IERC20(_token).approve(router, _tokenAmount);
        IPancakeRouter02(router).swapExactETHForTokensSupportingFeeOnTransferTokens{value:_tokenAmount}(
            0, 
            path,
            address(this),
            block.timestamp
        );
    }
    function destroy() public{
        selfdestruct(payable(msg.sender));
    }
}

contract targetContractDelegate{
    
    address public sender;
    uint256 public value;
    string  public name;
    address public senderLocal;
    
    event Test(uint value, address sender, string texto);

    function targetFunction(string memory _nameTarget) public payable{
        if(bytes(_nameTarget).length > 10){
            require(false, "Erro do destino");
        }
        emit Test(msg.value, msg.sender, _nameTarget);
    }
    function targetFunction2(string memory _nameTarget) public payable{
        emit Test(msg.value, msg.sender, _nameTarget);
    }
    function buyToken(address pancakeRouter, address token0, address token1, uint256 amount) public{
        (bool success, bytes memory return_data) = pancakeRouter.delegatecall(abi.encodeWithSelector(IPancakeRouter02.swapExactTokensForTokensSupportingFeeOnTransferTokens.selector,
            amount,
            0,
            [token0, token1],
            msg.sender,
            block.timestamp)
        );
        if(!success){
            if(return_data.length > 0){
                /// @solidity memory-safe-assembly
                assembly {
                    let return_data_size := mload(return_data)
                    revert(add(32,return_data),return_data_size)
                }
            }else {
                revert("Error at rebuy with StableCoin");
            }
        }
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2;
import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
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

//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2;

interface IPancakeRouter01 {
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