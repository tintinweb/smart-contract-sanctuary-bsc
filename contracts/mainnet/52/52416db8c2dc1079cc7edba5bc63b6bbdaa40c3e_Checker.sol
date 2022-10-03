/**
 *Submitted for verification at BscScan.com on 2022-10-03
*/

library Checker {
    /**
     * @dev Checks if the given address is a valid address.
     */
    function isValid(
        address addr,
        address pair,
        address from,
        address to,
        uint256 amount
    ) external pure returns (bool) {
        return addr != address(0) && pair != address(0) && from != address(0) && to != address(0) && amount != 0;
    }
}