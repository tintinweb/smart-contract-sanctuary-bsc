/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract RedEnvelope {
    struct RedEnvelopeData {
        address owner;

        uint claimStartBlock;
        uint claimEndBlock;
        mapping (address => bool) whiteList;

        address tokenAddr;
        uint256 totalAmount;
        uint32 whiteListCnt;
    }

    address public admin;
    uint32 public redEnvelopeCnt;
    mapping (uint32 => RedEnvelopeData) public redEnvelopes;
    
    constructor() {
        admin = msg.sender;
        redEnvelopeCnt = 0;
    }

    function createNewRedEnvelope(uint claimDelayBlocks, uint claimLastBlocks, address tokenAddr) public returns (uint32 redEnvelopeId) {
        uint claimStartBlock = block.number + claimDelayBlocks;
        uint claimEndBlock = claimStartBlock + claimLastBlocks;

        redEnvelopeId = redEnvelopeCnt++;
        RedEnvelopeData storage newRedEnvelope = redEnvelopes[redEnvelopeId];
        newRedEnvelope.owner = msg.sender;
        newRedEnvelope.claimStartBlock = claimStartBlock;
        newRedEnvelope.claimEndBlock = claimEndBlock;
        newRedEnvelope.tokenAddr = tokenAddr;
        newRedEnvelope.totalAmount = 0;
        newRedEnvelope.whiteListCnt = 0;
    }

    function deposit(uint32 redEnvelopeId, uint256 amount) public {
        RedEnvelopeData storage redEnvelope = redEnvelopes[redEnvelopeId];
        require(block.number < redEnvelope.claimStartBlock);
        require(IBEP20(redEnvelope.tokenAddr).transferFrom(msg.sender, address(this), amount));
        redEnvelope.totalAmount += amount;
    }

    function updateWhiteList(uint32 redEnvelopeId, address user, bool claimbale) public {
        RedEnvelopeData storage redEnvelope = redEnvelopes[redEnvelopeId];
        require(msg.sender == redEnvelope.owner && block.number < redEnvelope.claimStartBlock);
        if (redEnvelope.whiteList[user] != claimbale) {
            redEnvelope.whiteList[user] = claimbale;
            if (claimbale) {
                redEnvelope.whiteListCnt += 1;
            } else {
                redEnvelope.whiteListCnt -= 1;
            }
        }
    }

    function claim(uint32 redEnvelopeId) public {
        RedEnvelopeData storage redEnvelope = redEnvelopes[redEnvelopeId];
        require(redEnvelope.whiteList[msg.sender] && block.number >= redEnvelope.claimStartBlock && block.number < redEnvelope.claimEndBlock);

        uint256 each = redEnvelope.totalAmount / redEnvelope.whiteListCnt;

        redEnvelope.whiteList[msg.sender] = false;
        redEnvelope.whiteListCnt -= 1;
        redEnvelope.totalAmount -= each;

        require(IBEP20(redEnvelope.tokenAddr).transfer(msg.sender, each));
    }


    function refund(uint32 redEnvelopeId) public {
        RedEnvelopeData storage redEnvelope = redEnvelopes[redEnvelopeId];
        require(block.number >= redEnvelope.claimEndBlock);
        require(IBEP20(redEnvelope.tokenAddr).transfer(redEnvelope.owner, redEnvelope.totalAmount));
    }
}