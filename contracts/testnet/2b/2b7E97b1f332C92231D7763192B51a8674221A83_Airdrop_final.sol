/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

contract Airdrop_final {
    using Counters for Counters.Counter;
    address payable public admin;
    mapping(address => bool) public processedAirdrops;
    IBEP20 public token;
    uint256 private releasetime;
    uint256 private currentAirdropAmount;
    uint256 public maxAirdropAmount = 100000000000000 * (10**16);
    Counters.Counter private _claimdropNumber;
    Counters.Counter private _unlockedDropsNumber;
    uint256 Supplyamount = 20000000 * (10**16);
    struct Drops {
        uint256 dropId;
        IBEP20 token;
        address claimer;
        uint256 amount;
        uint256 releasetime;
        bool withdrawn;
    }
    Drops[] alldrops;
    event Claimtoken(
        uint256 dropId,
        IBEP20 token,
        address claimer,
        uint256 amount,
        uint256 unlockTime
    );
    event RewardToken(
        uint256 dropId,
        IBEP20 token,
        address claimer,
        uint256 amount
    );
    event StartAirdrop(address token, uint256 airdropamount);
    modifier onlyadmin() {
        if (msg.sender == admin) {}
        _;
    }

    constructor(address _tokenAddr) {
        require(_tokenAddr != address(0));
        token = IBEP20(_tokenAddr);
        admin = payable(msg.sender);
    }

    function RewardTokens() public {
        require(payable(msg.sender) != admin);
        require(
            processedAirdrops[msg.sender] == false,
            "airdrop already processed"
        );
        require(
            currentAirdropAmount + Supplyamount <= maxAirdropAmount,
            "airdropped 100% of the tokens"
        );
        processedAirdrops[msg.sender] = true;
        releasetime = block.timestamp + 60;
        uint256 currentdropId = _unlockedDropsNumber.current();
        alldrops.push(
            Drops(
                currentdropId,
                token,
                msg.sender,
                Supplyamount,
                releasetime,
                false
            )
        );
        _unlockedDropsNumber.increment();
        emit Claimtoken(
            currentdropId,
            token,
            msg.sender,
            Supplyamount,
            releasetime
        );
    }

    function ClaimReward(uint256 dropId) public {
        Drops memory drops = alldrops[dropId];
        require(drops.claimer == msg.sender, "you are not owner of tokens!");
        require(drops.withdrawn == false, "you already withdrawn your tokens!");
        require(
            drops.releasetime < block.timestamp,
            "you must wait for unlock!"
        );
        require(msg.sender != admin, "admin cannot claim token");
        alldrops[dropId].withdrawn = true;
        IBEP20(token).transfer(msg.sender, Supplyamount);
        emit RewardToken(dropId, IBEP20(token), msg.sender, drops.amount);
    }

    function getamount(uint256 dropId)
        public
        view
        returns (
            address,
            uint256,
            uint256,
            uint256
        )
    {
        Drops storage drop = alldrops[dropId];
        require(drop.dropId == dropId);
        return (drop.claimer, drop.dropId, drop.amount, drop.releasetime);
    }
}