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
    uint256 public period;
    address private stakeWallet;
    uint256 private stakeTime;
    uint256 private vStakeTime;
    uint256 private stakeAmount;
    uint256 private claimAmount;
    uint256 private vClaimAmount;

    address[] public whiteList;
    mapping(address => VClaimInfo) public validators;
    uint256 vClaimTime;
    bool _canClaim;

    constructor(address _token) {
        token = IToken(_token);
        period = 60;
        _canClaim = true;
    }

    function setPeriod(uint256 _period) external onlyOwner {
        period = _period;
    }

    function stake(uint256 amount) external {
        require(msg.sender == stakeWallet, 'This wallet cannot stake');
        token.transferFrom(msg.sender, address(this), amount);
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

        if (claimAmount <= (stakeAmount * _turn) / 8 * 11) {
            _transferamount = claimAmount;
            claimAmount = 0;
        } else {
            _transferamount = (stakeAmount * _turn) / 8 * 11;
            claimAmount -= (stakeAmount * _turn) / 8 * 11;
        }

        token.transfer(msg.sender, _transferamount);

        stakeTime = stakeTime + _turn * period;
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

        if (_vClaim.claimAmount <= (stakeAmount * _turn) / 8 * 11 / whiteList.length) {
            _transferamount = _vClaim.claimAmount;
            _vClaim.claimAmount = 0;
        } else {
            _transferamount = (stakeAmount * _turn) / 8 * 11 / whiteList.length;
            _vClaim.claimAmount -= (stakeAmount * _turn) / 8 * 11 / whiteList.length;
        }

        token.transfer(msg.sender, _transferamount);

        _vClaim.claimTime = _vClaim.claimTime + _turn * period;
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IToken {
    function approve(address to, uint256 amount) external;

    function transfer(address recipient, uint256 amount) external;

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;

    function balanceOf(address account) external view returns (uint256);
}