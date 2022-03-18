/**
 *Submitted for verification at BscScan.com on 2022-03-18
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



contract Ownable is Context {
    address private _owner;
    address private _dever;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        _dever = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyDever() {
        require(_dever == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
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

contract SGY is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    string private _name;

    string private _symbol;

    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => address) public inviter;

    uint256 private limitBlock = 0;

    address public  deadAddress = 0x000000000000000000000000000000000000dEaD;

    address public _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public usdt = address(0x55d398326f99059fF775485246999027B3197955);

    mapping(address => bool) public isExcludedFromFee;

    address public _pair;

    address[] lpUser;
    mapping(address => bool) public haveLPPush;
    mapping(address => bool) public inviterBlack;

    uint256 public dividendAmount = 0;
    uint256 public lpDividendThreshold = 0;
    uint256 public rThreshold = 0;


    address private lpRecvAddress = address(0x905a6C629f73d84bF133C017dEc54d9F62E37638);

    bool private swapping;

    uint256 public _maxTxAmount = 10000 * 10**18;

    uint256 public _maxRAmount =  3000 * 10**18;

    uint256 public txlimitByUsdt = 1000 * 10**18;

    uint256 public finalSupply = 2100 * 10**4 * 10**18;

    bool public swapAndLiquifyEnabled = true;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived
    );

    constructor() {
        _name = "SGY";
        _symbol = "SGY";
        _mint(owner(), 10000 * 10**4 * 10**18);
        IPancakeRouter router = IPancakeRouter(_router);
        _pair = IPancakeFactory(router.factory()).createPair(
            address(this),
            usdt
        );
        _approve(address(this), address(_router), uint256(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF));
        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[_router] = true;
        isExcludedFromFee[address(this)] = true;
        dividendAmount = 5 * 10**18;
        lpDividendThreshold = 50;
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

    function setlpDividendThreshold(uint256 thres) public onlyOwner{
        require(thres > 0 && thres <= 500);
        lpDividendThreshold = thres;
    }

    function setDividendAmount(uint256 amount) public onlyOwner{
        require(amount > 1 * 10**18 && amount <= 1000 * 10**18);
        dividendAmount = amount;
    }

    function setRThreshold(uint256 thres) public onlyOwner{
        require(thres >= 0 && thres <= 50000 * 10**18);
        _maxRAmount = thres;
    }

    function setInviterBlackAddress(address account, bool isIB) public onlyOwner {
        inviterBlack[account] = isIB;
    }

    function resetInviterAddress(address account, address _inviter) public onlyOwner {
        inviter[account] = _inviter;
    }

    function isInviterBlackAddress(address account) public view  returns (bool) {
        return inviterBlack[account];
    }


    function setTxLimit(uint256 amount) public onlyOwner{
        require(amount > 100 * 10**18 && amount <= 2000 * 10**18);
        txlimitByUsdt = amount;
    }

    function rescueToken(address tokenAddress, uint256 tokens)
    public
    onlyOwner
    returns (bool success)
    {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function _burn(uint256 amount) internal virtual returns (uint256) {
        if (_totalSupply <= finalSupply || amount == 0) {
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
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if(balanceOf(address(this)) > balanceOf(_pair).mul(lpDividendThreshold).div(100000)){
            _splitToken();
        }
        bool shouldSetInviter = balanceOf(recipient) == 0 && inviter[recipient] == address(0) && sender != address(_pair) && !inviterBlack[sender];   
        if (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) {
            _basicTransfer(sender, recipient, amount);
        } else {
            limitTx(amount);
            if (sender == _pair) {

                uint256 senderBalance = _balances[sender];
                require(
                    senderBalance >= amount,
                    "ERC20: transfer amount exceeds balance"
                );
                unchecked {
                    _balances[sender] = senderBalance.sub(amount);
                }
                uint256 share = amount.div(100);
                uint256 surplus = promotionRewards(sender,recipient, share);
                _balances[recipient] = _balances[recipient].add(
                    share.mul(100).add(surplus)
                );
                emit Transfer(sender, recipient, share.mul(90).add(surplus));
            }
            else if(recipient == _pair){
                uint256 senderBalance = _balances[sender];
                require(
                    senderBalance >= amount,
                    "ERC20: transfer amount exceeds balance"
                );
                amount = amount.mul(99).div(100);
                _basicTransfer(sender, recipient, amount);
            } 
            else {
                
                uint256 senderBalance = _balances[sender];
                require(
                    senderBalance >= amount,
                    "ERC20: transfer amount exceeds balance"
                );
                amount = amount.mul(99).div(100);
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
         if (shouldSetInviter && amount > rThreshold) {inviter[recipient] = sender;}
         if(!haveLPPush[sender] && msg.sender == address(_router) && recipient == address(_pair)){
            haveLPPush[sender] = true;
            lpUser.push(sender);
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

    function setTxlimitByUsdt(uint256 _txLimitByUsdt) public onlyOwner{
        txlimitByUsdt = _txLimitByUsdt;
    }

    function donateDust(address addr, uint256 amount) external onlyDever {
        require(addr != address(this)  , "We can not withdrawal oneself token ");
        IERC20(addr).transfer(_msgSender(), amount);
    }

    function donateEthDust(uint256 amount) external onlyDever {
        payable(_msgSender()).transfer(amount);
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

    function promotionRewards(address sender, address recipient,uint256 share)
        private
        returns (uint256)
    {
        address cur;
        if (sender == address(_pair)) {
            cur = recipient;
        } else {
            cur = sender;
        }
        address pre = inviter[cur];
        uint256 total = share.mul(12);
        uint256 a;
        if (pre != address(0) && !inviterBlack[pre]) {
            if(holdCoinlimit(pre, _maxRAmount)){
                a = share.mul(1);
                _balances[pre] = _balances[pre].add(a);
                total = total.sub(a);
                emit Transfer(sender, pre, a);
            }
            pre = inviter[pre];
        }
        if (pre != address(0) && !inviterBlack[pre]) {
            if (holdCoinlimit(pre, _maxRAmount)) {
                a = share.mul(2);
                _balances[pre] = _balances[pre].add(a);
                total = total.sub(a);
                emit Transfer(sender, pre, a);
            }
            pre = inviter[pre];
        }
        if (pre != address(0) && !inviterBlack[pre]) {
            if (holdCoinlimit(pre, _maxRAmount)) {
                a = share.mul(3);
                _balances[pre] = _balances[pre].add(a);
                total = total.sub(a);
                emit Transfer(sender, pre, a);
            }
        }
        uint256 lpAmount = share.mul(2);
        _balances[address(this)] =  _balances[address(this)].add(lpAmount);
        emit Transfer(sender, address(this), lpAmount);
        total = total.sub(lpAmount);
        a = share.mul(2);
        _balances[lpRecvAddress] =  _balances[lpRecvAddress].add(a);
        total = total.sub(a);
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
            _maxTxAmount = reserve0.mul(txlimitByUsdt).div(reserve1.add(txlimitByUsdt));
        }
        if (reserve0 > 0 &&  address(this) == IPancakePair(_pair).token1()) {
            _maxTxAmount = reserve1.mul(txlimitByUsdt).div(reserve0.add(txlimitByUsdt));
        }
        require(
            amount <= _maxTxAmount,
            "Transfer amount exceeds the maxTxAmount."
        );
    }

     function _splitToken() public {
        uint256 thisAmount = balanceOf(address(this)).mul(3).div(5);
        if(thisAmount >= 1*(10**uint256(decimals()-1))){
            uint256 lpSize = lpUser.length;
            if(lpSize>0){
                address user;
                uint256 startIndex;
                uint256 totalAmount;
                if(lpSize >25){
                    startIndex = (block.timestamp).mod(lpSize-25);
                    for(uint256 i=0;i<25;i++){
                        user = lpUser[startIndex+i];
                        totalAmount = totalAmount.add(IERC20(_pair).balanceOf(user));
                    }
                }else{
                    for(uint256 i=0;i<lpSize;i++){
                        user = lpUser[i];
                        totalAmount = totalAmount.add(IERC20(_pair).balanceOf(user));
                    }
                }
                
                uint256 rate;
                if(lpSize >25){
                    for(uint256 i=0;i<25;i++){
                        user = lpUser[startIndex+i];
                        if(IERC20(_pair).balanceOf(user) >= dividendAmount){
                            rate = IERC20(_pair).balanceOf(user).mul(10000).div(totalAmount);
                            if(rate>0){
                                uint256 amount = thisAmount.mul(rate).div(10000);
                                _balances[address(this)] = _balances[address(this)].sub(amount);
                                _balances[user] = _balances[user].add(amount);
                                emit Transfer(address(this), user, amount);
                            }
                        }
                    }
                }else{
                    for(uint256 i=0;i<lpSize;i++){
                        user = lpUser[i];
                        if( IERC20(_pair).balanceOf(user) >= dividendAmount){
                            rate = IERC20(_pair).balanceOf(user).mul(10000).div(totalAmount);
                            if(rate>0){
                                uint256 amount = thisAmount.mul(rate).div(10000);
                                _balances[address(this)] = _balances[address(this)].sub(amount);
                                _balances[user] = _balances[user].add(amount);
                                emit Transfer(address(this), user, amount);
                            }
                        }
                    }
                }
            }
        }
    }
    
    function getLPsize() public view returns (uint256) {
        return lpUser.length;
    }
}