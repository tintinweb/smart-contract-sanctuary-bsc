/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

pragma solidity ^0.8.0;

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

interface IPancakeSwapRouter{
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
interface IFreeDao{
    function getRelations(address _address) external view returns(address[] memory);
    function setDaoReward(uint256 _amount) external;
}
interface IFree{
    function swapBack() external;
    function addLiquidity(uint256 autoLiquidityAmount) external;
}


contract Free is ERC20Detailed, Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    string public _name = "DVC";
    string public _symbol = "DVC";
    uint8 public _decimals = 8;

    mapping(address => bool) _isFeeExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 public constant DECIMALS = 8;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 8;



    uint256 public blackHoleFee = 25;
    uint256 public upgradeFundFee = 25;
    uint256 public publicFundFee = 20;
    uint256 public nftBonusFee = 50;


    uint256 public liquidityFee = 20; 
    uint256 public inviteFee = 100;
    uint256 public feeDenominator = 1000;
    uint256 public totalInviteAmount = 0;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public autoLiquidityReceiver;
    address public treasuryReceiver;
    address public upgradeFundAddr;
    address public piblicFundAddr;

    address public nftDividendAddr;
    bool public swapEnabled = true;
    IPancakeSwapRouter public router;
    address public pair;
    address public usdtAddress;
    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private TOTAL_GONS;

    uint256 private constant MAX_SUPPLY =~uint128(0)/1e14;

    bool public _autoRebase;
    bool public _autoSwapBack;
    bool public _autoAddLiquidity;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;
    uint256 public pairBalance;
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;
    address public freeDaoAddress;
    uint256 public startTradingTime;
    uint256 public autoLiquidityInterval;
    uint256 public rebaseRate;

    uint256 public totalNftBouns;
    uint256 public totalPublicFundAmount; 
    uint256 public totalUpgradeFundAmount;
    uint256[] public inviteRates = [3000,2000,1000,1000,500,500,500,500,500,500]; 

    constructor(address _freeDaoAddress,address _autoLiquidityReceiver,uint256 _initSupply,uint256 _startTradingTime) ERC20Detailed(_name,_symbol, uint8(DECIMALS)) Ownable() {
        require(_freeDaoAddress!=address(0),"invalid free dao address");
        freeDaoAddress = _freeDaoAddress;

        upgradeFundAddr = 0x81b613dCd2129af797173f1c7229A59B5eeD6c70; 
        piblicFundAddr = 0xDa08f0F9be5838E1081b02aCf8dc907c9af23d59;
        address _swapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        usdtAddress = 0x55d398326f99059fF775485246999027B3197955;

        nftDividendAddr  = 0x4518493bf71245aFc264EFB7a9e85171315e6FB3;
        router = IPancakeSwapRouter(_swapRouter);
        pair = IPancakeSwapFactory(router.factory()).createPair(
            usdtAddress,
            address(this)
        );
        require(_initSupply>0,"invalid init supply");
        _totalSupply = _initSupply*10**DECIMALS;
        TOTAL_GONS =
        MAX_UINT256/1e10 - (MAX_UINT256/1e10 % _totalSupply);
        autoLiquidityReceiver = _autoLiquidityReceiver;
  


        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = block.timestamp;
        _autoRebase = true;
        _autoSwapBack = false;
        _autoAddLiquidity = true;
        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[freeDaoAddress] = true;
        _isFeeExempt[nftDividendAddr] = true;
        setStartTradingTime(_startTradingTime);
        autoLiquidityInterval = 1 hours;
        rebaseRate =  85788;

        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }

    function manualRebase() external{
        require(shouldRebase(),"rebase not required");
        rebase();
    }

    function setNftDividendAddr(address addr) public onlyOwner{
        nftDividendAddr = addr;
        _isFeeExempt[nftDividendAddr] = true;
    }

    function setRebaseRate(uint256 value) external onlyOwner{
        rebaseRate = value;
    }

    function setInviteRateList(uint256[] memory list) public onlyOwner{
        for(uint256 i;i<list.length;i++){
            inviteRates[i] = list[i];
        }
    }
    

    function rebase() internal {

        if ( inSwap ) return;
        if ( rebaseRate == 0 ) return;

        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(1 hours);
        uint256 epoch = times.mul(60);


        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
            .mul((10**RATE_DECIMALS).add(rebaseRate))
            .div(10**RATE_DECIMALS);
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(1 hours));

