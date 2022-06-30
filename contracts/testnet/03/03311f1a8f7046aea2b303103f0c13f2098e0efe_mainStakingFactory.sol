/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint256);

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

interface BNBForBNB{
    function createBNBForBNB(address ownerAddress, uint256 _apy, uint256 _earlyUstakeFee, address _rewardingTokenWallet, uint256 _lockPeriod, uint256 _maxReward, uint256 _earlyRewardUstakeFee, bool autoCompund) external returns (address);
}

interface BNBForTOKEN{
    function createBNBForToken(address ownerAddress, uint256 _apy, uint256 _earlyUstakeFee, IBEP20 _rewardingToken, address _rewardingTokenWallet, uint256 _lockPeriod, uint256 _maxReward, uint256 _earlyRewardUstakeFee, bool autoCompund) external returns (address);
}

interface TOKENForBNB{
    function createTokenForBNB(address ownerAddress, uint256 _apy, uint256 _earlyUstakeFee, IBEP20 _stakingToken, address _rewardingTokenWallet, uint256 _lockPeriod, uint256 _maxReward, uint256 _earlyRewardUstakeFee, bool autoCompund) external returns (address);
}

interface TOKENForTOKEN {
    function createTokenForToken(address ownerAddress, uint256 _apy, uint256 _earlyUstakeFee, IBEP20 _stakingToken, IBEP20 _rewardingToken, address _rewardingTokenWallet, uint256 _lockPeriod, uint256 _maxReward, uint256 _earlyRewardUstakeFee, bool autoCompund)  external returns (address);
}

contract mainStakingFactory{

    BNBForBNB public bnbForBnb;
    BNBForTOKEN public bnbForToken;
    TOKENForBNB public tokenForBnb;
    TOKENForTOKEN public tokenForToken;

    struct structBnbForBnb{
        uint256 _apy;
        address _rewardingTokenWallet;
        address ownerAddress;
        uint256 _earlyUnstakeFee;
        uint256 _lockPeriod;
        uint256 _maxReward;
        uint256 _earlyRewardUstakeFee;
        bool _autoCompund;
    }

    struct structBnbForToken{
        uint256 _apy;
        uint256 _lockPeriod;
        address _rewardingTokenWallet;
        uint256 _earlyUnstakeFee;
        uint256 _maxReward;
        uint256 _earlyRewardUstakeFee;
        IBEP20 _rewardingToken;
        address ownerAddress;
        bool _autoCompund;
    }

    struct structTokenForBnb{
        address ownerAddress;
        uint256 _apy;
        uint256 _lockPeriod;
        address _rewardingTokenWallet;
        uint256 _earlyUnstakeFee;
        uint256 _maxReward;
        uint256 _earlyRewardUstakeFee;
        IBEP20 _stakeToken;
        bool _autoCompund;
    }

    struct structTokenForToken{
        uint256 _apy;
        address ownerAddress;
        uint256 _earlyUnstakeFee;
        IBEP20 _stakingToken;
        IBEP20 _rewardingToken;
        address _rewardingTokenWallet;
        uint256 _lockPeriod;
        uint256 _maxReward;
        uint256 _earlyRewardUstakeFee;
        bool _autoCompund;
    }


    constructor(
        address _bnbForBnb,
        address _bnbForToken,
        address _tokenForBnb,
        address _tokenForToken
    ){
        bnbForBnb = BNBForBNB(_bnbForBnb);
        bnbForToken = BNBForTOKEN(_bnbForToken);
        tokenForBnb = TOKENForBNB(_tokenForBnb);
        tokenForToken = TOKENForTOKEN(_tokenForToken);
    }

    function  createBnbForBnb(structBnbForBnb memory _values) public returns (address){
       address addres = bnbForBnb.createBNBForBNB(_values.ownerAddress, _values._apy, _values._earlyUnstakeFee, _values._rewardingTokenWallet, _values._lockPeriod, _values._maxReward, _values._earlyRewardUstakeFee, _values._autoCompund);
       return addres;
    }

    function  createBnbForToken(structBnbForToken memory _values) public {
        bnbForToken.createBNBForToken(_values.ownerAddress, _values._apy, _values._earlyUnstakeFee, _values._rewardingToken, _values._rewardingTokenWallet, _values._lockPeriod, _values._maxReward, _values._earlyRewardUstakeFee, _values._autoCompund);
    }

    function  createTokenForBnb(structTokenForBnb memory _values) public {
        tokenForBnb.createTokenForBNB(_values.ownerAddress, _values._apy, _values._earlyUnstakeFee, _values._stakeToken, _values._rewardingTokenWallet, _values._lockPeriod, _values._maxReward, _values._earlyRewardUstakeFee, _values._autoCompund);
    }

    function  createTokenForToken(structTokenForToken memory _values) public{
        tokenForToken.createTokenForToken(_values.ownerAddress, _values._apy, _values._earlyUnstakeFee, _values._stakingToken, _values._rewardingToken, _values._rewardingTokenWallet, _values._lockPeriod, _values._maxReward, _values._earlyRewardUstakeFee, _values._autoCompund);
    }

}

// 0xfbB8b82106bd2CF921DB03371186f7a1b7A0981E
// 0x350FF497B2240cac53De58Df5a2BB396bb0452Cd
// 0xceca730a658B9cCdA446C1A627d0DD317Ad01ee2
// 0x978482caDfBCAe9f0dCD7FbAfcdaBb15748680ED

 //  temp  =(1 + (interestRate.div(100).div(timeStaked)))**(apyTier1.xdiv(100).mul(365));
             //  uint256 totalamount = principleAmount.mul(temp);