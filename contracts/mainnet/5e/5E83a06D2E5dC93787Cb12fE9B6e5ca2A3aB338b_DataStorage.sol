//SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.4;

contract DataStorage {
    uint256 constant N_PETS = 9;
    uint256 constant N_EGGS = 6;
    uint256 constant BASE_POWER = 10000;
    uint256 constant SAMPLE_SPACE = 1e10;
    uint256 constant STEP = 1e9;

    uint256 constant BASE_POWER_LEVEL_FLOOR = 9000;
    uint256 constant BASE_POWER_LEVEL_CEILING = 18000;
    uint256 constant MAX_LEVEL = 8;

    uint256 constant MAX_CEILING = BASE_POWER_LEVEL_CEILING * 2 ** MAX_LEVEL;

    uint256[N_EGGS] private pandoBoxCreating;
    mapping (uint256 => mapping(uint256 => uint256)) private droidBotCreating;
    mapping (uint256 => mapping(uint256 => mapping(uint256 => uint256))) private droidBotUpgrading;
//    mapping (uint256 => uint256) ;
    uint256[N_PETS - 1] public nTickets;
    uint256[39] private droidBotUpgradingPower;

    /*----------------------------CONSTRUCTOR----------------------------*/

    constructor() {
        pandoBoxCreating = [9000000000 , 700000000, 200000000, 75000000, 20000000, 5000000];
        nTickets = [1, 2, 3, 4, 5, 8, 11, 17];
        droidBotCreating[0][0] = 9000000000;
        droidBotCreating[0][1] = 650000000;
        droidBotCreating[0][2] = 210400000;
        droidBotCreating[0][3] = 84160000;
        droidBotCreating[0][4] = 33664000;
        droidBotCreating[0][5] = 13465600;
        droidBotCreating[0][6] = 5386240;
        droidBotCreating[0][7] = 2154496;
        droidBotCreating[0][8] = 769664;


        droidBotCreating[1][0] = 0;
        droidBotCreating[1][1] = 9000000000;
        droidBotCreating[1][2] = 650000000;
        droidBotCreating[1][3] = 211000000;
        droidBotCreating[1][4] = 84400000;
        droidBotCreating[1][5] = 33760000;
        droidBotCreating[1][6] = 13504000;
        droidBotCreating[1][7] = 5401600;
        droidBotCreating[1][8] = 1934400;

        droidBotCreating[2][0] = 0;
        droidBotCreating[2][1] = 0;
        droidBotCreating[2][2] = 9000000000;
        droidBotCreating[2][3] = 650000000;
        droidBotCreating[2][4] = 212500000;
        droidBotCreating[2][5] = 85000000;
        droidBotCreating[2][6] = 34000000;
        droidBotCreating[2][7] = 13600000;
        droidBotCreating[2][8] = 4900000;

        droidBotCreating[3][0] = 0;
        droidBotCreating[3][1] = 0;
        droidBotCreating[3][2] = 0;
        droidBotCreating[3][3] = 9000000000;
        droidBotCreating[3][4] = 650000000;
        droidBotCreating[3][5] = 216500000;
        droidBotCreating[3][6] = 86600000;
        droidBotCreating[3][7] = 34640000;
        droidBotCreating[3][8] = 12260000;

        droidBotCreating[4][0] = 0;
        droidBotCreating[4][1] = 0;
        droidBotCreating[4][2] = 0;
        droidBotCreating[4][3] = 0;
        droidBotCreating[4][4] = 9000000000;
        droidBotCreating[4][5] = 650000000;
        droidBotCreating[4][6] = 227000000;
        droidBotCreating[4][7] = 90800000;
        droidBotCreating[4][8] = 32200000;

        droidBotCreating[5][0] = 0;
        droidBotCreating[5][1] = 0;
        droidBotCreating[5][2] = 0;
        droidBotCreating[5][3] = 0;
        droidBotCreating[5][4] = 0;
        droidBotCreating[5][5] = 9000000000;
        droidBotCreating[5][6] = 650000000;
        droidBotCreating[5][7] = 258000000;
        droidBotCreating[5][8] = 92000000;

        droidBotUpgradingPower = [21677600, 467803500, 920432600, 1324070400, 1286351300, 1117699200, 891514600, 685013400, 592623300, 466242700, 379523500, 305455300, 249691700, 201555400, 170942700, 135546800, 112981700, 102953600, 85578100, 71187600, 61826800, 52114800, 45516500, 38450100, 32944400, 28449300, 24660500, 21609100, 18850400, 16368800, 14152500, 12158600, 10363600, 8748200, 7292800, 5981700, 4803300, 3742000, 3121600];
    }

    /*----------------------------INTERNAL FUNCTIONS----------------------------*/

    function _powerToLevel(uint256 _oldLevel, uint256 _power) internal pure returns(uint256) {
        uint256 _baseCeiling = BASE_POWER_LEVEL_CEILING;
        uint256 _maxLevel = MAX_LEVEL;
        for(uint256 i = _oldLevel; i <= _maxLevel; i++) {
            if(_power < _baseCeiling * 2 ** i) {
                return i;
            }
        }
        return MAX_LEVEL;
    }

    function _getPowerUpgradeProbability(uint256 _rand) internal view returns(uint256) {
        uint256 _length = droidBotUpgradingPower.length;
        uint256 _cur = 0;
        for(uint i = 0; i < _length; i++ ) {
            _cur += droidBotUpgradingPower[i];
            if(_rand <= _cur) {
                return i + 2; //start from 20%
            }
        }
        return 0;
    }

    /*----------------------------EXTERNAL FUNCTIONS----------------------------*/

    function getPandoBoxPower() external pure returns(uint256) {
        return 0;
    }

    function getSampleSpace() external pure returns(uint256) {
        return SAMPLE_SPACE;
    }

    function getNewPowerLevel(uint256 _rand, uint256 _mainPower, uint256 _materialPower, uint256 _mainLevel) external view returns (uint256 , uint256) {
        uint256 _probability = _getPowerUpgradeProbability(_rand);
        uint256 _newPower = _mainPower + _materialPower * _probability * STEP / SAMPLE_SPACE;
        uint256 _ceiling = MAX_CEILING;
        if(_newPower >= _ceiling) {
            _newPower = _ceiling - 1;
        }
        uint256 _level = _powerToLevel(_mainLevel, _newPower);
        return (_level, _newPower);
    }

    // power
    // power based = (level - 10%)
    // power + rand ( < 20 %) => 90% < power < 110%
    function getDroidBotPower(uint256 _droidBotLevel, uint256 _rand) external pure returns (uint256) {
        uint256 _seed = _rand % 1000;
        uint256 _power = BASE_POWER * (2**(_droidBotLevel)) * 9 / 10;
        uint256 _r1 = _rand % 10;
        //30% greater than base
        if(_r1 >= 7) {
            _seed += 1000; // 10%
        }
        return _power + _power * _seed / BASE_POWER;
    }

    function getPandoBoxCreatingProbability() external view returns(uint256[] memory _pandoBoxCreating) {
        _pandoBoxCreating = new uint256[](N_EGGS);
        for (uint256 i = 0; i < N_EGGS; i++) {
            _pandoBoxCreating[i] = pandoBoxCreating[i];
        }
    }

    function getDroidBotCreatingProbability(uint256 _pandoBoxLevel) external view returns(uint256[] memory _droidBotCreating) {
        _droidBotCreating = new uint256[](N_PETS);
        for (uint256 i = 0; i < N_PETS; i++) {
            _droidBotCreating[i] = droidBotCreating[_pandoBoxLevel][i];
        }
    }

    function getDroidBotUpgradingProbability(uint256 _droidBot0Level, uint256 _droidBot1Level) external view returns(uint256[] memory _droidBotUpgrading) {
        _droidBotUpgrading = new uint256[](N_PETS);
        for (uint256 i = 0; i < N_PETS; i++) {
            _droidBotUpgrading[i] = droidBotUpgrading[_droidBot0Level][_droidBot1Level][i];
        }
    }

    function getNumberOfTicket(uint256 _lv) external view returns (uint256) {
        return nTickets[_lv];
    }
}