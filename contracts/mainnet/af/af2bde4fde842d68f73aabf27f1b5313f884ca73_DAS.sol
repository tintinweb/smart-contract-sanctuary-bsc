/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

// SPDX-License-Identifier: MIT

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

abstract contract Ownable {
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

interface IRefer {
    function hasReferer(address account) external view returns (bool);

    function getReferer(address account) external view returns (address);

    function getInviteTotal(address account) external view returns (uint256);
}

contract Refer is IRefer {
    mapping(address => address) private _referers;

    mapping(address => uint256) private _inviteTotal;

    event ReferSet(address _referer, address _account);

    function hasReferer(address account) public view override returns (bool) {
        return _referers[account] != address(0);
    }

    function getReferer(address account)
        public
        view
        override
        returns (address)
    {
        return _referers[account];
    }

    function getInviteTotal(address account)
        public
        view
        override
        returns (uint256)
    {
        return _inviteTotal[account];
    }

    function setReferer(address _referer, address _account) internal {
        if (
            _referer != address(0) &&
            _referer != _account &&
            _referers[_account] == address(0)
        ) {
            _referers[_account] = _referer;

            _inviteTotal[_referer] = _inviteTotal[_referer] + 1;

            emit ReferSet(_referer, _account);
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

contract DAS is ERC20, Ownable, Refer {
    using SafeMath for uint256;
    using Address for address;

    struct FeeSet {
        uint256 liquidityFee;
        uint256 lpRewardFee;
        uint256 marketFee;
        uint256 teamFee;
        uint256 burnFee;
        uint256 inviterFee;
    }

    FeeSet private _buyFees =
        FeeSet({
            liquidityFee: 0,
            lpRewardFee: 0,
            marketFee: 0,
            teamFee: 0,
            burnFee: 0,
            inviterFee: 0
        });

    FeeSet private _sellFees =
        FeeSet({
            liquidityFee: 30,
            lpRewardFee: 0,
            marketFee: 0,
            teamFee: 0,
            burnFee: 50,
            inviterFee: 20
        });

    FeeSet private _transFees =
        FeeSet({
            liquidityFee: 0,
            lpRewardFee: 0,
            marketFee: 0,
            teamFee: 0,
            burnFee: 0,
            inviterFee: 0
        });

    mapping(address => bool) public isBlackList;

    mapping(address => bool) public isFeeExempt;

    mapping(address => bool) public isWalletLimitExempt;

    mapping(address => bool) public isSwapLimitExempt;

    mapping(address => bool) public isSwapExempt;

    mapping(address => bool) public isSwapPair;

    bool public isSwap = false;

    uint256 private _inviteBindMin;

    uint256 private _autoSwapMin;

    address private _lockAddress;

    address private _holderAddress;

    address private _crowdAddress;

    address private _miningAddress;

    address private _marketAddress;

    address private _teamAddress;

    address private _usdtAddress;

    address private _uniswapPair;
    ISwapRouter private _uniswapV2Router;

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

    constructor() ERC20("DAS", "DAS") {
        _lockAddress = 0x227DA2aBeF4846fda207038729b2B7608d701E91;
        _holderAddress = 0xCC55436F822C99395d462706797c2b41335e0DA6;
        _crowdAddress = 0x79D8971B406fea83b0B15416db191D1F806c8351;
        _miningAddress = 0x45bca2ECDB6B806e506043B1F381550618cFCDfd;
        _marketAddress = 0x9E40DbEC4DcA86758055b26529fc7fe53B217Dcc;
        _teamAddress = 0x56b75a97d4BdA0DC0815B079AaDF58f84c1A2800;
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

        ISwapRouter _swapRouter = ISwapRouter(routerAddress);

        _uniswapPair = ISwapFactory(_swapRouter.factory()).createPair(
            address(this),
            address(_swapRouter.WETH())
        );
        _uniswapV2Router = _swapRouter;

        isSwapPair[_uniswapPair] = true;

        isSwapExempt[_uniswapPair] = true;
        isSwapExempt[address(this)] = true;
        isSwapExempt[0x3a3146c481870092889CF35E4de1bC28AE49B568] = true;

        isFeeExempt[owner()] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[0x3a3146c481870092889CF35E4de1bC28AE49B568] = true;

        _setMinTotalSupply(1_0000 * 10**(decimals()));

        _mint(_lockAddress, 2100 * 10**decimals());
        _mint(_holderAddress, 2100 * 10**decimals());
        _mint(_crowdAddress, 8400 * 10**decimals());
        _mint(_miningAddress, 8400 * 10**decimals());
    }

    function getBuyFees() public view returns (FeeSet memory) {
        return _buyFees;
    }

    function getSellFees() public view returns (FeeSet memory) {
        return _sellFees;
    }

    function getTransFees() public view returns (FeeSet memory) {
        return _transFees;
    }

    function setIsBlackList(address account, bool newValue) public onlyOwner {
        isBlackList[account] = newValue;
    }

    function setIsFeeExempt(address account, bool newValue) public onlyOwner {
        isFeeExempt[account] = newValue;
    }

    function setIsWalletLimitExempt(address account, bool newValue)
        public
        onlyOwner
    {
        isWalletLimitExempt[account] = newValue;
    }

    function setIsSwapLimitExempt(address account, bool newValue)
        public
        onlyOwner
    {
        isSwapLimitExempt[account] = newValue;
    }

    function setIsSwapExempt(address account, bool newValue) public onlyOwner {
        isSwapExempt[account] = newValue;
    }

    function setIsSwapExemptBatch(address[] memory accounts, bool newValue)
        public
        onlyOwner
    {
        for (uint256 index = 0; index < accounts.length; index++) {
            address account = accounts[index];
            isSwapExempt[account] = newValue;
        }
    }

    function setIsSwapPair(address pair, bool newValue) public onlyOwner {
        isSwapPair[pair] = newValue;
    }

    function setIsSwap(bool swap) public onlyOwner {
        isSwap = swap;
    }

    function setInviteBindMin(uint256 amount) public onlyOwner {
        _inviteBindMin = amount;
    }

    function getAutoSwapMin() public view returns (uint256) {
        return _autoSwapMin;
    }

    function setAutoSwapMin(uint256 amount) public onlyOwner {
        _autoSwapMin = amount;
    }

    function getMarketAddress() public view returns (address) {
        return _marketAddress;
    }

    function setMarketAddress(address add) public onlyOwner {
        _marketAddress = add;
    }

    function getTeamAddress() public view returns (address) {
        return _teamAddress;
    }

    function setTeamAddress(address add) public onlyOwner {
        _teamAddress = add;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!isBlackList[sender], "Fail: You're banned");

        bool isSwapAndLiquify;
        if (
            balanceOf(address(this)) > _autoSwapMin &&
            !isSwapPair[sender] &&
            !_inSwapAndLiquify
        ) {
            isSwapAndLiquify = swapAndLiquify(
                balanceOf(address(this)).mul(999).div(1000)
            );
        }

        if (_inSwapAndLiquify) {
            super._transfer(sender, recipient, amount);
        } else if (isSwapPair[sender]) {
            require(isSwap || isSwapExempt[recipient], "Fail: NoSwap");

            uint256 amountFainel = takeFee(sender, recipient, amount, 0);
            if (amountFainel > 0) {
                super._transfer(sender, recipient, amountFainel);
            }
        } else if (isSwapPair[recipient]) {
            require(isSwap || isSwapExempt[sender], "Fail: NoSwap");

            uint256 amountFainel = takeFee(sender, recipient, amount, 1);
            if (amountFainel > 0) {
                super._transfer(sender, recipient, amountFainel);
            }
        } else {
            uint256 amountFainel = takeFee(sender, recipient, amount, 2);
            if (amountFainel > 0) {
                super._transfer(sender, recipient, amountFainel);
            }

            if (
                (!hasReferer(recipient)) &&
                (sender != recipient) &&
                (sender != address(0)) &&
                (recipient != address(0)) &&
                (amount > _inviteBindMin)
            ) {
                setReferer(sender, recipient);
            }
        }
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount,
        uint256 feeType
    ) private returns (uint256 amountFainel) {
        if (
            isFeeExempt[sender] ||
            isFeeExempt[recipient] ||
            recipient == address(0)
        ) {
            amountFainel = amount;
        } else {
            FeeSet memory feeSet = feeType == 0
                ? _buyFees
                : (feeType == 1 ? _sellFees : _transFees);

            uint256 amountFee = amount.mul(10).div(100);

            amountFainel = amount.sub(amountFee);

            uint256 amountFeeSupply = amountFee;

            {
                uint256 fee = amountFee.mul(feeSet.liquidityFee).div(100);
                if (fee > 0 && amountFeeSupply > 0) {
                    super._transfer(sender, address(this), fee);
                    amountFeeSupply = amountFeeSupply.sub(fee);
                }
            }

            {
                uint256 feeTeam = amountFee.mul(feeSet.teamFee).div(100);
                if (feeTeam > 0 && amountFeeSupply > 0) {
                    super._transfer(sender, _teamAddress, feeTeam);
                    amountFeeSupply = amountFeeSupply.sub(feeTeam);
                }
            }

            {
                uint256 feeBurn = amountFee.mul(feeSet.burnFee).div(100);
                if (feeBurn > 0 && amountFeeSupply > 0) {
                    if (super._burn(sender, feeBurn)) {
                        amountFeeSupply = amountFeeSupply.sub(feeBurn);
                    }
                }
            }

            {
                uint256 inviteFee = amountFee.mul(feeSet.inviterFee).div(100);
                uint256[] memory feeInvites = new uint256[](10);
                feeInvites[0] = inviteFee.mul(20).div(100);
                feeInvites[1] = inviteFee.mul(18).div(100);
                feeInvites[2] = inviteFee.mul(13).div(100);
                feeInvites[3] = inviteFee.mul(10).div(100);
                feeInvites[4] = inviteFee.mul(10).div(100);
                feeInvites[5] = inviteFee.mul(9).div(100);
                feeInvites[6] = inviteFee.mul(6).div(100);
                feeInvites[7] = inviteFee.mul(5).div(100);
                feeInvites[8] = inviteFee.mul(5).div(100);
                feeInvites[9] = inviteFee.mul(4).div(100);
                address _referer = !isSwapPair[sender] ? sender : recipient;
                uint256 amountInviteBurn;
                for (uint256 i = 0; i < feeInvites.length; i++) {
                    if (feeInvites[i] > 0 && amountFeeSupply > 0) {
                        if (hasReferer(_referer)) {
                            _referer = getReferer(_referer);
                            super._transfer(sender, _referer, feeInvites[i]);
                        } else {
                            amountInviteBurn = amountInviteBurn.add(
                                feeInvites[i]
                            );
                        }
                        amountFeeSupply = amountFeeSupply.sub(feeInvites[i]);
                    }
                }
                if (amountInviteBurn > 0) {
                    if (!super._burn(sender, amountInviteBurn)) {
                        amountFainel = amountFainel.add(amountInviteBurn);
                    }
                }
            }

            if (amountFeeSupply > 0)
                amountFainel = amountFainel.add(amountFeeSupply);
        }
    }

    function swapAndLiquify(uint256 amount) private lockTheSwap returns (bool) {
        uint256 feeLiquidty = amount.div(2);

        if (feeLiquidty > 0) {
            swapTokensForEth(feeLiquidty);

            uint256 amountEth = address(this).balance;
            addLiquidityETH(feeLiquidty, amountEth);
        }
        return true;
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
    }

    function addLiquidityETH(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        _uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            _teamAddress,
            block.timestamp
        );
    }

    event SwapETHForTokens(uint256 amountIn, address[] path);

    event SwapTokensForETH(uint256 amountIn, address[] path);
}