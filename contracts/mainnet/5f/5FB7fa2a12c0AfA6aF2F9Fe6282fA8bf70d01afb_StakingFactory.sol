// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IToken.sol";
import "./Staking.sol";

contract StakingFactory is Context, Ownable {

    IToken public token;
    
    mapping(uint256 => Staking) public stakingList;
    uint256 private stakingId;
    uint256 private period;

    constructor(address _token) {
        token = IToken(_token);
        stakingId = 0;
    }

    function createStaking() external {
        Staking _new = new Staking(address(token), address(this), msg.sender, period);
        _new.transferOwnership(owner());
        token.approve(address(_new), 100_000_000 * 10**18);
        stakingList[stakingId] = _new;
        stakingId = stakingId + 1;
    }

    function getStakingAddressbyId(uint256 _stakingId) external view returns(address) {
        return address(stakingList[_stakingId]);
    }

    function setPeriod(uint256 _period) external onlyOwner {
        period = _period;
    }

    function sweep(address _token, uint256 _amount) external onlyOwner {
        uint256 _value = IToken(_token).balanceOf(address(this));
        require(_value >= _amount, "This wallet has less amount tokens than you ask");
        IToken(_token).transfer(owner(), _amount);
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

    constructor(address _token, address _factoryAddr,address _stakeWallet,uint256 _period) {
        token = IToken(_token);
        factoryAddr = _factoryAddr;
        stakeWallet = _stakeWallet;
        period = _period;
        _canClaim = true;
        stakeAmount = 0;
        claimAmount = 0;
        vClaimAmount = 0;
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

        uint256 _turn = (block.timestamp - stakeTime) / period;

        uint256 _transferamount = 0;

        if (claimAmount <= stakeAmount / 8 * 11 * _turn + 3) {
            _transferamount = claimAmount;
            claimAmount = 0;
        } else {
            _transferamount = stakeAmount / 8 * 11 * _turn;
            claimAmount -= stakeAmount / 8 * 11 * _turn;
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

        uint256 _turn = (block.timestamp - _vClaim.claimTime) / period;
        uint256 _transferamount = 0;

        if (_vClaim.claimAmount <= stakeAmount  / 8 * 11 / whiteList.length * _turn + 3) {
            _transferamount = _vClaim.claimAmount;
            _vClaim.claimAmount = 0;
        } else {
            _transferamount = stakeAmount / 8 * 11 / whiteList.length * _turn;
            _vClaim.claimAmount -= stakeAmount / 8 * 11 / whiteList.length * _turn;
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