pragma solidity 0.5.0;

import "./ERC20Pausable.sol";
import "./ERC20Detailed.sol";
import "./ERC20VestingCrowdsale.sol";

/**
  @title InveCoin
  @dev Token of the Investoland project.
  Has vesteable tokens, a crowdsale and is paused during the crowdsale.
 */
contract InveCoin is ERC20Detailed, ERC20Pausable, ERC20VestingCrowdsale {

  constructor(uint256 presaleVestingTimestamp, uint256 crowdsaleVestingTimestamp)
    ERC20VestingCrowdsale(presaleVestingTimestamp, crowdsaleVestingTimestamp)
    ERC20Detailed("Invecoin", "INV", 18)
    public {
    // empty constructor
  }

  function finishCrowdsale() public {
    super.finishCrowdsale();
  }

  function setCrowdsale(address crowdsale) public  {
    super.setCrowdsale(crowdsale);
  }
}