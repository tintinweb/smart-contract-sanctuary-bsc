pragma solidity ^0.4.23;


import "./Crowdsale.sol";
import "./CappedCrowdsale.sol";

contract ExampleTokenCrowdsale is Crowdsale, CappedCrowdsale{

	uint256 public investorMinCap   = 10000000000000000;
	uint256 public investorHardCap  = 500000000000000000;

	mapping(address => uint256) public contributions;

	constructor(uint256 _rate,
	  address _wallet,
	  ERC20 _token,
	  uint256 _cap)
	Crowdsale(_rate, _wallet, _token)
	CappedCrowdsale(_cap)
	public{
	}


  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
    uint256 _existingContribution = contributions[_beneficiary];
    uint256 _newContribution = _existingContribution.add(_weiAmount);
    require(_newContribution >= investorMinCap && _newContribution <= investorHardCap);
	contributions[_beneficiary] = _newContribution;
  }
  
}