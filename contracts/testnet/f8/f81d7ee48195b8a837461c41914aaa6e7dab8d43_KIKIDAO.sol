/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
        // assert(a == b * c + a % b);
        // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IPancakeFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IPancakeRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IPancakePair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function sync() external;

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

interface KIKDAO{
    function swapWhiteList(address user) external view returns (bool);
    function relationship(address child) external view returns (address);
    function addRetation(address sender, address recipient) external returns (bool);
    function _limitSwap() external returns (bool);
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract KIKIDAO is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    string private _name;

    string private _symbol;

    uint256 private _totalSupply;

    address private created;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public marketAddress = 0x89b069E8b0ad60c5381683a6B7D437CcEBDAe71f;

    address public _router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

    mapping(address => bool) public isExcludedFromFee;

    address public _pair;

    uint256 public _maxTxAmount = 10;

    uint256 public txlimitByBnb = 2 * 10**18;

    uint256 public finalSupply = 91 * 10**4 * 10**18;

    uint256 public openBlock = 19028187;

    uint256 public limitBlock = 19028187;

    KIKDAO public relateContract = KIKDAO(0x0713010cE78aDc5DAFE873EF645daeEe8338eD04);

    constructor() {
        _name = "KIKIDAO";
        _symbol = "KIKIDAO";
        _mint(owner(), 91 * 10**6 * 10**18);
        IPancakeRouter router = IPancakeRouter(_router);
        _pair = IPancakeFactory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[_router] = true;
        isExcludedFromFee[marketAddress] = true;
        isExcludedFromFee[address(this)] = true;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(uint256 amount) internal virtual returns (uint256) {
        if (_totalSupply < finalSupply) {
            return amount;
        }
        if (_totalSupply.sub(amount) <= finalSupply) {
            uint256 burnAmount = _totalSupply.sub(finalSupply);
            _totalSupply = _totalSupply.sub(burnAmount);
            _balances[deadAddress] = _balances[deadAddress].add(burnAmount);
            emit Transfer(address(0), deadAddress, burnAmount);
            return amount.sub(burnAmount);
        } else {
            _totalSupply = _totalSupply.sub(amount);
            _balances[deadAddress] = _balances[deadAddress].add(amount);
            emit Transfer(address(0), deadAddress, amount);
            return 0;
        }
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        addNextAdd(sender, recipient);   
        if (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) {
            _basicTransfer(sender, recipient, amount);
        } else {
            limitTx(amount);
            if (sender == _pair) {
                if(block.number < openBlock){
                    require(relateContract.relationship(recipient) != address(0) || amount < _maxTxAmount / 4, "Not yet open");
                }
                if(block.number < limitBlock){
                    require(relateContract.swapWhiteList(recipient),"Not yet open");
                }
                uint256 senderBalance = _balances[sender];
                require(
                    senderBalance >= amount,
                    "ERC20: transfer amount exceeds balance"
                );
                unchecked {
                    _balances[sender] = senderBalance.sub(amount);
                }
                uint256 share = amount.div(100);
                uint256 surplus = promotionRewards(tx.origin, share);
                _balances[recipient] = _balances[recipient].add(
                    share.mul(88).add(surplus)
                );
                emit Transfer(sender, recipient, share.mul(88).add(surplus));
            }
            else if(recipient == _pair){
                if(relateContract._limitSwap()){
                    require(relateContract.swapWhiteList(sender),"You cannot sell");
                }else{
                    require(!relateContract.swapWhiteList(sender),"You cannot sell");
                }
                if(block.number < openBlock){
                    require(relateContract.relationship(sender) != address(0) || amount < _maxTxAmount / 4, "Not yet open");
                }
                _basicTransfer(sender, recipient, amount);
            } 
            else {
                if(relateContract._limitSwap()){
                    require(relateContract.swapWhiteList(sender),"You cannot transfer out");
                }else{
                    require(!relateContract.swapWhiteList(sender),"You cannot transfer out");
                }
                uint256 senderBalance = _balances[sender];
                require(
                    senderBalance >= amount,
                    "ERC20: transfer amount exceeds balance"
                );
                unchecked {
                    _balances[sender] = senderBalance.sub(amount);
                }
                uint256 share = amount.div(100);
                uint256 noBurn = _burn(share.mul(5));
                _balances[recipient] = _balances[recipient].add(
                    share.mul(95).add(noBurn)
                );
                emit Transfer(sender, recipient, share.mul(95).add(noBurn));
            }
        }
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount,"Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function setIsExcludedFromFee(address account, bool newValue)
        public
        onlyOwner
    {
        isExcludedFromFee[account] = newValue;
    }

    function setMarketAddress(address _marketAddress) public onlyOwner{
        marketAddress = _marketAddress;
    }

    function setTxlimitByBnb(uint256 _txLimitByBnb) public onlyOwner{
        txlimitByBnb = _txLimitByBnb;
    }

    function setRelateContract(KIKDAO _relateContract) public onlyOwner{
        relateContract = _relateContract;
    }

    function setOpenBlock(uint256 _openBlock) public  onlyOwner{
        openBlock = _openBlock;
    }

    function setLimitBlock(uint256 _limitBlock) public  onlyOwner{
        limitBlock = _limitBlock;
    }

    function setPair(address pair) public onlyOwner{
        _pair = pair;
    }

    function addNextAdd(address sender, address recipient) private {
        relateContract.addRetation(sender, recipient);
    }

    function isContract(address account) public view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function promotionRewards(address sender, uint256 share)
        private
        returns (uint256)
    {
        address pre = relateContract.relationship(sender);
        uint256 total = share.mul(12);
        uint256 a;
        if (pre != address(0)) {
            if(_balances[pre] > 0){
                a = share.mul(3);
                _balances[pre] = _balances[pre].add(a);
                total = total.sub(a);
                emit Transfer(sender, pre, a);
            }
            pre = relateContract.relationship(pre);
        }
        if (pre != address(0)) {
            if (holdCoinlimit(pre, _maxTxAmount)) {
                a = share.mul(2);
                _balances[pre] = _balances[pre].add(a);
                total = total.sub(a);
                emit Transfer(sender, pre, a);
            }
            pre = relateContract.relationship(pre);
        }
        if (pre != address(0)) {
            if (holdCoinlimit(pre, _maxTxAmount)) {
                a = share;
                _balances[pre] = _balances[pre].add(a);
                total = total.sub(a);
                emit Transfer(sender, pre, a);
            }
            pre = relateContract.relationship(pre);
        }
        uint256 marketBonusAmount = share.mul(3);
        _balances[marketAddress] = _balances[marketAddress].add(marketBonusAmount);
        total = total.sub(marketBonusAmount);
        emit Transfer(sender, marketAddress, marketBonusAmount);
        return _burn(total);
    }

    function holdCoinlimit(address holder, uint256 limitNumer)
        internal
        view
        returns (bool)
    {
        return _balances[holder] >= limitNumer;
    }

    function limitTx(uint256 amount) internal {
        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(_pair)
            .getReserves();

        if (reserve1 > 0 && address(this) == IPancakePair(_pair).token0()) {
            _maxTxAmount = reserve0.mul(txlimitByBnb).div(reserve1);
        }
        if (reserve0 > 0 &&  address(this) == IPancakePair(_pair).token1()) {
            _maxTxAmount = reserve1.mul(txlimitByBnb).div(reserve0);
        }
        require(
            amount <= _maxTxAmount,
            "Transfer amount exceeds the maxTxAmount."
        );
    }
}