// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./BEP20.sol";
import "./SafeMath.sol";
import "./Burnable.sol";
import "./AccessControl.sol";

contract DUSD is BEP20, Burnable, AccessControl {
  using SafeMath for uint256;

  string private _tokenName = "Decentralized USD";
  string private _tokenSymbol = "DUSD";
  uint8 private _decimals = 6;

  mapping(address => bool) private _lock;

  bytes32 public constant BURN_ROLE = keccak256("BURN_ROLE");
  bytes32 public constant LOCK_ROLE = keccak256("LOCK_ROLE");

  constructor() BEP20(_tokenName, _tokenSymbol) {
      _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  function grantBurnRole(address _account) public onlyRole(DEFAULT_ADMIN_ROLE) {
      require(_account != address(0), "DUSD: cannot grant role to zero address");

      _grantRole(BURN_ROLE, _account);
  }

  function revokeBurnRole(address _account) public onlyRole(DEFAULT_ADMIN_ROLE) {
      require(hasRole(BURN_ROLE, _account), "DUSD: unauthorized address");

      _revokeRole(BURN_ROLE, _account);
  }

  function grantLockRole(address _account) public onlyRole(DEFAULT_ADMIN_ROLE) {
      require(_account != address(0), "DUSD: cannot grant role to zero address");

      _grantRole(LOCK_ROLE, _account);
  }

  function revokeLockRole(address _account) public onlyRole(DEFAULT_ADMIN_ROLE) {
      require(hasRole(LOCK_ROLE, _account), "DUSD: unauthorized address");

      _revokeRole(LOCK_ROLE, _account);
  }

  function mint(address _account, uint256 _amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
      require(_amount > 0, "DUSD: cannot mint zero");

      _mint(_account, _amount);
  }

  function burn(uint256 _amount) public override onlyRole(BURN_ROLE) {
      require(_amount > 0, "DUSD: cannot burn zero");

      uint256 balance = balanceOf(msg.sender);
      
      require(_amount <= balance, "DUSD: exceeded wallet balance");

      _burn(msg.sender, _amount);
  }

  function lockAddress(address account) public onlyRole(LOCK_ROLE) {
      _lock[account] = true;
  }

  function unlockAddress(address account) public onlyRole(LOCK_ROLE) {
      _lock[account] = false;
  }

  function transfer(address to, uint256 amount) public virtual override returns (bool) {
      require(_lock[msg.sender] != true, "DUSD: account locked");

      _transfer(msg.sender, to, amount);
      return true;
  }

  function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        require(_lock[msg.sender] != true, "DUSD: account locked");

        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }

  function decimals() public view virtual override returns (uint8) {
      return _decimals;
  }
}