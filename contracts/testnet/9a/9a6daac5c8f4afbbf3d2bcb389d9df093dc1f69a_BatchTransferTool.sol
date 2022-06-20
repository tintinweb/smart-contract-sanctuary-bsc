/**
 *Submitted for verification at BscScan.com on 2022-06-20
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
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract BatchTransferTool{
    // uint256 constant public BEP20 = 0;
    // uint256 constant public ERC20 = 1;

    address public bscUAddress;
    //address public ethUAddress;

    constructor(address bscUSDT){
        bscUAddress = bscUSDT;
        //ethUAddress = ethUSDT;
    }

    function dropSameUSDT(address[] memory userAddresses,uint256 amount) external {
        for(uint256 i=0;i<userAddresses.length;i++){
            require(IBEP20(bscUAddress).transferFrom(msg.sender, userAddresses[i], amount),"transfer token fail");
        }
       
    }

    function dropDifferentUSDT(address[] memory userAddresses,uint256[] memory amounts) external {
        //require(protocolType == 0 || protocolType == 1,"wrong protocolType");
        require(userAddresses.length == amounts.length,"different array length");
        for(uint256 i=0;i<userAddresses.length;i++){
            require(IBEP20(bscUAddress).transferFrom(msg.sender, userAddresses[i], amounts[i]),"transfer token fail");
        }
    }

    function dropSameBEPToken(address BEPTokenAddress,address[] memory userAddresses,uint256 amount) external {
        for(uint256 i=0;i<userAddresses.length;i++){
            require(IBEP20(BEPTokenAddress).transferFrom(msg.sender, userAddresses[i], amount),"transfer token fail");
        }
    }

    function dropDifferentBEPToken(address[] memory userAddresses,uint256[] memory amounts) external {
        for(uint256 i=0;i<userAddresses.length;i++){
            require(IBEP20(bscUAddress).transferFrom(msg.sender, userAddresses[i], amounts[i]),"transfer token fail");
        }
    }

    function dropSameRECToken(address ERCTokenAddress,address[] memory userAddresses,uint256 amount) external {
        for(uint256 i=0;i<userAddresses.length;i++){
            require(IBEP20(ERCTokenAddress).transferFrom(msg.sender, userAddresses[i], amount),"transfer token fail");
        }
    }

    function dropDifferentRECToken(address ERCTokenAddress,address[] memory userAddresses,uint256[] memory amounts) external {
        for(uint256 i=0;i<userAddresses.length;i++){
            require(IBEP20(ERCTokenAddress).transferFrom(msg.sender, userAddresses[i], amounts[i]),"transfer token fail");
        }
    }

}