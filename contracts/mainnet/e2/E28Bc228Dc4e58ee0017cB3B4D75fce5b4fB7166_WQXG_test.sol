/**
 *Submitted for verification at BscScan.com on 2022-03-19
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

interface GinPledge {
    function setDividendsPerShare(uint256 amount) external;
}

interface ZzNFT {
    function balanceOf(address account) external view returns (uint256);
    function balanceInUse(address account) external view returns (uint256);
}

contract WQXG_test is IBEP20, Auth {
    using SafeMath for uint256;

    uint256 public constant MASK = type(uint128).max;
    address dexRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "WQXG_test";
    string constant _symbol = "WQXG_test";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 10_000_000_000_000 * (10 ** _decimals);
    uint256 public _maxHavAmount = _totalSupply;
    uint256 public _maxTxSellAmount = _totalSupply.div(1000); // 0.1%
    uint256 public _minAirDropAmount = 100 * (10 ** _decimals); // 0.00001%

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping(address => bool) diamondHand;
    mapping(address => address) inviter;
    mapping(address => bool) invitExemptList;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isHavLimitExempt;
    mapping (address => bool) isDividendExempt;

    bool isLocked = true;
    bool nftSwitch;

    uint256 public totalBurn;
    uint256 public launchedAtTimestamp;
    uint256 public waitTimestamp = 60 * 5;

    bool public isProtection;

    uint256 buyInviterFee = 200;
    uint256 buyReflectionFee = 300;
    uint256 buyMarketFee = 300;
    uint256 buyTransitionFee = 200;

    uint256 sellInviterFee = 0;
    uint256 sellReflectionFee = 500;
    uint256 sellMarketFee = 300;
    uint256 sellTransitionFee = 400;

    uint256 feeUnit = 500;
    uint256 feeDenominator = 10000;

    address public marketFeeReceiver = 0x18Fd78BcA6Aba71bCEa7a4f8Ec3b66db6cBB6D65;
    address public transitionFeeReceiver = 0x18Fd78BcA6Aba71bCEa7a4f8Ec3b66db6cBB6D65;
    // address public teamFeeReceiver = 0x4f481985197B2e017530A7911109A4028D99D8cF;
    // address public constructionFeeReceiver = 0x96B0e7544B04093370Eda5cF39F807fE2d62B064;

    uint256 public INTERVAL = 24 * 60 * 60;
    uint256 public _protectionT;
    uint256 public _protectionP;

    IDEXRouter public router;
    address public pair;

    address public ginPledgeAddress;
    address public NFTAddress;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 10000; // 0.01%
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(dexRouter);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = _totalSupply;
        WBNB = router.WETH();

        diamondHand[msg.sender] = true;
        isFeeExempt[msg.sender] = true;
        isHavLimitExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;

        isHavLimitExempt[address(this)] = true;
        isDividendExempt[address(this)] = true;

        isHavLimitExempt[DEAD] = true;
        isDividendExempt[DEAD] = true;
        isHavLimitExempt[address(0)] = true;

        approve(dexRouter, _totalSupply);
        approve(address(pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    

    receive() external payable { }

    event Invite(address indexed inviter, address indexed user);

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
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
        if(sender == ginPledgeAddress || recipient == ginPledgeAddress){ return _basicTransfer(sender, recipient, amount); }

        if(sender == pair || recipient == pair){require(launchedAtTimestamp > 0);}
        require(recipient == pair || _balances[recipient].add(amount) <= _maxHavAmount || isHavLimitExempt[recipient], "HAV Limit Exceeded");
        if(recipient == pair){require(amount <= _maxTxSellAmount || isTxLimitExempt[sender], "TX Limit Exceeded");}

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

        if (shouldSetInviter) {
            inviter[recipient] = sender;

            emit Invite(sender, recipient);
        }
        
        checklock();

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        // emit Transfer(sender, recipient, amount);
        return true;
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

    function multiDiamondHand(address[] memory addresses) external authorized {
        for (uint256 i = 0; i < addresses.length; i++) {
            diamondHand[addresses[i]] = true;
        }
    }

    function multiRemoveFromDiamondHand(address[] memory addresses) external authorized {
        for (uint256 i = 0; i < addresses.length; i++) {
            diamondHand[addresses[i]] = false;
        }
    }

    function checkDiamondHand(address holder) public view returns (bool) {
        return diamondHand[holder];
    }

    function checklock() internal {
        if(
            isLocked &&
            (
                IBEP20(USDC).balanceOf(address(this)) >= 9999990 * (10**18) ||
                totalBurn >= 9999990000000 * (10**18) ||
                totalSupply() <= 10000000 * (10**18) ||
                block.timestamp.sub(launchedAtTimestamp) >= 93312000    // 86400 * 30 * 12 * 3  Automatically unlock after 3 years
            )
        )
        {
            isLocked = false;
        }
    }

    function swap(uint256 amount) public {
        require(!isLocked, "Token Smart contract is locked");
        require(diamondHand[msg.sender], "Address is not diamondHand");  // Reward diamondHands after victory day

        this.transferFrom(msg.sender, address(this), amount);
        IBEP20(USDC).transfer(msg.sender, amount);
        
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

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function getFees(bool selling, address user) public view returns (uint256, uint256, uint256, uint256) {
        uint256 inviterFee;
        uint256 reflectionFee;
        uint256 marketFee;
        uint256 transitionFee;

        if(launchedAtTimestamp + waitTimestamp >= block.timestamp){ return (inviterFee, reflectionFee, marketFee, feeDenominator); }

        if(nftSwitch == true && ZzNFT(NFTAddress).balanceInUse(user) > 0){
            marketFee = 0;
            transitionFee = 0;
            if(selling){
                inviterFee = 0;
                reflectionFee = sellReflectionFee;
            }
            else{
                inviterFee = buyInviterFee;
                reflectionFee = 0;
            }
        }
        else if(selling){
            inviterFee = sellInviterFee;
            marketFee = sellMarketFee;
            transitionFee = sellTransitionFee;
            reflectionFee = sellReflectionFee;
            if(isProtection == true){
                uint256 currentP = IBEP20(WBNB).balanceOf(pair).div(_balances[pair]);
                if(currentP < _protectionP.mul(60).div(100)){
                    reflectionFee = reflectionFee.add(feeUnit.mul(4));
                }
                else if(currentP < _protectionP.mul(70).div(100)){
                    reflectionFee = reflectionFee.add(feeUnit.mul(3));
                }
                else if(currentP < _protectionP.mul(80).div(100)){
                    reflectionFee = reflectionFee.add(feeUnit.mul(2));
                }
                else if(currentP < _protectionP.mul(90).div(100)){
                    reflectionFee = reflectionFee.add(feeUnit);
                }
            }
        }
        else{
            inviterFee = buyInviterFee;
            reflectionFee = buyReflectionFee;
            marketFee = buyMarketFee;
            transitionFee = buyTransitionFee;
        }

        return (inviterFee, reflectionFee, marketFee, transitionFee);
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        address user;
        if(sender == pair){user=recipient;}else{user=sender;}
        (uint256 inviterFee, uint256 reflectionFee, uint256 marketFee, uint256 transitionFee) = getFees(recipient == pair, user);
        _balances[marketFeeReceiver] = _balances[marketFeeReceiver].add(amount.mul(marketFee).div(feeDenominator));
        _balances[transitionFeeReceiver] = _balances[transitionFeeReceiver].add(amount.mul(transitionFee).div(feeDenominator));
        _balances[address(this)] = _balances[address(this)].add(amount.mul(reflectionFee).div(feeDenominator));
        _takeInviterFee(sender, recipient, inviterFee, amount);
        uint256 totalAmount = amount.mul(inviterFee.add(reflectionFee).add(marketFee).add(transitionFee)).div(feeDenominator);
        
        emit Transfer(sender, marketFeeReceiver, amount.mul(marketFee).div(feeDenominator));
        emit Transfer(sender, transitionFeeReceiver, amount.mul(transitionFee).div(feeDenominator));
        emit Transfer(sender, address(this), amount.mul(reflectionFee).div(feeDenominator));
        return amount.sub(totalAmount);
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 inviterFee,
        uint256 tAmount
    ) private {
        if (inviterFee == 0) return;
        address cur;
        if (sender == pair) {
            cur = recipient;
        } else if (recipient == pair) {
            cur = sender;
        } else {
            _balances[address(this)] = _balances[address(this)].add(tAmount.mul(inviterFee).div(feeDenominator));
            emit Transfer(sender, address(this), tAmount.mul(inviterFee).div(feeDenominator));
            return;
        }

        uint256 accurRate;
        int256 i = 0;
        while (i < 3) {
            uint256 rate;
            if (i == 0) {
                rate = 200;
            } else if(i == 1 ){
                rate = 100;
            } else {
                rate = 50;
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
        uint256 USDCbalanceBefore = IBEP20(USDC).balanceOf(address(this));

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = WBNB;
        path[2] = USDC;

        _allowances[address(this)][address(router)] = swapThreshold;

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            swapThreshold,
            0, // accept any amount of dividend token
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = IBEP20(USDC).balanceOf(address(this)).sub(USDCbalanceBefore);
        
        IBEP20(USDC).transfer(ginPledgeAddress, amount);
        GinPledge(ginPledgeAddress).setDividendsPerShare(amount);
    }

    function launch() public authorized {
        require(launchedAtTimestamp == 0, "Already launched boi");
        launchedAtTimestamp = block.timestamp;
    }

    function setWaitTimestamp(uint256 _waitTimestamp) external authorized {
        waitTimestamp = _waitTimestamp;
    }

    // function setINTERVAL(uint256 t) external authorized {
    //     INTERVAL = t;
    // }

    function setTxLimit(uint256 sellAmount) external authorized {
        _maxTxSellAmount = sellAmount;
    }

    function setMaxHavAmount(uint256 maxHavAmount) external authorized {
        _maxHavAmount = maxHavAmount;
    }

    function setMinAirDropAmount(uint256 minAirDropAmount) external authorized {
        _minAirDropAmount = minAirDropAmount;
    }

    function setNftAddress(address _nftAddress) external authorized {
        NFTAddress = _nftAddress;
    }

    function setNftSwitch(bool _nftSwitch) external authorized {
        nftSwitch = _nftSwitch;
    }

    function setPair(address _pair) external authorized {
        pair = _pair;
        isHavLimitExempt[pair] = true;
        isDividendExempt[pair] = true;
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool txExempt, bool havExempt) external authorized {
        isTxLimitExempt[holder] = txExempt;
        isHavLimitExempt[holder] = havExempt;
    }

    function setFees(uint256 _buyInviterFee, uint256 _buyMarketFee, uint256 _buyReflectionFee, uint256 _buyTransitionFee, uint256 _sellInviterFee, uint256 _sellMarketFee, uint256 _sellReflectionFee, uint256 _sellTransitionFee, uint256 _feeDenominator, uint256 _feeUnit) external authorized {
        buyInviterFee = _buyInviterFee;
        buyMarketFee = _buyMarketFee;
        buyReflectionFee = _buyReflectionFee;
        buyTransitionFee = _buyTransitionFee;
        sellInviterFee = _sellInviterFee;
        sellMarketFee = _sellMarketFee;
        sellReflectionFee = _sellReflectionFee;
        sellTransitionFee = _sellTransitionFee;
        feeDenominator = _feeDenominator;
        feeUnit = _feeUnit;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setGinPledgeAddress(address _ginPledgeAddress) external authorized {
        ginPledgeAddress = _ginPledgeAddress;
        isHavLimitExempt[ginPledgeAddress] = true;
        isTxLimitExempt[ginPledgeAddress] = true;
        isDividendExempt[ginPledgeAddress] = true;
        isFeeExempt[ginPledgeAddress] = true;
    }
}