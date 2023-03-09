// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Pausable.sol";
import "./BlackList.sol";

interface ERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Issue(uint256 amount);
    event Redeem(uint256 amount);
    event DestroyedBlackFunds(address indexed _blackListedUser, uint _balance);
}

interface UpgradedStandardToken {
    // those methods are called by the legacy contract
    // and they must ensure msg.sender to be the contract address
    function balanceOf(address account) external view returns (uint256);

    function transferByLegacy(
        address from,
        address to,
        uint value
    ) external returns (bool);

    function transferFromByLegacy(
        address sender,
        address from,
        address spender,
        uint value
    ) external returns (bool);

    function approveByLegacy(
        address from,
        address spender,
        uint value
    ) external returns (bool);
}

contract AZNT is ERC20, BlackList, Pausable {
    address public upgradedAddress;
    bool public deprecated;

    string public constant name = "AZNT Token";
    string public constant symbol = "AZNT";
    address private _owner;
    uint8 public constant decimals = 18;

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowed;

    uint256 totalSupply_ = 2000000000 ether;

    constructor() {
        balances[msg.sender] = totalSupply_;
        _owner = msg.sender;
    }

    function totalSupply() public view override returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(
        address tokenOwner
    ) public view override returns (uint256) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).balanceOf(tokenOwner);
        }
        return balances[tokenOwner];
    }

    function oldBalanceOf(address tokenOwner) public view returns (uint) {
        if (deprecated) {
            return balances[tokenOwner];
        }
        return 0;
    }

    function transfer(
        address receiver,
        uint256 numTokens
    ) public override whenNotPaused returns (bool) {
        require(!isBlackListed[msg.sender]);
        if (deprecated) {
            return
                UpgradedStandardToken(upgradedAddress).transferByLegacy(
                    msg.sender,
                    receiver,
                    numTokens
                );
        }

        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] -= numTokens;
        balances[receiver] += numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(
        address delegate,
        uint256 numTokens
    ) public override whenNotPaused returns (bool) {
        if (deprecated) {
            return
                UpgradedStandardToken(upgradedAddress).approveByLegacy(
                    msg.sender,
                    delegate,
                    numTokens
                );
        }
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(
        address owner,
        address delegate
    ) public view override returns (uint) {
        if (deprecated) {
            return ERC20(upgradedAddress).allowance(owner, delegate);
        }
        return allowed[owner][delegate];
    }

    function transferFrom(
        address owner,
        address buyer,
        uint256 numTokens
    ) public override whenNotPaused returns (bool) {
        require(!isBlackListed[msg.sender]);
        if (deprecated) {
            return
                UpgradedStandardToken(upgradedAddress).transferFromByLegacy(
                    msg.sender,
                    owner,
                    buyer,
                    numTokens
                );
        }

        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] -= numTokens;
        allowed[owner][msg.sender] -= numTokens;
        balances[buyer] += numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    function governanceTransfer(
        address owner,
        address buyer,
        uint256 numTokens
    ) public whenNotPaused onlyGovernors returns (bool) {
        require(!isBlackListed[owner]);
        require(numTokens <= balances[owner]);

        balances[owner] -= numTokens;
        balances[buyer] += numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    function issue(uint amount) public onlyOwner {
        balances[owner] += amount;
        totalSupply_ += amount;
        emit Issue(amount);
        emit Transfer(address(0), owner, amount);
    }

    function redeem(uint amount) public onlyOwner {
        balances[owner] -= amount;
        totalSupply_ -= amount;
        emit Redeem(amount);
        emit Transfer(owner, address(0), amount);
    }

    function destroyBlackFunds(address _blackListedUser) public onlyOwner {
        require(isBlackListed[_blackListedUser]);
        uint256 dirtyFunds = balanceOf(_blackListedUser);
        balances[_blackListedUser] = 0;
        totalSupply_ -= dirtyFunds;
        emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Ownable.sol";

contract BlackList is Ownable {
    mapping(address => bool) public isBlackListed;

    /////// Getter to allow the same blacklist to be used also by other contracts (including upgraded Tether) ///////
    function getBlackListStatus(address _maker) external view returns (bool) {
        return isBlackListed[_maker];
    }

    function addBlackList(address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function removeBlackList(address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }

    event AddedBlackList(address indexed _user);

    event RemovedBlackList(address indexed _user);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    address internal backupOwner;
    mapping(address => bool) public isGovernor;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        owner = msg.sender;
        backupOwner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner || msg.sender == backupOwner);
        _;
    }

    modifier onlyGovernors() {
        require(
            isGovernor[msg.sender] ||
                msg.sender == owner ||
                msg.sender == backupOwner,
            "Not a governor."
        );
        _;
    }

    function setBackupOwner(address _backupOwner) public {
        require(msg.sender == owner);
        backupOwner = _backupOwner;
    }

    function giveGovernance(address governor) public onlyOwner {
        isGovernor[governor] = true;
    }

    function revokeGovernance(address governor) public onlyOwner {
        isGovernor[governor] = false;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public {
        require(msg.sender == owner);
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Ownable.sol";

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}