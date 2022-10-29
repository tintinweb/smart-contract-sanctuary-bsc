/**
 *Submitted for verification at BscScan.com on 2022-10-29
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


contract ETTS is ERC20 {
    string private _name = "ETTS Token";
    string private _symbol = "ETTS";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 100000000 * (10**_decimals);
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowed;


    constructor() {
        _balances[msg.sender] = _totalSupply;
    }

    function name() public override view returns (string memory) {
        return _name;
    }


    function symbol() public override view returns (string memory) {
        return _symbol;
    }


    function decimals() public override view returns (uint8) {
        return _decimals;
    }


    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address address_) public override view returns (uint256) {
        return _balances[address_];
    }


    function _transfer(address from_, address to_, uint256 value_) private {
        _balances[from_] = SafeMath.sub(_balances[from_], value_);
        _balances[to_] = SafeMath.add(_balances[to_], value_);
        emit Transfer(from_, to_, value_);
    }


    function transfer(address to_, uint256 value_) public override returns (bool) {
        _transfer(msg.sender, to_, value_);
        return true;
    }


    function approve(address spender_, uint256 amount_) public override returns (bool) {
        _allowed[msg.sender][spender_] = amount_;
        emit Approval(msg.sender, spender_, amount_);
        return true;
    }


    function transferFrom(address from_, address to_, uint256 value_) public override returns (bool) {
        _allowed[from_][msg.sender] = SafeMath.sub(_allowed[from_][msg.sender], value_);
        _transfer(from_, to_, value_);
        return true;
    }


    function allowance(address owner_, address spender_) public override view returns (uint256) {
        return _allowed[owner_][spender_];
    }
   
}