// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.5;

import "./../interfaces/IFutura.sol";
import "./../interfaces/IFuturaLinkFuel.sol";
import "./../utils/AccessControlled.sol";
import "./../utils/EmergencyWithdrawable.sol";

contract FuturaLinkFuel is IFuturaLinkFuel, AccessControlled, EmergencyWithdrawable {
    IFutura public futura;

    uint256 minFundsBeforeProcessing = 100000000000000000 wei;
    uint256 processRewardQueueMaxGas = 0;

    event FuelRun();

    constructor(IFutura _futura) {
        setFutura(_futura);
    }

    receive() external payable { }

    function addGas(uint256 gas) external override notUnauthorizedContract {
        run(gas);
    }

    function buyGas(uint256 gas) external onlyAdmins {
        uint remainingGasStart = gasleft();

        run(gas);
        
        uint usedGas = remainingGasStart - gasleft() + 21000 + 9700;
        payable(tx.origin).transfer(usedGas * tx.gasprice);
    }

    function run(uint256 gas) internal {
        uint256 gasLeft = gasleft();

        if (processRewardQueueMaxGas > 0) {
            uint256 consumedGas = gasLeft - gasleft();
            if (consumedGas < gas) {
                gas = gas - consumedGas;
                if (gas > processRewardQueueMaxGas) {
                    gas = processRewardQueueMaxGas;
                }

                futura.processRewardClaimQueue(gas);
            }
        }

        emit FuelRun();
    }

    function setFutura(IFutura _futura) public onlyOwner {
        require(address(_futura) != address(0), "FuturaLinkFuel: Invalid address");
        futura = _futura;
    }

    function setMinFundsBeforeProcessing(uint256 amount) external onlyOwner {
        minFundsBeforeProcessing = amount;
    }

    function setProcessRewardQueueMaxGas(uint256 maxGas) external onlyOwner {
        processRewardQueueMaxGas = maxGas;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.5;

import "./../interfaces/IBEP20.sol";

interface IFutura is IBEP20 {
    function processRewardClaimQueue(uint256 gas) external;

    function calculateRewardCycleExtension(uint256 balance, uint256 amount) external view returns (uint256);

    function claimReward() external;

    function claimReward(address addr) external;

    function isRewardReady(address user) external view returns (bool);

    function isExcludedFromFees(address addr) external view returns(bool);

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function rewardClaimQueueIndex() external view returns(uint256);

    function setFirstToken(string memory token) external;

    function setSecondToken(string memory token) external;

    function setClaimDivision(uint8 claimDivision) external;

    function getFirstToken(address user) external view returns (address);

    function getSecondToken(address user) external view returns (address);

    function isTokenAllowed(string memory symbol) external view returns (bool);

    function getTokenAddress(string memory symbol) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.5;

interface IFuturaLinkFuel {
    function addGas(uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.5;

/**
 * @dev Contract module that helps prevent calls to a function.
 */
abstract contract AccessControlled {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    address private _owner;
    bool private _isPaused;
    mapping(address => bool) private _admins;
    mapping(address => bool) private _authorizedContracts;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _status = _NOT_ENTERED;
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);

        setAdmin(_owner, true);
        setAdmin(address(this), true);
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "AccessControlled: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    /**
     * @notice Checks if the msg.sender is a contract or a proxy
     */
    modifier notContract() {
        require(!_isContract(msg.sender), "AccessControlled: contract not allowed");
        require(msg.sender == tx.origin, "AccessControlled: proxy contract not allowed");
        _;
    }

    modifier notUnauthorizedContract() {
        if (!_authorizedContracts[msg.sender]) {
            require(!_isContract(msg.sender), "AccessControlled: unauthorized contract not allowed");
            require(msg.sender == tx.origin, "AccessControlled: unauthorized proxy contract not allowed");
        }
        _;
    }

    modifier isNotUnauthorizedContract(address addr) {
        if (!_authorizedContracts[addr]) {
            require(!_isContract(addr), "AccessControlled: contract not allowed");
        }
        
        _;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "AccessControlled: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called by a non-admin account
     */
    modifier onlyAdmins() {
        require(_admins[msg.sender], "AccessControlled: caller does not have permission");
        _;
    }

    modifier notPaused() {
        require(!_isPaused, "AccessControlled: paused");
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function setAdmin(address addr, bool _isAdmin) public onlyOwner {
        _admins[addr] = _isAdmin;
    }

    function isAdmin(address addr) public view returns(bool) {
        return _admins[addr];
    }

    function setAuthorizedContract(address addr, bool isAuthorized) public onlyOwner {
        _authorizedContracts[addr] = isAuthorized;
    }
    
     function isAuthorizedContract(address addr) public view onlyOwner returns (bool) {
        return _authorizedContracts[addr];
    }

    function pause() public onlyOwner {
        _isPaused = true;
    }

    function unpause() public onlyOwner {
        _isPaused = false;
    }

    /**
     * @notice Checks if address is a contract
     * @dev It prevents contract from being targetted
     */
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.5;

import "./AccessControlled.sol";
import "./../interfaces/IBEP20.sol";

abstract contract EmergencyWithdrawable is AccessControlled {
    /**
     * @notice Withdraw unexpected tokens sent to the contract
     */
    function withdrawStuckTokens(address token) external onlyOwner {
        uint256 amount = IBEP20(token).balanceOf(address(this));
        IBEP20(token).transfer(msg.sender, amount);
    }
    
    /**
     * @notice Withdraws funds of the contract - only for emergencies
     */
    function emergencyWithdrawFunds() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}

pragma solidity >= 0.8.0;

// SPDX-License-Identifier: UNLICENSED

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}