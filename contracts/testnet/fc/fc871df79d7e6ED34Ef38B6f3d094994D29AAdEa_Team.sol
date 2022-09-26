/**
 *Submitted for verification at BscScan.com on 2022-09-25
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Math error");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Math error");
        return a - b;
    }
}


abstract contract ERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external virtual view returns (string memory);
    function symbol() external virtual view returns (string memory);
    function decimals() external virtual view returns (uint8);
    function totalSupply() external virtual view returns (uint256);
    function balanceOf(address owner) external virtual view returns (uint256);
    function allowance(address owner, address spender) external virtual view returns (uint256);
    function approve(address spender, uint256 value) external virtual returns (bool);
    function transfer(address to, uint256 value) external virtual returns (bool);
    function transferFrom(address from, address to, uint256 value) external virtual returns (bool);
}


contract Team is ERC20 {
    string private _name = "Team Token";
    string private _symbol = "TEAM";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 100000000 * (10**_decimals);
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowed;

    // user -> super
    mapping (address => address) private _superiorAddress;
    // user -> junior
    mapping (address => address[]) private _juniorsAddress;
    uint256 public boundMix = 1 * (10**16); // 0.01
    // owner
    address public owner;
    // first super
    address private immutable _firstSuper;

    event Bound(address indexed superior, address indexed junior);


    constructor() {
        owner = msg.sender;
        _firstSuper = owner;
        _balances[owner] = _totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: owner error");
        _;
    }

    function transferOwnership(address owner_) external onlyOwner {
        require(owner_ != address(0), "Ownable: zero address error");
        owner = owner_;
    }

    function setBoundMix(uint256 boundMix_) external onlyOwner {
        boundMix = boundMix_;
    }

    
    function name() external override view returns (string memory) {
        return _name;
    }

    function symbol() external override view returns (string memory) {
        return _symbol;
    }

    function decimals() external override view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address address_) external override view returns (uint256) {
        return _balances[address_];
    }

    function _transfer(address from_, address to_, uint256 value_) private {
        if(value_ >= boundMix) _bound(from_, to_);
        _balances[from_] = SafeMath.sub(_balances[from_], value_);
        _balances[to_] = SafeMath.add(_balances[to_], value_);
        emit Transfer(from_, to_, value_);
    }

    function transfer(address to_, uint256 value_) external override returns (bool) {
        _transfer(msg.sender, to_, value_);
        return true;
    }

    function approve(address spender_, uint256 amount_) external override returns (bool) {
        _allowed[msg.sender][spender_] = amount_;
        emit Approval(msg.sender, spender_, amount_);
        return true;
    }

    function transferFrom(address from_, address to_, uint256 value_) external override returns (bool) {
        _allowed[from_][msg.sender] = SafeMath.sub(_allowed[from_][msg.sender], value_);
        _transfer(from_, to_, value_);
        return true;
    }

    function allowance(address owner_, address spender_) external override view returns (uint256) {
        return _allowed[owner_][spender_];
    }

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    function _bound(address superior_, address junior_) internal {
        if (
            superior_ != junior_ &&
            !isContract(superior_) &&
            !isContract(junior_) &&
            superior_ != address(0) &&
            junior_ != address(0) &&
            _superiorAddress[junior_] == address(0) &&
            junior_ != _firstSuper
        ) {
            _superiorAddress[junior_] = superior_;
            _juniorsAddress[superior_].push(junior_);
            emit Bound(superior_, junior_);
        }
    }

    function getSuperior(address user_) external view returns(address) {
        return _superiorAddress[user_];
    }

    function getJuniors(address user_) external view returns(address[] memory) {
        return _juniorsAddress[user_];
    }


    
}