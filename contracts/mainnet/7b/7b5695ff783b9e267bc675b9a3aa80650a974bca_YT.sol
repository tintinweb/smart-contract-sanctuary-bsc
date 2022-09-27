/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

pragma solidity ^0.8.1;
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
interface ISwapPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
    function skim(address to) external;
    function sync() external;
}
interface ISwapFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}
interface ISwapRouter {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
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
contract Ownable {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() {
        _transferOwnership(_msgSender());
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
contract ERC20 is IERC20 {
    string private _name;
    string private _symbol;
    mapping(address => uint256) private _tBalances;
    mapping(address => uint256) private _rBalances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isBonusExempt;
    address[] private _bonusExempt;
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _totalCirculation;
    uint256 private _minSupply;
    uint256 private _maxSupply = ~uint256(0);
    uint256 private _rebaseRate = 3 * 10**(decimals() - 4);
    uint256 private _rebaseLastTime = block.timestamp;
    uint256 private _rebaseEndTime;
    uint256 private _rebaseStepTime = 2 minutes;
    uint256 private _currentRate;
    uint256 private _bounsMinHold;
    uint256 private _rTotalBouns;
    uint256 private _tTotalBouns;
    uint256 private constant MAX = ~uint256(0);
    bool private _autoRebase = true;
    modifier transactional() {
        _rebase();
        _currentRate = _getRate();
        _;
        _currentRate = 0;
    }
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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
        return _tTotal;
    }
    function totalCirculation() public view virtual returns (uint256) {
        return _totalCirculation;
    }
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        if (isBonusExempt[account] || _tBalances[account] > 0)
            return _tBalances[account];
        uint256 currentRate = _getRate();
        return _rBalances[account] / currentRate;
    }
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = msg.sender;
        _transfer(owner, to, amount);
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
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = msg.sender;
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = msg.sender;
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    function _transfer(
        address from,
        address to,
        uint256 tAmount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount * currentRate;
        require(
            _rBalances[from] >= rAmount || _tBalances[from] >= tAmount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balanceSub(from, tAmount, rAmount);
        }
        _balanceAdd(to, tAmount, rAmount);
        emit Transfer(from, to, tAmount);
    }
    function _burn(address account, uint256 tAmount)
        internal
        virtual
        returns (bool)
    {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount * currentRate;
        require(
            _rBalances[account] >= rAmount || _tBalances[account] >= tAmount,
            "ERC20: burn amount exceeds balance"
        );
        unchecked {
            _balanceSub(account, tAmount, rAmount);
        }
        _balanceAdd(address(0), tAmount, rAmount);
        emit Transfer(account, address(0), tAmount);
        return true;
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function getInfo(address account)
        public
        view
        returns (uint256 tBalance, uint256 rBalance)
    {
        return (_tBalances[account], _rBalances[account]);
    }
    function getParam()
        public
        view
        returns (
            uint256 tTotal,
            uint256 rTotal,
            uint256 tBouns,
            uint256 rBouns
        )
    {
        return (_tTotal, _rTotal, _tTotalBouns, _rTotalBouns);
    }
    function minSupply() public view returns (uint256) {
        return _minSupply;
    }
    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }
    function rebaseRate() public view returns (uint256) {
        return _rebaseRate;
    }
    function autoRebase() public view returns (bool) {
        return _autoRebase;
    }
    function _setMinSupply(uint256 amount) internal {
        _minSupply = amount;
    }
    function _setMaxSupply(uint256 amount) internal {
        _maxSupply = amount;
    }
    function _setRebaseRate(uint256 rate) internal {
        _rebaseRate = rate;
    }
    function _setAutoRebase(bool value) internal {
        _autoRebase = value;
    }
    function _setRebaseEndTime(uint256 time) internal {
        _rebaseEndTime = time;
    }
    function _setRebaseStepTime(uint256 time) internal {
        _rebaseStepTime = time;
    }
    function _setBounsMinHold(uint256 minHold) internal {
        _bounsMinHold = minHold;
    }
    function _addBounsExempt(address account) internal {
        require(!isBonusExempt[account], "Account is already exempt");
        if (_rBalances[account] > 0) {
            uint256 currentRate = _getRate();
            _tBalances[account] = _rBalances[account] / currentRate;
            _totalBounsAdd(_tBalances[account], _rBalances[account]);
            _rBalances[account] = 0;
        }
        isBonusExempt[account] = true;
        _bonusExempt.push(account);
    }
    function _removeBounsExempt(address account) internal {
        require(isBonusExempt[account], "Account is already remove");
        for (uint256 i = 0; i < _bonusExempt.length; i++) {
            if (_bonusExempt[i] == account) {
                _bonusExempt[i] = _bonusExempt[_bonusExempt.length - 1];
                uint256 currentRate = _getRate();
                _rBalances[account] = _tBalances[account] * currentRate;
                _totalBounsAdd(_tBalances[account], _rBalances[account]);
                _tBalances[account] = 0;
                isBonusExempt[account] = false;
                _bonusExempt.pop();
                break;
            }
        }
    }
    function _init(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _tTotal = amount;
        _rTotal = (MAX - (MAX % (_tTotal * 1_0000_0000)));
        _totalCirculation = _tTotal;
        _balanceAdd(account, _tTotal, _rTotal);
        emit Transfer(address(0), account, amount);
    }
    function _rebase() private {
        if (
            _autoRebase &&
            (_tTotal < _maxSupply) &&
            (_rebaseEndTime == 0 || block.timestamp <= _rebaseEndTime) &&
            block.timestamp >= (_rebaseLastTime + _rebaseStepTime)
        ) {
            uint256 deltaTime = block.timestamp - _rebaseLastTime;
            uint256 times = deltaTime / _rebaseStepTime;
            for (uint256 i = 0; i < times; i++) {
                _tTotal += _rebaseRate;
            }
            _rebaseLastTime = _rebaseLastTime + (times * _rebaseStepTime);
            emit Rebase(times, _tTotal);
        }
    }
    function _balanceAdd(
        address account,
        uint256 tAmount,
        uint256 rAmount
    ) private {
        if (isBonusExempt[account]) {
            _tBalances[account] += tAmount;
            _totalBounsAdd(tAmount, rAmount);
            return;
        }
        if (_rBalances[account] > 0) {
            _rBalances[account] += rAmount;
        } else {
            if (_tBalances[account] + tAmount < _bounsMinHold) {
                _tBalances[account] += tAmount;
                _totalBounsAdd(tAmount, rAmount);
            } else {
                uint256 currentRate = _getRate();
                uint256 rbalance = _tBalances[account] * currentRate;
                _totalBounsSub(_tBalances[account], rbalance);
                _tBalances[account] = 0;
                _rBalances[account] += rbalance + rAmount;
            }
        }
    }
    function _balanceSub(
        address account,
        uint256 tAmount,
        uint256 rAmount
    ) private {
        if (isBonusExempt[account]) {
            _tBalances[account] -= tAmount;
            _totalBounsSub(tAmount, rAmount);
            return;
        }
        if (_tBalances[account] > 0) {
            _tBalances[account] -= tAmount;
            _totalBounsSub(tAmount, rAmount);
        } else {
            uint256 currentRate = _getRate();
            _rBalances[account] -= rAmount;
            if (_rBalances[account] / currentRate < _bounsMinHold) {
                _tBalances[account] = _rBalances[account] / currentRate;
                _totalBounsAdd(_tBalances[account], _rBalances[account]);
                _rBalances[account] = 0;
            }
        }
    }
    function _totalBounsAdd(uint256 tAmount, uint256 rAmount) private {
        _tTotalBouns += tAmount;
        _rTotalBouns += rAmount;
    }
    function _totalBounsSub(uint256 tAmount, uint256 rAmount) private {
        if (_tTotalBouns > tAmount) _tTotalBouns -= tAmount;
        else _tTotalBouns = 0;
        if (_rTotalBouns > rAmount) _rTotalBouns -= rAmount;
        else _rTotalBouns = 0;
    }
    function _getRate() private view returns (uint256) {
        if (_currentRate > 0) return _currentRate;
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }
    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal - _rTotalBouns;
        uint256 tSupply = _tTotal - _tTotalBouns;
        if (tSupply == 0 || rSupply == 0) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    event Rebase(uint256 times, uint256 tTotal);
}
contract Distributor {
    constructor(address token) {
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}
contract YT is ERC20, Ownable {
    using Address for address;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isSwapPair;
    mapping(address => address) public refers;
    uint256 public autoSwapMin;
    address private _market;
    address private _usdtAddress;
    address private _swapPair;
    ISwapRouter private _swapRouter;
    Distributor internal _distributor;
    bool _inSwapAndLiquify;
    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }
    function withdrawToken(IERC20 token, uint256 amount) public onlyOwner {
        token.transfer(msg.sender, amount);
    }
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }
    constructor() ERC20("YT", "YT") {
        _market = 0x6951Cc026D2A0bc3A95fCa4559c52928759be49E;
        address _adminAddress = 0x6951Cc026D2A0bc3A95fCa4559c52928759be49E;
        _usdtAddress = 0x0D8Ce2A99Bb6e3B7Db580eD848240e4a0F9aE153;
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        _swapRouter = ISwapRouter(routerAddress);
        _swapPair = ISwapFactory(_swapRouter.factory()).createPair(
            address(this),
            _usdtAddress
        );
        isSwapPair[_swapPair] = true;
        isFeeExempt[owner()] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[_adminAddress] = true;
        addBounsExempt(_swapPair);
        addBounsExempt(address(0));
        addBounsExempt(address(this));
        addBounsExempt(0x000000000000000000000000000000000000dEaD);
        autoSwapMin = 1 * 10**(decimals() - 4);
        _distributor = new Distributor(_usdtAddress);
        _setBounsMinHold(2 * 10**decimals());
        _setMaxSupply(1_0000 * 10**decimals());
        _setRebaseRate(23148148148148148);
        _setRebaseStepTime(2 minutes);
        _init(_adminAddress, 1000 * 10**decimals());
    }
    function setIsFeeExempt(address account, bool newValue) public onlyOwner {
        isFeeExempt[account] = newValue;
    }
    function setAutoSwapMin(uint256 amount) public onlyOwner {
        autoSwapMin = amount;
    }
    function addBounsExempt(address account) public onlyOwner {
        _addBounsExempt(account);
    }
    function removeBounsExempt(address account) public onlyOwner {
        _removeBounsExempt(account);
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override transactional {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if (_inSwapAndLiquify) {
            super._transfer(sender, recipient, amount);
        } else if (isSwapPair[sender]) {
            if (isFeeExempt[recipient]) {
                super._transfer(sender, recipient, amount);
            } else {
                uint256 every = amount / 1000;
                uint256 amountFainel = amount - every * 60;
                super._transfer(sender, address(this), every * 45);
                uint256 amountBurn;
                address refer = refers[recipient];
                if (refer == address(0)) {
                    amountBurn += every * 15;
                } else {
                    super._transfer(sender, refer, every * 5);
                    refer = refers[refer];
                    if (refer == address(0)) {
                        amountBurn += every * 10;
                    } else {
                        super._transfer(sender, refer, every * 5);
                        refer = refers[refer];
                        if (refer == address(0)) {
                            amountBurn += every * 5;
                        } else {
                            super._transfer(sender, refer, every * 5);
                        }
                    }
                }
                if (amountBurn > 0) super._burn(sender, amountBurn);
                super._transfer(sender, recipient, amountFainel);
            }
            _addLpProvider(recipient);
        } else if (isSwapPair[recipient]) {
            if (balanceOf(address(this)) > autoSwapMin && !_inSwapAndLiquify) {
                _swapAndLiquify();
            }
            if (isFeeExempt[sender]) {
                super._transfer(sender, recipient, amount);
            } else {
                uint256 every = amount / 1000;
                uint256 amountFainel = amount - every * 70;
                super._transfer(sender, address(this), every * 45);
                uint256 amountBurn = every;
                address refer = refers[sender];
                if (refer == address(0)) {
                    amountBurn += every * 15;
                } else {
                    super._transfer(sender, refer, every * 5);
                    refer = refers[refer];
                    if (refer == address(0)) {
                        amountBurn += every * 10;
                    } else {
                        super._transfer(sender, refer, every * 5);
                        refer = refers[refer];
                        if (refer == address(0)) {
                            amountBurn += every * 5;
                        } else {
                            super._transfer(sender, refer, every * 5);
                        }
                    }
                }
                if (amountBurn > 0) super._burn(sender, amountBurn);
                super._transfer(sender, recipient, amountFainel);
            }
            _addLpProvider(sender);
        } else {
            super._transfer(sender, recipient, amount);
            if (
                refers[recipient] == address(0) &&
                sender != recipient &&
                refers[sender] != recipient
            ) {
                refers[recipient] = sender;
            }
        }
        if (sender != address(this)) {
            processLP(500000);
        }
    }
    function swapAndLiquity() public {
        if (balanceOf(address(this)) > autoSwapMin) {
            _swapAndLiquify();
        }
    }
    function _swapAndLiquify() private lockTheSwap returns (bool) {
        uint256 amount = balanceOf(address(this));
        address token0 = ISwapPair(_swapPair).token0();
        (uint256 reserve0, uint256 reserve1, ) = ISwapPair(_swapPair)
            .getReserves();
        uint256 tokenPool = reserve0;
        if (token0 != address(this)) tokenPool = reserve1;
        if (amount > tokenPool / 100) {
            amount = tokenPool / 100;
        }
        _swapTokensForUSDT(amount);
        IERC20 USDT = IERC20(_usdtAddress);
        uint256 bal = USDT.balanceOf(address(_distributor));
        uint256 every = bal / 9;
        USDT.transferFrom(address(_distributor), address(this), every * 4);
        USDT.transferFrom(address(_distributor), _market, bal - every * 4);
        return true;
    }
    function _swapTokensForUSDT(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdtAddress;
        super._approve(address(this), address(_swapRouter), tokenAmount * 2);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_distributor),
            block.timestamp
        );
        emit SwapTokensForTokens(tokenAmount, path);
    }
    event SwapTokensForTokens(uint256 amountIn, address[] path);
    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    uint256 public lpRewardIndex;
    uint256 public lpRewardBlock;
    uint256 public lpRewardShare = 5 * 1e18;
    function setLpRewardShare(uint256 amount) public onlyOwner {
        lpRewardShare = amount;
    }
    function _addLpProvider(address account) private {
        if (0 == lpProviderIndex[account]) {
            if (0 == lpProviders.length || lpProviders[0] != account) {
                lpProviderIndex[account] = lpProviders.length;
                lpProviders.push(account);
            }
        }
    }
    function processLP(uint256 gas) private {
        uint256 totalPair = IERC20(_swapPair).totalSupply();
        if (0 == totalPair) {
            return;
        }
        IERC20 USDT = IERC20(_usdtAddress);
        uint256 usdtBalance = USDT.balanceOf(address(this));
        if (usdtBalance < lpRewardShare) {
            return;
        }
        address shareHolder;
        uint256 pairBalance;
        uint256 amount;
        uint256 shareholderCount = lpProviders.length;
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        while (gasUsed < gas && iterations < shareholderCount) {
            if (lpRewardIndex >= shareholderCount) {
                lpRewardIndex = 0;
            }
            shareHolder = lpProviders[lpRewardIndex];
            pairBalance = IERC20(_swapPair).balanceOf(shareHolder);
            if (pairBalance > 0 && !shareHolder.isContract()) {
                amount = (lpRewardShare * pairBalance) / totalPair;
                if (usdtBalance < amount) {
                    break;
                }
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
                    usdtBalance -= amount;
                }
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            lpRewardIndex++;
            iterations++;
        }
        lpRewardBlock = block.number;
    }
}