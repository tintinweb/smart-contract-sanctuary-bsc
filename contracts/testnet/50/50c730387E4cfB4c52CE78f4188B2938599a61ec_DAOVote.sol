// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./Delegatee.sol";
import "./interfaces/IDelegatee.sol";
import "./interfaces/IVesting.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DAOVote is Ownable {
    address public immutable angelToken;
    address public immutable privateToken;
    address public immutable token;
    uint256 public minClaim;
    mapping(uint256 => uint256) public pass; // 0 = Token, 1 = Angel, 2 = Private
    mapping(uint256 => uint256) public notPass;
    mapping(address => uint256) public userVoted;
    mapping(address => address) public delegateeAngel;
    mapping(address => address) public delegateePrivate;
    address[] public angelVoted;
    address[] public privateVoted;
    mapping(address => mapping(uint256 => bool)) public alreadyVoted;

    event OnDeposit (address adr, uint256 amount);
    event OnVote (uint256 _amount, bool _pass);
    event OnSpecialVote (uint256 _amount, bool _pass, uint256 _type);
    event OnIniDelegatee (address _adr, uint256 _type, address _delegatee);

    constructor (address _angel, address _private, address _token) {
        angelToken = _angel;
        privateToken = _private;
        token = _token;
        minClaim = 1000 * 10 ** 18;
    }

    function totalVote () public view returns (uint256) {
        return pass[0] + notPass[0] + pass[1] + notPass[1] + pass[2] + notPass[2];
    }

    function sumPass () public view returns (uint256) {
        return pass[0] + pass[1] + pass[2];
    }

    function sumNotPass () public view returns (uint256) {
        return notPass[0] + notPass[1] + notPass[2];
    }

    function setMinClaim (uint256 _amount) public onlyOwner {
        require(_amount >= 0, "Invalid amount");
        minClaim = _amount;
    }

    function vote (uint256 _amount, bool _pass) public {
        require(_amount >= 0, "Invalid amount");
        require(IERC20(token).transferFrom(_msgSender(), address(this), _amount), "Failed transfer");
        if(_pass == true) {
            pass[0] += _amount;
        } else {
            notPass[0] += _amount;
        }
        userVoted[_msgSender()] += _amount;
        emit OnVote (_amount, _pass);
    }

    function specialVote (bool _pass, uint256 _type) public {
        require(_type == 1 || _type == 2, "Invalid type");
        require(alreadyVoted[_msgSender()][_type] != true, "Already voted");
        address _vesting;
        address _delegatee;
        if (_type == 1) {
            _vesting = angelToken;
            _delegatee = delegateeAngel[_msgSender()];
        }
        if (_type == 2) {
            _vesting = privateToken;
            _delegatee = delegateePrivate[_msgSender()];
        }
        require(IVesting(_vesting).vestingAmount(_delegatee) >= 0, "Not Delegated yet");
        uint256 _amount = IVesting(_vesting).vestingAmount(_delegatee);
        if(_pass == true) {
            pass[_type] += _amount;
        } else {
            notPass[_type] += _amount;
        }
        alreadyVoted[_msgSender()][_type] = true;
        emit OnSpecialVote (_amount, _pass, _type);
    }

    function iniDelegatee (uint256 _type) public {
        require(_type == 1 || _type == 2, "Invalid type");
        address _vesting;
        if (_type == 1) {
            _vesting = angelToken;
            require(delegateeAngel[_msgSender()] == address(0), "Already initialized");
        }
        if (_type == 2) {
            _vesting = privateToken;
            require(delegateePrivate[_msgSender()] == address(0), "Already initialized");
        }
        address _delegatee = address(new Delegatee(_vesting, token, address(this)));
        if (_type == 1) {
            delegateeAngel[_msgSender()] = _delegatee;
            angelVoted.push(_msgSender());
        }
        if (_type == 2) {
            delegateePrivate[_msgSender()] = _delegatee;
            privateVoted.push(_msgSender());
        }
        emit OnIniDelegatee (_msgSender(), _type, _delegatee);
    }

    function changeController (address _to) public onlyOwner {
        for (uint256 i = 0; i <= angelVoted.length; i++) {
            IDelegatee(delegateeAngel[angelVoted[i]]).setController(_to);
        }
        for (uint256 i = 0; i <= privateVoted.length; i++) {
            IDelegatee(delegateePrivate[privateVoted[i]]).setController(_to);
        }
    }

    function claimVesting () public onlyOwner {
        for (uint256 i = 0; i <= angelVoted.length; i++) {
            if (IDelegatee(delegateeAngel[angelVoted[i]]).getWithdrawable() >= minClaim) {
                IDelegatee(delegateeAngel[angelVoted[i]]).claimVesting(_msgSender());
            }
        }
        for (uint256 i = 0; i <= privateVoted.length; i++) {
            if (IDelegatee(delegateeAngel[privateVoted[i]]).getWithdrawable() >= minClaim) {
                IDelegatee(delegateePrivate[privateVoted[i]]).claimVesting(_msgSender());
            }
        }
    }

    function withdraw (address _token) public onlyOwner {
        IERC20(_token).transfer(_msgSender(), IERC20(_token).balanceOf(address(this)));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface IVesting {
    function changeWallet(address _to) external;

    function claimVesting() external;

    function getWithdrawAmount() external view returns (uint256);

    function fullAmount(address _adr) external view returns (uint256);

    function vestingAmount(address _adr) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface IDelegatee {
    function setController (address _adr) external;

    function changeVesting (address _to) external;

    function claimVesting (address _to) external;

    function getWithdrawable() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IVesting.sol";

contract Delegatee is Ownable {
    address public immutable vesting;
    address public immutable token;
    address public controller;

    modifier onlyController {
        require(controller == _msgSender(), "No permission");
        _;
    }

    constructor (address _vesting, address _token, address _controller) {
        vesting = _vesting;
        token = _token;
        controller = _controller;
    }

    function setController (address _adr) public onlyOwner {
        require(_adr != address(0), "Address is not valid");
        controller = _adr;
    }

    function changeVesting (address _to) public onlyController {
        IVesting(vesting).changeWallet(_to);
    }

    function claimVesting (address _to) public onlyController {
        IVesting(vesting).claimVesting();
        require(IERC20(token).transfer(_to, IERC20(token).balanceOf(address(this))), "Failed transfer");
    }

    function getWithdrawable () public view returns (uint256) {
        return IVesting(vesting).getWithdrawAmount();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
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