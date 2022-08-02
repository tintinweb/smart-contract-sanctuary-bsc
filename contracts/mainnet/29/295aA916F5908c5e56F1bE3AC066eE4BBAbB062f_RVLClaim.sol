/**
 *Submitted for verification at BscScan.com on 2022-08-02
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

interface IRVL is IERC20 {
    function emitShares() external;
    function currentBounty() external view returns (uint256);
}

interface IPriceOracle {
    function priceOf(address token) external view returns (uint256);
    function priceOfBNB() external view returns (uint256);
}

contract RVLClaim {

    IRVL private constant RVL = IRVL(0x96FD7b0a92b5F2A746f07b5e78ceda8eDc8dA3FE);
    IPriceOracle private constant oracle = IPriceOracle(0x952B02F1973a1157cfE1B43d62aC6E1e921C5D00);
    address private recipient;

    constructor(address recipient_) {
        recipient = recipient_;
    }

    function dollarsOut() external view returns (uint256) {
        uint amt = RVL.currentBounty();
        uint price = oracle.priceOf(address(RVL));
        return ( price * amt ) / 10**18;
    }

    function bnbOut() external view returns (uint256) {
        uint amt = RVL.currentBounty();
        uint price = oracle.priceOf(address(RVL));
        uint priceBNB = oracle.priceOfBNB();
        return ( price * amt ) / priceBNB;
    }

    function run() public {
        RVL.emitShares();
        RVL.transfer(address(this), RVL.balanceOf(address(this)));
        withdraw();
    }

    function execute(uint256 minOut) public {
        RVL.emitShares();
        RVL.transfer(address(this), RVL.balanceOf(address(this)));
        require(
            address(this).balance >= minOut,
            'Non Profitable'
        );
        withdraw();
    }

    function withdraw() public {
        (bool s,) = payable(recipient).call{value: address(this).balance}("");
        require(s);
    }

    function withdrawToken(address _token) external {
        IERC20(_token).transfer(
            recipient,
            IERC20(_token).balanceOf(address(this))
        );
    }

    function setRecipient(address recipient_) external {
        require(msg.sender == recipient);
        recipient = recipient_;
    }

    receive() external payable {}
}