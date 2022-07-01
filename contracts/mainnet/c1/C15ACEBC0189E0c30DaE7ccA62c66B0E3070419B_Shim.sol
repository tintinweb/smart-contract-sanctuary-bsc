/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// SPDX-License-Identifier: MIT
/*
███████╗██╗  ██╗██╗███╗   ███╗   ███████╗██╗███╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗
██╔════╝██║  ██║██║████╗ ████║   ██╔════╝██║████╗  ██║██╔══██╗████╗  ██║██╔════╝██╔════╝
███████╗███████║██║██╔████╔██║   █████╗  ██║██╔██╗ ██║███████║██╔██╗ ██║██║     █████╗  
╚════██║██╔══██║██║██║╚██╔╝██║   ██╔══╝  ██║██║╚██╗██║██╔══██║██║╚██╗██║██║     ██╔══╝  
███████║██║  ██║██║██║ ╚═╝ ██║██╗██║     ██║██║ ╚████║██║  ██║██║ ╚████║╚██████╗███████╗
╚══════╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚═╝╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝
*/
//     https://shim.finance/
// SHIM PROTOCOL COPYRIGHT (C) 2022 

pragma solidity ^0.8.11;

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

}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface IShimSwapPair {
	function sync() external;
}

interface IShimSwapRouter{
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
        function swapExactETHForTokens(
            uint amountOutMin,
            address[] calldata path,
            address to,
            uint deadline
        ) external payable returns (uint[] memory amounts);
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

interface IShimSwapFactory {
		function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IStaking {
		function injectReward(uint256 _busdReward) external;
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

contract Shim is Ownable, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    string public _name = "Shim";
    string public _symbol = "SHIM";
    uint8 public _decimals = 5;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;

    mapping(address => bool) _isFeeExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint8 public constant DECIMALS = 5;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 10;

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY =
        1_000_000 * (10**DECIMALS);

    uint256 public constant liquidityFee = 40;
    uint256 public constant treasuryFee = 20;
    uint256 public constant rewardFee = 100;
    uint256 public constant sellFee = 20;

    uint256 public totalFee = liquidityFee.add(treasuryFee).add(rewardFee);
    uint256 public feeDenominator = 1000;

    address public immutable BUSD = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //BUSD

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public autoLiquidityReceiver;
    address public treasuryReceiver;
    IShimSwapRouter public routerETH;
    IShimSwapRouter public routerBUSD;
    address public staking;
    address[] public pairs;
    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private constant TOTAL_GONS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 private constant MAX_SUPPLY = 2_500_000_000 * (10**DECIMALS);

    bool public _autoRebase;
    bool public _autoAddLiquidity;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _lastRewardTime;
    uint256 public rewardPackage;

    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;

    constructor(uint256 _startTime) Ownable() {
        _name = "Shim";
        _symbol = "SHIM";
        _decimals = DECIMALS;
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;

        routerETH = IShimSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        routerBUSD = IShimSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pairs.push(IShimSwapFactory(routerETH.factory()).createPair(
            routerETH.WETH(),
            address(this)
        ));

        autoLiquidityReceiver = 0xd800977Eb030f1E4A69e450F69CF30ceDDC08e0E;
        treasuryReceiver = 0x1d48BF42F8A1e161859ae9e5Bb47092ca4DAdb01;

        _gonBalances[treasuryReceiver] = TOTAL_GONS;
        _allowedFragments[address(this)][address(routerETH)] = MAX_UINT256;

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _autoRebase = true;
        _autoAddLiquidity = true;
        _initRebaseStartTime = _startTime;
        _lastRebasedTime = _startTime;
        _lastAddLiquidityTime = _startTime;
        _lastRewardTime = _startTime;
        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[address(this)] = true;

        _transferOwnership(treasuryReceiver);
        emit Transfer(address(0x0), treasuryReceiver, _totalSupply);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
   
    function balanceOf(address who) public view returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function rebase() internal {
        
        if ( inSwap ) return;
        uint256 rebaseRate;
        uint256 deltaTimeFromInit = block.timestamp - _initRebaseStartTime;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(15 minutes);
        uint256 epoch = times.mul(15);

        if (deltaTimeFromInit < (365 days)) {
            rebaseRate = 1971871;
        } else if (deltaTimeFromInit < ((15 * 365 days) / 10)) {
            rebaseRate = 197187;
        } else if (deltaTimeFromInit < (7 * 365 days)) {
            rebaseRate = 19718;
        } else {
            rebaseRate = 1971;
        }

        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(15 minutes));

        for (uint256 j = 0; j < pairs.length; j++) {
            IShimSwapPair(pairs[j]).sync();
        }

        emit LogRebase(epoch, _totalSupply);
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
        
        if (_allowedFragments[from][msg.sender] != MAX_UINT256) {
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
            swapBack();
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, gonAmount)
            : gonAmount;
        _gonBalances[recipient] = _gonBalances[recipient].add(
            gonAmountReceived
        );


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
        uint256 _totalFee = totalFee;
        uint256 _treasuryFee = treasuryFee;

        for (uint256 i = 0; i < pairs.length; i++) {
            if (recipient == pairs[i]) {
                _totalFee = totalFee.add(sellFee);
                _treasuryFee = treasuryFee.add(sellFee);
                break;
            }
        }

        uint256 feeAmount = gonAmount.div(feeDenominator).mul(_totalFee);
       
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            gonAmount.div(feeDenominator).mul(_treasuryFee.add(rewardFee))
        );
        _gonBalances[autoLiquidityReceiver] = _gonBalances[autoLiquidityReceiver].add(
            gonAmount.div(feeDenominator).mul(liquidityFee)
        );
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
        path[1] = routerETH.WETH();

        uint256 balanceBefore = address(this).balance;


        routerETH.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);

