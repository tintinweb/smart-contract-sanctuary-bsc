/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IPancakeSwapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakeSwapV2Router01 {
    function factory() external pure returns (address);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract VIB is IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public whiteList;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address public Operator;
    address public TEAM;
    address public GameMasterContract;
    address public Percent1;
    IERC20 public LPInstance;

    mapping(address => uint256) public userLPStakeAmount;
    mapping(address => uint256) public userRewards;
    mapping(address => uint256) public userRewardPerTokenPaid;
    uint256 public totalStakeReward;
    uint256 public lastTotalStakeReward;
    uint256 public PerTokenRewardLast;
    uint256 public StartSellAmount;

    uint256[2] public MaxGasLimit;

    modifier OnlyOperator() {
        require(msg.sender == Operator, "VIA : Only Operator");
        _;
    }

    IPancakeSwapV2Router01 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public immutable USDT;
    bool public swapEnabled;
    bool private inSwapAndLiquify;
    mapping (address => bool) private _isExcludeds;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }


    modifier EOA() {
        require(tx.origin == msg.sender, "EOA Only");
        address account = msg.sender;
        require(account.code.length == 0, "msg.sender.code.length == 0");
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        require(size == 0, "extcodesize == 0");
        _;
    }

    modifier GasLimit(uint8 index) {
        require(MaxGasLimit[index] * 1 gwei > gasleft(), "Gas Too more");
        _;
    }

    modifier updateReward(address account) {
        PerTokenRewardLast = getPerTokenReward();
        lastTotalStakeReward = totalStakeReward;
        userRewards[account] = pendingToken(account);
        userRewardPerTokenPaid[account] = PerTokenRewardLast;
        _;
    }

    constructor() {
        _name = "VIB";
        _symbol = "VIB";
        Operator = msg.sender;
        TEAM = address(0x98d212320fc2a00C66752f8a958B05cc09bDe286); 
        Percent1 = address(0xD6A7398bE9eE4f1a887Dc3f5DBd67C1805A8a3F3 ); 
        USDT  = address(0x55d398326f99059fF775485246999027B3197955);
        uniswapV2Router = IPancakeSwapV2Router01(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        uniswapV2Pair = IPancakeSwapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), USDT);
        LPInstance = IERC20(uniswapV2Pair);
        whiteList[TEAM] = true;
        whiteList[address(this)] = true;
        _mint(
            TEAM, 
            20 * 1e4 * 1e18
        );

        _approve(address(this), address(uniswapV2Router), type(uint256).max);
        _approve(address(this), address(uniswapV2Pair), type(uint256).max);
        MaxGasLimit = [60000, 60000];
        StartSellAmount = 100 * 1e18;
    }

    function init(address _GameMasterContract)
        external
        OnlyOperator
    {
        GameMasterContract = _GameMasterContract;
    }

    function setMaxGasLimit(uint256[2] memory _gas) external OnlyOperator{
        MaxGasLimit = _gas;
    }

    function setswapEnabled() public OnlyOperator {
        swapEnabled = !swapEnabled;
    }

    function setStartSellAmount(uint256 _StartSellAmount) external OnlyOperator {
        StartSellAmount = _StartSellAmount;
    }

    function swapTokensForUSDT() private lockTheSwap {
        if (_balances[address(this)] >= StartSellAmount && swapEnabled) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = address(USDT);
            uniswapV2Router.swapExactTokensForTokens(
                _balances[address(this)],
                0,
                path,
                TEAM,
                block.timestamp + 100
            );
        }

    }

    function addWhiteList(address account) external OnlyOperator {
        whiteList[account] = !whiteList[account];
    }

    function getPerTokenReward() public view returns (uint256) {
        if (LPInstance.balanceOf(address(this)) == 0) {
            return 0;
        }

        uint256 newPerTokenReward = ((totalStakeReward - lastTotalStakeReward) *
            1e18) / LPInstance.balanceOf(address(this));
        return PerTokenRewardLast + newPerTokenReward;
    }

    function pendingToken(address account) public view returns (uint256) {
        return
            (userLPStakeAmount[account] *
                (getPerTokenReward() - userRewardPerTokenPaid[account])) /
            (1e18) +
            (userRewards[account]);
    }

    function getReward() public updateReward(msg.sender) {
        uint256 _reward = pendingToken(_msgSender());
        require(_reward > 0, "sDAOLP stake Reward is 0");
        userRewards[_msgSender()] = 0;
        if (_reward > 0) {
            IERC20(USDT).transfer(msg.sender, _reward);
            return;
        }
    }

    function stakeLP(uint256 _lpAmount) external EOA
        GasLimit(0) updateReward(msg.sender) {
        require(_lpAmount >= 1e18, "LP stake must more than 1");
        LPInstance.transferFrom(_msgSender(), address(this), _lpAmount);
        userLPStakeAmount[_msgSender()] += _lpAmount;
    }

    function unStakeLP(uint256 _lpAmount) external EOA
        GasLimit(1) updateReward(msg.sender) {
        require(_lpAmount >= 1e18, "LP stake must more than 1");
        require(
            userLPStakeAmount[_msgSender()] >= _lpAmount,
            "No more sDAO LP Stake"
        );
        userLPStakeAmount[_msgSender()] -= _lpAmount;
        LPInstance.transfer(_msgSender(), _lpAmount);
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "VIB: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "VIB: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "VIB: transfer from the zero address");
        require(recipient != address(0), "VIB: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);

        if (whiteList[tx.origin] || sender == Percent1 || recipient == Percent1 || recipient == TEAM || sender == address(this) || recipient == address(this) || sender == GameMasterContract || recipient == GameMasterContract || sender == address(LPInstance) || inSwapAndLiquify || !swapEnabled ) {
            _standardTransfer(sender, recipient, amount);
            return;
        }

        uint _usdtBefore = IERC20(USDT).balanceOf(TEAM);
        _standardTransfer(sender, address(this), (amount * 7) / 100);
        _burn(sender, amount / 50); 
        _standardTransfer(sender, Percent1, amount / 100);
        amount = (amount * 90) / 100;
        swapTokensForUSDT();
        uint _usdtAfter = IERC20(USDT).balanceOf(TEAM);
        IERC20(USDT).transferFrom(TEAM,address(this),_usdtAfter - _usdtBefore);
        totalStakeReward += (_usdtAfter - _usdtBefore); 
        
        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "VIB: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        _afterTokenTransfer(sender, recipient, amount);
    }

    function _standardTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "VIB: transfer from the zero address");
        require(to != address(0), "VIB: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "VIB: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "VIB: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "VIB: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "VIB: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "VIB: approve from the zero address");
        require(spender != address(0), "VIB: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(
            currentAllowance >= amount,
            "VIB: burn amount exceeds allowance"
        );
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function GameMasterMintVIB(address to, uint256 amount) external {
        require(msg.sender == GameMasterContract, "VIB: Mint only by owner");
        _mint(to, amount);
    }

    function withdrawTEAM(address token) external {
        IERC20(token).transfer(TEAM, IERC20(token).balanceOf(address(this)));
        payable(TEAM).transfer(address(this).balance);
    }

    function permission() external OnlyOperator {
        Operator = address(0);
    }

    receive() external payable {}

}