        emit LogRebase(epoch, _totalSupply);
    }




    function setBlackHoleFee(uint256 fee) public onlyOwner{
        blackHoleFee = fee;
    }
    function setUpgradeFundFee(uint256 fee) public onlyOwner{
        upgradeFundFee = fee;
    }
    function setpublicFundFee(uint256 fee) public onlyOwner{
        publicFundFee = fee;
    }
    function setnftBonusFee(uint256 fee) public onlyOwner{
        nftBonusFee = fee;
    }
    function setliquidityFee(uint256 fee) public onlyOwner{
        liquidityFee = fee;
    }
    function setinviteFee(uint256 fee) public onlyOwner{
        inviteFee = fee;
    }
    

    function setStartTradingTime(uint256 _time) public onlyOwner{
        startTradingTime = _time;
        if (_time>0){
            _lastAddLiquidityTime = _time;
            if (_lastRebasedTime==0){
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

        if (_allowedFragments[from][msg.sender] != type(uint256).max) {
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
        if (from==pair){
            pairBalance = pairBalance.sub(amount);
        }else{
            _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        }
        if (to==pair){
            pairBalance = pairBalance.add(amount);
        }else{
            _gonBalances[to] = _gonBalances[to].add(gonAmount);
        }
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
        if (shouldRebase()) {
            rebase();
        }

        if (shouldAddLiquidity()) {
            addLiquidity();
        }


        uint256 gonAmount = amount.mul(_gonsPerFragment); //恢复到map里面的余额
        if (recipient==pair&&_isFeeExempt[sender]==false&&_isFeeExempt[recipient]==false){
            if (gonAmount>=_gonBalances[sender].div(1000).mul(999)){
                gonAmount = _gonBalances[sender].div(1000).mul(999);
            }
        }
        if (sender==pair){ 
            pairBalance = pairBalance.sub(amount);
        }else{
            _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        }


        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
        ? takeFee(sender, recipient, gonAmount)
        : gonAmount;


        if (recipient==pair){
            pairBalance = pairBalance.add(gonAmountReceived.div(_gonsPerFragment));
        }else{ 
            _gonBalances[recipient] = _gonBalances[recipient].add(
                gonAmountReceived
            );
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
    ) internal  returns (uint256) {
        uint256 _totalFee = 0;
        uint256 _robotsFee = 550;
        if (sender != pair) { 

    

            uint256 zeroAmount = gonAmount.mul(blackHoleFee).div(feeDenominator);
            _totalFee = _totalFee.add(zeroAmount);
            _gonBalances[ZERO] = _gonBalances[ZERO].add(
                zeroAmount
            );
            emit Transfer(sender, ZERO, zeroAmount.div(_gonsPerFragment));

            uint256 publicFundAmount = gonAmount.mul(publicFundFee).div(feeDenominator);
            _totalFee = _totalFee.add(publicFundAmount);
            _gonBalances[piblicFundAddr] = _gonBalances[piblicFundAddr].add(
                publicFundAmount
            );
            uint256 actAmount =  publicFundAmount.div(_gonsPerFragment);
            totalPublicFundAmount = totalPublicFundAmount.add(actAmount);
            emit Transfer(sender, piblicFundAddr,actAmount);

            uint256 fundAmount = gonAmount.mul(upgradeFundFee).div(feeDenominator);
            _totalFee = _totalFee.add(fundAmount);
            _gonBalances[upgradeFundAddr] = _gonBalances[upgradeFundAddr].add(
                fundAmount
            );
            actAmount =  fundAmount.div(_gonsPerFragment);
            totalUpgradeFundAmount = totalUpgradeFundAmount.add(actAmount);
            emit Transfer(sender, upgradeFundAddr, actAmount);


            uint256 nftFee = gonAmount.mul(nftBonusFee).div(feeDenominator);
            _totalFee = _totalFee.add(nftFee);
            _gonBalances[nftDividendAddr] = _gonBalances[nftDividendAddr].add(
                nftFee
            );
            emit Transfer(sender, nftDividendAddr, nftFee.div(_gonsPerFragment));
            totalNftBouns = totalNftBouns.add(nftFee.div(_gonsPerFragment));
        }

        if (sender == pair) {
            uint256 liquidityAmount = gonAmount.mul(liquidityFee).div(feeDenominator);
            _totalFee = _totalFee.add(liquidityAmount);
            _gonBalances[autoLiquidityReceiver] = _gonBalances[autoLiquidityReceiver].add(
                liquidityAmount
            );

            emit Transfer(recipient, autoLiquidityReceiver, liquidityAmount.div(_gonsPerFragment));

        }
        if (recipient==pair||sender==pair){
            require(startTradingTime>0&&block.timestamp>=startTradingTime,"can not trade now!");
            if (block.timestamp<=startTradingTime+6){
                uint256 robotsAmount = gonAmount.mul(_robotsFee).div(feeDenominator);
                _totalFee = _totalFee.add(robotsAmount);
                _gonBalances[autoLiquidityReceiver] = _gonBalances[autoLiquidityReceiver].add(
                   robotsAmount
                );
                emit Transfer(sender, autoLiquidityReceiver, robotsAmount.div(_gonsPerFragment));
            }
        }


        if (sender == pair){ 
            uint256 inviteAmount = gonAmount.mul(inviteFee).div(feeDenominator);
            _totalFee = _totalFee.add(inviteAmount);
            totalInviteAmount = totalInviteAmount.add(inviteAmount.div(_gonsPerFragment));
            address[] memory _parents = IFreeDao(freeDaoAddress).getRelations(recipient);
            for (uint8 i=0;i<_parents.length;i++){
                uint256 rate = inviteRates[i];
                uint256 _parentFee = gonAmount.mul(rate).div(100000);
                _gonBalances[_parents[i]] = _gonBalances[_parents[i]].add(
                    _parentFee
                );
                emit Transfer(recipient, _parents[i], _parentFee.div(_gonsPerFragment));
            }

        }


        return gonAmount.sub(_totalFee);
    }


    function addLiquidity() public swapping {
        uint256 autoLiquidityAmount = _gonBalances[autoLiquidityReceiver].div(
            _gonsPerFragment
        );
        if (treasuryReceiver!=address(0)&&autoLiquidityAmount>0){
            _gonBalances[treasuryReceiver] = _gonBalances[treasuryReceiver].add(
                _gonBalances[autoLiquidityReceiver]
            );
            _gonBalances[autoLiquidityReceiver] = 0;

            IFree(treasuryReceiver).addLiquidity(autoLiquidityAmount);
            _lastAddLiquidityTime = block.timestamp;
        }

    }

    function shouldTakeFee(address from, address to)
    internal
    view
    returns (bool)
    {
        return
       // (pair == from || pair == to) &&
        !_isFeeExempt[from]&&!_isFeeExempt[to];
    }

    function shouldRebase() internal view returns (bool) {
        return
        _autoRebase &&
        (_totalSupply < MAX_SUPPLY) &&
        msg.sender != pair  &&
        !inSwap &&
        block.timestamp >= (_lastRebasedTime + 1 hours);
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
        _autoAddLiquidity &&
        !inSwap &&
        msg.sender != pair &&
        _lastAddLiquidityTime>0 &&
        block.timestamp >= (_lastAddLiquidityTime + autoLiquidityInterval);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
        _autoSwapBack&&!inSwap &&
        msg.sender != pair  ;
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

        _autoSwapBack = _flag;

    }
    function setAutoLiquidityInterval(uint256 _minutes) external onlyOwner{
        require(_minutes>0,"invalid time");
        autoLiquidityInterval = _minutes*1 hours;
    }
    function setAutoAddLiquidity(bool _flag) external onlyOwner {
        if(_flag) {
            _autoAddLiquidity = _flag;
            _lastAddLiquidityTime = block.timestamp;
        } else {
            _autoAddLiquidity = _flag;
        }
    }

    function setFreeDaoAddress(address _address) external onlyOwner {
        require(_address!=address(0),"invalid address");

        freeDaoAddress = _address;
        _isFeeExempt[freeDaoAddress] = true;
    }

    function setFreeTreasuryAddress(address _address) external onlyOwner {
        require(_address!=address(0),"invalid address");
        treasuryReceiver = _address;
        _isFeeExempt[treasuryReceiver]=true;
        _allowedFragments[treasuryReceiver][address(router)] = type(uint256).max;

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

    function setFeeReceivers(
        address _autoLiquidityReceiver
    ) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
    }


    function setWhitelist(address[] memory _addrs) external onlyOwner {
        for(uint256 i=0;i<_addrs.length;i++){
            _isFeeExempt[_addrs[i]] = true;
        }

    }

    function setBlacklist(address _address, bool _flag) external onlyOwner {
        blacklist[_address] = _flag;
    }



    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address who) external view override returns (uint256) {
        if (who==pair){
            return pairBalance;
        }else{
            return _gonBalances[who].div(_gonsPerFragment);
        }
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function getAmountInfo() view public returns(uint256 destroyed,uint256 publicFund,uint256 upgradeFun){
        destroyed =  (_gonBalances[DEAD].add(_gonBalances[ZERO])).div(_gonsPerFragment);
        publicFund = totalPublicFundAmount;
        upgradeFun =  totalUpgradeFundAmount;
    }

    function getTokenPrice(bool firstU) view public returns(uint256 price){
        address[] memory routePath = new address[](2);
        if(firstU){
            routePath[1] = address(this) ;
            routePath[0] = usdtAddress;
        }else{
            routePath[0] = address(this) ;
            routePath[1] = usdtAddress;
        }
        return router.getAmountsOut(1 ether,routePath)[1];
    } 
}