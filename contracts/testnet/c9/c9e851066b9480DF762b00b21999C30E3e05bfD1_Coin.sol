/**
 *Submitted for verification at BscScan.com on 2023-02-14
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

interface InterfaceLP {
    function sync() external;
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

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract Coin is Context, IERC20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    address public autoLiquidityReceiver;
    address payable public marketingReceiver;
    address payable public teamReceiver;
    address public Dead = 0x000000000000000000000000000000000000dEaD;

    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping (address => bool) public _isFeeExempt;
    mapping (address => bool) public automatedMarketMakerPairs;
    address[] public markerPairs;
    bool public autoRebase = true;
    bool public autoSwapBack = true;
    bool public swapMode; 
    uint256 public lastSwapTime;
    uint256 public swapInterval = 30 minutes;
    uint256 public swapThreshold;
    uint256 public minCirculation;
    uint256 public kiloDenominator = 1000;
    uint256 public liquidityShare;
    uint256 public marketingShare;
    uint256 public teamShare;
    uint256 public totalDistributionShares;

    uint256 public rewardYield; // compound n% per day
    uint256 public rewardYieldDenominator = 10**10;
    uint256 public startTradingTime;
    uint256 public rebaseInterval;
    uint256 public lastRebasedTime;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint256 public MAX_SUPPLY = MAX_UINT256;
    uint256 public TOTAL_GONS;
    uint256 public gonsPerFragment;

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
        uint8 tokenDecimals,
        uint256 supply,
        uint256[] memory compounds,   
        address[] memory addressArray, 
        uint256[] memory baseFees
        ) payable Ownable(addressArray[0]) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = tokenDecimals;
        _totalSupply = supply  * 10 ** _decimals;
        TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % _totalSupply);
        gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        rewardYield = compounds[0];
        rebaseInterval = compounds[1];

        minCirculation = 1 * 10**_decimals;
        swapThreshold = 1 * 10**_decimals;

        autoLiquidityReceiver = addressArray[3];
        marketingReceiver = payable(addressArray[4]);
        teamReceiver = payable(addressArray[5]);

        _isFeeExempt[autoLiquidityReceiver] = true;
        _isFeeExempt[marketingReceiver] = true;
        _isFeeExempt[teamReceiver] = true;
        _isFeeExempt[owner()] = true;
        _isFeeExempt[address(this)] = true;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(addressArray[1]);
        uniswapV2Router = _uniswapV2Router;
        _allowedFragments[address(this)][address(uniswapV2Router)] = type(uint256).max;
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        setAutomatedMarketMakerPairs(uniswapPair, true);

        liquidityShare = baseFees[0];
        marketingShare = baseFees[1];
        teamShare = baseFees[2];
        totalDistributionShares = liquidityShare.add(marketingShare).add(teamShare);
        inoutReserveFee = totalDistributionShares;
        inoutBurnFee = baseFees[3];

        _gonBalances[owner()] = TOTAL_GONS;
        payable(addressArray[2]).transfer(msg.value);
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
        return _gonBalances[account].div(gonsPerFragment);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowedFragments[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowedFragments[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowedFragments[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
  
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowedFragments[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public override validRecipient(recipient) returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override validRecipient(recipient) returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowedFragments[sender][_msgSender()] != type(uint256).max) {
            _approve(sender, _msgSender(), _allowedFragments[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        }
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        if(inSwap){
            return _basicTransfer(sender, recipient, amount);
        }

        if (shouldRebase() && 
        !automatedMarketMakerPairs[msg.sender] &&
        autoRebase) {
            _rebase();
            manualSync();
        }

        if (shouldSwapBack()) {
            swapAndLiquify();
            if (!swapMode) {
                lastSwapTime = block.timestamp;
            } 
        }
        uint256 gonAmount = amount.mul(gonsPerFragment);
        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount, "Insufficient Balance");
        uint256 gonAmountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, gonAmount) : gonAmount;
        _gonBalances[recipient] = _gonBalances[recipient].add(gonAmountReceived);
        emit Transfer(sender, recipient, gonAmountReceived.div(gonsPerFragment));

        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        uint256 gonAmount = amount.mul(gonsPerFragment);
        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount, "Insufficient Balance");
        _gonBalances[recipient] = _gonBalances[recipient].add(gonAmount);
        emit Transfer(sender, recipient, amount);

        return true;
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            autoSwapBack &&
            !automatedMarketMakerPairs[msg.sender] &&
            !inSwap &&
            balanceOf(address(this)) > 0 &&
            (!swapMode && block.timestamp >= (lastSwapTime + swapInterval) || 
            swapMode && balanceOf(address(this)) >= swapThreshold);
    }

    function manualSwap() external onlyOwner {
        require(!inSwap && !autoSwapBack, "Swap not required");
        swapAndLiquify();
    }

    function swapAndLiquify() private swapping {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 liquidityTokens = contractTokenBalance.mul(liquidityShare).div(totalDistributionShares).div(2);
        uint256 swapTokens = contractTokenBalance.sub(liquidityTokens);

        swapTokensForEth(swapTokens);
        uint256 ethReceived = address(this).balance;
        uint256 totalShare = totalDistributionShares.sub(liquidityShare.div(2));
        uint256 liquidityEth = ethReceived.mul(liquidityShare).div(totalShare).div(2);
        uint256 teamEth = ethReceived.mul(teamShare).div(totalShare);
        uint256 marketingEth = ethReceived.sub(liquidityEth).sub(teamEth);
        if(marketingEth > 0) {
            transferEth(marketingReceiver, marketingEth);
        }  
        if(teamEth > 0) {
            transferEth(teamReceiver, teamEth);
        }  
        if(liquidityEth > 0 && liquidityTokens > 0) {
            addLiquidity(liquidityTokens, liquidityEth);
        }  
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
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

    function transferEth(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
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

    function setMinCirculation(uint256 amount) public onlyOwner {
        minCirculation = amount;
    }

    function setSwapThreshold(uint256 amount) external onlyOwner {
        swapThreshold = amount;
    }

    function setAutoLiquidityReceiver(address account) external onlyOwner {
        autoLiquidityReceiver = payable(account);
    }

    function setMarketingReceiver(address account) external onlyOwner {
        marketingReceiver = payable(account);
    }

    function setTeamReceiver(address account) external onlyOwner {
        teamReceiver = payable(account);
    }

    function setAutoSwapBack(bool value) external onlyOwner {
        autoSwapBack = value;
    }

    function setSwapMode(bool value) external onlyOwner {
        swapMode = value;
        if (!swapMode) {
            lastSwapTime = block.timestamp;
        }
    }

    function setSwapInterval(uint256 time) external onlyOwner {
        require(time > 0, "invalid time");
        swapInterval = time;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (TOTAL_GONS.sub(_gonBalances[Dead])).div(gonsPerFragment);
    }
  
    function shouldRebase() public view returns (bool) {
        return !inSwap &&
            _totalSupply < MAX_SUPPLY && 
            lastRebasedTime > 0 && 
            block.timestamp >= lastRebasedTime.add(rebaseInterval);
    }

    function nextRebaseTime() external view returns (uint256) {
        return lastRebasedTime.add(rebaseInterval);
    }

    function _rebase() private {
        if (inSwap) return;
        uint256 deltaTime = block.timestamp - lastRebasedTime;
        uint256 times = deltaTime.div(rebaseInterval);
        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
            .mul(rewardYieldDenominator.add(rewardYield))
            .div(rewardYieldDenominator);
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }
        gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        lastRebasedTime = lastRebasedTime.add(times.mul(rebaseInterval));
    }

    function manualSync() public {
        for (uint256 i = 0; i < markerPairs.length; i++) {
            InterfaceLP(markerPairs[i]).sync();
        }
    }

    function manualRebase() external nonReentrant{
        require(shouldRebase(), "rebase not required");
        _rebase();
        manualSync();
    }

    function setMaxSupply(uint256 amount) public onlyOwner{
        MAX_SUPPLY = amount;
    }

    function setStartTradingTime(uint256 time) public onlyOwner{
        startTradingTime = time;
        if (lastRebasedTime == 0) {
            lastRebasedTime = time;
        }
        if (lastSwapTime == 0) {
            lastSwapTime = time;
        }
    }

    function setAutoRebase(bool value) external onlyOwner {
        autoRebase = value;
    }

    function setRebaseInterval(uint256 time) external onlyOwner {
        require(time > 0, "invalid time");
        rebaseInterval = time;
    }

    function setRewardYield(uint256 _rewardYield) external onlyOwner {
        rewardYield = _rewardYield;
    }

    function setAutomatedMarketMakerPairs(address pair, bool value) public onlyOwner {
        automatedMarketMakerPairs[pair] = value;
        if (value) {
            markerPairs.push(pair);
        } else {
            require(markerPairs.length > 1, "Required 1 pair");
            for (uint256 i = 0; i < markerPairs.length; i++) {
                if (markerPairs[i] == pair) {
                    markerPairs[i] = markerPairs[markerPairs.length - 1];
                    markerPairs.pop();
                    break;
                }
            }
        }

    }

    function changeRouterVersion(address newRouter) external onlyOwner returns(address newPair) {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouter);
        uniswapV2Router = _uniswapV2Router;
        _allowedFragments[address(this)][address(uniswapV2Router)] = type(uint256).max;

        newPair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());
        if(newPair == address(0)) {
            newPair = IUniswapV2Factory(uniswapV2Router.factory())
                .createPair(address(this), uniswapV2Router.WETH());
        }

        uniswapPair = newPair; 
        automatedMarketMakerPairs[address(uniswapPair)] = true;

    }

    function removeToken(address tokenAddress, uint256 amount) external onlyOwner {
        if (tokenAddress == address(0))
            payable(msg.sender).transfer(amount);
        else
            IERC20(tokenAddress).transfer(msg.sender, amount);
    }

    receive() external payable {}

    function takeFee(address sender, address recipient, uint256 gonAmount) internal returns (uint256) {
        require(startTradingTime > 0 && block.timestamp >= startTradingTime, "can not trade now!");
        uint256 feeAmount;
        uint256 burnAmount;
        uint256 receiveAmount;

        feeAmount = gonAmount.mul(inoutReserveFee).div(kiloDenominator);
        if(inoutBurnFee > 0 && getCirculatingSupply() > minCirculation) {
            burnAmount = gonAmount.mul(inoutBurnFee).div(kiloDenominator);
        }

        receiveAmount = gonAmount.sub(feeAmount.add(burnAmount));
        if(feeAmount > 0) {
            _gonBalances[address(this)] = _gonBalances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount.div(gonsPerFragment));
        }
        if (burnAmount > 0) {
            _gonBalances[Dead] = _gonBalances[Dead].add(burnAmount);
            emit Transfer(sender, Dead, burnAmount.div(gonsPerFragment));
        }
        return receiveAmount;
    }

    function setInOutTaxes(uint256 liquidityFee, uint256 marketingFee, uint256 teamFee, uint256 burnFee) external onlyOwner {
        liquidityShare = liquidityFee;
        marketingShare = marketingFee;
        teamShare = teamFee;
        totalDistributionShares = liquidityShare.add(marketingShare).add(teamShare);
        inoutReserveFee = totalDistributionShares;
        inoutBurnFee = burnFee; 
    }

}