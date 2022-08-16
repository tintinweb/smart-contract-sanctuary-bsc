// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Pausable.sol";
import "./Ownable.sol";
import "./IERC20.sol";

contract HashCashExchangeTest is Ownable, Pausable {
    IERC20 public hashcash;
    IERC20 public hashfree;
    // finance must be white list in both hashfree & hashcash
    // before start finance should approve this from hashfree
    address public finance; 
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    event ExchangeSuccess(address owner, uint256 cashAmount, uint256 freeAmount);

    constructor(address _hashcash, address _hashfree, address _fina) {
        hashcash = IERC20(_hashcash);
        hashfree = IERC20(_hashfree);
        finance = _fina;
    }

    function doExchange() public whenNotPaused {
        // Note: hashcash's decimals equals hashfree's decimals
        uint256 cashbal = hashcash.balanceOf(_msgSender());
        bool cashRes = hashcash.transferFrom(_msgSender(), DEAD, cashbal);
        require(cashRes, "cash transferfrom failed");
        // add additional

        // end
        // todo
        uint256 recAmount = cashbal;
        bool freeRes = hashfree.transferFrom(finance, _msgSender(), recAmount);
        require(freeRes, "hashfree receive failed");
        emit ExchangeSuccess(_msgSender(), cashbal, recAmount);
    }

    function ownerWithdraw(address _token, address _to) public onlyOwner {
        if (_token == address(0x0)) {
            payable(_to).transfer(address(this).balance);
            return;
        }
        IERC20 token = IERC20(_token);
        token.transfer(_to, token.balanceOf(address(this)));
    }
}