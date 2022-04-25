/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}

// interface IBEP20 {
//   /**
//    * @dev Returns the amount of tokens in existence.
//    */
//   function totalSupply() external view returns (uint256);

//   /**
//    * @dev Returns the token decimals.
//    */
//   function decimals() external view returns (uint8);

//   /**
//    * @dev Returns the token symbol.
//    */
//   function symbol() external view returns (string memory);

//   /**
//   * @dev Returns the token name.
//   */
//   function name() external view returns (string memory);

//   /**
//    * @dev Returns the bep token owner.
//    */
//   function getOwner() external view returns (address);

//   /**
//    * @dev Returns the amount of tokens owned by `account`.
//    */
//   function balanceOf(address account) external view returns (uint256);

//   /**
//    * @dev Moves `amount` tokens from the caller's account to `recipient`.
//    *
//    * Returns a boolean value indicating whether the operation succeeded.
//    *
//    * Emits a {Transfer} event.
//    */
//   function transfer(address recipient, uint256 amount) external returns (bool);

//   /**
//    * @dev Returns the remaining number of tokens that `spender` will be
//    * allowed to spend on behalf of `owner` through {transferFrom}. This is
//    * zero by default.
//    *
//    * This value changes when {approve} or {transferFrom} are called.
//    */
//   function allowance(address _owner, address spender) external view returns (uint256);

//   /**
//    * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
//    *
//    * Returns a boolean value indicating whether the operation succeeded.
//    *
//    * IMPORTANT: Beware that changing an allowance with this method brings the risk
//    * that someone may use both the old and the new allowance by unfortunate
//    * transaction ordering. One possible solution to mitigate this race
//    * condition is to first reduce the spender's allowance to 0 and set the
//    * desired value afterwards:
//    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
//    *
//    * Emits an {Approval} event.
//    */
//   function approve(address spender, uint256 amount) external returns (bool);

//   /**
//    * @dev Moves `amount` tokens from `sender` to `recipient` using the
//    * allowance mechanism. `amount` is then deducted from the caller's
//    * allowance.
//    *
//    * Returns a boolean value indicating whether the operation succeeded.
//    *
//    * Emits a {Transfer} event.
//    */
//   function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

//   /**
//    * @dev Emitted when `value` tokens are moved from one account (`from`) to
//    * another (`to`).
//    *
//    * Note that `value` may be zero.
//    */
//   event Transfer(address indexed from, address indexed to, uint256 value);

