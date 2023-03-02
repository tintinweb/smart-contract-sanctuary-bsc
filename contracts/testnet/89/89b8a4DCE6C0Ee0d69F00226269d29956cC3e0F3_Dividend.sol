/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
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

library Address {

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success,) = recipient.call{ value : amount}("");
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

        (bool success, bytes memory returndata) = target.call{ value : weiValue}(data);
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

library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address tokenOwner) {
        _transferOwnership(tokenOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function createPair(address tokenA, address tokenB) external returns (address pair);
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
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface BABYTOKENDividendTracker {
    function initialize(address rewardToken_, uint256 minimumTokenBalanceForDividends_) external;
    function excludeFromDividends(address account) external;
    function updateMinimumTokenBalanceForDividends(uint256 amount) external;
    function minimumTokenBalanceForDividends() external view returns (uint256);
    function updateClaimWait(uint256 newClaimWait) external;
    function claimWait() external view returns (uint256);
    function totalDividendsDistributed() external view returns (uint256);
    function withdrawableDividendOf(address _owner) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function isExcludedFromDividends(address account) external view returns (bool);
    function getAccount(address _account) external view returns (
        address account,
        int256 index,
        int256 iterationsUntilProcessed,
        uint256 withdrawableDividends,
        uint256 totalDividends,
        uint256 lastClaimTime,
        uint256 nextClaimTime,
        uint256 secondsUntilAutoClaimAvailable
    );
    function getAccountAtIndex(uint256 index) external view returns (
        address,
        int256,
        int256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    );
    function processAccount(address payable account, bool automatic) external returns (bool);
    function getLastProcessedIndex() external view returns (uint256);
    function getNumberOfTokenHolders() external view returns (uint256);
    function setBalance(address payable account, uint256 newBalance) external;
    function process(uint256 gas) external returns (
        uint256,
        uint256,
        uint256
    );
    function distributeCAKEDividends(uint256 amount) external;
}

contract Dividend is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    string private _name;
    string private _symbol;
    uint8 private _decimals = 18;
    uint256 private _totalSupply;

    address public autoLiquidityReceiver;
    address public marketingReceiver;
    address public Dead = 0x000000000000000000000000000000000000dEaD;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => bool) public _isFeeExempt;
    bool public autoSwapBack = true;
    uint256 public swapThreshold;
    uint256 public feeDenominator = 1000;
    uint256 public liquidityShare;
    uint256 public marketingShare;
    uint256 public dividendShare;
    uint256 public totalDistributionShares;

    BABYTOKENDividendTracker public dividendTracker;
    address public rewardToken;
    uint256 public gasForProcessing;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    uint256 public inoutBurnFee;
    uint256 public inoutReserveFee;

    bool public inSwap;
    modifier swapping {
        require (inSwap == false, "ReentrancyGuard: reentrant call");
        inSwap = true;
        _;
        inSwap = false;
    }
    modifier validRecipient(address to) {
        require(to != address(0x0), "Recipient zero address");
        _;
    }

    constructor (
        string memory tokenName,
        string memory tokenSymbol,
        uint256 supply,
        address[] memory addrs,
        uint256[] memory baseFees,
        uint256 tokenBalanceForReward
        ) payable Ownable(addrs[0]) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _totalSupply = supply  * 10 ** _decimals;

        swapThreshold = _totalSupply.mul(2).div(10**6); // 0.002%

        autoLiquidityReceiver = addrs[2];
        marketingReceiver = addrs[3];

        _isFeeExempt[autoLiquidityReceiver] = true;
        _isFeeExempt[marketingReceiver] = true;
        _isFeeExempt[owner()] = true;
        _isFeeExempt[address(this)] = true;

        // use by default 300,000 gas to process auto-claiming dividends
        gasForProcessing = 300000;
        dividendTracker = BABYTOKENDividendTracker(payable(Clones.clone(addrs[5])));
        rewardToken = addrs[6];
        dividendTracker.initialize(rewardToken, tokenBalanceForReward * 10 ** _decimals);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(addrs[4]);
        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = type(uint256).max;

        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        automatedMarketMakerPairs[address(uniswapPair)] = true;

        liquidityShare = baseFees[0];
        marketingShare = baseFees[1];
        dividendShare = baseFees[2];
        totalDistributionShares = liquidityShare.add(marketingShare).add(dividendShare);
        inoutReserveFee = totalDistributionShares;
        inoutBurnFee = baseFees[3];

         // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(Dead);
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
        dividendTracker.excludeFromDividends(address(uniswapPair));

        _balances[owner()] = _totalSupply;
        payable(addrs[1]).transfer(msg.value);
        emit Transfer(address(0), owner(), _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public override validRecipient(recipient) returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override validRecipient(recipient) returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        if (shouldSwapBack()) {
            swapAndLiquify();
        }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = !inSwap && shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);

        try dividendTracker.setBalance(payable(sender), balanceOf(sender)) {} catch {}
        try dividendTracker.setBalance(payable(recipient), balanceOf(recipient)) {} catch {}

        if(!inSwap) {
            try dividendTracker.process(gasForProcessing) {} catch {}
        }

        return true;
    }

    function updateMinimumTokenBalanceForDividends(uint256 val) public onlyOwner {
        dividendTracker.updateMinimumTokenBalanceForDividends(val);
    }

    function getMinimumTokenBalanceForDividends() external view returns (uint256){
        return dividendTracker.minimumTokenBalanceForDividends();
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns(uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function withdrawableDividendOf(address account) public view returns(uint256) {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(address account) public view returns (uint256) {
        return dividendTracker.balanceOf(account);
    }

    function excludeFromDividends(address account) external onlyOwner{
        dividendTracker.excludeFromDividends(account);
    }

    function isExcludedFromDividends(address account) public view returns (bool) {
        return dividendTracker.isExcludedFromDividends(account);
    }

    function getAccountDividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccount(account);
    }

    function getAccountDividendsInfoAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccountAtIndex(index);
    }

    function processDividendTracker(uint256 gas) external {
        dividendTracker.process(gas);
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function getLastProcessedIndex() external view returns(uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "GasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "Cannot update gasForProcessing to same value");
        gasForProcessing = newValue;
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            autoSwapBack &&
            !automatedMarketMakerPairs[msg.sender] &&
            !inSwap &&
            balanceOf(address(this)) >= swapThreshold;
    }

    function manualSwap() external onlyOwner {
        require(balanceOf(address(this)) > 0, "token balance zero");
        require(!inSwap && !autoSwapBack, "swap not required");
        swapAndLiquify();
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            autoLiquidityReceiver,
            block.timestamp
        );
    }

    function swapAndLiquify() private swapping {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 liquidityTokens = contractTokenBalance.mul(liquidityShare).div(totalDistributionShares).div(2);
        uint256 swapTokens = contractTokenBalance.sub(liquidityTokens);

        swapTokensForEth(swapTokens);
        uint256 ethReceived = address(this).balance;
        uint256 totalShare = totalDistributionShares.sub(liquidityShare.div(2));
        uint256 liquidityEth = ethReceived.mul(liquidityShare).div(totalShare).div(2);
        uint256 dividendEth = ethReceived.mul(dividendShare).div(totalShare);
        uint256 marketingEth = ethReceived.sub(liquidityEth).sub(dividendEth);
        if(marketingEth > 0) {
            (bool b, ) = payable(marketingReceiver).call{value: marketingEth}("");
            if (b) {}
        }  
        if(dividendEth > 0) {
            (bool b, ) = payable(address(dividendTracker)).call{value: dividendEth}("");
            if (b) {
                dividendTracker.distributeCAKEDividends(dividendEth);
            }
        }  
        if(liquidityEth > 0 && liquidityTokens > 0) {
            addLiquidity(liquidityTokens, liquidityEth);
        }   
    }

    function shouldTakeFee(address from, address to) internal view returns (bool) {
        if (_isFeeExempt[from] || _isFeeExempt[to]) {
            return false;
        }
        return (automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]);
    }

    function setFeeExempt(address account, bool value) public onlyOwner {
        _isFeeExempt[account] = value;
    }

    function setSwapThreshold(uint256 amount) external onlyOwner {
        require(amount > 0, "not required");
        swapThreshold = amount;
    }

    function setAutoLiquidityReceiver(address account) external onlyOwner {
        autoLiquidityReceiver = account;
    }

    function setMarketingReceiver(address account) external onlyOwner {
        marketingReceiver = account;
    }

    function setAutoSwapBack(bool value) external onlyOwner {
        autoSwapBack = value;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(Dead));
    }

    function setAutomatedMarketMakerPairs(address pair, bool value) public onlyOwner {
        automatedMarketMakerPairs[pair] = value;
        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }
    }

    function changeRouterVersion(address newRouter) external onlyOwner returns(address newPair) {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouter);
        uniswapV2Router = _uniswapV2Router;
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
        _allowances[address(this)][address(uniswapV2Router)] = type(uint256).max;

        newPair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());
        if(newPair == address(0)) {
            newPair = IUniswapV2Factory(uniswapV2Router.factory())
                .createPair(address(this), uniswapV2Router.WETH());
        }

        uniswapPair = newPair; 
        automatedMarketMakerPairs[address(uniswapPair)] = true;
        dividendTracker.excludeFromDividends(uniswapPair);
    }

    function removeToken(address tokenAddress, uint256 amount) external onlyOwner {
        if (tokenAddress == address(0))
            payable(msg.sender).transfer(amount);
        else
            IERC20(tokenAddress).transfer(msg.sender, amount);
    }

    receive() external payable {}

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 feeAmount;
        uint256 burnAmount;
        uint256 receiveAmount;

        feeAmount = amount.mul(inoutReserveFee).div(feeDenominator);
        if(inoutBurnFee > 0) {
            burnAmount = amount.mul(inoutBurnFee).div(feeDenominator);
        }

        receiveAmount = amount.sub(feeAmount.add(burnAmount));

        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }
        if (burnAmount > 0) {
            _balances[Dead] = _balances[Dead].add(burnAmount);
            emit Transfer(sender, Dead, burnAmount);
        }
        return receiveAmount;
    }

    function setInOutTaxes(uint256 liquidityFee, uint256 marketingFee, uint256 dividendFee, uint256 burnFee) external onlyOwner {
        liquidityShare = liquidityFee;
        marketingShare = marketingFee;
        dividendShare = dividendFee;
        totalDistributionShares = liquidityShare.add(marketingShare).add(dividendShare);
        inoutReserveFee = totalDistributionShares;
        inoutBurnFee = burnFee; 
    }

}