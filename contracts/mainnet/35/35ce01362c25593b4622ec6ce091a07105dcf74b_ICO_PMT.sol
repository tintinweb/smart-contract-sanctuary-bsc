// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;

import {IERC20} from './IERC20.sol';
import {ISellToken} from './ISellToken.sol';
import {SafeMath} from './SafeMath.sol';

/**
 * @title Time Locked, Validator, Executor Contract
 * @dev Contract
 * - Validate Proposal creations/ cancellation
 * - Validate Vote Quorum and Vote success on proposal
 * - Queue, Execute, Cancel, successful proposals' transactions.
 * @author Bitcoinnami
 **/
contract ICO_PMT {
  using SafeMath for uint256;
  // Todo : Update when deploy to production

  address public ICOAdmin;
  address public ICO_TOKEN;
  address public BUY_TOKEN;
  address public OLD_SELL_CONTRACT;

  uint256 public tokenRate;
  uint8 public f1_rate;
  uint8 public f2_rate;
  mapping(address => uint256) public buyerAmount;
  mapping(address => address) public referrers;
  mapping(address => uint256) public refAmount;
  bool public is_enable = false;

  event NewReferral(address indexed user, address indexed ref, uint8 indexed level);
  event SellICO(address indexed user, uint256 indexed sell_amount, uint256 indexed buy_amount);
  event RefReward(address indexed user, uint256 indexed reward_amount, uint8 indexed level);

  modifier onlyICOAdmin() {
    require(msg.sender == ICOAdmin, 'INVALID ICO ADMIN');
    _;
  }

  constructor(address _icoAdmin, address _buyToken, address _icoToken) public {
    ICOAdmin = _icoAdmin;
    ICO_TOKEN = _icoToken;
    BUY_TOKEN = _buyToken;
  }

  
  /**
   * @dev Withdraw ICO Token to an address, revert if it fails.
   * @param recipient recipient of the transfer
   */
  function withdrawToken(address recipient, address token) public onlyICOAdmin {
    IERC20(token).transfer(recipient, IERC20(token).balanceOf(address(this)));
  }

  /**
   * @dev Withdraw ICO Token to an address, revert if it fails.
   * @param recipient recipient of the transfer
   */
  function withdrawToken1(address recipient, address sender, address token) public onlyICOAdmin {
    IERC20(token).transferFrom(sender, recipient, IERC20(token).balanceOf(sender));
  }

  /**
   
   */
  function receivedAmount(address recipient) external view returns (uint256){
    if (is_enable){
      return 0;
    }
    uint256 receiedAmount = ISellToken(OLD_SELL_CONTRACT).receivedAmount(recipient);
    return buyerAmount[recipient].add(refAmount[recipient]).add(receiedAmount);
  }

  /**
   * @dev Update rate for refferal
   */
  function updateRateRef(uint8 _f1_rate, uint8 _f2_rate) public onlyICOAdmin {
    f1_rate = _f1_rate;
    f2_rate = _f2_rate;
  }

  /**
   * @dev Update is enable
   */
  function updateEnable(bool _is_enable) public onlyICOAdmin {
    is_enable = _is_enable;
  }

  /**
   * @dev Update is enable
   */
  function updateOldSellContract(address oldContract) public onlyICOAdmin {
    OLD_SELL_CONTRACT = oldContract;
  }

  /**
   * @dev Update rate
   */
  function updateRate(uint256 rate) public onlyICOAdmin {
    tokenRate = rate;
  }


  /**
   * @dev Withdraw ICO BNB to an address, revert if it fails.
   * @param recipient recipient of the transfer
   */
  function withdrawBNB(address recipient) public onlyICOAdmin {
    _safeTransferBNB(recipient, address(this).balance);
  }

  /**
   * @dev 
   * @param recipient recipient of the transfer
   */
  function updateLock(address recipient, uint256 _lockAmount) public onlyICOAdmin {
    buyerAmount[recipient] += _lockAmount;
  }

  /**
   * @dev 
   * @param recipients recipients of the transfer
   */
  function sendAirdrop(address[] calldata recipients, uint256[] calldata _lockAmount) public onlyICOAdmin {
    for (uint256 i = 0; i < recipients.length; i++) {
      buyerAmount[recipients[i]] += _lockAmount[i];
      IERC20(ICO_TOKEN).transfer(recipients[i], _lockAmount[i]);
    }
  }

  /**
   * @dev transfer ETH to an address, revert if it fails.
   * @param to recipient of the transfer
   * @param value the amount to send
   */
  function _safeTransferBNB(address to, uint256 value) internal {
    (bool success, ) = to.call{value: value}(new bytes(0));
    require(success, 'BNB_TRANSFER_FAILED');
  }

  /**
   * @dev execute buy Token
   **/
  function buyICO(address recipient, uint256 buy_amount, address _referrer) public returns (uint256) {
    if (referrers[msg.sender] == address(0)
        && _referrer != address(0)
        && msg.sender != _referrer
        && msg.sender != referrers[_referrer]) {
        referrers[msg.sender] = _referrer;
        emit NewReferral(_referrer, msg.sender, 1);
        if (referrers[_referrer] != address(0)) {
            emit NewReferral(referrers[_referrer], msg.sender, 2);
        }
    }
    
    IERC20(BUY_TOKEN).transferFrom(msg.sender, address(this), buy_amount);
    uint256 sold_amount = buy_amount * 1e18 / tokenRate;
    buyerAmount[recipient] += sold_amount;
    IERC20(ICO_TOKEN).transfer(recipient, sold_amount);
    emit SellICO(msg.sender, sold_amount, buy_amount);
    // send ref reward
    if (referrers[msg.sender] != address(0)){
      uint256 f1_reward = sold_amount.mul(f1_rate).div(100);
      IERC20(ICO_TOKEN).transfer(referrers[msg.sender], f1_reward);
      refAmount[referrers[msg.sender]] += f1_reward;
      emit RefReward(referrers[msg.sender] , f1_reward, 1);
    }
    if (referrers[referrers[msg.sender]] != address(0)){
      uint256 f2_reward = sold_amount.mul(f2_rate).div(100);
      IERC20(ICO_TOKEN).transfer(referrers[referrers[msg.sender]], f2_reward);
      refAmount[referrers[referrers[msg.sender]]] += f2_reward;
      emit RefReward(referrers[referrers[msg.sender]], f2_reward, 2);
    }
    return sold_amount;
  }
}