        if (amountToLiquify > 0&&amountETHLiquidity > 0) {
            routerETH.addLiquidityETH{value: amountETHLiquidity}(
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

    function swapBack() internal swapping {

        uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);

        if( amountToSwap == 0) {
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = routerETH.WETH();

        uint256 balanceBefore = address(this).balance;

        routerETH.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHToSwap = address(this).balance.sub(balanceBefore);

        path[0] = routerBUSD.WETH();
        path[1] = BUSD;

        balanceBefore = IERC20(BUSD).balanceOf(address(this));

        routerBUSD.swapExactETHForTokens{value: amountETHToSwap}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBUSDForTreasuryAndReward = IERC20(BUSD).balanceOf(
            address(this)).sub(balanceBefore);
        uint256 amountBUSDForReward = amountBUSDForTreasuryAndReward.mul(
            rewardFee).div(treasuryFee.add(rewardFee));
        uint256 amountBUSDForTreasury = amountBUSDForTreasuryAndReward.sub(
            amountBUSDForReward);

        IERC20(BUSD).transfer(treasuryReceiver, amountBUSDForTreasury);

        rewardPackage += amountBUSDForReward;
        IStaking(staking).injectReward(rewardPackage);
        rewardPackage = 0;
        _lastRewardTime = block.timestamp;
    }

    function withdrawAllToTreasury() external swapping onlyOwner {
        uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);
        require( amountToSwap > 0,"There is no Shim token deposited in token contract");

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = routerETH.WETH();

        routerETH.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHToSwap = address(this).balance;

        path[0] = routerBUSD.WETH();
        path[1] = BUSD;

        routerBUSD.swapExactETHForTokens{value: amountETHToSwap}(
            0,
            path,
            treasuryReceiver,
            block.timestamp
        );
    }

    function shouldTakeFee(address from, address to)
        internal
        view
        returns (bool)
    {
        bool flag = false;
        if (!_isFeeExempt[from]) {
            for (uint256 i = 0; i < pairs.length; i++) {
                if (pairs[i] == from || pairs[i] == to) {
                    flag = true;
                    break;
                }
            }
        }
        return flag;
    }

    function shouldRebase() internal view returns (bool) {
        bool flag = _autoRebase &&
            (_totalSupply < MAX_SUPPLY) &&
            !inSwap &&
            block.timestamp >= (_lastRebasedTime + 15 minutes);
        if (flag) {
            for (uint256 i = 0; i < pairs.length; i++) {
                if (msg.sender == pairs[i]) {
                    flag = false;
                    break;
                }
            }
        }
        return flag;
    }

    function shouldAddLiquidity() internal view returns (bool) {
        bool flag = _autoAddLiquidity && 
            !inSwap && 
            block.timestamp >= (_lastAddLiquidityTime + 2 days);
        if (flag) {
            for (uint256 i = 0; i < pairs.length; i++) {
                if (msg.sender == pairs[i]) {
                    flag = false;
                    break;
                }
            }
        }
        return flag;
    }

    function shouldSwapBack() internal view returns (bool) {
        bool flag = !inSwap &&
            block.timestamp >= (_lastRewardTime + 15 minutes);
        if (flag) {
            for (uint256 i = 0; i < pairs.length; i++) {
                if (msg.sender == pairs[i]) {
                    flag = false;
                    break;
                }
            }
        }
        return flag; 
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
        for (uint256 i = 0; i < pairs.length; i++) {
            IShimSwapPair(pairs[i]).sync();
        }
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _treasuryReceiver
    ) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
    }

    function getLiquidityBacking(uint256 accuracy)
        external
        view
        returns (uint256)
    {
        uint256 liquidityBalance = 0;
        for (uint256 i = 0; i < pairs.length; i++) {
            liquidityBalance = liquidityBalance.add(
                _gonBalances[pairs[i]].div(_gonsPerFragment));
        }
        return
            accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function setWhitelist(address _addr) external onlyOwner {
        _isFeeExempt[_addr] = true;
    }

    function setBotBlacklist(address _botAddress, bool _flag) external onlyOwner {
        require(isContract(_botAddress),
            "only contract address, not allowed exteranlly owned account");
        blacklist[_botAddress] = _flag;    
    }
    
    function addPair(address _pair) external onlyOwner {
        require(isContract(_pair), "only contract address");
        pairs.push(_pair);
    }

    function setPair(uint256 _id, address _pair) external onlyOwner {
        require(isContract(_pair), "only contract address");
        pairs[_id] = _pair;
    }

    function removePair(uint256 _id) external onlyOwner {
        pairs[_id] = pairs[pairs.length-1];
        pairs.pop();
    }

    function pairsLength() external view returns (uint256) {
        return pairs.length;
    }

    function setRouterETH(address _routerETH) external onlyOwner {
        require(isContract(_routerETH), "only contract address");
        routerETH = IShimSwapRouter(_routerETH);
        _allowedFragments[address(this)][address(_routerETH)] = MAX_UINT256;
    }

    function setRouterBUSD(address _routerBUSD) external onlyOwner {
        require(isContract(_routerBUSD), "only contract address");
        routerBUSD = IShimSwapRouter(_routerBUSD);
    }

    function setStaking(address _staking) external onlyOwner {
        require(isContract(_staking), "only contract address");
        staking = _staking;
        IERC20(BUSD).approve(_staking, MAX_UINT256);
    }

    function updateStartTime(uint256 _startTime) external onlyOwner {
        require(_initRebaseStartTime > block.timestamp, "Rebase have been already begun.");
        _initRebaseStartTime = _startTime;
        _lastRebasedTime = _startTime;
        _lastAddLiquidityTime = _startTime;
        _lastRewardTime = _startTime;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    receive() external payable {}
}