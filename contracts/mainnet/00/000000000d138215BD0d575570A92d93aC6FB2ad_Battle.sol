/**
 *Submitted for verification at BscScan.com on 2022-12-17
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

    address public immutable WZER = address(0x530e9346870E632A63E8d461bb3c3622e00782DE); //WZER
    address public HYC; //HYC

    struct UserInfo {
        uint256 index;
		uint256[] buyAmount;
        uint256 biggestBuy;
        uint256 totalBuyAmountInRound;
        uint256 totalBuyLengthInRound;
        uint256 averageBuy;
        uint256 wins;
		uint256 smallWzerReward;
        uint256 smallBnbReward;
        uint256 bigReward;
	}

    struct Round {
        address winner;
        address bigWinner;
        uint256 wzerFundsForSmallBattle;
        uint256 bnbFundsForSmallBattle;
        uint256 fundsForBigBattle;
        uint256 wzerRewardForSmallBattle;
        uint256 bnbRewardForSmallBattle;
        uint256 rewardForBigBattle;
    }

    mapping(address => bool) internal isOperator;
    address[] internal operators;
    mapping (uint256 => mapping(address => UserInfo)) internal usersInfo;
    mapping(uint256 => Round) internal _rounds;
    mapping(uint256 => address[]) internal investors;
    mapping(uint256 => mapping(address => bool)) internal isInvestor;

    uint256 public currentRoundId;

    modifier onlyOperator() {
        require(isOperator[msg.sender], "Not operator");
        _;
    }

    event BuyDone(address indexed _investor, uint256 _buyAmount);
    event RoundEnd(
        address indexed _winner,
        uint256 _wzerRewardForSmallBattle,
        uint256 _bnbRewardForSmallBattle,
        uint256 _rewardForBigBattle
        );
    event OperatorSet(address indexed _operator, bool _flag);

    constructor() {}

    function setHypercube(address _hypercube) external onlyOwner {
        require(_hypercube != address(0), "Token address zero not allowed.");
        
        HYC = _hypercube;
        setOperator(_hypercube, true);
    }

    function buyAction(address _investor, uint256 _buyAmount) external onlyOperator {
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

    function endRound(
        uint256 _wzerFundsForSmallBattle,
        uint256 _fundsForBigBattle
    ) external payable onlyOperator {
        address roundWinner = _rounds[currentRoundId].winner;
        _rounds[currentRoundId].bnbFundsForSmallBattle += msg.value;
        IERC20(WZER).transferFrom(msg.sender, address(this), _wzerFundsForSmallBattle);
        IERC20(HYC).transferFrom(msg.sender, address(this), _fundsForBigBattle);
        _rounds[currentRoundId].wzerFundsForSmallBattle += _wzerFundsForSmallBattle;
        _rounds[currentRoundId].fundsForBigBattle += _fundsForBigBattle;
        
        if (roundWinner != address(0)) {
            UserInfo storage winnerInfo = usersInfo[currentRoundId][roundWinner];
            winnerInfo.wins++;
            IERC20(WZER).transfer(roundWinner, _rounds[currentRoundId].wzerFundsForSmallBattle);
            winnerInfo.smallWzerReward = _rounds[currentRoundId].wzerFundsForSmallBattle;
            _rounds[currentRoundId].wzerRewardForSmallBattle = _rounds[currentRoundId].wzerFundsForSmallBattle;
            bool success;
            (success, ) = roundWinner.call{
                value: _rounds[currentRoundId].bnbFundsForSmallBattle,
                gas: 30000
            }("");
            winnerInfo.smallBnbReward = _rounds[currentRoundId].bnbFundsForSmallBattle;
            _rounds[currentRoundId].bnbRewardForSmallBattle = _rounds[currentRoundId].bnbFundsForSmallBattle;
            if (winnerInfo.wins >= 48) {
                IERC20(HYC).transfer(roundWinner, _rounds[currentRoundId].fundsForBigBattle);
                winnerInfo.bigReward = _rounds[currentRoundId].fundsForBigBattle;
                _rounds[currentRoundId].rewardForBigBattle = _rounds[currentRoundId].fundsForBigBattle;
            } else {
                _rounds[currentRoundId + 1].fundsForBigBattle = _rounds[currentRoundId].fundsForBigBattle;
            }
        } else {
            _rounds[currentRoundId + 1].wzerFundsForSmallBattle = _rounds[currentRoundId].wzerFundsForSmallBattle;
            _rounds[currentRoundId + 1].bnbFundsForSmallBattle = _rounds[currentRoundId].bnbFundsForSmallBattle;
            _rounds[currentRoundId + 1].fundsForBigBattle = _rounds[currentRoundId].fundsForBigBattle;
        }

        currentRoundId++;

        emit RoundEnd(
            roundWinner,
            _rounds[currentRoundId].wzerRewardForSmallBattle,
            _rounds[currentRoundId].bnbRewardForSmallBattle,
            _rounds[currentRoundId].rewardForBigBattle
        );
    }

    function setOperator(address _operator, bool _flag) public onlyOwner {
        if (_flag) {
            if (!isOperator[_operator]) {
                isOperator[_operator] = true;
                operators.push(_operator);
            }
        } else {
            if (isOperator[_operator]) {
                isOperator[_operator] = false;
                for (uint256 i=0; i<operators.length; i++) {
                    if (operators[i] == _operator) {
                        operators[i] = operators[operators.length - 1];
                        operators.pop();
                        break;
                    }
                }
            }
        }

        emit OperatorSet(_operator, _flag);
    }

    function checkOperator(address _user) external view returns (bool) {
        return isOperator[_user];
    }

    function totalOperators() external view returns (uint256) {
        return operators.length;
    }

    function viewOperatorByIndex(uint256 _index) external view returns (address) {
        return operators[_index];
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

}