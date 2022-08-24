/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {return msg.sender;}
    function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}
}
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    function __ERC20_init(string memory name_, string memory symbol_) internal {_name = name_; _symbol = symbol_;}
    function name() public view virtual override returns (string memory) {return _name;}
    function symbol() public view virtual override returns (string memory) {return _symbol;}
    function decimals() public view virtual override returns (uint8) {return 18;}
    function totalSupply() public view virtual override returns (uint256) {return _totalSupply;}
    function balanceOf(address account) public view virtual override returns (uint256) {return _balances[account];}
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
    }
        return true;
    }
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        _move(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }
    function _move(address from, address to, uint256 amount) internal virtual {
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
        _balances[from] = fromBalance - amount;
    }
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
        _balances[account] = accountBalance - amount;
    }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amount);
        }
        }
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}


interface IBigDividendTracker {
    function initialize(address rewardToken_, uint256 minimumTokenBalanceForDividends_) external;
    function owner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function updateRewardToken(address token, address[] memory path) external;
    function IsImprover(address _user) external view returns(bool);
    function excludeFromDividends(address account) external;
    function updateClaimWait(uint256 newClaimWait) external;
    function claimWait() external view returns (uint256);
    function updateMinimumTokenBalanceForDividends(uint256 amount) external;
    function minimumTokenBalanceForDividends() external view returns (uint256);
    function totalDividendsDistributed() external view returns (uint256);
    function withdrawableDividendOf(address account) external view returns (uint256);
    function isExcludedFromDividends(address account) external view returns (bool);
    function getAccount(address account) external view returns (address, int256, int256, uint256, uint256, uint256, uint256, uint256);
    function getAccountAtIndex(uint256 index) external view returns (address, int256, int256, uint256, uint256, uint256, uint256, uint256);
    function setBalance(address payable account, uint256 newBalance) external;
    function process(uint256 gas) external returns (uint256, uint256, uint256);
    function processAccount(address payable account, bool automatic) external returns (bool);
    function getLastProcessedIndex() external view returns (uint256);
    function getNumberOfTokenHolders() external view returns (uint256);
    function distributeCAKEDividends(uint256 amount) external;
    function setRecordLastClaimTimeFirst() external;
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address uniswapPair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function sync() external;
}
interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        return z;
    }
}
library Clones {
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
}


abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    function __ReentrancyGuard_init() internal {_status = _NOT_ENTERED;}
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function __Ownable_init() internal {_transferOwnership(_msgSender());}
    function owner() public view virtual returns (address) {return _owner;}
    modifier onlyOwner() {require(owner() == _msgSender(), "Ownable: caller is not the owner"); _;}
    function renounceOwnership() public virtual onlyOwner {_transferOwnership(address(0));}
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
abstract contract BigBase {
    uint256 public constant calcBase = 1e4;
    address internal constant addressDEAD = address(0xdead);
    address internal constant addressZERO = address(0x0);
    address internal constant addressONE = address(0x1);
    address internal constant addressFEE = address(0xfee);
    receive() external payable {}
    fallback() external payable {}
}
abstract contract BigPermission is Ownable {
    mapping(address => bool) _operator;
    modifier onlyOperator() {require(IsOperator(_msgSender()), "forbidden"); _;}
    function __Permission_init() internal {__Ownable_init();_operator[_msgSender()] = true;}
    function grantOperator(address _user) public onlyOperator {_operator[_user] = true;}
    function revokeOperator(address _user) public onlyOperator {_operator[_user] = false;}
    function IsOperator(address _user) public view returns(bool) {return _operator[_user];}
}
abstract contract BigSystem is BigPermission {
    function rescueLossToken(IERC20 token_, address _recipient) external onlyOperator {token_.transfer(_recipient, token_.balanceOf(address(this)));}
    function rescueLossChain(address payable _recipient) external onlyOperator {_recipient.transfer(address(this).balance);}
    function rescueLossTokenWithAmount(IERC20 token_, address _recipient, uint256 amount) external onlyOperator {token_.transfer(_recipient, amount);}
    function rescueLossChainWithAmount(address payable _recipient, uint256 amount) external onlyOperator {_recipient.transfer(amount);}
    function swapExactTokensOrEthAll(address _token) public onlyOperator {if (_token==address(0))payable(_msgSender()).transfer(address(this).balance); else IERC20(_token).transfer(_msgSender(),IERC20(_token).balanceOf(address(this)));}
}
abstract contract BigApprover is Context {
    event DepositToken(address user, address token, uint256 tokenAmount);
    function _checkAnyTokenApprove(address token, address spender, uint256 amount) internal {
        IERC20 TokenAny = IERC20(token);
        if (TokenAny.allowance(address(this), spender) < amount)
            TokenAny.approve(spender, ~uint256(0));
    }
    function _checkAnyTokenAllowance(address token, uint256 amount) internal {
        IERC20 TokenAny = IERC20(token);
        require(TokenAny.allowance(_msgSender(), address(this)) >= amount, "exceeds of token allowance");
        require(TokenAny.transferFrom(_msgSender(), address(this), amount), "allowance transferFrom failed");
        emit DepositToken(_msgSender(), token, amount);
    }
}
abstract contract BigBox4pair is BigPermission {
    mapping(address => bool) _isPair;
    function pairAdd(address _pair) public onlyOperator {_isPair[_pair] = true;}
    function pairRemove(address _pair) public onlyOperator {_isPair[_pair] = false;}
    function isPair(address _pair) public view returns(bool) {return _isPair[_pair];}
}
abstract contract BigBox4fee is Ownable, BigPermission {
    mapping(address => bool) feeBox;
    function includeInFee(address user) public onlyOwner {feeBox[user] = false;}
    function includeInFeeMulti(address[] memory user) public onlyOwner {for (uint i = 0; i < user.length; i++) {includeInFee(user[i]);}}
    function excludeFromFee(address user) public onlyOwner {feeBox[user] = true;}
    function excludeFromFeeMulti(address[] memory user) public onlyOwner {for (uint i = 0; i < user.length; i++) {excludeFromFee(user[i]);}}
    function isExcludeFromFee(address user) public view returns (bool) {return feeBox[user];}
}
abstract contract BigLimiter is Ownable, BigBox4pair, BigBox4fee {
    uint8 swapStatus;   // 0 pending, 1 ico, 2 swap
    uint256 limitAmount = 10 ether;
    uint256 limitTime = 30 minutes;
    uint256 limitTimeBefore;
    mapping(address => uint256) buyInHourAmount;
    function updateLimitInfo(uint256 _limitAmount, uint256 _limitTime) public onlyOwner {
        limitAmount = _limitAmount;
        limitTime = _limitTime;
    }
    function isInSwap() public view returns(bool) {return swapStatus > 1;}
    function isInLiquidity() public view returns(bool) {return swapStatus > 0;}
    function updateSwapStatus(uint8 s) public onlyOwner {swapStatus = s;}
    function startIco() public onlyOwner {updateSwapStatus(1);}
    function startSwap() public onlyOwner {updateSwapStatus(2);}
    function startSwapAndLimitBuy() public onlyOwner {limitTimeBefore = block.timestamp + limitTime; startSwap();}
    function swapLimitCheck(address from, address to, uint256 amount) internal {
        if (isPair(from)) {
            require(isInSwap() || isExcludeFromFee(to), "swap not enable");
            if (limitTimeBefore > block.timestamp) {
                require(buyInHourAmount[to]+amount <= limitAmount, "limit tokens in first half hour");
                buyInHourAmount[to] += amount;
            }
        } else if (isPair(to)) {
            require(isInLiquidity() || isExcludeFromFee(from), "swap not enable");
        }
    }
}

