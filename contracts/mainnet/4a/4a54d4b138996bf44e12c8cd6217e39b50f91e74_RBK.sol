/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

// SPDX-License-Identifier: MIT
// RebaseBunnyKingdom by https://msgsender.io

pragma solidity ^0.7.6;

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

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }


    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }


    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }


    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IMsgWrap {
    function swapBack() external;

    function addLiquidity(uint256 autoLiquidityAmount) external;

    function withdrawToToken(address _token) external;
}

interface IMsgRelation {
    function setRelation(address father, address child) external;

    function getRelation(address _address)
        external
        view
        returns (address parent);

    function getRelations(address _address, uint length)
        external
        view
        returns (address[] memory);

    function setDaoReward(uint256 _amount) external;

    function hasRelation(address _address) external view returns (bool);
}

interface IPancakeSwapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender)
        external
        view
        returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(
        address indexed sender,
        uint amount0,
        uint amount1,
        address indexed to
    );
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

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeSwapFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IPancakeRouter01 {
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
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (
            uint amountToken,
            uint amountETH,
            uint liquidity
        );

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
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
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

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path)
        external
        view
        returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path)
        external
        view
        returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
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
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
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
    using SafeMath for uint256;
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

contract RBK is ERC20Detailed, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event DeBugEvent(string indexed processStep, string processData);

    string public _name = "Rebase Bunny King";
    string public _symbol = "RBK";
    uint8 public _decimals = 8;

    uint256 public constant DECIMALS = 8;
    uint8 public constant RATE_DECIMALS = 8;

    //RebaseBunnyKingdom by https://msgsender.io   // fee

    uint256 public liquidityFee = 30;
    uint256 public inviteBuyFee = 30;
    uint256 public inviteSellFee = 30;
    uint256 public nftFee = 10;
    uint256 public marketFee = 30;
    uint256 public buyMsgFee = 30;
    uint256 public robotfee = 550;

    uint256 public buyBackAccumulate = 0;
    uint256 public opertationCount = 0;
    uint256 public feeDenominator = 1000;
    uint256 public inviterMinHoldAmount = 1 * 10**DECIMALS;
    uint256 public MinAirdropAmount = 1 * 10**DECIMALS;
    uint256 public AddLiquidityAmount = 1000 * 10**DECIMALS;

    //RebaseBunnyKingdom by https://msgsender.io   // special addresses

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    IPancakeRouter02 public router;
    mapping(address => uint) public typesOfAddress;
    mapping(address => bool) public botlist;

    address public lpPoolAddress;
    address public realtionWrap;
    address public feeWrap;
    address public developer;
    address public marketAddress;
    address public buyBackTokenAddress = 0x43F10Fb99DBb8a80d1394Cf452F255D4814E6495;
    address public wbnbAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
    address public _swapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    //RebaseBunnyKingdom by https://msgsender.io   // Reflection for balance


    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 2 * 10**8 * 10**DECIMALS;
    uint256 public constant TOTAL_GONS = INITIAL_FRAGMENTS_SUPPLY;
    uint256 public constant MAX_SUPPLY = 10**30 * 10**DECIMALS;


    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    address pairAddress;
    IPancakeSwapPair public pairContract;

    //RebaseBunnyKingdom by https://msgsender.io   //rebaes parameters

    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public startTradingTime;
    uint256 public _initRebaseStartTime;
    uint256 public deltaTimeFromInit;
    uint256 public autoOpertationInterval = 5 minutes;
    uint256 public stopTime = 0;

    bool inSwap = false;
    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyPool() {
        require(msg.sender == lpPoolAddress, "only pool");
        _;
    }

    // RebaseBunnyKingdom by https://msgsender.io

    constructor(
        uint256 _startTradingTime
    ) ERC20Detailed(_name, _symbol, uint8(DECIMALS)) Ownable() {

        
        require(_swapRouter != address(0), "invalid swap router address");
        router = IPancakeRouter02(_swapRouter);
        pairAddress = IPancakeSwapFactory(router.factory()).createPair(
            usdtAddress,
            address(this)
        );

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        emit Transfer(address(0x0), msg.sender, _totalSupply);

        typesOfAddress[msg.sender] = 1;
        typesOfAddress[address(this)] = 1;
        typesOfAddress[pairAddress] = 2;
        pairContract = IPancakeSwapPair(pairAddress);


        setStartTradingTime(_startTradingTime);
    }

    function setLpPoolAddress(address _lpPoolAddress) public onlyOwner {
        lpPoolAddress = _lpPoolAddress;
    }

    function setBuyBackAddress(address _buyBckAddress) public onlyOwner {
        buyBackTokenAddress = _buyBckAddress;
    }

    function getPairAddress() public view returns (address) {
        return pairAddress;
    }

    function setFeeExcept(address _address) public onlyOwner {
        typesOfAddress[_address] = 1;
    }

    function setOtherPairs(address _address) public onlyOwner {
        typesOfAddress[_address] = 2;
    }

    function setBotlist(address _Address, bool _flag) public onlyOwner {
        require(
            isContract(_Address),
            "only contract address, not allowed exteranlly owned account"
        );
        botlist[_Address] = _flag;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function resetAddress(address _address) public onlyOwner {
        typesOfAddress[_address] = 0;
    }

    function isNormalAddress(address _address) public view returns (bool) {
        return typesOfAddress[_address] <= 1;
    }

    function isFreeAddress(address _address) public view returns (bool) {
        return typesOfAddress[_address] == 1;
    }

    function isPair(address _address) public view returns (bool) {
        return typesOfAddress[_address] == 2;
    }

    function setStartTradingTime(uint256 _time) public onlyOwner {
        if (_time <= 0) {
            _time = block.timestamp;
        }

        _initRebaseStartTime = _time;
        startTradingTime = _time;
        _lastAddLiquidityTime = _time;
        _lastRebasedTime = _time;
    }

    function setStopTime(uint256 _stopTime) public onlyOwner {
        stopTime = _stopTime;
    }

    function setFeeWrap(address _feeWrap) public onlyOwner {
        feeWrap = _feeWrap;
    }

    function setdeveloper(address _developer) public onlyOwner {
        developer = _developer;
    }

    function setrealtionWrap(address _realtionWrap) public onlyOwner {
        realtionWrap = _realtionWrap;
    }

    function setmarketAddress(address _marketAddress) public onlyOwner {
        marketAddress = _marketAddress;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address who) public view override returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function allowance(address _owner, address _spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowedFragments[_owner][_spender];
    }

    function approve(address _spender, uint256 value)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, _spender, value);
        return true;
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 value
    ) internal {
        _allowedFragments[_owner][_spender] = value;
        emit Approval(_owner, _spender, value);
    }

    function increaseAllowance(address _spender, uint256 _addedValue)
        external
        returns (bool)
    {
        _allowedFragments[msg.sender][_spender] = _allowedFragments[msg.sender][
            _spender
        ].add(_addedValue);
        emit Approval(
            msg.sender,
            _spender,
            _allowedFragments[msg.sender][_spender]
        );
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue)
        external
        returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][_spender] = 0;
        } else {
            _allowedFragments[msg.sender][_spender] = oldValue.sub(
                _subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            _spender,
            _allowedFragments[msg.sender][_spender]
        );
        return true;
    }

    function distributeLpReward(address recipet, uint256 amount)
        external
        onlyPool
    {

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _totalSupply = _totalSupply.add(amount);
        _gonBalances[recipet] = _gonBalances[recipet].add(gonAmount);
        emit Transfer(lpPoolAddress, recipet, amount);
    }

    function transfer(address to, uint256 value)
        external
        override
        validRecipient(to)
        returns (bool)
    {
        _transfer(msg.sender, to, value);
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
        require(!botlist[from] && !botlist[to], "bot");

        _transfer(from, to, value);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal {
        
        bool isFree = isFreeAddress(from) || isFreeAddress(to);
        if (inSwap) {
            _transferFree(from, to, value);
        } else {
            inSwap = isPair(from) || isPair(to);
            if ((!isFree) && inSwap) {
                require(
                    block.timestamp >= startTradingTime,
                    "trading not start"
                );
                _transferWithFee(from, to, value);
            } else {
                _transferFree(from, to, value);
                if (!inSwap) {
                    // set inviter
                    setInviter(from, to, value);
                    // auto add liquidity
                    if (
                        block.timestamp - _lastAddLiquidityTime >=
                        autoOpertationInterval
                    ) {
                        opertationCount = opertationCount.mod(3);
                        if (opertationCount == 0) {
                            autoLiquidity();
                        } else if (opertationCount == 1) {
                            swapBack();
                        } else if (opertationCount == 2) {
                            swapBack();
                        }
                        opertationCount = opertationCount.add(1);
                        _lastAddLiquidityTime = block.timestamp;
                    }
                }
            }
            inSwap = false;
        }
    }

    function _transferFree(
        address from,
        address to,
        uint256 amount
    ) internal {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
        emit Transfer(from, to, amount);
    }

    function _transferWithFee(
        address from,
        address to,
        uint256 value
    ) internal {
        uint256 totalFee = takeFee(from, to, value);
        _subFree(from, totalFee);
        uint256 afterFeeValue = value.sub(totalFee);
        afterFeeValue = afterFeeValue.mul(999).div(1000);
        _transferFree(from, to, afterFeeValue);
    }

    function takeFee(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256) {
        bool isBuy = isPair(from);
        bool isSell = isPair(to);
        uint256 totalFee = 0;
        uint256 inviteFee = 0;
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        uint256 gonstotalFee;

        if (isBuy) {
            totalFee = liquidityFee
                .add(inviteBuyFee)
                .add(nftFee)
                .add(buyMsgFee)
                .add(marketFee);
            inviteFee = inviteBuyFee;

            // fee for liquidity
            uint256 gonsLiquidityFee = gonAmount.mul(liquidityFee).div(
                feeDenominator
            );
            _gonBalances[address(this)] = _gonBalances[address(this)].add(
                gonsLiquidityFee
            );
            emit Transfer(
                to,
                address(this),
                gonsLiquidityFee.div(_gonsPerFragment)
            );

            // fee for NFT
            uint256 gonsNftFee = gonAmount.mul(nftFee).div(
                feeDenominator
            );
            _gonBalances[address(DEAD)] = _gonBalances[address(DEAD)].add(
                gonsNftFee
            );
            emit Transfer(
                to,
                address(DEAD),
                gonsNftFee.div(_gonsPerFragment)
            );

            //fee for referral
            uint256 inviteGonsFee = gonAmount.mul(inviteFee).div(
                feeDenominator
            );
            takeInviteFee(to, inviteGonsFee);

            // fee for market, buyMsgBack
            uint256 feeWrapRate = marketFee.add(buyMsgFee);
            uint256 gonsWrapFee = gonAmount.mul(feeWrapRate).div(
                feeDenominator
            );
            _gonBalances[feeWrap] = _gonBalances[feeWrap].add(gonsWrapFee);
            emit Transfer(to, feeWrap, gonsWrapFee.div(_gonsPerFragment));
        }
        if (isSell) {
            totalFee = liquidityFee
                .add(inviteBuyFee)
                .add(nftFee)
                .add(buyMsgFee)
                .add(marketFee);
            inviteFee = inviteBuyFee;

            // fee for liquidity
            uint256 gonsLiquidityFee = gonAmount.mul(liquidityFee).div(
                feeDenominator
            );
            _gonBalances[address(this)] = _gonBalances[address(this)].add(
                gonsLiquidityFee
            );
            emit Transfer(
                from,
                address(this),
                gonsLiquidityFee.div(_gonsPerFragment)
            );

            // fee for NFT
            uint256 gonsNftFee = gonAmount.mul(nftFee).div(
                feeDenominator
            );
            _gonBalances[address(DEAD)] = _gonBalances[address(DEAD)].add(
                gonsNftFee
            );
            emit Transfer(
                from,
                address(DEAD),
                gonsNftFee.div(_gonsPerFragment)
            );

            //fee for referral
            uint256 inviteGonsFee = gonAmount.mul(inviteFee).div(
                feeDenominator
            );
            takeInviteFee(from, inviteGonsFee);

            // fee for market, buyMsgBack
            uint256 feeWrapRate = marketFee.add(buyMsgFee);
            uint256 gonsWrapFee = gonAmount.mul(feeWrapRate).div(
                feeDenominator
            );
            _gonBalances[feeWrap] = _gonBalances[feeWrap].add(gonsWrapFee);
            emit Transfer(from, feeWrap, gonsWrapFee.div(_gonsPerFragment));
        }

        if (block.timestamp <= (startTradingTime + stopTime)){

            totalFee = totalFee.add(robotfee);
            gonstotalFee = gonAmount.mul(totalFee).div(feeDenominator);
            totalFee = gonstotalFee.div(_gonsPerFragment);
            _gonBalances[developer] = _gonBalances[developer].add(gonAmount.mul(robotfee).div(feeDenominator));  
            return totalFee;

        } else{

            gonstotalFee = gonAmount.mul(totalFee).div(feeDenominator);
            totalFee = gonstotalFee.div(_gonsPerFragment);
            return totalFee;

        }     


    }

    function _subFree(address from, uint256 amount) internal {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
    }

    function filterReferrer(address _address) internal view returns (address) {
        if (_address == address(0)) {
            return developer;
        }
        uint256 balanceOfReferrer = balanceOf(_address);
        if (
            (balanceOfReferrer >= inviterMinHoldAmount) &&
            isNormalAddress(_address)
        ) {
            return _address;
        }
        return developer;
    }

    function takeInviteFee(address from, uint256 gonsAmount) internal {
        if (gonsAmount == 0) {
            return;
        }
        address[] memory referrers = IMsgRelation(realtionWrap).getRelations(
            from,
            2
        );
        uint256 gonsAmountOne = gonsAmount.div(3).mul(2);
        uint256 gonsAmountTwo = gonsAmount.sub(gonsAmountOne);
        address reffererOne = filterReferrer(referrers[0]);
        address reffererTwo = filterReferrer(referrers[1]);

        _gonBalances[reffererOne] = _gonBalances[reffererOne].add(
            gonsAmountOne
        );
        emit Transfer(from, reffererOne, gonsAmountOne.div(_gonsPerFragment));

        _gonBalances[reffererTwo] = _gonBalances[reffererTwo].add(
            gonsAmountTwo
        );
        emit Transfer(from, reffererTwo, gonsAmountTwo.div(_gonsPerFragment));
    }

    function setInviter(
        address father,
        address child,
        uint256 amount
    ) internal {
        if (block.timestamp < _initRebaseStartTime) {
            deltaTimeFromInit = 0;
        } else {
            deltaTimeFromInit = block.timestamp - _initRebaseStartTime;
        }

        if (
            !IMsgRelation(realtionWrap).hasRelation(child) &&
            amount >= MinAirdropAmount &&
            isNormalAddress(father) &&
            isNormalAddress(child)
        ) {
            IMsgRelation(realtionWrap).setRelation(father, child);
        }
    }

    function autoLiquidity() public swapping {
        uint256 balanceAmount = balanceOf(address(this));
        if (balanceAmount > AddLiquidityAmount) {
            // swap half for liquidity
            _approve(address(this), address(router), balanceAmount);
            uint256 swapAmount = balanceAmount.div(2);
            uint256 usdtBalanceBofore = IERC20(usdtAddress).balanceOf(
                address(this)
            );
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = usdtAddress;
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                swapAmount,
                0,
                path,
                feeWrap,
                block.timestamp
            );

            // withdraw tokens for adding liquidity
            IMsgWrap(feeWrap).withdrawToToken(usdtAddress);

            // add liquidity
            uint256 usdtBalanceAfter = IERC20(usdtAddress).balanceOf(
                address(this)
            );
            uint256 amountUsdtDesired = usdtBalanceAfter.sub(usdtBalanceBofore);
            IERC20(usdtAddress).approve(address(router), amountUsdtDesired);
            router.addLiquidity(
                address(this),
                usdtAddress,
                balanceAmount.sub(swapAmount),
                amountUsdtDesired,
                0,
                0,
                feeWrap,
                block.timestamp
            );
        }
    }

    function swapBack() public swapping {
        if (buyBackAccumulate <= 0) {
            uint256 tokenBalance = IERC20(address(this)).balanceOf(feeWrap);
            if (tokenBalance == 0) {
                return;
            }
            _gonBalances[address(this)] = _gonBalances[address(this)].add(
                _gonBalances[feeWrap]
            );
            _gonBalances[feeWrap] = 0;
            _approve(address(this), address(router), tokenBalance);
            uint256 usdtBalanceBofore = IERC20(usdtAddress).balanceOf(
                address(this)
            );
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = usdtAddress;
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenBalance,
                0,
                path,
                feeWrap,
                block.timestamp
            );
            IMsgWrap(feeWrap).withdrawToToken(usdtAddress);
            uint256 usdtBalanceAfter = IERC20(usdtAddress).balanceOf(
                address(this)
            );
            uint256 receiveUsdt = usdtBalanceAfter.sub(usdtBalanceBofore);

            uint256 backUsdt = receiveUsdt.div(2);
            uint256 marktUsdt = receiveUsdt.sub(backUsdt);

            if (marktUsdt > 0) {
                IERC20(usdtAddress).transfer(marketAddress, marktUsdt);
                buyBackAccumulate = buyBackAccumulate + backUsdt;
            }
        } else {
            uint256 usdtBalanceAfterDis = IERC20(usdtAddress).balanceOf(
                address(this)
            );
            if (usdtBalanceAfterDis == 0) {
                return;
            }
            if (buyBackAccumulate > usdtBalanceAfterDis) {
                buyBackAccumulate = usdtBalanceAfterDis;
            }
            IERC20(usdtAddress).approve(address(router), buyBackAccumulate);
            address[] memory backPath = new address[](3);
            backPath[0] = usdtAddress;
            backPath[1] = wbnbAddress;
            backPath[2] = buyBackTokenAddress;
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                buyBackAccumulate,
                0,
                backPath,
                marketAddress,
                block.timestamp
            );
            buyBackAccumulate = 0;
        }
    }

    function burnManual(uint256 _amount) public onlyOwner {
        _totalSupply = _totalSupply.sub(_amount);
        _gonBalances[msg.sender] = _gonBalances[msg.sender].sub(_amount.mul(_gonsPerFragment));
        emit Transfer(msg.sender, address(0), _amount);
    }   
 
}