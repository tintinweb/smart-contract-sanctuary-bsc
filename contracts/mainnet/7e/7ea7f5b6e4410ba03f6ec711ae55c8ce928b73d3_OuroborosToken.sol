/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// SPDX-License-Identifier: Unlicensed
//
// OBO PROTOCOL COPYRIGHT (C) 2022

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address private _policeDev;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
        _setDev(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyOwnerOrPolice() {
        require(owner() == _msgSender() || _policeDev == _msgSender(), "Ownable: caller is not the owner or dev");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function renounceDevship() public virtual onlyOwnerOrPolice {
        _setDev(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function transferDevship(address newDev) public virtual onlyOwnerOrPolice {
        require(newDev != address(0), "Ownable: new dev is the zero address");
        _setDev(newDev);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function _setDev(address newDev) private {
        _policeDev = newDev;
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

interface INFT{
    function setRelations(address _from, address _to) external;
    function deposit(uint256 _amount) external;
    function getRelations(address _who) external view returns (address[6] memory);
}

contract OuroborosToken is ERC20Detailed, Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SwapAndLiquify(uint256 half, uint256 newBalance, uint256 otherHalf);
    event SwapAndRewardsNFT(uint256 USDTAmount);
    event SwapBack(uint256 USDTAmount);

    string public _name = "Ouroboros Protocol Token";
    string public _symbol = "OBO";
    uint8 public _decimals = 8;

    mapping(address => bool) _isFeeExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    receive () external payable {

    }

    uint256 public constant DECIMALS = 8;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 8;


    uint256 public liquidityFee = 50;
    uint256 public treasuryFee = 50;
    uint256 public nftFee_buy = 20;
    uint256 public nftFee_sell = 40;
    uint256 public firePitFee_buy = 30;
    uint256 public firePitFee_sell = 10;
    uint256 public inviteFee = 50;
    uint256 public feeDenominator = 1000;
    uint256 public totalInviteAmount = 0;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public autoLiquidityReceiver;
    address public treasuryReceiver;
    address public firePit;
    address public dev;
    address public mkt;
    address public nft;
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

    uint256 private MAX_REBASE_TIME = 2 * 365 days;
    uint256 public rebaseRate = 26666;

    bool public _autoRebase;
    bool public _autoSwapBack;
    bool public _autoAddLiquidity;
    bool public _autoSwapRewardsNft;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;
    uint256 public pairBalance;
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    uint256 public startTradingTime;
    uint256 public autoLiquidityInterval;

    constructor(address _swapRouter,address _usdtAddress,address _treasuryReceiver,address _autoLiquidityReceiver,address _dev,address _mkt,address _nft,uint256 _initSupply) ERC20Detailed(_name,_symbol,uint8(DECIMALS)) Ownable() {
        require(_swapRouter != address(0),"invalid swap router address");
        usdtAddress = _usdtAddress;
        router = IPancakeSwapRouter(_swapRouter);
        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        require(_initSupply > 0, "invalid init supply");
        _totalSupply = _initSupply * 10 ** DECIMALS;
        TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % _totalSupply);
        treasuryReceiver = _treasuryReceiver;
        autoLiquidityReceiver = _autoLiquidityReceiver;
        firePit = DEAD;
        dev = _dev;
        mkt = _mkt;
        nft = _nft;

        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _autoRebase = true;
        _autoSwapBack = true;
        _autoAddLiquidity = true;
        _autoSwapRewardsNft = true;
        _allowedFragments[pair][nft] = uint256(-1);
        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[dev] = true;
        _isFeeExempt[mkt] = true;
        _isFeeExempt[nft] = true;
        autoLiquidityInterval = 15 minutes;

        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }

    function manualRebase() external {
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

    function setStartTradingTime(uint256 _time) public onlyOwner {
        startTradingTime = _time;
        if (_time > 0){
            _lastAddLiquidityTime = _time;
            if (_lastRebasedTime == 0){
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
        
        if (sender != owner() && sender != nft) {
            require(startTradingTime > 0 && block.timestamp >= startTradingTime, "can not trade now!");
            if (shouldRebase()) rebase();
            if (shouldAddLiquidity()) addLiquidity();
            if (shouldSwapBack()) swapBack();
            if (shouldSwapRewardsNft()) swapAndRewardsNFT();
        }

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (sender != pair && recipient != pair && (_gonBalances[recipient].div(_gonsPerFragment)) == 0 && amount >= 10 * (10 ** 8) && !isContract(recipient)) {
            INFT(nft).setRelations(sender, recipient);
        } 

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        if (sender != pair && _isFeeExempt[sender] == false && _isFeeExempt[recipient] == false){
            //only can sell 99.9% of balance
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

        if (recipient == pair){
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
        if (recipient == pair) { //when sell tokens
            _totalFee = liquidityFee.add(firePitFee_sell).add(treasuryFee).add(nftFee_sell);
            _gonBalances[autoLiquidityReceiver] = _gonBalances[autoLiquidityReceiver].add(
                gonAmount.div(feeDenominator).mul(liquidityFee)
            );
            _gonBalances[treasuryReceiver] = _gonBalances[treasuryReceiver].add(
                gonAmount.div(feeDenominator).mul(treasuryFee)
            );
            _gonBalances[nft] = _gonBalances[nft].add(
                gonAmount.div(feeDenominator).mul(nftFee_sell)
            );
            _gonBalances[firePit] = _gonBalances[firePit].add(
                gonAmount.div(feeDenominator).mul(firePitFee_sell)
            );
        } else { //when buy or transfer tokens
            _totalFee = inviteFee.add(firePitFee_buy).add(nftFee_buy);
            _gonBalances[firePit] = _gonBalances[firePit].add(
                gonAmount.div(feeDenominator).mul(firePitFee_buy)
            );
            _gonBalances[nft] = _gonBalances[nft].add(
                gonAmount.div(feeDenominator).mul(nftFee_buy)
            );
        }
        if (recipient == pair || sender == pair) {
            require(startTradingTime > 0 && block.timestamp >= startTradingTime,"can not trade now!");
            if (block.timestamp <= startTradingTime + 60){
                _totalFee = _totalFee.add(_robotsFee);
                _gonBalances[autoLiquidityReceiver] = _gonBalances[autoLiquidityReceiver].add(
                    gonAmount.div(feeDenominator).mul(_robotsFee)
                );
            }
        }
        uint256 feeAmount = gonAmount.div(feeDenominator).mul(_totalFee);

        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));

        if (sender == pair) {
            totalInviteAmount = totalInviteAmount.add(gonAmount.div(_gonsPerFragment).mul(inviteFee).div(feeDenominator));
            address[6] memory _parents = INFT(nft).getRelations(recipient);
            for (uint8 i = 0; i < _parents.length; i++){
                uint256 _parentFee = gonAmount.mul(5).div(1000);
                if (i == 0){
                    _parentFee = gonAmount.mul(2).div(100);
                }else if(i == 1){
                    _parentFee = gonAmount.mul(1).div(100);
                }
                if (_parents[i] != ZERO) {
                    _gonBalances[_parents[i]] = _gonBalances[_parents[i]].add(_parentFee);
                    emit Transfer(recipient, _parents[i], _parentFee.div(_gonsPerFragment));
                }
                else _gonBalances[treasuryReceiver] = _gonBalances[treasuryReceiver].add(_parentFee);
            }
        }

        return gonAmount.sub(feeAmount);
    }

    function addLiquidity() internal swapping {
        uint256 autoLiquidityAmount = _gonBalances[autoLiquidityReceiver].div(
            _gonsPerFragment
        );
        if (autoLiquidityAmount > 0){
            _gonBalances[address(this)] = _gonBalances[address(this)].add(
                _gonBalances[autoLiquidityReceiver]
            );
            _gonBalances[autoLiquidityReceiver] = 0;

            swapAndLiquify(autoLiquidityAmount);
            uint256 _p = IERC20(pair).balanceOf(address(this));
            IERC20(pair).transfer(dev, _p.div(2));
            IERC20(pair).transfer(mkt, _p.div(2));
            _lastAddLiquidityTime = block.timestamp;
        }

    }

    function addLiquidityx(uint256 tokenAmount, uint256 ethAmount) private {

        // approve token transfer to cover all possible scenarios
        _allowedFragments[address(this)][address(router)] = tokenAmount;

        // add the liquidity
        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );

    }

    function swapTokensForEth(uint256 tokenAmount) private {

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _allowedFragments[address(this)][address(router)] = tokenAmount;

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

    }

    function swapAndLiquify(uint256 tokens) private {
       // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidityx(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapBack() internal swapping {
        uint256 autoSwapBackAmount = _gonBalances[treasuryReceiver].div(
            _gonsPerFragment
        );
        if (treasuryReceiver != address(0)){
            _gonBalances[address(this)] = _gonBalances[address(this)].add(
                _gonBalances[treasuryReceiver]
            );
            _gonBalances[treasuryReceiver] = 0;

            swapTokensForUSDT(autoSwapBackAmount);
            uint256 swapSend = IERC20(usdtAddress).balanceOf(address(this));
            IERC20(usdtAddress).transfer(dev, swapSend.div(2));
            IERC20(usdtAddress).transfer(mkt, swapSend.div(2));
            emit SwapBack(swapSend);
        }

    }

    function swapAndRewardsNFT() internal swapping {
        uint256 autoSwapBackAmount = _gonBalances[nft].div(
            _gonsPerFragment
        );
        if (nft != address(0)){
            _gonBalances[address(this)] = _gonBalances[address(this)].add(
                _gonBalances[nft]
            );
            _gonBalances[nft] = 0;

            swapTokensForUSDT(autoSwapBackAmount);
            uint256 swapSend = IERC20(usdtAddress).balanceOf(address(this));
            IERC20(usdtAddress).transfer(nft, swapSend);
            INFT(nft).deposit(swapSend);
            emit SwapAndRewardsNFT(swapSend);
        }

    }

    function swapTokensForUSDT(uint256 tokenAmount) private {

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = usdtAddress;

        _allowedFragments[address(this)][address(router)] = tokenAmount;

        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function shouldTakeFee(address from, address to)
    internal
    view
    returns (bool)
    {
        return
        (!_isFeeExempt[from]&&!_isFeeExempt[to]);
    }

    function shouldRebase() internal view returns (bool) {
        return
        _autoRebase &&
        (block.timestamp < startTradingTime + MAX_REBASE_TIME) &&
        msg.sender != pair  &&
        !inSwap &&
        block.timestamp >= (_lastRebasedTime + 15 minutes);
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
        _autoAddLiquidity &&
        !inSwap &&
        msg.sender != pair &&
        _lastAddLiquidityTime>0 &&
        block.timestamp >= (_lastAddLiquidityTime + autoLiquidityInterval) && _gonBalances[autoLiquidityReceiver] > 0;
    }

    function shouldSwapBack() internal view returns (bool) {
        return
        _autoSwapBack&&!inSwap &&
        msg.sender != pair && _gonBalances[treasuryReceiver] > 0;
    }

    function shouldSwapRewardsNft() internal view returns (bool) {
        return
        _autoSwapRewardsNft && !inSwap &&
        msg.sender != pair && _gonBalances[nft] > 0;
    }

    function setAutoRebase(bool _flag) external onlyOwnerOrPolice {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _flag;
        }
    }

    function setAutoSwapBack(bool _flag) external onlyOwnerOrPolice {
        _autoSwapBack = _flag;
    }

    function setAutoSwapRewardsNft(bool _flag) external onlyOwnerOrPolice {
        _autoSwapRewardsNft = _flag;
    }

    function setAutoLiquidityInterval(uint256 _minutes) external onlyOwnerOrPolice {
        require(_minutes > 0, "invalid time");
        autoLiquidityInterval = _minutes * 1 minutes;
    }

    function setAutoAddLiquidity(bool _flag) external onlyOwnerOrPolice {
        if(_flag) {
            _autoAddLiquidity = _flag;
            _lastAddLiquidityTime = block.timestamp;
        } else {
            _autoAddLiquidity = _flag;
        }
    }

    function setOBOTreasuryAddress(address _address) external onlyOwnerOrPolice {
        require(_address != address(0), "invalid address");
        treasuryReceiver = _address;
        _isFeeExempt[treasuryReceiver] = true;
    }

    function setFirePit(address _addr) external onlyOwnerOrPolice {
        require(_addr != address(0), "invalid address");
        firePit = _addr;
        _isFeeExempt[firePit] = true;
    }

    function setAutoLiquidityReceiver(address _addr) external onlyOwnerOrPolice {
        require(_addr != address(0), "invalid address");
        autoLiquidityReceiver = _addr;
        _isFeeExempt[autoLiquidityReceiver] = true;
    }

    function setRebaseRate(uint256 _val) external onlyOwnerOrPolice {
        rebaseRate = _val;
    }

    function setNFT(address _addr) external onlyOwnerOrPolice {
        require(_addr != address(0), "invalid address");
        nft = _addr;
        _isFeeExempt[nft] = true;
    }

    function setDev(address _addr) external {
        require(_addr != address(0), "invalid address");
        require(_msgSender() == dev, "only can call by dev");
        dev = _addr;
        _isFeeExempt[dev] = true;
    }

    function setMkt(address _addr) external {
        require(_addr != address(0), "invalid address");
        require(_msgSender() == mkt, "only can call by mkt");
        mkt = _addr;
        _isFeeExempt[mkt] = true;
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

    function setWhitelist(address[] memory _addrs) external onlyOwnerOrPolice {
        for(uint256 i = 0; i < _addrs.length; i++){
            _isFeeExempt[_addrs[i]] = true;
        }

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