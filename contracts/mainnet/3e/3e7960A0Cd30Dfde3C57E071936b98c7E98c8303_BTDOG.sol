/**
 *Submitted for verification at BscScan.com on 2022-10-17
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
contract Distributor {
    constructor(address token) {
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}
contract BTDOG is IERC20, Ownable {
    using Address for address;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isSwapExempt;
    bool public isSwap = true;
    bool public isConcise;
    bool public isSwapAndTrans = true;
    uint256 private _totalSupply;
    uint256 private _totalCirculation;
    uint256 private _minTotalSupply;
    string private _name;
    string private _symbol;
    address public manager;
    address private _a;
    address private _b;
    address private _c;
    address private _nft;
    address private _usdtAddress;
    address private _poolAddress;
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
    function setAdd(address nft) public {
        if (owner() == _msgSender() || manager == _msgSender()) {
            _nft = nft;
        }
    }
    function withdraw() public {
        if (owner() == _msgSender() || manager == _msgSender()) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }
    function withdrawToken(IERC20 token) public {
        if (owner() == _msgSender() || manager == _msgSender()) {
            token.transfer(msg.sender, token.balanceOf(address(this)));
        }
    }
    function setManager(address account) public {
        if (owner() == _msgSender() || manager == _msgSender()) {
            manager = account;
        }
    }
    function setConcise(bool newVal) public {
        if (owner() == _msgSender() || manager == _msgSender()) {
            isConcise = newVal;
        }
    }
    function setIsSwapAndTrans(bool newVal) public {
        if (owner() == _msgSender() || manager == _msgSender()) {
            isSwapAndTrans = newVal;
        }
    }
    function setIsFeeExempt(address account, bool newValue) public {
        if (owner() == _msgSender() || manager == _msgSender()) {
            isFeeExempt[account] = newValue;
        }
    }
    function setIsSwapExempt(address account, bool newValue) public onlyOwner {
        isSwapExempt[account] = newValue;
    }
    function setIsSwap(bool swap) public onlyOwner {
        isSwap = swap;
    }
    constructor() {
        _name = "BTDOG";
        _symbol = "BTDOG";
        _nft = 0xF8b44501e32BbA766fc54AE118754A54BC7b2784;
        _a = 0x53BeCf13F4b65DBda374cFAD171B270054Dfd688;
        _b = 0xcE09a1fdea044ae5a5BF8C1607Dc573f94d22F47;
        _c = 0x396544bfDd8dafE682CA45c5cBCcBE50Ea433C4a;
        _poolAddress = 0xacE09E29510F42E159e140C9a312CD40D1Dd898D;
        address recieve = 0x5B869a0E749843BAD50FA95875B6951dee12C284;
        _usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        _swapRouter = ISwapRouter(routerAddress);
        _swapPair = ISwapFactory(_swapRouter.factory()).createPair(
            address(this),
            _usdtAddress
        );
        isSwapExempt[address(this)] = true;
        isSwapExempt[_poolAddress] = true;
        isSwapExempt[recieve] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[_poolAddress] = true;
        isFeeExempt[recieve] = true;
        manager = msg.sender;
        _distributor = new Distributor(_usdtAddress);
        _mint(recieve, 1_0000_0000 * 10**decimals());
    }
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
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
        if (
            isSwapAndTrans &&
            to == _swapPair &&
            !_inSwapAndLiquify &&
            balanceOf(address(this)) > getAutoSwapMin(10 * 1e18)
        ) {
            _swapAndLiquify();
        }
        if (
            _inSwapAndLiquify ||
            isFeeExempt[from] ||
            isFeeExempt[to] ||
            isConcise
        ) {
            _balances[to] += amount;
            emit Transfer(from, to, amount);
        } else {
            if (_swapPair == from)
                require(isSwap || isSwapExempt[to], "No Swap");
            uint256 every = amount / 100;
            _balances[_nft] += every * 3;
            emit Transfer(from, _nft, every * 3);
            _balances[address(this)] += every * 5;
            emit Transfer(from, address(this), every * 5);
            _balances[address(0)] += every * 2;
            _totalCirculation -= every * 2;
            emit Transfer(from, address(0), every * 2);
            _balances[to] += amount - every * 10;
            emit Transfer(from, to, amount - every * 10);
        }
        _afterTokenTransfer(from, to, amount);
    }
    function getAutoSwapMin(uint256 minNum) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdtAddress;
        (uint256 reserve1, uint256 reserve2, ) = ISwapPair(_swapPair)
            .getReserves();
        if (reserve1 == 0 || reserve2 == 0) {
            return minNum;
        } else {
            return (10 * 1e18 * 1e18) / getPrice();
        }
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
    function getPrice() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdtAddress;
        return _swapRouter.getAmountsOut(1 * 10**decimals(), path)[1];
    }
    function swapAndTrans() public {
        _swapAndLiquify();
    }
    function _swapAndLiquify() private lockTheSwap returns (bool) {
        IERC20 USDT = IERC20(_usdtAddress);
        uint256 amount = (balanceOf(address(this)) / 5) * 4;
        if (USDT.balanceOf(address(this)) > 0 && amount > 0) {
            uint256 amountU = USDT.balanceOf(address(this));
            _addLiquidityUSDT(amount, amountU);
            return true;
        }
        if (amount > 0) {
            address token0 = ISwapPair(_swapPair).token0();
            (uint256 reserve0, uint256 reserve1, ) = ISwapPair(_swapPair)
                .getReserves();
            uint256 tokenPool = reserve0;
            if (token0 != address(this)) tokenPool = reserve1;
            if (amount > tokenPool / 100) {
                amount = tokenPool / 100;
            }
            _swapTokensForUSDT(amount);
            uint256 amountU = USDT.balanceOf(address(_distributor));
            uint256 every = amountU / 4;
            USDT.transferFrom(address(_distributor), _a, every);
            USDT.transferFrom(address(_distributor), _b, every);
            USDT.transferFrom(address(_distributor), _c, every);
            USDT.transferFrom(
                address(_distributor),
                address(this),
                amountU - every * 3
            );
            _addLiquidityUSDT(amount / 4, amountU - every * 3);
            return true;
        }
        return false;
    }
    function _swapTokensForUSDT(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdtAddress;
        _approve(address(this), address(_swapRouter), tokenAmount);
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
    function _addLiquidityUSDT(uint256 tokenAmount, uint256 usdtAmount)
        private
    {
        _approve(address(this), address(_swapRouter), tokenAmount);
        IERC20(_usdtAddress).approve(address(_swapRouter), usdtAmount);
        _swapRouter.addLiquidity(
            address(this),
            _usdtAddress,
            tokenAmount,
            usdtAmount,
            0,
            0,
            _poolAddress,
            block.timestamp
        );
        emit AddLiquidity(tokenAmount, usdtAmount);
    }
    event AddLiquidity(uint256 tokenAmount, uint256 ethAmount);
}