pragma solidity ^0.8.0;
import "./ERC20.sol";

contract SkyBossToken is ERC20 {

    constructor() ERC20("SKYBOSS", "SBOSS") {
        _mint(msg.sender, 100000000 * 10 ** decimals());
    }

}