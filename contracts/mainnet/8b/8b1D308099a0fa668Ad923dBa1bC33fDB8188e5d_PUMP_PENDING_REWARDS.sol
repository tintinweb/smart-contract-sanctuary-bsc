/**
 *Submitted for verification at BscScan.com on 2022-06-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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

interface IXUSD {
    function calculatePrice() external view returns (uint256);
}

interface IStaking {
    function pendingRewards(address user) external view returns (uint256);
}

contract PUMP_PENDING_REWARDS is IERC20 {

    // XUSD Token
    IXUSD public constant XUSD = IXUSD(0x324E8E649A6A3dF817F97CdDBED2b746b62553dD);
    IStaking public constant Staking = IStaking(0xb90b2E9f230C469F54F063CB40F6D6d3ba960E3E);

    // token data
    uint8 private constant _decimals = 18;
    string private constant _name = "Pending XUSD";
    string private constant _symbol = "pXUSD";

    /** Returns the total number of tokens in existence */
    function totalSupply() external pure override returns (uint256) { 
        return 0;
    }

    /** Returns the number of tokens owned by `account` */
    function balanceOf(address account) public view override returns (uint256) { 
        uint pXUSD = Staking.pendingRewards(account);
        return pXUSD * XUSD.calculatePrice() / 10**18;
    }

    /** Returns the number of tokens `spender` can transfer from `holder` */
    function allowance(address, address) external pure override returns (uint256) { 
        return 0; 
    }
    
    /** Token Name */
    function name() public pure override returns (string memory) {
        return _name;
    }

    /** Token Ticker Symbol */
    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    /** Tokens decimals */
    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    /** Approves `spender` to transfer `amount` tokens from caller */
    function approve(address, uint256) public override returns (bool) {
        emit Approval(msg.sender, address(0), 0);
        return true;
    }

    /** Transfer Function */
    function transfer(address token, uint256) external override returns (bool) {
        emit Transfer(msg.sender, token, 0);
        return true;
    }

    /** Transfer Function */
    function transferFrom(address, address, uint256) external override returns (bool) {
        emit Transfer(msg.sender, address(0), 0);
        return true;
    }
}