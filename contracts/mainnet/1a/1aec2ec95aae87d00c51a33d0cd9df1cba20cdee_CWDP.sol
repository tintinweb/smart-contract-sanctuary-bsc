// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./Ownable.sol";

// 2022.10.12 10:50 PM
contract CWDP is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("Crypto Wave Diamond Pearls", "CWDP") {}

    // CMTT codes starts here
    address CTMTConAdd;
    address sCTMTConAdd = address(this);
    address treasuryConAdd = 0xdeA16c78B98a9BfE9F13a84DAb0D53166f565331;

    IERC20 CTMT;

    function setCTMTConAdd(address _CTMTConAdd) public virtual onlyOwner {
    CTMTConAdd = _CTMTConAdd;
    CTMT = IERC20(CTMTConAdd);
    }

    function getSCTMTPrice() public view returns (uint) {
        uint sCTMTPrice;
        if (totalSupply() == 0) {sCTMTPrice = 1000000000000000000000000000;}
            else {uint sCTMTRatio = 1000000000000000000000000000 * CTMT.balanceOf(sCTMTConAdd) / totalSupply();
                sCTMTPrice = sCTMTRatio;}
        return sCTMTPrice;
    }

    function stakeCTMT(uint CTMTAmount) public {
        uint sCTMTPrice = getSCTMTPrice();
        uint sCTMTAmount = CTMTAmount * 1000000000000000000000000000 / sCTMTPrice;
        CTMT.transferFrom(_msgSender(), sCTMTConAdd, CTMTAmount);
        _mint(_msgSender(), sCTMTAmount * 995 / 1000);
    }

    function unStakeCTMT(uint sCTMTAmount) public {
        uint sCTMTPrice = getSCTMTPrice();
        uint CTMTAmount = sCTMTAmount * sCTMTPrice / 1000000000000000000000000000;
        _burn(_msgSender(), sCTMTAmount);
        CTMT.transfer(_msgSender(), CTMTAmount * 995 / 1000);
    }

}