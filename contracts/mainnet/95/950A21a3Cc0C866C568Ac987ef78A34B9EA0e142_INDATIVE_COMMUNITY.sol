/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

/*
INDATIVE COMMUNITY (IDT) - t.me/indativecommunity
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.15;

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
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

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDexFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

interface IDexRouter {
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

interface IPancakePair {
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

contract INDATIVE_COMMUNITY is IBEP20, Auth {
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    string _name = "INDATIVE COMMUNITY";
    string _symbol = "IDT";
    uint8 constant _decimals = 4;

    uint256 _totalSupply = 1_000_000 * (10 ** _decimals);
    uint256 public _maxTxSize = _totalSupply * 10 / 1000;     // 1% of Total Supply initially
    uint256 public _maxWalletSize = _totalSupply * 20 / 1000; // 2% of Total Supply initially

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isPair;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isWalletLimitExempt;

    uint256 buybackFee = 0;         // 0%
    uint256 marketingFee = 0;       // 0%
    uint256 liquidityFee = 0;       // 0%
    uint256 totalFee = 0;           // 0%
    uint256 feeDenominator = 1000;  // 100%
    
    address autoLiquidityReceiver;
    address marketingFeeReceiver;

    uint256 public launchedAt = 0;

    IDexRouter public router;
    address private main_pair;
    address[] private pairs;

    bool public swapEnabled = true;
    uint256 public smallSwapThreshold = _totalSupply / 1000;
    uint256 public largeSwapThreshold = _totalSupply / 500;

    uint256 public swapThreshold = smallSwapThreshold;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        if (block.chainid == 56) {
            router = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        } else if (block.chainid == 97) {
            router = IDexRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        } else revert();
        
        main_pair = IDexFactory(router.factory()).createPair(router.WETH(), address(this));
        pairs.push(main_pair);
        isPair[main_pair] = true;

        _allowances[address(this)][address(router)] = type(uint256).max;

        address deployer = msg.sender;
        marketingFeeReceiver = deployer;
        autoLiquidityReceiver = deployer;

        isFeeExempt[deployer] = true;
        isFeeExempt[address(this)] = true;
        isTxLimitExempt[deployer] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[ZERO] = true;
        isWalletLimitExempt[deployer] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[DEAD] = true;
        isWalletLimitExempt[ZERO] = true;

        _balances[deployer] = _totalSupply;
        emit Transfer(address(0), deployer, _totalSupply);
    }

    receive() external payable { }
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure returns (uint8) { return _decimals; }
    function symbol() external view returns (string memory) { return _symbol; }
    function name() external view returns (string memory) { return _name; }
    function getOwner() external view returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function viewFees() external view returns (uint256, uint256, uint256, uint256, uint256) { 
        return (buybackFee, marketingFee, liquidityFee, totalFee, feeDenominator);
    }

    function updateTokenDetails(string memory newName, string memory newSymbol) external authorized {
        _name = newName;
        _symbol = newSymbol;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (inSwap) { 
            return _basicTransfer(sender, recipient, amount);
        }

        checkTxLimit(sender, recipient, amount);

        if(shouldSwapBack()) {
            swapBack(recipient);
        }

        if (!launched() && isPair[recipient]) {
            require(_balances[sender] > 0);
            require(sender == owner, "Only the owner can be the first to add liquidity.");
            launch();
        }

        _balances[sender] = _balances[sender] - amount;

        uint256 amountReceived = amount;
        if (!isPair[sender] && !isPair[recipient] && totalFee > 0) {
            amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        }
        _balances[recipient] = _balances[recipient] + amountReceived;

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        
        return true;
    }

    function checkTxLimit(address sender, address recipient, uint256 amount) internal view {
        require(amount <= _maxTxSize || isTxLimitExempt[sender] || isTxLimitExempt[recipient] && isPair[sender], "Tx Limit Exceeded");

        if (sender != owner && recipient != owner && !isTxLimitExempt[recipient] && recipient != ZERO  && recipient != DEAD  && !isPair[recipient] && recipient != address(this)) {
            uint256 newBalance = balanceOf(recipient) + amount;
            require(newBalance <= _maxWalletSize, "Exceeds max wallet.");
        }
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[recipient];
    }

    function getTotalFee(bool) public view returns (uint256) {
        return totalFee;
    }

    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;

        //normal fee
        feeAmount = amount * getTotalFee(isPair[receiver]) / feeDenominator;
        
        _balances[address(this)] = _balances[address(this)] + feeAmount;
        emit Transfer(sender, address(this), feeAmount);

        return amount - feeAmount;
    }

    function shouldSwapBack() internal view returns (bool) {
        return !isPair[msg.sender] && !inSwap && swapEnabled && _balances[address(this)] >= swapThreshold;
    }

    function swapBack(address pair_factory) internal swapping {
        if (pair_factory == main_pair) {
            uint256 amountToLiquify = swapThreshold * liquidityFee / totalFee / 2;
            uint256 amountToSwap = swapThreshold - amountToLiquify;

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = router.WETH();

            (bool success,) = address(router).call{gas : gasleft()}(
                abi.encodeWithSignature(
                    "swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)",
                    amountToSwap,
                    0,
                    path,
                    address(this),
                    block.timestamp
                )
            );
        
            uint256 amountBNB = address(this).balance;
            uint256 amountBNBLiquidity = amountBNB / 3;

            if(amountToLiquify > 0) {
                try router.addLiquidityETH{value: amountBNBLiquidity}(
                    address(this),
                    amountToLiquify,
                    0,
                    0,
                    autoLiquidityReceiver,
                    block.timestamp
                ) {
                emit AutoLiquify(amountBNBLiquidity, amountToLiquify);

                emit SwapBackSuccess(swapThreshold);
                } catch Error(string memory e) {
                    emit SwapBackFailed(string(abi.encodePacked("SwapBack failed with error ", e)));
                } catch {
                    emit SwapBackFailed("SwapBack failed without an error message from pancakeSwap");
                }
            }

            (success,)  = payable(marketingFeeReceiver).call{value: address(this).balance, gas: 30000}("");
            require(success, "receiver rejected ETH transfer");
        }

        swapThreshold = swapThreshold == smallSwapThreshold ? largeSwapThreshold : smallSwapThreshold;
    }

    function setSwapBackSettings(bool _enabled, uint256 _smallAmount, uint256 _largeAmount) external authorized {
        swapEnabled = _enabled;
        smallSwapThreshold = _smallAmount;
        largeSwapThreshold = _largeAmount;
        require(smallSwapThreshold <= 7500000000 && largeSwapThreshold <= 10000000000, "Swap Threshold must be lower");
    }

    function triggerManualBuyback(uint256 amountBNB) external authorized {
        buyTokens(amountBNB, DEAD);
    }

    function buyTokens(uint256 amountBNB, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountBNB}(
            0,
            path,
            to,
            block.timestamp
        );
    }

    function ChangeMaxTxSize(uint256 percent, uint256 denominator) external authorized { 
        require(percent >= 1 && denominator >= 1000, "Max tx must be greater than 0.1%");
        _maxTxSize = _totalSupply * percent / denominator;
    }
    
    function ChangeMaxWallet(uint256 percent, uint256 denominator) external authorized {
        require(percent >= 5 && denominator >= 1000, "Max wallet must be greater than 0.5%");
        _maxWalletSize = _totalSupply * percent / denominator;
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsWalletLimitExempt(address holder, bool exempt) external authorized {
        isWalletLimitExempt[holder] = exempt;
    }

    function adjustFees(uint256 _buybackFee, uint256 _liquidityFee, uint256 _marketingFee, uint256 _feeDenominator) external authorized {
        buybackFee = _buybackFee;
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        totalFee = _liquidityFee + _marketingFee;
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator / 10); // totalFee must be less than 10%
    }
    
    function resetFees() external authorized {
        buybackFee = 0;         //0%
        liquidityFee = 0;      //6%
        marketingFee = 0;      //6%
        totalFee = buybackFee + liquidityFee + marketingFee;
        feeDenominator = 1000;  //100%
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - balanceOf(DEAD) - balanceOf(ZERO);
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    // Recover any BNB sent to the contract by mistake.
	function rescue() external authorized {
        payable(marketingFeeReceiver).transfer(address(this).balance);
    }

    function rescueToken(address _token) external authorized {
        uint256 amount = IBEP20(_token).balanceOf(address(this));
        require(_token != address(this), "STOP");
        require(IBEP20(_token).balanceOf(address(this)) > 0, "No tokens");

        IBEP20(_token).transfer(marketingFeeReceiver, amount);
    }

    function createPair(address token) external authorized {
        address new_pair = IDexFactory(router.factory()).createPair(token, address(this));
        isPair[main_pair] = true;

        pairs.push(new_pair);
    }

    function showPairList() public view returns(address[] memory){
        return pairs;
    }

    event SwapBackSuccess(uint256 amount);
    event SwapBackFailed(string message);
    event AutoLiquify(uint256 amountBNB, uint256 amountToken);
}