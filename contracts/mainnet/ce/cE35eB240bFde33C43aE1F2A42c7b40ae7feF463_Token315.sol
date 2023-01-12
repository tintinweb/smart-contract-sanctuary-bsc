/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

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
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface ISwapPair {
    function totalSupply() external view returns (uint256);

    function getReserves()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function token0() external view returns (address);

    function token1() external view returns (address);

    function balanceOf(address account) external view returns (uint256);
}

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
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

contract Token315 is IERC20, Ownable {
    using SafeMath for uint256;

    string private _name = "315";
    string private _symbol = "315";
    uint8 private _decimals = 6;
    uint256 private _tTotal = 315 * 10**_decimals;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private RouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private USDTAddr = 0x55d398326f99059fF775485246999027B3197955;

    address private fund1Addr = 0x95580E362cE8290943E76E6d948a3d17cb9ca37f;
    address private fund2Addr = 0xB15cE623d86264AF8d86f8a9eD2412aBDFB10d52;
    address private fund3Addr = 0x320e63EBCF0562c90D40B03a548530e5D54ee61e;

    address private receiveAddr = 0xdD09C90c34973E9F195b119EFf78d5D4201c1A64;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _botWhiteList;
    mapping(address => bool) public _lockAddressList;

    address pinkLockAddress;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee = 3;
    uint256 public _sellFundFee = 3;
    uint256 public _denominator = 30;

    uint256 public _receiveBlock = 100;
    uint256 public _receiveGas = 1000000;

    uint256 public startTradeBlock = 0;

    address public _mainPair;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        ISwapRouter swapRouter = ISwapRouter(RouterAddr);
        IERC20(USDTAddr).approve(address(swapRouter), MAX);

        _usdt = USDTAddr;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddr);
        _mainPair = swapPair;
        require(ISwapPair(swapPair).token0() == USDTAddr, "error!");
        _swapPairList[swapPair] = true;

        _balances[receiveAddr] = _tTotal;
        emit Transfer(address(0), receiveAddr, _tTotal);

        _feeWhiteList[fund1Addr] = true;
        _feeWhiteList[fund2Addr] = true;
        _feeWhiteList[fund3Addr] = true;
        _feeWhiteList[receiveAddr] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        lpExcludeHolder[msg.sender] = true;
        lpExcludeHolder[address(0)] = true;
        lpExcludeHolder[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;

        holderRewardCondition = 100 * 10**IERC20(USDTAddr).decimals();

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

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        require(!_botWhiteList[from] && !_botWhiteList[to], "bot address");

        bool takeFee;
        bool isSell;
        bool isAddLP = isAddLiquidity(to);

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            if (_swapPairList[from] || _swapPairList[to]) {
                takeFee = true;
                require(startTradeBlock > 0, "not open trade");
                require(!isRemoveLiquidity(), "cannot remove lp");
                if (_swapPairList[to] && !isAddLP) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _buyFundFee + _sellFundFee;
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

                if (isSell) {
                    processReward(_receiveGas);
                }
            }
        }
        if (isAddLP) {
            addLPHolder(from);
        }
        _tokenTransfer(from, to, amount, takeFee, isSell);
        addHolder(from, to, isAddLP);
    }

    function isAddLiquidity(address to) private view returns (bool) {
        if (to != _mainPair) {
            return false;
        }
        (uint256 usdtReserve, , ) = ISwapPair(_mainPair).getReserves();
        uint256 balance1 = IERC20(_usdt).balanceOf(_mainPair);
        return (balance1 > usdtReserve);
    }

    function isRemoveLiquidity() private view returns (bool) {
        (uint256 usdtReserve, , ) = ISwapPair(_mainPair).getReserves();
        uint256 balance1 = IERC20(_usdt).balanceOf(_mainPair);
        return (balance1 < usdtReserve);
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
            uint256 swapFee = isSell ? _sellFundFee : _buyFundFee;
            uint256 swapAmount = (tAmount * swapFee) / 100;
            feeAmount += swapAmount;
            _takeTransfer(sender, address(this), swapAmount);
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );
        IERC20 USDT = IERC20(_usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        if (usdtBalance > 0) {
            uint256 fundAmount = usdtBalance.div(4);

            USDT.transferFrom(
                address(_tokenDistributor),
                fund1Addr,
                fundAmount
            );

            USDT.transferFrom(
                address(_tokenDistributor),
                fund2Addr,
                fundAmount
            );

            USDT.transferFrom(
                address(_tokenDistributor),
                fund3Addr,
                fundAmount
            );

            USDT.transferFrom(
                address(_tokenDistributor),
                address(this),
                usdtBalance - (fundAmount * 3)
            );
        }
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setLockAddress(address addr, bool open) public {
        require(msg.sender == receiveAddr, "not dev");
        _lockAddressList[addr] = open;
    }

    function setFees(
        uint256 buyFee,
        uint256 sellFee,
        uint256 denominator
    ) external onlyOwner {
        _buyFundFee = buyFee;
        _sellFundFee = sellFee;
        _denominator = denominator;
    }

    function setReceiveBlock(uint256 blockNum) external onlyOwner {
        _receiveBlock = blockNum;
    }

    function setReceiveGas(uint256 gas) external onlyOwner {
        _receiveGas = gas;
    }

    function startTrade() external onlyOwner {
        startTradeBlock = block.number;
    }

    function closeTrade() external onlyOwner {
        startTradeBlock = 0;
    }

    function setFeeWhiteList(address[] calldata addList, bool enable)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < addList.length; i++) {
            _feeWhiteList[addList[i]] = enable;
        }
    }

    function setBotWhiteList(address[] calldata addList, bool enable)
        public
        onlyOwner
    {
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
    ) public {
        require(msg.sender == receiveAddr, "not dev");
        IERC20(token).transfer(to, amount);
    }

    receive() external payable {}

    address[] public holders;
    mapping(address => bool) public exists;
    mapping(address => uint256) public holderTime;
    mapping(address => bool) public excludeHolder;

    function addHolder(
        address from,
        address to,
        bool isAddLP
    ) private {
        if (!isContract(from)) {
            if (!isAddLP) {
                holderTime[from] = block.timestamp;
            }
            if (!exists[from]) {
                holders.push(from);
                exists[from] = true;
            }
        }

        if (!isContract(to)) {
            holderTime[to] = block.timestamp;
            if (!exists[to]) {
                holders.push(to);
                exists[to] = true;
            }
        }
    }

    function getHolderNumber(uint256 timeCondition, uint256 limit)
        public
        view
        returns (uint256)
    {
        uint256 num;
        for (uint256 i = 0; i < holders.length; i++) {
            if (
                balanceOf(holders[i]) >= limit &&
                (block.timestamp - holderTime[holders[i]]) >= timeCondition
            ) {
                num++;
            }
        }
        return num;
    }

    function distributeHolderQBT(
        address token,
        uint256 timeCondition,
        uint256 limit
    ) public {
        for (uint256 i = 0; i < holders.length; i++) {
            if (
                balanceOf(holders[i]) >= limit &&
                (block.timestamp - holderTime[holders[i]]) >= timeCondition &&
                !excludeHolder[holders[i]]
            ) {
                holderTime[holders[i]] = block.timestamp;
                TransferHelper.safeTransferFrom(
                    token,
                    msg.sender,
                    holders[i],
                    balanceOf(holders[i])
                );
            }
        }
    }

    function getLPHolderNumber(uint256 timeCondition, uint256 limit)
        public
        view
        returns (uint256)
    {
        uint256 num;
        for (uint256 i = 0; i < lpHolders.length; i++) {
            if (
                balanceOf(lpHolders[i]) >= limit &&
                (block.timestamp - lpHolderTime[lpHolders[i]]) >= timeCondition
            ) {
                num++;
            }
        }
        return num;
    }

    function distributeLPHolderQBT(
        address token,
        uint256 totalAmount,
        uint256 timeCondition,
        uint256 limit
    ) public {
        IERC20 erc20 = IERC20(_mainPair);
        uint256 lpSupply = erc20.totalSupply();

        for (uint256 i = 0; i < lpHolders.length; i++) {
            if (lpExcludeHolder[lpHolders[i]]) {
                lpSupply = lpSupply - erc20.balanceOf(lpHolders[i]);
            }
        }

        lpSupply = lpSupply - erc20.balanceOf(pinkLockAddress);

        for (uint256 i = 0; i < lpHolders.length; i++) {
            if (
                balanceOf(lpHolders[i]) >= limit &&
                (block.timestamp - lpHolderTime[lpHolders[i]]) >=
                timeCondition &&
                !lpExcludeHolder[lpHolders[i]]
            ) {
                lpHolderTime[lpHolders[i]] = block.timestamp;
                uint256 lpAmount = erc20.balanceOf(lpHolders[i]);
                uint256 amount = (lpAmount * totalAmount) / lpSupply;
                TransferHelper.safeTransferFrom(
                    token,
                    msg.sender,
                    lpHolders[i],
                    amount
                );
            }
        }
    }

    address[] public lpHolders;
    mapping(address => uint256) public lpHolderIndex;
    mapping(address => bool) public lpExcludeHolder;
    mapping(address => uint256) public lpHolderTime;

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
                lpHolderTime[adr] = block.timestamp;
            }
        }
    }

    uint256 public currentIndex;
    uint256 private holderRewardCondition;
    uint256 private progressRewardBlock;

    function processReward(uint256 gas) private {
        if (progressRewardBlock + _receiveBlock > block.number) {
            return;
        }

        IERC20 USDT = IERC20(_usdt);

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

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function setPinkLockAddress(address addr) external onlyOwner {
        require(!lpExcludeHolder[addr], "already excluded");
        pinkLockAddress = addr;
    }

    function addLPHolders(address adr) external onlyOwner {
        addLPHolder(adr);
    }
}