/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

/**
Endgame approaches, will you heed the call?

Step into the unknown, at endgame.black

The end draws near, dare you join us?
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Battle is Ownable {
    using SafeMath for uint256;
    string public name = "Battle";

    struct UserInfo {
        uint256 index;
		uint256[] buyAmount;
        uint256 biggestBuy;
        uint256 totalBuyAmountInRound;
        uint256 totalBuyLengthInRound;
        uint256 averageBuy;
        uint256 wins;
		uint256[] smallRTokenReward;
        address[] smallRTokenList;
        uint256 smallEndgameReward;
        uint256 bigBnbReward;
	}

    struct Round {
        address winner;
        address bigWinner;
        uint256[] rTokenFundsForSmallBattle;
        address[] rTokenListForSmallBattle;
        uint256 fundsForSmallBattle;
        uint256 bnbFundsForBigBattle;
        uint256[] rTokenRewardForSmallBattle;
        uint256 endgameRewardForSmallBattle;
        uint256 bnbRewardForBigBattle;
    }

    address public taxSystem;
    mapping (uint256 => mapping(address => UserInfo)) internal usersInfo;
    mapping(uint256 => Round) internal _rounds;
    mapping(uint256 => address[]) internal investors;
    mapping(uint256 => mapping(address => bool)) internal isInvestor;

    uint256 public currentRoundId;

    modifier onlyTaxSystem() {
        require(msg.sender == taxSystem, "Not Tax System");
        _;
    }

    event BuyDone(address indexed _investor, uint256 _buyAmount);
    event FundsNotify(
        uint256 _rTokenFundsForSmallBattle,
        uint256 _endgameForSmallBattle,
        uint256 _bnbFundsForBigBattle,
        address _rToken
    );
    event RoundEnd(
        uint256 indexed _roundId,
        address indexed _winner,
        uint256[] _rTokenRewardForSmallBattle,
        uint256 _endgameRewardForSmallBattle,
        uint256 _bnbRewardForBigBattle,
        address[] rTokenList
    );

    constructor() {
        
    }

    function buyAction(address _investor, uint256 _buyAmount) external onlyOwner {
        if (!isInvestor[currentRoundId][_investor]) {
            isInvestor[currentRoundId][_investor] = true;
            usersInfo[currentRoundId][_investor].index = investors[currentRoundId].length;
            investors[currentRoundId].push(_investor);
        }

        UserInfo storage userInfo = usersInfo[currentRoundId][_investor];
        userInfo.buyAmount.push(_buyAmount);
        if (_buyAmount > userInfo.biggestBuy) {
            userInfo.biggestBuy = _buyAmount;
        }
        userInfo.totalBuyAmountInRound += _buyAmount;
        userInfo.totalBuyLengthInRound++;
        userInfo.averageBuy = userInfo.totalBuyAmountInRound.div(userInfo.totalBuyLengthInRound);
        if ((currentRoundId > 0) && (_rounds[currentRoundId - 1].winner == _investor)) {
            userInfo.wins = usersInfo[currentRoundId - 1][_investor].wins;
        }

        address tempWinner = _rounds[currentRoundId].winner;
        UserInfo storage winnerInfo = usersInfo[currentRoundId][tempWinner];
        if (userInfo.biggestBuy > winnerInfo.biggestBuy) {
            _rounds[currentRoundId].winner = _investor;
        }

        emit BuyDone(_investor, _buyAmount);
    }

    function notifyFunds(
        uint256 _rTokenFundsForSmallBattle,
        uint256 _fundsForSmallBattle,
        uint256 _bnbFundsForBigBattle,
        uint256 _gamesPerFragment,
        address _rToken
    ) external onlyTaxSystem {
        bool registered = false;
        uint256 rTokenId = 0;
        for (uint256 i = 0; i < _rounds[currentRoundId].rTokenListForSmallBattle.length; i++) {
            if (_rounds[currentRoundId].rTokenListForSmallBattle[i] == _rToken) {
                registered = true;
                rTokenId = i;
            }
        }
        if (registered) {
            _rounds[currentRoundId].rTokenFundsForSmallBattle[rTokenId] += _rTokenFundsForSmallBattle;
        } else {
            _rounds[currentRoundId].rTokenListForSmallBattle.push(_rToken);
            _rounds[currentRoundId].rTokenFundsForSmallBattle.push(_rTokenFundsForSmallBattle);
        }
        _rounds[currentRoundId].fundsForSmallBattle += _fundsForSmallBattle;
        _rounds[currentRoundId].bnbFundsForBigBattle += _bnbFundsForBigBattle;

        emit FundsNotify(
            _rTokenFundsForSmallBattle,
            _fundsForSmallBattle.div(_gamesPerFragment),
            _bnbFundsForBigBattle,
            _rToken
        );
    }

    function endRound(uint256 _gamesPerFragment) external onlyOwner {
        address roundWinner = _rounds[currentRoundId].winner;
        
        if (roundWinner != address(0)) {
            UserInfo storage winnerInfo = usersInfo[currentRoundId][roundWinner];
            winnerInfo.wins++;
            for (uint256 i = 0; i < _rounds[currentRoundId].rTokenListForSmallBattle.length; i++) {
                if (_rounds[currentRoundId].rTokenFundsForSmallBattle[i] > 0) {
                    IERC20(_rounds[currentRoundId].rTokenListForSmallBattle[i]).transfer(
                        roundWinner, _rounds[currentRoundId].rTokenFundsForSmallBattle[i]);
                }
                winnerInfo.smallRTokenList.push(_rounds[currentRoundId].rTokenListForSmallBattle[i]);
                winnerInfo.smallRTokenReward.push(_rounds[currentRoundId].rTokenFundsForSmallBattle[i]);
                _rounds[currentRoundId].rTokenRewardForSmallBattle.push(_rounds[currentRoundId].rTokenFundsForSmallBattle[i]);
            }
            if (_rounds[currentRoundId].fundsForSmallBattle.div(_gamesPerFragment) > 0){
                IERC20(owner()).transfer(roundWinner, _rounds[currentRoundId].fundsForSmallBattle.div(_gamesPerFragment));
            }
            winnerInfo.smallEndgameReward = _rounds[currentRoundId].fundsForSmallBattle.div(_gamesPerFragment);
            _rounds[currentRoundId].endgameRewardForSmallBattle = _rounds[currentRoundId].fundsForSmallBattle.div(_gamesPerFragment);
            if (winnerInfo.wins >= 48) {
                bool success;
                if (_rounds[currentRoundId].bnbFundsForBigBattle > 0) {
                    (success, ) = roundWinner.call{
                        value: _rounds[currentRoundId].bnbFundsForBigBattle,
                        gas: 30000
                    }("");
                }
                winnerInfo.bigBnbReward = _rounds[currentRoundId].bnbFundsForBigBattle;
                _rounds[currentRoundId].bnbRewardForBigBattle = _rounds[currentRoundId].bnbFundsForBigBattle;               
            } else {
                _rounds[currentRoundId + 1].bnbFundsForBigBattle = _rounds[currentRoundId].bnbFundsForBigBattle;
            }
        } else {
            for (uint256 i = 0; i < _rounds[currentRoundId].rTokenListForSmallBattle.length; i++) {
                _rounds[currentRoundId + 1].rTokenListForSmallBattle.push(_rounds[currentRoundId].rTokenListForSmallBattle[i]);
                _rounds[currentRoundId + 1].rTokenFundsForSmallBattle.push(_rounds[currentRoundId].rTokenFundsForSmallBattle[i]);
            }
            _rounds[currentRoundId + 1].fundsForSmallBattle = _rounds[currentRoundId].fundsForSmallBattle;
            _rounds[currentRoundId + 1].bnbFundsForBigBattle = _rounds[currentRoundId].bnbFundsForBigBattle;
        }

        currentRoundId++;

        emit RoundEnd(
            currentRoundId,
            roundWinner,
            _rounds[currentRoundId].rTokenRewardForSmallBattle,
            _rounds[currentRoundId].endgameRewardForSmallBattle,
            _rounds[currentRoundId].bnbRewardForBigBattle,
            _rounds[currentRoundId].rTokenListForSmallBattle
        );
    }

    function updateTaxSystem(address _taxSystem) external onlyOwner {
        taxSystem = _taxSystem;
    }

    function viewCurrentRoundId() external view returns (uint256) {
        return currentRoundId;
    }

    function viewRound(uint256 _id) external view returns (Round memory) {
        return _rounds[_id];
    }

    function checkInvestor(uint256 _id, address _user) external view returns (bool) {
        return isInvestor[_id][_user];
    }

    function totalInvestors(uint256 _id) external view returns (uint256) {
        return investors[_id].length;
    }

    function investorAddressByIndex(uint256 _id, uint256 _index) external view returns (address) {
        return investors[_id][_index];
    }

    function viewUserInfoByIndex(
        uint256 _id,
        uint256 _index
    ) external view returns (
        address _userAddress,
        UserInfo memory _userInfo
    ) {
        _userAddress = investors[_id][_index];
        _userInfo = usersInfo[_id][_userAddress];
    }

    function viewUserInfoByAddress(
        uint256 _id,
        address _userAddress
    ) external view returns (
        UserInfo memory _userInfo
    ) {
        _userInfo = usersInfo[_id][_userAddress];
    }

    receive() external payable {}
}