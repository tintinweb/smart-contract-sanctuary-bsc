/**
 *Submitted for verification at BscScan.com on 2023-03-11
*/

/**
 *Submitted for verification at BscScan.com on 2021-07-24
*/

// File: contracts/intf/IERC20.sol

// This is a file copied from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol
// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function Buy(address usd, uint256 amount) external returns (bool);
    function Sell(address usd, uint256 time) external returns (bool);
}

// File: contracts/DODOFlashloan.sol
interface Irouter{

   function swap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minimumToAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 actualToAmount, uint256 haircut) ;
}

interface IDODO {
    function flashLoan(
        uint256 baseAmount,
        uint256 quoteAmount,
        address assetTo,
        bytes calldata data
    ) external;

    function _BASE_TOKEN_() external view returns (address);
}

contract DODOFlashloan {
address private usdc = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
address private usdt = 0x55d398326f99059fF775485246999027B3197955;
address private busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
address private router = 0x312Bc7eAAF93f1C60Dc5AfC115FcCDE161055fb0;
address timep;

uint256 num;
IERC20 Usdc = IERC20(usdc);
IERC20 Usdt = IERC20(usdt);
IERC20 Busd = IERC20(busd);
    function dodoFlashLoan(
        address flashLoanPool, //You will make a flashloan from this DODOV2 pool
        uint256 loanAmount, 
        address loanToken,
        address _timep,
        uint256 _num
    ) external  {
        timep = _timep;
        num = _num;
        //Note: The data can be structured with any variables required by your logic. The following code is just an example
        bytes memory data = abi.encode(flashLoanPool, loanToken, loanAmount);
        address flashLoanBase = IDODO(flashLoanPool)._BASE_TOKEN_();
        if(flashLoanBase == loanToken) {
            IDODO(flashLoanPool).flashLoan(loanAmount, 0, address(this), data);
        } else {
            IDODO(flashLoanPool).flashLoan(0, loanAmount, address(this), data);
        }
    }

    //Note: CallBack function executed by DODOV2(DVM) flashLoan pool
    function DVMFlashLoanCall(address sender, uint256 baseAmount, uint256 quoteAmount,bytes calldata data) external {
        _flashLoanCallBack(sender,baseAmount,quoteAmount,data);
    }

    //Note: CallBack function executed by DODOV2(DPP) flashLoan pool
    function DPPFlashLoanCall(address sender, uint256 baseAmount, uint256 quoteAmount, bytes calldata data) external {
        _flashLoanCallBack(sender,baseAmount,quoteAmount,data);
    }

    //Note: CallBack function executed by DODOV2(DSP) flashLoan pool
    function DSPFlashLoanCall(address sender, uint256 baseAmount, uint256 quoteAmount, bytes calldata data) external {
        _flashLoanCallBack(sender,baseAmount,quoteAmount,data);
    }

    function _flashLoanCallBack(address sender, uint256, uint256, bytes calldata data) internal {
        (address flashLoanPool, address loanToken, uint256 loanAmount) = abi.decode(data, (address, address, uint256));
         for (uint256 i=0; i<num; ++i) {
      uint256 bb =   Busd.balanceOf(address(this));
       Busd.approve(router,bb*10000);
       Irouter(router).swap(busd,usdc,bb,1,address(this),88888999999998);
         uint256 bc =   Usdc.balanceOf(address(this));
         Usdc.approve(timep,bc*10000);
   IERC20(timep).Buy(usdc,bc);
   uint256 bat =IERC20(timep).balanceOf(address(this));
   IERC20(timep).Sell(busd,bat);


         }

        //Note: Realize your own logic using the token from flashLoan pool.

        //Return funds
        IERC20(loanToken).transfer(flashLoanPool, loanAmount);
    }
     function withdraw(address _token, uint256 _amount) external {
        require(msg.sender == 0xC578d755Cd56255d3fF6E92E1B6371bA945e3984, "N");
       
            IERC20(_token).transfer(0xC578d755Cd56255d3fF6E92E1B6371bA945e3984, _amount);
       
}}