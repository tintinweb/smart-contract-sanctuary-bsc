// contracts/SimpleToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

 
contract SixPackToken is ERC20, Ownable {
    using SafeMath for uint256;
    modifier onlyTreasuryAccount() {
        _checkTreasuryAccount();
        _;
    }
    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    uint256 public maxSupply;
    uint256 public mintPerDay;
    uint256 halvingBlockNumber;
    uint256 lastMintedBlockNumber;
    address public treasuryAccount;

    constructor() ERC20("Sixpack Token", "SIXP") {
         maxSupply = 6000000000 * (10**decimals());
        halvingBlockNumber = block.number + 21024000;
        lastMintedBlockNumber = block.number;
        mintPerDay= 6000000 * (10**decimals());
    }

    function mintForTreasury() public onlyTreasuryAccount {
        if (block.number > halvingBlockNumber) {
            mintPerDay = mintPerDay.div(2);
            halvingBlockNumber = halvingBlockNumber + 21024000;
        }
        require(block.number > lastMintedBlockNumber + 28800);
        lastMintedBlockNumber = block.number;

        _mint(treasuryAccount, mintPerDay);
        require(totalSupply() <= maxSupply, "Sixpack Error: Reach max supply");
    }

    function setTreasuryAccount(address _address) public onlyOwner {
        require(
            _address != address(0),
            "Sixpack Error: new treasury is the zero address"
        );
        treasuryAccount = _address;
    }

    function _checkTreasuryAccount() internal view virtual {
        require(
            treasuryAccount == _msgSender(),
            "Sixpack Error: caller is not the treasury"
        );
    }
}