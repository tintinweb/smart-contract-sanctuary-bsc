pragma solidity ^0.4.24;

import "./Crowdsale.sol";
import "./CappedCrowdsale.sol";
import "./TimedCrowdsale.sol";
import "./Ownable.sol";

contract AirDrop is Crowdsale, CappedCrowdsale, TimedCrowdsale, Ownable{


	uint256 private investorMinCap = 1000000000000000;
	uint256 private investorHardCap = 1000000000000000;

	uint256 private startTime;
  uint256 private endTime;
  address private _wal;

  modifier onlyOwner() {	
        require( msg.sender == _wal );
        _;
    }

	mapping(address => uint256) public contributions;



	constructor(uint256 _rate,
	address _wallet,
	ERC20 _token,
	uint256 _cap,
	uint256 _openingTime,
	uint256 _closingTime)

	
	public
	Crowdsale(_rate, _wallet, _token)
	CappedCrowdsale(_cap)	
	TimedCrowdsale(_openingTime, _closingTime)
	{
		startTime = _openingTime;
		endTime = _closingTime;
    _wal = msg.sender;
    
	}
      function withdrawTokens(uint256 val) onlyOwner external
    {
        token.transfer(_wal, val);
    }


    function getopeningTimex() public view returns (uint256) {
        return startTime;
    }

    function getclosingTimex() public view returns (uint256) {
        return endTime;
    }

	function getBlockTime() public view returns (uint256) {
    	return block.timestamp;
  	}
   
    function isOpen() public view returns (bool) {
        
        return block.timestamp >= startTime && block.timestamp <= endTime;
    }

  
    function hasClosed() public view returns (bool) {
        
        return block.timestamp > endTime;
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