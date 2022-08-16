/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
contract bDogeBSCBridge {
    address public BEP20Doge=0xbA2aE424d960c26247Dd6c32edC70B295c744C43;
    IBEP20 public Doge = IBEP20(BEP20Doge);

    address public bDogeAddress = 0xF17d541415a9f5B36A9032eCA43B942600dba47E;
    address public owner=0x7650F39bA8D036b1f7C7b974a6b02aAd4B7F71F7;
    address public oracle=0x3e697f3373F1a2795996C090eFc2Cef08BcCbcb9;
    IBEP20 public bDoge = IBEP20(bDogeAddress);
    uint256 lockFee=0;
    uint256 oracleFee=2000000000000000;

    function getBDoge(uint256 amount) public{
        require(amount!=0);

        Doge.transferFrom(msg.sender,address(this),amount);
        bDoge.transfer(msg.sender,amount);
    }

    function getDoge(uint256 amount) public{
        require(amount!=0);

        bDoge.transferFrom(msg.sender,address(this),amount);
        Doge.transfer(msg.sender,amount);

    }


    function modifyOwner(address newowner) public{
        require(msg.sender==owner);
        owner=newowner;
    }

    function modifyOracleFee(uint256 newFee) public{
        require(msg.sender==owner);
        oracleFee=newFee;
    }

    function modifyBSCToDCFee(uint256 newFee) public{
        require(msg.sender==owner);
        lockFee=newFee;
    }
    event bscReceived(address requestor, uint256 value);

    function DCtoBSC(uint256 amount,address requestor) public{
        require(msg.sender==oracle);
        bDoge.transfer(requestor,amount);
    }

    function BSCToDC (address receiver,uint256 amount) public
    {
        require(amount!=0);
        bDoge.transferFrom(msg.sender,address(this),amount);
        bDoge.transfer(owner,lockFee);                
        uint256 amountMinusFees=amount-((amount/100)*lockFee);
        emit bscReceived(receiver,amountMinusFees);   
    }
    

}