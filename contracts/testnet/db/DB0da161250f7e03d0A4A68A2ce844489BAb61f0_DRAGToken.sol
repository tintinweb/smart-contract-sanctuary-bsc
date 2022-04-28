pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./ERC20.sol";

contract DRAGToken is ERC20
{
    using SafeMath for uint256;

    address private chairman;

    uint256 private totalToken;

    constructor() ERC20('Dragon World Token', 'DRAG') public
    {
        chairman = msg.sender;
        totalToken = 270000000 * 10 ** uint256(decimals());
        _mint(chairman, totalToken);
    }

    function getOwner() public view returns (address)
    {
        return chairman;
    }

    function getBurnedAmountTotal() external view returns (uint256)
    {
        return totalToken.sub(totalSupply());
    }

    function burn(uint256 amount) external
    {
        _burn(msg.sender, amount);
    }
}