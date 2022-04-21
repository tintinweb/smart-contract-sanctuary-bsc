// SPDX-License-Identifier: MIT
pragma solidity ^0.6.9;

import "./IPool.sol";
import "./IPricefeed.sol";
import "./IBEP20.sol";
import "./IDonStaking.sol";

contract Multicall {

    function getPoolData(
        address _pool,
        address _pricefeed
    )
        public view
        returns (uint256, uint8)
    {
        IPool pool = IPool(_pool);
        IPricefeed priceFeed = IPricefeed(_pricefeed);

        IBEP20 token = pool.getToken();
        uint256 tokenPriceUsd = priceFeed.getPriceinUSD(address(token));
        uint8 tokenDecimals = token.decimals();

        return (tokenPriceUsd, tokenDecimals);
    }

    function getPoolFees(
        address _pool
    )
        public view
        returns (uint256, uint256)
    {
        IPool pool = IPool(_pool);

        uint256 farmerFee = pool.getFarmerRewardFee();
        uint256 teamFee = pool.getTeamRewardFee();

        return (farmerFee, teamFee);
    }

    function getPoolInvestorData(
        address _pool,
        address _investor
    ) 
        public view 
        returns (uint256, uint256, uint256, uint256)
    {
        IPool pool = IPool(_pool);

        uint256 amountInvestedTokens = pool.getUserInvestedAmount(_investor);
        uint256 amountInvestedUsd = pool.getUserInvestedAmountInUSD(_investor);
        uint256 lpTokens = pool.balanceOf(_investor);
        uint256 claimableAmountTokens = pool.getInvestorClaimableAmount(_investor, 10000);

        return (amountInvestedTokens, amountInvestedUsd, lpTokens, claimableAmountTokens);
    }

    function getSponsoredPoolInvestorData(
        address _staking, 
        address _investor,
        address _pool
    ) 
        public view
        returns (uint8, uint256, uint256, uint256, uint256)
    {
        IDonStaking staking = IDonStaking(_staking);
        IPool pool = IPool(_pool);

        uint8 userTier = staking.getUserTier(_investor);
        uint256 amountInvestedTokens = pool.getUserInvestedAmount(_investor);
        uint256 amountInvestedUsd = pool.getUserInvestedAmountInUSD(_investor);
        (uint256 pendingRewardTokens, uint256 donPriceUsd) = staking.pendingRewardPerPool(_investor, _pool);

        return (userTier, amountInvestedTokens, amountInvestedUsd, pendingRewardTokens, donPriceUsd);
    }

}

//SPDX-License-Identifier: MIT
pragma solidity ^0.6.9;

import "./IBEP20.sol";

interface IPool {
    function getUserInvestedAmount(address _investor) external view returns (uint256);
    function getUserInvestedAmountInUSD(address _investor) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function getInvestorClaimableAmount(address _address, uint256 _LPAmountInPer) external view returns (uint256);
    function getToken() external view returns(IBEP20);
    function getFarmerRewardFee() external view returns (uint256);
    function getTeamRewardFee() external view returns (uint256);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.6.9;

interface IPricefeed {
    function getPriceinUSD(address tokenAddress) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.9;

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
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.6.9;

interface IDonStaking {
    function getUserTier(address _addr) external view returns (uint8);
    function pendingRewardPerPool(address _user, address _pool) external view returns (uint256 rewardAmountInDON, uint256 donPriceInUSD);
}