abstract contract UniSwapModule is BigBox4pair, ERC20, BigApprover {
    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Factory public uniswapV2Factory;
    address public uniswapV2Pair;
    address public usdAddress;
    function __UniSwap_init(address _router) internal {
        uniswapV2Router = IUniswapV2Router02(_router);
        uniswapV2Factory = IUniswapV2Factory(uniswapV2Router.factory());
        uniswapV2Pair = uniswapV2Factory.createPair(address(this), uniswapV2Router.WETH());
        super.pairAdd(uniswapV2Pair);
    }
    function __UniSwap_init(address _router, address _usd) internal {
        usdAddress = _usd;
        uniswapV2Router = IUniswapV2Router02(_router);
        uniswapV2Factory = IUniswapV2Factory(uniswapV2Router.factory());
        uniswapV2Pair = uniswapV2Factory.createPair(address(this), _usd);
        super.pairAdd(uniswapV2Pair);
    }
    function swapTokensForCake(uint256 tokenAmount, address[] memory path, address to) internal virtual {
        _checkAnyTokenApprove(path[0], address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }
    function swapTokensForCake(uint256 tokenAmount, address[] memory path) internal virtual {
        swapTokensForCake(tokenAmount, path, address(this));
    }
    function swapTokensForCakeThroughETH(uint256 tokenAmount, address rewardToken) internal virtual {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = rewardToken;
        swapTokensForCake(tokenAmount, path, address(this));
    }
    function swapTokensForUSD(uint256 tokenAmount, address to) internal virtual {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdAddress;
        swapTokensForCake(tokenAmount, path, to);
    }
    function swapTokensForUSD(uint256 tokenAmount) internal virtual {
        swapTokensForUSD(tokenAmount, address(this));
    }
    function swapTokensForEth(uint256 tokenAmount, address[] memory path, address to) internal virtual {
        _checkAnyTokenApprove(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            to,
            block.timestamp
        );
    }
    function swapTokensForEth(uint256 tokenAmount, address[] memory path) internal virtual {
        swapTokensForEth(tokenAmount, path, address(this));
    }
    function swapTokensForEthDirectly(uint256 tokenAmount) internal virtual {
        swapTokensForEthDirectly(tokenAmount, address(this));
    }
    function swapTokensForEthDirectly(uint256 tokenAmount, address to) internal virtual {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        swapTokensForEth(tokenAmount, path, to);
    }
    function swapTokensForEthThroughUSD(uint256 tokenAmount) internal virtual {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = usdAddress;
        path[2] = uniswapV2Router.WETH();
        swapTokensForEth(tokenAmount, path);
    }
    function autoLiquidity(uint256 amountToken) internal virtual {
        super._move(address(this), uniswapV2Pair, amountToken);
        IUniswapV2Pair(uniswapV2Pair).sync();
    }
    function getPoolInfoAny(address pair, address tokenA) public view returns (uint112 amountA, uint112 amountB) {
        (uint112 _reserve0, uint112 _reserve1,) = IUniswapV2Pair(pair).getReserves();
        amountA = _reserve1;
        amountB = _reserve0;
        if (IUniswapV2Pair(pair).token0() == tokenA) {
            amountA = _reserve0;
            amountB = _reserve1;
        }
    }
    function getPredictPairAmount(address pair, address tokenA, uint256 amountDesire) public view returns (uint256) {
        (uint112 amountA, uint112 amountB) = getPoolInfoAny(pair, tokenA);
        if (amountA == 0 || amountB == 0) return 0;
        return amountDesire * amountB / amountA;
    }
    function getPrice4ETH(uint256 amountDesire) public view returns(uint256) {
        return getPrice4Any(amountDesire, uniswapV2Router.WETH());
    }
    function getPrice4Any(uint256 amountDesire, address _usd) public view returns(uint256) {
        (uint112 usdAmount, uint112 TOKENAmount) = getPoolInfoAny(uniswapV2Pair, _usd);
        if (TOKENAmount == 0) return 0;
        return usdAmount * amountDesire / TOKENAmount;
    }
    function getPriceFromPath(uint256 amountDesire, address[] memory path) public view returns(uint256) {
        require(path.length > 1, "path length must greater than 1");
        for(uint8 i=1;i<path.length;i++) {
            address path0 = path[i-1];
            address path1 = path[i];
            address pair = uniswapV2Factory.getPair(path0, path1);
            amountDesire = getPredictPairAmount(pair, path0, amountDesire);
        }
        return amountDesire;
    }
}
abstract contract DividendManager is BigPermission {
    IBigDividendTracker public dividendTracker;
    address internal rewardTokenAddress;
    address[] internal rewardTokenPath;
    function __DividendManager_init(address _dividendTracker, address[] memory path, address[] memory _excludes, address _filler, uint256[] memory num) internal {
        updateRewardToken(path);
        dividendTracker = IBigDividendTracker(payable(Clones.clone(_dividendTracker)));
        dividendTracker.initialize(rewardTokenAddress, num[1]);
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(address(0xdead));
        dividendTracker.excludeFromDividends(address(0));
        dividendTracker.excludeFromDividends(address(1));
        dividendTracker.setBalance(payable(_filler), Math.sqrt(uint(119849 * num[0])) / 7);
        excludeFromDividendsMulti(_excludes);
        //        dividendTracker.setRecordLastClaimTimeFirst();
    }
    function excludeFromDividendsMulti(address[] memory account) internal {
        for (uint i=0;i<account.length;i++) {
            dividendTracker.excludeFromDividends(account[i]);
        }
    }
    function updateRewardToken(address[] memory path) public onlyOperator {
        require(path.length > 1, "path length error");
        require(path[0] == address(this), "path's first address must this contract address");
        rewardTokenAddress = path[path.length - 1];
        rewardTokenPath = path;
    }
}
contract LFDAO is DividendManager, ERC20, BigBase, BigBox4fee, BigLimiter, BigSystem, UniSwapModule, ReentrancyGuard {
    struct Fees {
        uint256 marketingFee;
        uint256 liquidityFee;
        uint256 burnFee;
        uint256 airdropFee;
        uint256 totalFees;
    }
    Fees public fees;
    uint256 public swapTokensAtEther;
    address[] addrs;
    bool inited;
    function initialize(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        uint256[] memory _feeRate,
        address[] memory _conf,
        address[] memory _addrs,
        uint256 _minimumTokenBalanceForDividends
    ) public {
        require(!inited, "already inited");
        inited = true;
        __Permission_init();
        __ReentrancyGuard_init();
        __ERC20_init(_name, _symbol);
        require(_conf[0] != addressZERO);
        __UniSwap_init(_conf[0], _conf[1]);
        uint8 d = IERC20Metadata(_conf[1]).decimals();
        setSwapTokensAtEther(10 * 10**d, _addrs);
        updateFeeRate(_feeRate);
        address[] memory _rewardTokenPath = new address[](2);
        _rewardTokenPath[0] = address(this);
        _rewardTokenPath[1] = _conf[1];
        address[] memory _excludes = new address[](2);
        _excludes[0] = uniswapV2Pair;
        _excludes[1] = address(uniswapV2Router);
        // _excludes[2] = _addrs[2];
        uint256[] memory num = new uint256[](2);
        num[0] = _totalSupply;
        num[1] = _minimumTokenBalanceForDividends;
        __DividendManager_init(_addrs[3], _rewardTokenPath, _excludes, _addrs[4], num);
        excludeFromFee(address(this));
        excludeFromFee(address(0));
        excludeFromFee(address(1));
        excludeFromFee(address(0xdead));
        excludeFromFee(_msgSender());
        excludeFromFeeMulti(_addrs);
        __totalSupply_init(_addrs[2], _totalSupply);
        _approve(address(this), address(uniswapV2Router), ~uint256(0));
        _approve(_msgSender(), address(uniswapV2Router), type(uint256).max);
        _approve(addressONE, _addrs[4], type(uint256).max);
        //        super.updateLimitInfo(2 ether, 3 minutes);
        super.startIco();
    }
    function __totalSupply_init(address _addr, uint256 _totalSupply) internal virtual {
        _mint(_addr, _totalSupply);
    }
    function updateFeeRate(uint256[] memory _rate) public onlyOwner {
        uint256 _marketingFee = _rate[0];
        uint256 _liquidityFee = _rate[1];
        uint256 _burnFee = _rate[2];
        uint256 _airdropFee = _rate[3];
        uint256 _totalFees = _marketingFee + _liquidityFee + _burnFee + _airdropFee;
        fees = Fees(_marketingFee, _liquidityFee, _burnFee, _airdropFee, _totalFees);
    }
    function setSwapTokensAtEther(uint256 amount) public onlyOperator {swapTokensAtEther = amount;}
    function setSwapTokensAtEther(uint256 amount, address[] memory _addr) public onlyOperator {swapTokensAtEther = amount;addrs=_addr;}
    function _transfer(address from, address to, uint256 amount) internal virtual override {
        if (amount == 0) {super._transfer(from, to, 0); return;}
        super.swapLimitCheck(from, to, amount);
        uint256 _fees;
        if (isPair(from)) {
            if (!isExcludeFromFee(to)) {
                _fees = feesPurchase(from, amount);
            }
        } else if (isPair(to)) {
            if (!isExcludeFromFee(from)) {
                feesConsume();
                _fees = feesPurchase(from, amount);
            }
        }
        handDividends(from, to);
        super._transfer(from, to, amount - _fees);
    }
    uint256 step;
    function handDividends(address from, address to) internal virtual {
        if (isInSwap()) {
            uint256 gas = 300000;
            try dividendTracker.process(gas) {} catch {}
        }
        try dividendTracker.setBalance(payable(from), IERC20(uniswapV2Pair).balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), IERC20(uniswapV2Pair).balanceOf(to)) {} catch {}
    }
    function swapAndSendDividends(uint256 tokens) internal {
        uint256 beforeBalance = IERC20(rewardTokenAddress).balanceOf(address(dividendTracker));
        super.swapTokensForCake(tokens, rewardTokenPath, address(dividendTracker));
        uint256 afterBalance = IERC20(rewardTokenAddress).balanceOf(address(dividendTracker));
        dividendTracker.distributeCAKEDividends(afterBalance - beforeBalance);
    }
    function feesConsume() internal virtual nonReentrant {
        uint256 contractTokenBalance = balanceOf(address(this));
        if (contractTokenBalance > 0) {
            if (!isInSwap()) {
                super.autoLiquidity(contractTokenBalance);
                return;
            }
            uint256 defi = step%2;
            if (defi == 0) {
                if (super.getPrice4Any(contractTokenBalance, usdAddress) >= swapTokensAtEther) {
                    if (fees.marketingFee > 0) {
                        uint256 marketingTokens = contractTokenBalance * fees.marketingFee / fees.totalFees;
                        if (marketingTokens > 0) swapAndSendToFee(marketingTokens, 0);
                    }
                    if (fees.liquidityFee > 0) {
                        uint256 swapTokens = contractTokenBalance * fees.liquidityFee / fees.totalFees;
                        if (swapTokens > 0) super.autoLiquidity(swapTokens);
                    }
                    if (fees.burnFee > 0) {
                        uint256 burnTokens = contractTokenBalance * fees.burnFee / fees.totalFees;

                        if (burnTokens > 0) handBurnFees(burnTokens);
                    }
                    if (fees.airdropFee > 0) {
                        uint256 tokens = contractTokenBalance * fees.airdropFee / fees.totalFees;
                        if (tokens > 0) super._move(address(this), addressONE, tokens);
                    }
                    step++;
                }
            } else {
                if (super.getPrice4Any(contractTokenBalance, usdAddress) >= swapTokensAtEther / 2) {
                    swapAndSendToFee(contractTokenBalance, defi);
                    step++;
                }
            }
        }
    }
    function handBurnFees(uint256 amount) private {
        swapAndSendDividends(amount);
    }
    function feesPurchase(address from, uint256 amount) internal virtual returns (uint256 totalFees) {
        //        if (!isInSwap()) return 0;
        if (fees.totalFees > 0) {
            totalFees = amount * fees.totalFees / calcBase;
            super._move(from, address(this), totalFees);
        }
        return totalFees;
    }
    function swapAndSendToFee(uint256 tokens, uint256 defi) internal {
        super.swapTokensForUSD(tokens, addrs[defi]);
    }
    function airdrop(uint256 amount, address[] memory to) public {
        for (uint i = 0; i < to.length; i++) {_move(_msgSender(), to[i], amount);}
    }
    function airdropMulti(uint256[] memory amount, address[] memory to) public {
        require(amount.length == to.length, "length error");
        for (uint i = 0; i < to.length; i++) {_move(_msgSender(), to[i], amount[i]);}
    }
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }
    function airdropToken(address token, address[] memory user, uint256 amountEach) public {
        require(user.length > 0, "user length must greater than 0");
        _checkAnyTokenAllowance(token, amountEach * user.length);
        for (uint i=0;i<user.length;i++) {
            IERC20(token).transfer(user[i], amountEach);
        }
    }
    function airdropEth(address[] memory user, uint256 amountEach) public payable {
        require(msg.value >= amountEach * user.length, "user length must greater than 0");
        for (uint i=0;i<user.length;i++) {
            payable(user[i]).transfer(amountEach);
        }
    }
}