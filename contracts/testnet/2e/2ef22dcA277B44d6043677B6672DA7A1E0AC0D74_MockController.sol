// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

contract MockController {

  struct ValueConf {
    address oracle;
    uint16 dr;  // discount rate
    uint16 pr;  // premium rate
  }

  struct VaultState {
    bool enabled;
    bool enableDeposit;
    bool enableWithdraw;
    bool enableBorrow;
    bool enableRepay;
    bool enableLiquidate;
  }

  mapping(address => address) public dyTokens;
  mapping(address => address) public dyTokenVaults;
  mapping(address => ValueConf) internal valueConfs;
  mapping(address => VaultState) public vaultStates;

  function getValueConf(address _underlying) public view returns (address oracle, uint16 dr, uint16 pr) {
    ValueConf memory conf = valueConfs[_underlying];
    oracle = conf.oracle;
    dr = conf.dr;
    pr = conf.pr;
  }

  function setVault(address _dyToken, address _vault, uint vtype) external {
    dyTokenVaults[_dyToken] = _vault;
  }

  function setVaultStates(address _vault, VaultState memory _state) external {
    vaultStates[_vault] = _state;
  }

  function setOracles(address _underlying, address _oracle, uint16 _discound, uint16 _premium) external {
    ValueConf storage conf = valueConfs[_underlying];
    conf.oracle = _oracle;
    conf.dr = _discound;
    conf.pr = _premium;
  }

}