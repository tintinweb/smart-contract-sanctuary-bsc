/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
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

interface IOldMigrator{
    function claimable(address wallet) external returns (uint256); 
}

contract MigrationClaims is Auth {

	bool public newTokenAvailable = false;
	address public tokenIn;
	address public tokenOut;
    IOldMigrator private oldMigrator = IOldMigrator(0x038aB04504Ee7dF294fB4A953B3eB009De030e2a);

	mapping (address => uint256) public deposits;
	mapping (address => uint256) public claimable;
	mapping (address => uint256) public redeemed;
	mapping (address => uint64) public lastRedeem;

	event Deposit(address indexed depositer, uint256 quantity);
	event Redeem(address indexed redeemer, uint256 quantity);

	constructor(address t1, address t2) Auth(msg.sender) {

        tokenIn = t1;
		tokenOut = t2;
    }

	function setNewTokenAvailable(bool av) external authorized {
		newTokenAvailable = av;
	}

	function setClaimAmount(address claimer, uint256 amount) public authorized {
		claimable[claimer] = amount;
	}

    function migrateClaims(address[] memory wallets) external authorized {
        for (uint256 i = 0; i < wallets.length; i++) {
            uint256 amount = oldMigrator.claimable(wallets[i]);
            if(amount>0) setClaimAmount(wallets[i],amount);
        }
    }

	function sendTokens(address sender, address receiver, uint256 amount) internal returns(bool) {
		return IBEP20(tokenIn).transferFrom(sender, receiver, amount);
	}

	function deposit(uint256 amount) external {
		sendTokens(msg.sender, address(this), amount);
		deposits[msg.sender] += amount;
		claimable[msg.sender] += amount;

		emit Deposit(msg.sender, amount);
	}



	function redeem() external {
		require(newTokenAvailable, "Not available yet!");
		require(claimable[msg.sender] > 0, "Nothing to redeem!");
		uint256 redeeming = claimable[msg.sender];
		IBEP20(tokenOut).transfer(msg.sender, redeeming);
		claimable[msg.sender] = 0;
		lastRedeem[msg.sender] = uint64(block.timestamp);
		redeemed[msg.sender] += redeeming;

		emit Redeem(msg.sender, redeeming);
	}

	function emergencyRecoverToken(address t) external authorized {
		IBEP20 tok = IBEP20(t);
		tok.transfer(msg.sender, tok.balanceOf(address(this)));
	}
}