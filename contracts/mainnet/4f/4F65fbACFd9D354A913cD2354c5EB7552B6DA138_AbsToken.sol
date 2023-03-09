/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.16;

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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
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

interface ISwapPair {
    function sync() external;
}

contract TokenDistributor {
    constructor(address token) {
        //将token代币授权给创建合约的地址，数量为最大整数，可以认为是无限大，在本合约中是USDT
        //因为swap合约要求，兑换的接收地址不能是swapPair的两个代币合约地址，所以在非主链币交易对的时候，
        //都需要一个类似这样的中转合约来接收兑换的代币，然后再将中转合约地址里的代币转出，需要调用transferFrom方法，该方法需要授权
        //当然，中转合约还有别的写法
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}

contract AbsToken is IERC20, Ownable {
    mapping(address => mapping(address => uint256)) private _allowances;

    //基金会营销钱包
    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    //买入的邀请税
    uint256 public _buyInviteFee = 2;
    //买入的基金会营销税
    uint256 public _buyFundFee = 2;
    //卖出的邀请税
    uint256 public _sellInviteFee = 3;
    //卖出的基金会营销税
    uint256 public _sellFundFee = 2;

    //白名单列表
    mapping(address => bool) public _feeWhiteList;

    //实际总量，复利的时候，该总量会变大
    uint256 public _tTotal;
    //根据系数放大后的总量，合约部署后，不会再改变，_tTotal变大，系数会变小，每个人的余额_rOwned[account]/系数，会变大
    uint256 public _rTotal;
    //放大比例后的数量，初始_rOwned[account]=_tOwned[account]*_rTotal/_tTotal
    mapping(address => uint256) public _rOwned;
    //真实拥有的数量，一般初始化或者不参与复利分红时有用
    mapping(address => uint256) public _tOwned;
    uint256 public constant MAX = ~uint256(0);

    mapping(address => bool) public _swapPairList;

    //关系链
    mapping(address => address) public inviter;

    //利率的分母
    uint256 private constant AprDivBase = 100000000;

    //防止合约卖币时，方法重入，陷入无限递归
    bool private inSwap;

    TokenDistributor public _tokenDistributor;
    address public _usdt;
    ISwapRouter public _swapRouter;

    constructor(bool prod) {
        _name = "ELX";
        _symbol = "ELX";
        _decimals = 18;
        uint256 Supply = 2100 * 100_000_000;
        address ReceivedAddress = msg.sender;
        ISwapRouter swapRouter;
        if (prod) {
            //主网
            _usdt = 0x55d398326f99059fF775485246999027B3197955;
            swapRouter = ISwapRouter(
                0x10ED43C718714eb63d5aA57B78B54704E256024E
            );
        } else {
            //测试网
            _usdt = 0x6B0AA926f4Bd81669aE269d8FE0124F5060A6aa9;
            swapRouter = ISwapRouter(
                0xD99D1c33F9fC3444f8101754aBC46c52416550D1
            );
        }

        _swapRouter = swapRouter;
        //因为要回流，提前将本合约地址的本代币授权给路由地址，数量为最大整数
        _allowances[address(this)][address(swapRouter)] = MAX;

        //创建USDT交易对
        address usdtPair = ISwapFactory(swapRouter.factory()).createPair(
            address(this),
            _usdt
        );
        _swapPairList[usdtPair] = true;

        //实际总量
        uint256 tTotal = Supply * 10**_decimals;
        //
        uint256 base = AprDivBase * 100;
        //放大比例后的总量，MAX/base后，最大的能够整除 tTotal 的整数，rTotal/tTotal=比例系数
        uint256 rTotal = MAX / base - ((MAX / base) % tTotal);
        _rOwned[ReceivedAddress] = rTotal;
        _tOwned[ReceivedAddress] = tTotal;
        emit Transfer(address(0), ReceivedAddress, tTotal);
        _rTotal = rTotal;
        _tTotal = tTotal;

        //设置发展基金地址
        fundAddress = msg.sender;

        //白名单
        _feeWhiteList[fundAddress] = true;

        _feeWhiteList[ReceivedAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(swapRouter)] = true;

        //创建接收合约兑换后接收USDT的中转合约
        _tokenDistributor = new TokenDistributor(_usdt);
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

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
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
        //都授权最大值了，转账后，没必要减少授权额度
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
            _allowances[sender][msg.sender] -
            amount;
        }
        return true;
    }

    //利用公式计算代币余额，参数是根据系数放大后的值
    function tokenFromReflection(uint256 rAmount)
    public
    view
    returns (uint256)
    {
        //放大系数
        uint256 currentRate = _getRate();
        //系数放大后的数值/系数，就是实际持币数量，在这里，用户的rAmount不变，系数会慢慢变小，所以余额会变多
        return rAmount / currentRate;
    }

    function _getRate() public view returns (uint256) {
        //一般不会出现这个情况
        if (_rTotal < _tTotal) {
            return 1;
        }
        //_rTotal不变，_tTotal变大，返回的系数会变小
        return _rTotal / _tTotal;
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
        //余额不足，这里一般是配合dapp使用的
        require(balance >= amount, "balanceNotEnough");

        // if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
        //     //地址不能把币都转出去，保留持币地址
        //     uint256 maxSellAmount = (balance * 99999) / 100000;
        //     if (amount > maxSellAmount) {
        //         amount = maxSellAmount;
        //     }
        // }

        bool takeFee;
        bool isBuy;

        //买入卖出操作
        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;
                if (_swapPairList[from]) {
                    isBuy = true;
                }
            }
        } else {
            //转账绑定关系

            //to未绑定、from 、to都非合约地址
            bool shouldInvite = (inviter[to] == address(0) &&
            !isContract(from) &&
            !isContract(to) &&
            amount == 1 * 10**(_decimals - 2));
            //必须等于0.01
            if (shouldInvite) {
                inviter[to] = from;
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isBuy);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isBuy
    ) private {
        //扣减实际数量
        if (_tOwned[sender] > tAmount) {
            _tOwned[sender] -= tAmount;
        } else {
            _tOwned[sender] = 0;
        }

        //当前的余额系数
        uint256 currentRate = _getRate();
        //扣减放大系数后的数量
        _rOwned[sender] = _rOwned[sender] - tAmount * currentRate;

        uint256 feeAmount;
        if (takeFee) {
            if (isBuy) {
                //处理买入税

                //买入基金营销税
                uint256 fundAmount = (tAmount * _buyFundFee) / 100;
                if (fundAmount > 0) {
                    feeAmount += fundAmount;
                    _takeTransfer(sender, fundAddress, fundAmount, currentRate);
                }

                //买入邀请税
                uint256 inviteAmount = (tAmount * _buyInviteFee) / 100;
                if (inviteAmount > 0) {
                    feeAmount += inviteAmount;
                    address cur = recipient;

                    for (uint256 i = 0; i < 10; i++) {
                        cur = inviter[cur];
                        if (cur == address(0)) {
                            //如果没有推荐地址，回流基金会
                            cur = fundAddress;
                        }
                        _takeTransfer(sender,cur,inviteAmount / 10,currentRate);
                    }
                }
            } else {
                //处理卖出税
                if (!inSwap) {
                    inSwap = true;

                    //基金营销税
                    uint256 fundAmount = (tAmount * _sellFundFee) / 100;
                    if (fundAmount > 0) {
                        feeAmount += fundAmount;
                        _takeTransfer(
                            sender,
                            fundAddress,
                            fundAmount,
                            currentRate
                        );
                    }

                    //邀请税
                    uint256 inviteAmount = (tAmount * _sellInviteFee) / 100;
                    if (inviteAmount > 0) {
                        feeAmount += inviteAmount;
                        _takeTransfer(
                            sender,
                            address(this),
                            inviteAmount,
                            currentRate
                        );

                        address usdt = _usdt;
                        address tokenDistributor = address(_tokenDistributor);
                        address[] memory path = new address[](2);
                        path[0] = address(this);
                        path[1] = usdt;
                        //兑换USDT，不能当前合约地址接收，只能中转合约地址接收，然后分配给上级钱包地址
                        _swapRouter
                        .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                            inviteAmount,
                            0,
                            path,
                            tokenDistributor,
                            block.timestamp
                        );

                        IERC20 USDT = IERC20(usdt);
                        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
                        //USDT分配给上级 10代均分U
                        uint256 fundUsdt = usdtBalance / 10;

                        if (fundUsdt > 0) {
                            address cur = sender;
                            for (uint256 i = 0; i < 10; i++) {
                                cur = inviter[cur];
                                if (cur == address(0)) {
                                    //如果没有推荐地址，回流基金会
                                    cur = fundAddress;
                                }

                                USDT.transferFrom(tokenDistributor,cur,fundUsdt);
                            }
                        }
                    }

                    inSwap = false;
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount, currentRate);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        _tOwned[to] += tAmount;

        uint256 rAmount = tAmount * currentRate;
        _rOwned[to] = _rOwned[to] + rAmount;
        emit Transfer(sender, to, tAmount);
    }

    receive() external payable {}

    function claimBalance() external onlyOwner {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(fundAddress, amount);
    }

    //修改基金地址
    function changeFundAddress(address newFundAddress) public onlyOwner {
        fundAddress = newFundAddress;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setBuyFee(uint256 buyInviteFee, uint256 buyFundFee)
    external
    onlyOwner
    {
        _buyInviteFee = buyInviteFee;
        _buyFundFee = buyFundFee;
    }

    function setSellFee(uint256 sellInviteFee, uint256 sellFundFee)
    external
    onlyOwner
    {
        _sellInviteFee = sellInviteFee;
        _sellFundFee = sellFundFee;
    }
}