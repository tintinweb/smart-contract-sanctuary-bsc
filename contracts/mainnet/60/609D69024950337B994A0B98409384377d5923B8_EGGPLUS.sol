/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.7.4;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != - 1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? - a : a;
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

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IPancakeSwapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeSwapRouter {
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IPancakeSwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
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
}


interface EGGNFT {
    function createNFT(
        address _to,
        uint256 _catId,
        bytes memory _data
    ) external returns (uint256 tokenId);

    function balanceOf(address owner) external view returns (uint256 balance);
}

contract Recv {
    IERC20 public token;
    IERC20 public usdt;

    constructor (IERC20 _token, IERC20 _usdt) public {
        token = _token;
        usdt = _usdt;
    }

    function withdraw() public {
        uint256 usdtBalance = usdt.balanceOf(address(this));
        if (usdtBalance > 0) {
            usdt.transfer(address(token), usdtBalance);
        }
        uint256 tokenBalance = token.balanceOf(address(this));
        if (tokenBalance > 0) {
            token.transfer(address(token), tokenBalance);
        }
    }
}

contract EGGPLUS is ERC20Detailed, Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    string public _name = "MOOPLUS";
    string public _symbol = "MOOPLUS";
    uint8 public _decimals = 8;

    uint256 private constant MAX = ~uint256(0);

    mapping(address => bool) _isFeeExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 public constant DECIMALS = 8;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 8;

    struct UserInfo {
        uint256 referTime;
        address parent;
        bool isShare;
        uint256 referIdoNum;
        bool shareRefund;
        uint256 idoAmount;
        bool idoRefund;
        uint256 buyAmount;
    }

    address[] public shareHolder;

    mapping(address => UserInfo) public userInfo;
    mapping(address => address[]) public userInviters;


    uint256 public liquidityFee = 50; //5%  only for buy
    uint256 public inviteFee = 100;//10% //only for buy
    uint256[] public REFERRAL_PERCENTS = [40, 20, 5, 5, 5, 5, 5, 5, 5, 5];

    uint256 public treasuryFee = 50;//5% only for sell
    uint256 public consensusFundFee = 25;//2.5% only for sell
    uint256 public daoFee = 50;//5% dao fee.only for sell
    uint256 public firePitFee = 25;//2.5% only for sell
    uint256 public feeDenominator = 1000;

    uint256 public totalInviteAmount = 0;
    uint256 public totalDaoAmount = 0;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public autoLiquidityReceiver;
    address public freeDaoAddress;
    address public treasuryReceiver;
    address public safuuInsuranceFundReceiver;
    address public idoAddress;

    address public firePit = ZERO;

    bool public swapEnabled = true;
    IPancakeSwapRouter public router;
    address public pair;

    Recv public recv;

    address public eggNFTAddress;

    IERC20 public usdt;
    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private TOTAL_GONS;
    uint256 private constant MAX_SUPPLY = 3250000000 * 10 ** DECIMALS;

    bool public _autoRebase;
    bool public _autoSwapBack;
    bool public _autoAddLiquidity;

    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _lastSwapBackTime;
    uint256 public _totalSupply;
    uint256 public _gonsPerFragment;
    uint256 public _beforegonsPerFragment;
    uint256 public pairBalance;
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;

    uint256 public startTradingTime;
    uint256 public autoLiquidityInterval = 60 minutes;
    uint256 public swapBackInterval = 240 minutes;

    uint256 public shareMx = 300 * 10 ** 18;
    uint256 public idoMx = 100 * 10 ** 18;
    uint256 public idoTotal = 0;
    bool public idoPaused = true;
    uint256 public startIdoTime;
    uint256 public idoInterval = 1 weeks;

    event parentInfo(
        address indexed childAddress,
        address indexed parentAddress
    );

    constructor(address _router, IERC20 _usdt, address _eggNFTAddress, address _idoAddress, address _autoLiquidityReceiver, address _treasuryReceiver, address _safuuInsuranceFundReceiver) ERC20Detailed(_name, _symbol, uint8(DECIMALS)) Ownable() {
        usdt = _usdt;
        eggNFTAddress = _eggNFTAddress;
        idoAddress = _idoAddress;
        treasuryReceiver = _treasuryReceiver;
        safuuInsuranceFundReceiver = _safuuInsuranceFundReceiver;
        autoLiquidityReceiver = _autoLiquidityReceiver;
        router = IPancakeSwapRouter(_router);

        pair = IPancakeSwapFactory(router.factory()).createPair(address(usdt), address(this));

        _totalSupply = 3520000 * 10 ** DECIMALS;
        TOTAL_GONS = MAX_UINT256 / 1e10 - (MAX_UINT256 / 1e10 % _totalSupply);
        _gonBalances[msg.sender] = TOTAL_GONS;
        emit Transfer(address(0x0), msg.sender, _totalSupply);
        _beforegonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        _allowedFragments[idoAddress][address(this)] = MAX;
        _allowedFragments[address(this)][address(router)] = MAX;
        usdt.approve(address(router), MAX);

        recv = new Recv(IERC20(this), usdt);

        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[idoAddress] = true;
        _isFeeExempt[autoLiquidityReceiver] = true;
        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[safuuInsuranceFundReceiver] = true;
        _isFeeExempt[firePit] = true;
    }

