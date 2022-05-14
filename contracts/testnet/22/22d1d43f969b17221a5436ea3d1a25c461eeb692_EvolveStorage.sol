/* SPDX-License-Identifier: MIT OR Apache-2.0 */
pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;
import "./Ownable.sol";
import "./Context.sol";
import "./SafeMath.sol";
import "./IEvolveStorage.sol";

contract EvolveStorage is  Context, Ownable, IEvolveStorage{
    using SafeMath for uint256;

    address public factoryAddrss;
    uint256 internal startCompetitionId = 0;
    uint256 internal startPresetId = 0;


    

   
    

    mapping(uint256 => Preset) public presetList;
    mapping(uint256 => Competion ) public competionList;


    constructor(){
        factoryAddrss = _msgSender();
    }
   /* -------------------------------------------------------------------------- */
   /*                                 permissions                                */
    modifier ownerOrFactory {
        require(_msgSender() == factoryAddrss || _msgSender() == owner() || owner() == tx.origin , "To call this method you have to be owner or subAdmin!");
         _;
    }

    function updateFactoryAddress(address _factory) external override onlyOwner returns(bool result){
        factoryAddrss = _factory;
        result = true;
    }
   /* -------------------------------------------------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                        work with Competition methods                       */



    //    enum CompetionWinner {TEAMA , TEAMB , DRAW, OPEN}
    function updateCompetionWinner(uint _competionId, uint8 _winnerTeam) external override ownerOrFactory returns(bool){
        require(isExistsCompetionList(_competionId), "can't find competion with this competionId!");
        require(_winnerTeam >= 0 && _winnerTeam <= 3, "winner need to be somting between 0 to 3");
        Competion storage competion = competionList[_competionId];
        if(_winnerTeam == 0){
            competion.winners = CompetionWinner.TEAMA;
        }else if(_winnerTeam == 1){
            competion.winners = CompetionWinner.TEAMB;
        }else if(_winnerTeam == 2){
            competion.winners = CompetionWinner.DRAW;
        }else if(_winnerTeam == 3){
            competion.winners = CompetionWinner.OPEN;
        }
        
        return true;
    }



    //  enum CompetionStatus { PENDING, CANCELED, DONE }
    function updateCompetionStatus(uint _competionId, uint8 _status) external override ownerOrFactory returns(bool){
        require(isExistsCompetionList(_competionId), "can't find competion with this competionId!");
        require(_status >= 0 && _status <= 2, "status need to be somting between 0 to 2");
        Competion storage competion = competionList[_competionId];
        if(_status == 0){
            competion.status = CompetionStatus.PENDING;
        }else if(_status == 1){
            competion.status = CompetionStatus.CANCELED;
        }else if(_status == 2){
            competion.status = CompetionStatus.DONE;
        }
        return true;
    }

    function addNewCompetion(uint256 _presetId, address[] calldata _teamA, address[] calldata _teamB, uint256 _priceRate) external override ownerOrFactory returns(uint competionId){
        require(isExistsPresetList(_presetId), "can't find preset with this id!");
        competionList[startCompetitionId] = Competion(presetList[_presetId],_teamA, _teamB, CompetionStatus.PENDING, CompetionWinner.OPEN, _priceRate);
        competionId = startCompetitionId;
        startCompetitionId += 1;
    }


    /* -------------------------------------------------------------------------- */





   /* -------------------------------------------------------------------------- */
   /*                           work with presetMethods                          */
    function addNewPreset(uint256 _matchPrice, uint256 _numberOfTeamMemebr ) external override ownerOrFactory returns(uint presetId) {
        uint _lastPresetId = startPresetId;
        Preset memory currentPreset = Preset(_matchPrice, _numberOfTeamMemebr, block.timestamp);
        presetList[_lastPresetId] = currentPreset;
        startPresetId += 1;
        return _lastPresetId;
    }
   /* -------------------------------------------------------------------------- */

    // read methods 

    function getPreset(uint256 _presetId) external view override returns(uint256,uint256,uint256){
     return (presetList[_presetId].matchPrice, presetList[_presetId].numberOfTeamMemebr, presetList[_presetId].date);
    }

    function getCompetion(uint256 _competionId) external view override 
        returns(uint256 presetPrice,uint256 playerCount,address[] memory _teamA, address[] memory _teamB, uint _competionStatus, uint _competionWinner, uint256 _priceRate){
        Preset memory competionPreset = competionList[_competionId].preset;
        presetPrice = competionPreset.matchPrice;
        playerCount = competionPreset.numberOfTeamMemebr;
        _teamA = competionList[_competionId].teamA;
        _teamB = competionList[_competionId].teamB;
        _competionStatus = uint(competionList[_competionId].status);
        _competionWinner = uint(competionList[_competionId].winners);
        _priceRate = competionList[_competionId].priceRate;
    }
    

    // utilse methods

    function isExistsCompetionList(uint key) internal view returns (bool) {
        if(competionList[key].teamA.length != 0){
            return true;
        } 
        return false;
    }
     function isExistsPresetList(uint256 key) internal view returns (bool) {
        if(presetList[key].date != 0){
            return true;
        } 
        return false;
    }

}