pragma solidity 0.6.12;

import './SafeMath.sol';
import './IBEP20.sol';
import './SafeBEP20.sol';
import './Ownable.sol';
import './ReentrancyGuard.sol';

contract OraclePrice is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    IBEP20 public BUSDContact;

    constructor(
        IBEP20 _BUSDContact
    ) public {
        BUSDContact = _BUSDContact;
    }


    mapping(IBEP20 => uint256) public priceByBEP20Address;

    event SetPrice(address indexed setterAddr, IBEP20 _token, uint256 price);

    function setPrice(IBEP20 _token, uint256 _price) public onlyOwner nonReentrant {
        priceByBEP20Address[_token] = _price;
        emit SetPrice(msg.sender, _token, _price);
    }

    function getPrice(IBEP20 _token) public view returns (uint256) {
        return priceByBEP20Address[_token];
    }

    function getPriceRealTime(IBEP20 _token, IBEP20 _lpWithBUSD) public view returns (uint256) {
        uint256 balanceOfToken = _token.balanceOf(address(_lpWithBUSD));
        uint256 balanceOfBUSD = _token.balanceOf(address(_lpWithBUSD));

        return balanceOfBUSD / balanceOfToken;
    }
}