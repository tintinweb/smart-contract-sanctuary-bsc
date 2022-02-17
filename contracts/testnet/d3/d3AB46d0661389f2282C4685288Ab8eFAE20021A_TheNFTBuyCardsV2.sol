pragma solidity 0.6.12;

import './SafeMath.sol';
import './IBEP20.sol';
import './SafeBEP20.sol';
import './Ownable.sol';
import './ReentrancyGuard.sol';

import './TheNFTCryptoGirl.sol';
import './OraclePrice.sol';

contract TheNFTBuyCardsV2 is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // Fee address
    address public feeAddress;

    event BuyHeroCard(address indexed sender, uint256 indexed cardsPaymentsTypePid, uint256 tokenID);

    event SetFeeAddress(address indexed user, address indexed _feeAddress);

    struct CardsPaymentsTypes {
        IBEP20 token;
        uint256 tokenQty;
        uint256 bnbQty;
        uint256 heroType;
        bool isActive;
    }

    CardsPaymentsTypes[] public cardsPaymentsTypes;

    TheNFTCryptoGirl public nftMasterAddress;

    OraclePrice public oraclePriceAddress;

    bool public thisContractIsActive = true;

    constructor(
        address _feeAddress
    ) public {
        feeAddress = _feeAddress;
    }

    modifier onlyIfIsActive() {
        require(thisContractIsActive, "You can use, if is active");
        _;
    }

    function setContractState(bool _newContractState) public onlyOwner {
        thisContractIsActive = _newContractState;
    }

    function changeNFTMasterAddress(TheNFTCryptoGirl _address) public onlyOwner {
        nftMasterAddress = _address;
    }

    function changeOracleAddress(OraclePrice _address) public onlyOwner {
        oraclePriceAddress = _address;
    }

    function addCardsPaymentsTypes(IBEP20 _token, uint256 _tokenQty, uint256 _bnbQty, uint256 _heroType, bool _isActive) public onlyOwner {
        cardsPaymentsTypes.push(
            CardsPaymentsTypes({
        token: _token,
        tokenQty: _tokenQty,
        bnbQty: _bnbQty,
        heroType: _heroType,
        isActive: _isActive
        })
        );
    }

    function setCardsPaymentsTypes(uint256 _pid, IBEP20 _token, uint256 _tokenQty, uint256 _bnbQty, uint256 _heroType, bool _isActive) public onlyOwner {
        cardsPaymentsTypes[_pid].token = _token;
        cardsPaymentsTypes[_pid].tokenQty = _tokenQty;
        cardsPaymentsTypes[_pid].bnbQty = _bnbQty;
        cardsPaymentsTypes[_pid].heroType = _heroType;
        cardsPaymentsTypes[_pid].isActive = _isActive;
    }

    function cardsPaymentsTypesLength() external view returns (uint256) {
        return cardsPaymentsTypes.length;
    }

    function buyHeroCard(uint256 _cardsPaymentsTypePid) public onlyIfIsActive payable returns (uint256) {
        CardsPaymentsTypes storage cardsPaymentsTypeSelected = cardsPaymentsTypes[_cardsPaymentsTypePid];

        uint256 currentTokenPrice = oraclePriceAddress.getPrice(cardsPaymentsTypeSelected.token);
        uint256 qtyOfTokensByCurrentPrice = cardsPaymentsTypeSelected.tokenQty.mul(1e18).div(currentTokenPrice);

        require(cardsPaymentsTypeSelected.isActive, "This option is not available");
        require(cardsPaymentsTypeSelected.token.balanceOf(msg.sender) >= qtyOfTokensByCurrentPrice, "You don't have enough Tokens");
        require(msg.value >= cardsPaymentsTypeSelected.bnbQty, "You don't have enough Tokens");

        payable(feeAddress).transfer(msg.value);

        cardsPaymentsTypeSelected.token.safeTransferFrom(address(msg.sender), address(feeAddress), qtyOfTokensByCurrentPrice);

        uint256 tokenCount = nftMasterAddress.mintNFTHero(cardsPaymentsTypeSelected.heroType, address(msg.sender));

        emit BuyHeroCard(msg.sender, _cardsPaymentsTypePid, tokenCount);

        return tokenCount;
    }

    function setFeeAddress(address _feeAddress) public {
        require(_feeAddress != address(0), "setFeeAddress: invalid address");
        require(msg.sender == feeAddress, "setFeeAddress: FORBIDDEN");
        feeAddress = _feeAddress;
        emit SetFeeAddress(msg.sender, _feeAddress);
    }
}