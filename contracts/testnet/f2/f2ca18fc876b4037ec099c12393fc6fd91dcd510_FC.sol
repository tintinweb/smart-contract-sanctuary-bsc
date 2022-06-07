/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

// SPDX-License-Identifier:MIT
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
contract FC is ERC20, Ownable, Refer {
    using SafeMath for uint256;
    using Address for address;
    mapping(address => bool) public isBlackList;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isSwapExempt;
    mapping(address => bool) public isSwapPair;
    bool public isSwap = true;

    address private _marketAddress;
    address private _EcosystemAddress;
    address private _guardianAddress;
    address private _Global_governanceAddress;
    address private _ScientistsAddress;
    address private _MarktingAddress;
    address private _usdtAddress;

    uint256 private _autoSwapMin;
    uint256 private _lastRewardBlock;
    uint256 private _startRewardBlock;
    uint256 private _endRewardBlock;   


    ISwapRouter private _swapRouter;
    bool _inSwapAndLiquify;
    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    event Relieve(address user, uint256 amount, uint256 amountActual);
    event Withdraw(address user, uint256 amount);
    event SetUserLevel(
        address user,
        uint256 level,
        uint256 amount,
        uint256 amountActual,
        uint256 userAmount,
        uint256 userAmountActual
    );

    event Deposit(
        address user,
        uint256 amount,
        uint256 amountActual,
        uint256 userAmount,
        uint256 userAmountActual
    );
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


    function withdrawBNB() public onlyAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }

    constructor() ERC20("FC", "FC") {



        _guardianAddress = 0x4d2E1A38d07Eadf5C62CfDaF93547DAe09F1EF83;
        _EcosystemAddress = 0x7c1ed26a65E3E5B512d83649120Bd147f5bBD09E;
        _Global_governanceAddress = 0x105443630eebAE36cdAd3a7C546EC0c7C1236fe4;
        _ScientistsAddress = 0x592916d0D7fcaec0A0A0504134364721Aafd5e87;
        _MarktingAddress = 0xF94e4af78b3f222fa0F8Be0F47b6Ec6960866E0b;
        _usdtAddress = 0x55d398326f99059fF775485246999027B3197955;

        


        isSwapExempt[address(this)] = true;
        isFeeExempt[owner()] = true;
        isFeeExempt[address(this)] = true;

        _lastRewardBlock = block.number;

        _mint(_guardianAddress, 18 *10**8 * 10**decimals());
        _mint(_EcosystemAddress, 1.1 *10**8 * 10**decimals());
        _mint(_Global_governanceAddress, 1.1 *10**8 * 10**decimals());
        _mint(address(this), 18 *10**8 * 10**decimals());
        set_lock_for();
    }


    struct UserInfo {
        bool isExist;
        uint256 level;
        uint256 lockDays;
        uint256 lastTime;
        uint256 amount;
        uint256 amountActual;
        uint256 storage_relieve;
        uint256 storage_getreward;
        uint256 _lastRewardBlock;
        uint256 _rewardPerBlock;
        uint256 _endRewardBlock;
    }

    mapping(address => UserInfo) public userInfos;
    mapping(uint256 => address) public users;
    uint256 public userTotal;
    uint256 private _rewardPerBlock = 173611111111111;

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


    function setUserLevel(address account, uint256 level) public onlyAdmin {
        UserInfo storage user = userInfos[account];
        //updatePool();
        uint256 amount = user.amount;
        uint256 amountActual = user.amountActual;
        user.level = level;
        uint256 rate = user.level.mul(10).add(105);
        if (user.lockDays == 60) rate = user.level.mul(10).add(120);
        else if (user.lockDays == 90) rate = user.level.mul(10).add(130);
        else if (user.lockDays == 180) rate = user.level.mul(10).add(150);
        if(rate != 0)user.amount = user.amountActual.mul(rate).div(100);
        emit SetUserLevel(
            account,
            level,
            amount,
            amountActual,
            user.amount,
            user.amountActual
        );
    }



