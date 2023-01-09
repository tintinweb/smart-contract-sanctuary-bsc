/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.5.16;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract swap {
    IBEP20 _vizadd;
    IBEP20 _viuadd;
    IBEP20 _bnbadd;
    address public _owner;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;

constructor (address _viz, address _viu, address _bnb) public {
      _vizadd = IBEP20(_viz);
      _viuadd = IBEP20(_viu);
      _bnbadd = IBEP20(_bnb);
      _owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _owner = newOwner;
    }

    modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }

    function internaln(address _add, string memory _val) internal view returns (string memory) {
        _val = IBEP20(_add).symbol();
        return _val;
    }

    function Swapfrombnb(uint256 _amount, address _add, string memory _case) public returns (bool) {
        require(keccak256(bytes(_case)) == keccak256(bytes("VIZ")) || keccak256(bytes(_case)) == keccak256(bytes("VIU")), "BEP20: please input carefully");
        internalapprove(_amount);
        _bnbadd.transferFrom(msg.sender, address(this), _amount);
        _case = internaln(_add, _case);
        if (keccak256(bytes(_case)) == keccak256(bytes("VIZ"))) {
            _vizadd.transfer(msg.sender, _amount);
        }
        else if (keccak256(bytes(_case)) == keccak256(bytes("VIU"))) {
            _viuadd.transfer(msg.sender, _amount);
        }
        return true;
    }

    function Swapfromviz(uint256 _amount, address _add, string memory _case) public returns (bool) {
        require(keccak256(bytes(_case)) == keccak256(bytes("VIU")) || keccak256(bytes(_case)) == keccak256(bytes("WBNB")), "BEP20: please input carefully");
        internalapprove(_amount);
        _vizadd.transferFrom(msg.sender, address(this), _amount);
        _case = internaln(_add, _case);
        if (keccak256(bytes(_case)) == keccak256(bytes("VIU"))) {
            _viuadd.transfer(msg.sender, _amount);
        }
        else if (keccak256(bytes(_case)) == keccak256(bytes("WBNB"))) {
            _bnbadd.transfer(msg.sender, _amount);
        }
        return true;
    }

    function Swapfromviu(uint256 _amount, address _add, string memory _case) public returns (bool) {
        require(keccak256(bytes(_case)) == keccak256(bytes("VIZ")) || keccak256(bytes(_case)) == keccak256(bytes("WBNB")), "BEP20: please input carefully");
        internalapprove(_amount);
        _viuadd.transferFrom(msg.sender, address(this), _amount);
        _case = internaln(_add, _case);
        if (keccak256(bytes(_case)) == keccak256(bytes("VIZ"))) {
            _vizadd.transfer(msg.sender, _amount);
        }
        else if (keccak256(bytes(_case)) == keccak256(bytes("WBNB"))) {
            _bnbadd.transfer(msg.sender, _amount);
        }
        return true;
    }

    function retrivtokentoOwner(address _add, uint256 _amount) public onlyOwner {
        IBEP20(_add).transfer(msg.sender, _amount);
    }

    function internalapprove(uint256 _amount) public {
        _viuadd.approve(msg.sender, _amount);
        _viuadd.allowance(msg.sender, address(this));
        _allowances[msg.sender][address(this)] += _amount;
    }
}