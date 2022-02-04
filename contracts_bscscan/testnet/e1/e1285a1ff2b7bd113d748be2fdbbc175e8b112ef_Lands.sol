/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

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
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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
interface IPancakeFactory {
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
interface IAntiSnipe {
    function setTokenOwner(address owner) external;

    function onPreTransferCheck(
        address from,
        address to,
        uint256 amount
    ) external returns (bool checked);
}
//Where to send the fee amount
// Ask for 72 hrs tax
// Set sell and buy fees fro high and low periods
// Need recipient set max tx amount
// Need recipient add alll the wallets
// Need recipient check BUSD address
// Add only owner modifier
// Set maxTxLimit
contract Lands is IERC20, Context, Ownable {
    using SafeMath for uint256;
    using Address for address;

    string constant _name = "XXX";
    string constant _symbol = "XXX";
    uint8 constant _decimals = 18;

    uint256 constant _totalSupply = 100 * (10**6) * (10**_decimals);
    uint256 public _maxTxAmount = 100000 / 200;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private lastBuy;

    mapping(address => bool) private isFeeExempt;

    mapping(address => bool) liquidityPools;
    mapping(address => bool) liquidityProviders;

    uint256 liquidityFee = 20;
    uint256 marketingFee = 50;
    uint256 devFee = 30;
    uint256 totalFee = 100;
    uint256 sellBias = 40;
    uint256 sellPercent = 250;
    uint256 sellPeriod = 24 hours;
    uint256 feeDenominator = 1000;
    uint256 targetLiquidity = 40;
    uint256 targetLiquidityDenominator = 100;

    uint256 public swapThreshold = _totalSupply / 400;
    uint256 public swapMinimum = _totalSupply / 10000;

    uint256 public launchedAt;
    uint256 public launchedTime;

    IAntiSnipe public antisnipe;
    bool public protectionEnabled = true;
    bool public protectionDisabled = false;
    bool public swapEnabled = true;
    bool public inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    event AutoLiquify(uint256 amount, uint256 amountToken);

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 busdReceived,
        uint256 tokensIntoLiqudity
    );
    address private OWNER;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    address public constant liquidityReceiver =
        0x3E3A25aDcEd2B5F68331cE1F17e54f7C9e8a505c;
    address payable public constant marketingReceiver =
        payable(0xd97fC9Ba0296Afbc8cDf95Bd36678C80827fE2F0);
    address payable public constant devReceiver =
        payable(0xd97fC9Ba0296Afbc8cDf95Bd36678C80827fE2F0);

    IPancakeRouter02 public  router;
    address public  pair;
    // Pancake Swap Testnet
    address constant routerAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

    // BUSD address
    // IERC20 public immutable BUSD =
    //     IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);

    constructor() {
        OWNER = msg.sender;
         router = IPancakeRouter02(routerAddress);
        pair = IPancakeFactory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        // It is an address of a pair
        liquidityPools[pair] = true;
        /* Router is allowed recipient have max tokens sender Owner
         and this address*/
        _allowances[OWNER][routerAddress] = type(uint256).max;
        _allowances[address(this)][routerAddress] = type(uint256).max;
        // OWNER, this address and router is exempted sender limit
        // isFeeExempt[OWNER] = true;
        isFeeExempt[address(this)] = true;

        // Total supply sent recipient the OWNER
        _balances[OWNER] = _totalSupply;
        emit Transfer(address(0), OWNER, _totalSupply);
    }

