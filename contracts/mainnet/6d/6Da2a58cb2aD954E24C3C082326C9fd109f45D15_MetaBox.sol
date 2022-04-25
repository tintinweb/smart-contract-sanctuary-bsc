/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
     function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
}

library EnumerableSet {
   
    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

    
            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    struct Bytes32Set {
        Set _inner;
    }

    
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }


    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

   
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    struct AddressSet {
        Set _inner;
    }

    
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }


    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

   
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

   
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    struct UintSet {
        Set _inner;
    }

    
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

contract MetaBox is IBEP20, Auth {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    string constant _name = "MetaBox";
    string constant _symbol = "MBX";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256 public _minAirDropAmount = 1 * (10 ** 18);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isDividendExempt;

    mapping(address => bool) private _updated;
    mapping(address => uint256) lpAwardTimeStamp;

    mapping(address => address) inviter;
    mapping(address => bool) invitExemptList;

    uint256 public totalBurn;
    uint256 public launchedAtTimestamp;
    uint256 public waitTimestamp = 6;

    bool public isProtection;
    uint public lpCondition = 0;
    uint public usdtCondition = 1 * 10 ** 18;

    uint256 public INTERVAL = 24 * 60 * 60;
    uint256 public _protectionT;
    uint256 public _protectionP;
    uint256 public protectionAccuracyFactor = 10 ** 18;

    address public initPoolAddress;
    uint256 lpAmount;

    uint256 currentIndex;
    uint256 distributorGas = 500000;
    uint256 public minPeriod = 86400;

    uint256 marketFee = 200;
    uint256 burnFee = 200;
    uint256 lpFee = 500;
    uint256 inviterFee = 300;
    uint256 awardFee = 400;
    // uint256 transitionFee = 200;

    uint256 feeUnit = 400;
    uint256 feeDenominator = 10000;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address public marketAddress = 0x6A4327810A577E278ae8eA14D18706558A33824e;
    address public transitionAddress = 0x576EAfa935d795aFBF030d179914838D4480C657;
    address public awardAddress = 0x7a68C5dEa774FB79f44778E57089bf73321a1105;

    IUniswapV2Router02 public uniswapV2Router;
    IERC20 public uniswapV2Pair;
    address public pair;
    address public dexRouter;
    address public WBNB;
    address public USDT;
    address public usdtBnbPair;

    address private fromAddress;
    address private toAddress;

    EnumerableSet.AddressSet lpProviders;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 10000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor (address _dexRouter, address _USDT, address _usdtBnbPair) Auth(msg.sender) {
        dexRouter = _dexRouter;
        USDT = _USDT;
        usdtBnbPair = _usdtBnbPair;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(dexRouter);
        uniswapV2Router = _uniswapV2Router;
        WBNB = _uniswapV2Router.WETH();
        pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), WBNB);
        uniswapV2Pair = IERC20(pair);

        initPoolAddress = owner;

        isFeeExempt[msg.sender] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        approve(dexRouter, _totalSupply);
        approve(address(pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) external view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    receive() external payable {}

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
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
        if((sender == pair || recipient == pair) && !isFeeExempt[sender]){require(launchedAtTimestamp > 0);}

        if( recipient == pair && IERC20(recipient).totalSupply() == 0  ){
            require(sender == initPoolAddress,"not allow init");
            lpAmount = uniswapV2Pair.balanceOf(initPoolAddress);
        }
        
        if(uniswapV2Pair.balanceOf(initPoolAddress) > lpAmount){
            lpAmount = uniswapV2Pair.balanceOf(initPoolAddress);
        }

        if(shouldSwapBack(recipient)){ swapBack(); }

        if(isProtection && block.timestamp.sub(_protectionT) >= INTERVAL){_resetProtection();}

        bool shouldSetInviter = _balances[recipient] == 0 && inviter[recipient] == address(0) && amount >= _minAirDropAmount && sender != pair;

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);

        if (recipient == address(0) || recipient == DEAD) {
            totalBurn = totalBurn.add(amountReceived);
            _totalSupply = _totalSupply.sub(amountReceived);

            emit Burn(sender, address(0), amountReceived);
        }

        if( pair != address(0) ){
            if (fromAddress == address(0)) fromAddress = sender;
            if (toAddress == address(0)) toAddress = recipient;
            if ( fromAddress != pair ) setShare(fromAddress);
            if ( toAddress != pair ) setShare(toAddress);
            fromAddress = sender;
            toAddress = recipient;

            if (
                sender != address(this) 
                && IBEP20(USDT).balanceOf(address(this)) > 0
                && uniswapV2Pair.totalSupply() > 1000 ) {

                process(distributorGas);
            }
        }

        if (shouldSetInviter) {
            inviter[recipient] = sender;
        }

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function getLpProviderAmount(address user) public view returns (uint256) {
        uint256 lpProviderAmount = uniswapV2Pair.balanceOf(user);
        if(user == initPoolAddress){
            lpProviderAmount = lpAmount;
        }
        return lpProviderAmount;
    }

    function getLpProviderBnbAmount(address user) public view returns (uint256) {
        uint256 lpProviderAmount = uniswapV2Pair.balanceOf(user);
        if(user == initPoolAddress){
            lpProviderAmount = lpAmount;
        }
        uint ts = uniswapV2Pair.totalSupply();
        uint256 bnbAmount = IERC20(WBNB).balanceOf(pair).mul(lpProviderAmount).div(ts);
        return bnbAmount;
    }

    function getLpProvider(uint256 _index) public view returns (address) {
        require(_index < lpProviders.length(), 'Index must less than the lenght of lp provider');
        return lpProviders.at(_index);
    }

    function checkLpPass(uint256 amount) public view returns (bool) {
        bool isPass; 
        if (amount >= lpCondition) {
            isPass = true;
        }
        return isPass;
    }

    function process(uint256 gas) private {
        uint256 shareholderCount = lpProviders.length();

        if (shareholderCount == 0) return;

        uint256 nowbanance = IBEP20(USDT).balanceOf(address(this));
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        uint ts = uniswapV2Pair.totalSupply();
        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if(lpAwardTimeStamp[lpProviders.at(currentIndex)].add(minPeriod) <= block.timestamp){
                uint256 lpProviderAmount = getLpProviderAmount(lpProviders.at(currentIndex));
                uint256 amount = nowbanance.mul(lpProviderAmount).div(ts);
                
                if (IBEP20(USDT).balanceOf(address(this)) < amount ) return;

                if (checkLpPass(lpProviderAmount) && amount > usdtCondition) {
                    IBEP20(USDT).transfer(lpProviders.at(currentIndex), amount);  
                }

                lpAwardTimeStamp[lpProviders.at(currentIndex)] = block.timestamp;
            }
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function setShare(address shareholder) private {
        if (_updated[shareholder]) {
            if (uniswapV2Pair.balanceOf(shareholder) == 0) quitShare(shareholder);
            return;
        }
        if (uniswapV2Pair.balanceOf(shareholder) == 0) return;
        lpProviders.add(shareholder);
        _updated[shareholder] = true;
    }

    function quitShare(address shareholder) private {
        lpProviders.remove(shareholder);
        _updated[shareholder] = false;
    }

    function setMinAirDropAmount(uint256 minAirDropAmount) external authorized {
        _minAirDropAmount = minAirDropAmount;
    }

    function setProtection(bool _isProtection) external authorized {
        isProtection = _isProtection;
    }

    function resetProtection() external authorized {
        _protectionT = block.timestamp;
        _protectionP = getPWithAccuracyFactor();
    }

    function setProtectionP(uint256 protectionP) external authorized {
        _protectionP = protectionP;
    }

    function _resetProtection() private {
        uint256 time = block.timestamp;
        if (time.sub(_protectionT) >= INTERVAL) {
        _protectionT = time;
        _protectionP = getPWithAccuracyFactor();
        }
    }

    function getPWithAccuracyFactor() public view returns(uint256) {
        return IERC20(WBNB).balanceOf(pair).mul(protectionAccuracyFactor).div(_balances[pair]);
    }

    function getUsdtPWithAccuracyFactor() public view returns(uint256) {
        uint256 bnbP = IERC20(WBNB).balanceOf(pair).mul(protectionAccuracyFactor).div(_balances[pair]);
        return bnbP.mul(IERC20(USDT).balanceOf(usdtBnbPair).div(IERC20(WBNB).balanceOf(usdtBnbPair)));
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function getFees(bool selling) public view returns (uint256, uint256, uint256, uint256, uint256) {
        uint256 _marketFee = marketFee;
        uint256 _burnFee = burnFee;
        uint256 _lpFee = lpFee;
        uint256 _inviterFee = inviterFee;
        uint256 _awardFee = awardFee;
        // uint256 _transitionFee = transitionFee;

        if(selling){
            if(isProtection == true){
                uint256 currentP = getPWithAccuracyFactor();
                if(currentP < _protectionP.mul(76).div(100)){
                    _lpFee = _lpFee.add(feeUnit.mul(3));
                }
                else if(currentP < _protectionP.mul(84).div(100)){
                    _lpFee = _lpFee.add(feeUnit.mul(2));
                }
                else if(currentP < _protectionP.mul(92).div(100)){
                    _lpFee = _lpFee.add(feeUnit);
                }
            }
        }

        if(launchedAtTimestamp + waitTimestamp >= block.timestamp){ _lpFee = feeDenominator; }

        return (_marketFee, _burnFee, _lpFee, _inviterFee, _awardFee);
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        (uint256 _marketFee, uint256 _burnFee, uint256 _lpFee, uint256 _inviterFee, uint256 _awardFee) = getFees(recipient == pair);
        _balances[marketAddress] = _balances[marketAddress].add(amount.mul(_marketFee).div(feeDenominator));
        _balances[DEAD] = _balances[DEAD].add(amount.mul(_burnFee).div(feeDenominator));
        _balances[address(this)] = _balances[address(this)].add(amount.mul(_lpFee.add(_awardFee)).div(feeDenominator));
        _takeInviterFee(sender, recipient, _inviterFee, amount);
        uint256 _totalFee = _marketFee.add(_burnFee).add(_lpFee).add(_inviterFee).add(_awardFee);
        uint256 totalAmount = amount.mul(_totalFee).div(feeDenominator);
        
        emit Transfer(sender, marketAddress, amount.mul(_marketFee).div(feeDenominator));
        emit Transfer(sender, DEAD, amount.mul(_burnFee).div(feeDenominator));
        emit Transfer(sender, address(this), amount.mul(_lpFee.add(_awardFee)).div(feeDenominator));
        return amount.sub(totalAmount);
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 _inviterFee,
        uint256 tAmount
    ) private {
        if (_inviterFee == 0) return;
        address cur;
        if (sender == pair) {
            cur = recipient;
        } else if (recipient == pair) {
            cur = sender;
        } else {
            _balances[address(this)] = _balances[address(this)].add(tAmount.mul(_inviterFee).div(feeDenominator));
            emit Transfer(sender, address(this), tAmount.mul(_inviterFee).div(feeDenominator));
            return;
        }

        uint256 accurRate;
        int256 i = 0;
        while (i < 6) {
            uint256 rate;
            if (i == 0) {
                rate = 100;
            } else if(i == 1 ){
                rate = 50;
            } else if(i == 2 ){
                rate = 50;
            } else if(i == 3 ){
                rate = 50;
            } else if(i == 4 ){
                rate = 25;
            } else {
                rate = 25;
            }
            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }
            if(invitExemptList[cur] == true){
                continue;
            }
            else{
                accurRate = accurRate.add(rate);
                uint256 curTAmount = tAmount.div(feeDenominator).mul(rate);
                _balances[cur] = _balances[cur].add(curTAmount);
                i++;

                emit Transfer(sender, cur, curTAmount);
            }
        }
        
        _balances[address(this)] = _balances[address(this)].add(tAmount.div(feeDenominator).mul(inviterFee.sub(accurRate)));
        emit Transfer(sender, address(this), tAmount.div(feeDenominator).mul(inviterFee.sub(accurRate)));
    }

    function shouldSwapBack(address recipient) internal view returns (bool) {
        return recipient == pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        _allowances[address(this)][address(uniswapV2Router)] = swapThreshold;
        
        uint256 USDTbalanceBefore = IBEP20(USDT).balanceOf(address(this));

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = WBNB;
        path[2] = USDT;

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            swapThreshold,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = IBEP20(USDT).balanceOf(address(this)).sub(USDTbalanceBefore);
        uint256 amountToAward = amount.mul(awardFee).div(lpFee.add(awardFee));

        IBEP20(USDT).transfer(awardAddress, amountToAward);
    }

    function launch() public authorized {
        require(launchedAtTimestamp == 0, "Already launched boi");
        launchedAtTimestamp = block.timestamp;
    }

    function setWaitTimestamp(uint256 _waitTimestamp) external authorized {
        waitTimestamp = _waitTimestamp;
    }

    function addToInvitExemptList(address[] calldata users) external authorized {
        for (uint i = 0; i < users.length; i++) {
            invitExemptList[users[i]] = true;
        }
    }

    function removeFromInvitExemptList(address[] calldata users) external authorized {
        for (uint i = 0; i < users.length; i++) {
            invitExemptList[users[i]] = false;
        }
    }

    function setPair(address _pair) external authorized {
        pair = _pair;
        uniswapV2Pair = IERC20(pair);
        isDividendExempt[pair] = true;
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setFees(uint256 _marketFee, uint256 _burnFee, uint256 _lpFee, uint256 _inviterFee, uint256 _awardFee, uint256 _feeDenominator, uint256 _feeUnit) external authorized {
        marketFee = _marketFee;
        burnFee = _burnFee;
        lpFee = _lpFee;
        inviterFee = _inviterFee;
        awardFee = _awardFee;
        feeDenominator = _feeDenominator;
        feeUnit = _feeUnit;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setLpCondition(uint lc, uint uc) external authorized{
        lpCondition = lc;
        usdtCondition = uc;
    }

    function setMinPeriod(uint period) external authorized{
        minPeriod = period;
    }

    function getRandomLpProvider() public view returns(address) {
        uint256 random = block.timestamp.mod(lpProviders.length());
        return lpProviders.at(random);
    }

    function takeOutTokenInCase(address _token, uint256 _amount, address _to) public authorized {
        IBEP20(_token).transfer(_to, _amount);
    }

}