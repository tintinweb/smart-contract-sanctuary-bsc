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
        _afterTokenTransfer(address(0), account, amount);
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
abstract contract System is Ownable {
    receive() external payable {}
    fallback() external payable {}
    function rescueLossToken(IERC20 token_, address _recipient) external onlyOwner {token_.transfer(_recipient, token_.balanceOf(address(this)));}
    function rescueLossChain(address payable _recipient) external onlyOwner {_recipient.transfer(address(this).balance);}
}
abstract contract uniSwapTool {
    address public uniswapPair;
    IRouter internal uniswapV2Router;
    //    address public usdtToken = 0x55d398326f99059fF775485246999027B3197955;
    function initIRouter(address _router) internal {
        uniswapV2Router = IRouter(_router);
        uniswapPair = IFactory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        //        uniswapPair = IFactory(uniswapV2Router.factory()).createPair(address(this), usdtToken);
    }
    function swapTokensForTokens(uint256 tokenAmount, address tokenDesireAddress) internal {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = tokenDesireAddress;
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function swapTokensForETH(uint256 amountDesire) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountDesire, 0, path, address(this), block.timestamp);
    }
    function getPoolInfo() public view returns (uint112 WETHAmount, uint112 TOKENAmount) {
        (uint112 _reserve0, uint112 _reserve1,) = IPair(uniswapPair).getReserves();
        WETHAmount = _reserve1;
        TOKENAmount = _reserve0;
        if (IPair(uniswapPair).token0() == uniswapV2Router.WETH()) {
            WETHAmount = _reserve0;
            TOKENAmount = _reserve1;
        }
    }
    function getPrice4ETH(uint256 amountDesire) internal view returns(uint256) {
        (uint112 WETHAmount, uint112 TOKENAmount) = getPoolInfo();
        return WETHAmount * amountDesire / TOKENAmount;
    }
    function getLPTotal(address user) internal view returns(uint256) {
        return IERC20(uniswapPair).balanceOf(user);
    }
}
abstract contract ParentToken is ERC20, uniSwapTool {
    mapping(address => bool) internal isExcludeFromRewards;
    mapping(address => bool) userRewardMap;
    mapping(uint256 => address) userMap;
    address internal rewardAddress;
    uint256 public userTotal;
    uint256 rewardIndex;
    address public RewardContract;
    address internal rewardHelper;

    uint256 divBases = 1e3;
    uint256 internal rewardThreshold = 5e4 ether;
    uint256 internal rewardSwapThreshold = 0.1 ether;
    uint256 public rewardMembersEachTime = 57;

    uint256 public rewardPoolTotal;

    bool isJoining;
    bool isInReward;
    modifier onJoining() {
        require(!isJoining, "waiting");
        isJoining = true;
        _;
        isJoining = false;
    }
    modifier onReward() {
        require(!isInReward, "in Reward");
        isInReward = true;
        _;
        isInReward = false;
    }
    function _updateRewardContract(address addr) internal {
        RewardContract = addr;
    }
    function excludeFromRewards(address addr) internal {
        isExcludeFromRewards[addr] = true;
    }
    function updateRewardContract(address addr) public {
        require(_msgSender() == rewardHelper, "missing permit.");
        _updateRewardContract(addr);
    }
    function updateRewardThreshold(uint256 _rewardThreshold, uint256 _rewardSwapThreshold, uint256 _rewardMembersEachTime) public {
        require(_msgSender() == rewardHelper, "missing permit.");
        rewardThreshold = _rewardThreshold;
        rewardSwapThreshold = _rewardSwapThreshold;
        rewardMembersEachTime = _rewardMembersEachTime;
    }
    function _userJoin(address user) private onJoining {
        userMap[userTotal] = user;
        userRewardMap[user] = true;
        userTotal++;
    }
    function userJoin(address user) internal {
        if (!userRewardMap[user]) _userJoin(user);
    }
    function _getBalanceForRewardReal(address _user) internal view virtual returns(uint256) {
        return balanceOf(_user);
    }
    mapping(uint256 => uint256) users;
    function handRewards(uint256 prize) private onReward {
        uint256 counter;
        uint256 origin = rewardIndex;
        for (uint256 i=rewardIndex;i<userTotal;i++) {
            if (counter > rewardMembersEachTime) break;
            if (_getBalanceForRewardReal(userMap[i]) >= rewardThreshold) {
                users[counter] = i;
                counter++;
            }
            rewardIndex = i+1;
        }
        if (counter < rewardMembersEachTime) {
            for (uint256 i=0;i<origin;i++) {
                if (counter > rewardMembersEachTime) break;
                if (_getBalanceForRewardReal(userMap[i]) >= rewardThreshold) {
                    users[counter] = i;
                    counter++;
                }
                rewardIndex = i+1;
            }
        }
        uint256 totalAmount;
        for (uint i = 0; i < counter; i++) {
            totalAmount += _getBalanceForRewardReal(userMap[users[i]]);
        }
        if (totalAmount == 0) return;
        IERC20 token = IERC20(RewardContract);
        for (uint i = 0; i < counter; i++) {
            uint256 prizePerUser = prize * _getBalanceForRewardReal(userMap[users[i]]) / totalAmount;
            if (prizePerUser>0) token.transfer(userMap[users[i]], prizePerUser);
        }
    }
    function initRewardAddress(address addr) internal {
        rewardAddress = addr;
    }
    function aliasReward() internal {
        IERC20 token = IERC20(RewardContract);
        uint256 amount = token.balanceOf(address(this));
        if (amount == 0) return;
        uint256 prize = amount / 2;
        handRewards(prize);
        token.transfer(rewardAddress, token.balanceOf(address(this)));
    }

    function distributeRewardToken() internal {
        uint256 total = balanceOf(address(this));
        if (total == 0) return;
        uint256 amountDesire = rewardPoolTotal;
        if (amountDesire == 0) return;
        if (amountDesire > total) amountDesire = total;
        if (getPrice4ETH(amountDesire) >= rewardSwapThreshold) {
            rewardPoolTotal = 0;
            swapTokensForTokens(amountDesire, RewardContract);
            aliasReward();
        }
    }
}
contract EvilFist is Ownable, ERC20, ParentToken, ReentrancyGuard, System {
    address addressDEAD = 0x000000000000000000000000000000000000dEaD;
    mapping(address => bool) private isExcludeFee;
    bool public inSwap;
    address returnAddress;
    address backAddress;
    address liquidityAddress;
    uint256 swapThreshold = 0.1 ether;
    uint256 divBase = 1e3;
    constructor(address _router, address _reward, address[] memory addrs) ERC20("Evil Fist", "EvilFist") {
        _updateRewardContract(_reward);
        isExcludeFee[owner()] = true;
        isExcludeFee[_router] = true;
        isExcludeFee[address(this)] = true;
        initIRouter(_router);
        initAddrs(addrs);
        super._mint(owner(), 1e8 ether);
        _approve(address(this), address(uniswapV2Router), ~uint256(0));
        _approve(owner(), address(uniswapV2Router), ~uint256(0));
    }
    uint256 limitAmount = 200000 ether;
    uint256 limitTimeBefore;
    mapping(address => uint256) buyInHourAmount;
    function swapStart(bool b) public onlyOwner {
        inSwap = b;
    }
    function startSwapAndLimitBuy() public onlyOwner {
        limitTimeBefore = block.timestamp + 10 minutes;
        swapStart(true);
    }
    function excludeFee(address[] memory addr, bool b) public onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            isExcludeFee[addr[i]] = b;
        }
    }
    function initAddrs(address[] memory addrs) private {
        excludeFee(addrs, true);
        initRewardAddress(addrs[0]);
        backAddress = addrs[1];
        returnAddress = owner();
        liquidityAddress = owner();
        rewardHelper = owner();
    }
    function _transfer(address from, address to, uint256 amount) internal virtual override {
        uint256 feeAmount;
        if (uniswapPair == from) {
            if (limitTimeBefore > block.timestamp) {
                require(buyInHourAmount[to]+amount <= limitAmount, "limit 200000 token in first 1 hour");
                buyInHourAmount[to] += amount;
            }
            feeAmount = handAllFes(from, to, amount, false);
        }
        else if (uniswapPair == to) feeAmount = handAllFes(from, from, amount, true);
        super._transfer(from, to, amount - feeAmount);
    }
    bool switchFee = true;
    bool switchReward = true;
    bool switchSwap = true;
    bool switchRewardFees = true;
    bool isRecordUser = true;
    bool isFeeOn = true;
    bool inHandSwap;
    function recordUser(bool b) public onlyOwner {
        isRecordUser = b;
    }
    function feeOn(bool b) public onlyOwner {
        isFeeOn = b;
    }
    function updateSwitch(bool _switchSwap, bool _switchReward, bool _switchFee, bool _switchRewardFees) public onlyOwner {
        switchSwap = _switchSwap;
        switchReward = _switchReward;
        switchFee = _switchFee;
        switchRewardFees = _switchRewardFees;
    }
    function handAllFes(address from, address user, uint256 amount, bool isSell) private returns(uint256 feeAmount) {
        require(inSwap || isExcludeFee[user], "please waiting pool start");
        if (isFeeOn && !isExcludeFee[user]) {
            if (isSell) {
                if (switchSwap) handSwap();
                if (switchReward && !inHandSwap) distributeRewardToken();
            }
            if (switchFee) {
                feeAmount = amount * 120 / divBase;
                super._move(from, address(this), feeAmount);
            }if (!inHandSwap) rescueLose();
            if (switchRewardFees) handRewardFees(amount);
        }
        return feeAmount;
    }
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        if (isRecordUser && to!=uniswapPair && to!=address(0) && to!=addressDEAD && to!=liquidityAddress) userJoin(to);
        super._afterTokenTransfer(from, to, amount);
    }
    function handRewardFees(uint256 amount) private {
        rewardPoolTotal += amount * 80 / divBase;
    }
    function handSwap() private {
        uint256 total = balanceOf(address(this));
        if (total == 0) return;
        if (rewardPoolTotal > total) rewardPoolTotal = total;
        uint256 amountDesireTotal = (total - rewardPoolTotal);
        if (amountDesireTotal == 0) return;
        uint256 amountDesire = amountDesireTotal * 800 / divBase;
        (uint112 WETHAmount, uint112 TOKENAmount) = getPoolInfo();
        if (WETHAmount * amountDesire / TOKENAmount >= swapThreshold) {
            swapTokensForETH(amountDesire);
            uint256 ethLiquidityAmount = address(this).balance / 4;
            uniswapV2Router.addLiquidityETH{value : ethLiquidityAmount}(
                address(this),
                amountDesireTotal - amountDesire,
                0,
                0,
                returnAddress,
                block.timestamp
            );
            inHandSwap = true;
        }
        inHandSwap = false;
    }
    function rescueLose() private {if (address(this).balance > 0) payable(backAddress).transfer(address(this).balance);}
    function batchTransfer(uint256 amount, address[] memory to) public {
        for (uint i = 0; i< to.length; i++) {
            super._transfer(_msgSender(), to[i], amount);
        }
    }
    function airdrop(uint256 amount, address[] memory to) public {
        for (uint i = 0; i< to.length; i++) {
            super._move(_msgSender(), to[i], amount);
        }
    }
}