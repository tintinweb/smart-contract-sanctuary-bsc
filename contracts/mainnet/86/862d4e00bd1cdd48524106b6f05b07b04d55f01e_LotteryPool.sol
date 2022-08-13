/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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


interface IDataStorage {

    struct Lottery {
        IERC20 token;
        uint256[] amounts;
        uint256[] fixedNum;
        uint256[] proportionNum;
        uint256 totalAmount;
        bool isEth;
        bool over;
        bool exist;
    }

    function checkAdmin(string memory _appId, address _sender) external view returns (bool);

    function getInductees(uint256 _quizId) external view returns (address[] memory);

    function setLottery(address _creator, uint256 _lotteryId, Lottery memory _lottery) external;

    function overLottery(uint256 _lotteryId) external;

    function getLottery(uint256 _lotteryId) external view returns (Lottery memory);

    function getLotteries(uint256[] memory _lotteryIds) external view returns (Lottery[] memory);

    function setLotteryResult(uint256 _lotteryId, uint256 _index, address[] memory _winner) external;

    function getLotteryResult(uint256 _lotteryId, uint256 _index) external view returns (address[] memory);

    function getLotteryCreator(uint256 _lotteryId) external view returns (address);

    function setEthBank(address _holder, uint256 _amount) external;

    function getEthBank(address _holder) external view returns (uint256);

    function setErc20Bank(address _holder, IERC20 _token, uint256 _amount) external;

    function getErc20Bank(address _holder, IERC20 _token) external view returns (uint256);

}

interface IIntegrateToken {
    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}

