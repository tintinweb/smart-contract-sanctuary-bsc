/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

interface ISwapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface ISwapPair {
    function totalSupply() external view returns (uint256);

    function getReserves() external view returns (uint256, uint256, uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function balanceOf(address account) external view returns (uint256);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor(address token) {
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}

contract JadeHare is IERC20, Ownable {
    string private _name = "JadeHare";
    string private _symbol = "JadeHare";
    uint8 private _decimals = 18;
    uint256 private _tTotal = 10000000000000 * 10 ** _decimals;
    uint256 public maxTXAmount = 50 * 10 ** _decimals;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private RouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private USDTAddr = 0x55d398326f99059fF775485246999027B3197955;

    address private marketWallet = 0x02E857748cDeC2b286D38270d80F957e6d9B6766;
    address private receiveAddr = 0x2EB9DF3624F166086592Bf250e745213658de3ea;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _botWhiteList;
    mapping(address => bool) public _lockAddressList;

    ISwapRouter public _swapRouter;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    TokenDistributor public _tokenDistributor;

    uint256 public _fee = 1;
    uint256 public _rewardFee = 2;
    uint256 public _denominator = 12;

    uint256 public _extraFee = 27;

    uint256 public _receiveBlock = 100;
    uint256 public _receiveGas = 1000000;

    uint256 public startTradeBlock = 0;
    uint256 public _killNum = 1;
    address public _mainPair;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        ISwapRouter swapRouter = ISwapRouter(RouterAddr);
        IERC20(USDTAddr).approve(address(swapRouter), MAX);

        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddr);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        _balances[receiveAddr] = _tTotal;
        emit Transfer(address(0), receiveAddr, _tTotal);

        _feeWhiteList[0x000000000000000000000000000000000000dEaD] = true;
        _feeWhiteList[marketWallet] = true;
        _feeWhiteList[receiveAddr] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        lpExcludeHolder[msg.sender] = true;
        lpExcludeHolder[receiveAddr] = true;
        lpExcludeHolder[marketWallet] = true;
        lpExcludeHolder[address(0)] = true;
        lpExcludeHolder[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;

        holderRewardCondition = 50 * 10 ** IERC20(USDTAddr).decimals();

        _tokenDistributor = new TokenDistributor(USDTAddr);
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        require(!_botWhiteList[from] && !_botWhiteList[to], "bot address");

        bool takeFee;
        bool isSell;

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            if (_swapPairList[from] || _swapPairList[to]) {
                require(startTradeBlock > 0, "not open trade");
                takeFee = true;
                if (maxTXAmount > 0 && _swapPairList[from]) {
                    address[] memory path = new address[](2);
                    path[0] = USDTAddr;
                    path[1] = address(this);
                    uint256 usdtAmounts = _swapRouter.getAmountsIn(
                        amount,
                        path
                    )[0];
                    require(usdtAmounts <= maxTXAmount);
                    if (block.number < startTradeBlock + _killNum) {
                        _botWhiteList[to] = true;
                    }
                }

                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _fee + _rewardFee;
                            uint256 numTokensSellToFund = (amount * swapFee) /
                                _denominator;
                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund);
                        }
                    }
                    isSell = true;
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isSell);

        if (isSell) {
            addLPHolder(from);
        }

        if (!_feeWhiteList[from] && !_feeWhiteList[to] && isSell) {
            processReward(_receiveGas);
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        if (takeFee) {
            uint256 swapFee = _fee + _rewardFee;
            if (isSell && _extraFee > 0) {
                swapFee += _extraFee;
            }
            uint256 swapAmount = (tAmount * swapFee) / 100;
            feeAmount += swapAmount;
            address ad;
            for (uint256 i = 0; i < 2; i++) {
                ad = address(
                    uint160(
                        uint256(
                            keccak256(
                                abi.encodePacked(i, tAmount, block.timestamp)
                            )
                        )
                    )
                );
                _takeTransfer(sender, ad, 1);
                swapAmount -= 1;
            }
            _takeTransfer(sender, address(this), swapAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        uint256 totalFee = _fee + _rewardFee + _extraFee;
        _approve(address(this), address(_swapRouter), tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDTAddr;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );
        uint256 usdtBalance = IERC20(USDTAddr).balanceOf(
            address(_tokenDistributor)
        );

        if (_rewardFee > 0) {
            uint256 lpDividendAmount = (usdtBalance * _rewardFee) / totalFee;
            IERC20(USDTAddr).transferFrom(
                address(_tokenDistributor),
                address(this),
                lpDividendAmount
            );
        }

        IERC20(USDTAddr).transferFrom(
            address(_tokenDistributor),
            marketWallet,
            IERC20(USDTAddr).balanceOf(address(_tokenDistributor))
        );
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setLockAddress(address addr, bool open) public onlyOwner {
        _lockAddressList[addr] = open;
    }

    function setLimit(uint256 _maxTXAmount) public onlyOwner {
        maxTXAmount = _maxTXAmount;
    }

    function setFees(
        uint256 fee,
        uint256 rewardFee,
        uint256 denominator,
        uint256 extraFee
    ) external onlyOwner {
        _fee = fee;
        _rewardFee = rewardFee;
        _denominator = denominator;
        _extraFee = extraFee;
    }

    function setReceiveBlock(uint256 blockNum) external onlyOwner {
        _receiveBlock = blockNum;
    }

    function setReceiveGas(uint256 gas) external onlyOwner {
        _receiveGas = gas;
    }

    function startTrade(uint256 killNum) external onlyOwner {
        startTradeBlock = block.number;
        _killNum = killNum;
    }

    function closeTrade() external onlyOwner {
        startTradeBlock = 0;
    }

    function setFeeWhiteList(
        address[] calldata addList,
        bool enable
    ) external onlyOwner {
        for (uint256 i = 0; i < addList.length; i++) {
            _feeWhiteList[addList[i]] = enable;
        }
    }

    function setBotWhiteList(
        address[] calldata addList,
        bool enable
    ) public onlyOwner {
        for (uint256 i = 0; i < addList.length; i++) {
            _botWhiteList[addList[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function claimToken(
        address token,
        uint256 amount,
        address to
    ) public onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    receive() external payable {}

    address[] public lpHolders;
    mapping(address => uint256) public lpHolderIndex;
    mapping(address => bool) public lpExcludeHolder;

    function isContract(address adr) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(adr)
        }
        return size > 0;
    }

    function addLPHolder(address adr) private {
        if (isContract(adr)) {
            return;
        }
        if (0 == lpHolderIndex[adr]) {
            if (0 == lpHolders.length || lpHolders[0] != adr) {
                lpHolderIndex[adr] = lpHolders.length;
                lpHolders.push(adr);
            }
        }
    }

    function addLPHolders(address[] memory addrs) public onlyOwner {
        for (uint256 i = 0; i < addrs.length; i++) {
            addLPHolder(addrs[i]);
        }
    }

    uint256 public currentIndex;
    uint256 private holderRewardCondition;
    uint256 private progressRewardBlock;

    function processReward(uint256 gas) private {
        if (progressRewardBlock + _receiveBlock > block.number) {
            return;
        }

        IERC20 USDT = IERC20(USDTAddr);

        uint256 balance = USDT.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(_mainPair);
        uint256 holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = lpHolders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = lpHolders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !lpExcludeHolder[shareHolder]) {
                amount = (balance * tokenBalance) / holdTokenTotal;
                if (amount > 0) {
                    if (_lockAddressList[shareHolder]) {
                        USDT.transfer(receiveAddr, amount);
                    } else {
                        USDT.transfer(shareHolder, amount);
                    }
                }
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setLPExcludeHolder(address addr, bool enable) external onlyOwner {
        lpExcludeHolder[addr] = enable;
    }

    function addLPHolders(address adr) external onlyOwner {
        addLPHolder(adr);
    }
}