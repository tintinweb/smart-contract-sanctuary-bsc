/**
 *Submitted for verification at BscScan.com on 2022-07-14
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
    uint256 private _rebaseLastTime;
    uint256 private _rebaseEndTime;
    uint256 private _rebaseStepTime = 15 minutes;
    uint256 private _currentRate;
    uint256 private _bounsMaxHold;
    uint256 private _rTotalBouns;
    uint256 private _tTotalBouns;
    uint256 private _rebaseRate = 30000 * 10**10;
    uint256 private constant MAX = ~uint256(0);
    bool private _autoRebase = true;
    modifier transactional() {
        _currentRate = _getRate();
        _;
        _currentRate = 0;
    }
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _rebaseLastTime = block.timestamp;
        _bounsMaxHold = 200 * 10**decimals();
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
        if (isBonusExempt[account]) return _tBalances[account];
        uint256 currentRate = _getRate();
        if (_tBalances[account] <= _bounsMaxHold)
            return
                _tBalances[account] > _rBalances[account] / currentRate
                    ? _tBalances[account]
                    : _rBalances[account] / currentRate;
        return
            (_tBalances[account] - _bounsMaxHold) +
            (_rBalances[account] / currentRate);
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
        if (
            _autoRebase &&
            (_tTotal < _maxSupply) &&
            (_rebaseEndTime == 0 || block.timestamp <= _rebaseEndTime) &&
            block.timestamp >= (_rebaseLastTime + _rebaseStepTime)
        ) {
            _rebase();
        }
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount * currentRate;
        require(
            _tBalances[from] >= tAmount,
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
                _tBalances[account] >= tAmount,
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
    function _setBounsMaxHold(uint256 maxHold) internal {
        _bounsMaxHold = maxHold;
    }
    function _addBounsExempt(address account) internal {
        require(!isBonusExempt[account], "Account is already exempt");
        if (_rBalances[account] > 0) {
            _rTotalBouns -= _rBalances[account];
            _rBalances[account] = 0;
            if (_tBalances[account] >= _bounsMaxHold) {
                _tTotalBouns -= _bounsMaxHold;
            } else {
                _tTotalBouns -= _tBalances[account];
            }
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
                if (_tBalances[account] >= _bounsMaxHold) {
                    _tTotalBouns += _bounsMaxHold;
                    _rTotalBouns += _bounsMaxHold * currentRate;
                    _rBalances[account] = _bounsMaxHold * currentRate;
                } else {
                    _tTotalBouns += _tBalances[account];
                    _rTotalBouns += _tBalances[account] * currentRate;
                    _rBalances[account] = _tBalances[account] * currentRate;
                }
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
        _tBalances[account] = _tTotal;
        uint256 currentRate = _rTotal / _tTotal;
        if (_tBalances[account] >= _bounsMaxHold) {
            _tTotalBouns = _bounsMaxHold;
            _rTotalBouns = _bounsMaxHold * currentRate;
            _rBalances[account] = _rTotalBouns;
        } else {
            _tTotalBouns = _tBalances[account];
            _rTotalBouns = _tBalances[account] * currentRate;
            _rBalances[account] = _rTotalBouns;
        }
        emit Transfer(address(0), account, amount);
    }
    function _rebase() private {
        uint256 deltaTime = block.timestamp - _rebaseLastTime;
        uint256 times = deltaTime / _rebaseStepTime;
        (, uint256 tSupply) = _getCurrentSupply();
        for (uint256 i = 0; i < times; i++) {
            uint256 x = (tSupply * _rebaseRate) / 10**decimals();
            _tTotal += x;
            _tTotalBouns += x;
        }
        _rebaseLastTime = _rebaseLastTime + (times * _rebaseStepTime);
        emit Rebase(times, _tTotal);
    }
    function _balanceAdd(
        address account,
        uint256 tAmount,
        uint256 rAmount
    ) private {
        uint256 fromBalance = _tBalances[account];
        _tBalances[account] += tAmount;
        if (!isBonusExempt[account]) {
            uint256 currentRate = _getRate();
            if (fromBalance >= _bounsMaxHold) {
                if (_rBalances[account] > _bounsMaxHold * currentRate) {
                    uint256 x = _rBalances[account] -
                        (_bounsMaxHold * currentRate);
                    _rBalances[account] -= x;
                    _rTotalBouns -= x;
                    _tTotalBouns -= x / currentRate;
                    _tBalances[account] += x / currentRate;
                }
            } else if (_tBalances[account] > _bounsMaxHold) {
                if (_bounsMaxHold * currentRate > _rBalances[account]) {
                    uint256 x = (_bounsMaxHold * currentRate) -
                        _rBalances[account];
                    _rBalances[account] += x;
                    _rTotalBouns += x;
                }
                if (_bounsMaxHold > fromBalance) {
                    _tTotalBouns += _bounsMaxHold - fromBalance;
                }
            } else {
                _rBalances[account] += rAmount;
                _rTotalBouns += rAmount;
                _tTotalBouns += tAmount;
            }
        }
    }
    function _balanceSub(
        address account,
        uint256 tAmount,
        uint256 rAmount
    ) private {
        uint256 fromBalance = _tBalances[account];
        _tBalances[account] -= tAmount;
        if (!isBonusExempt[account]) {
            uint256 currentRate = _getRate();
            if (_tBalances[account] >= _bounsMaxHold) {
                if (_rBalances[account] > _bounsMaxHold * currentRate) {
                    uint256 x = _rBalances[account] -
                        (_bounsMaxHold * currentRate);
                    _rBalances[account] -= x;
                    _rTotalBouns -= x;
                    _tTotalBouns -= x / currentRate;
                    _tBalances[account] += x / currentRate;
                }
            } else if (fromBalance >= _bounsMaxHold) {
                if (_rBalances[account] > _tBalances[account] * currentRate) {
                    uint256 x = _rBalances[account] -
                        (_tBalances[account] * currentRate);
                    _rBalances[account] -= x;
                    _rTotalBouns -= x;
                }
                if (_bounsMaxHold > _tBalances[account]) {
                    _tTotalBouns -= _bounsMaxHold - _tBalances[account];
                }
            } else {
                _rBalances[account] -= rAmount;
                _rTotalBouns -= rAmount;
                _tTotalBouns -= tAmount;
            }
        }
    }
    function _getRate() private view returns (uint256) {
        if (_currentRate > 0) return _currentRate;
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }
    function _getCurrentSupply() private view returns (uint256, uint256) {
        return (_rTotalBouns, _tTotalBouns);
    }
    event Rebase(uint256 times, uint256 tTotal);
}

contract OLOGY is ERC20, Ownable {
    using Address for address;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isSwapPair;
    address private _a;
    address private _b;
    address private _c;
    address private _adminAddress;
    address private _usdtAddress;
    address private _swapPair;
    ISwapRouter private _swapRouter;
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
    constructor() ERC20("OLOGY", "OLOGY") {
        _a = 0x972332f3B97a8bbbA2bBD77a936725AEF650b0fa;
        _b = 0xd6bfe13277ef006631b6B56022EF44253bA612B5;
        _c = 0x37fd01D28be1641546b5183E531bf26ACa6279ca;
        _adminAddress = 0x66C96317a2Ccf2Eed03bDc9D0B61587cDbB5E734;
        _usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
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
        isAdmin[owner()] = true;
        addBounsExempt(_swapPair);
        _setRebaseEndTime(block.timestamp + 3 * 365 * 24 * 3600);
        setMinSupply(1_0000 * 10**decimals());
        _init(_adminAddress, 1000_0000 * 10**decimals());
        transferOwnership(0xF8D58D5b687a019fC358bD131c1fA1cA197503bC);
    }
    function setIsFeeExempt(address account, bool newValue) public onlyAdmin {
        isFeeExempt[account] = newValue;
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
    function setRebaseEndTime(uint256 time) public onlyAdmin {
        _setRebaseEndTime(time);
    }
    function getPriceUSDT() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdtAddress;
        return _swapRouter.getAmountsOut(1 * 10**decimals(), path)[1];
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
        if (isSwapPair[sender]) {
            if (isFeeExempt[recipient]) {
                super._transfer(sender, recipient, amount);
            } else {
                uint256 every = amount / 100;
                uint256 amountFainel = amount - every * 10;
                super._transfer(sender, _c, every * 7);
                if (!super._burn(sender, every)) {
                    amountFainel = amountFainel + every;
                }
                super._transfer(sender, address(this), every * 2);
                super._transfer(sender, recipient, amountFainel);
            }
        } else if (isSwapPair[recipient]) {
            if (isFeeExempt[sender]) {
                super._transfer(sender, recipient, amount);
            } else {
                uint256 every = amount / 100;
                uint256 amountFainel = amount - every * 15;
                super._transfer(sender, _a, every * 5);
                super._transfer(sender, _b, every * 3);
                if (!super._burn(sender, every * 2)) {
                    amountFainel = amountFainel + every * 2;
                }
                super._transfer(sender, address(this), every * 5);
                super._transfer(sender, recipient, amountFainel);
            }
        } else {
            super._transfer(sender, recipient, amount);
            if (balanceOf(address(this)) > 0) {
                super._transfer(
                    address(this),
                    _swapPair,
                    balanceOf(address(this))
                );
                ISwapPair(_swapPair).sync();
            }
        }
    }
}