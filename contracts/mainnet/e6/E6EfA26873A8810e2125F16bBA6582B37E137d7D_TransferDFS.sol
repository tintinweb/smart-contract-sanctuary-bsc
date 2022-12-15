/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

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

    function sqrrt(uint256 a) internal pure returns (uint256 c) {
        if (a > 3) {
            c = a;
            uint256 b = add(div(a, 2), 1);
            while (b < c) {
                c = b;
                b = div(add(div(a, b), b), 2);
            }
        } else if (a != 0) {
            c = 1;
        }
    }
}

contract Context {
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
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

interface IDFS {
    function transfer(address to, uint256 amount) external;

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external;

    function balanceOf(address _address) external view returns (uint256);
}

contract TransferDFS is Ownable {
    using SafeMath for uint256;
    IDFS public Dfs;
    uint256 public reminder = 1e15;
    uint256 public bnbAmount = 1e15;
    address public from;
    mapping(address => bool) _admin;

    constructor(address _dfs) {
        Dfs = IDFS(_dfs);
        _admin[msg.sender] = true;
    }

    receive() external payable {}

    modifier onlyAdmin() {
        require(_admin[msg.sender], "Not admin");
        _;
    }
    function setDFS(address _dfs) public onlyAdmin {
        Dfs = IDFS(_dfs);
    }

    function setFrom(address _from) public onlyAdmin {
        from = _from;
    }

    function setReminder(uint256 _reminder) public onlyAdmin {
        reminder = _reminder;
    }

    function setAdmin(address[] memory _admins) public onlyOwner {
        for (uint32 i = 0; i < _admins.length; ++i) {
            if (!_admin[_admins[i]]) {
                _admin[_admins[i]] = true;
            }
        }
    }
    function withdraw(address _to) public onlyAdmin {
      uint256 balance = Dfs.balanceOf(address(this));
      Dfs.transfer(_to, balance);
    }
    function getRandom(uint256 i) public view returns (uint256) {
        uint256 randomNumber = uint256(
            keccak256(abi.encodePacked(i, block.timestamp, msg.sender))
        );
        return randomNumber;
    }

    function transfer(address[] memory addresses) public onlyAdmin {
        for (uint256 i = 0; i < addresses.length; ++i) {
            uint256 random = getRandom(i);
            uint256 amount = random.mod(reminder);
            require(Dfs.balanceOf(from) >= amount, "Not enough balance");
            Dfs.transferFrom(from, addresses[i], amount);
        }
    }
}