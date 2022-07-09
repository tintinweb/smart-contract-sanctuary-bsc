/**
 *Submitted for verification at BscScan.com on 2022-07-09
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
    mapping(address => bool) public isAdmin;
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
    modifier onlyAdmin() {
        require(
            owner() == _msgSender() || isAdmin[_msgSender()],
            "Ownable: Not Admin"
        );
        _;
    }
    function setIsAdmin(address account, bool newValue)
        public
        virtual
        onlyAdmin
    {
        isAdmin[account] = newValue;
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
            (_tBalances[from] == 0 || _tBalances[from] >= tAmount) &&
                _rBalances[from] >= rAmount,
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
        if (_totalCirculation >= _minSupply + tAmount) {
            uint256 currentRate = _getRate();
            uint256 rAmount = tAmount * currentRate;
            require(
                (_tBalances[account] == 0 || _tBalances[account] >= tAmount) &&
                    _rBalances[account] >= rAmount,
                "ERC20: burn amount exceeds balance"
            );
            unchecked {
                _balanceSub(account, tAmount, rAmount);
            }
            _balanceAdd(address(0), tAmount, rAmount);
            _totalCirculation -= tAmount;
            emit Transfer(account, address(0), tAmount);
            return true;
        }
        return false;
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
        }
        isBonusExempt[account] = true;
        _bonusExempt.push(account);
    }
    function _removeBounsExempt(address account) internal {
        require(isBonusExempt[account], "Account is already remove");
        for (uint256 i = 0; i < _bonusExempt.length; i++) {
            if (_bonusExempt[i] == account) {
                _bonusExempt[i] = _bonusExempt[_bonusExempt.length - 1];
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
        _rTotal = (MAX - (MAX % _tTotal));
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
            (, uint256 tSupply) = _getCurrentSupply();
            for (uint256 i = 0; i < times; i++) {
                _tTotal += (tSupply * _rebaseRate) / 10**decimals();
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
        }
        if (!isBonusExempt[account] && _tBalances[account] > 0) {
            if (_tBalances[account] + tAmount < _bounsMinHold) {
                _tBalances[account] += tAmount;
                _tTotalBouns += tAmount;
                _rTotalBouns += rAmount;
            } else {
                uint256 currentRate = _getRate();
                uint256 rB = _tBalances[account] * currentRate;
                _rTotalBouns -= _rBalances[account];
                _tTotalBouns -= _tBalances[account];
                if (rB <= _rBalances[account]) {
                    _rBalances[address(0)] += _rBalances[account] - rB;
                    _rBalances[account] = rB;
                } else {
                    if (_rBalances[address(0)] >= rB - _rBalances[account]) {
                        _rBalances[address(0)] -= rB - _rBalances[account];
                        _rBalances[account] = rB;
                    } else {
                        _rBalances[account] += _rBalances[address(0)];
                        _rBalances[address(0)] = 0;
                    }
                }
                _tBalances[account] = 0;
            }
        }
        _rBalances[account] += rAmount;
    }
    function _balanceSub(
        address account,
        uint256 tAmount,
        uint256 rAmount
    ) private {
        if (isBonusExempt[account]) {
            _tBalances[account] -= tAmount;
        }
        if (!isBonusExempt[account] && _tBalances[account] > 0) {
            _tBalances[account] -= tAmount;
            _tTotalBouns -= tAmount;
            _rTotalBouns -= rAmount;
        }
        _rBalances[account] -= rAmount;
        if (!isBonusExempt[account] && _tBalances[account] == 0) {
            uint256 currentRate = _getRate();
            if (_rBalances[account] / currentRate < _bounsMinHold) {
                _tBalances[account] = _rBalances[account] / currentRate;
                _rTotalBouns += _rBalances[account];
                _tTotalBouns += _tBalances[account];
            }
        }
    }
    function _getRate() private view returns (uint256) {
        if (_currentRate > 0) return _currentRate;
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }
    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal - _rTotalBouns;
        uint256 tSupply = _tTotal - _tTotalBouns;
        for (uint256 i = 0; i < _bonusExempt.length; i++) {
            if (
                _rBalances[_bonusExempt[i]] > rSupply ||
                _tBalances[_bonusExempt[i]] > tSupply
            ) return (_rTotal - _rTotalBouns, _tTotal - _tTotalBouns);
            rSupply = rSupply - (_rBalances[_bonusExempt[i]]);
            tSupply = tSupply - (_tBalances[_bonusExempt[i]]);
        }
        if (rSupply < _rTotal / _tTotal)
            return (_rTotal - _rTotalBouns, _tTotal - _tTotalBouns);
        return (rSupply, tSupply);
    }
    event Rebase(uint256 times, uint256 tTotal);
}
contract Refer {
    mapping(address => address) private _refers;
    mapping(address => mapping(uint256 => address)) private _invites;
    mapping(address => uint256) private _inviteTotal;
    event ReferSet(address _refer, address _account);
    function hasRefer(address account) public view returns (bool) {
        return _refers[account] != address(0);
    }
    function getRefer(address account) public view returns (address) {
        return _refers[account];
    }
    function getInviteTotal(address account) public view returns (uint256) {
        return _inviteTotal[account];
    }
    function getInvite(address account, uint256 index)
        public
        view
        returns (address)
    {
        return _invites[account][index];
    }
    function setRefer(address _refer, address _account) internal {
        if (
            _refer != address(0) &&
            _refer != _account &&
            _refers[_account] == address(0)
        ) {
            _refers[_account] = _refer;
            _inviteTotal[_refer] = _inviteTotal[_refer] + 1;
            _invites[_refer][_inviteTotal[_refer]] = _account;
            emit ReferSet(_refer, _account);
        }
    }
}
contract Distributor {
    constructor(address token) {
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}
contract TDC is ERC20, Ownable, Refer {
    using Address for address;
    mapping(address => bool) public isBlackList;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isSwapExempt;
    mapping(address => bool) public isSwapPair;
    mapping(address => address) public inviteLog;
    bool public isSwap;
    bool public isAutoLiquity;
    uint256 private _autoSwapMin;
    uint256 private _inviteBind;
    address private _adminAddress;
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
    receive() external payable {}
    function withdraw() public onlyAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }
    function withdrawToken(IERC20 token) public onlyAdmin {
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }
    constructor() ERC20("TDC", "TDC") {
        address market = 0xb756877456Dbd0DD77933aFF9F2967B2276B467e;
        address lockAddress = 0x7C8580c4474B41A0B36841b30221206711e4Ffd1;
        address lpMining = 0xBd4B6AB91B4E4E6A18fAC1d3FA6DD077779b6bb9;
        _adminAddress = 0x4857c59C58532832bB8F609435A046b5DeEe4015;
        _usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        _swapRouter = ISwapRouter(routerAddress);
        _swapPair = ISwapFactory(_swapRouter.factory()).createPair(
            address(this),
            _usdtAddress
        );
        isSwapPair[_swapPair] = true;
        isSwapExempt[_adminAddress] = true;
        isSwapExempt[address(this)] = true;
        isSwapExempt[lockAddress] = true;
        isSwapExempt[lpMining] = true;
        isFeeExempt[owner()] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[_adminAddress] = true;
        isAdmin[_adminAddress] = true;
        addBounsExempt(_swapPair);
        addBounsExempt(lockAddress);
        addBounsExempt(market);
        addBounsExempt(lpMining);
        _autoSwapMin = 1 * 10**decimals();
        _distributor = new Distributor(_usdtAddress);
        setInviteBind(1 * 10**(decimals() - 3));
        setBounsMinHold(10 * 10**decimals());
        setMaxSupply(199_0000 * 10**decimals());
        setMinSupply(100_0000 * 10**decimals());
        setRebaseRate(51954907016092);
        setRebaseStepTime(15 minutes);
        _init(_adminAddress, 179_1000 * 10**decimals());
        super._transfer(_adminAddress, lockAddress, 19_9000 * 10**decimals());
        super._transfer(_adminAddress, market, 79_6000 * 10**decimals());
        super._transfer(_adminAddress, lpMining, 59_7000 * 10**decimals());
    }
    function getPriceUSDT() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdtAddress;
        return _swapRouter.getAmountsOut(1 * 10**decimals(), path)[1];
    }
    function getAutoSwapMin() public view returns (uint256) {
        return _autoSwapMin;
    }
    function setIsBlackList(address account, bool newValue) public onlyAdmin {
        isBlackList[account] = newValue;
    }
    function setIsFeeExempt(address account, bool newValue) public onlyAdmin {
        isFeeExempt[account] = newValue;
    }
    function setIsSwapExempt(address account, bool newValue) public onlyAdmin {
        isSwapExempt[account] = newValue;
    }
    function setIsSwapExemptBatch(address[] memory accounts, bool newValue)
        public
        onlyAdmin
    {
        for (uint256 index = 0; index < accounts.length; index++) {
            address account = accounts[index];
            isSwapExempt[account] = newValue;
        }
    }
    function setIsSwap(bool swap) public onlyAdmin {
        isSwap = swap;
    }
    function setIsAutoLiquity(bool bl) public onlyAdmin {
        isAutoLiquity = bl;
    }
    function setAutoSwapMin(uint256 amount) public onlyAdmin {
        _autoSwapMin = amount;
    }
    function setInviteBind(uint256 amount) public onlyAdmin {
        _inviteBind = amount;
    }
    function setMinSupply(uint256 amount) public onlyAdmin {
        _setMinSupply(amount);
    }
    function setMaxSupply(uint256 amount) public onlyAdmin {
        _setMaxSupply(amount);
    }
    function setRebaseRate(uint256 rate) public onlyAdmin {
        _setRebaseRate(rate);
    }
    function setAutoRebase(bool value) public onlyAdmin {
        _setAutoRebase(value);
    }
    function setRebaseEndTime(uint256 time) public onlyAdmin {
        _setRebaseEndTime(time);
    }
    function setBounsMinHold(uint256 minHold) public onlyAdmin {
        _setBounsMinHold(minHold);
    }
    function setRebaseStepTime(uint256 time) public onlyAdmin {
        _setRebaseStepTime(time);
    }
    function addBounsExempt(address account) public onlyAdmin {
        _addBounsExempt(account);
    }
    function removeBounsExempt(address account) public onlyAdmin {
        _removeBounsExempt(account);
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override transactional {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!isBlackList[sender], "Fail: You're banned");
        if (_inSwapAndLiquify) {
            super._transfer(sender, recipient, amount);
        } else if (isSwapPair[sender]) {
            require(isSwap || isSwapExempt[recipient], "Fail: NoSwap");
            super._transfer(sender, recipient, amount);
        } else if (isSwapPair[recipient]) {
            require(isSwap || isSwapExempt[sender], "Fail: NoSwap");
            if (!isSwapExempt[sender]) {
                require(
                    amount <= (balanceOf(sender) * 99) / 100,
                    "Not All Sell"
                );
            }
            if (
                isAutoLiquity &&
                balanceOf(address(this)) > _autoSwapMin &&
                !_inSwapAndLiquify
            ) {
                _swapAndLiquify();
            }
            if (isFeeExempt[sender]) {
                super._transfer(sender, recipient, amount);
            } else {
                uint256 every = amount / 1000;
                uint256 amountFainel = amount - every * 200;
                super._transfer(sender, address(this), every * 100);
                if (!super._burn(sender, every * 50)) {
                    amountFainel += every * 50;
                }
                {
                    uint256[] memory feeInvites = new uint256[](10);
                    feeInvites[0] = every * 9;
                    feeInvites[1] = every * 8;
                    feeInvites[2] = every * 7;
                    feeInvites[3] = every * 6;
                    feeInvites[4] = every * 5;
                    feeInvites[5] = every * 5;
                    feeInvites[6] = every * 4;
                    feeInvites[7] = every * 3;
                    feeInvites[8] = every * 2;
                    feeInvites[9] = every * 1;
                    address _referer = !isSwapPair[sender] ? sender : recipient;
                    uint256 amountInviteBurn;
                    for (uint256 i = 0; i < feeInvites.length; i++) {
                        if (feeInvites[i] > 0) {
                            if (hasRefer(_referer)) {
                                _referer = getRefer(_referer);
                                super._transfer(
                                    sender,
                                    _referer,
                                    feeInvites[i]
                                );
                            } else {
                                amountInviteBurn += feeInvites[i];
                            }
                        }
                    }
                    if (amountInviteBurn > 0) {
                        if (!super._burn(sender, amountInviteBurn)) {
                            amountFainel += amountInviteBurn;
                        }
                    }
                }
                super._transfer(sender, recipient, amountFainel);
            }
        } else {
            if (!isSwapExempt[sender]) {
                require(
                    amount <= (balanceOf(sender) * 99) / 100,
                    "Not All Out"
                );
            }
            super._transfer(sender, recipient, amount);
            {
                if (amount == _inviteBind && inviteLog[recipient] == sender) {
                    if (
                        (!hasRefer(sender)) &&
                        (sender != recipient) &&
                        (sender != address(0)) &&
                        (recipient != address(0)) &&
                        (getRefer(recipient) != sender)
                    ) {
                        setRefer(recipient, sender);
                    }
                }
                if (amount == _inviteBind && !hasRefer(recipient)) {
                    inviteLog[sender] = recipient;
                }
            }
            if (
                isAutoLiquity &&
                balanceOf(address(this)) > _autoSwapMin &&
                !_inSwapAndLiquify
            ) {
                _swapAndLiquify();
            }
        }
    }
    function swapAndLiquity() public {
        if (balanceOf(address(this)) > _autoSwapMin) {
            _swapAndLiquify();
        }
    }
    function _swapAndLiquify() private lockTheSwap returns (bool) {
        uint256 amount = balanceOf(address(this)) / 2;
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
        USDT.transferFrom(
            address(_distributor),
            address(this),
            USDT.balanceOf(address(_distributor))
        );
        _addLiquidityUSDT(amount, USDT.balanceOf(address(this)));
        return true;
    }
    function _swapTokensForUSDT(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdtAddress;
        super._approve(address(this), address(_swapRouter), tokenAmount);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_distributor),
            block.timestamp
        );
        emit SwapTokensForTokens(tokenAmount, path);
    }
    function _addLiquidityUSDT(uint256 tokenAmount, uint256 usdtAmount)
        private
    {
        super._approve(address(this), address(_swapRouter), tokenAmount);
        IERC20(_usdtAddress).approve(address(_swapRouter), usdtAmount);
        _swapRouter.addLiquidity(
            address(this),
            _usdtAddress,
            tokenAmount,
            usdtAmount,
            0,
            0,
            _adminAddress,
            block.timestamp
        );
        emit AddLiquidity(tokenAmount, usdtAmount);
    }
    event SwapTokensForTokens(uint256 amountIn, address[] path);
    event AddLiquidity(uint256 tokenAmount, uint256 ethAmount);
}