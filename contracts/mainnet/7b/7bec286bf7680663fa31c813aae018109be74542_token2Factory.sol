/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT
pragma solidity = 0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "s003");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "s004");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "s005");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "s006");
        uint256 c = a / b;
        return c;
    }
}

contract Token2 is Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    //for minter
    uint256 public maxSupply;
    mapping(address => bool)  public MinerList;


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (address newOwner_, string memory name_, string memory symbol_, uint256 decimals_, uint256 totalSupply_, uint256 _preSupply)  {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        //for minter
        maxSupply = totalSupply_.mul(10 ** decimals_);
        MinerList[newOwner_] = true;
        uint256 preSupply = _preSupply.mul(10 ** decimals_);
        _totalSupply = preSupply;
        _balances[newOwner_] = preSupply;
        emit Transfer(address(0), newOwner_, preSupply);
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

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "e007");
        require(recipient != address(0), "e008");
        _beforeTokenTransfer(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "e009");
        require(spender != address(0), "e010");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    //for minter
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: mint to the zero address');
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    //for minter
    function mint(address _to, uint256 _amount) public returns (bool) {
        require(MinerList[msg.sender], "only miner!");
        require(_totalSupply.add(_amount) <= maxSupply);
        _mint(_to, _amount);
        return true;
    }

    //for minter
    function addMiner(address _adddress) public onlyOwner {
        MinerList[_adddress] = true;
    }

    //for minter
    function removeMiner(address _adddress) public onlyOwner {
        MinerList[_adddress] = false;
    }
}


interface tokenFactoryList {
    function addToken(address _factoryAddress, string memory _factoryName, address _token, address _owner, string memory name_, string memory symbol_, uint256 decimals_, uint256 totalSupply_, bool _has_miner_mode, uint256 preSupply_) external;
}

contract token2Factory is Ownable {
    tokenFactoryList public tokenFactoryListAddress;

    constructor(tokenFactoryList _tokenFactoryListAddress) {
        setTokenFactoryListAddress(_tokenFactoryListAddress);
    }

    function setTokenFactoryListAddress(tokenFactoryList _tokenFactoryListAddress) public onlyOwner {
        tokenFactoryListAddress = _tokenFactoryListAddress;
    }

    function createToken(
        address newOwner_,
        string memory name_,
        string memory symbol_,
        uint256 decimals_,
        uint256 totalSupply_,
        bool _has_miner_mode,
        uint256 preSupply_
    ) external {
        require(address(tokenFactoryListAddress) != address(0), "k001");
        require(msg.sender == address(tokenFactoryListAddress), "k002");
        require(_has_miner_mode, "k003");
        address token = address(new Token2(newOwner_, name_, symbol_, decimals_, totalSupply_, preSupply_));
        Token2(token).transferOwnership(newOwner_);
        tokenFactoryListAddress.addToken(address(this), "Token2", token, newOwner_, name_, symbol_, decimals_, totalSupply_, _has_miner_mode, preSupply_);
    }
}