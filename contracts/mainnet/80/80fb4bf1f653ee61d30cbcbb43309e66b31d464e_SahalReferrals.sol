/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

// File: contracts/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// File: contracts/SahalReferral.sol


pragma solidity ^0.8.10;



contract SahalReferrals {

    function getEthBalances(address[] memory addresses) public view returns(uint256[] memory) {
       uint256[] memory ethBalances = new uint256[](addresses.length);
        for(uint256 index=0; index < addresses.length; index+=1){
            ethBalances[index] = addresses[index].balance;
        }
        return ethBalances;
    }

    function getErc20Balances(address[] memory addresses, address[] memory tokens) public view returns(uint256[] memory) {
       uint256[] memory erc20Balances = new uint256[](addresses.length * tokens.length);
        for(uint256 i=0; i < addresses.length; i+=1){
            for(uint256 j=0; j<tokens.length; j++){
                uint256 index = j + tokens.length * i;
                erc20Balances[index] = IERC20(tokens[j]).balanceOf(address(addresses[i]));
            }
        }
        return erc20Balances;
    }

    function rewardDistribution(address[] memory referred, uint256 referredReward, address[] memory referree, uint256 referreeReward, address erc20Token) public payable returns(bool){
        require(referred.length !=0,"referred addresses required");
        require(referree.length !=0,"referree addresses required");
        require(referred.length==referree.length,"referree and referred address should have same length");
        
        for(uint256 i=0; i<referred.length; i++){
            IERC20(erc20Token).transferFrom(msg.sender, referred[i],referredReward);
            IERC20(erc20Token).transferFrom(msg.sender, referree[i],referreeReward);
        }
        return true;
    }
}