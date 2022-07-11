/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

// SPDX-License-Identifier: Unlicensed
//
// SAFUU PROTOCOL COPYRIGHT (C) 2022

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
interface IMOPDao{
    function users(address addre) external view returns (address);

}
contract Mop is ERC20Detailed, Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event RefBonus(address indexed from, address indexed to, uint _value, uint _amount);


    string public _name = "Messenger of Peace";
    string public _symbol = "MOP";
    uint8 public _decimals = 18;

    mapping(address => bool) _isFeeExempt;
    mapping(address => bool) public isAllow;


    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 public constant DECIMALS = 18;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 8;


    uint256 public NFTFee = 30; //3%  only for buy
    uint256 public treasuryFee = 50;//5% only for transfer
    uint256 public consensusFundFee = 25;//2.5% only for sell
    uint256 public daoFee = 50;//5% dao fee.only for buy
    uint256 public firePitFee = 20;//2% only for buy
    uint256 public inviteFee = 125;//12.5% //only for sell
    uint256 public feeDenominator = 1000;
    uint256 public rebaseRate = 20833;
    uint256 public min=1000*10**18;

    uint256 public totalInviteAmount = 0;
    uint[] public REFERRAL_PERCENTS = [40,30,20,10,5,5,5,5,5]; 


    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address public NFT = 0xF5dDA0B0AC3AbAF26784051191DEe7E4FA2A09C0;
    address public BONUS = 0x81444079F947D5d775A069281E238B258cd9BEED;
    address public MOP = 0x12B3EF1eF28Db1fd8818f01b2B6e27f36D785995;
    address public ANGLE = 0x9A4a7C8c5d59152B5A66f98714d9eEB271881FA9;






    address public autoLiquidityReceiver;
    address public treasuryReceiver;
    address public firePit;
    IPancakeSwapRouter public router;
    address public pair;
    address public usdtAddress;
    bool inSwap = false;
    bool public isSwapAndLiquid;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 public TOTAL_GONS;

    uint256 public constant MAX_SUPPLY =~uint128(0)/1e6;

    bool public _autoRebase;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;
    uint256 public _gonsPerFragment;
    uint256 public pairBalance;
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blist;
    uint256 public startTradingTime;
    constructor(uint256 _initSupply,uint256 _startTradingTime) ERC20Detailed(_name,_symbol, uint8(DECIMALS)) Ownable() {    
        usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
    
        //freeDaoAddress = _freeDaoAddress;
         IPancakeSwapRouter _uniswapV2Router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // Mainnet 

        address _uniswapV2Pair = IPancakeSwapFactory(_uniswapV2Router.factory())
             .createPair(address(this), usdtAddress);
        pair = _uniswapV2Pair;
        require(_initSupply>0,"invalid init supply");
        _totalSupply = _initSupply*10**DECIMALS;
        TOTAL_GONS =
        MAX_UINT256 - (MAX_UINT256 % _totalSupply);

        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = block.timestamp;
        _isFeeExempt[msg.sender] = true;
        setStartTradingTime(_startTradingTime);

        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }
    function manualRebase() external{
        require(shouldRebase(),"rebase not required");
        rebase();
    }
    function rebase() internal {

        if ( inSwap ) return;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(15 minutes);
        uint256 epoch = times.mul(15);


        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
            .mul((10**RATE_DECIMALS).add(rebaseRate))
            .div(10**RATE_DECIMALS);
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(15 minutes));

        emit LogRebase(epoch, _totalSupply);
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

        require(!blist[sender] && !blist[recipient], "in_blacklist");