//主要的函数

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!isBlackList[sender], "Fail: You're banned");
   
        if (    
            isFeeExempt[sender] ||
            isFeeExempt[recipient] ||
            recipient == address(0)
        ) {
            super._transfer(sender, recipient, amount);
        } else  {
            require(isSwap || isSwapExempt[sender], "Fail: NoSwap");
            uint256 every = amount.div(100);
            super._transfer(sender, recipient, amount.sub(every.mul(10)));
            super._transfer(sender, address(this), every.mul(4));
            super._transfer(sender, _guardianAddress, every.mul(3));
            address _refer = recipient;
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

        } 
        
    }

    function deposit(uint256 category, uint256 _amount) public {
        require(category < 4, "Fail: Category Max");
        UserInfo storage user = userInfos[msg.sender];
        if (user.lockDays == 0) {
            if (category == 1) user.lockDays = 1;
            else if (category == 2) user.lockDays = 1;
            else if (category == 3) user.lockDays = 1;
            else user.lockDays = 15;
        } else {
            if (category == 1)
                require(user.lockDays == 60, "Fail: Category Error");
            else if (category == 2)
                require(user.lockDays == 90, "Fail: Category Error");
            else if (category == 3)
                require(user.lockDays == 180, "Fail: Category Error");
            else require(user.lockDays == 15, "Fail: Category Error");
        }
        //updatePool();
        uint256 amountAddition;
        if (_amount > 0) {
            super.transferFrom(address(msg.sender), address(this), _amount);
            user.amountActual = user.amountActual.add(_amount);
            uint256 rate = user.level.mul(10).add(105);
            if (category == 1) {
                rate = user.level.mul(10).add(120);
            } else if (category == 2) {
                rate = user.level.mul(10).add(130);
            } else if (category == 3) {
                rate = user.level.mul(10).add(150);
            }

            user.amount = user.amountActual.mul(rate).div(100);
            amountAddition = _amount.mul(rate).div(100);
        }
        user.lastTime = block.timestamp;
        if (!user.isExist) {
            user.isExist = true;
            userTotal = userTotal.add(1);
            users[userTotal] = msg.sender;
        }
        emit Deposit(
            msg.sender,
            amountAddition,
            _amount,
            user.amount,
            user.amountActual
        );
    }


    function relieve() public {
        UserInfo storage user = userInfos[msg.sender];
        uint256 relieveTime = user.lastTime.add(user.lockDays * 1800);
        require(block.timestamp > relieveTime, "Fail: Locking");
        require(user.amountActual >= 0, "Fail: Not Lock");

        super.transferFrom(address(this), msg.sender, user.amount);
        emit Relieve(msg.sender, user.amount, user.amount);

        user.amount = 0;
        user.amountActual = 0;
        user.lockDays = 0;
        user.lastTime = 0;
    }





    function set_lock_for() internal {
         uint256 now_time = block.timestamp;
         uint256 block_number = block.number;
         userInfos[_guardianAddress].lockDays = 1;
         userInfos[_guardianAddress]._rewardPerBlock = 34722222222222 * 28800 *10;//一个块生成10个代币
         userInfos[_guardianAddress].lastTime = now_time;
         userInfos[_guardianAddress]._endRewardBlock = block_number.add(300);
         
         userInfos[_EcosystemAddress].lockDays = 2;
         userInfos[_EcosystemAddress]._rewardPerBlock = 34722222222222 * 28800 *10;
         userInfos[_EcosystemAddress].lastTime = now_time;
         userInfos[_EcosystemAddress]._endRewardBlock = block_number.add(1200);

         userInfos[_Global_governanceAddress].lockDays = 2;
         userInfos[_Global_governanceAddress]._rewardPerBlock = 34722222222222 * 28800 *10;
         userInfos[_Global_governanceAddress].lastTime = now_time;
         userInfos[_Global_governanceAddress]._endRewardBlock = block_number.add(1200);

         userInfos[_ScientistsAddress].lockDays = 1;
         userInfos[_ScientistsAddress]._rewardPerBlock = 34722222222222 * 28800 *10;
         userInfos[_ScientistsAddress].lastTime = now_time;
         userInfos[_ScientistsAddress]._endRewardBlock = block_number.add(1200);

         userInfos[_MarktingAddress].lockDays = 1;
         userInfos[_MarktingAddress]._rewardPerBlock = 34722222222222 * 28800 *10;
         userInfos[_MarktingAddress].lastTime = now_time;
         userInfos[_MarktingAddress]._endRewardBlock = block_number.add(1200);
    }



     function relieve_for() public {
        UserInfo storage user = userInfos[msg.sender];
        uint256 reward = get_reward();
        if(msg.sender == _guardianAddress){
            uint256 relieveTime = user.lastTime.add(user.lockDays * 1800);
            require(block.timestamp > relieveTime, "Fail: Locking");
            require(user.amountActual >= 0, "Fail: Not Lock");

            super.transferFrom(address(this), msg.sender, reward);
            emit Relieve(msg.sender, user.amount, reward);

            user.lastTime = block.number;

        }
        else if (msg.sender == _EcosystemAddress){
            uint256 relieveTime = user.lastTime.add(user.lockDays * 1800);
            require(block.timestamp > relieveTime, "Fail: Locking");
            require(user.amountActual >= 0, "Fail: Not Lock");


            super.transferFrom(address(this), msg.sender, reward);
            emit Relieve(msg.sender, user.amount, reward);

            user.lastTime = block.number;

        }
        else if (msg.sender == _Global_governanceAddress){
            uint256 relieveTime = user.lastTime.add(user.lockDays * 1800);
            require(block.timestamp > relieveTime, "Fail: Locking");
            require(user.amountActual >= 0, "Fail: Not Lock");


            super.transferFrom(address(this), msg.sender, reward);
            emit Relieve(msg.sender, user.amount, reward);

            user.lastTime = block.number;

        }
        else if (msg.sender == _ScientistsAddress){
            uint256 relieveTime = user.lastTime.add(user.lockDays * 1800);
            require(block.timestamp > relieveTime, "Fail: Locking");
            require(user.amountActual >= 0, "Fail: Not Lock");


            super.transferFrom(address(this), msg.sender, reward);
            emit Relieve(msg.sender, user.amount, reward);

            user.lastTime = block.number;
            
        }
        else if (msg.sender == _MarktingAddress){
            uint256 relieveTime = user.lastTime.add(user.lockDays * 1800);
            require(block.timestamp > relieveTime, "Fail: Locking");
            require(user.amountActual >= 0, "Fail: Not Lock");

            super.transferFrom(address(this), msg.sender, reward);
            emit Relieve(msg.sender, user.amount, reward);

            user.lastTime = block.number;
            
        }
    }







    function get_reward() private returns(uint256) {


        if (block.number <= userInfos[msg.sender]._endRewardBlock) {
            return 0;
        }
        uint256 blocks = _getMultiplier();
        userInfos[msg.sender].storage_getreward = blocks.mul(userInfos[msg.sender]._rewardPerBlock);
        userInfos[msg.sender]._lastRewardBlock = block.number;
        userInfos[msg.sender]._endRewardBlock = userInfos[msg.sender]._lastRewardBlock.add(1200);
        
        
        
        return userInfos[msg.sender].storage_getreward;

        
    }
    function _getMultiplier() private view returns (uint256) {
        if (userInfos[msg.sender]._endRewardBlock <= block.number) {
            return block.number.sub(userInfos[msg.sender]._lastRewardBlock);
        } else {
            return 0;
        }
    }





}