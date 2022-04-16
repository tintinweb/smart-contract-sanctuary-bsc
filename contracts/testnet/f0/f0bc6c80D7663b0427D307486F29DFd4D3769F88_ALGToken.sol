//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./IERC20.sol";
import "./Ownable.sol";
import "./Address.sol";

contract ALGToken is ERC20, Ownable {
    using Address for address;
    uint256 constant maxSupply = 100000000 * 1e18;
    uint256 private swapFee = 10;
    mapping(address => bool) private _isExcluded;
    address public pairAddr;
    uint256 public startTime;
    address public marketAddress;
    bool public isFee;

    constructor(address _marketAddr) ERC20("ALG Token", "ALG") {
        _mint(msg.sender, maxSupply);
        marketAddress = _marketAddr;
        isFee = true;
    }

    function setExcluded(address _addr, bool _bol) public onlyOwner {
        _isExcluded[_addr] = _bol;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _TokenTransfer(from, to, amount);
        if (pairAddr == address(0) && to.isContract()) {
            pairAddr = to;
            startTime = block.timestamp;
        }
        return true;
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        address owner = _msgSender();
        _TokenTransfer(owner, to, amount);
        return true;
    }

    function _TokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "Invalid address");
        require(to != address(0), "Invalid address");
        require(amount > 0, "Invalid amount");
        require(amount <= balanceOf(from), "Not enough balance");
        require(from != pairAddr || _isExcluded[to]);
        if (to == pairAddr && !_isExcluded[from]) {
            _SwapTransfer(from, to, amount);
        } else {
            _transfer(from, to, amount);
        }
    }

    function _SwapTransfer(
        address from,
        address to,
        uint256 amount
    ) private {
        // amount是总数,他最终得到的是扣掉swapFee的数量,扣掉10%的数量
        if (isFee) {
            uint256 _market = (amount * swapFee) / 100;
            _transfer(from, marketAddress, _market);
            amount = (amount * (100 - swapFee)) / 100;
        }
        _transfer(from, to, amount);
    }
}