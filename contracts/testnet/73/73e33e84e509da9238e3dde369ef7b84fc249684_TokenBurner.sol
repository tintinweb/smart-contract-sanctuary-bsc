// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.9;

import "./IBEP20Burnable.sol";

contract TokenBurner {
    /**
     * @dev BEP20 basic token contract being burnt.
     */
    IBEP20Burnable public immutable _token;

    /**
     * @dev Timestamp starting from which tokens can be burnt.
     */
    uint public _minTimestamp;

    /**
     * @dev Token address (immutable), minimum burning timestamp should
     * be provided for contract initialization.
     */
    constructor(address tokenAddress_, uint256 minTimestamp_) {
        _token = IBEP20Burnable(tokenAddress_);
        _minTimestamp = minTimestamp_;
    }

    function burn() public {
        require(block.timestamp >= _minTimestamp, "TokenBurner: it's not time for burning yet");
        require(_token.balanceOf(address(this)) > 0, "TokenBurner: no tokens to burn");

        _token.burn(
            _token.balanceOf(address(this))
        );
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.9;

interface IBEP20Burnable {

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
    * @dev Destroys `amount` tokens from the caller.
     *
     * See {BEP20-_burn}.
     */
    function burn(uint256 amount) external;
}