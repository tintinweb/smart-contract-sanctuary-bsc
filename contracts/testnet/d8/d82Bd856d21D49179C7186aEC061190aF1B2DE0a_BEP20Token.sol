/**
 *Submitted for verification at BscScan.com on 2022-07-24
*/

// SPDX-License-Identifier: Unlicensed

/**
 *Submitted for verification at BscScan.com on 2021-07-21
*/

pragma solidity ^0.8.0;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
}

abstract contract Context {
  function _msgSender() internal view virtual returns (address) { return msg.sender; }
  function _msgData() internal view virtual returns (bytes calldata) { return msg.data; }
}

contract ERC20 is Context, IERC20, IERC20Metadata {

  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply;
  string private _name;
  string private _symbol;

  constructor(string memory name_, string memory symbol_) {
    _name = name_;
    _symbol = symbol_;
  }

  function name() public view virtual override returns (string memory) {
    return _name;
  }

  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  function decimals() public view virtual override returns (uint8) {
    return 18;
  }

  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view virtual override returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public virtual override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(
      address sender,
      address recipient,
      uint256 amount
      ) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);

    uint256 currentAllowance = _allowances[sender][_msgSender()];
    require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    unchecked {
      _approve(sender, _msgSender(), currentAllowance - amount);
    }

    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    uint256 currentAllowance = _allowances[_msgSender()][spender];
    require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
      _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }

    return true;
  }

  function _transfer(
      address sender,
      address recipient,
      uint256 amount
      ) internal virtual {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");

    _beforeTokenTransfer(sender, recipient, amount);

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
      _balances[sender] = senderBalance - amount;
    }
    _balances[recipient] += amount;

    emit Transfer(sender, recipient, amount);

    _afterTokenTransfer(sender, recipient, amount);
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
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
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
}

contract BEP20Token is ERC20 {

  uint8 private _decimals;
  uint256 private _chainId;

  address[] private _authorityAddresses;
  uint256 private _authorityThreshold;
  uint256 private _minBurnAmount;
  uint256 private _configurationNonce;

  mapping (address => mapping(string => uint256)) private _mintHistory;
  mapping (address => uint256) private _mintNonce;
  mapping (address => uint256[]) private _burnAmount;
  mapping (address => string[]) private _burnDestination;

  constructor() ERC20("Wrapped Dingocoin", "wDingocoin") {
    _decimals = 8;
    _chainId = 56;

    _authorityAddresses = [
      0x3B098ED6165AF1Baeee57c0fcdd3386230621209
    ];
    _authorityThreshold = 3;
    _minBurnAmount = 1000000000;
    _configurationNonce = 0;

  }

  function decimals() override public view returns (uint8) {
    return _decimals;
  }

  function _verifyAuthority(bytes32 dataHash, uint8[] calldata signV, bytes32[] calldata signR, bytes32[] calldata signS) private view {
    bytes32 prefixedHash = keccak256(abi.encodePacked(bytes("\x19Ethereum Signed Message:\n32"), dataHash));
    uint256 signatures = 0;
    for (uint256 i = 0; i < _authorityAddresses.length; i++) {
      if (ecrecover(prefixedHash, signV[i], signR[i], signS[i]) == _authorityAddresses[i]) {
        signatures++;
      }
      if (signatures >= _authorityThreshold) {
        break;
      }
    }
    require(signatures >= _authorityThreshold);
  }

  function authorityAddresses() external view returns (address[] memory) {
    return _authorityAddresses;
  }

  function authorityThreshold() external view returns (uint256) {
    return _authorityThreshold;
  }

  function minBurnAmount() external view returns (uint256) {
    return _minBurnAmount;
  }

  function configurationNonce() external view returns (uint256) {
    return _configurationNonce;
  }

  function configure(address[] calldata newAuthorityAddresses, uint256 newAuthorityThreshold, uint256 newMinBurnAmount,
      uint8[] calldata signV, bytes32[] calldata signR, bytes32[] calldata signS) external {

    require(newAuthorityAddresses.length >= 1);
    require(newAuthorityThreshold >= 1);
    require(signV.length == _authorityAddresses.length);
    require(signR.length == _authorityAddresses.length);
    require(signS.length == _authorityAddresses.length);

    _verifyAuthority(
        keccak256(abi.encode(_chainId, _configurationNonce, newAuthorityAddresses, newAuthorityThreshold, newMinBurnAmount)),
        signV, signR, signS);

    _configurationNonce++;
    _authorityAddresses = newAuthorityAddresses;
    _authorityThreshold = newAuthorityThreshold;
    _minBurnAmount = newMinBurnAmount;
  }

  function mintNonce(address addr) external view returns (uint256) {
    return _mintNonce[addr];
  }

  function mintHistory(address addr, string calldata depositAddress) external view returns (uint256, uint256) {
    return (_mintNonce[addr], _mintHistory[addr][depositAddress]);
  }

  function mint(string calldata depositAddress, uint256 amount,
      uint8[] calldata signV, bytes32[] calldata signR, bytes32[] calldata signS) external {
    require(signV.length == _authorityAddresses.length);
    require(signR.length == _authorityAddresses.length);
    require(signS.length == _authorityAddresses.length);

    _verifyAuthority(
        keccak256(abi.encode(_chainId, _msgSender(), _mintNonce[_msgSender()], depositAddress, amount)),
        signV, signR, signS);

    _mint(_msgSender(), amount);
    _mintNonce[_msgSender()]++;
    _mintHistory[_msgSender()][depositAddress] += amount;
  }

  function burnHistory(address addr) external view returns (string[] memory, uint256[] memory) {
    require(_burnDestination[addr].length == _burnAmount[addr].length);
    return (_burnDestination[addr], _burnAmount[addr]);
  }

  function burnHistory(address addr, uint256 index) external view returns (string memory, uint256) {
    require(_burnDestination[addr].length == _burnAmount[addr].length);
    return (_burnDestination[addr][index], _burnAmount[addr][index]);
  }

  function burnHistoryMultiple(address[] calldata addrs, uint256[] calldata indexes) external view returns (string[] memory, uint256[] memory) {
    require(addrs.length == indexes.length);
    string[] memory destinations = new string[](addrs.length);
    uint256[] memory amounts= new uint256[](addrs.length);
    for (uint256 i = 0; i < addrs.length; i++) {
      destinations[i] = _burnDestination[addrs[i]][indexes[i]];
      amounts[i] = _burnAmount[addrs[i]][indexes[i]];
    }
    return (destinations, amounts);
  }

  function burn(uint256 amount, string calldata destination) external {
    require(amount >= _minBurnAmount);
    _burn(_msgSender(), amount);
    _burnAmount[_msgSender()].push(amount);
    _burnDestination[_msgSender()].push(destination);
  }
}