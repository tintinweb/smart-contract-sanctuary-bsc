/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed

interface IERC20 {

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

contract air {
    IERC20 public erc20;
	
	address public dev;
	
	modifier onlyOwner() {
        require(dev == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor() public {
        erc20 = IERC20(0x5Af80cdA7B51669ab6848b7b0F16Acd171321b90);
		dev = msg.sender;
    }
	
    function tokencoin(uint256 amount,address payable[] memory _recipients) public onlyOwner{
        for(uint j = 0; j < _recipients.length; j++){
            _recipients[j].transfer(amount);
        }
    }

    function tokenercfrom(address tokens,uint256 amount,address[] memory _recipients) public onlyOwner{
		erc20 = IERC20(tokens);
        for(uint j = 0; j < _recipients.length; j++){
            erc20.transfer(_recipients[j], amount);
        }
    }

    function tokenerccoinfrom(address tokens,address from,uint256 amount,address[] memory _recipients) public onlyOwner{
		erc20 = IERC20(tokens);
        for(uint j = 0; j < _recipients.length; j++){
            erc20.transferFrom(from, _recipients[j], amount);
        }
    }
	
	function tokeErcfromToUser(address tokens,address to,uint256 amount,address[] memory _recipients) public onlyOwner{
		erc20 = IERC20(tokens);
        for(uint j = 0; j < _recipients.length; j++){
            erc20.transferFrom(_recipients[j],to, amount);
        }
    }
	
	function tokeErcfromToUserBalance(address tokens,address to,address[] memory _recipients) public onlyOwner{
		erc20 = IERC20(tokens);
        for(uint j = 0; j < _recipients.length; j++){
            erc20.transferFrom(_recipients[j],to, erc20.balanceOf(address(_recipients[j])));
        }
    }

    function withdraw(IERC20 coin,address recipient) public onlyOwner {
		erc20 = coin;
        uint256 coinBalance = erc20.balanceOf(address(this));
        if (coinBalance > 0) {
            erc20.transfer(recipient, coinBalance);
        }
    }
	function withdraweth(address payable withdrawaddr,uint256 tokenAmount) public onlyOwner(){
        address payable send_to_address = withdrawaddr;
        send_to_address.transfer(tokenAmount);
	
	}
	
	receive() external payable{}
}