pragma solidity 0.6.12;

import './Ownable.sol';
import './ReentrancyGuard.sol';
import './SafeMath.sol';
import './TheNFTCryptoGirl.sol';
import './Wallet.sol';
import './OraclePrice.sol';
import './IBEP20.sol';

contract TheGame is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    TheNFTCryptoGirl public theNFTContract;
    //address public theNFTContract;
    Wallet public wallet;
    OraclePrice public oraclePrice;
    IBEP20 public cryptoGirlToken;
    IBEP20 public energyCryptoGirlToken;

    bool public thisContractIsActive = true;

    uint256 public constant PRICE_IN_USD_EVERY_10_EXTRA_PERCENT_ENERGY = 500; // 0.5 USD

    address public feeAddress;

    event SetFeeAddress(address indexed user, address indexed _feeAddress);

    event PlayGame(string cityPlayingName, uint256 heroTVS, uint256 villainTVS);

    constructor(
        TheNFTCryptoGirl _theNFTContract,
        Wallet _wallet,
        OraclePrice _oraclePrice,
        IBEP20 _cryptoGirlToken,
        IBEP20 _energyCryptoGirlToken,
        address _feeAddress
    ) public {
        theNFTContract = _theNFTContract;
        wallet = _wallet;
        oraclePrice = _oraclePrice;
        cryptoGirlToken = _cryptoGirlToken;
        energyCryptoGirlToken = _energyCryptoGirlToken;
        feeAddress = _feeAddress;
    }

    modifier onlyIfIsActive() {
        require(thisContractIsActive, "You can use, if is active");
        _;
    }

    function setContractState(bool _newContractState) public onlyOwner {
        thisContractIsActive = _newContractState;
    }

    function getEnergyPriceInEnergyCryptoGirlQty(uint256 _percentEnergy) public returns (uint256) {
        require(_percentEnergy >= 10 && _percentEnergy <= 17, "Incorrect percent");

        uint256 extraEnergyPercent = _percentEnergy.sub(10);

        uint256 energyCryptoGirlTokenPrice = oraclePrice.getPrice(energyCryptoGirlToken);
        uint256 energyCryptoGirlQty = PRICE_IN_USD_EVERY_10_EXTRA_PERCENT_ENERGY.mul(1e18).div(energyCryptoGirlTokenPrice);

        return energyCryptoGirlQty;
    }

    function getHeroTVS(uint256 _heroId, uint256 _percentEnergy, uint256 _citizensValue) public view returns (uint256) {
        uint256 heroPlayingHeroType;
        uint256 heroPlayingLevel;
        uint256 heroPlayingDefense;
        uint256 heroPlayingAttack;
        uint256 heroPlayingSpeed;
        uint256 heroPlayingFly;
        //uint256 heroPlayingBornAt;

        (heroPlayingHeroType, heroPlayingLevel, heroPlayingDefense, heroPlayingAttack, heroPlayingSpeed, heroPlayingFly,) = theNFTContract.heroes(_heroId);

        heroPlayingLevel = heroPlayingLevel;
        heroPlayingDefense = heroPlayingDefense.mul(1000);
        heroPlayingAttack = heroPlayingAttack.mul(1000);
        heroPlayingSpeed = heroPlayingSpeed.mul(1000);
        heroPlayingFly = heroPlayingFly.mul(1000);

        uint256 tvs = (heroPlayingDefense + heroPlayingAttack + heroPlayingSpeed + heroPlayingFly);

        uint256 heroTypeMultiplier = heroPlayingHeroType.add(1).mul(5).add(100);
        tvs = tvs.mul(heroTypeMultiplier).div(100);

        uint256 levelMultiplier = heroPlayingLevel.sub(1).add(100);
        tvs = tvs.mul(levelMultiplier).div(100);

        uint256 citizensMultiplier = _citizensValue.mul(2).add(100);
        tvs = tvs.mul(citizensMultiplier).div(100);

        uint256 energyMultiplier = _percentEnergy.mul(10);
        tvs = tvs.mul(energyMultiplier).div(100);

        return tvs;
    }

    function getVillainTVS(uint256 _villainId, uint256 _gangstersValue, uint256 _difficultyValue) public view returns (uint256) {
        uint256 villainPlayingVillainType;
        //uint256 villainPlayingCityId;
        uint256 villainPlayingLevel;
        uint256 villainPlayingDefense;
        uint256 villainPlayingAttack;
        uint256 villainPlayingSpeed;
        uint256 villainPlayingFly;
        //uint256 villainPlayingBornAt;

        (villainPlayingVillainType, , villainPlayingLevel, villainPlayingDefense, villainPlayingAttack, villainPlayingSpeed, villainPlayingFly,) = theNFTContract.villains(_villainId);

        villainPlayingLevel = villainPlayingLevel;
        villainPlayingDefense = villainPlayingDefense.mul(1000);
        villainPlayingAttack = villainPlayingAttack.mul(1000);
        villainPlayingSpeed = villainPlayingSpeed.mul(1000);
        villainPlayingFly = villainPlayingFly.mul(1000);

        uint256 tvs = (villainPlayingDefense + villainPlayingAttack + villainPlayingSpeed + villainPlayingFly);

        uint256 villainTypeMultiplier = villainPlayingVillainType.add(1).mul(5).add(100);
        tvs = tvs.mul(villainTypeMultiplier).div(100);

        uint256 levelMultiplier = villainPlayingLevel.sub(1).add(100);
        tvs = tvs.mul(levelMultiplier).div(100);

        uint256 gangstersMultiplier = _gangstersValue.add(100);
        tvs = tvs.mul(gangstersMultiplier).div(100);

        uint256 difficultyMultiplier = _difficultyValue.add(100);
        tvs = tvs.mul(difficultyMultiplier).div(100);

        return tvs;
    }

    function playGame(uint256 _cityId, uint256 _heroId, uint256 _percentEnergy) public onlyIfIsActive {

        uint256 energyCryptoGirlQtyForPercentEnergy = getEnergyPriceInEnergyCryptoGirlQty(_percentEnergy);

        require(_percentEnergy >= 10 && _percentEnergy <= 17, "Incorrect percent");
        require(theNFTContract.tokenTypeByTokenId(_cityId) == 1, "This NFT is not a City");
        require(theNFTContract._owners(_heroId) == msg.sender, "You're not the owner of this NFT");
        require(theNFTContract.tokenTypeByTokenId(_heroId) == 0, "This NFT is not a Hero");
        require(energyCryptoGirlToken.balanceOf(msg.sender) >= energyCryptoGirlQtyForPercentEnergy);

        if (_percentEnergy > 10) {
            energyCryptoGirlToken.safeTransferFrom(address(msg.sender), address(feeAddress), energyCryptoGirlQtyForPercentEnergy);
        }

        string memory cityPlayingName;
        uint256 cityPlayingGangsters;
        uint256 cityPlayingCitizens;
        uint256 cityPlayingDifficulty;
        uint256 cityPlayingBornAt;
        (cityPlayingName, cityPlayingGangsters, cityPlayingCitizens, cityPlayingDifficulty,cityPlayingBornAt) = theNFTContract.cities(_cityId);

        (uint256 heroPlayingHeroType,,,,,,) = theNFTContract.heroes(_heroId);

        uint256 heroTVS = getHeroTVS(_heroId, _percentEnergy, cityPlayingCitizens);
        //getIdsVillainByCityId(_cityId, heroPlayingHeroType);
        uint256[] memory possibleVillainsIds = getIdsVillainByCityId(_cityId, heroPlayingHeroType);

        uint256 villainId = possibleVillainsIds[generateStats(possibleVillainsIds.length)[0]];
        //uint256 villainId = 9;

        uint256 villainTVS = getVillainTVS(villainId, cityPlayingGangsters, cityPlayingDifficulty);


        if (heroTVS >= villainTVS) {
            wallet.depositToUserBalance(energyCryptoGirlToken, msg.sender, 1500000000000000000);
        } else {
            address villainOwner = theNFTContract._owners(villainId);
            wallet.depositToUserBalance(energyCryptoGirlToken, villainOwner, 1500000000000000000);
        }
        emit PlayGame(cityPlayingName, heroTVS, villainTVS);
    }


    function getIdsVillainByCityId(uint256 _cityId, uint256 _villainType) public view returns(uint256[] memory villainsIds) {
        uint256 totalSupply = theNFTContract.totalSupply();

        uint256 villainId = 0;

        if (totalSupply == 0) {
            return new uint256[](0);
        } else {
            uint256 tId;
            uint256 totalVillains = 0;
            for (tId = 1; tId <= totalSupply; tId++) {
                if (theNFTContract.tokenTypeByTokenId(tId) == 2) {
                    (uint256 villainPlayingVillainType, uint256 villainCityId,,,,,,) = theNFTContract.villains(tId);
                    if (villainCityId == _cityId && villainPlayingVillainType <= _villainType) {
                        totalVillains++;
                    }
                }
            }

            uint256[] memory result = new uint256[](totalVillains);
            uint256 i = 0;

            for (tId = 1; tId <= totalSupply; tId++) {
                if (theNFTContract.tokenTypeByTokenId(tId) == 2) {
                    (uint256 villainPlayingVillainType, uint256 villainCityId,,,,,,) = theNFTContract.villains(tId);
                    if (villainCityId == _cityId && villainPlayingVillainType <= _villainType) {
                        result[i] = tId;
                        i++;
                    }
                }
            }

            return result;
        }
    }

    /*
    function getIdsVillainByCityId(uint256 _cityId, uint256 _villainType) public view returns(uint256 villainId) {
        uint256 totalSupply = theNFTContract.totalSupply();

        uint256 villainId = 0;

        if (totalSupply == 0) {
            return villainId;
        } else {
            uint256 tId;
            uint256 totalVillains = 0;
            for (tId = 1; tId <= totalSupply; tId++) {
                //if (keccak256(abi.encodePacked(theNFTContract.tokenTypeByTokenId(tId))) == keccak256("villain")) {
                //    (uint256 villainPlayingVillainType, uint256 villainCityId,,,,,,) = theNFTContract.villains(tId);
                //    if (villainCityId == _cityId && villainPlayingVillainType <= _villainType) {
                        totalVillains++;
                //    }
                //}
            }

            uint256 i = 0;
            uint256 randN = generateStats(totalVillains)[0];

            for (tId = 1; tId <= totalSupply; tId++) {
                //if (keccak256(abi.encodePacked(theNFTContract.tokenTypeByTokenId(tId))) == keccak256("villain")) {
                //    (uint256 villainPlayingVillainType, uint256 villainCityId,,,,,,) = theNFTContract.villains(tId);
                //    if (villainCityId == _cityId && villainPlayingVillainType <= _villainType) {
                        if (i == randN) {
                            villainId = tId;
                        }
                        i++;
                //    }
                //}
            }

            return villainId;
        }
    }
    */

    function setFeeAddress(address _feeAddress) public {
        require(_feeAddress != address(0), "setFeeAddress: invalid address");
        require(msg.sender == feeAddress, "setFeeAddress: FORBIDDEN");
        feeAddress = _feeAddress;
        emit SetFeeAddress(msg.sender, _feeAddress);
    }

    function generateStats(uint256 maxStatValue) public view returns(uint256[] memory){
        // generate psuedo-randomHash
        uint256 randomHash = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));

        // build an array of predefined length
        uint256[] memory stats = new uint256[](10);

        // iterate over the number of stats we want a random number for
        for(uint256 i; i < 10; i++){
            // use random number to get number between 0 and maxStatValue
            stats[i] = randomHash % maxStatValue;

            // byte shift randomHash to the right 8 bytes - can be fewer
            randomHash >>= 8;
        }

        return stats;
    }
}