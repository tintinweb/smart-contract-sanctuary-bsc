/**
 *Submitted for verification at BscScan.com on 2022-08-30
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

interface INFT {
    function totalSupply() external view returns (uint256);
    function depositRewards(uint256 amount) external;
}

interface IStaking {
    function depositRewards(uint256 amount) external;
}

contract RewardDistributor {

    uint256 public constant conversionRate = 25_000 * 10**18;
    uint256 private constant PRECISION = 10**18;

    address public immutable infinity;
    address public immutable staking;
    address public immutable nft;

    constructor(address infinity_, address staking_, address nft_) {
        infinity = infinity_;
        staking = staking_;
        nft = nft_;
    }

    function distribute() external payable {
        _distribute();
    }

    receive() external payable{
        _distribute();
    }

    function _distribute() internal {

        // Infinity Balances In Each
        uint nftBal = infBalanceNFT();
        uint stakingBal = infBalanceStaking();

        // Which Pool Has A Larger Balance
        bool nftHasMore = nftBal > stakingBal;

        // Ratio Of Bigger Balance / Smaller Balance
        uint ratio = nftHasMore ? ( nftBal * PRECISION ) / stakingBal : ( stakingBal * PRECISION ) / nftBal;

        // Value / ( Ratio + 1 )
        uint smallerShare = ( address(this).balance * PRECISION ) / ( ratio + PRECISION );

        // split up amounts to their correct pools
        _send(nftHasMore ? staking : nft, smallerShare);
        _send(nftHasMore ? nft : staking, address(this).balance);
    }

    function infBalanceNFT() public view returns (uint256) {
        return INFT(nft).totalSupply() * conversionRate;
    }

    function infBalanceStaking() public view returns (uint256) {
        return IERC20(infinity).balanceOf(staking);
    }

    function _send(address to, uint amount) internal {
        (bool s,) = payable(to).call{value: amount}("");
        require(s);
    }
}