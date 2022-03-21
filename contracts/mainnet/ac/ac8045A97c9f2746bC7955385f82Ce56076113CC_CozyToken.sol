/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
contract Owner {

    address private owner;
    address private previousOwner;
    uint256 private ownerUnlockTime = 7 days;
    uint256 private newOwnerTimestamp;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == getOwner(), "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        previousOwner = msg.sender;
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        newOwnerTimestamp = block.timestamp;
        previousOwner = getOwner();
        owner = newOwner;
        
        emit OwnerSet(previousOwner, newOwner);

    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() internal view returns (address) {
        if((block.timestamp - newOwnerTimestamp) > ownerUnlockTime) {
            return owner; 
        } else {
            return previousOwner;
        }
    }
    
    function getOwnerExternal() public view returns (address) {
        return getOwner();
    }
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

contract CozyToken is IBEP20, Owner {

    address cozyFundWallet;

    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    struct TransactionInfo {
        uint256 amount;
        uint256 endTime;
    }

    string _name = "Cozy";
    string constant _symbol = "COZY";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 10**12 * (10 ** _decimals);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;

    
    uint256 _buyFee = 100; // 1%
    uint256 _sellFee = 100; // 1%
    uint256 feeDenominator = 10000;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool hasTradingEnable = false;

    bool public swapEnabled = true;
    bool inSwap;
    modifier swapping() { 
        inSwap = true; 
        _; 
        inSwap = false; 
        
    }
    
    event BasicTransfer(address sender, address recipient, uint256 amount);
    event SwapCozyForWBNB(uint256 comfySwapped, uint256 WBNBReceived);
    event SwapWBNBForBUSD(uint256 amount);

    constructor () {
        
        uniswapV2Router = IUniswapV2Router02(routerAddress);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(uniswapV2Router.WETH(), address(this));

        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;
        WBNB = uniswapV2Router.WETH();

        isFeeExempt[msg.sender] = true;

        approve(address(uniswapV2Pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply; 
        
    }
    
    function decimals() external pure override returns (uint8) {
        return _decimals; 
    }
    
    function symbol() external pure override returns (string memory) { 
        return _symbol;
    }
    
    function name() external view override returns (string memory) {
        return _name;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != _totalSupply){
            require(_allowances[sender][msg.sender] >= amount, "Insufficient Allowance");
            _allowances[sender][msg.sender] -= amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(isTradingEnabled(sender, recipient), "Token not launched yet");
        require(balanceOf(sender) >= amount, "Insufficient balance");
        
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if(shouldSwapCozyForWBNB(recipient)) {
            swapCozyForWBNB();
        }

        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        
        _balances[sender] -= amount;
        _balances[recipient] += amountReceived;

        emit Transfer(sender, recipient, amountReceived);
        
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        
        emit BasicTransfer(sender, recipient, amount);
        return true;
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        bool _takeFee = true;
        if(isFeeExempt[sender] || isFeeExempt[recipient]) {
            _takeFee = false;
        }
        if(sender != uniswapV2Pair && recipient != uniswapV2Pair) {
            _takeFee = false;
        }

        return _takeFee;
    }

    function getTotalFee(bool selling) public view returns (uint256) {
        if (selling) {
            return _sellFee;
        }
        return _buyFee;
    }
    
    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        bool isSelling = receiver == uniswapV2Pair;
        uint256 feeAmount = (amount * getTotalFee(isSelling)) / feeDenominator;

        _balances[address(this)] += feeAmount;
        emit Transfer(sender, address(this), feeAmount);

        return amount - feeAmount;
    }

    function shouldSwapCozyForWBNB(address recipient) internal view returns (bool) {
        return !inSwap
               && swapEnabled
               && hasTradingEnable
               && recipient == uniswapV2Pair
               && balanceOf(address(this)) > 0;
    }

    function swapCozyForWBNB() internal swapping {
        
        uint256 amountToSwap = balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        approve(address(uniswapV2Router), amountToSwap);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 WBNBBalance = address(this).balance;
        
        emit SwapCozyForWBNB(amountToSwap, WBNBBalance);
        
        swapWBNBForBUSD(WBNBBalance);
        
    }
    
    function swapWBNBForBUSD(uint256 wBNBAmount) internal {

        IBEP20 BUSDToken = IBEP20(BUSD);

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = BUSD;

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: wBNBAmount}(
            0,
            path,
            address(this),
            block.timestamp
        );
        
        
        uint256 busdAmount = BUSDToken.balanceOf(address(this));

        require(BUSDToken.transfer(cozyFundWallet, busdAmount), "Error while sending tokens to CozyFund wallet");
        
        emit SwapWBNBForBUSD(busdAmount);
    }
    
    function isTradingEnabled(address sender, address recipient) internal view returns (bool) {
        return hasTradingEnable || getOwner() == sender || getOwner() == recipient || isFeeExempt[sender] || isFeeExempt[recipient];
    }

    function launch() external onlyOwner {
        require(!hasTradingEnable, "Already launched");
        hasTradingEnable = true;
    }

    function stopTrading() external onlyOwner {
        require(hasTradingEnable, "Trading is already disabled");
        hasTradingEnable = false;
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setFees(uint256 buyFee, uint256 sellFee) external onlyOwner {
        require(buyFee <= 5000, "Exceeding max buy fee!"); // 50% max
        require(sellFee <= 5000, "Exceeding max sell fee!"); // 50% max
        _buyFee = buyFee;
        _sellFee = sellFee;
        
    }

    function setCozyFundAddress(address contractAddress) external onlyOwner {
        cozyFundWallet = contractAddress;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - balanceOf(DEAD) - balanceOf(ZERO);
    }


    /*
    UPDATE PANCAKESWAP ROUTER AND LIQUIDITY PAIRING
    */


    // Set new router and make the new pair address
    function setNewRouterAndMakePair(address _newRouter) public onlyOwner {
        uniswapV2Router = IUniswapV2Router02(_newRouter);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(uniswapV2Router.WETH(), address(this));
        approve(routerAddress, _totalSupply);
        approve(address(uniswapV2Pair), _totalSupply);
    }
   
    // Set new router
    function setNewRouterAddress(address _newRouter) public onlyOwner {
        IUniswapV2Router02 newRouter = IUniswapV2Router02(_newRouter);
        uniswapV2Router = newRouter;
        approve(routerAddress, _totalSupply);
    }
    
    // Set new address - This will be the 'Cake LP' address for the token pairing
    function setNewPairAddress(address newPair) public onlyOwner {
        uniswapV2Pair = newPair;
        approve(address(uniswapV2Pair), _totalSupply);
    }
}