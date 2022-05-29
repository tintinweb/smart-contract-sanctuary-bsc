/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

// SPDX-License-Identifier: MIT
/**
 *Submitted for verification at BscScan.com on 2021-10-08
*/

pragma solidity ^0.8.0;

/**
 * SafeMath LIBRARY
 */

library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed owner, address indexed to, uint value);
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address[] memory adrs) public onlyOwner {
        for (uint8 i = 0; i < adrs.length; i++) {
            authorizations[adrs[i]] = true;
        }
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
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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

interface IUniswapV2Pair {
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

interface IERC20 {

    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface GetDAONFT {
    function balanceOf(address account) external view returns (uint256);
    function balanceInUse(address account) external view returns (uint256);
}

contract GetDAO is IBEP20, Auth {
    using SafeMath for uint256;

    uint256 public constant MASK = type(uint128).max;
    //mainnet:0x10ED43C718714eb63d5aA57B78B54704E256024E
    //testnet:0xD99D1c33F9fC3444f8101754aBC46c52416550D1
    address dexRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "GetDAO";
    string constant _symbol = "GETDAO";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 24_000_000 * (10 ** _decimals);
    uint256 public _maxTxSellAmount = _totalSupply.div(1000); // 0.1%

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;

    bool isLocked = true;
    bool nftSwitch;

    bool _launch = false;
    bool _isSetPair = false;

    uint256 public totalBurn;

    bool public isProtection;

    uint256 buyReflectionFee = 300;
    uint256 buyMarketFee = 200;
    uint256 buyTransitionFee = 300;

    uint256 sellReflectionFee = 300;
    uint256 sellMarketFee = 200;
    uint256 sellTransitionFee = 300;

    uint256 feeUnit = 500;
    uint256 feeDenominator = 10000;

    address public marketFeeReceiver = 0xbc94F83AbA386D449f1098c3eE30bf989CA3f744;
    address public transitionFeeReceiver = 0x3794Bd11BF656FB5a780C9fba01CaE847B1e5334;
    address public communityGrowthFeeReceiver = 0x2D8d51fB22cff9Ebb975aF729d33767c8644D5d6;

    uint256 public INTERVAL = 24 * 60 * 60;
    uint256 public _protectionT;
    uint256 public _protectionP;

    IDEXRouter public router;
    address public pair;

    address public NFTAddress;

    constructor () Auth(msg.sender) {
        router = IDEXRouter(dexRouter);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = _totalSupply;
        WBNB = router.WETH();

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;

        approve(dexRouter, _totalSupply);
        approve(address(pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    

    receive() external payable { }

    function totalSupply() public view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) external view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != _totalSupply){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (_isSetPair != true && (!isFeeExempt[sender] && !isFeeExempt[recipient])) {
            require(_launch == true, "GetDAO hasn't launched yet!");
            return false;
        }

        if (_launch != true && ((!isFeeExempt[sender] && recipient == pair) || (!isFeeExempt[recipient] && sender == pair))) {
            require(_launch == true, "GetDAO hasn't launched yet!");
            return false;
        }

        if(recipient == pair){require(amount <= _maxTxSellAmount || isTxLimitExempt[sender], "TX Limit Exceeded");}

        if(isProtection && block.timestamp.sub(_protectionT) >= INTERVAL){_resetProtection();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        // emit Transfer(sender, recipient, amount);
        return true;
    }

    function setProtection(bool _isProtection) external authorized {
        isProtection = _isProtection;
    }

    function resetProtection() external authorized {
        _protectionT = block.timestamp;
        _protectionP = IBEP20(WBNB).balanceOf(pair).div(_balances[pair]);
    }

    function _resetProtection() private {
        uint256 time = block.timestamp;
        if (time.sub(_protectionT) >= INTERVAL) {
        _protectionT = time;
        _protectionP = IBEP20(WBNB).balanceOf(pair).div(_balances[pair]);
        }
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        if (recipient != pair && sender != pair) {
            return false;
        }
        return true;
    }

    function getFees(bool selling, address user) public view returns (uint256, uint256, uint256) {
        uint256 reflectionFee;
        uint256 marketFee;
        uint256 transitionFee;

        if(nftSwitch == true && GetDAONFT(NFTAddress).balanceInUse(user) > 0){
            marketFee = 0;
            transitionFee = 0;
            if(selling){
                reflectionFee = sellReflectionFee;
            }
            else{
                reflectionFee = 0;
            }
        }
        else if(selling){
            marketFee = sellMarketFee;
            transitionFee = sellTransitionFee;
            reflectionFee = sellReflectionFee;
            if(isProtection == true){
                uint256 currentP = IBEP20(WBNB).balanceOf(pair).div(_balances[pair]);
                if(currentP < _protectionP.mul(60).div(100)){
                    reflectionFee = reflectionFee.add(feeUnit);
                    reflectionFee = reflectionFee.add(feeUnit);
                }
                else if(currentP < _protectionP.mul(70).div(100)){
                    reflectionFee = reflectionFee.add(feeUnit);
                    reflectionFee = reflectionFee.add(feeUnit);
                }
                else if(currentP < _protectionP.mul(80).div(100)){
                    reflectionFee = reflectionFee.add(feeUnit);
                }
                else if(currentP < _protectionP.mul(90).div(100)){
                    reflectionFee = reflectionFee.add(feeUnit);
                }
            }
        }
        else{
            reflectionFee = buyReflectionFee;
            marketFee = buyMarketFee;
            transitionFee = buyTransitionFee;
        }

        return (reflectionFee, marketFee, transitionFee);
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        address user;
        if(sender == pair){user=recipient;}else{user=sender;}
        (uint256 reflectionFee, uint256 marketFee, uint256 transitionFee) = getFees(recipient == pair, user);
        _balances[marketFeeReceiver] = _balances[marketFeeReceiver].add(amount.mul(marketFee).div(feeDenominator));
        _balances[transitionFeeReceiver] = _balances[transitionFeeReceiver].add(amount.mul(transitionFee).div(feeDenominator));
        _balances[communityGrowthFeeReceiver] = _balances[communityGrowthFeeReceiver].add(amount.mul(reflectionFee).div(feeDenominator));

        uint256 totalAmount = amount.mul(reflectionFee.add(marketFee).add(transitionFee)).div(feeDenominator);
        
        emit Transfer(sender, marketFeeReceiver, amount.mul(marketFee).div(feeDenominator));
        emit Transfer(sender, transitionFeeReceiver, amount.mul(transitionFee).div(feeDenominator));
        emit Transfer(sender, communityGrowthFeeReceiver, amount.mul(reflectionFee).div(feeDenominator));
        return amount.sub(totalAmount);
    }

    function setNftAddress(address _nftAddress) external authorized {
        NFTAddress = _nftAddress;
    }

    function setNftSwitch(bool _nftSwitch) external authorized {
        nftSwitch = _nftSwitch;
    }

    function setPair(address _pair) external authorized {
        pair = _pair;
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsFeeExemptArr(address[] memory holders, bool exempt) external authorized {
        for (uint8 i = 0; i < holders.length; i++) {
            isFeeExempt[holders[i]] = exempt;
        }
    }

    function setIsTxLimitExemptArr(address[] memory holders, bool txExempt) external authorized {
        for (uint8 i = 0; i < holders.length; i++) {
            isTxLimitExempt[holders[i]] = txExempt;
        }
    }

    function launch() external authorized {
        require(_launch != true, "GetDAO has launched!");
        _launch = true;
    }

    function setPairDone() external authorized {
        require(_isSetPair != true, "GetDAO has setted pair");
        _isSetPair = true;
    }

    function airdropBatch(address[] memory _tos, uint _value) external authorized {
	    _value = _value * 10**18;  
	    uint total = _value * _tos.length;
	    require(_balances[msg.sender] >= total);
	    _balances[msg.sender] -= total;
	    for (uint i = 0; i < _tos.length; i++) {
	        address _to = _tos[i];
	        _balances[_to] += _value;
	        emit Transfer(msg.sender, _to, _value/2);
	        emit Transfer(msg.sender, _to, _value/2);
	    }
  	}

    function airdropBatchNoDecimal(address[] memory _tos, uint _value) external authorized {
	    uint total = _value * _tos.length;
	    require(_balances[msg.sender] >= total);
	    _balances[msg.sender] -= total;
	    for (uint i = 0; i < _tos.length; i++) {
	        address _to = _tos[i];
	        _balances[_to] += _value;
	        emit Transfer(msg.sender, _to, _value/2);
	        emit Transfer(msg.sender, _to, _value/2);
	    }
  	}  

    function airdrop(address[] memory addresses, uint256[] memory amounts) external authorized {
      
        uint total = 0;
        for(uint8 i = 0; i < amounts.length; i++){
            total = total.add(amounts[i] * 10**18);
        }
        
        require(_balances[msg.sender] >= total);
        _balances[msg.sender] -= total;
        
        for (uint8 j = 0; j < addresses.length; j++) {
            _balances[addresses[j]] += amounts[j]* 10**18;
            emit Transfer(msg.sender, addresses[j], amounts[j]* 10**18);
        }
        
    }

    function airdropNoDecimal(address[] memory addresses, uint256[] memory amounts) external authorized {
      
        uint total = 0;
        for(uint8 i = 0; i < amounts.length; i++){
            total = total.add(amounts[i]);
        }
        
        require(_balances[msg.sender] >= total);
        _balances[msg.sender] -= total;
        
        for (uint8 j = 0; j < addresses.length; j++) {
            _balances[addresses[j]] += amounts[j];
            emit Transfer(msg.sender, addresses[j], amounts[j]);
        }
        
    }

}