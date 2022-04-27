/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

pragma solidity ^0.8.13;
// SPDX-License-Identifier: UNLICENSED
// Credit BalGu

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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

contract HYPEFEGMarketingFaucet{
    bool  private _rentrenceLock = true;
    address public _claimer = 0x68f39eb24CD9759916E503bAbc51A399a82CB433;
    address private _activeTokenAddress = 0x9db2287bb8cf41Af6c269cD8147BeaeB8B997406;
    uint256 public _locked = 0;

    modifier onlyClaimers() {
        require(address(msg.sender) == _claimer, "Claimer: caller is not the allowed list of claimer");
        _;
    }
    modifier lock(){
        require(_rentrenceLock,"Reentrency protection hit");
        _rentrenceLock = false;
        _;
        _rentrenceLock = true;
    }

    function sync() external onlyClaimers{
        _locked  = IERC20(_activeTokenAddress).balanceOf(address(this));
    }

    
    function availableReflection() external view returns(uint256){
        return IERC20(_activeTokenAddress).balanceOf(address(this)) - _locked;
    }
    function getReflections() external lock onlyClaimers{
        uint256 amt = IERC20(_activeTokenAddress).balanceOf(address(this)) - _locked;
        bool xfer = IERC20(_activeTokenAddress).transfer(msg.sender, amt);
        require(xfer, "ERR_ERC20_FALSE");

    }

}