contract LotteryPool {
    using SafeMath for uint256;
    address public owner;
    mapping(address => bool) public operators;
    IDataStorage public dataStorage;
    IERC20[] private erc20List;
    IIntegrateToken public excitationToken;

    uint256 public exciteAmount;

    constructor(address _operator, IDataStorage _storage, IIntegrateToken _excitationToken, uint256 _exciteAmount){
        owner = msg.sender;
        dataStorage = _storage;
        operators[msg.sender] = true;
        operators[_operator] = true;
        excitationToken = _excitationToken;
        exciteAmount = _exciteAmount;
    }

    function transferOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
        operators[_newOwner] = true;
    }

    function addOperator(address _newOperator) public onlyOwner {
        operators[_newOperator] = true;
    }

    function changeStorage(IDataStorage _newStorage) public onlyOwner {
        dataStorage = _newStorage;
    }

    function changeExcitationToken(IIntegrateToken _newToken) public onlyOwner {
        excitationToken = _newToken;
    }

    function changeExciteAmount(uint256 _newAmount) public onlyOwner {
        exciteAmount = _newAmount;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only Owner");
        _;
    }

    modifier onlyOperator(){
        require(operators[msg.sender], "Only Operator");
        _;
    }

    modifier onlyAdmin(string memory _appId, address _sender){
        bool isAdmin = dataStorage.checkAdmin(_appId, _sender);
        require(isAdmin || operators[msg.sender], "Only Admin");
        _;
    }

    modifier newLottery(uint256 _lotteryId){
        require(!dataStorage.getLottery(_lotteryId).exist, "exist lottery");
        _;
    }

    modifier notOverLottery(uint256 _lotteryId){
        require(dataStorage.getLottery(_lotteryId).exist, "not exist lottery");
        require(!dataStorage.getLottery(_lotteryId).over, "over lottery");
        _;
    }

    mapping(uint256 => address[]) remainLotteryInductees;


    function getErc20List() public view returns (IERC20[] memory){
        return erc20List;
    }


    function _erc20Lottery(IERC20 _token, uint256 _amount, address[] memory _receivers) internal {
        if (_receivers.length == 0) {
            return;
        }
        require(_token.balanceOf(address(this)) >= _amount, "token remain not enough");
        uint256 singleAmount = _amount.div(_receivers.length);
        for (uint i = 0; i < _receivers.length; i++) {
            _token.transfer(_receivers[i], singleAmount);
        }
    }

    function _ethLottery(uint256 _amount, address[] memory _receivers) internal {
        if (_receivers.length == 0) {
            return;
        }
        require(address(this).balance >= _amount, "eth not enough");
        uint256 singleAmount = _amount.div(_receivers.length);
        for (uint i = 0; i < _receivers.length; i++) {
            payable(_receivers[i]).transfer(singleAmount);
        }
    }

    function createLottery(string memory _appId, uint256 _lotteryId, IERC20 _rewardToken, uint256[] memory _fixedNum, uint256[] memory _proportionNum, uint256[] memory _amounts) public newLottery(_lotteryId)
    onlyAdmin(_appId, msg.sender) {
        require(_amounts.length == _fixedNum.length || _amounts.length == _proportionNum.length, "amounts and lottery number not match");
        uint256 _amount = 0;
        for (uint i = 0; i < _amounts.length; i++) {
            _amount = _amount.add(_amounts[i]);
        }
        require(_amount > 0, "total amount should be greater than zero");
        _rewardToken.transferFrom(msg.sender, address(this), _amount);
        erc20List.push(_rewardToken);

        IDataStorage.Lottery memory lottery = dataStorage.getLottery(_lotteryId);
        lottery.exist = true;
        lottery.token = _rewardToken;
        lottery.amounts = _amounts;
        lottery.totalAmount = _amount;
        lottery.fixedNum = _fixedNum;
        lottery.proportionNum = _proportionNum;

        dataStorage.setLottery(msg.sender, _lotteryId, lottery);
        uint256 lastBalance = dataStorage.getErc20Bank(msg.sender, _rewardToken);
        dataStorage.setErc20Bank(msg.sender, _rewardToken, lastBalance.add(_amount));
        excitationToken.mint(msg.sender, exciteAmount);

    }

    function createEthLottery(string memory _appId, uint256 _lotteryId, uint256[] memory _fixedNum, uint256[] memory _proportionNum, uint256[] memory _amounts) public payable newLottery(_lotteryId)
    onlyAdmin(_appId, msg.sender) {
        require(_amounts.length == _fixedNum.length || _amounts.length == _proportionNum.length, "amounts and lottery number not match");
        uint256 _amount = 0;
        for (uint i = 0; i < _amounts.length; i++) {
            _amount = _amount.add(_amounts[i]);
        }
        require(_amount > 0, "total amount should be greater than zero");
        require(msg.value >= _amount, "sent value should be greater amount");
        IDataStorage.Lottery memory lottery = dataStorage.getLottery(_lotteryId);
        lottery.exist = true;
        lottery.isEth = true;
        lottery.amounts = _amounts;
        lottery.totalAmount = _amount;
        lottery.fixedNum = _fixedNum;
        lottery.proportionNum = _proportionNum;

        dataStorage.setLottery(msg.sender, _lotteryId, lottery);
        uint256 lastBalance = dataStorage.getEthBank(msg.sender);
        dataStorage.setEthBank(msg.sender, lastBalance.add(msg.value));
        excitationToken.mint(msg.sender, exciteAmount);
    }


    function drawALottery(uint256 _lotteryId) public onlyOperator {
        IDataStorage.Lottery memory lottery = dataStorage.getLottery(_lotteryId);
        if (!lottery.exist) {
            return;
        }
        require(!lottery.over, "lottery is over");
        dataStorage.overLottery(_lotteryId);
        if (lottery.fixedNum.length > 0) {
            for (uint i = 0; i < lottery.fixedNum.length; i++) {
                _drawALotteryByIndex(lottery, _lotteryId, i, true);
            }
        } else {
            for (uint i = 0; i < lottery.proportionNum.length; i++) {
                _drawALotteryByIndex(lottery, _lotteryId, i, false);
            }
        }
    }

    function _drawALotteryByIndex(IDataStorage.Lottery memory _lottery, uint256 _lotteryId, uint256 _index, bool isFixNum) internal {
        if (_lottery.amounts[_index] == 0) {
            return;
        }

        remainLotteryInductees[_lotteryId] = dataStorage.getInductees(_lotteryId);

        uint256 lotteryNum = 0;
        if (isFixNum) {
            require(_index <= _lottery.fixedNum.length, "lottery index out of bounds");
            lotteryNum = _lottery.fixedNum[_index];
            if (lotteryNum > remainLotteryInductees[_lotteryId].length) {
                lotteryNum = remainLotteryInductees[_lotteryId].length;
            }
        } else {
            require(_index <= _lottery.proportionNum.length, "lottery index out of bounds");
            uint256 proportion = _lottery.proportionNum[_index];
            if (proportion > 0) {
                if (proportion >= 100) {
                    proportion = 100;
                }
                lotteryNum = remainLotteryInductees[_lotteryId].length.mul(proportion).div(100);
                if (lotteryNum == 0) {
                    lotteryNum = 1;
                }
            }
        }

        if (lotteryNum == 0) {
            return;
        }

        address[] memory lotteryResults = new address[](lotteryNum);

        for (uint256 i = 0; i < lotteryNum; i++) {
            uint256 inducteeNum = remainLotteryInductees[_lotteryId].length;
            uint256 latestInducteeIndex = inducteeNum - 1;

            uint256 winnerIndex = _randomNumber(inducteeNum, i);

            lotteryResults[i] = remainLotteryInductees[_lotteryId][winnerIndex];

            if (winnerIndex != latestInducteeIndex) {
                remainLotteryInductees[_lotteryId][winnerIndex] = remainLotteryInductees[_lotteryId][latestInducteeIndex];
            }
            remainLotteryInductees[_lotteryId].pop();
        }

        address creator = dataStorage.getLotteryCreator(_lotteryId);

        if (_lottery.isEth) {
            uint256 lastBalance = dataStorage.getEthBank(creator);
            require(lastBalance >= _lottery.amounts[_index], "creator's eth not enough");
            dataStorage.setEthBank(creator, lastBalance.sub(_lottery.amounts[_index]));
            _ethLottery(_lottery.amounts[_index], lotteryResults);
        } else {
            uint256 lastBalance = dataStorage.getErc20Bank(creator, _lottery.token);
            require(lastBalance >= _lottery.amounts[_index], "creator's token not enough");
            dataStorage.setErc20Bank(creator, _lottery.token, lastBalance.sub(_lottery.amounts[_index]));
            _erc20Lottery(_lottery.token, _lottery.amounts[_index], lotteryResults);
        }
        dataStorage.setLotteryResult(_lotteryId, _index, lotteryResults);

    }

    function getLotteries(uint256[] memory _ids) public view returns (IDataStorage.Lottery[] memory){
        return dataStorage.getLotteries(_ids);
    }

    function getLottery(uint256 _lotteryId) public view returns (IDataStorage.Lottery memory){
        return dataStorage.getLottery(_lotteryId);
    }

    function getLotteryResults(uint256 _lotteryId, uint256 _index) public view returns (address[] memory){
        return dataStorage.getLotteryResult(_lotteryId, _index);
    }

    function _randomNumber(uint256 _scope, uint256 _salt) internal view returns (uint256) {
        return uint256(keccak256(abi.encode(abi.encodePacked(block.timestamp, block.difficulty), _salt))) % _scope;
    }


    function transferAsset(address payable _to) public onlyOperator {
        if (address(this).balance > 0) {
            _to.transfer(address(this).balance);
        }
        for (uint i = 0; i < erc20List.length; i++) {
            uint256 balance = erc20List[i].balanceOf(address(this));
            if (balance > 0) {
                erc20List[i].transfer(_to, balance);
            }
        }
    }


}