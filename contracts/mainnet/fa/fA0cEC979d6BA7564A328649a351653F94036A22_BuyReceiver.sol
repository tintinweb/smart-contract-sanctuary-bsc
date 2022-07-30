//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IToken is IERC20 {
    function getOwner() external view returns (address);
    function burn(uint256 amount) external returns (bool);
}

interface IStaking {
    function distributor() external view returns (address);
}

contract BuyReceiver {

    // Main Token
    IToken public immutable token;
    address public immutable staking;

    // Dev Fee Address
    address public dev = 0xeb98dB0f4Bc181194C8ebf4Bfa0584408037Cf6a;
    address public dev1 = 0xEF1C1Ec45B265C6a6ADA8b311Ee8D20C92F3BE42;

    // Allocations
    uint256 public devCut      = 2;
    uint256 public dev1Cut     = 1;
    uint256 public rewardsCut  = 4;
    uint256 public burnCut     = 5;
    uint256 private DENOM      = 12;

    modifier onlyOwner() {
        require(
            msg.sender == token.getOwner(),
            'Only Owner'
        );
        _;
    }

    constructor(
        address token_,
        address staking_
    ) {
        token = IToken(token_);
        staking = staking_;
    }

    function trigger() external {
        
        // ensure there is balance to distribute
        uint256 balance = token.balanceOf(address(this));
        if (balance == 0) {
            return;
        }

        // split up dev and staking
        uint256 devAmount = ( balance * devCut ) / DENOM;
        uint256 dev1Amount = ( balance * dev1Cut ) / DENOM;
        uint256 burnAmount = ( balance * burnCut ) / DENOM;

        // send to dev and dev1
        _send(dev, devAmount);    
        _send(dev1, dev1Amount);

        // burn remainder of tokens
        if (burnAmount > 0) {
            token.burn(burnAmount);
        }

        // sell remainder of tokens
        _send(staking, token.balanceOf(address(this)));
    }

    function setDev(address dev_) external onlyOwner {
        dev = dev_;
    }

    function setDev1(address dev1_) external onlyOwner {
        dev1 = dev1_;
    }

    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function withdrawToken(IERC20 token_) external onlyOwner {
        token_.transfer(msg.sender, token_.balanceOf(address(this)));
    }

    function setAllocations(
        uint dev_,
        uint dev1_,
        uint rewards_,
        uint burn_
    ) external onlyOwner {

        // set amounts
        devCut = dev_;
        dev1Cut = dev1_;
        rewardsCut = rewards_;
        burnCut = burn_;

        // set denominator
        DENOM = dev_ + dev1_ + rewards_ + burn_;
    }

    function _send(address to, uint amount) internal {
        if (to == address(0)) {
            return;
        }
        if (amount > token.balanceOf(address(this))) {
            amount = token.balanceOf(address(this));
        }
        if (amount == 0) {
            return;
        }
        token.transfer(to, amount);
    }

    receive() external payable {}
}

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