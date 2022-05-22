/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

pragma solidity ^0.8.14;

interface IUniswapV2Router02 {
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
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function transfer(address receiver, uint256 amount) external;
    function sell(uint256 amount) external returns(bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

    event Transfer(address from, address to, uint amount);
    event Approval(address owner, address spender, uint256 value);
    event SentUSDCBackToContract(address owner, address spender, uint256 value);
}

contract myToken is IERC20, ReentrancyGuard {
    using Address for  address;

    // Token data
    string constant _name = "BSCtrader Token";
    string constant _symbol = "BTOKEN";
    uint8 constant _decimals = 0;
    uint256 _totalSupply = 0;

    // Contract deployer is owner
    address public owner;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    // Initialize Pancakeswap Router
    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    address public usdc = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;

    constructor(){
        owner = msg.sender;
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function swapForUSDC(address receiver, uint256 amount) internal {
        
        // how many Tokens did we have in this contract already
        uint256 initalTokenBalance = IERC20(usdc).balanceOf(address(this));
        
        // Uniswap Pair Path for BNB -> Token
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = usdc;
        
        // Swap BNB for Token
        uniswapV2Router.swapExactETHForTokens{value: amount}(
            0, // accept as many tokens as we can
            path,
            address(this), // Send To Recipient
            block.timestamp + 300
        );
        
        // how many tokens did we just purchase?
        uint256 balance = IERC20(usdc).balanceOf(address(this));
        uint256 tokensPurchased = balance - initalTokenBalance;
        
        // Mint the tokens
        mint(receiver, tokensPurchased);

        emit SentUSDCBackToContract(usdc, address(this), amount);
    }

    // Mint tokens to an address
    function mint(address receiver, uint256 amount) internal {
        _balances[receiver] += amount;
        _totalSupply += amount;
        emit Transfer(address(this), receiver, amount);
    }
    
    function purchase(address receiver, uint256 amount) internal returns (bool) {
        // revert if if not larger than 0
        if (amount < 0) {
            revert('Cant buy 0 tokens');
        }
        swapForUSDC(receiver, amount);
        return true;
    }

    function sell(uint256 amount) public nonReentrant returns (bool) { 
        address seller = msg.sender;
            
        // Check if seller has sufficent balance
        require(_balances[seller] >= amount, 'Insuficcent balance');

        address[] memory path = new address[](2);
        path[0] = usdc;
        path[1] = uniswapV2Router.WETH();

        //Swap usdc for bnb and send to seller
        uniswapV2Router.swapExactTokensForETH(
            amount,
            0, // accept as many tokens as we can
            path,
            seller, // Send To Recipient
            block.timestamp + 300
        );

        burn(seller, amount);

        emit Transfer(seller, address(this), amount);
        return true;
    }

    function burn(address target, uint256 amount) internal {
        _balances[target] -= amount;
        _totalSupply -= amount;
        emit Transfer(address(this), target, amount);
    }   

    function transfer(address receiver, uint amount) public {
        require(amount <= _balances[msg.sender], "Insufficient Balance");
        _balances[msg.sender] -= amount;
        _balances[receiver] += amount;
        emit Transfer(msg.sender, receiver, amount);
    }

    receive() external payable {
        address receiver = msg.sender;
        uint256 amount = msg.value;
        purchase(receiver, amount);
    }
}