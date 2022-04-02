/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

// SPDX-License-Identifier: MIT
// MattMcP_Solidity_collatzConjecture v 0.4
// collatzConjecture.sol

pragma solidity 0.8.12;

contract c_collatzConjecture {

    uint256 internal maxLoops;
    uint256 internal lockedFunction;
    address internal blackBoxMint;
    uint256 internal blackBoxMintTax;
    uint256 internal blackBoxMintBalance;
    address internal collatzMaster;
    uint256 internal collatzMastersTax;
    uint256 internal collatzMastersBalance;

    string public name = "Collatz Conjecture";
    string public symbol = "BLKBX";

    constructor(){ collatzMaster = msg.sender; blackBoxMint = msg.sender; maxLoops = 1000000; collatzMastersTax = 7; blackBoxMintTax = 3;}   

    mapping(uint256 => uint256) internal completeSequence;
    mapping(address => uint256[]) internal playersScores;
    mapping(address => uint256[]) internal playersInputs;
    mapping(address => uint256) internal playersHighScore;
    mapping(address => uint256) internal playersBalance;

    struct highestScoreEver {
        address _address;
        uint256 _iniValue;
        uint256 _highScore;
        uint256 _timein;
        uint256 _timeout;
    }
    highestScoreEver highestScore;

    event newScore(address _player, uint256 _playerValue, uint256 _playerScore);
    event newHighScore(address _player, uint256 _playerValue, uint256 _playerScore);
    event collatzCollection(address _player, uint256 _playerDeposit, uint256 _contractBalance);
    event collatzDeposit(address _player, uint256 _playerValue, uint256 _playerScore);

    receive() external payable { playersBalance[msg.sender] += msg.value; emit collatzCollection(msg.sender, msg.value, address(this).balance); }

    function f_doOdds(uint256 _odds) internal pure returns (uint256) {return _odds * 3 + 1;}
    function f_doEvens(uint256 _evens) internal pure returns (uint256) {return _evens / 2;}
    function f_isOdd(uint256 _number) internal pure returns(uint256){return _number % 2;}
    function f_getMaxLoops() external view returns (uint256) {return maxLoops;}
    function f_setMaxLoops(uint256 _newLoops) external payable onlyblackBoxMint {maxLoops = _newLoops;}
    function f_playersBalance(address _player) external view returns (uint256) {return playersBalance[_player];}
    function f_playersHighScore(address _player) external view returns (uint256){return playersHighScore[_player];}
    function f_collatzOwner() external view returns (address){return collatzMaster;}
    function f_getSequence(uint256 _element) external view returns (uint256){return completeSequence[_element];}

    function f_checkContractBalance() external view returns (uint256 _blackBoxMintBalance, uint256 _collatzMastersBalance, uint256 _contractBalance, uint256 _sumPlayersBalance){
        _blackBoxMintBalance    =   blackBoxMintBalance;
        _collatzMastersBalance  =   collatzMastersBalance;
        _contractBalance        =   address(this).balance;
        _sumPlayersBalance      =   address(this).balance - (collatzMastersBalance + blackBoxMintBalance);
    }

    function f_playersHistory(address _player) external view returns (uint256 [] memory _iniValue, uint256 [] memory _result){
        _iniValue = playersInputs[_player];
        _result = playersScores[_player];
    }

    function f_allTimeHighScore() external view returns (address _player, uint256 _iniValue, uint256 _highScore, uint256 _timein, uint256 _timeout){
        _player     = highestScore._address;
        _iniValue   = highestScore._iniValue;
        _highScore  = highestScore._highScore;
        _timein     = highestScore._timein;
        _timeout    = highestScore._timeout;
    }

    function f_playerWithdraw() external onlyoneallowed {
        require(playersBalance[msg.sender] > 0, "Empty");
        (bool success, ) = collatzMaster.call{value: playersBalance[msg.sender]}("");
        require(success, "lockedFunction");
        playersBalance[msg.sender] = 0;
    }

    function f_collatzMasterWithDraw() external onlyoneallowed onlycollatzMaster {
        require(collatzMastersBalance > 0, "Empty");
        (bool success, ) = collatzMaster.call{value: collatzMastersBalance}("");
        require(success, "lockedFunction");
        collatzMastersBalance = 0;
    }

    function f_blackBoxMintWithDraw() external onlyoneallowed onlyblackBoxMint {
        require(blackBoxMintBalance > 0, "Empty");
        (bool success, ) = blackBoxMint.call{value: blackBoxMintBalance}("");
        require(success, "lockedFunction");
        blackBoxMintBalance = 0;
    }

    function f_collatzConjecture(uint256 _iniValue) internal returns (uint256) {
        uint256 loopCount = 0;
        completeSequence[loopCount]=_iniValue;
        do {
            loopCount += 1;
            if (f_isOdd(_iniValue) == 1){_iniValue = f_doOdds(_iniValue);
            }else{_iniValue = f_doEvens(_iniValue);}
            completeSequence[loopCount]=_iniValue;
        } while (_iniValue != 1 && loopCount < maxLoops);
        return loopCount;
    } 

    function f_checkResults(uint256 _timein, address _player, uint256 _iniValue, uint256 _newPlayerScore) internal {
        if (_newPlayerScore > highestScore._highScore){highestScore = highestScoreEver(_player, _iniValue, _newPlayerScore, _timein, block.timestamp);collatzMaster=_player;emit newHighScore(_player, _iniValue, _newPlayerScore);}
        if (_newPlayerScore > playersHighScore[_player]){playersHighScore[_player]=_newPlayerScore;}
        emit newScore(_player, _iniValue, _newPlayerScore);
    }

    function f_payCollatzMaster(uint256 _incoming, address _player) internal {
        require(_incoming +  address(this).balance < (2 ** 256) -1, "Fat Contract");
        uint256 minimumValue = (100 / collatzMastersTax) - 1; 
        uint256 collatzMastersCut = (_incoming * collatzMastersTax) / 100;
        if (_incoming > minimumValue ){ collatzMastersBalance += collatzMastersCut; playersBalance[_player] -= collatzMastersCut;}
    }

    function f_payBlackBoxMint(uint256 _incoming, address _player) internal {
        require(_incoming +  address(this).balance < (2 ** 256) -1, "Fat Contract");
        uint256 minimumValue = (100 / blackBoxMintTax) - 1; 
        uint256 blackBoxMintCut = (_incoming * blackBoxMintTax) / 100;
        if (_incoming > minimumValue ){ blackBoxMintBalance += blackBoxMintCut; playersBalance[_player] -= blackBoxMintCut;}
    }

    function f_enterValue() external payable onlyoneallowed {
        uint256 minimumValue = (100 / (blackBoxMintTax + collatzMastersTax)) - 1; 
        require(msg.value > minimumValue, "To low");
        playersBalance[msg.sender] += msg.value;
        uint256 timein = block.timestamp;
        uint256 result = f_collatzConjecture(msg.value);
        playersScores[msg.sender].push( result );
        playersInputs[msg.sender].push( msg.value );
        f_payCollatzMaster(msg.value, msg.sender);
        f_payBlackBoxMint(msg.value, msg.sender);
        f_checkResults(timein, msg.sender, msg.value, result);
        emit collatzDeposit(msg.sender, msg.value, result);
    }

    modifier onlycollatzMaster() {require(msg.sender == collatzMaster, "onlycollatzMaster"); _; }
    modifier onlyblackBoxMint() {require(msg.sender == blackBoxMint, "onlyblackBoxMint"); _; }  
    modifier onlyoneallowed() {require(lockedFunction != 1, "onlyoneallowed"); lockedFunction = 1; _; lockedFunction = 0;}
}