//   /**
//    * @dev Emitted when the allowance of a `spender` for an `owner` is set by
//    * a call to {approve}. `value` is the new allowance.
//    */
//   event Approval(address indexed owner, address indexed spender, uint256 value);
// }


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Dragon is Ownable {

    uint moneyLimit = 100;
    //address award_address;
    //uint award_timeout = 3000;
    uint maxPlayerNumber = 10;
    uint minPlayerNumber = 3;
    uint lastGameTimestamp = 0;
    // game cycle
    uint game_interval = 10;
    // last reward passed time
    //uint last_award_block = 0;
    // 充提币种
    address tokenAddress = 0x15Ff092Ef0730C117d0EB1F6D953daB5D9FA7BF6;
    // constructor(uint _moneyLimit, uint _maxPlayerNumber, uint _minPlayerNumber) {
    //     moneyLimit = _moneyLimit;
    //     maxPlayerNumber = _maxPlayerNumber;
    //     minPlayerNumber = _minPlayerNumber;

    // constructor(){
    //     _mock(0x328BDCD8396ac0B063BA21277Ec5Dc0b787d26e7, 100);
    //     _mock(0x7fE499623C6324B9FebF612c80B555324A74dc04, 100);
    //     _mock(0xF0Bdaa279dA102e51EBfbA96CFfdDC9E791b4673, 100);
    //     _mock(0x6959b7c87f686Bb07bb68D47946Cfc18204CDf1e, 100);
    //     _mock(0x5A1771687c04BE06759D20C931FEC25D7a2DCebE, 100);
    // }

    bool isInGame = false;

    struct Player {
        address playerAddr;
        uint amount;
        bool isValid;
        bool isRecharged;
    }

    address[] playerList;

    mapping (address => Player) private depositMap;

    receive() external payable {}

    //events
    event Recharge(address indexed player, uint amount, uint time);
    event WithDraw(address indexed player, uint amount, uint time);
    event GetAmount(address player, uint time);
    event Reward(address player, uint amount);
    event Log(string ms);
    event LogAddress(address ms);
    event LogInt(uint ms);

    //modifier
    // assert if player have recharged
    modifier isUserValid() {
        require(depositMap[msg.sender].isRecharged, "Player didn't recharge.");
        _;
    }
    // if in game,we can't start game again
    modifier IsInGame() {
        require(!isInGame, "Game is running, pls wait.");
        _;
    }

    function _mock(address _player, uint _amount) private returns(uint) {
        depositMap[_player].amount += _amount;
        depositMap[_player].isRecharged = true;
        playerList.push(_player);
        emit Recharge(_player, _amount, block.timestamp);
        // if user amount bigger than 100, I will change his status
        if (depositMap[_player].amount >= 100) {
            if (!depositMap[_player].isValid) {
                depositMap[_player].isValid = true;
            }
        }
        return depositMap[_player].amount;
    }

    function recharge(uint _amount) public returns(uint) {
        safeTransferFrom(tokenAddress, msg.sender, address(this), _amount);
        require(_amount > 0, "Recharge amount should big than 0!");
        depositMap[msg.sender].amount += _amount;
        depositMap[msg.sender].isRecharged = true;
        playerList.push(msg.sender);
        emit Recharge(msg.sender, _amount, block.timestamp);
        if (depositMap[msg.sender].amount >= 100) {
            if (!depositMap[msg.sender].isValid) {
                depositMap[msg.sender].isValid = true;
            }
        }
        return depositMap[msg.sender].amount;
    }

    // function getAllowance()

    // function safeApprove(address token, address to, uint value) public {
    //     (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
    //     require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    // }

    function safeApprove(address token, uint value) public {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, address(this), value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransferFrom(address _token, address _from, address _to, uint _value) internal {
        (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(0x23b872dd, _from, _to, _value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransfer(address _token, address _to, uint256 _value) internal {
        (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(0xa9059cbb, _to, _value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function withdraw() public onlyOwner isUserValid returns (uint) {
        uint _amount = depositMap[msg.sender].amount;
        require(_amount > 0, "Withdraw amount should big than 0!");
        require(_amount <= depositMap[msg.sender].amount, "Withdraw amount too big.");
        safeTransfer(tokenAddress, msg.sender, depositMap[msg.sender].amount);
        depositMap[msg.sender].amount -= _amount;
        emit WithDraw(msg.sender, _amount, block.timestamp);
        if (depositMap[msg.sender].amount < 100) {
            depositMap[msg.sender].isValid = false;
        }
        return depositMap[msg.sender].amount;
    }

    function getAmount() public view isUserValid returns (uint) {
        return depositMap[msg.sender].amount;
    }

    function _getValidPlayerList() private view returns (address[] memory, uint) {
        uint _allPlayerNumber = playerList.length;
        address[] memory validPlayerList = new address[](_allPlayerNumber);
        uint _playerIndex =0;

        for (uint i = 0; i < _allPlayerNumber; i++) {
            if (depositMap[playerList[i]].amount >= moneyLimit) {
                address playerAddr = playerList[i];
                validPlayerList[_playerIndex] = playerAddr;
                _playerIndex ++;
            }
        }
        return (validPlayerList, _playerIndex);
    }

    // start game
    function gameStart() public onlyOwner IsInGame returns (string memory) {
        // less than 2 people, can't start game
        (address[] memory _validPlayerList, uint _validNumber) = _getValidPlayerList();
        if (_validNumber < minPlayerNumber) {
            return "Players are not enough, pls wait.";
        }
        // time limit between games
        if (lastGameTimestamp + game_interval > block.timestamp) {
            return "Cold time.Pls wait.";
        }
        isInGame = true;
        
        // uint _playerNumber = _validPlayerList.length;
        uint _playerNumber = _validNumber;
        uint _remain_amount = moneyLimit;
        uint _max_amount = 0;
        address _loser = _validPlayerList[0];
        uint256 _randomAmount;
        for (uint i = 0; i < _playerNumber; i++) {
            if (i < _playerNumber - 1) {
                _randomAmount = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % _remain_amount;
            } else {
                _randomAmount = _remain_amount;
            }
            
            depositMap[_validPlayerList[i]].amount += _randomAmount;
            if (i > 0) {
                if (_randomAmount > _max_amount) {
                    _loser = _validPlayerList[i];
                    _max_amount = _randomAmount;
                }
            } else {
                _max_amount = _randomAmount;
            }
            
            _remain_amount -= _randomAmount;
            emit Reward(_validPlayerList[i], _randomAmount);
        }
        depositMap[_loser].amount -= moneyLimit;   
        isInGame = false;
        lastGameTimestamp = block.timestamp;
        return "Game finished.";
    }

    // function getAllowence() public returns (uint) {
    //     IBEP20(0x9161e0914cea21adc0408127662d2ae130450f80)
    // }
}