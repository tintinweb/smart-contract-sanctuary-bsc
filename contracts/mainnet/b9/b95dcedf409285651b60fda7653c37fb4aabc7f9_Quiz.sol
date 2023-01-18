/**
 *Submitted for verification at BscScan.com on 2023-01-18
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


interface ILottery {
    function drawALottery(uint256 _lotteryId) external;

    function transferAsset(address payable _to) external;
}

interface IIntegrateToken {
    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}

interface IDataStorage {

    struct QuizDetail {
        uint256 id;
        string app_id;
        string[] questions;
        uint256 amount;
        int256 group;
        uint botType;
        bool exist;
        bool over;
        uint256 startTime;
        uint256 activeTime;
        string title;
        string photo;
        uint256 participate;
    }

    function checkAdmin(string memory _appId, address _sender) external view returns (bool);

    function setQuiz(string memory _appId, QuizDetail memory _quiz) external;

    function overQuiz(uint256 _quizId) external;

    function getQuiz(uint256 _quizId) external view returns (QuizDetail memory);

    function getQuizzes(uint256[] memory _quizIds) external view returns (QuizDetail[] memory);

    function addInductees(uint256 _quizId, address[] memory _inductees, uint256 _participate) external;

    function getInductees(uint256 _quizId) external view returns (address[] memory);

    function getShouldAwardQuizIds() external view returns (uint256[] memory);

    function getAppQuizIds(string memory _appId) external view returns (uint256[] memory);

    function getLotteryResult(uint256 _quizId, uint256 _index) external view returns (address[] memory);

}

interface ICAT {
    function balanceOf(address _owner) external view returns (uint256);

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);

    function level(uint256 _tokenId) external view returns (uint256);

}


contract Quiz {

    using SafeMath for uint256;
    address  public owner;
    address payable public operator;
    mapping(string => address payable) appOperators;
    ILottery public lottery;
    IIntegrateToken public quizToken;
    IIntegrateToken public excitationToken;
    IDataStorage public dataStorage;

    mapping(string => IIntegrateToken) public quizTokens;
    mapping(string => ICAT) public appCats;


    uint256 public correctRewardAmount;
    uint256 public exciteAmount;

    struct Timezone {
        int256 timeOffset;
        string timezone;
    }

    mapping(uint256 => Timezone) public quizTimezoneList;

    constructor(address payable _operator, ILottery _lottery, IIntegrateToken _quizToken, IIntegrateToken _excitationToken, IDataStorage _storage, uint256 _rewardAmount, uint256 _exciteAmount) {
        owner = msg.sender;
        operator = _operator;
        lottery = _lottery;
        excitationToken = _excitationToken;
        quizToken = _quizToken;
        dataStorage = _storage;
        correctRewardAmount = _rewardAmount;
        exciteAmount = _exciteAmount;
        if (block.chainid == 137) {
            appCats["Tristan"] = ICAT(0x21BdABb0CAb83DF0ff7e0C7425e9145D15dd11e8);
        }

    }


    modifier checkQuiz(uint256 _quizId){
        require(_quizId != 0, "invalid quizId 0");
        require(dataStorage.getQuiz(_quizId).exist, "nonexistent quiz");
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only Owner");
        _;
    }

    modifier onlyAdmin(string memory _appId) {
        require(dataStorage.checkAdmin(_appId, msg.sender) || operator == msg.sender
        || address(appOperators[_appId]) == msg.sender || owner == msg.sender, "Only admin");
        _;
    }

    event CreateQuiz(string _appId, uint256 _quizId, int256 _groupId, uint _botType, string[] questions, uint256 _rewardAmount,
        uint256 _startTime, uint256 _activeTime);
    event Awards(bytes32 _quizId);


    function transferOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function changeOperator(address payable _newOperator) public onlyOwner {
        operator = _newOperator;
    }

    function addAppOperator(string memory _appId, address payable _newOperator) public onlyOwner {
        appOperators[_appId] = _newOperator;
    }

    function changeLottery(ILottery _newLottery) public onlyOwner {
        if (address(lottery) != address(0)) {
            address _to = address(_newLottery);
            lottery.transferAsset(payable(_to));
        }
        lottery = _newLottery;
    }

    function changeQuizToken(IIntegrateToken _newToken) public onlyOwner {
        quizToken = _newToken;
    }

    function changeExcitationToken(IIntegrateToken _newToken) public onlyOwner {
        excitationToken = _newToken;
    }

    function changeRewardAmount(uint256 _newAmount) public onlyOwner {
        correctRewardAmount = _newAmount;
    }

    function changeExciteAmount(uint256 _newAmount) public onlyOwner {
        exciteAmount = _newAmount;
    }

    function changeDataStorage(IDataStorage _data) public onlyOwner {
        dataStorage = _data;
    }

    function setAppQzt(string memory _appId, IIntegrateToken _newToken) public onlyOwner {
        quizTokens[_appId] = _newToken;
    }

    function setAppCat(string memory _appId, address _cat) public onlyOwner {
        appCats[_appId] = ICAT(_cat);
    }

    function createQuiz(string memory _appId, uint256 _quizId, int256 _groupId, uint _botType, string[] memory _questions,
        uint256 _rewardAmount, uint256 _startTime, uint256 _activeTime, string memory _title, string memory _photo, Timezone memory _timezone) payable public onlyAdmin(_appId) {
        require(_quizId != 0, "invalid quizId 0");
        IDataStorage.QuizDetail memory quiz = dataStorage.getQuiz(_quizId);
        require(!quiz.exist, "exist quiz");
        _rewardAmount = correctRewardAmount;

        address payable thisOperator = appOperators[_appId];

        if (address(msg.sender) != address(operator) && address(msg.sender) != owner) {
            require(msg.value > 0, "you should prepay for gas");
            if (address(thisOperator) != address(0)) {
                require(msg.value > 0, "you should prepay for gas");
                thisOperator.transfer(msg.value);
            } else {
                operator.transfer(msg.value);
            }
        }

        quiz.id = _quizId;
        quiz.app_id = _appId;
        quiz.amount = _rewardAmount;
        quiz.questions = _questions;
        quiz.group = _groupId;
        quiz.exist = true;
        quiz.botType = _botType;
        quiz.title = _title;
        quiz.photo = _photo;
        quiz.startTime = _startTime;
        quiz.activeTime = _activeTime;

        dataStorage.setQuiz(_appId, quiz);
        quizTimezoneList[_quizId] = _timezone;

        excitationToken.mint(msg.sender, exciteAmount);

        emit CreateQuiz(_appId, _quizId, _groupId, _botType, _questions, _rewardAmount, _startTime, _activeTime);
    }


    function editQuiz(string memory _appId, uint256 _quizId, int256 _groupId, string[] memory _questions, uint256 _startTime, uint256 _activeTime, string memory _title, string memory _photo) public
    onlyAdmin(_appId)
    checkQuiz(_quizId) {
        IDataStorage.QuizDetail memory quiz = dataStorage.getQuiz(_quizId);
        if (_groupId != 0) {
            quiz.group = _groupId;
        }
        if (_questions.length > 0) {
            quiz.questions = _questions;
        }
        if (_startTime > 0) {
            quiz.startTime = _startTime;
        }
        if (_activeTime > 0) {
            quiz.activeTime = _activeTime;
        }
        if (bytes(_title).length > 0) {
            quiz.title = _title;
        }
        if (bytes(_photo).length > 0) {
            quiz.photo = _photo;
        }

        dataStorage.setQuiz(_appId, quiz);
    }


    function getQuiz(uint256 _quizId) public view returns (IDataStorage.QuizDetail memory) {
        return dataStorage.getQuiz(_quizId);
    }

    function getQuizzes(uint256[] memory _ids) public view returns (IDataStorage.QuizDetail[] memory){
        return dataStorage.getQuizzes(_ids);
    }


    function getShouldAwardQuizIds() public view returns (uint256[] memory) {
        return dataStorage.getShouldAwardQuizIds();
    }

    function getAppQuizIds(string memory _appId) public view returns (uint256[] memory){
        return dataStorage.getAppQuizIds(_appId);
    }


    function getInductees(uint256 _quizId) public view returns (address[] memory){
        return dataStorage.getInductees(_quizId);
    }

    function addInductees(string memory _appId, uint256 _quizId, address[] memory _inductees, uint256 _participateNumber) public checkQuiz(_quizId) onlyAdmin(_appId) {
        IDataStorage.QuizDetail memory quiz = dataStorage.getQuiz(_quizId);
        require(!quiz.over, "quiz is over");
        dataStorage.addInductees(_quizId, _inductees, _participateNumber);
    }

    function awards(string memory _appId, uint256 _quizId) public checkQuiz(_quizId) onlyAdmin(_appId) {
        IDataStorage.QuizDetail memory quiz = dataStorage.getQuiz(_quizId);
        require(!quiz.over, "quiz is over");

        address[] memory thisInductees = dataStorage.getInductees(_quizId);
        uint256 i = 0;

        while (i < thisInductees.length) {
            if (address(quizTokens[_appId]) != address(0)) {
                uint256 _rewardAmount = correctRewardAmount;
                if (address(appCats[_appId]) != address(0)) {
                    if (appCats[_appId].balanceOf(thisInductees[i]) > 0) {
                        uint256 level = appCats[_appId].level(appCats[_appId].tokenOfOwnerByIndex(thisInductees[i], 0));
                        if (level == 2) {
                            _rewardAmount = _rewardAmount.mul(150).div(100);
                        } else if (level == 3) {
                            _rewardAmount = _rewardAmount.add(_rewardAmount.mul(250).div(100));
                        } else if (level == 4) {
                            _rewardAmount = _rewardAmount.add(_rewardAmount.mul(500).div(100));
                        } else if (level == 5) {
                            _rewardAmount = _rewardAmount.add(_rewardAmount.mul(1000).div(100));
                        }
                    } else {
                        _rewardAmount = 0;
                    }
                }
                if (_rewardAmount > 0) {
                    quizTokens[_appId].mint(thisInductees[i], correctRewardAmount);
                }
            } else {
                quizToken.mint(thisInductees[i], quiz.amount);
            }

            i += 1;
        }

        quiz.over = true;
        dataStorage.overQuiz(_quizId);
        lottery.drawALottery(_quizId);
    }


    function getLotteryResults(uint256 _quizId, uint256 _index) public view returns (address[] memory){
        return dataStorage.getLotteryResult(_quizId, _index);
    }


}