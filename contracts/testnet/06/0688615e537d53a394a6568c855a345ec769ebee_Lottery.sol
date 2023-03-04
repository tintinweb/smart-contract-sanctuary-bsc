/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Lottery is Ownable {
    using SafeMath for uint256;

    struct _player {
        address[] players;
        uint256 winningamount;
        uint256 winners;
        uint256 time;
        uint256 currenttime;
        uint256 received_entry;
        uint256 total_entry;
        uint256 multiple_entry;
        address[] final_winners;
        uint256[] amount_winners;
    }

    address private winner;

    event NewEntry(address count);
    event WinnerSelected(address winner, uint256 amount);

    mapping(address => uint256) public winning_amount;
    mapping(uint256 => mapping(address => uint256)) public playerentry;
    mapping(address => uint256) public previouslevel;
    mapping(uint256 => _player) public fin;

    uint256 public total_entries;
    uint256 public total_invested_amount;
    uint256 public total_reward;
    uint256 public total_lottery_completed;
    uint256 min_amount = 1e18;
    uint256 public _time;
    uint256 public current_time = block.timestamp;

    IBEP20 public Token;

    constructor(IBEP20 _Token) {
        Token = _Token;
        startTime();
    }

    function change_prise(uint256 prise) public onlyOwner {
        min_amount = prise;
    }

    function set_time(uint256 _level, uint256 __time) public onlyOwner {
        fin[_level].time = __time;
    }

    function set_winningamount(uint256 _level, uint256 _amount)
        public
        onlyOwner
    {
        fin[_level].winningamount = _amount;
    }

    function set_winners(uint256 _level, uint256 winners) public onlyOwner {
        fin[_level].winners = winners;
    }

    function set_totalentry(uint256 _level, uint256 entry) public onlyOwner {
        fin[_level].total_entry = entry;
    }

    function set_multipleentry(uint256 _level, uint256 multipleentry)
        public
        onlyOwner
    {
        fin[_level].multiple_entry = multipleentry;
    }
  
    function plans(uint256 _level, uint256 _entry ) public {
        total_entries = total_entries.add(_entry);
        uint256 amount=_entry.mul(1e18);
        total_invested_amount = total_invested_amount.add(amount);
        fin[_level].currenttime = block.timestamp;
            require(
                fin[_level].received_entry <= fin[_level].total_entry,
                "total entries exceeded"
            );
            fin[_level].received_entry = fin[_level].received_entry.add(_entry);
            require(
                playerentry[_level][msg.sender] < fin[_level].multiple_entry,
                "multiple entries exceeded"
            );
            playerentry[_level][msg.sender] = playerentry[_level][msg.sender]
                .add(_entry);
            Token.transferFrom(msg.sender, address(this), amount);
            for(uint256 i; i <=_entry ; i++){
            fin[_level].players.push(msg.sender);
            }
     
    }

    function showWinners(uint256 _level)
        public
        view
        returns (address[] memory, uint256[] memory)
    {
        fin[_level].final_winners;
        fin[_level].amount_winners;

        return (fin[_level].final_winners, fin[_level].amount_winners);
    }

    function amount_everywinner(uint256 _level)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
     uint256 winerRatio = (fin[_level].received_entry * 100)/fin[_level].total_entry;
        uint256 newwinner = (winerRatio * fin[_level].winners)/100;
         if (newwinner >= (fin[_level].winners) * 100) {
             uint256 _amount = fin[_level].winners * fin[_level].winningamount;
            uint256 _amounteverywinner = (_amount) / fin[_level].winners;
            return (winerRatio, newwinner, _amount, _amounteverywinner);
        }
         else if (newwinner == 0) {
           uint256 _amount = (fin[_level].winningamount).div(100);

            uint256 _amounteverywinner = (_amount) / fin[_level].received_entry;
            return (winerRatio, newwinner, _amount, _amounteverywinner);
        }
         else {
            uint256 _newwinner = (newwinner);
            uint256 _amount = _newwinner * fin[_level].winningamount;
            uint256 _amounteverywinner = (_amount) / _newwinner;
            return (winerRatio, _newwinner, _amount, _amounteverywinner);
        }
    }

    function randomNumberSelector(uint256 _level)
        public
        view
        returns (uint256)
    {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        fin[_level].players
                    )
                )
            );
    }

    function startTime() internal {
        fin[1].time = block.timestamp + 7 days;
        fin[1].winningamount = 10e18;
        fin[1].winners = 50;
        fin[1].total_entry = 1000;
        fin[1].multiple_entry = 10;

        fin[2].time = block.timestamp + 7 days;
        fin[2].winningamount = 20e18;
        fin[2].winners = 25;
        fin[2].total_entry = 1000;
        fin[2].multiple_entry = 10;

        fin[3].time = block.timestamp + 7 days;
        fin[3].winningamount = 50e18;
        fin[3].winners = 10;
        fin[3].total_entry = 1000;
        fin[3].multiple_entry = 10;

        fin[4].time = block.timestamp + 14 days;
        fin[4].winningamount = 100e18;
        fin[4].winners = 10;
        fin[4].total_entry = 2000;
        fin[4].multiple_entry = 20;

        fin[5].time = block.timestamp + 21 days;
        fin[5].winningamount = 250e18;
        fin[5].winners = 10;
        fin[5].total_entry = 5000;
        fin[5].multiple_entry = 50;

        fin[6].time = block.timestamp + 21 days;
        fin[6].winningamount = 500e18;
        fin[6].winners = 5;
        fin[6].total_entry = 5000;
        fin[6].multiple_entry = 50;

        fin[7].time = block.timestamp + 30 days;
        fin[7].winningamount = 1000e18;
        fin[7].winners = 4;
        fin[7].total_entry = 8000;
        fin[7].multiple_entry = 80;

        fin[8].time = block.timestamp + 35 days;
        fin[8].winningamount = 2500e18;
        fin[8].winners = 2;
        fin[8].total_entry = 10000;
        fin[8].multiple_entry = 100;

        fin[9].time = block.timestamp + 50 days;
        fin[9].winningamount = 5000e18;
        fin[9].winners = 2;
        fin[9].total_entry = 20000;
        fin[9].multiple_entry = 200;
        
        fin[10].time = block.timestamp + 60 days;
        fin[10].winningamount = 10000e18;
        fin[10].winners = 2;
        fin[10].total_entry = 40000;
        fin[10].multiple_entry = 400;

        fin[11].time = block.timestamp + 90 days;
        fin[11].winningamount = 25000e18;
        fin[11].winners = 3;
        fin[11].total_entry = 100000;
        fin[11].multiple_entry = 1000;

        fin[12].time = block.timestamp + 180 days;
        fin[12].winningamount = 50000e18;
        fin[12].winners = 3;
        fin[12].total_entry = 200000;
        fin[12].multiple_entry = 2000;

        fin[13].time = block.timestamp + 270 days;
        fin[13].winningamount = 100000e18;
        fin[13].winners = 2;
        fin[13].total_entry = 300000;
        fin[13].multiple_entry = 3000;

        fin[14].time = block.timestamp + 300 days;
        fin[14].winningamount = 250000e18;
        fin[14].winners = 2;
        fin[14].total_entry = 600000;
        fin[14].multiple_entry = 6000;

        fin[15].time = block.timestamp + 360 days;
        fin[15].winningamount = 500000e18;
        fin[15].winners = 2;
        fin[15].total_entry = 1100000;
        fin[15].multiple_entry = 11000;

        fin[16].time = block.timestamp + 365 days;
        fin[16].winningamount = 1000000e18;
        fin[16].winners = 1;
        fin[16].total_entry = 1500000;
        fin[16].multiple_entry = 15000;
    }

    function selectWinner(uint256 _level) public onlyOwner {
        total_lottery_completed = total_lottery_completed.add(1);
        for (uint256 i = 0; i < fin[_level].players.length; i++) {
            address a = fin[_level].players[i];
            playerentry[_level][a] = 0;
        }
        require(block.timestamp >= fin[_level].time, "Time not reached");

        uint256 winerRatio = (fin[_level].received_entry * 100)/fin[_level].total_entry;
        uint256 newwinner = (winerRatio * fin[_level].winners)/100;
        
         if (newwinner >= (fin[_level].winners) ) {
            uint256 _amount = fin[_level].winners * fin[_level].winningamount;
            uint256 _amounteverywinner = (_amount) / fin[_level].winners;
            for (uint256 i; i < fin[_level].winners; i++) {
                uint256 random = randomNumberSelector(_level) %
                    fin[_level].players.length;
                winner = fin[_level].players[random];
                Token.transfer(winner, _amounteverywinner);

                fin[_level].final_winners.push(winner);
                fin[_level].amount_winners.push(_amounteverywinner);
                winning_amount[winner] += _amounteverywinner;
                total_reward = total_reward.add(_amounteverywinner);
                emit WinnerSelected(winner, _amounteverywinner);

                uint256 lastindex = (fin[_level].players.length) - 1;
                fin[_level].players[random] = fin[_level].players[lastindex];
                fin[_level].players.pop();
            }
         }
           else if (newwinner == 0) {
            uint256 _amount = (fin[_level].winningamount);

            uint256 _amounteverywinner = (_amount) / fin[_level].received_entry;

            for (uint256 i; i < fin[_level].received_entry; i++) {
                uint256 random = randomNumberSelector(_level) %
                    fin[_level].players.length;
                winner = fin[_level].players[random];
                Token.transfer(winner, _amounteverywinner);

                fin[_level].final_winners.push(winner);
                fin[_level].amount_winners.push(_amounteverywinner);
                winning_amount[winner] += _amounteverywinner;
                total_reward = total_reward.add(_amounteverywinner);
                emit WinnerSelected(winner, _amounteverywinner);
                uint256 lastindex = (fin[_level].players.length) - 1;
                fin[_level].players[random] = fin[_level].players[lastindex];
                fin[_level].players.pop();
            }
        
         
        } else {
            uint256 _newwinner = (newwinner);
            uint256 _amount = _newwinner * fin[_level].winningamount;
            uint256 _amounteverywinner = (_amount) / _newwinner;
            for (uint256 i; i < _newwinner; i++) {
                uint256 random = randomNumberSelector(_level) %
                    fin[_level].players.length;
                winner = fin[_level].players[random];
                Token.transfer(winner, _amounteverywinner);

                fin[_level].final_winners.push(winner);
                fin[_level].amount_winners.push(_amounteverywinner);
                winning_amount[winner] += _amounteverywinner;
                total_reward = total_reward.add(_amounteverywinner);
                emit WinnerSelected(winner, _amounteverywinner);

                uint256 lastindex = (fin[_level].players.length) - 1;
                fin[_level].players[random] = fin[_level].players[lastindex];
                fin[_level].players.pop();
            }
        }
        if (_level == 1 || _level == 2 || _level == 3) {
            fin[_level].time = block.timestamp + 7 days;
        } else if (_level == 4) {
            fin[_level].time = block.timestamp + 14 days;
        } else if (_level == 5 || _level == 6) {
            fin[_level].time = block.timestamp + 21 days;
        } else if (_level == 7) {
            fin[_level].time = block.timestamp + 30 days;
        } else if (_level == 8) {
            fin[_level].time = block.timestamp + 35 days;
        } else if (_level == 9) {
            fin[_level].time = block.timestamp + 50 days;
        } else if (_level == 10) {
            fin[_level].time = block.timestamp + 60 days;
        } else if (_level == 11) {
            fin[_level].time = block.timestamp + 90 days;
        } else if (_level == 12) {
            fin[_level].time = block.timestamp + 180 days;
        } else if (_level == 13) {
            fin[_level].time = block.timestamp + 270 days;
        } else if (_level == 14) {
            fin[_level].time = block.timestamp + 300 days;
        } else if (_level == 15) {
            fin[_level].time = block.timestamp + 360 days;
        } else {
            fin[_level].time = block.timestamp + 365 days;
        }

        delete fin[_level].players;
        delete fin[_level].received_entry;
        playerentry[_level];
    }

    function WithdrawToken(address _Token, uint256 _amount) public onlyOwner {
        require(
            IBEP20(_Token).transfer(msg.sender, _amount),
            "Token transfer Error!"
        );
    }

    function withdrawBNB(uint256 _amount) public onlyOwner {
        payable(msg.sender).transfer(_amount);
    }
}