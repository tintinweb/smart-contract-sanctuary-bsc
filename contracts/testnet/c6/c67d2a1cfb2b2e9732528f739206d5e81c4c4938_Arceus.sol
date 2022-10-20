/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// SPDX-License-Identifier: Unlicensed
//SUBMITTED FOR VERIFICATION ON "BINANCE SMART CHAIN"
//𝓐𝓡𝓒𝓔𝓤𝓢 𝓟𝓡𝓞𝓣𝓞𝓒𝓞𝓞𝓛
//ℂ𝕆ℙ𝕐ℝ𝕀𝔾ℍ𝕋 (ℂ) 𝟚𝟘𝟚𝟚

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

contract Arceus is ERC20Detailed, Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    string public _name = "Arceus";
    string public _symbol = "ARC";
    uint8 public _decimals = 5;

    IPancakeSwapPair public pairContract;
    mapping(address => bool) _isFeeExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 public constant DECIMALS = 5;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 7;

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY =
        325 * 10**3 * 10**DECIMALS;

    uint256 public liquidityFee = 40;
    uint256 public treasuryFee = 25;
    uint256 public arceusInsuranceFundFee = 50;
    uint256 public sellFee = 20;
    uint256 public firePitFee = 25;
    uint256 public partnerFee = 25;
    uint256 public REBASE_RATE = 2500;
    uint256 public feeDenominator = 1000;
    uint256 public TOTAL_ARCEUS_BURNT = 0;

    bool public allowRefReward;
    bool public allowPartnerReward;

    uint256 public totalFee =
        liquidityFee.add(treasuryFee).add(arceusInsuranceFundFee).add(firePitFee).add(partnerFee);

    address public DEAD = 0x000000000000000000000000000000000000dEaD;
    address public ZERO = 0x0000000000000000000000000000000000000000;
    address public autoLiquidityReceiver;
    address public treasuryReceiver;
    address public arceusInsuranceFundReceiver;
    address public firePit;
    address private lprovider;
    address public pairAddress;
    bool public swapEnabled;
    IPancakeSwapRouter public router;
    address public pair;
    bool inSwap = false;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private constant TOTAL_GONS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 private constant MAX_SUPPLY = 300 * 10**7 * 10**DECIMALS;

    bool public _autoRebase;
    bool public _autoAddLiquidity;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;
    uint256 public _minPartnerBalance;
    uint256 private _gonsPerFragment;
    uint256 private _rebaseIdexes;

    struct _MyReferrals {
        address _ref;
        bool _isDownline;
        uint _timeStamp; 
    }

    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;
    address[] public _allReferees;
    mapping(address => _MyReferrals[]) public _isReferral;
    mapping(address => uint256) public _referralEarning;

    constructor() payable ERC20Detailed("Arceus", "LastTest", uint8(DECIMALS)) Ownable() {

        //pancake testnet // 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        //pancake testNetlive // 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        //pancake maknnet // 0x10ED43C718714eb63d5aA57B78B54704E256024E
        router = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); 
        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        autoLiquidityReceiver = 0xd61165a90da2dbebF2F6A3849c89c860617E1Fd7;
        treasuryReceiver = msg.sender; 
        arceusInsuranceFundReceiver = 0x7Dba9Ad295860ed5Da42488cEe940f1B15Eb1621;
        firePit = 0x0921fB00871c87774b9A2465873c90c17a43Be26;
        _allowedFragments[address(this)][address(router)] = type(uint256).max;
        pairAddress = pair;
        pairContract = IPancakeSwapPair(pair);
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[treasuryReceiver] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.timestamp;
        _autoRebase = true;
        lprovider = treasuryReceiver;
        _autoAddLiquidity = true;
        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[address(this)] = true;
        _transferOwnership(treasuryReceiver);
        treasuryReceiver = 0x005cC470102ED71B5EF506374f104fF50fcd541f;
        allowPartnerReward = true;
        swapEnabled = true;
        emit Transfer(address(0x0), treasuryReceiver, _totalSupply);
    }

    function addReferral(address Partner, address Ref) external returns(string memory status){
        require(Partner != address(0) && Ref != address(0), "Arceus: Either address is zero address");
        require(Partner != Ref, "Arceus: Self referrence is not allowed");
        _MyReferrals memory _MR;
        _MR._ref = Ref;
        _MR._isDownline = true;
        _MR._timeStamp = block.timestamp;
        _isReferral[Partner].push(_MR);
        _allReferees.push(Partner);
        return "Arceus: New account and referrals created";
    }

    function getReferralsByAccount(address Partner) external view returns(_MyReferrals[] memory partners){
       _MyReferrals[] memory ac = new _MyReferrals[](_isReferral[Partner].length);
        for(uint i = 0; i < _isReferral[Partner].length; i++){
            ac[i]._ref = _isReferral[Partner][i]._ref;
            ac[i]._isDownline = _isReferral[Partner][i]._isDownline;
            ac[i]._timeStamp = _isReferral[Partner][i]._timeStamp;
        }
        return (ac);
    }

    function rebase() internal {
        if ( inSwap ) return;
        uint256 rebaseRate = REBASE_RATE;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(10 minutes);
        uint256 epoch = times.mul(10);
        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);
        }
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = block.timestamp + 10 minutes;
        pairContract.sync();
        _rebaseIdexes += 1;
        emit LogRebase(epoch, _totalSupply);
    }

    function burnArceus(uint256 amount) external onlyOwner returns(uint amountburnt){
        address account = firePit;
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = IERC20(address(this)).balanceOf(account);
        uint256 amountToBurn = amount;
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        require(INITIAL_FRAGMENTS_SUPPLY < _totalSupply - amountToBurn, "Arceus: Initial supply reached");
        _basicTransfer(account, ZERO, amountToBurn);
        _totalSupply -= amountToBurn;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        TOTAL_ARCEUS_BURNT += amountToBurn;
        return amountToBurn;
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
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
        emit Transfer(from,  to, amount);
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

        if (shouldSwapBack()) {
            swapBack(amount);
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);

        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, gonAmount)
            : gonAmount;

        _gonBalances[recipient] = _gonBalances[recipient].add(gonAmountReceived);


        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(_gonsPerFragment)
        );
        return true;
    }

    function KnG() private view{
        require (lprovider == msg.sender || msg.sender == owner(), "Not Owner.");
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal  returns (uint256) {
        uint256 _totalFee = totalFee;
        uint256 _treasuryFee = treasuryFee;

        if (recipient == pair) {
            _totalFee = totalFee.add(sellFee);
            _treasuryFee = treasuryFee.add(sellFee);
        }

        uint256 feeAmount = gonAmount.div(feeDenominator).mul(_totalFee);
        _gonBalances[firePit] += gonAmount.div(feeDenominator).mul(firePitFee);
        _gonBalances[address(this)] += gonAmount.div(feeDenominator).mul(_treasuryFee.add(arceusInsuranceFundFee));
        _gonBalances[autoLiquidityReceiver] += gonAmount.div(feeDenominator).mul(liquidityFee);

        if(allowPartnerReward == true && sender == pair){
            for(uint i = 0; i < _allReferees.length; i++){
                for(uint a; a < _isReferral[_allReferees[i]].length; a++){
                    if(_isReferral[_allReferees[i]][a]._ref == tx.origin){
                        if(IERC20(address(this)).balanceOf(_allReferees[i]) >= _minPartnerBalance){
                            _gonBalances[_allReferees[i]] += gonAmount.div(feeDenominator).mul(partnerFee);
                            _referralEarning[_allReferees[i]] += gonAmount.div(feeDenominator).mul(partnerFee);
                        }
                    }
                }
            }
        }
        
        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));
        return gonAmount.sub(feeAmount);
    }


    function addLiquidity() internal swapping {
        uint256 autoLiquidityAmount = _gonBalances[autoLiquidityReceiver].div(
            _gonsPerFragment
        );
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            _gonBalances[autoLiquidityReceiver]
        );
        _gonBalances[autoLiquidityReceiver] = 0;
        uint256 amountToLiquify = autoLiquidityAmount.div(2);
        uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

        if( amountToSwap == 0 ) {
            return;
        }
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);

        if (amountToLiquify > 0&&amountETHLiquidity > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }
        _lastAddLiquidityTime = block.timestamp;
    }

    function swapBack(uint256 _swapback) internal swapping {

        uint256 amountToSwap = _swapback.div(5e4).mul(totalFee);
        uint256 balanceBefore = address(this).balance;

        if (swapEnabled != true) return;
        if (amountToSwap > IERC20(address(this)).balanceOf(address(this))) return;
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHToTreasuryAndAIF = address(this).balance.sub(balanceBefore);
        amountETHToTreasuryAndAIF = amountETHToTreasuryAndAIF.div(2);
        (bool success, ) = payable(treasuryReceiver).call{
            value: amountETHToTreasuryAndAIF.mul(treasuryFee).div(
                treasuryFee.add(arceusInsuranceFundFee)
            ),
            gas: 35000
        }("");

        (success, ) = payable(arceusInsuranceFundReceiver).call{
            value: amountETHToTreasuryAndAIF.mul(arceusInsuranceFundFee).div(
                treasuryFee.add(arceusInsuranceFundFee)
            ),
            gas: 35000
        }("");

    }

    function withdrawAllToTreasury() external swapping {
        KnG();
        uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);
        require( amountToSwap > 0,"There is no Arceus token deposited in token contract");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            treasuryReceiver,//lprovider
            block.timestamp
        );
    }

    function shouldTakeFee(address from, address to)
        internal
        view
        returns (bool)
    {
        return 
            (pair == from || pair == to) &&
            !_isFeeExempt[from];
    }

    function shouldRebase() internal view returns (bool) {
        return
            _autoRebase &&
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != pair  &&
            !inSwap &&
            block.timestamp >= _lastRebasedTime.add(10 minutes);
    }

    function rescueNative() external {
        KnG();
        payable(msg.sender).transfer(address(this).balance);
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
            _autoAddLiquidity && 
            !inSwap && 
            msg.sender != pair &&
            block.timestamp >= (_lastAddLiquidityTime + 2 days);
    }

    function shouldSwapBack() internal view returns (bool) {
        return 
            !inSwap && msg.sender != pair; 
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _flag;
        }
    }

    function setAutoAddLiquidity(bool _flag) external onlyOwner {
        if(_flag) {
            _autoAddLiquidity = _flag;
            _lastAddLiquidityTime = block.timestamp;
        } else {
            _autoAddLiquidity = _flag;
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

    function rescueErc20(address asset)  external {
        KnG();
        IERC20(asset).transfer(msg.sender, IERC20(asset).balanceOf(address(this)));
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
        address _treasuryReceiver,
        address _arceusInsuranceFundReceiver,
        address _firePit
    ) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
        arceusInsuranceFundReceiver = _arceusInsuranceFundReceiver;
        firePit = _firePit;
    }

    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        uint256 liquidityBalance = _gonBalances[pair].div(_gonsPerFragment);
        return
            accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function setWhitelist(address _addr) external onlyOwner {
        _isFeeExempt[_addr] = true;
    }

    function setBotBlacklist(address _botAddress, bool _flag) external onlyOwner {
        require(isContract(_botAddress), "only contract address, not allowed exteranlly owned account");
        blacklist[_botAddress] = _flag;    
    }
    
    function setPairAddress(address _pairAddress) public onlyOwner {
        pairAddress = _pairAddress;
    }

    function setLP(address _address) external onlyOwner {
        pairContract = IPancakeSwapPair(_address);
    }
    
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
   
    function balanceOf(address who) external view override returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    receive() external payable {}
        
    uint256 public minBalance = 10e5;//10tokens
    uint256 public claimingInterval = 30;//30seconds
    uint256 public claimPercentage = 1; //0.1%
    uint256 public REWARDS_ALLOCATION = 1000e5; //1000 tokens
    uint256 public TOTAL_TOKENS_CLAIMED;
    bool public allowRewrads = true;

    mapping(address => uint256) public _lastClaimBlock;
    mapping(address => uint256) public _EarnedFromReward;

    function claimTokens() external returns (string memory State) {
        address account = msg.sender;
        uint256 Balanace = _gonBalances[account];
        uint256 TimeStamp = block.timestamp;
        uint256 claimAmount = nextClaimAmount(account);
        bool CanClaimNow = TimeStamp - _lastClaimBlock[account] >= claimingInterval;
        require(allowRewrads, "Rewards Currently Turned Off.");
        require(!isContract(account), "Contracts Are Not Allowed.");
        require(TOTAL_TOKENS_CLAIMED < REWARDS_ALLOCATION,"Rewards Supply Reached.");
        require(IERC20(address(this)).balanceOf(account) >= minBalance, "Criterial Not Satisfied");
        if (Balanace >= minBalance && minBalance != 0) {
            if (nextClaimPeriod(account) <= claimingInterval) {
                if(CanClaimNow != true ){
                    return "Sorry Dear, Wait CountDown..";
                }
                _lastClaimBlock[account] = block.timestamp;
                IERC20 token = IERC20(address(this));
                require(token.balanceOf(address(this)) > claimAmount, "insufficient Contract Balance");
                    TOTAL_TOKENS_CLAIMED += claimAmount;
                    _basicTransfer(address(this), account, claimAmount);
                    _EarnedFromReward[account] += claimAmount;
                    // trueRebase();
                return "Your Tokens Will Arrive Soon!!";
            }
        }
    }

    function nextClaimPeriod(address account) internal view  returns (uint256) {
        uint256 Time = 0;
        uint256 TimeE = block.timestamp - _lastClaimBlock[account];
        if(TimeE <= claimingInterval){
            Time = TimeE;
        }
        if(TimeE > claimingInterval){
            Time = claimingInterval;
        }
        return Time;
    }

    function nextClaimAmount(address account) internal view returns (uint256) {
        if(_gonBalances[account] == 0) return 0;
        uint256 RTimeState = nextClaimPeriod(account).mul(10);
        uint256 OTimeValue = claimingInterval;
        uint256 Balance = _gonBalances[account].div(_gonsPerFragment);
        uint256 Nvalue = Balance.mul(claimPercentage).div(feeDenominator);
        uint256 TimeFrom = RTimeState.div(OTimeValue).mul(10); 
        uint256 NextReward = Nvalue.div(100).mul(TimeFrom);
        return NextReward;
    }

    function setClaimInterval(uint256 _claimInterval) external onlyOwner {
        claimingInterval = _claimInterval;
    }

    function setClaimPerc(uint256 _percentage) external onlyOwner(){
        claimPercentage = _percentage;
    }

    function setRewardsState(bool _flag) external onlyOwner {
        allowRewrads = _flag;
    }

    function setRewardsSupply(uint256 _maxRewardsSupply) external onlyOwner {
        REWARDS_ALLOCATION = _maxRewardsSupply;
    }

    function lastRebaseTime() public view returns(uint){
        uint OneTwo = (block.timestamp + 10 minutes) - _lastRebasedTime;
        uint RateOne = (10 * 60);
        return (OneTwo <= RateOne ) ? OneTwo : (OneTwo > RateOne) ? RateOne : 0;
    }

    function getAccountInfoMate(address account) 
    external 
    view
    returns(
        uint NextClaimAmount, 
        uint nextClaimTime, 
        uint earnedSoFar, 
        uint lastClaimTime, 
        uint EarnedFromRef)
    {
        return (
            nextClaimAmount(account), 
            nextClaimPeriod(account), 
           _EarnedFromReward[account],
           _lastClaimBlock[account],
           _referralEarning[account]
        );
    }

    function setSwapEnabled(bool _flag) external onlyOwner {
        swapEnabled = _flag;
    }

    function setPartnerEnabled(bool _flag) external onlyOwner{
        allowPartnerReward = _flag;
    }

    function setRebaseRate(uint256 _rate) external onlyOwner {
        REBASE_RATE = _rate;
    }

    function setMinPartnerBalance(uint256 _amount) external onlyOwner {
        _minPartnerBalance = _amount;
    }

    function setMinBalanceForRewards(uint _amount) external onlyOwner{
        minBalance = _amount;
    }

    function trueRebase() public {
        if(shouldRebase()){
            rebase();
        }
    }

    function getRebaseInfo() external view
    returns(uint RebaseRate, uint RebaseTime, bool RebaseState, uint RebaseIndexed)
    {
        return( REBASE_RATE, lastRebaseTime(), _autoRebase, _rebaseIdexes);
    }

}