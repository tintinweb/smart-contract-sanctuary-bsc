/**
 *Submitted for verification at BscScan.com on 2022-05-30
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
library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
interface ISwapPair {
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
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
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);
    function mint(address to) external returns (uint256 liquidity);
    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
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
contract ERC20 is IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint256 private _totalCirculation;
    uint256 private _minTotalSupply;
    string private _name;
    string private _symbol;
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
        return _totalSupply;
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
        return _balances[account];
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
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _totalCirculation += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount)
        internal
        virtual
        returns (bool)
    {
        require(account != address(0), "ERC20: burn from the zero address");
        if (_totalCirculation > _minTotalSupply + amount) {
            _beforeTokenTransfer(account, address(0), amount);
            uint256 accountBalance = _balances[account];
            require(
                accountBalance >= amount,
                "ERC20: burn amount exceeds balance"
            );
            unchecked {
                _balances[account] = accountBalance - amount;
                _balances[address(0)] += amount;
            }
            _totalCirculation -= amount;
            emit Transfer(account, address(0), amount);
            _afterTokenTransfer(account, address(0), amount);
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function _setMinTotalSupply(uint256 amount) internal {
        _minTotalSupply = amount;
    }
}
contract Distributor {
    constructor(address token) {
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}
interface ITDAO {
    function getPriceUSDT() external view returns (uint256);
    function getSwapPair() external view returns (address);
    function syncSwapPair() external;
    function swapOrBurn() external;
}
contract TPS is ERC20, Ownable, Refer {
    using SafeMath for uint256;
    using Address for address;
    mapping(address => bool) public isBlackList;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isSwapExempt;
    mapping(address => bool) public isSwapPair;
    bool public isSwap;
    uint256 private _autoSwapMin;
    address private _marketAddress;
    address private _teamAddress;
    address private _lpAddress;
    address private _poolAddress;
    address private _usdtAddress;
    address private _swapPair;
    ISwapRouter private _swapRouter;
    Distributor private _distributor;
    ITDAO private _TDAO;
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
        super._burn(_msgSender(), amount);
    }
    constructor() ERC20("TPS", "TPS") {
        _lpAddress = 0xe42143af41E3BDd4dE8f150A9b9932632CCe96b4;
        address tDaoAddress = 0x37b0Ded4fDF8Cf7b40Ed0C8D4cA2166A02665A62;
        address guardianAddress = 0x7eEB9b266cC82377Ef085B73A43329C607B23efD;
        address holderAddress = 0x20E48C29A1963A0027F85c0c370c0F8E5CcE1cfD;
        address crowdAddress = 0x520965Ba0F20fdB9855Be04d84C557dFAe1f88Db;
        address miningAddress = 0xcb283D79Bf832229688f5BC8AA4FeCe9d39574b9;
        _marketAddress = 0x45352aDD31D96a2E9739d2A2394FbE7284fd638E;
        _teamAddress = 0x2CE435bE3CA16468A4258C57628e72A8407f8d4D;
        _poolAddress = 0xd39Bf0352f09355089f32Bea6d5416c83bDb98d1;
        _usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        _swapRouter = ISwapRouter(routerAddress);
        _swapPair = ISwapFactory(_swapRouter.factory()).createPair(
            address(this),
            _usdtAddress
        );
        isSwapPair[_swapPair] = true;
        isSwapExempt[_swapPair] = true;
        isSwapExempt[address(this)] = true;
        isSwapExempt[_poolAddress] = true;
        isFeeExempt[owner()] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[_lpAddress] = true;
        isFeeExempt[_poolAddress] = true;
        _TDAO = ITDAO(tDaoAddress);
        _distributor = new Distributor(_usdtAddress);
        _mint(guardianAddress, 630_0000 * 10**decimals());
        _mint(holderAddress, 315_0000 * 10**decimals());
        _mint(crowdAddress, 105_0000 * 10**decimals());
        _mint(miningAddress, 1050_0000 * 10**decimals());
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
    function getAutoSwapMin() public view returns (uint256) {
        return _autoSwapMin;
    }
    function setAutoSwapMin(uint256 amount) public onlyAdmin {
        _autoSwapMin = amount;
    }
    function getPriceUSDT() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdtAddress;
        return _swapRouter.getAmountsOut(1 * 10**decimals(), path)[1];
    }
    function setTDao(address add) public onlyAdmin {
        _TDAO = ITDAO(add);
    }
    function setLPAddress(address add) public onlyAdmin {
        _lpAddress = add;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!isBlackList[sender], "Fail: You're banned");
        if (
            balanceOf(address(this)) > _autoSwapMin &&
            !isSwapPair[sender] &&
            _poolAddress != sender &&
            !_inSwapAndLiquify
        ) {
            swapAndLiquify(balanceOf(address(this)));
        }
        if (
            _inSwapAndLiquify ||
            isFeeExempt[sender] ||
            isFeeExempt[recipient] ||
            recipient == address(0)
        ) {
            super._transfer(sender, recipient, amount);
        } else if (isSwapPair[sender] || isSwapPair[recipient]) {
            require(isSwap || isSwapExempt[sender], "Fail: NoSwap");
            uint256 every = amount.div(100);
            super._transfer(sender, recipient, amount.sub(every.mul(10)));
            super._transfer(sender, address(this), every.mul(2));
            super._transfer(sender, _teamAddress, every.mul(2));
            super._transfer(sender, _lpAddress, every.mul(2));
            super._transfer(sender, _marketAddress, every);
            address _refer = !isSwapPair[sender] ? sender : recipient;
            if (!hasRefer(_refer)) {
                super._burn(sender, every.mul(3));
            } else {
                _refer = getRefer(_refer);
                super._transfer(sender, _refer, every.mul(2));
                if (!hasRefer(_refer)) {
                    super._burn(sender, every);
                } else {
                    _refer = getRefer(_refer);
                    super._transfer(sender, _refer, every);
                }
            }
            _TDAO.swapOrBurn();
        } else {
            super._burn(sender, amount.mul(3).div(100));
            super._transfer(
                sender,
                recipient,
                amount.sub(amount.mul(3).div(100))
            );
            if (
                (!hasRefer(recipient)) &&
                (sender != recipient) &&
                (sender != address(0)) &&
                (recipient != address(0)) &&
                (amount > 0)
            ) {
                setRefer(sender, recipient);
            }
            _TDAO.swapOrBurn();
        }
    }
    function swapAndLiquify(uint256 amount) private lockTheSwap returns (bool) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdtAddress;
        IERC20(address(this)).approve(address(_swapRouter), amount);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(_distributor),
            block.timestamp
        );
        emit SwapTokensForTokens(amount, path);
        IERC20 usdt = IERC20(_usdtAddress);
        uint256 balance = usdt.balanceOf(address(_distributor));
        usdt.transferFrom(address(_distributor), _TDAO.getSwapPair(), balance);
        _TDAO.syncSwapPair();
        return true;
    }
    event SwapTokensForTokens(uint256 amountIn, address[] path);
}