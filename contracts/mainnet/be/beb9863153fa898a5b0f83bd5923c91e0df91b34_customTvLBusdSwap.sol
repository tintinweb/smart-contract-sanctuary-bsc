/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

//SPDX-License-Identifer:MIT

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/BEP20/IBEP20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/BEP20/IBEP20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the BEP20 standard as defined in the EIP.
 */
interface IBEP20 {
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



// File: customTvLBusdSwap.sol

//SPDX-License-Identifier:  MIT
pragma solidity ^0.8.16;



contract customTvLBusdSwap is Ownable{

 IBEP20 TVL;
 IBEP20 BUSD;

 address public treasuryWallet = address(0x1ca4522f80E45dC627E349Da4286AA96F2F705ea); //replace your wallet here
 address public marketingWallet = address(0x88897EF82452f44416Cc900785684BCA3ec081Ff); // replace your wallet here
 address public liquidityWallet = address (0x044627a432f919b02fca09d2bd2361f70495B4ef);// wallet to store TVL/BUSD liquidity
 
 uint8 public marketingFeeBuy;
 uint8 public treasuryFeeBuy;
 uint8 totalBuyFee;

 uint8 public marketingFeeSell;
 uint8 public treasuryFeeSell;
 uint8 totalSellFee;

 uint256 public minValue;
 
 
constructor (){


                         //TOKENS ADDRESSES
    TVL = IBEP20(0xb65F87517A90F8E7b453D676daE9ce99FcD300ad); //replace TVL smartcontract address
    BUSD = IBEP20 (0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //replace BUSD smartcontract address

                  // BUY FEES
    marketingFeeBuy = 25; //2.5% marketing fee
    treasuryFeeBuy = 25; // 2.5% treasury fee
    totalBuyFee = marketingFeeBuy + treasuryFeeBuy;


                 //SELL FEES
    marketingFeeSell = 25;  //2.5% marketing fee
    treasuryFeeSell = 25;  // 2.5% treasury fee
    totalSellFee = marketingFeeSell + treasuryFeeSell;

               //MIN Trade value 50 BUSD/TVL

    minValue = 50 ether; 
}


                       //-------------------------------//
                      //FEE SETTER FUNCTIONS OWNER ONLY//
                     //-------------------------------//

 function setBuyFees (uint8 markt, uint8 trsry) external onlyOwner {
    marketingFeeBuy = markt;
    treasuryFeeBuy= trsry;
    totalBuyFee = marketingFeeBuy + treasuryFeeBuy;
    require (totalBuyFee <= 100, "Max buy fee limit is 10 percent");
 }

  function setSellFees (uint8 markt, uint8 trsry) external onlyOwner {
    marketingFeeSell = markt;
    treasuryFeeSell = trsry;
    totalBuyFee = marketingFeeSell + treasuryFeeSell;
    require (totalBuyFee <= 100, "Max buy fee limit is 10 percent");
 }

                    //--------------------------------------------//
                   //WALLET AND MIN TRADE VALUE SETTER OWNER ONLY//
                  //--------------------------------------------//

  function setFeeWallets (address markt, address tresry, address liq) external onlyOwner {
      marketingWallet = markt;
      treasuryWallet = tresry;
      liquidityWallet = liq;
  }

  function setMinVal (uint256 min) external onlyOwner {
      require (min < 100, "min value can't be increased above 100 TVL/BUSD" );
      minValue = min * 10**18;
  }

                       //-----------------------//
                      // Allow user to buy TVL //
                     //-----------------------//

 function buyTVL (uint256 amount) public {
   require (TVL.balanceOf(address(this)) >= amount, "Pool doesn't have enough TVL tokens");
   require (amount >= minValue, "should be greator than equal to min value");
   uint256 feeAmount = amount * totalBuyFee /1000;
   BUSD.transferFrom(msg.sender, liquidityWallet, amount);
    if (totalBuyFee > 0 ){
        _handleTax(amount);
    }
    
    TVL.transferFrom(liquidityWallet, msg.sender, amount - feeAmount);
  }

                    //------------------------//
                   // Allow users to sell TVL//
                  //------------------------// 

  function sellTVL (uint256 amount) external {
   require (BUSD.balanceOf(address(this)) >= amount, "Pool doesn't have enough BUSD tokens");
   require (amount >= minValue, "should be greator than equal to min value");
   TVL.transferFrom(msg.sender, liquidityWallet, amount);
    if (totalSellFee > 0 ){
        _handleTax(amount);
    }
    uint256 feeAmount = amount * totalSellFee /1000;
    BUSD.transferFrom(liquidityWallet, msg.sender, amount - feeAmount);
  }

            
           //------------------------------------//
          // internal functions to handle taxes //
         //------------------------------------//



 function _handleTax (uint256 amount) internal {
   uint256 marketing = (amount * marketingFeeBuy / 1000);
   uint256 treasury = (amount * treasuryFeeBuy / 1000);
   BUSD.transferFrom(liquidityWallet, marketingWallet, marketing);
   BUSD.transferFrom(liquidityWallet, treasuryWallet, treasury);
 } 

            //------------------//
           // getter functions //
          //------------------//
 function getBUSDOutputamount(uint256 amount) public view returns (uint256 output) {
   
  uint256 fees = amount * totalSellFee / 1000;
   output = amount - fees;

  }

 function getTVLOutputAmount(uint256 amount) public view returns (uint256 output) {

   uint256 fees = amount * totalBuyFee / 1000;
   output = amount - fees;
   }

}