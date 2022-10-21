/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: MIT

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
        require(b != -1 || a != MIN_INT256);

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
        return a < 0 ? -a : a;
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

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
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

    function mint(address to) external returns (uint256 liquidity);

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

interface IPancakeSwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

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

interface IPancakeSwapFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

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

interface IDao {
    function getRelations(address _address, uint256 amount)
        external
        returns (address[] memory);

    function setNpReceive(address account) external;

    function payToken() external view returns (address);

    function notifyPerformance(address recommend, uint256 amount) external;
}

interface IPool {
    function setReward(uint256 amount) external;

    //function notifyPerformance(address recommend, uint256 amount) external;
}

interface ITreasury {
    function swapBack() external;

    function addLiquidity(uint256 autoLiquidityAmount) external;
}

contract NPCToken is ERC20Detailed, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    string public _name = "NPCash";
    string public _symbol = "NPC";
    uint8 public _decimals = 8;

    mapping(address => bool) _isFeeExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 public constant DECIMALS = 8;

    uint256 public liquidityFee = 30;
    uint256 public minerFee = 50; //2.5% only for sell
    uint256 public bossFee = 30;
    uint256 public inviteFee = 100; //10% //only for buy
    uint256 public feeDenominator = 1000;
    uint256 public totalInviteAmount = 0;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public autoLiquidityReceiver;
    address public minerPool;
    address public bossPool;
    address public foundation;
    bool public swapEnabled = false;
    IPancakeSwapRouter public router;
    address public pair;
    address public usdtAddress;
    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private constant MAX_SUPPLY = 10**19;

    bool public _autoSwapBack;
    bool public _autoAddLiquidity;
    bool public _notify;
    uint256 public _lastAddLiquidityTime;
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;
    address public daoAddress;
    uint256 public autoLiquidityInterval;

    constructor(
        address _swapRouter,
        address _daoAddress,
        address _autoLiquidityReceiver,
        address _minerPool,
        address _boosPool,
        address _foundation
    ) ERC20Detailed(_name, _symbol, uint8(DECIMALS)) Ownable() {
        require(_swapRouter != address(0), "invalid swap router address");
        require(_daoAddress != address(0), "invalid  dao address");
        daoAddress = _daoAddress;
        usdtAddress = IDao(_daoAddress).payToken();
        router = IPancakeSwapRouter(_swapRouter);
        pair = IPancakeSwapFactory(router.factory()).createPair(
            usdtAddress,
            address(this)
        );
        autoLiquidityReceiver = _autoLiquidityReceiver;
        minerPool = _minerPool;
        bossPool = _boosPool;
        foundation = _foundation;

        _gonBalances[msg.sender] = MAX_SUPPLY;
        _autoSwapBack = true;
        _autoAddLiquidity = true;
        _notify = true;
        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[daoAddress] = true;
        _isFeeExempt[minerPool] = true;
        _isFeeExempt[bossPool] = true;
        _isFeeExempt[autoLiquidityReceiver] = true;
        autoLiquidityInterval = 10 minutes;

        emit Transfer(address(0x0), msg.sender, MAX_SUPPLY);
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
        if (_allowedFragments[from][msg.sender] != uint256(-1)) {
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
        _gonBalances[from] = _gonBalances[from].sub(amount);

        _gonBalances[to] = _gonBalances[to].add(amount);

        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(!blacklist[sender] && !blacklist[recipient], "in_blacklist");
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (shouldAddLiquidity()) {
            addLiquidity();
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        uint256 gonAmount = amount;
        if (
            recipient == pair &&
            _isFeeExempt[sender] == false &&
            _isFeeExempt[recipient] == false
        ) {
            if (gonAmount >= _gonBalances[sender].div(1000).mul(999)) {
                gonAmount = _gonBalances[sender].div(1000).mul(999);
            }
        }
        if (sender == pair) {
            if (shouldNotify()) {
                IDao(daoAddress).notifyPerformance(recipient, amount);
            }
        }
        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);

        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, gonAmount)
            : gonAmount;

        _gonBalances[recipient] = _gonBalances[recipient].add(
            gonAmountReceived
        );

        if (isContract(daoAddress) && amount > 0) {
            IDao(daoAddress).setNpReceive(recipient);
        }

        emit Transfer(sender, recipient, gonAmountReceived);
        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal returns (uint256) {
        uint256 _burn = 20;
        uint256 _totalFee = _burn;
        _gonBalances[DEAD] = _gonBalances[DEAD].add(
            gonAmount.div(feeDenominator).mul(_burn)
        );

        emit Transfer(sender, DEAD, gonAmount.div(feeDenominator).mul(_burn));

        //sell token or buy token
        if (recipient == pair || sender == pair) {
            require(swapEnabled, "can not trade now!");
            //Liquidity
            _totalFee = _totalFee.add(liquidityFee);
            _gonBalances[autoLiquidityReceiver] = _gonBalances[
                autoLiquidityReceiver
            ].add(gonAmount.div(feeDenominator).mul(liquidityFee));

            emit Transfer(
                sender,
                autoLiquidityReceiver,
                gonAmount.div(feeDenominator).mul(liquidityFee)
            );

            //buy token
            if (sender == pair) {
                _totalFee = _totalFee.add(inviteFee);
                totalInviteAmount = totalInviteAmount.add(
                    gonAmount.mul(inviteFee).div(feeDenominator)
                );
                address[] memory _parents = IDao(daoAddress).getRelations(
                    recipient,
                    gonAmount
                );
                for (uint8 i = 0; i < _parents.length; i++) {
                    uint256 _parentFee = gonAmount.mul(5).div(1000);
                    if (i == 0) {
                        _parentFee = gonAmount.mul(4).div(100);
                    }
                    if (i == 1) {
                        _parentFee = gonAmount.mul(2).div(100);
                    }
                    _gonBalances[_parents[i]] = _gonBalances[_parents[i]].add(
                        _parentFee
                    );
                    emit Transfer(recipient, _parents[i], _parentFee);
                }

                //sell token
            } else {
                uint256 foundationFee = 20;
                _totalFee = _totalFee.add(foundationFee).add(minerFee).add(
                    bossFee
                ); //foundation
                _gonBalances[foundation] = _gonBalances[foundation].add(
                    gonAmount.div(feeDenominator).mul(foundationFee)
                );
                emit Transfer(
                    sender,
                    foundation,
                    gonAmount.div(feeDenominator).mul(foundationFee)
                );
                _gonBalances[minerPool] = _gonBalances[minerPool].add(
                    gonAmount.div(feeDenominator).mul(minerFee)
                );

                emit Transfer(
                    sender,
                    minerPool,
                    gonAmount.div(feeDenominator).mul(minerFee)
                );
                if (isContract(minerPool)) {
                    IPool(minerPool).setReward(
                        gonAmount.mul(minerFee).div(feeDenominator)
                    );
                }

                _gonBalances[bossPool] = _gonBalances[bossPool].add(
                    gonAmount.div(feeDenominator).mul(bossFee)
                );

                emit Transfer(
                    sender,
                    bossPool,
                    gonAmount.div(feeDenominator).mul(bossFee)
                );

                if (isContract(bossPool)) {
                    IPool(bossPool).setReward(gonAmount.mul(bossFee));
                }
            }
            //transfer token
        } else {
            uint256 foundationFee = 30;
            _totalFee = _totalFee.add(foundationFee); //foundation

            _gonBalances[foundation] = _gonBalances[foundation].add(
                gonAmount.div(feeDenominator).mul(foundationFee)
            );

            emit Transfer(
                sender,
                foundation,
                gonAmount.div(feeDenominator).mul(foundationFee)
            );
        }

        uint256 feeAmount = gonAmount.div(feeDenominator).mul(_totalFee);

        return gonAmount.sub(feeAmount);
    }

    function addLiquidity() internal swapping {
        uint256 autoLiquidityAmount = _gonBalances[autoLiquidityReceiver];
        if (autoLiquidityAmount > 10**DECIMALS * 10) {
            ITreasury(autoLiquidityReceiver).addLiquidity(autoLiquidityAmount);
            _lastAddLiquidityTime = block.timestamp;
        }
    }

    function swapBack() internal swapping {
        if (autoLiquidityReceiver != address(0)) {
            ITreasury(autoLiquidityReceiver).swapBack();
        }
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

    function shouldNotify() internal view returns (bool) {
        return _notify;
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
        return _autoSwapBack && !inSwap && msg.sender != pair;
    }

    function setAutoSwapBack(bool _flag) external onlyOwner {
        _autoSwapBack = _flag;
    }

    function setNotify(bool _flag) external onlyOwner {
        _notify = _flag;
    }

    function setTradeStatus(bool _flag) external onlyOwner {
        swapEnabled = _flag;
        if (_flag) {
            _lastAddLiquidityTime = block.timestamp;
        }
    }

    function setAutoLiquidityInterval(uint256 _minutes) external onlyOwner {
        require(_minutes > 0, "invalid time");
        autoLiquidityInterval = _minutes * 1 minutes;
    }

    function setAutoAddLiquidity(bool _flag) external onlyOwner {
        if (_flag) {
            _autoAddLiquidity = _flag;
            _lastAddLiquidityTime = block.timestamp;
        } else {
            _autoAddLiquidity = _flag;
        }
    }

    function setDaoAddress(address _address) external onlyOwner {
        require(_address != address(0), "invalid address");

        daoAddress = _address;
        _isFeeExempt[daoAddress] = true;
    }

    function setTreasuryAddress(address _address) external onlyOwner {
        require(_address != address(0), "invalid address");
        autoLiquidityReceiver = _address;
        _isFeeExempt[autoLiquidityReceiver] = true;
        _allowedFragments[autoLiquidityReceiver][address(router)] = uint256(-1);
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
        return (MAX_SUPPLY.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO]));
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function manualSync() external {
        IPancakeSwapPair(pair).sync();
    }

    function setFeeReceivers(
        address _bossPool,
        address _minerPool,
        address _foundation
    ) external onlyOwner {
        bossPool = _bossPool;
        minerPool = _minerPool;
        foundation = _foundation;
        _isFeeExempt[bossPool] = true;
        _isFeeExempt[minerPool] = true;
        _isFeeExempt[foundation] = true;
    }

    function setWhitelist(address[] memory _addrs, bool _flag)
        external
        onlyOwner
    {
        require(_addrs.length > 0);
        for (uint256 i = 0; i < _addrs.length; i++) {
            _isFeeExempt[_addrs[i]] = _flag;
        }
    }

    function setBlacklist(address _address, bool _flag) external onlyOwner {
        blacklist[_address] = _flag;
    }

    function totalSupply() external pure override returns (uint256) {
        return MAX_SUPPLY;
    }

    function balanceOf(address who) external view override returns (uint256) {
        return _gonBalances[who];
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}