//        if ((sender==pair||recipient==pair)&&_isFeeExempt(sender)==false&&_isFeeExempt(recipient)==false){
//            require(startTradingTime>0&&block.timestamp>=startTradingTime,"can not trade");
//        }

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (shouldRebase()) {
            rebase();
        }


        uint256 gonAmount = amount.mul(_gonsPerFragment);
        if (recipient==pair&&_isFeeExempt[sender]==false&&_isFeeExempt[recipient]==false){
            //only can sell 99% of balance
            if (gonAmount>=_gonBalances[sender].div(1000).mul(999)){
                gonAmount = _gonBalances[sender].div(1000).mul(999);
            }
            //require(gonAmount<=_gonBalances[sender].mul(99).div(100),"only can sell 99% of balance");
        }
        if(sender==pair||recipient==pair){
           if(!isAllow[recipient]&&!isAllow[sender]){
            require(isSwapAndLiquid,"BEP20: sell is not allow");
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
        uint256 _totalFee=0;
        // transfer token
        if (sender != pair&&recipient!=pair) {
            _gonBalances[address(0)] = _gonBalances[address(0)].add(
                gonAmount.div(feeDenominator).mul(treasuryFee)
            );
            emit Transfer(sender, address(0), gonAmount.div(feeDenominator).mul(treasuryFee).div(_gonsPerFragment));
            gonAmount=gonAmount.sub(gonAmount.div(feeDenominator).mul(treasuryFee));
        }
        if (sender == pair) {//when buy token
            _totalFee=NFTFee.add(firePitFee).add(daoFee);
            _gonBalances[NFT] = _gonBalances[NFT].add(
                gonAmount.div(feeDenominator).mul(NFTFee)
            );
            pairBalance = pairBalance.add(
                gonAmount.div(feeDenominator).mul(daoFee).div(_gonsPerFragment)
            );
            _gonBalances[address(0)] = _gonBalances[address(0)].add(
                gonAmount.div(feeDenominator).mul(firePitFee)
            );
            emit Transfer(sender, pair, gonAmount.div(feeDenominator).mul(daoFee).div(_gonsPerFragment));
            emit Transfer(sender, address(0),  gonAmount.div(feeDenominator).mul(firePitFee).div(_gonsPerFragment));
            emit Transfer(sender, NFT, gonAmount.div(feeDenominator).mul(NFTFee).div(_gonsPerFragment));
            gonAmount=gonAmount.sub(gonAmount.div(feeDenominator).mul(_totalFee));
        }

        if (recipient == pair){
            _totalFee=inviteFee.add(consensusFundFee);
            uint val=gonAmount.mul(inviteFee).div(feeDenominator);
            if ( sender != address(0)) {
            address upline=IMOPDao(MOP).users(sender);
            for (uint i = 0; i <9 ; i++) {
                if (upline != address(0)) {
                    uint amount=gonAmount.mul(REFERRAL_PERCENTS[i]).div(feeDenominator);
                    if (amount > 0&&_gonBalances[upline]>=min) {
                        //address(uint160(upline)).transfer(amount);
                        _gonBalances[upline] = _gonBalances[upline].add(amount);
                        val=val.sub(amount);
                        emit RefBonus(sender, upline, i, amount.div(_gonsPerFragment));
                        emit Transfer(sender, upline, amount.div(_gonsPerFragment));
                    }
                    upline = IMOPDao(MOP).users(upline);
                }else break; 
            }
            if(val>0){
            _gonBalances[BONUS] = _gonBalances[BONUS].add(val);            
            emit Transfer(sender, BONUS, val.div(_gonsPerFragment));
            } 
        }
        _gonBalances[ANGLE] = _gonBalances[ANGLE].add(gonAmount.div(feeDenominator).mul(consensusFundFee)); 
        emit Transfer(sender, ANGLE, gonAmount.div(feeDenominator).mul(consensusFundFee).div(_gonsPerFragment));
        gonAmount=gonAmount.sub(gonAmount.div(feeDenominator).mul(_totalFee));
        }
    
        return gonAmount;
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
        block.timestamp >= (_lastRebasedTime + 15 minutes);
    }
    function addAllow(address gameAddress) external onlyOwner {
        require(!isAllow[gameAddress], "address already in allow list");
        // add gameAddress to allowedGameAddress
        isAllow[gameAddress] = true;

    }


    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _flag;
        }
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
        address _autoLiquidityReceiver,
        address _firePit
    ) external onlyOwner {
        NFT = _autoLiquidityReceiver;
        BONUS = _firePit;
    }
    function setAngle(
        address _an
    ) external onlyOwner {
        ANGLE = _an;
    }
     function setMop(
        address _an
    ) external onlyOwner {
        MOP = _an;
    }


    function setFeelist(address[] memory _addrs) external onlyOwner {
        for(uint256 i=0;i<_addrs.length;i++){
            _isFeeExempt[_addrs[i]] = true;
        }

    }

    function setBlist(address _address, bool _flag) external onlyOwner {
        blist[_address] = _flag;
    }
    function setRate(uint res) external onlyOwner {
        rebaseRate = res;
    }
    function setMin(uint _min) external onlyOwner {
        min = _min;
    }

    function setisLiquid(bool res) external onlyOwner {
        isSwapAndLiquid = res;
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

}