//用户可获得一个NFT
    function refundShare() public swapping {
        require(!isContract(msg.sender), "robot");
        require(startIdoTime != 0 && block.timestamp.sub(startIdoTime) > idoInterval, "ido have not ended");
        UserInfo storage user = userInfo[msg.sender];
        require(user.isShare && !user.shareRefund, "user have refunded");
        require(user.referIdoNum >= 10, "referIdoNum not good");
        uint256 uAmount = shareMx;
        user.shareRefund = true;
        usdt.transfer(msg.sender, uAmount);
        require(eggNFTAddress != address(0x0), "eggNFTAddress is 0x00");
        EGGNFT(eggNFTAddress).createNFT(msg.sender, 1, new bytes(0));
    }

    function takeShare() public swapping {
        require(!isContract(msg.sender), "robot");
        require(startIdoTime == 0 || block.timestamp.sub(startIdoTime) <= idoInterval, "ido have ended");
        if (userInfo[msg.sender].parent == address(0)) {
            referParent(owner());
        }
        UserInfo storage user = userInfo[msg.sender];
        require(!user.isShare, "user have joined the share");
        uint256 uAmount = shareMx;
        usdt.transferFrom(msg.sender, address(this), uAmount);
        user.isShare = true;
        shareHolder.push(msg.sender);
    }

    function claimIdo() public swapping {
        require(!isContract(msg.sender), "robot");
        require(block.timestamp.sub(startIdoTime) > idoInterval, "ido have not ended");
        UserInfo storage user = userInfo[msg.sender];
        require(!user.idoRefund, "user have refunded");
        require(user.idoAmount > 0, "user have not joined the ido");

        uint256 price = 50 * 10 ** DECIMALS;
        uint256 getAmount = price.mul(user.idoAmount).div(100 * 10 ** 18);
        user.idoRefund = true;
        _basicTransfer(idoAddress, msg.sender, getAmount);
    }

    function ido(uint256 uAmount) public swapping {
        require(!isContract(msg.sender), "robot");
        require(!idoPaused, "ido have paused");
        require(block.timestamp.sub(startIdoTime) <= idoInterval, "ido not start or have ended");
        uint256 uTotal = idoMx;
        UserInfo storage user = userInfo[msg.sender];
        if (user.isShare) {
            uTotal = 2 * uTotal;
        }
        require(uAmount % idoMx == 0 && uAmount >= idoMx, "uAmount error");
        require(user.idoAmount <= uTotal.sub(uAmount), "ido too big");
        usdt.transferFrom(msg.sender, idoAddress, uAmount);
        if (user.idoAmount == 0 && user.parent != address(0x0)) {
            UserInfo storage parent = userInfo[user.parent];
            parent.referIdoNum = parent.referIdoNum + 1;
        }
        user.idoAmount = user.idoAmount.add(uAmount);
        idoTotal = idoTotal.add(uAmount);
        require(idoTotal <= 2000000 * 10 ** 18, "ido have overflowed");
    }

    function setIdo(uint256 _time, uint256 _time2, bool _idoPaused) public onlyOwner {
        idoPaused = _idoPaused;
        if (_time > 0) {
            startIdoTime = _time;
        } else {
            startIdoTime = block.timestamp;
        }
        if (_time2 > 0) {
            idoInterval = _time2;
        }
    }

    function setEggNFTAddress(address _eggNFTAddress) public onlyOwner {
        eggNFTAddress = _eggNFTAddress;
    }

