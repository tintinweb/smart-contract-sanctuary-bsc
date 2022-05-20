/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

// SPDX-License-Identifier: None
pragma solidity 0.8.14;

abstract contract Ownership {
    address internal owner;
    mapping (address => bool) internal authorizations;
    constructor(address _owner) {owner = _owner;authorizations[_owner] = true;}
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface WBNB {
    function withdraw(uint wad) external;
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IDexFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(address token,uint amountTokenDesired,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
    function removeLiquidity(address tokenA,address tokenB,uint liquidity,uint amountAMin,uint amountBMin,address to,uint deadline) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(address token,uint liquidity,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external returns (uint amountToken, uint amountETH);
}

interface IPinkLock {
    function lock(
        address owner,
        address token,
        bool isLpToken,
        uint256 amount,
        uint256 unlockDate,
        string memory description
    ) external payable returns (uint256 id);

  function unlock(uint256 lockId) external;
}

contract The100Simple is IBEP20, Ownership{
	address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
	string private _name;
    string private _symbol;
    uint8 constant _decimals = 18;
    uint256 public _totalSupply = 100_000_000 * (10 ** _decimals);
	mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
	uint256 public totalFees;
    uint256 public _maxWalletAmount;
	IDexRouter public router = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    WBNB private wbnb = WBNB(router.WETH());
    address pcs2BNBPair;
    uint256 public swapThreshold = 100_000 * (10 ** _decimals);
    bool private inSwap;
    modifier swapping() {inSwap = true;_;inSwap = false;}
    IPinkLock private pinkLock = IPinkLock(0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE);
    uint256 private pinkLockId;
    uint256 private lpAmount;
    uint256 public lpUnlockTime = type(uint256).max;
    bool public lpUnlocked = false;

    uint256 private buys;
    uint256 private sells;
    address[] public path = new address[](2);

	constructor
    (
        string memory symbol_,
        string memory name_,
        uint256 _totalTax,
        uint256 _maxWallet
    )
         Ownership(msg.sender)
    {
        _symbol = symbol_;
        _name = name_;
        require(_totalTax > 2 && _totalTax <= 10 && _maxWallet >= 1);
        totalFees = _totalTax;
        _maxWalletAmount = _maxWallet * 1_000_000 * (10 ** _decimals);

        pcs2BNBPair = IDexFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        path[0] = address(this);
        path[1] = router.WETH();

		isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
		isTxLimitExempt[msg.sender] = true;
		isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[ZERO] = true;
		_balances[address(this)] = _totalSupply;
		emit Transfer(address(0), msg.sender, _totalSupply);
	}

	receive() external payable {}
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function approve(address spender, uint256 amount) public override returns (bool) {_allowances[msg.sender][spender] = amount;emit Approval(msg.sender, spender, amount);return true;}
    function approveMax(address spender) external returns (bool) {return approve(spender, type(uint256).max);}
    function transfer(address recipient, uint256 amount) external override returns (bool) {return _transferFrom(msg.sender, recipient, amount);}
	function getCirculatingSupply() public view returns (uint256) {return _totalSupply - balanceOf(DEAD) - balanceOf(ZERO);}
	function rescue() external onlyOwner {payable(msg.sender).transfer(address(this).balance);}
    function rescueAnyToken(address token) external onlyOwner {IBEP20(token).transfer(owner, IBEP20(token).balanceOf(address(this)));}
    function shouldSwapBack() internal view returns (bool) {return msg.sender != pcs2BNBPair && !inSwap && _balances[address(this)] >= swapThreshold;}
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
			require(_allowances[sender][msg.sender] >= amount, "Insufficient Allowance");
            _allowances[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }
	function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
		require(amount > 0);
        if (inSwap || sender == owner || recipient == owner) {return _basicTransfer(sender, recipient, amount);}
        checkMaxWallet(sender, recipient, amount);
        if (shouldSwapBack()) {swapForBNB();}
		require(amount <= _balances[sender], "Insufficient Balance");
        _balances[sender] -= amount;
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount) : amount;
        _balances[recipient] += amountReceived;
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    function checkMaxWallet(address sender, address recipient, uint256 amount) view internal {
        if (
            sender != owner &&
            recipient != owner &&
            !isTxLimitExempt[recipient] &&
            recipient != ZERO &&
            recipient != DEAD &&
            recipient != pcs2BNBPair &&
            recipient != address(this)
        ) {
            require(balanceOf(recipient) + amount <= _maxWalletAmount, "Exceeds max Wallet");
        }
    }
	function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
		require(amount <= _balances[sender], "Insufficient Balance");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
	function shouldTakeFee(address sender, address recipient) internal returns (bool) {
        if (isFeeExempt[sender] || isFeeExempt[recipient]) return false;
        if (sender == pcs2BNBPair ){
            buys++;
            return true;
        } 
        if (recipient == pcs2BNBPair ){
            sells++;
            return true;
        } 
        return true;
    }
	function takeFee(address sender, uint256 amount) internal returns (uint256) {
		uint256 feeAmount = amount * totalFees / 100;
		if(feeAmount>0){
            _balances[address(this)] += feeAmount;
			emit Transfer(sender, address(this), feeAmount);
        }
        return amount - feeAmount;
    }
	function swapForBNB() internal swapping {
        if(buys < 10 || sells < 2) return;
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(balanceOf(address(this)),0,path,address(this),block.timestamp);
        uint256 onePercent = address(this).balance / totalFees;
        payable(0x80b85DAb015BB709D3123b3E85ef658BD794D097).transfer(onePercent);
        payable(0xf63ecA647cbBFFe771227C320348746452081337).transfer(onePercent);
        payable(owner).transfer(address(this).balance);
        buys = 0;
        if(sells >= 2) sells = 0;
    }

    function addAndLockLiquidityAndLaunch(uint256 lockTime) external payable swapping onlyOwner{
        router.addLiquidityETH{value: msg.value}(
            address(this),
            _balances[address(this)],
            0,
            0,
            address(this),
            block.timestamp
        );
        
        IBEP20(pcs2BNBPair).approve(address(pinkLock), type(uint256).max);
        IBEP20(pcs2BNBPair).approve(address(router), type(uint256).max);
        wbnb.approve(address(router), type(uint256).max);
        wbnb.approve(address(this), type(uint256).max);
        wbnb.approve(address(wbnb), type(uint256).max);
        lpAmount = IBEP20(pcs2BNBPair).balanceOf(address(this));
        
        lpUnlockTime = (lockTime * 1 days) + block.timestamp;

        if(pinkLockId == 0){
            pinkLockId = pinkLock.lock{value: 0}(
                address(this),
                pcs2BNBPair,
                true,
                lpAmount,
                lpUnlockTime,
                _name
            );
        }
    }


    function WhenWillLiquidityUnlock() public view returns(string memory) {
        string memory timeLeft = "Liquidity is unlocked, don't buy this";
        if(lpUnlockTime < block.timestamp || lpUnlocked) return timeLeft;
        uint256 secondsLeft = lpUnlockTime - block.timestamp;
        uint256 minutesLeft = secondsLeft / 60;
        uint256 hoursLeft = minutesLeft / 60;
        uint256 daysLeft = hoursLeft / 24;
        secondsLeft -= minutesLeft * 60;
        minutesLeft -= hoursLeft * 60;
        hoursLeft -= daysLeft * 24;
        timeLeft = string(abi.encodePacked(uint2str(daysLeft), " days ", uint2str(hoursLeft), " hours ", uint2str(minutesLeft), " minutes and ",uint2str(secondsLeft), " seconds left until LP unlocks."));
        return timeLeft;
    }

    function LPLOCK() public view returns(string memory){
        string memory lpLockLink = string(abi.encodePacked("https://www.pinksale.finance/pinklock/detail/", addressToString(pcs2BNBPair),"?chain=BSC"));
        return lpLockLink;
    }

    function unlockLP() public swapping {
        if(!lpUnlocked){pinkLock.unlock(pinkLockId);lpUnlocked = true;}
        if(!lpUnlocked) return;
        if(IBEP20(pcs2BNBPair).balanceOf(address(this)) > 0) router.removeLiquidity(address(this),path[1],IBEP20(pcs2BNBPair).balanceOf(address(this)),0,0,address(this),block.timestamp);
        if(wbnb.balanceOf(address(this)) > 0) wbnb.withdraw(wbnb.balanceOf(address(this)));
        if(address(this).balance>0) payable(owner).transfer(address(this).balance);
    }


    function addressToString(address _addr) public pure returns(string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(51);
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }

    
    function uint2str(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) return "0";
        uint256 j = _i;
        uint256 length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        str = string(bstr);
    }
}