/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event TransferFrom(address indexed from, address indexed to, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new owner is 0");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

//GAIN ERC20 智能合约
contract Pro is IERC20, Ownable {
    string private _name; // 代币名称
    string private _symbol; // 代币符合
    uint256 private _decimals; // 小数点位数
    uint256 private _tTotal; // 代币发行总量
    mapping(address => uint256) private _balanceOf; // 代币存放map
    mapping(address => mapping(address => uint256)) private _allowances; // 授权转账额度

    address public pancakeV2Pair;

    address public USD = address(0x55d398326f99059fF775485246999027B3197955);
    address public _blackHoleAddress = address(0x000000000000000000000000000000000000dEaD);

    address private _mintAddress = address(0x6AbC9dc6dbbc544bBcD6377D2c4320ff1FF60681);
    address public _staticAddress = address(0x03A10e26C294B6578bE72fdd4A58aD4Ed89391f1);
    address public _dynamicAddress = address(0x1F48E56739B87279302917dB2Db8f39538b65dE8);
    address public _poolAddress = address(0x949045065494D046B548b6AF08995fb92547C326);
    address public _partnerAddress = address(0x874Cc89006F1e6D88e83f5F4B907174d5769EeE9);
    address public _operateAddress = address(0x843438Ab33BD3c0EBbe4E0dAa70273AF35a811c2);
    address public _adminAddress = address(0x0d12F1f8467a1aB1761841f998cc0294bC3f4e69);

    uint256 public _buyBurnFee = 0;
    uint256 public _buyOperateFee = 5;

    uint256 public _sellBurnFee = 9;
    uint256 public _sellOperateFee = 21;

    mapping(uint256 => uint256) public _random;

    event _buyTicket(uint256 amount, uint256 random);

    event _rechargeUSD(uint256 amount, uint256 random);

    event _buyToken(address indexed from, address indexed to, uint256 value);

    event _sellToken(address indexed from, address indexed to, uint256 value);

    constructor(address tokenOwner) {
        _name = "Pro";
        _symbol = "Pro";
        _decimals = 18;
        _tTotal = 100000 * 10**_decimals;
        // 总量 10 万
        _balanceOf[_mintAddress] = 100000 * 10**_decimals;
        emit Transfer(_blackHoleAddress, _mintAddress, 100000 * 10**_decimals);
        //转移所有权
        transferOwnership(tokenOwner);
    }

    // 购买凭证
    function buyTicket(
        uint256 amount,
        uint256 random
    ) public returns (bool) {
        uint256 balance = _balanceOf[msg.sender];
        require(balance >= amount, "balance is not enough");

        bool success = IERC20(USD).transferFrom(address(msg.sender), _staticAddress, 5 * 10**_decimals);
        require(success,  "USDT transfer is failed");

        if (success) {
            _balanceOf[msg.sender] = _balanceOf[msg.sender] - amount;
            _balanceOf[_blackHoleAddress] = _balanceOf[_blackHoleAddress] + amount;
            emit Transfer(msg.sender, _blackHoleAddress, amount);

            _random[random] = amount;
            emit _buyTicket(amount, random);
            return true;
        } else {
            return false;
        }
    }

    // 充值
    function rechargeUSD(
        uint256 amount,
        uint256 random
    ) public returns (bool) {
        bool successStatic = IERC20(USD).transferFrom(address(msg.sender), _staticAddress, amount * 9 * 10**18);
        bool successDynamic = IERC20(USD).transferFrom(address(msg.sender), _dynamicAddress, amount * 798 * 10**16);
        bool successPool = IERC20(USD).transferFrom(address(msg.sender), _poolAddress, amount * 630 * 10**16);
        bool successPartner = IERC20(USD).transferFrom(address(msg.sender), _partnerAddress, amount * 357 * 10**16);
        bool successOperate = IERC20(USD).transferFrom(address(msg.sender), _operateAddress, amount * 210 * 10**16);
        bool successAdmin = IERC20(USD).transferFrom(address(msg.sender), _adminAddress, amount * 105 * 10**16);

        if (successStatic && successDynamic && successPool && successPartner && successOperate && successAdmin) {
            _random[random] = amount * 30 * 10**18;
            emit _rechargeUSD(amount * 30 * 10**18, random);
            return true;
        } else {
            return false;
        }
    }

    function changeRouter(address router) public onlyOwner {
        require(router != address(0), "transfer router to the zero address");
        pancakeV2Pair = router;
    }

    function getRandomAmount(uint256 random) public view returns (uint256 amount) {
        return _random[random];
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balanceOf[account];
    }

    //转账交易
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        if (msg.sender == pancakeV2Pair) {
            _transferBuy(msg.sender, recipient, amount);
        } else {
            // 普通转账
            _transfer(msg.sender, recipient, amount);
        }
        return true;
    }

    //授权转账
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "exceeds allowance"); //判断授权额度是否够
        require(_balanceOf[sender] >= amount, "exceeds allowance"); //判断sender账户余额是否够
        if (recipient == pancakeV2Pair) {
            _transferSell(sender, recipient, amount);
        } else {
            // 普通转账
            _transfer(sender, recipient, amount);
        }
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        emit TransferFrom(sender, recipient, amount);

        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        require(amount > 0, "amount <= 0");
        require(_balanceOf[msg.sender] >= amount, "exceeds allowance");
        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        require(_allowances[msg.sender][spender] >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    //to recieve ETH from pancakeV2Router when swaping
    receive() external payable {}

    function claimTokens() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // 普通交易转账
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balanceOf[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        _balanceOf[from] = fromBalance - amount;
        _balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }

    //pancake 交易转账
    function _transferBuy(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balanceOf[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        _balanceOf[from] = fromBalance - amount;

        require((_buyBurnFee + _buyOperateFee) < 1000, "ERC20: transfer fee error");
        uint256 recipientRate = 1000 - (_buyBurnFee + _buyOperateFee);

        if(_buyBurnFee > 0){
            _takeTransfer(from, _blackHoleAddress, (amount * _buyBurnFee) / 1000);
        }
        if(_buyOperateFee > 0){
            _takeTransfer(from, _staticAddress, (amount * _buyOperateFee) / 1000);
        }

        _balanceOf[to] = _balanceOf[to] + ((amount * recipientRate) / 1000);

        emit _buyToken(from, to, amount);
        emit Transfer(from, to, ((amount * recipientRate) / 1000));
    }

    //pancake 交易转账
    function _transferSell(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balanceOf[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        _balanceOf[from] = fromBalance - amount;

        require((_sellBurnFee + _sellOperateFee) < 1000, "ERC20: transfer fee error");
        uint256 recipientRate = 1000 - (_sellBurnFee + _sellOperateFee);

        if(_sellBurnFee > 0){
            _takeTransfer(from, _blackHoleAddress, (amount * _sellBurnFee) / 1000);
        }
        if(_sellOperateFee > 0){
            _takeTransfer(from, _staticAddress, (amount * _sellOperateFee) / 1000);
        }

        _balanceOf[to] = _balanceOf[to] + ((amount * recipientRate) / 1000);

        emit _sellToken(from, to, amount);
        emit Transfer(from, to, ((amount * recipientRate) / 1000));
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balanceOf[to] = _balanceOf[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "owner:0");
        require(spender != address(0), "spender:0");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}