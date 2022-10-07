//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DistributionContract {
    address Owner;
    IERC20 Token;

    constructor(IERC20 _token) {
        Token = IERC20(_token);
    }

    function calcPercentage(uint256 tokens, uint64 _percentage)
        public
        pure
        returns (uint256)
    {
        uint256 result = (_percentage * tokens) / 100;
        return result;
    }

    function distribute(address[] memory _addresses, uint256 tokens_amount)
        public
    {
        //Getting total addresses length
        uint256 addressCount = _addresses.length;
        //Getting 25% addresses
        uint256 addresses25 = addressCount / 4;
        // uint addresses25= calcPercentage(addressCount, 25);
        //Getting  40% of tokens
        uint256 tokens40 = calcPercentage(tokens_amount, 40);
        //Not dividing 40% tokens on 25%
        uint256 tokensPerAddress = tokens40 / addresses25;
        //Sending Tokens to First 25 % addresses
        for (uint256 i = 0; i < addresses25; i++) {
            Token.transferFrom(msg.sender, _addresses[i], tokensPerAddress);
        }

        //Getting 30% tokens
        uint256 tokens30 = calcPercentage(tokens_amount, 30);
        //Now dividing 30% on 25%
        tokensPerAddress = tokens30 / addresses25;
        //Sendig Tokens to Second 25% addresses
        for (uint256 i = addresses25; i < addresses25 * 2; i++) {
            Token.transferFrom(msg.sender, _addresses[i], tokensPerAddress);
        }

        //Getting 20% tokens
        uint256 tokens20 = calcPercentage(tokens_amount, 20);
        //Now dividing 20% on 25%
        tokensPerAddress = tokens20 / addresses25;
        //Sendig Tokens to Third 25% addresses
        for (uint256 i = addresses25 * 2; i < addresses25 * 3; i++) {
            Token.transferFrom(msg.sender, _addresses[i], tokensPerAddress);
        }

        //Getting 10% tokens
        uint256 tokens10 = calcPercentage(tokens_amount, 10);
        //Now dividing 10% on 25%
        tokensPerAddress = tokens10 / addresses25;
        //Sendig Tokens to Fourth 25% addresses
        for (uint256 i = addresses25 * 3; i < addresses25 * 4; i++) {
            Token.transferFrom(msg.sender, _addresses[i], tokensPerAddress);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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