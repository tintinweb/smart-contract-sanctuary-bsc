/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-29
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-19
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

contract LuckyStakes{
    function internalDeposit (uint256 amount, address player) public {}
    }

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

contract LuckyWallet {
    mapping (address=> uint256) accountBalance;
    address public CNRContract = 0xb0800b08B109aC82D04dC82c25eECfC654Fc6662;
    address public LuckyStakingContractAddress=0xA62070d55F35c7F8127AAE728740C4cD929586f4;
    IBEP20 public CNR = IBEP20(CNRContract);
    LuckyStakes public LuckyStakingContract=LuckyStakes(LuckyStakingContractAddress);

    function deposit(uint256 amount) public{
        CNR.transferFrom(msg.sender,address(this),amount);
        accountBalance[msg.sender]+=amount;
    }

    function withdraw(uint256 amount) public{
        require(accountBalance[msg.sender]>=amount,"Not enough balance");
        accountBalance[msg.sender]-=amount;
        CNR.transfer(msg.sender,amount);
    }

    function readBalance(address player) public view returns(uint256){
        return accountBalance[player];
    }

    function internalTransferLuckyStakes(address gameAddress,uint256 amount) public {
        require(accountBalance[msg.sender]>=amount,"Not enough balance");
        accountBalance[msg.sender]-=amount;  
        CNR.transfer(gameAddress,amount);
        LuckyStakingContract.internalDeposit(amount,msg.sender);

    }


}