//绑定上家
    function referParent(address parentAddress) public {
        require(
            parentAddress != msg.sender,
            "Error: parent address can not equal sender!"
        );
        require(
            userInfo[msg.sender].parent == address(0),
            "Error: sender must be has no parent!"
        );
        require(
            parentAddress == owner() || userInfo[parentAddress].parent != address(0),
            "Error: parentAddress must be has parent!"
        );
        require(
            !isContract(parentAddress),
            "Error: parent address must be a address!"
        );
        userInfo[msg.sender].parent = parentAddress;
        userInfo[msg.sender].referTime = block.timestamp;
        userInviters[parentAddress].push(msg.sender);
        emit parentInfo(msg.sender, parentAddress);
    }

    function manualRebase() external {
        require(shouldRebase(), "rebase not required");
        rebase();
    }

    function rebase() internal {

        if (inSwap) return;
        uint256 rebaseRate = 21447;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(3 minutes);
        uint256 epoch = times.mul(3);


        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
            .mul((10 ** RATE_DECIMALS).add(rebaseRate))
            .div(10 ** RATE_DECIMALS);
        }

        _beforegonsPerFragment = _gonsPerFragment;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(3 minutes));

        emit LogRebase(epoch, _totalSupply);
    }

    function setStartTradingTime(uint256 _time) public onlyOwner {
        startTradingTime = _time;
        if (_time > 0) {
            _lastAddLiquidityTime = _time;
            if (_lastRebasedTime == 0) {
                _lastRebasedTime = _time;
            }
        }
    }

    function transfer(address to, uint256 value)
    external
    override
    validRecipient(to)
    returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {

        if (_allowedFragments[from][msg.sender] != uint256(- 1)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
            msg.sender
            ].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        if (from == pair) {
            pairBalance = pairBalance.sub(amount);
        } else {
            _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        }
        if (to == pair) {
            pairBalance = pairBalance.add(amount);
        } else {
            _gonBalances[to] = _gonBalances[to].add(gonAmount);
        }
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {

        require(!blacklist[sender], "in_blacklist");
        if (inSwap || !shouldTakeFee(sender, recipient)) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (shouldRebase()) {
            rebase();
        }

        if (shouldAddLiquidity()) {
            addLiquidity();
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        if (recipient == pair && _isFeeExempt[sender] == false && _isFeeExempt[recipient] == false) {
            //only can sell 99% of balance
            if (gonAmount >= _gonBalances[sender].div(1000).mul(999)) {
                gonAmount = _gonBalances[sender].div(1000).mul(999);
            }
        }
        if (sender == pair) {
            pairBalance = pairBalance.sub(amount);
            if (userInfo[recipient].parent != address(0x0)) {
                userInfo[recipient].buyAmount = userInfo[recipient].buyAmount.add(amount);
            }
        } else {
            _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        }
        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
        ? takeFee(sender, recipient, gonAmount)
        : gonAmount;

        if (recipient == pair) {
            pairBalance = pairBalance.add(gonAmountReceived.div(_gonsPerFragment));
        } else {
            _gonBalances[recipient] = _gonBalances[recipient].add(gonAmountReceived);
        }
        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(_gonsPerFragment)
        );
        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal returns (uint256) {
        uint256 _totalFee = 0;
        uint256 _robotsFee = 550;
        //sell token or transfer token
        if (sender != pair) {
            _totalFee = firePitFee.add(treasuryFee).add(daoFee).add(consensusFundFee);
            //when sell token .
            uint256 fee = gonAmount.div(feeDenominator).mul(firePitFee);
            _gonBalances[firePit] = _gonBalances[firePit].add(fee);
            emit Transfer(sender, firePit, fee.div(_gonsPerFragment));

            fee = gonAmount.div(feeDenominator).mul(treasuryFee.add(consensusFundFee));
            _gonBalances[address(this)] = _gonBalances[address(this)].add(fee);
            emit Transfer(sender, address(this), fee.div(_gonsPerFragment));

            fee = gonAmount.div(feeDenominator).mul(daoFee);
            _gonBalances[freeDaoAddress] = _gonBalances[freeDaoAddress].add(fee);
            emit Transfer(sender, freeDaoAddress, fee.div(_gonsPerFragment));
            totalDaoAmount = totalDaoAmount.add(fee.div(_gonsPerFragment));

        }
        if (sender == pair) {//when buy token
            _totalFee = inviteFee.add(liquidityFee);
            uint256 fee = gonAmount.div(feeDenominator).mul(liquidityFee);
            _gonBalances[autoLiquidityReceiver] = _gonBalances[autoLiquidityReceiver].add(fee);
            emit Transfer(sender, autoLiquidityReceiver, fee.div(_gonsPerFragment));

            _takeInviterFee(sender, recipient, gonAmount);
            totalInviteAmount = totalInviteAmount.add(gonAmount.div(_gonsPerFragment).mul(inviteFee).div(feeDenominator));

        }
        if (recipient == pair || sender == pair) {
            //sell token
            require(startTradingTime > 0 && block.timestamp >= startTradingTime, "can not trade now!");
            if (block.timestamp <= startTradingTime + 6) {
                _totalFee = _totalFee.add(_robotsFee);
                _gonBalances[autoLiquidityReceiver] = _gonBalances[autoLiquidityReceiver].add(gonAmount.div(feeDenominator).mul(_robotsFee));
                emit Transfer(sender, autoLiquidityReceiver, gonAmount.div(feeDenominator).mul(_robotsFee).div(_gonsPerFragment));
            }
        }
        uint256 feeAmount = gonAmount.div(feeDenominator).mul(_totalFee);
        return gonAmount.sub(feeAmount);
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 amount
    ) private returns (uint256) {
        uint256 tFee = amount.div(feeDenominator).mul(inviteFee);
        address cur;
        if (sender == pair) {
            cur = recipient;
        } else {
            cur = sender;
        }
        uint256 accurAmount = 0;
        for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
            cur = userInfo[cur].parent;
            if (cur == address(0)) {
                break;
            }
            uint256 curTAmount = amount.div(feeDenominator).mul(REFERRAL_PERCENTS[i]);
            accurAmount = accurAmount.add(curTAmount);
            _gonBalances[cur] = _gonBalances[cur].add(curTAmount);
            emit Transfer(sender, cur, curTAmount.div(_gonsPerFragment));
        }
        if (tFee.sub(accurAmount) > 0) {
            _gonBalances[address(this)] = _gonBalances[address(this)].add(tFee.sub(accurAmount));
            emit Transfer(sender, address(this), tFee.sub(accurAmount).div(_gonsPerFragment));
        }
        return tFee;
    }

    function swapBack() internal swapping {
        uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);
        if (amountToSwap == 0) {
            return;
        }
        uint256 initialUsdt = usdt.balanceOf(address(this));
        swapTokensForUSDT(amountToSwap);
        uint256 afterUsdt = usdt.balanceOf(address(this));
        uint256 addUsdt = afterUsdt.sub(initialUsdt);
        usdt.transfer(treasuryReceiver, addUsdt.mul(treasuryFee).div(treasuryFee + consensusFundFee));
        usdt.transfer(safuuInsuranceFundReceiver, addUsdt.mul(consensusFundFee).div(treasuryFee + consensusFundFee));

        _lastSwapBackTime = block.timestamp;
    }


    function shouldTakeFee(address from, address to)
    internal
    view
    returns (bool)
    {
        return
        // (pair == from || pair == to) &&
        !_isFeeExempt[from] && !_isFeeExempt[to];
    }

    function shouldRebase() internal view returns (bool) {
        return
        _autoRebase &&
        (_totalSupply < MAX_SUPPLY) &&
        msg.sender != pair &&
        !inSwap &&
        block.timestamp >= (_lastRebasedTime + 3 minutes);
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
        _autoAddLiquidity &&
        !inSwap &&
        msg.sender != pair &&
        _lastAddLiquidityTime > 0 &&
        block.timestamp >= (_lastAddLiquidityTime + autoLiquidityInterval);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
        _autoSwapBack && !inSwap &&
        msg.sender != pair &&
        _lastSwapBackTime > 0 &&
        block.timestamp >= (_lastSwapBackTime + swapBackInterval);
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _flag;
        }
    }

    function setAutoSwapBack(bool _flag) external onlyOwner {
        if (_flag) {
            _autoSwapBack = _flag;
            _lastSwapBackTime = block.timestamp;
        } else {
            _autoSwapBack = _flag;
        }
    }

    function setAutoLiquidityInterval(uint256 _minutes) external onlyOwner {
        require(_minutes > 0, "invalid time");
        autoLiquidityInterval = _minutes * 1 minutes;
    }

    function setSwapBackInterval(uint256 _minutes) external onlyOwner {
        require(_minutes > 0, "invalid time");
        swapBackInterval = _minutes * 1 minutes;
    }

    function setAutoAddLiquidity(bool _flag) external onlyOwner {
        if (_flag) {
            _autoAddLiquidity = _flag;
            _lastAddLiquidityTime = block.timestamp;
        } else {
            _autoAddLiquidity = _flag;
        }
    }

    function setFeeReceivers(
        address _idoAddress,
        address _autoLiquidityReceiver,
        address _treasuryReceiver,
        address _safuuInsuranceFundReceiver,
        address _freeDaoAddress,
        address _firePit
    ) external onlyOwner {
        idoAddress = _idoAddress;
        autoLiquidityReceiver = _autoLiquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
        safuuInsuranceFundReceiver = _safuuInsuranceFundReceiver;
        freeDaoAddress = _freeDaoAddress;
        firePit = _firePit;

        _isFeeExempt[idoAddress] = true;
        _isFeeExempt[autoLiquidityReceiver] = true;
        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[safuuInsuranceFundReceiver] = true;
        _isFeeExempt[freeDaoAddress] = true;
        _isFeeExempt[firePit] = true;
    }

    function rescueToken(
        address token,
        address recipient,
        uint256 amount
    ) public onlyOwner {
        IERC20(token).transfer(recipient, amount);
    }

    function allowance(address owner_, address spender)
    external
    view
    override
    returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
    external
    returns (bool)
    {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
        spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value)
    external
    override
    returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
        (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(
            _gonsPerFragment
        );
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function manualSync() external {
        IPancakeSwapPair(pair).sync();
    }

    function setWhitelist(address[] memory _addrs) external onlyOwner {
        for (uint256 i = 0; i < _addrs.length; i++) {
            _isFeeExempt[_addrs[i]] = true;
        }

    }

    function setBlacklist(address _address, bool _flag) external onlyOwner {
        blacklist[_address] = _flag;
    }


    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address who) public view override returns (uint256) {
        if (who == pair) {
            return pairBalance;
        } else {
            return _gonBalances[who].div(_gonsPerFragment);
        }
    }

    function addLiquidity() internal swapping {
        uint256 autoLiquidityAmount = _gonBalances[autoLiquidityReceiver].div(
            _gonsPerFragment
        );
        if (treasuryReceiver != address(0) && autoLiquidityAmount > 0) {
            _gonBalances[address(this)] = _gonBalances[address(this)].add(
                _gonBalances[autoLiquidityReceiver]
            );
            _gonBalances[autoLiquidityReceiver] = 0;
            emit Transfer(autoLiquidityReceiver, address(this), autoLiquidityAmount);

            swapAndLiquify(autoLiquidityAmount);
            _lastAddLiquidityTime = block.timestamp;
        }

    }

    function swapAndLiquify(uint256 contractTokenBalance) private {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half, "sub half");

        uint256 initialUsdt = usdt.balanceOf(address(this));
        swapTokensForUSDT(half);
        uint256 afterUsdt = usdt.balanceOf(address(this));
        uint256 addUsdt = afterUsdt.sub(initialUsdt);

        addLiquidityUSDT(otherHalf, addUsdt);
    }

    function swapTokensForUSDT(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdt);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(recv),
            block.timestamp
        );
        recv.withdraw();
    }

    function addLiquidityUSDT(uint256 tokenAmount, uint256 uAmount) private {
        // approve token transfer to cover all possible scenarios
        router.addLiquidity(
            address(this),
            address(usdt),
            tokenAmount,
            uAmount,
            0,
            0,
            autoLiquidityReceiver,
            block.timestamp
        );
    }

    function getEGGToUSD() public view returns (uint256){
        if (pairBalance == 0) {
            return 0;
        }
        return usdt.balanceOf(pair).mul(10 ** decimals()).div(pairBalance);
    }


    function getSysInfo() public view returns (uint256[18] memory){
        uint256 price = getEGGToUSD();
        uint256 fireBalance = _gonBalances[DEAD].add(_gonBalances[ZERO]).div(_gonsPerFragment);
        uint256[18] memory d = [
        price, _totalSupply, getCirculatingSupply(), pairBalance, fireBalance, _lastRebasedTime,
        shareMx, shareHolder.length, idoMx, idoTotal, startIdoTime, idoInterval, startTradingTime,
        totalDaoAmount, totalInviteAmount,
        balanceOf(treasuryReceiver), balanceOf(safuuInsuranceFundReceiver), balanceOf(freeDaoAddress)
        ];
        return (d);
    }

    function getUserInfo(address account) public view returns (address, bool, bool, bool, uint256[7] memory){
        UserInfo storage user = userInfo[account];
        address[] storage inviters = userInviters[account];
        uint256 totalTeam = 0;
        for (uint256 i = 0; i < inviters.length; i++) {
            totalTeam = totalTeam.add(userInfo[inviters[i]].buyAmount);
        }
        uint256 nftAmount = 0;
        if (eggNFTAddress != address(0x0)) {
            nftAmount = EGGNFT(eggNFTAddress).balanceOf(account);
        }
        uint256[7] memory d = [user.referTime, user.referIdoNum, user.idoAmount, user.buyAmount, inviters.length, totalTeam, nftAmount];
        return (user.parent, user.isShare, user.shareRefund, user.idoRefund, d);
    }

    function getReferSize(address account) public view returns (uint256){
        return userInviters[account].length;
    }

    function getReferList(address account) public view returns (uint256[] memory, address[] memory, uint256[] memory, uint256[] memory){
        address[] storage inviters = userInviters[account];
        uint256[] memory referTimes = new uint256[](inviters.length);
        address[] memory users = new address[](inviters.length);
        uint256[] memory buyAmounts = new uint256[](inviters.length);
        uint256[] memory idoAmounts = new uint256[](inviters.length);
        for (uint256 i = 0; i < inviters.length; i++) {
            referTimes[i] = userInfo[inviters[i]].referTime;
            users[i] = inviters[i];
            buyAmounts[i] = userInfo[inviters[i]].buyAmount;
            idoAmounts[i] = userInfo[inviters[i]].idoAmount;
        }
        return (referTimes, users, buyAmounts, idoAmounts);
    }

    function getReferCompound(address account) public view returns(uint256) {
        uint256 totalBalances = 0;
        address[] storage inviters = userInviters[account];
        for(uint256 i=0;i < inviters.length; i++){
            totalBalances=totalBalances.add(_gonBalances[inviters[i]]);
        }
        uint256 reward = _beforegonsPerFragment.sub(_gonsPerFragment).mul(totalBalances).div(_gonsPerFragment).div(_beforegonsPerFragment);
        return reward.mul(200).div(1000);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {size := extcodesize(addr)}
        return size > 0;
    }

}