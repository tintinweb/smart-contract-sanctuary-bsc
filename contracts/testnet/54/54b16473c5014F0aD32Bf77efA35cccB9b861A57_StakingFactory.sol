// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IToken.sol";
import "./Staking.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract StakingFactory is Context, Ownable {

    // using Counters for Counters.Counter;

    IToken public token;
    
    mapping(uint256 => Staking) public stakingList;
    uint256 private stakingId;

    constructor(address _token) {
        token = IToken(_token);
        stakingId = 0;
    }

    function createStaking() external {
        Staking _new = new Staking(address(token), address(this));
        _new.transferOwnership(owner());
        token.approve(address(_new), 10000*10**18);
        stakingList[stakingId] = _new;
        stakingId = stakingId + 1;
    }

    function getStakingAddressbyId(uint256 _stakingId) external view returns(address) {
        return address(stakingList[_stakingId]);
    }

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IToken {
    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function burnFrom(address account, uint256 amount) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IToken.sol";

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Staking is Context, Ownable {

    struct VClaimInfo {
        uint256 claimAmount;
        uint256 claimTime;
    }

    IToken public token;
    address public factoryAddr;
    uint256 public period;
    address public stakeWallet;
    uint256 private stakeTime;
    uint256 private vStakeTime;
    uint256 private stakeAmount;
    uint256 private claimAmount;
    uint256 private vClaimAmount;

    address[] public whiteList;
    mapping(address => VClaimInfo) public validators;
    uint256 vClaimTime;
    bool _canClaim;

    constructor(address _token, address _factoryAddr) {
        token = IToken(_token);
        factoryAddr = _factoryAddr;
        period = 60;
        _canClaim = true;
    }

    function setPeriod(uint256 _period) external onlyOwner {
        period = _period;
    }

    function stake(uint256 amount) external {
        require(msg.sender == stakeWallet, 'This wallet cannot stake' );
        uint256 _amount = token.balanceOf(msg.sender);
        require(_amount >= amount, 'The wallet has less amount ');
        token.transferFrom(msg.sender, address(this), amount);
        token.transferFrom(factoryAddr, address(this), amount * 10);
        stakeTime = block.timestamp;
        vStakeTime = stakeTime;
        stakeAmount = amount;
        claimAmount = amount * 11 / 2;
        vClaimAmount  = amount * 11 / 2;
    }

    function claim() external {
        require(msg.sender == stakeWallet, 'This wallet cannot claim');
        require(_canClaim == true, 'This wallet cannot claim anymore');
        require(claimAmount > 0, "There is no claimable Amount");
        require(
            block.timestamp >= stakeTime + period,
            "Not Claim Time"
        );
        uint256 _transferamount = 0;

        if (claimAmount <= stakeAmount / 8 * 11 + 3) {
            _transferamount = claimAmount;
            claimAmount = 0;
        } else {
            _transferamount = stakeAmount / 8 * 11;
            claimAmount -= stakeAmount / 8 * 11;
        }

        token.transfer(msg.sender, _transferamount);

        stakeTime = block.timestamp;
    }


    function addValidatorWhitelist(address[] calldata _users) external onlyOwner {
        address[] storage _wlist = whiteList;
        for(uint256 i = 0; i < _users.length; i ++)
        {
            VClaimInfo storage _vinfo = validators[_users[i]];
            _vinfo.claimAmount = vClaimAmount / _users.length;
            _vinfo.claimTime = stakeTime;
            _wlist.push(_users[i]);
        }
    }


    function validatorClaim() external {
        bool isClaim = validatorCheck(msg.sender);
        require(isClaim == true, "This is not validator");
        require(_canClaim == true, "Cannot claim anymore");
        
        VClaimInfo storage _vClaim = validators[msg.sender];
        require(_vClaim.claimAmount > 0, "There's no token for claim");
        require(block.timestamp >= _vClaim.claimTime + period, "Not Claim Time");

        uint256 _transferamount = 0;

        if (_vClaim.claimAmount <= stakeAmount  / 8 * 11 / whiteList.length + 3) {
            _transferamount = _vClaim.claimAmount;
            _vClaim.claimAmount = 0;
        } else {
            _transferamount = stakeAmount / 8 * 11 / whiteList.length;
            _vClaim.claimAmount -= stakeAmount / 8 * 11 / whiteList.length;
        }

        token.transfer(msg.sender, _transferamount);

        _vClaim.claimTime = block.timestamp;
    }

    function validatorCheck(address addr) public view returns (bool) {
        for(uint256 i = 0; i < whiteList.length; i ++)
        {
            if(whiteList[i] == addr)
                return true;
        }
        return false;
    }

    function withdrawFunds() external onlyOwner {
        uint256 _tokenAmount = token.balanceOf(address(this));
        token.transfer(owner(), _tokenAmount);
    }

    function addStakeWallet(address _stakeWallet) external onlyOwner {
        stakeWallet = _stakeWallet;
        stakeAmount = 0;
        claimAmount = 0;
        vClaimAmount = 0;
    }

    function projectOver() external onlyOwner{
        _canClaim = false;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
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