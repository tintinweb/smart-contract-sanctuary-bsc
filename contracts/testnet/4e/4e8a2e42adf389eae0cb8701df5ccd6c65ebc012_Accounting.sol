/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

pragma solidity >=0.8.0;


contract Accounting {

    mapping(address => uint) private _balances;

    mapping(address => uint) public accountCount;


    constructor() {}

    function doTransfer(address caller, address from, address to, uint amount) external {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint fromBalance = _balances[from];

        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        // Here it depends what you want to account...
        accountCount[caller] += 1;

        _afterTokenTransfer(from, to, amount);
    }

    function balanceOf(address addr) external view returns(uint) {
        return _balances[addr];
    }

    /**
     * Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}