// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Interfaces.sol";

contract ZaiFighting is Ownable, ERC721Holder {

    IAddresses public gameAddresses;

    uint256 _nonce = 1;

    event FightResult(uint256 indexed zaiId, uint256 challengerId, uint256[27] progress);

    uint256[4] public staminaRegenerationDuration = [600,480,360,180]; // in seconds

    uint256 public xpRewardByFight = 2000;

    mapping(uint256 => uint256) _zaiStamina;
    mapping(uint256 => uint256) _firstOf5FightTimestamp;

    function setGameAddresses(address _address) external onlyOwner {
        gameAddresses = IAddresses(_address);
    }

    function setRegenerationDuration(uint256[4] memory _durations) external onlyOwner{
        require(
            _durations[0] <= 1000 &&
            _durations[1] <= 1000 &&
            _durations[2] <= 1000 &&
            _durations[3] <= 1000,
            "excessive durations"
            );
        staminaRegenerationDuration[0] = _durations[0];
        staminaRegenerationDuration[1] = _durations[1];
        staminaRegenerationDuration[2] = _durations[2];
        staminaRegenerationDuration[3] = _durations[3];
    }

    function setXpRewardByFight(uint256 _xp) external onlyOwner{
        xpRewardByFight = _xp;
    }

    function getZaiStamina(uint256 _zaiId) external view returns(uint256){
        ZaiStruct.Zai memory z = IZaiNFT(gameAddresses.getZaiAddress()).getZai(_zaiId);
        (uint256 result, ) = _getZaiStamina(_zaiId,z);
        return result;
    }

    function _getZaiStamina(uint256 _zaiId,ZaiStruct.Zai memory z) internal view returns(uint256 stamina,uint256 added){
        uint256 _result;
        uint256 _added;
        // if no fight return max stamina : 5
        if(_firstOf5FightTimestamp[_zaiId] == 0){
            _result = 5;
        }else {
            // take the old variable
            _result = _zaiStamina[_zaiId];
            // calculate time passed since the last fight
            uint256 _timeSinceLastFight = block.timestamp - _firstOf5FightTimestamp[_zaiId];
            // if there is > 1 stamina duration
            if(_timeSinceLastFight >= staminaRegenerationDuration[z.metadata.state]){
                // calculate number of stamina to add no need modulo cause in solidity 100 / 60 = 1
                _added = _timeSinceLastFight / staminaRegenerationDuration[z.metadata.state];
                // max stamina is 5
                if(_result + _added >= 5){
                    _result = 5;
                }else{
                    _result += _added;
                }           
            } 
        }
        return (_result, _added);
    }

    function _updateStamina(uint256 _zaiId, ZaiStruct.Zai memory z) internal returns(bool){

        //reload 
        (uint256 stamina, uint256 added)= _getZaiStamina(_zaiId, z);
        _zaiStamina[_zaiId] = stamina;
        require(_zaiStamina[_zaiId] > 0, "exhausted Zai!");
        
        if(stamina == 5){
           _firstOf5FightTimestamp[_zaiId] = block.timestamp; 
        }else{
           _firstOf5FightTimestamp[_zaiId] += (added * staminaRegenerationDuration[z.metadata.state]);
        }
        // reduce stamina counter
        _zaiStamina[_zaiId] -= 1; //
        return true;
    }

    function useRestPotion(uint256 _zaiId, uint256 _potionId) external returns(uint256){        
        require(
            IZaiNFT(gameAddresses.getZaiAddress()).ownerOf(_zaiId) == msg.sender ||
            IDelegate(gameAddresses.getDelegateZaiAddress()).gotDelegationForZai(_zaiId,msg.sender)
            , "Not your zai");
        PotionStruct.Potion memory p = IPotions(gameAddresses.getPotionAddress()).getFullPotion(_potionId);
        require(p.powers.rest > 0, "Not a rest p");
        IPotions(gameAddresses.getPotionAddress()).burnPotion(_potionId);
        _zaiStamina[_zaiId] += p.powers.rest;
        return _zaiStamina[_zaiId];
    }

    // _elements (0: water ; 1: fire ; 2:metal ; 3:air ; 4:stone)
    function initFighting(
        uint256 _zaiId,
        uint256[9] memory _elements,
        uint256[9] memory _powers,
        uint256[3] memory _usedPotions 
        )
        external
        returns(
            uint256[27] memory result //[0: zaiId,1:myScore, 2:challengerScore, 3-11: ElementByRoundOfChallenger, 12-20: PowerUseByChallengerByRound, 21 number of potions used by challenger, 22-23-24 potions ID if relevent, 25 xpWon, 26 BZAI won ]
            ){
        // Create Interface ZaiNFT instance
        IZaiNFT IZai = IZaiNFT(gameAddresses.getZaiAddress());
        // Create Interface Delagation instance
        IDelegate IDel = IDelegate(gameAddresses.getDelegateZaiAddress());
        // store result of isDelegate for this Zai 
        bool isDelegated = IDel.gotDelegationForZai(_zaiId,msg.sender);
        // store owner address of Zai
        address ownerOfZai = IZai.ownerOf(_zaiId);
        // check if zai can be use by msg.sender (owner or got delegation)
        require(
            ownerOfZai == msg.sender ||
            isDelegated
            , "Not your zai");
        // store Zai NFT datas    
        ZaiStruct.Zai memory z = IZaiNFT(gameAddresses.getZaiAddress()).getZai(_zaiId);
        // check if Zai is not in training, working or coaching. Must be free
        require(z.activity.statusId == 0,"Not free");
        // update stamin of Zai
        require(_updateStamina(_zaiId,z));

        // update loot progress (weekly reward when you play all days)
        ILootProgress(gameAddresses.getLootAddress()).updateUserProgress(msg.sender);

        // create Potions interface
        IPotions Potions = IPotions(gameAddresses.getPotionAddress());

        // if msg.sender use potions in this fight transfer them to fighting smart contract
        for(uint256 i = 0 ; i < 3 ; ){
            if(_usedPotions[i] != 0){
                Potions.transferFrom(msg.sender,address(this),_usedPotions[i]);
            }
            unchecked{ ++i; }
        }

        // check if user respect number of powers rule ( don't use more than Zai can use with potions or not)
        require(
            _isPowersUsedCorrect(
                _getZaiPowersByElement(z,_usedPotions,Potions),
                _getUsedPowersByElement(_elements,_powers)
            ),"cheat!");

        // update daily and weekly ranking
        require(IRanking(gameAddresses.getRankingContract()).updatePlayerRankings(msg.sender));

        // create array that's be returned by the function
        uint256[27] memory _toReturn;

        // get a challenger (can't be the same Zai used by the user)
        uint256 _challengerId = 
            ILevelStorage(
                gameAddresses.getLevelStorageAddress())
                .getRandomZaiFromLevel(z.level, _zaiId);

        // store zaiId for futur call of _updateCounterWinLoss
        _toReturn[0] = _zaiId;

        // store in memory challenger Zai NFT Datas
        ZaiStruct.Zai memory c = IZai.getZai(_challengerId);

        // create randoms 
        uint256[20] memory _randoms = _generateRandomDatas(msg.sender);

        // create challenger pattern (if challenger got an "old" pattern, use it)
        _toReturn = _getNewPattern(_randoms,c,Potions,_toReturn);

        // update the fighting progress in the return array
        _toReturn = _updateFightingProgress( _toReturn,_elements,_powers);

        // update all counters 
        _toReturn[25] = _getXpToWin(_usedPotions,z,_powers,Potions);
        _toReturn = _updateCounterWinLoss(z,ownerOfZai,_toReturn,IDel,isDelegated);

        // create event of fight
        emit FightResult(_zaiId, _challengerId, _toReturn);
        
        return(_toReturn);
    }

    function _updateFightingProgress(uint256[27] memory _toReturn, uint256[9] memory _elements, uint256[9] memory _powers) internal pure returns (uint256[27] memory){
        for(uint8 i = 0 ; i < 9 ;){
            if(_winTheRound(_elements[i],_toReturn[i+3]) == 1){
                _toReturn[1] += _powers[i]; // My score
            }else if(_winTheRound(_elements[i],_toReturn[i+3]) == 0){
                _toReturn[2] += _toReturn[i+12]; //challenger score
            }else if(_winTheRound(_elements[i],_toReturn[i+3]) == 2){ // draw round (player who have the more point score the difference between)
                if(_powers[i] > _toReturn[i+12]){
                    _toReturn[1] +=  (_powers[i] - _toReturn[i+12]);
                }
                if(_toReturn[i+12] > _powers[i]){
                    _toReturn[2] +=  (_toReturn[i+12] - _powers[i]);
                }
            }
            unchecked{ ++i; }
        }
        return _toReturn;
    }

    function _getXpToWin(
        uint256[3] memory _usedPotions,
        ZaiStruct.Zai memory z,
        uint256[9] memory _powers,
        IPotions Potions
        )
         internal returns(uint256){

        uint256 _xp = xpRewardByFight;

        uint256[5] memory powers = _getZaiPowersByElement(z,_usedPotions,Potions);
        uint256 _totalPowers = powers[0] + powers[1] + powers[2] + powers[3] + powers[4];
        uint256 _totalUsedPowers;
        for(uint256 i=0 ; i<9 ;){
            _totalUsedPowers += _powers[i];
            unchecked{ ++i; }
        }
        _xp = (_xp * 100) / 2;
        uint256 _ratio = _xp / _totalPowers;
        uint256 _toReduce = _ratio * _totalUsedPowers;
        _xp = ((2 * _xp) - _toReduce) / 100 ;

        for(uint256 i = 0; i < 3;){
            if(_usedPotions[i] !=0){
                PotionStruct.Potion memory p = Potions.getFullPotion(_usedPotions[i]);
                require(p.powers.rest == 0, "rest potion!");
                if(p.powers.xp > 0){
                    require(Potions.burnPotion(_usedPotions[i]));
                    _xp = _xp + (p.powers.xp * xpRewardByFight);
                }
            }
            unchecked{ ++i; }
        }
        return _xp;
    }

    // return [water,fire,metal,air,stone,numberOfusedPotions,potionId1,potionId2,potionId3]
    function _getchallengerPowers(
        ZaiStruct.Zai memory c, 
        IPotions Potions, 
        uint256[20] memory _random) 
        internal returns(uint256[10] memory){

        uint256[10] memory  _result;
        _result[0] = c.powers.water;
        _result[1] = c.powers.fire;
        _result[2] = c.powers.metal;
        _result[3] = c.powers.air;
        _result[4] = c.powers.stone;

        _result[5] = _random[10] % 4;

        if(_result[5] > 0){
            uint256 _potionBalanceOfContract = Potions.balanceOf(address(this));

            for(uint256 i = 0 ; i < _result[5]; ){
                uint256 _potionId = Potions.tokenOfOwnerByIndex(address(this),_random[i] % _potionBalanceOfContract);

                _result[i+6] = _potionId; 

                PotionStruct.Potion memory p = Potions.getFullPotion(_potionId);

                if(_potionBalanceOfContract > 100){
                    Potions.burnPotion(_potionId);
                    _potionBalanceOfContract -= 1;
                }
                if(p.powers.water > 0){
                    _result[0] += p.powers.water; 
                }
                if(p.powers.fire > 0){
                    _result[1] += p.powers.fire; 
                }
                if(p.powers.metal > 0){
                    _result[2] += p.powers.metal; 
                }
                if(p.powers.air > 0){
                    _result[3] += p.powers.air; 
                }
                if(p.powers.stone > 0){
                    _result[4] += p.powers.stone; 
                }
                unchecked{ ++i; }
            }
        }     
        if(_result[0] > 0){
            _result[9] += 1;
        } 
        if(_result[1] > 0){
            _result[9] += 1;
        }  
        if(_result[2] > 0){
            _result[9] += 1;
        }
        if(_result[3] > 0){
            _result[9] += 1;
        }
        if(_result[4] > 0){
            _result[9] += 1;
        }
        return _result;
    }

    function _updateCounterWinLoss(
        ZaiStruct.Zai memory z,
        address ownerOfZai,
        uint256[27] memory _toReturn,
        IDelegate IDel,
        bool isDelegated 
        ) internal returns(uint256[27] memory){

        IZaiNFT IZai = IZaiNFT(gameAddresses.getZaiAddress());
        require(IStats(gameAddresses.getZaiStatsAddress()).updateCounterWinLoss(_toReturn[0],_toReturn), "Stat issue");

        uint256 _xpWon = xpRewardByFight / 10;
        uint256 _bzaiWon;
        if(_toReturn[1] < _toReturn[2]){
            _toReturn[25] = _xpWon;
        }else if(_toReturn[1] == _toReturn[2]){
            _toReturn[25] = _xpWon * 2;
        }else{
            _bzaiWon = IRewardsWinningFound(gameAddresses.getWinRewardsAddress()).getWinningRewards();
            if(isDelegated){
                (address _scholarAddress,address _owner,,,uint256 percentageForScholar,) = IDel.getDelegateDatasByZai(_toReturn[0]);
                require(IDel.updateLastScholarPlayed(_toReturn[0]));
                _paySchoolarAndOwner(_scholarAddress, _owner, percentageForScholar, _bzaiWon);
                _bzaiWon = _bzaiWon * percentageForScholar / 100;

            }else{
                address paymentAddress = gameAddresses.getPaymentsAddress();
                require(IPayments(paymentAddress).rewardPlayer(ownerOfZai,_bzaiWon));
            }
        }
        if(IZai.updateXp(_toReturn[0],_toReturn[25]) > z.level){
            _zaiStamina[_toReturn[0]] = 5;
        }

        _toReturn[26] = _bzaiWon;
        return _toReturn;

    }

    function _paySchoolarAndOwner(address _schoolar, address _owner, uint256 _percentageForSchoolar, uint256 _reward) internal returns(bool){
                
        IPayments payment = IPayments(gameAddresses.getPaymentsAddress());

        require(payment.rewardPlayer(_owner,_reward * (100 - _percentageForSchoolar) / 100));
        return(payment.rewardPlayer(_schoolar,(_reward * _percentageForSchoolar / 100)));
    }

    function _getNewPattern(
        uint256[20] memory _randoms,
        ZaiStruct.Zai memory c,
        IPotions Potions,
        uint256[27] memory _toReturn
        ) 
        internal returns(
            uint256[27] memory result
        ){
            uint256[10] memory _cPowers = _getchallengerPowers(c,Potions,_randoms);
            _toReturn[21] = _cPowers[5];

            uint8[] memory _activePowers = new uint8[](_cPowers[9]);
            for(uint8 i = 0 ; i < _cPowers[9];){
                if(_cPowers[i] > 0){
                    _activePowers[i] = i;
                }
                unchecked {++i;}
            }

            if(_cPowers[5] > 0){
                for(uint256 i = 0 ; i < _cPowers[5] ; ){
                    _toReturn[i + 22] =  _cPowers[i + 6];
                    unchecked{ ++i; }
                }
            }

            // get a random order like [8,5,3,7,6,1,2,4,0]
            // allows a true random distribution of challenger powers. (not only big hit at begining of fight)
            uint8[9] memory randomOrder = _getRandomOrder(_randoms); 

            for(uint8 i = 0 ; i < 9 ; ){
                // define _toReturn [3 to 11] element of power (fire, water...) 
                _toReturn[randomOrder[i]+3] = _activePowers[_randoms[i] % _cPowers[9]];
                unchecked{ ++i; }
            }

            for(uint8 i = 0 ; i < 9 ;){
                // apply a power points amount only if challenger got more than 0 point in his element of power
                uint256 _points;
                if(_cPowers[_toReturn[randomOrder[i]+3]] > 0){
                    if(i >= 6){
                        _points = _cPowers[_toReturn[randomOrder[i]+3]];
                        _toReturn[randomOrder[i]+12] = _points;  
                        _cPowers[_toReturn[randomOrder[i]+3]] = 0; 
                    }else{
                        // generate random points between 1 to value of challenger points got in this element of power 
                        _points = (_randoms[i+5] % _cPowers[_toReturn[randomOrder[i]+3]]) + 1;
                        // apply points
                        _toReturn[randomOrder[i]+12] = _points;   
                        // substrate those points from power points . for not using 2 times the amount of point  
                        _cPowers[_toReturn[randomOrder[i]+3]] -= _points;
                    }

                }else{
                    if(i >= 6){
                        if(_randoms[i] % _cPowers[9] >= 0 && _randoms[i] % _cPowers[9] < _cPowers[9] - 1){
                            _toReturn[randomOrder[i]+3] = _randoms[i] % _cPowers[9] + 1;
                            _toReturn[randomOrder[i]+12] = _cPowers[_toReturn[randomOrder[i]+3]];
                            if(_toReturn[randomOrder[i]+12] == 0){
                                _toReturn[randomOrder[i]+3] = 5; // 5 is code for non power hit 
                                _toReturn[randomOrder[i]+12] = 0;    
                            }
                        } else if(_randoms[i] % _cPowers[9] <= _cPowers[9] && _randoms[i] % _cPowers[9] > 0){
                            _toReturn[randomOrder[i]+3] = _randoms[i] % _cPowers[9] - 1;
                            _toReturn[randomOrder[i]+12] = _cPowers[_toReturn[randomOrder[i]+3]];
                            if(_toReturn[randomOrder[i]+12] == 0){
                                _toReturn[randomOrder[i]+3] = 5; // 5 is code for non power hit 
                                _toReturn[randomOrder[i]+12] = 0;    
                            }   
                        }   
                    }else{
                        _toReturn[randomOrder[i]+3] = 5; // 5 is code for non power hit 
                        _toReturn[randomOrder[i]+12] = 0;     
                    }
                }

                unchecked { ++i; }
            }

            return (_toReturn);
    }

    function _getRandomOrder(uint256[20] memory _randoms) internal pure returns(uint8[9]memory){
            uint8[9] memory randomOrder = [0,1,2,3,4,5,6,7,8];
            for(uint256 r = 8 ; r > 0 ; ){
                uint256 randomIndex = _randoms[r] % 9;
                uint8 _temp = randomOrder[r];
                randomOrder[r] = randomOrder[randomIndex];
                randomOrder[randomIndex] =_temp;
                unchecked{ --r; }
            }
            return randomOrder;
    }

    function _winTheRound(uint256 _myHit, uint256 _challengerHit) internal pure returns(uint8){
        uint8 _result;
        if(
            _myHit == 0 && _challengerHit == 1 ||
            _myHit == 0 && _challengerHit == 2){
                _result = 1;
            } else if(
                _myHit == 1 && _challengerHit == 2 ||
                _myHit == 1 && _challengerHit == 3){
                   _result = 1;
            } else if(
                _myHit == 2 && _challengerHit == 3 ||
                _myHit == 2 && _challengerHit == 4){
                   _result = 1;
            } else if(
                _myHit == 3 && _challengerHit == 4 ||
                _myHit == 3 && _challengerHit == 0){
                   _result = 1;
            } else if(
                _myHit == 4 && _challengerHit == 0 ||
                _myHit == 4 && _challengerHit == 1){
                   _result = 1;
            } else if(_myHit != 5 && _challengerHit == 5){
                    _result = 1;
            } else if(_myHit == _challengerHit){
                _result = 2;
            }else{
                _result = 0;
            }
        return _result;
    }

    function _isPowersUsedCorrect(uint256[5] memory _got, uint256[5] memory _used ) internal pure returns(bool){
        return (
            _got[0] >= _used[0] &&
            _got[1] >= _used[1] &&
            _got[2] >= _used[2] &&
            _got[3] >= _used[3] &&
            _got[4] >= _used[4] 
            );
    }

    function _getUsedPowersByElement(uint256[9] memory _elements,uint256[9] memory _powers)internal pure returns(uint256[5] memory){
        uint256[5] memory usedPowers;
        for(uint256 i = 0 ; i < 9 ; ){
            require(_elements[i] <= 5, "Element !valid"); // 5 is non element
            if(_powers[i] == 0){
                require(_elements[i] == 5, "Cheat!");
            }
            if(_powers[i] > 0 && _elements[i] != 5){
                usedPowers[_elements[i]] += _powers[i];
            }
            unchecked{ ++i; }
        }
        return usedPowers;
    }

    function _getZaiPowersByElement(ZaiStruct.Zai memory z,uint256[3] memory _potions,IPotions Potions) internal view returns(uint256[5] memory){
        uint256[5] memory _powers = [z.powers.water,z.powers.fire,z.powers.metal,z.powers.air,z.powers.stone];

        if(_potions.length > 0){
            for (uint256 i = 0 ; i < _potions.length ; i++){

                PotionStruct.Potion memory p = Potions.getFullPotion(_potions[i]);

                if(p.powers.water > 0){
                    _powers[0] += p.powers.water; 
                }
                if(p.powers.fire > 0){
                    _powers[1] += p.powers.fire; 
                }
                if(p.powers.metal > 0){
                    _powers[2] += p.powers.metal; 
                }
                if(p.powers.air > 0){
                    _powers[3] += p.powers.air; 
                }
                if(p.powers.stone > 0){
                    _powers[4] += p.powers.stone; 
                }
            }
        }
        return _powers;
    }

    // utils

    function _generateRandomDatas(address _user) private returns (uint256[20] memory) {
        uint256 r = IOracle(gameAddresses.getOracleAddress()).getRandom(keccak256(abi.encodePacked(_user,_nonce,block.timestamp)));
        _nonce += 1;
        uint256 [20] memory randoms;
        for (uint256 i = 0; i < 20; ){
            randoms[i] = uint256(r / 10); 
            unchecked{ ++i; }
        }
        return(randoms);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library ZaiStruct {
        // Zai powers
    // Zai powers
    struct Powers {
        uint256 water;
        uint256 fire;
        uint256 metal;
        uint256 air;
        uint256 stone;
    }

    // A zai can work in a center , training or coaching. He can't fight if he isn't free
    //string[4] _status = ["Free","Training","Coaching","Working"];
    struct Activity{
        uint256 statusId;
        uint256 onCenter;
    }

    struct ZaiMetaData{
        uint256 state; // _states index
        uint256 ipfsPathId;
        uint256 seasonOf;
    }

    struct Zai {
        string name;
        uint256 xp; 
        uint256 alchemyXp;
        uint256 level;
        uint256 creditForUpgrade; // credit to use to raise powers
        Powers powers;
        Activity activity;
        ZaiMetaData metadata;
    }

    struct Stats {
        uint256 zaiTotalWins;
        uint256 zaiTotalDraw;
        uint256 zaiTotalLoss;
        uint256 zaiTotalFights;
        uint256 zaiTotalRandomSelected;  
    }

    struct ZaiLastPattern{
        bool gotPattern;
        uint256[9] elements;
        uint256[9] powers;
        uint256[] usedPotions;
    }

    struct EggsPrices {
        uint256 bronzePrice;
        uint256 silverPrice;
        uint256 goldPrice;
        uint256 platinumPrice;
    }

    struct MintedData {
        uint256 bronzeMinted;
        uint256 silverMinted;
        uint256 goldMinted;
        uint256 platinumMinted;
    }

    struct WorkInstance {
        uint256 zaiId;
        uint256 beginingAt;
    }

}

library PotionStruct {
    struct Powers {
        uint256 water;
        uint256 fire;
        uint256 metal;
        uint256 air;
        uint256 stone;
        uint256 rest;
        uint256 xp;
    }

    struct Potion {
        Powers powers;
        uint256 potionType; // 0: water ; 1: fire ; 2:metal ; 3:air ; 4:stone  ; 5:rest ; 6:xp ; 7:multiple
        address seller;
        uint256 listingPrice;
        uint256 fromLab;
        uint256 potionId;
        uint256 saleTimestamp;
    }
}

interface IOracle {
    function getRandom(bytes32 _id) external returns (uint256);
}

interface IZaiMeta {
    function getState(uint256 state) external view returns(string memory);

    function godNames(uint256 _ipfsId) external view returns(string memory);

    function getRandomPowers(uint256 level, uint256 _points, uint256 random) external view returns(ZaiStruct.Powers memory);

    function getGodsPowers(uint256 _ipfsId) external view returns(ZaiStruct.Powers memory);

    function updatePowers(uint256 level, ZaiStruct.Powers memory powers, ZaiStruct.Powers memory toAdd) external view returns(ZaiStruct.Powers memory);

    function getLevel(uint256 _xp) external view returns (uint256);

    function getNextLevelUpPoints(uint256 _level) external view returns(uint256);
}

interface IZaiNFT is IERC721Enumerable {

    function mintZai(address _to,string memory _name,uint256 _state) external returns (uint256);

    function burnZai(uint256 _tokenId) external;

    function updateStatus(uint256 _tokenId, uint256 _newStatusID, uint256 _center) external;

    function updateXp(uint256 _id,uint256 _xp) external returns (uint256 level);

    function isFree(uint256 _tokenId) external view returns(bool);

    function updateAlchemyXp(uint256 _tokenId, uint256 _xpRaised) external;

    function getZai(uint256 _tokenId) external view returns(ZaiStruct.Zai memory);
    
    function getNextLevelUpPoints(uint256 _level) external view returns(uint256);
    
}

interface IipfsIdStorage {
    function getTokenURI(uint256 _season, uint256 _state, uint256 _id) external view returns(string memory);

    function getNextIpfsId(uint256 _state) external returns(uint256);

    function getCurrentSeason() external view returns(uint256);
}

interface ILaboratory is IERC721Enumerable{
    function mintLaboratory(address _to) external returns (uint256);

    function burn(uint256 _tokenId) external;

    function getCreditLastUpdate(uint256 _tokenId) external view returns(uint256);

    function updateCreditLastUpdate(uint256 _tokenId) external returns(bool);

    function numberOfWorkingSpots(uint256 _tokenId) external view returns(uint256);

    function updateNumberOfWorkingSpots(uint256 _tokenId) external returns(bool);

    function getPreMintNumber() external view returns(uint256);
}

interface ILabManagement{
    function createdPotionsForLab(uint256 _tokenId) external view returns(uint256);

    function laboratoryRevenues(uint256 _tokenId) external view returns(uint256);

    function getCredit(uint256 _laboId) external view returns(uint256);

    function workingSpot(uint256 _laboId, uint256 _slotId) external view returns(ZaiStruct.WorkInstance memory);

    function cleanSlotsBeforeClosing(uint256 _laboId) external returns(bool);

}

interface IBZAI is IERC20{
    function burn(uint256 _amount) external returns(bool);
}

interface ITraining is IERC721Enumerable{
    function mintTrainingCenter(address _to) external returns (uint256);

    function burn(uint256 _tokenId) external;

    function numberOfTrainingSpots(uint256 _tokenId) external view returns(uint256);

    function addTrainingSpots(uint256 _tokenId, uint256 _amount) external returns(bool);

    function getPreMintNumber() external view returns(uint256);

}

interface ITrainingManagement {
    function cleanSlotsBeforeClosing(uint256 _laboId) external returns(bool);
}



interface INursery is IERC721Enumerable{
    function mintNursery(address _to, uint256 _bronzePrice, uint256 _silverPrice, uint256 _goldPrice, uint256 _platinumPrice) external returns (uint256);

    function burnNursery(uint256 _tokenId) external;

    function burn(uint256 _tokenId) external;

    function nextStateToMint(uint256 _tokenId) external view returns (uint256);

    function getEggsPrices(uint256 _nursId) external view returns(ZaiStruct.EggsPrices memory);

    function getNurseryMintedDatas(uint256 _tokenId) external view returns (ZaiStruct.MintedData memory);

    function getNextUnlock(uint256 _tokenId) external view returns (uint256);

    function getPreMintNumber() external view returns(uint256);

    function nurseryRevenues(uint256 _tokenId) external view returns(uint256);

    function nurseryMintedDatas(uint256 _tokenId) external view returns(ZaiStruct.MintedData memory);

}

interface ILottery is IERC721Enumerable{
    function getLotteryPrices() external view returns(uint256 _ticket, uint256 _bronze, uint256 _silver, uint256 _gold);
}

interface IStaking {
    function receiveFees(uint256 _amount) external;
}

interface IBZAIToken {
    function burnToken(uint256 _amount) external;
}

interface IPayments {
    function payOwner(address _owner, uint256 _value) external returns(bool);

    function distributeFees(uint256 _amount) external returns(bool);

    function getMyReward(address _user) external view returns(uint256);

    function useReward(address _user, uint256 _amount) external returns(bool);

    function rewardPlayer(address _user, uint256 _amount) external returns(bool);
}

interface IEggs is IERC721Enumerable{

    function mintEgg(address _to,uint256 _state,uint256 _maturityDuration) external returns (uint256);

    function burnEgg(uint256 _tokenId) external returns(bool);

    function isMature(uint256 _tokenId) external view returns(bool);

    function getStateIndex(uint256 _tokenId) external view returns (uint256);
}

interface IPotions is IERC721Enumerable{
    function mintPotionForSale(uint256 _fromLab,uint256 _price,uint256 _type, uint256 _power) external returns (uint256);

    function offerPotion(uint256 _type,uint256 _power,address _to) external returns (uint256);

    function updatePotion(uint256 _tokenId) external; 

    function burnPotion(uint256 _tokenId) external returns(bool);

    function getPotion(uint256 _tokenId) external view returns(address seller, uint256 price, uint256 fromLab);

    function buyPotion(address _to, uint256 _type) external returns (uint256);

    function mintMultiplePotion(uint256[7] memory _powers, address _owner) external returns(uint256);

    function changePotionPrice(uint256 _tokenId, uint256 _laboId, uint256 _price) external returns(bool);

    function updatePotionSaleTimestamp(uint256 _tokenId) external returns(bool);

    function getFullPotion(uint256 _tokenId) external view returns(PotionStruct.Potion memory);
}

interface IAddresses {
    function getBZAIAddress() external view returns(address);

    function getOracleAddress() external view returns(address);

    function getStakingAddress() external view returns(address); 

    function getZaiAddress() external view returns(address);

    function getIpfsStorageAddress() external view returns(address);

    function getLaboratoryAddress() external view returns(address);

    function getLaboratoryNFTAddress() external view returns(address);

    function getTrainingCenterAddress() external view returns(address);

    function getTrainingNFTAddress() external view returns(address);

    function getNurseryAddress() external view returns(address);

    function getPotionAddress() external view returns(address);

    function getTeamAddress() external view returns(address);

    function getGameAddress() external view returns(address);

    function getEggsAddress() external view returns(address);

    function getLotteryAddress() external view returns(address);

    function getPaymentsAddress() external view returns(address);

    function getChallengeRewardsAddress() external view returns(address);

    function getWinRewardsAddress() external view returns(address);

    function getOpenAndCloseAddress() external view returns(address);

    function getAlchemyAddress() external view returns(address);

    function getChickenAddress() external view returns(address);

    function getReserveChallengeAddress() external view returns(address);

    function getReserveWinAddress() external view returns(address);

    function getWinChallengeAddress() external view returns(address);

    function isAuthToManagedNFTs(address _address) external view returns(bool);

    function isAuthToManagedPayments(address _address) external view returns(bool);

    function getLevelStorageAddress() external view returns(address);

    function getRankingContract() external view returns(address);

    function getAuthorizedSigner() external view returns(address);

    function getDelegateZaiAddress() external view returns(address);

    function getZaiStatsAddress() external view returns(address);

    function getLootAddress() external view returns(address);
}

interface IOpenAndClose {

    function getLaboCreatingTime(uint256 _tokenId) external view returns(uint256);

    function getNurseryCreatingTime(uint256 _tokenId) external view returns(uint256);

    function canLaboSell(uint256 _tokenId) external view returns (bool);

    function canTrain(uint256 _tokenId) external view returns (bool);

    function canNurserySell(uint256 _tokenId) external view returns (bool);

    function nurseryMinted()external view returns(uint256);

    function laboratoryMinted()external view returns(uint256);

    function trainingCenterMinted()external view returns(uint256);

    function getLaboratoryName(uint256 _tokenId) external view returns(string memory);

    function getNurseryName(uint256 _tokenId) external view returns(string memory);

    function getNurseryState(uint256 _tokenId) external view returns (string memory);

    function getTrainingCenterName(uint256 _tokenId) external view returns(string memory);

    function getLaboratoryState(uint256 _tokenId) external view returns (string memory);

}

interface IReserveForChalengeRewards {
    function getNextUpdateTimestamp() external view returns(uint256);

    function getRewardFinished() external view returns(bool);

    function updateRewards() external returns(bool);
}

interface IReserveForWinRewards {
    function getNextUpdateTimestamp() external view returns(uint256);

    function getRewardFinished() external view returns(bool);

    function updateRewards() external returns(bool);
}

interface ILevelStorage {
     function addFighter(uint256 _level, uint256 _zaiId) external returns(bool);

     function removeFighter(uint256 _level, uint256 _zaiId) external returns (bool);

     function getLevelLength(uint256 _level) external view returns(uint256);
     
     function getRandomZaiFromLevel(uint256 _level, uint256 _idForbiden) external returns(uint256 _zaiId);
}

interface IRewardsRankingFound {
    function getDailyRewards(address _rewardStoringAddress) external returns(uint256);

    function getWeeklyRewards(address _rewardStoringAddress) external returns(uint256);
}

interface IRewardsWinningFound {
    function getWinningRewards() external returns(uint256);
}

interface IRanking {
    function updatePlayerRankings(address _user) external returns(bool);

    function getDayBegining() external view returns(uint256);
}

interface IDelegate {
    function gotDelegationForZai(uint256 _zaiId, address _user) external view returns(bool);

    function getDelegateDatasByZai(uint256 _zaiId) external view returns(
        address scholarAddress,
        address zaiOwner,
        uint256 contractDuration,
        uint256 contractEnd,
        uint256 percentageForScholar,
        uint256 lastScholarPlayed
        );

    function isZaiDelegated(uint256 _zaiId) external view returns(bool);

    function updateLastScholarPlayed(uint256 _zaiId) external returns(bool);
}

interface IStats {
    function updateCounterWinLoss(uint256 _zaiId,uint256[27] memory _fightProgress) external returns(bool result);

    function getZaiStats(uint256 _zaiId) external view returns(uint256[5] memory);

    function updateAllPowersInGame(ZaiStruct.Powers memory toAdd) external returns(bool);
}

interface IFighting{
    function getZaiStamina(uint256 _zaiId) external view returns(uint256);
}

interface ILootProgress {
    function updateUserProgress(address _user) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}