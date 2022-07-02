/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

/**
 * @dev Interface of the BEP20 standard. Does not include
 * the optional functions; to access them see {BEP20Detailed}.
 */
interface ERC20 {
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

contract AirDropToken {
    address public owner;
     ERC20 public token; // token that will be sold
    uint public totalSupply;
    uint public totalTokenRemain;
    struct AirdropInfor {
        uint amount;
        bool status;
    }
    mapping(address => AirdropInfor) public  addressCanAirDrops;
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    modifier isCanClaimable() {
        require(addressCanAirDrops[msg.sender].amount != 0, "address not exist");
        _;
    }
    constructor(address _tokenAddress) public {
        owner = msg.sender;
        token = ERC20(_tokenAddress);
    }
    
    function distributeToken(address _token, address[] calldata _addr, uint256[] calldata _amount) external onlyOwner {
        for(uint i=0; i< _addr.length; i++){
            ERC20(_token).transfer(_addr[i], _amount[i]);
        }
    }
    
    function distributeBSC(address[] calldata _addr, uint256[] calldata _amount) external onlyOwner {
        for(uint i=0; i< _addr.length; i++){
            payable(_addr[i]).transfer(_amount[i]);
        }
    }
    
     /**
     * Below emergency functions will be never used in normal situations.
     * These function is only prepared for emergency case such as smart contract hacking Vulnerability or smart contract abolishment
     * Withdrawn fund by these function cannot belong to any operators or owners.
     * Withdrawn fund should be distributed to individual accounts having original ownership of withdrawn fund.
     */
    function emergencyWithdrawal(address _token, uint256 _amount) public onlyOwner {
        require(ERC20(_token).transfer(msg.sender, _amount));
    }
    // set list airdrops claimable
    function checkAddressClaimable() external view returns(bool) {
        if (addressCanAirDrops[msg.sender].amount == 0 && addressCanAirDrops[msg.sender].status == false){
            return false;
        }
        return true;
    }

        // set list airdrops claimable
    function getAmountTokenClaimable() external view returns(uint) {
        return addressCanAirDrops[msg.sender].amount;
    }

  function claimTokens()
        external
        isCanClaimable

    {
        require(token.balanceOf(address(this))>0,"Insufficient balance token");
        require(addressCanAirDrops[msg.sender].status == false,"Can only be claimed once!");
        uint _amount = addressCanAirDrops[msg.sender].amount;
        require(_amount > 0,"Amount must greater than 0");
        token.transfer(
            msg.sender,
            addressCanAirDrops[msg.sender].amount
        );
        addressCanAirDrops[msg.sender].amount = 0;
        addressCanAirDrops[msg.sender].status = true;
        totalTokenRemain -=_amount;
    }

    function setListAirdropClaimable(address [] calldata addressAirdrops, uint256 _amount) public onlyOwner {
        require(_amount > 0,"Amount must greater than 0");
        for (uint i = 0;i<addressAirdrops.length;i++)
        {
            addressCanAirDrops[addressAirdrops[i]].amount = _amount;
            addressCanAirDrops[addressAirdrops[i]].status = false;
        }        
    }

    function transferTokensFromPool()
        external
        onlyOwner
    {
        uint256 tokensAmount =
            token.balanceOf(address(this));
        if (tokensAmount > 0) {
            token.transfer(msg.sender, tokensAmount);
        }
    }
     function setTotalTokenSupplyAirdrop(uint _amountTotalSupply)
        external
        onlyOwner
    {
        totalSupply = _amountTotalSupply;
        totalTokenRemain = totalSupply;
    }   
    function emergencyWithdrawalBSC(uint256 _amount) public onlyOwner {
        payable(owner).transfer(_amount);
    }
    
    receive () external payable{}
    
}