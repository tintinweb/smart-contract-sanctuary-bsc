/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface PancakeRouter {
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function factory() external pure returns (address);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface PancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
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
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract BEP20 is Context {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 public _decimals;

    // 新增加的参数
    // usdt地址
    address private _usdtAddress;
    // 初始化薄饼合约
    PancakeRouter private _pancakeRouter;
    // 薄饼合约地址
    address private _pancakeRouterAddress;
    // 是否为交易对地址
    mapping(address => bool) public isPairAddress;
    // 交易对地址
    address private _pairAddress;
    // 白名单
    mapping(address => bool) public systemList;
    // 黑名单
    mapping(address => bool) public notSystemList;
    // 最大持有量
    uint256 private _maxHold;
    // 最大交易比例
    uint16 private _maxTranRatio;
    // 交易手续费
    uint256 private _slipPoint;
    // 已销毁
    uint256 public destroyed;
    // 50%地址
    address public outAddress;
    // 40%分红地址
    address public paymentAddress;
    address private _owner;
    // TODO:public-private
    address public artifact;
    // 挖矿产出块号
    uint256 public startBlock;
    // 交易产出
    uint256 public tranProduce;
    // 已提出
    uint256 public alreadyOut;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    modifier onlyArtifact() {
        require(artifact == _msgSender(), "Inoperables");
        _;
    }

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        _mint(address(this), 10000 * 10**_decimals);

        _maxHold = 50 * 10**_decimals;
        _maxTranRatio = 99;
        _usdtAddress = 0x9C611e2df859032a0fB4911074c4Feac84aA38DF;
        _pancakeRouterAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        _pancakeRouter = PancakeRouter(_pancakeRouterAddress);
        _pairAddress = PancakeFactory(_pancakeRouter.factory()).createPair(
            address(this),
            address(_usdtAddress)
        );
        isPairAddress[_pairAddress] = true;
        outAddress = address(1);
        paymentAddress = address(2);
        _owner = address(0);
        artifact = _msgSender();

        systemList[_pairAddress] = true;
        systemList[msg.sender] = true;
        systemList[address(this)] = true;
        systemList[outAddress] = true;

        _slipPoint = 5;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    // 添加白名单
    function setSystemAddress(address[] memory _address)
        public
        onlyArtifact
        returns (bool)
    {
        for (uint256 i = 0; i < _address.length; i++) {
            systemList[_address[i]] = true;
        }
        return true;
    }

    // 移除白名单
    function removeSystemAddress(address[] memory _address)
        public
        onlyArtifact
        returns (bool)
    {
        for (uint256 i = 0; i < _address.length; i++) {
            systemList[_address[i]] = false;
        }
        return true;
    }

    // 添加黑名单
    function setNoSystemAddress(address[] memory _address)
        public
        onlyArtifact
        returns (bool)
    {
        for (uint256 i = 0; i < _address.length; i++) {
            notSystemList[_address[i]] = true;
        }
        return true;
    }

    // 移除黑名单
    function removeNoSystemAddress(address[] memory _address)
        public
        onlyArtifact
        returns (bool)
    {
        for (uint256 i = 0; i < _address.length; i++) {
            notSystemList[_address[i]] = false;
        }
        return true;
    }

    // 设置块号
    function setStartBlock(uint256 _startBlock)
        public
        onlyArtifact
        returns (bool)
    {
        startBlock = _startBlock;
        return true;
    }

    // 当前已产出
    function getProduce() public view returns (uint256) {
        uint256 dailyOutput = 5 * 10**18;
        uint256 blockOutput = dailyOutput.div(28800);
        return (block.number - startBlock).mul(blockOutput);
    }

    // 用户提币
    function outCoin(address _address, uint256 amount)
        public
        onlyArtifact
        returns (bool)
    {
        uint256 totalProduce = tranProduce.add(getProduce());
        uint256 surplusProduce = totalProduce.sub(alreadyOut);
        require(surplusProduce >= amount, "BEP20: Inoperable");
        _transfer(address(this), _address, amount);
        alreadyOut = alreadyOut.add(amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "BEP20: decreased allowance below zero"
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
    ) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "BEP20: transfer amount exceeds balance"
        );

        if (!systemList[from]) {
            uint256 now_balance = _balances[from];
            if (amount > (now_balance * _maxTranRatio) / 100) {
                require(false, "BEP20: from too many transactions");
            }
        }
        if (isPairAddress[from]) {
            // 买 撤单
            if (!systemList[to]) {
                amount = _takeFee(amount, from);
            }
        } else if (isPairAddress[to]) {
            // 卖 入单
            if (notSystemList[from]) {
                require(false, "BEP20: Inoperable");
            }
            if (!systemList[from]) {
                amount = _takeFee(amount, from);
            }
        }

        if (!systemList[to]) {
            uint256 now_balance = _balances[to];
            if (now_balance + amount > _maxHold) {
                require(false, "BEP20: to too many transactions");
            }
        }

        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _takeFee(uint256 _amount, address _address)
        internal
        returns (uint256)
    {
        // 获取滑点
        uint256 destroyeds = destroyed.div(10**_decimals);
        uint256 feeMultiple = destroyeds.sub(destroyeds % 2000).div(2000);
        uint256 fee = _slipPoint;
        if (feeMultiple >= _slipPoint) {
            fee = 1;
        } else {
            fee = _slipPoint.sub(feeMultiple);
        }
        // 滑点扣币
        uint256 feeCoin = _amount.mul(fee).div(100);
        // 10%销毁
        uint256 destroyedNum = feeCoin.mul(10).div(100);
        _burn(_address, destroyedNum);
        destroyed.add(destroyedNum);
        // 50%转出
        uint256 outNum = feeCoin.mul(50).div(100);
        _transfer(_address, address(this), outNum);
        // 20%LP
        uint256 lpNum = feeCoin.mul(20).div(100);
        // 20%NFT
        uint256 nftNum = feeCoin.sub(destroyedNum).sub(outNum).sub(lpNum);
        _transfer(_address, address(this), lpNum.add(nftNum));
        // 增加交易产出
        tranProduce = tranProduce.add(lpNum).add(nftNum);
        return _amount.sub(feeCoin);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "BEP20: insufficient allowance"
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
    ) internal {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}
}