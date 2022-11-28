/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address account, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    //管理员地址
    address payable public   adminAddress;

    modifier isAdmin(){
        require(msg.sender == adminAddress, 'no admin');
        _;
    }
    //修改管理员
    function editAdmin(address newAddress) public isAdmin {
        adminAddress = payable(newAddress);
    }
    //增发
    function mint(address account, uint256 amount) public isAdmin {
        _mint(account, amount * 10 ** _decimals);
    }
    //提现主币
    function withdraw() external isAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    /// 小数点位数一般为 18
    //修改精度修改此函数
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
    // 返回当前流通代币的总量
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    // 查询指定帐号地址余额
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    // 转帐功能
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }
    // 获取被授权者可使用授权帐号的可使用余额
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    // 授权指定帐事情可使用自己一定额度的帐户余额。
    // 授权spender, 可将自己余额。使用可使用的余额的总量为amount
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }
    //approve函数中的spender调用，将授权人 from 帐户中的代币转入to 帐户中
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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 substractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= substractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(owner, spender, currentAllowance - substractedValue);
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
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
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
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
        _balances[account] = accountBalance - amount;
    }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve  to the zero address");
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
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
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
    constructor(string memory tokenName, string memory symbolName, uint8 tokenDecimals, uint256 startTotal, address account) payable {
        _name = tokenName;
        //代币名称
        _symbol = symbolName;
        //代币符号
        _decimals = tokenDecimals;
        //代币精度
        _mint(account, startTotal * 10 ** _decimals);
        //代币总量
        adminAddress = payable(msg.sender);
        //设置管理地址
    }
    fallback() external payable {
    }

    receive() external payable {
    }
}

//部署合约
contract DeploymentContract {
    uint public deployFee;

    fallback() external payable {
    }

    receive() external payable {
    }
    constructor()  {
        adminAddress = payable(msg.sender);
        //设置管理地址
        deployFee = 1000000000000000000;
    }
    //管理员地址
    address payable public   adminAddress;
    modifier isAdmin(){
        require(msg.sender == adminAddress, 'no admin');
        _;
    }
    //修改管理员
    function editAdmin(address newAddress) public isAdmin {
        adminAddress = payable(newAddress);
    }

    event Deploy(address);
    event EditDeployFee(uint);
    //获取code码
    function getByCode(string memory _tokenName, string memory _symbolName, uint8 _tokenDecimals, uint256 _startTotal) public payable returns (bytes memory){
        bytes memory byteCode = type(ERC20).creationCode;
        return abi.encodePacked(byteCode, abi.encode(_tokenName, _symbolName, _tokenDecimals, _startTotal));
    }
    //部署合约
    function deploy(string memory _tokenName, string memory _symbolName, uint8 _tokenDecimals, uint256 _startTotal) public payable returns (address addr){
        require(msg.value >= deployFee, 'fee Insufficient');
        bytes memory byteCode = type(ERC20).creationCode;
        bytes memory _code = abi.encodePacked(byteCode, abi.encode(_tokenName, _symbolName, _tokenDecimals, _startTotal, msg.sender));
        assembly{
            addr := create(callvalue(), add(_code, 0x20), mload(_code))
        }
        require(addr != address(0), 'deploy failed');
        emit Deploy(addr);
    }
    //转移代币权限
    function editOwner(address token, address newAddress) external payable isAdmin {
        bytes memory _data = abi.encodeWithSignature("editAdmin(address)", newAddress);
        (bool success,) = token.call{value : msg.value}(_data);
        require(success, 'edit failed');
    }
    //增发代币
    function mint(address token, address account, uint256 amount) external payable isAdmin {
        bytes memory _data = abi.encodeWithSignature("mint(address,uint256)", account, amount);
        (bool success,) = token.call{value : msg.value}(_data);
        require(success, 'edit failed');
    }
    //修改发币手续费
    function editDeployFee(uint _fee) external isAdmin {
        deployFee = _fee;
        emit EditDeployFee(_fee);
    }
    //取出合约主币
    function tokenWithdraw(address token) external payable isAdmin {
        bytes memory _data = abi.encodeWithSignature("withdraw()");
        (bool success,) = token.call{value : msg.value}(_data);
        require(success, 'edit failed');
    }
    //取出代币
    function withdrawToken(IERC20 token) external payable isAdmin {
        token.transfer(msg.sender,token.balanceOf(address(this)));
    }

    //提现主币
    function withdraw() external isAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }
}