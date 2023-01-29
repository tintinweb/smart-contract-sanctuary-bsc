// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interface/IERC20.sol";
import "./lib/SafeMath.sol";
import "./role/Member.sol";

import "./interface/IMinterPool.sol";
import "./interface/IInviteManager.sol";

contract TestToken is IERC20, Member {
    using SafeMath for uint256;

    event TransferEventReceiverAdd(address receiver);
    event TransferEventReceiverRemove(address receiver);

    string public override name;
    string public override symbol;
    uint8 public decimals;

    uint256 public override totalSupply;
    uint256 public remainedSupply;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    constructor() {
        name = "XXMMTT";

        symbol = "XMT";
        decimals = 18;
        remainedSupply = 50000000 * 1e18;

        mint(msg.sender, remainedSupply);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "zero address");
        require(remainedSupply >= amount, "mint too much");

        remainedSupply = remainedSupply.sub(amount);
        totalSupply = totalSupply.add(amount);
        balanceOf[to] = balanceOf[to].add(amount);

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) private {
        require(balanceOf[from] >= amount, "balance not enough");

        balanceOf[from] = balanceOf[from].sub(amount);
        totalSupply = totalSupply.sub(amount);

        emit Transfer(from, address(0), amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function burnFrom(address from, uint256 amount) external {
        require(allowance[from][msg.sender] >= amount, "allowance not enough");

        allowance[from][msg.sender] = allowance[from][msg.sender].sub(amount);
        _burn(from, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(balanceOf[from] >= amount, "balance not enough");

        balanceOf[from] = balanceOf[from].sub(amount);
        balanceOf[to] = balanceOf[to].add(amount);

        _afterTransfer(from, to, amount);

        emit Transfer(from, to, amount);
    }

    function transfer(address to, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(allowance[from][msg.sender] >= amount, "allowance not enough");

        allowance[from][msg.sender] = allowance[from][msg.sender].sub(amount);
        _transfer(from, to, amount);

        return true;
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        require(spender != address(0), "zero address");

        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function _afterTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        if (to == address(0)) {
            address minterPool = getMember("MinePool");
            if (minterPool != address(0)) {
                IMinterPool(minterPool).onTransferToBlackHole(from, to, amount);
            }
        } else {
            address inviteManager = getMember("InviteManager");
            if (inviteManager != address(0)) {
                IInviteManager(inviteManager).onTransferToNozeroAddress(
                    from,
                    to,
                    amount
                );
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Context {
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

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
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Manager.sol";

abstract contract Member is Ownable {
    //检查权限
    modifier CheckPermit(string memory permit) {
        require(manager.getUserPermit(msg.sender, permit), "no permit");
        _;
    }

    Manager public manager;

    function getMember(string memory _name) public view returns (address) {
        return manager.members(_name);
    }

    function setManager(address addr) external onlyOwner {
        manager = Manager(addr);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../role/Ownable.sol";

contract Manager is Ownable {
    /// Oracle=>"Oracle"

    mapping(string => address) public members;

    mapping(address => mapping(string => bool)) public permits; //地址是否有某个权限

    function setMember(string memory name, address member) external onlyOwner {
        members[name] = member;
    }

    function getUserPermit(address user, string memory permit)
        public
        view
        returns (bool)
    {
        return permits[user][permit];
    }

    function setUserPermit(
        address user,
        string calldata permit,
        bool enable
    ) external onlyOwner {
        permits[user][permit] = enable;
    }

    function getTimestamp() external view returns (uint256) {
        return block.timestamp;
    }
}

//SPDX-License-Identifier: UNLICENSED
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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMinterPool {
    function onTransferToBlackHole(
        address from,
        address to,
        uint256 amount
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IInviteManager {
    struct DynamicIncome {
        address user;
        uint256 rate;
    }

    function onTransferToNozeroAddress(
        address from,
        address to,
        uint256 amount
    ) external;

    function nodeConfig(address user) external returns (bool);

    function allocationUsersWhenDeal(address user)
        external
        view
        returns (address[] memory);

    function allocationDynamicIncome(address user)
        external
        view
        returns (DynamicIncome[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);
}