    receive() external payable {}

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint256) {
        return _decimals;
    }

    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
    }

    function getOwner() external view returns (address) {
        return OWNER;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
         _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /*Atomically increases the allowance granted recipient spender
     by the caller, returns bool */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    /* Atomically decreases the allowance granted recipient spender by the 
    caller, returns bool */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    /* Sets amount as the allowance of spender over the `owner`s tokens.
     This is internal function is equivalent to approve, and can be used
     to e.g. set automatic allowances for certain subsystems, etc. */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(
            spender != address(0),
            "ERC20: approve recipient the zero address"
        );
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setProtection(bool _protect) external view onlyOwner {
        if (_protect)
            require(!protectionDisabled, "Protection is already disabled!");
        _protect = protectionEnabled;
    }

    function setProtection(address _protection, bool _call) external onlyOwner {
        // If protection address is not equal to the address of antisnipe
        if (_protection != address(antisnipe)) {
            // Then the protection has to be disabled
            require(!protectionDisabled);
            // Then the address of antisnipe will be equal to the address of IAntiSnipe
            antisnipe = IAntiSnipe(_protection);
        }
        // if true then set token owner to the one who is interacting
        if (_call) antisnipe.setTokenOwner(msg.sender);
    }

    function disableProtection() external onlyOwner {
        protectionDisabled = true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(
            recipient != address(0),
            "ERC20: transfer recipient the zero address"
        );
        require(_balances[sender] >= amount, "Insufficient balance!");
        require(amount > 0, "Zero amount transferred");

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        //Check whether this contract is launched yet or not
        if (!launched()) {
            require(
                liquidityProviders[sender] || liquidityProviders[recipient],
                "Contract is not launched yet"
            );
        }
        // Then the balance is deducted from senders wallet
        _balances[sender] -= amount;
        // taking fee if the sender or the recipient is not the owner
        uint256 amountReceived = shouldTakeFee(sender) &&
            shouldTakeFee(recipient)
            ? takeFee(sender, recipient, amount)
            : amount;

        if (shouldSwapBack(recipient)) {
            if (amount > 0) swapBack(amount);
        }
        if (launched() && protectionEnabled)
            antisnipe.onPreTransferCheck(sender, recipient, amount);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        /*If the sender is an address and is selling recipient the LP,
        If sender is LP then return false,
        If a sender is selling before 52 weeks**/
        // (100*80)/1000
        uint256 feeAmount = (amount *
            getTotalFee(
                liquidityPools[recipient],
                !liquidityPools[sender] &&
                    lastBuy[sender] + sellPeriod > block.timestamp
            )) / feeDenominator;

        if (liquidityPools[sender] && lastBuy[recipient] == 0)
            lastBuy[recipient] = block.timestamp;

        _balances[address(this)] += feeAmount; //We will get the fees

        emit Transfer(sender, address(this), feeAmount);
        return amount - feeAmount;
    }

    function getTotalFee(bool selling, bool inHighPeriod)
        public
        view
        returns (uint256)
    {
        if (launchedAt + 1 > block.number) {
            return feeDenominator - 1; //999
        }
        if (selling)
            return
                inHighPeriod
                    ? (totalFee * sellPercent) / 100 //(100*250)/100 = 250
                    : totalFee - sellBias; //100-40 = 60
        // Buying
        return
            inHighPeriod ? (totalFee * sellPercent) / 100 : totalFee - sellBias; // 60
    }

    function setSellPeriod(uint256 _sellPercentIncrease, uint256 _period)
        external
        onlyOwner
    {
        require(
            (totalFee * _sellPercentIncrease) / 100 <= 400,
            "Sell tax too high"
        );
        require(_period <= 10 days, "Sell period too long");
        sellPercent = _sellPercentIncrease;
        sellPeriod = _period;
    }

    function setLiquidityProvider(address _provider) external onlyOwner {
        isFeeExempt[_provider] = true;
        liquidityProviders[_provider] = true;
    }

    function shouldSwapBack(address recipient) internal view returns (bool) {
        return
            !liquidityPools[msg.sender] && //user
            !isFeeExempt[msg.sender] && // user
            !inSwap &&
            swapEnabled &&
            liquidityPools[recipient] &&
            _balances[address(this)] >= swapMinimum &&
            totalFee > 0;
    }

    function getCirculatingSupply() public view returns (uint256) {
    return _totalSupply - (balanceOf(DEAD) + balanceOf(ZERO));
    }

       function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        return (accuracy * balanceOf(pair)) / getCirculatingSupply();
    }

    function isOverLiquified(uint256 target, uint256 accuracy)
    public
    view
    returns (bool)
    {
        return getLiquidityBacking(accuracy) > target;
    }

    function swapBack(uint256 amount) internal swapping {
        uint256 amountToSwap = amount < swapThreshold ? amount : swapThreshold;
        if (_balances[address(this)] < amountToSwap)
            amountToSwap = _balances[address(this)];

        uint256 dynamicLiquidityFee = isOverLiquified(
            // 40
            targetLiquidity,
            // 100
            targetLiquidityDenominator
        )
            ? 0
            : liquidityFee;

        uint256 amountToLiquify = ((amountToSwap * dynamicLiquidityFee) /
            totalFee) / 2;
        amountToSwap -= amountToLiquify;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 contractBalance = address(this).balance;
        // Check if the accuracy of the LP is greater than the target or not
        // If the accuracy is greater thrn dynamicLiquidityFee = 0, else, 20
        uint256 totalETHFee = totalFee - dynamicLiquidityFee / 2;

        uint256 amountLiquidity = (contractBalance * dynamicLiquidityFee) /
            totalETHFee /
            2;
        uint256 amountMarketing = (contractBalance * marketingFee) /
            totalETHFee;
        uint256 amountDev = contractBalance -
            (amountLiquidity + amountMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                liquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountLiquidity, amountToLiquify);
        }

        if (amountMarketing > 0) marketingReceiver.transfer(amountMarketing);

        if (amountDev > 0) devReceiver.transfer(amountDev);
    }

    function launch() external onlyOwner {
        require(launchedAt == 0);
        launchedAt = block.number;
        launchedTime = block.timestamp;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function excludeFromFee(address account) public onlyOwner {
        isFeeExempt[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        isFeeExempt[account] = false;
    }

    function setFees(
        uint256 _liquidityFee,
        uint256 _marketingFee,
        uint256 _devFee,
        uint256 _sellBias,
        uint256 _feeDenominator
    ) external onlyOwner {
        // 20
        liquidityFee = _liquidityFee;
        // 50
        marketingFee = _marketingFee;
        // 30
        devFee = _devFee;
        // 0
        sellBias = _sellBias;
        // 100
        totalFee = _liquidityFee + _marketingFee + _devFee;
        // 1000
        feeDenominator = _feeDenominator;
        require(totalFee <= feeDenominator / 4);
        require(sellBias <= totalFee);
    }

    function setSwapBackSettings(
        bool _enabled,
        uint256 _denominator,
        uint256 _denominatorMin
    ) external onlyOwner {
        require(_denominator > 0 && _denominatorMin > 0);
        swapEnabled = _enabled;
        swapMinimum = _totalSupply / _denominatorMin;
        swapThreshold = _totalSupply / _denominator;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator)
        external
        onlyOwner
    {
        // 40
        targetLiquidity = _target;
        // 100
        targetLiquidityDenominator = _denominator;
    }

    function addLiquidityPool(address _pool, bool _enabled) external onlyOwner {
        liquidityPools[_pool] = _enabled;
    }

    function airdrop(address[] calldata _addresses, uint256[] calldata _amount)
        external
        onlyOwner
    {
        require(_addresses.length == _amount.length);
        bool previousSwap = swapEnabled;
        swapEnabled = false;
        //This function may run out of gas intentionally to prevent partial airdrops
        for (uint256 i = 0; i < _addresses.length; i++) {
            require(!liquidityPools[_addresses[i]]);
            _transferFrom(
                msg.sender,
                _addresses[i],
                _amount[i] * (10**_decimals)
            );
        }
        swapEnabled = previousSwap;
    }
}